import 'dart:convert';

class UserActivity {
  final String id;
  final String activityType; // e.g., 'calm_pulse'
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  /// Can be 'Relaxed', 'Better', 'Neutral', 'Tense', or null if skipped/silent
  final String? feeling;
  final bool completed;
  final bool ignored;

  const UserActivity({
    required this.id,
    required this.activityType,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    this.feeling,
    required this.completed,
    this.ignored = false,
  });

  UserActivity copyWith({
    String? id,
    String? activityType,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    String? feeling,
    bool? completed,
    bool? ignored,
  }) {
    return UserActivity(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      feeling: feeling ?? this.feeling,
      completed: completed ?? this.completed,
      ignored: ignored ?? this.ignored,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityType': activityType,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'feeling': feeling,
      'completed': completed,
      'ignored': ignored,
    };
  }

  factory UserActivity.fromMap(Map<String, dynamic> map) {
    return UserActivity(
      id: map['id'] as String,
      activityType: map['activityType'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      endedAt: DateTime.parse(map['endedAt'] as String),
      durationSeconds: map['durationSeconds'] as int,
      feeling: map['feeling'] as String?,
      completed: map['completed'] as bool? ?? false,
      ignored: map['ignored'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActivity.fromJson(String source) => 
      UserActivity.fromMap(json.decode(source) as Map<String, dynamic>);
}
