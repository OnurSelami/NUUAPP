import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/energy_log.dart';

/// Handles persistence of energy logs using SharedPreferences
class EnergyRepository {
  static const _logsKey = 'energy_logs';
  static const _maxDays = 90;

  final SharedPreferences _prefs;

  EnergyRepository(this._prefs);

  /// Get all stored logs
  List<EnergyLog> getAllLogs() {
    try {
      final raw = _prefs.getString(_logsKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => EnergyLog.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      return [];
    }
  }

  /// Get logs from the last N days
  List<EnergyLog> getLogs({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return getAllLogs().where((log) => log.timestamp.isAfter(cutoff)).toList();
  }

  /// Get today's logs
  List<EnergyLog> getTodayLogs() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return getAllLogs().where((log) => log.timestamp.isAfter(todayStart)).toList();
  }

  /// Add a new energy log
  Future<void> addLog(EnergyLog log) async {
    final logs = getAllLogs();
    logs.insert(0, log);

    // Auto-trim: keep only last 90 days
    final cutoff = DateTime.now().subtract(const Duration(days: _maxDays));
    final trimmed = logs.where((l) => l.timestamp.isAfter(cutoff)).toList();

    await _persist(trimmed);
  }

  /// Delete a log by ID
  Future<void> deleteLog(String logId) async {
    final logs = getAllLogs();
    logs.removeWhere((l) => l.id == logId);
    await _persist(logs);
  }

  /// Get daily average energy for a specific date
  double? getDailyAverage(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final dayLogs = getAllLogs()
        .where((l) => l.timestamp.isAfter(dayStart) && l.timestamp.isBefore(dayEnd))
        .toList();
    if (dayLogs.isEmpty) return null;
    return dayLogs.map((l) => l.level).reduce((a, b) => a + b) / dayLogs.length;
  }

  /// Get the total number of logs
  int get totalLogCount => getAllLogs().length;

  /// Get the number of unique days with logs
  int get uniqueDayCount {
    final days = <String>{};
    for (final log in getAllLogs()) {
      days.add('${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}');
    }
    return days.length;
  }

  Future<void> _persist(List<EnergyLog> logs) async {
    final encoded = jsonEncode(logs.map((l) => l.toJson()).toList());
    await _prefs.setString(_logsKey, encoded);
  }
}
