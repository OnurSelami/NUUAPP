import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import '../../stats/presentation/stats_controller.dart';
import '../data/calm_places_service.dart';
import '../data/calm_score_engine.dart';
import '../data/models/calm_place.dart';
import '../data/models/weather_data.dart';

/// State for Calm Places feature
class CalmPlacesState {
  final List<CalmPlace> places;
  final WeatherData? weather;
  final LatLng? userLocation;
  final PlaceCategory? selectedCategory;
  final bool isLoading;
  final String? error;
  final Set<String> savedPlaceIds;
  final CalmPlace? goModePlace; // Single best recommendation
  final bool isGoModeLoading;

  const CalmPlacesState({
    this.places = const [],
    this.weather,
    this.userLocation,
    this.selectedCategory,
    this.isLoading = false,
    this.error,
    this.savedPlaceIds = const {},
    this.goModePlace,
    this.isGoModeLoading = false,
  });

  /// Top-scored places
  List<CalmPlace> get bestNow {
    final sorted = List<CalmPlace>.from(places)
      ..sort((a, b) => b.calmScore.compareTo(a.calmScore));
    return sorted.take(3).toList();
  }

  /// Filtered by selected category (or all)
  List<CalmPlace> get filteredPlaces {
    if (selectedCategory == null) return places;
    return places.where((p) => p.category == selectedCategory).toList();
  }

  CalmPlacesState copyWith({
    List<CalmPlace>? places,
    WeatherData? weather,
    LatLng? userLocation,
    PlaceCategory? selectedCategory,
    bool? isLoading,
    String? error,
    Set<String>? savedPlaceIds,
    CalmPlace? goModePlace,
    bool? isGoModeLoading,
    bool clearCategory = false,
    bool clearGoMode = false,
  }) {
    return CalmPlacesState(
      places: places ?? this.places,
      weather: weather ?? this.weather,
      userLocation: userLocation ?? this.userLocation,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedPlaceIds: savedPlaceIds ?? this.savedPlaceIds,
      goModePlace: clearGoMode ? null : (goModePlace ?? this.goModePlace),
      isGoModeLoading: isGoModeLoading ?? this.isGoModeLoading,
    );
  }
}

/// Riverpod controller for Calm Places
class CalmPlacesController extends Notifier<CalmPlacesState> {
  final CalmPlacesService _service = CalmPlacesService();

  @override
  CalmPlacesState build() {
    _loadSavedPlaces();
    return const CalmPlacesState();
  }

  /// Load nearby places with location + weather
  Future<void> loadNearbyPlaces() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final position = await _getUserLocation();
      if (position == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission required',
        );
        return;
      }

      final userLoc = LatLng(position.latitude, position.longitude);
      state = state.copyWith(userLocation: userLoc);

      final results = await Future.wait([
        _service.fetchWeather(userLoc),
        _service.fetchNearbyPlaces(
          userLocation: userLoc,
          radiusMeters: 5000,
          category: state.selectedCategory,
        ),
      ]);

      final weather = results[0] as WeatherData?;
      final rawPlaces = results[1] as List<CalmPlace>;

      final savedCategories = <String>{};
      for (final place in rawPlaces) {
        if (state.savedPlaceIds.contains(place.id)) {
          savedCategories.add(place.category.name);
        }
      }

      // Compute calm scores (now includes timeline)
      final scoredPlaces = rawPlaces.map((place) {
        return CalmScoreEngine.computeScore(
          place: place,
          weather: weather,
          savedCategories: savedCategories,
        );
      }).toList();

      scoredPlaces.sort((a, b) => b.calmScore.compareTo(a.calmScore));

      // Attach stories from local storage
      final placesWithStories = scoredPlaces.map((p) {
        final stories = _getStoriesForPlace(p.id);
        return stories.isNotEmpty ? p.copyWith(stories: stories) : p;
      }).toList();

      state = state.copyWith(
        places: placesWithStories,
        weather: weather,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error loading places: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── GO MODE ──────────────────────────────────────────

  /// Find the single best place right now and set it
  Future<void> goMode() async {
    state = state.copyWith(isGoModeLoading: true, clearGoMode: true);

    try {
      // Ensure places are loaded
      if (state.places.isEmpty) {
        await loadNearbyPlaces();
      }

      if (state.places.isEmpty) {
        state = state.copyWith(isGoModeLoading: false);
        return;
      }

      // Get recently visited IDs
      final recentIds = _getRecentlyVisitedIds();

      // Get preferred categories from saved places
      final preferredCats = <String>{};
      for (final place in state.places) {
        if (state.savedPlaceIds.contains(place.id)) {
          preferredCats.add(place.category.name);
        }
      }

      // Compute Go scores and find the best
      CalmPlace? best;
      double bestScore = -1;

      for (final place in state.places) {
        if (!place.isOpenNow) continue; // Skip closed places

        final goScore = CalmScoreEngine.computeGoScore(
          place: place,
          preferredCategories: preferredCats,
          recentlyVisitedIds: recentIds,
        );

        if (goScore > bestScore) {
          bestScore = goScore;
          best = place;
        }
      }

      if (best != null) {
        _addToRecentlyVisited(best.id);
      }

      state = state.copyWith(
        goModePlace: best,
        isGoModeLoading: false,
      );
    } catch (e) {
      debugPrint('Go Mode error: $e');
      state = state.copyWith(isGoModeLoading: false);
    }
  }

  // ─── MICRO STORIES ────────────────────────────────────

  /// Add a story to a place
  Future<void> addStory({
    required String placeId,
    required String text,
    required String tag,
  }) async {
    final story = CalmStory(
      id: '${placeId}_${DateTime.now().millisecondsSinceEpoch}',
      placeId: placeId,
      text: text.length > 140 ? text.substring(0, 140) : text,
      author: 'You',
      timestamp: DateTime.now(),
      calmScoreAtTime: state.places
          .where((p) => p.id == placeId)
          .firstOrNull
          ?.calmScore ?? 0,
      tag: tag,
    );

    _persistStory(story);

    // Update the place in state with the new story
    final updatedPlaces = state.places.map((p) {
      if (p.id == placeId) {
        return p.copyWith(stories: [story, ...p.stories]);
      }
      return p;
    }).toList();

    state = state.copyWith(places: updatedPlaces);
  }

  /// Get stories for a place from local storage
  List<CalmStory> _getStoriesForPlace(String placeId) {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final raw = prefs.getString('calm_stories_$placeId');
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.map((e) => CalmStory.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Persist a story to SharedPreferences
  void _persistStory(CalmStory story) {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final key = 'calm_stories_${story.placeId}';
      final raw = prefs.getString(key);
      final List existing = raw != null ? jsonDecode(raw) as List : [];
      existing.insert(0, story.toJson());
      // Keep max 20 stories per place
      if (existing.length > 20) existing.removeRange(20, existing.length);
      prefs.setString(key, jsonEncode(existing));
    } catch (_) {}
  }

  // ─── RECENTLY VISITED ─────────────────────────────────

  Set<String> _getRecentlyVisitedIds() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final list = prefs.getStringList('go_mode_recent') ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  void _addToRecentlyVisited(String placeId) {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final list = prefs.getStringList('go_mode_recent') ?? [];
      list.insert(0, placeId);
      // Keep last 10
      final trimmed = list.take(10).toList();
      prefs.setStringList('go_mode_recent', trimmed);
    } catch (_) {}
  }

  // ─── EXISTING METHODS ─────────────────────────────────

  void filterByCategory(PlaceCategory? category) {
    if (category == state.selectedCategory) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  Future<void> savePlace(String placeId) async {
    final updated = {...state.savedPlaceIds, placeId};
    state = state.copyWith(savedPlaceIds: updated);
    await _persistSavedPlaces(updated);
  }

  Future<void> removeSavedPlace(String placeId) async {
    final updated = {...state.savedPlaceIds}..remove(placeId);
    state = state.copyWith(savedPlaceIds: updated);
    await _persistSavedPlaces(updated);
  }

  bool isPlaceSaved(String placeId) => state.savedPlaceIds.contains(placeId);

  Future<Position?> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  void _loadSavedPlaces() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final savedList = prefs.getStringList('saved_calm_places') ?? [];
      state = state.copyWith(savedPlaceIds: savedList.toSet());
    } catch (_) {}
  }

  Future<void> _persistSavedPlaces(Set<String> ids) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setStringList('saved_calm_places', ids.toList());
    } catch (_) {}
  }
}

/// Main provider for Calm Places
final calmPlacesProvider =
    NotifierProvider<CalmPlacesController, CalmPlacesState>(() {
  return CalmPlacesController();
});
