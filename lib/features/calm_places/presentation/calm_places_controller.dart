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

  const CalmPlacesState({
    this.places = const [],
    this.weather,
    this.userLocation,
    this.selectedCategory,
    this.isLoading = false,
    this.error,
    this.savedPlaceIds = const {},
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
    bool clearCategory = false,
  }) {
    return CalmPlacesState(
      places: places ?? this.places,
      weather: weather ?? this.weather,
      userLocation: userLocation ?? this.userLocation,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedPlaceIds: savedPlaceIds ?? this.savedPlaceIds,
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
      // Get user location
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

      // Fetch weather and places in parallel
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

      // Load saved preferences for score boost
      final savedCategories = <String>{};
      for (final place in rawPlaces) {
        if (state.savedPlaceIds.contains(place.id)) {
          savedCategories.add(place.category.name);
        }
      }

      // Compute calm scores for all places
      final scoredPlaces = rawPlaces.map((place) {
        return CalmScoreEngine.computeScore(
          place: place,
          weather: weather,
          savedCategories: savedCategories,
        );
      }).toList();

      // Sort by calm score (highest first)
      scoredPlaces.sort((a, b) => b.calmScore.compareTo(a.calmScore));

      state = state.copyWith(
        places: scoredPlaces,
        weather: weather,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error loading places: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Filter by category
  void filterByCategory(PlaceCategory? category) {
    if (category == state.selectedCategory) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  /// Save a place locally
  Future<void> savePlace(String placeId) async {
    final updated = {...state.savedPlaceIds, placeId};
    state = state.copyWith(savedPlaceIds: updated);
    await _persistSavedPlaces(updated);
  }

  /// Remove a saved place
  Future<void> removeSavedPlace(String placeId) async {
    final updated = {...state.savedPlaceIds}..remove(placeId);
    state = state.copyWith(savedPlaceIds: updated);
    await _persistSavedPlaces(updated);
  }

  /// Check if a place is saved
  bool isPlaceSaved(String placeId) => state.savedPlaceIds.contains(placeId);

  /// Get user's current GPS location
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

  /// Load saved place IDs from SharedPreferences
  void _loadSavedPlaces() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final savedList = prefs.getStringList('saved_calm_places') ?? [];
      state = state.copyWith(savedPlaceIds: savedList.toSet());
    } catch (_) {}
  }

  /// Persist saved place IDs
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
