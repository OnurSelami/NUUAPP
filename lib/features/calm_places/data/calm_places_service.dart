import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import 'models/calm_place.dart';
import 'models/weather_data.dart';

/// Service for fetching nearby calm places and weather data
/// Uses: Overpass API (OSM), Nominatim, Open-Meteo
class CalmPlacesService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const String _openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Fetch nearby calm places from Overpass API (OpenStreetMap)
  Future<List<CalmPlace>> fetchNearbyPlaces({
    required LatLng userLocation,
    double radiusMeters = 5000,
    PlaceCategory? category,
  }) async {
    try {
      final query = _buildOverpassQuery(
        lat: userLocation.latitude,
        lng: userLocation.longitude,
        radius: radiusMeters,
        category: category,
      );

      final response = await http.post(
        Uri.parse(_overpassUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('Overpass API error: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>? ?? [];
      
      final Distance distance = const Distance();
      final places = <CalmPlace>[];

      for (final element in elements) {
        final place = _parseElement(element, userLocation, distance);
        if (place != null) {
          places.add(place);
        }
      }

      // Sort by distance
      places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return places;
    } catch (e) {
      debugPrint('Error fetching nearby places: $e');
      return [];
    }
  }

  /// Fetch current weather from Open-Meteo (free, no API key)
  Future<WeatherData?> fetchWeather(LatLng location) async {
    try {
      final url = '$_openMeteoUrl'
          '?latitude=${location.latitude}'
          '&longitude=${location.longitude}'
          '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,is_day';

      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('Open-Meteo error: ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return WeatherData.fromOpenMeteo(data);
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      return null;
    }
  }

  /// Build Overpass QL query for calm-related places
  String _buildOverpassQuery({
    required double lat,
    required double lng,
    required double radius,
    PlaceCategory? category,
  }) {
    final filters = <String>[];

    if (category != null) {
      filters.addAll(_categoryToOverpassTags(category));
    } else {
      // All calm categories
      filters.addAll([
        'node["leisure"="park"](around:$radius,$lat,$lng);',
        'way["leisure"="park"](around:$radius,$lat,$lng);',
        'node["leisure"="garden"](around:$radius,$lat,$lng);',
        'way["leisure"="garden"](around:$radius,$lat,$lng);',
        'node["natural"="wood"](around:$radius,$lat,$lng);',
        'way["natural"="wood"](around:$radius,$lat,$lng);',
        'node["natural"="beach"](around:$radius,$lat,$lng);',
        'way["natural"="beach"](around:$radius,$lat,$lng);',
        'node["amenity"="cafe"](around:$radius,$lat,$lng);',
        'node["amenity"="library"](around:$radius,$lat,$lng);',
        'node["leisure"="nature_reserve"](around:$radius,$lat,$lng);',
        'way["leisure"="nature_reserve"](around:$radius,$lat,$lng);',
        'node["amenity"="place_of_worship"](around:$radius,$lat,$lng);',
        'node["leisure"="spa"](around:$radius,$lat,$lng);',
      ]);
    }

    return '[out:json][timeout:15];(${filters.join('')});out center body;';
  }

  /// Map category to Overpass tags
  List<String> _categoryToOverpassTags(PlaceCategory category) {
    final tags = <String, List<String>>{
      'park': ['"leisure"="park"', '"leisure"="garden"'],
      'forest': ['"natural"="wood"', '"leisure"="nature_reserve"'],
      'beach': ['"natural"="beach"'],
      'cafe': ['"amenity"="cafe"'],
      'library': ['"amenity"="library"'],
      'meditation': ['"amenity"="place_of_worship"'],
      'wellness': ['"leisure"="spa"', '"healthcare"="alternative"'],
      'trail': ['"highway"="path"'],
    };

    final categoryTags = tags[category.name] ?? tags['park']!;
    return categoryTags
        .expand((tag) => [
              'node[$tag](around:5000,{lat},{lng});',
              'way[$tag](around:5000,{lat},{lng});',
            ])
        .toList();
  }

  /// Parse a single Overpass element into a CalmPlace
  CalmPlace? _parseElement(
    Map<String, dynamic> element,
    LatLng userLocation,
    Distance distanceCalc,
  ) {
    final tags = (element['tags'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v.toString())) ??
        {};

    final name = tags['name'];
    if (name == null || name.isEmpty) return null;

    // Get coordinates (handle both nodes and ways with center)
    double? lat, lng;
    if (element.containsKey('lat') && element.containsKey('lon')) {
      lat = (element['lat'] as num).toDouble();
      lng = (element['lon'] as num).toDouble();
    } else if (element.containsKey('center')) {
      final center = element['center'] as Map<String, dynamic>;
      lat = (center['lat'] as num).toDouble();
      lng = (center['lon'] as num).toDouble();
    }
    if (lat == null || lng == null) return null;

    final placeLocation = LatLng(lat, lng);
    final dist = distanceCalc.as(
      LengthUnit.Meter,
      userLocation,
      placeLocation,
    );

    // Determine category from OSM tags
    final category = _detectCategory(tags);

    // Check if open now from opening_hours tag (simplified)
    final isOpen = !tags.containsKey('opening_hours') || 
                   tags['opening_hours'] == '24/7' ||
                   true; // default to open if we can't parse

    return CalmPlace(
      id: element['id'].toString(),
      name: name,
      address: tags['addr:street'] ?? tags['addr:city'],
      category: category,
      location: placeLocation,
      isOpenNow: isOpen,
      distanceMeters: dist,
      tags: tags,
    );
  }

  /// Detect PlaceCategory from OSM tags
  PlaceCategory _detectCategory(Map<String, String> tags) {
    if (tags['leisure'] == 'park' || tags['leisure'] == 'garden') {
      return PlaceCategory.park;
    }
    if (tags['natural'] == 'wood' || tags['leisure'] == 'nature_reserve') {
      return PlaceCategory.forest;
    }
    if (tags['natural'] == 'beach') return PlaceCategory.beach;
    if (tags['amenity'] == 'cafe') return PlaceCategory.cafe;
    if (tags['amenity'] == 'library') return PlaceCategory.library;
    if (tags['amenity'] == 'place_of_worship') return PlaceCategory.meditation;
    if (tags['leisure'] == 'spa') return PlaceCategory.wellness;
    if (tags['highway'] == 'path') return PlaceCategory.trail;
    return PlaceCategory.park; // default
  }
}
