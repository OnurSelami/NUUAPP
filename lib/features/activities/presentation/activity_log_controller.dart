import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stats/presentation/stats_controller.dart';
import '../domain/user_activity.dart';

/// Notifier to hold raw user activities.
/// Note: V1 local JSON log with SharedPreferences.
/// V2 will migrate to Hive/Isar if activity tracking expands.
class ActivityLogController extends Notifier<List<UserActivity>> {
  static const String _prefsKey = 'rawActivityLogs';

  @override
  List<UserActivity> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final logsJson = prefs.getStringList(_prefsKey);
    
    if (logsJson == null) {
      return [];
    }
    
    try {
      return logsJson.map((jsonStr) => UserActivity.fromJson(jsonStr)).toList();
    } catch (e) {
      // In case of parsing error, return empty list or handle accordingly
      return [];
    }
  }

  /// Adds a new activity log and saves it to SharedPreferences.
  void addLog(UserActivity activity) {
    final prefs = ref.read(sharedPreferencesProvider);
    
    // Create new state with the new activity at the start or end
    // Appending to the end makes it chronological
    final newState = [...state, activity];
    state = newState;
    
    // Save to SharedPreferences
    final logsJsonList = newState.map((log) => log.toJson()).toList();
    prefs.setStringList(_prefsKey, logsJsonList);
  }
}

final activityLogProvider = NotifierProvider<ActivityLogController, List<UserActivity>>(
  ActivityLogController.new,
);
