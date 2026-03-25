// Energy Map data models

/// A single energy log entry
class EnergyLog {
  final String id;
  final DateTime timestamp;
  final int level; // 0-100
  final List<String> tags;
  final DaySegment segment;

  const EnergyLog({
    required this.id,
    required this.timestamp,
    required this.level,
    this.tags = const [],
    required this.segment,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'level': level,
    'tags': tags,
    'segment': segment.name,
  };

  factory EnergyLog.fromJson(Map<String, dynamic> json) => EnergyLog(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    level: json['level'] as int,
    tags: (json['tags'] as List?)?.cast<String>() ?? [],
    segment: DaySegment.values.firstWhere(
      (s) => s.name == json['segment'],
      orElse: () => DaySegment.fromHour(DateTime.parse(json['timestamp'] as String).hour),
    ),
  );
}

/// Day segments for grouping logs
enum DaySegment {
  morning,   // 5-11
  midday,    // 11-14
  afternoon, // 14-18
  evening,   // 18-22
  night;     // 22-5

  static DaySegment fromHour(int hour) {
    if (hour >= 5 && hour < 11) return morning;
    if (hour >= 11 && hour < 14) return midday;
    if (hour >= 14 && hour < 18) return afternoon;
    if (hour >= 18 && hour < 22) return evening;
    return night;
  }

  String get label {
    switch (this) {
      case morning: return 'Morning';
      case midday: return 'Midday';
      case afternoon: return 'Afternoon';
      case evening: return 'Evening';
      case night: return 'Night';
    }
  }

  String get emoji {
    switch (this) {
      case morning: return '🌅';
      case midday: return '☀️';
      case afternoon: return '🌤️';
      case evening: return '🌇';
      case night: return '🌙';
    }
  }
}

/// Available tags for energy logging
class EnergyTag {
  final String id;
  final String label;
  final String emoji;

  const EnergyTag(this.id, this.label, this.emoji);

  static const List<EnergyTag> all = [
    EnergyTag('tired', 'Tired', '💤'),
    EnergyTag('caffeine', 'Caffeine', '☕'),
    EnergyTag('active', 'Active', '🏃'),
    EnergyTag('post_meal', 'Post-meal', '🍽️'),
    EnergyTag('stressed', 'Stressed', '😤'),
    EnergyTag('rested', 'Rested', '😌'),
    EnergyTag('focused', 'Focused', '🎯'),
  ];
}

/// Aggregated user energy profile
class EnergyProfile {
  final Map<int, double> hourlyAverages; // hour(0-23) → avg energy
  final int peakHour;
  final int dipHour;
  final double averageEnergy;
  final double trendPercent; // week-over-week change
  final Map<int, double> weekdayAverages; // 1=Mon..7=Sun → avg
  final Map<String, double> tagCorrelations; // tag → avg energy delta
  final int totalLogs;

  const EnergyProfile({
    this.hourlyAverages = const {},
    this.peakHour = 10,
    this.dipHour = 14,
    this.averageEnergy = 0,
    this.trendPercent = 0,
    this.weekdayAverages = const {},
    this.tagCorrelations = const {},
    this.totalLogs = 0,
  });

  /// Confidence level based on data points
  double get confidence {
    if (totalLogs < 3) return 0.1;
    if (totalLogs < 7) return 0.3;
    if (totalLogs < 15) return 0.6;
    if (totalLogs < 30) return 0.8;
    return 1.0;
  }

  String get confidenceLabel {
    if (confidence < 0.3) return 'Building profile...';
    if (confidence < 0.6) return 'Pattern forming';
    if (confidence < 0.8) return 'Good accuracy';
    return 'High confidence';
  }

  /// Best weekday name
  String? get bestDayName {
    if (weekdayAverages.isEmpty) return null;
    final best = weekdayAverages.entries.reduce((a, b) => a.value > b.value ? a : b);
    return dayName(best.key);
  }

  /// Worst weekday name
  String? get worstDayName {
    if (weekdayAverages.isEmpty) return null;
    final worst = weekdayAverages.entries.reduce((a, b) => a.value < b.value ? a : b);
    return dayName(worst.key);
  }

  static String dayName(int weekday) {
    const names = {1: 'Monday', 2: 'Tuesday', 3: 'Wednesday', 4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday'};
    return names[weekday] ?? '';
  }
}
