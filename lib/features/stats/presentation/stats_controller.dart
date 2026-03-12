import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStats {
  final int totalMinutes;
  final int currentStreak;
  final int sessionsCompleted;

  const UserStats({
    this.totalMinutes = 0,
    this.currentStreak = 0,
    this.sessionsCompleted = 0,
  });

  UserStats copyWith({
    int? totalMinutes,
    int? currentStreak,
    int? sessionsCompleted,
  }) {
    return UserStats(
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
    );
  }
}

// Global provider for shared preferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main.dart');
});

class StatsController extends Notifier<UserStats> {
  @override
  UserStats build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return UserStats(
      totalMinutes: prefs.getInt('totalMinutes') ?? 0,
      currentStreak: prefs.getInt('currentStreak') ?? 0,
      sessionsCompleted: prefs.getInt('sessionsCompleted') ?? 0,
    );
  }

  void addSession(int minutes) {
    final prefs = ref.read(sharedPreferencesProvider);
    
    final newMinutes = state.totalMinutes + minutes;
    final newSessions = state.sessionsCompleted + 1;
    final newStreak = state.currentStreak + 1;

    state = state.copyWith(
      totalMinutes: newMinutes,
      sessionsCompleted: newSessions,
      currentStreak: newStreak,
    );

    prefs.setInt('totalMinutes', newMinutes);
    prefs.setInt('sessionsCompleted', newSessions);
    prefs.setInt('currentStreak', newStreak);
  }
}

final statsProvider = NotifierProvider<StatsController, UserStats>(
  StatsController.new,
);
