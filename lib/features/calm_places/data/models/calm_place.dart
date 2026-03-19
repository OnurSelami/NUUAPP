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

/// 24-hour calm timeline for a place
class CalmTimeline {
  final String placeId;
  final Map<int, int> hourlyScores; // hour (0-23) → calm score (0-100)
  final int bestHour;
  final String bestReason;

  const CalmTimeline({
    required this.placeId,
    required this.hourlyScores,
    required this.bestHour,
    this.bestReason = '',
  });

  /// Get the 4 key display hours
  List<MapEntry<int, int>> get keyHours {
    const keys = [7, 13, 18, 22];
    return keys.map((h) => MapEntry(h, hourlyScores[h] ?? 50)).toList();
  }

  /// Emoji for a given hour
  static String hourEmoji(int hour) {
    if (hour >= 5 && hour <= 8) return '🌅';
    if (hour >= 9 && hour <= 15) return '☀️';
    if (hour >= 16 && hour <= 19) return '🌇';
    return '🌙';
  }

  /// Label for a given hour
  static String hourLabel(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }
}

/// A micro story — emotional note left at a place
class CalmStory {
  final String id;
  final String placeId;
  final String text; // max 140 chars
  final String author;
  final DateTime timestamp;
  final int calmScoreAtTime;
  final String tag; // e.g. "reset", "flow", "reflect", "connect", "silence"

  const CalmStory({
    required this.id,
    required this.placeId,
    required this.text,
    this.author = 'Anonymous',
    required this.timestamp,
    this.calmScoreAtTime = 0,
    this.tag = 'reset',
  });

  /// Tag display with emoji
  String get tagDisplay {
    switch (tag) {
      case 'reset': return '🍃 #reset';
      case 'flow': return '🌊 #flow';
      case 'reflect': return '💭 #reflect';
      case 'connect': return '🤝 #connect';
      case 'silence': return '🎧 #silence';
      default: return '🍃 #reset';
    }
  }

  /// Serialize to JSON map for SharedPreferences
  Map<String, dynamic> toJson() => {
    'id': id,
    'placeId': placeId,
    'text': text,
    'author': author,
    'timestamp': timestamp.toIso8601String(),
    'calmScoreAtTime': calmScoreAtTime,
    'tag': tag,
  };

  /// Deserialize from JSON map
  factory CalmStory.fromJson(Map<String, dynamic> json) => CalmStory(
    id: json['id'] as String,
    placeId: json['placeId'] as String,
    text: json['text'] as String,
    author: json['author'] as String? ?? 'Anonymous',
    timestamp: DateTime.parse(json['timestamp'] as String),
    calmScoreAtTime: json['calmScoreAtTime'] as int? ?? 0,
    tag: json['tag'] as String? ?? 'reset',
  );
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
  final CalmTimeline? timeline;
  final List<CalmStory> stories;

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
    this.timeline,
    this.stories = const [],
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
    CalmTimeline? timeline,
    List<CalmStory>? stories,
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
      timeline: timeline ?? this.timeline,
      stories: stories ?? this.stories,
    );
  }
}
