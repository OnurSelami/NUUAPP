import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStats {
  final int totalMinutes;
  final int focusMinutes;
  final int sleepMinutes;
  final int escapeMinutes;
  final int breatheMinutes;
  final int currentStreak;
  final int sessionsCompleted;
  final String lastSessionDate;
  final Map<String, int> dailyMinutes; // Format: 'yyyy-MM-dd' -> minutes
  final int totalBreaths;

  const UserStats({
    this.totalMinutes = 0,
    this.focusMinutes = 0,
    this.sleepMinutes = 0,
    this.escapeMinutes = 0,
    this.breatheMinutes = 0,
    this.currentStreak = 0,
    this.sessionsCompleted = 0,
    this.lastSessionDate = '',
    this.dailyMinutes = const {},
    this.totalBreaths = 0,
  });

  UserStats copyWith({
    int? totalMinutes,
    int? focusMinutes,
    int? sleepMinutes,
    int? escapeMinutes,
    int? breatheMinutes,
    int? currentStreak,
    int? sessionsCompleted,
    String? lastSessionDate,
    Map<String, int>? dailyMinutes,
    int? totalBreaths,
  }) {
    return UserStats(
      totalMinutes: totalMinutes ?? this.totalMinutes,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      escapeMinutes: escapeMinutes ?? this.escapeMinutes,
      breatheMinutes: breatheMinutes ?? this.breatheMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      totalBreaths: totalBreaths ?? this.totalBreaths,
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
    
    // Parse daily minutes from JSON
    Map<String, int> dailyMinutes = {};
    final dailyStr = prefs.getString('dailyMinutes');
    if (dailyStr != null) {
      try {
        final decoded = jsonDecode(dailyStr) as Map<String, dynamic>;
        dailyMinutes = decoded.map((key, value) => MapEntry(key, value as int));
      } catch (_) {}
    }

    return UserStats(
      totalMinutes: prefs.getInt('totalMinutes') ?? 0,
      focusMinutes: prefs.getInt('focusMinutes') ?? 0,
      sleepMinutes: prefs.getInt('sleepMinutes') ?? 0,
      escapeMinutes: prefs.getInt('escapeMinutes') ?? 0,
      breatheMinutes: prefs.getInt('breatheMinutes') ?? 0,
      currentStreak: prefs.getInt('currentStreak') ?? 0,
      sessionsCompleted: prefs.getInt('sessionsCompleted') ?? 0,
      lastSessionDate: prefs.getString('lastSessionDate') ?? '',
      dailyMinutes: dailyMinutes,
      totalBreaths: prefs.getInt('totalBreaths') ?? 0,
    );
  }

  void addSession(int minutes, String category) {
    if (minutes <= 0) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // 1. Calculate new category and total times
    final newTotal = state.totalMinutes + minutes;
    final newFocus = category == 'focus' ? state.focusMinutes + minutes : state.focusMinutes;
    final newSleep = category == 'sleep' ? state.sleepMinutes + minutes : state.sleepMinutes;
    final newEscape = category == 'escape' ? state.escapeMinutes + minutes : state.escapeMinutes;
    final newBreathe = category == 'breathe' ? state.breatheMinutes + minutes : state.breatheMinutes;
    final newSessions = state.sessionsCompleted + 1;

    // 2. Calculate daily record
    final newDaily = Map<String, int>.from(state.dailyMinutes);
    newDaily[todayStr] = (newDaily[todayStr] ?? 0) + minutes;

    // 3. Calculate streak
    int newStreak = state.currentStreak;
    if (state.lastSessionDate.isNotEmpty) {
      try {
        final lastDate = DateTime.parse(state.lastSessionDate);
        final difference = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;

        if (difference == 1) {
          newStreak += 1; // Consecutive day
        } else if (difference > 1) {
          newStreak = 1; // Streak broken
        } // if difference == 0, streak stays the same (multiple sessions same day)
      } catch (_) {
        newStreak = 1; // Fallback
      }
    } else {
      newStreak = 1; // First session ever
    }

    // 4. Update State
    state = state.copyWith(
      totalMinutes: newTotal,
      focusMinutes: newFocus,
      sleepMinutes: newSleep,
      escapeMinutes: newEscape,
      breatheMinutes: newBreathe,
      sessionsCompleted: newSessions,
      currentStreak: newStreak,
      lastSessionDate: todayStr,
      dailyMinutes: newDaily,
    );

    // 5. Persist to SharedPreferences
    prefs.setInt('totalMinutes', newTotal);
    prefs.setInt('focusMinutes', newFocus);
    prefs.setInt('sleepMinutes', newSleep);
    prefs.setInt('escapeMinutes', newEscape);
    prefs.setInt('breatheMinutes', newBreathe);
    prefs.setInt('sessionsCompleted', newSessions);
    prefs.setInt('currentStreak', newStreak);
    prefs.setString('lastSessionDate', todayStr);
    prefs.setString('dailyMinutes', jsonEncode(newDaily));
  }

  void addBreaths(int count) {
    if (count <= 0) return;
    
    final prefs = ref.read(sharedPreferencesProvider);
    final newTotalBreaths = state.totalBreaths + count;
    
    state = state.copyWith(totalBreaths: newTotalBreaths);
    prefs.setInt('totalBreaths', newTotalBreaths);
  }
}

final statsProvider = NotifierProvider<StatsController, UserStats>(
  StatsController.new,
);
