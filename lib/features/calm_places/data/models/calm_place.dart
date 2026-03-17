import 'package:latlong2/latlong.dart';

/// Category of a calm place
enum PlaceCategory {
  park('Park', '🌳'),
  forest('Forest', '🌲'),
  beach('Beach', '🏖️'),
  cafe('Quiet Cafe', '☕'),
  library('Library', '📚'),
  meditation('Meditation', '🧘'),
  wellness('Wellness', '💆'),
  trail('Nature Trail', '🥾');

  final String label;
  final String emoji;
  const PlaceCategory(this.label, this.emoji);
}

/// A single calm reason explaining why a place is recommended
class CalmReason {
  final String text;
  final String icon; // lucide icon name

  const CalmReason({required this.text, this.icon = 'sparkles'});
}

/// Represents a discovered calm place from Overpass API
class CalmPlace {
  final String id;
  final String name;
  final String? address;
  final PlaceCategory category;
  final LatLng location;
  final double? rating;
  final bool isOpenNow;
  final double distanceMeters;
  final int calmScore;
  final List<CalmReason> calmReasons;
  final String? imageUrl;
  final Map<String, String> tags; // raw OSM tags

  const CalmPlace({
    required this.id,
    required this.name,
    this.address,
    required this.category,
    required this.location,
    this.rating,
    this.isOpenNow = true,
    required this.distanceMeters,
    this.calmScore = 0,
    this.calmReasons = const [],
    this.imageUrl,
    this.tags = const {},
  });

  /// Distance formatted for display
  String get distanceDisplay {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
  }

  /// Walking time estimate (avg 80m/min)
  String get walkingTime {
    final minutes = (distanceMeters / 80).round();
    if (minutes < 1) return '< 1 min';
    return '$minutes min walk';
  }

  CalmPlace copyWith({
    int? calmScore,
    List<CalmReason>? calmReasons,
    double? distanceMeters,
    bool? isOpenNow,
  }) {
    return CalmPlace(
      id: id,
      name: name,
      address: address,
      category: category,
      location: location,
      rating: rating,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      calmScore: calmScore ?? this.calmScore,
      calmReasons: calmReasons ?? this.calmReasons,
      imageUrl: imageUrl,
      tags: tags,
    );
  }
}
