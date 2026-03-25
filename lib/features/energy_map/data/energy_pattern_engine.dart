import 'dart:math';
import 'models/energy_log.dart';

/// Detects patterns in energy log data
class EnergyPatternEngine {
  /// Compute hourly averages over a window of days
  /// Returns `Map<hour(0-23), averageEnergy>`
  static Map<int, double> computeHourlyAverages(List<EnergyLog> logs, {int windowDays = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: windowDays));
    final recent = logs.where((l) => l.timestamp.isAfter(cutoff)).toList();

    final sums = <int, double>{};
    final counts = <int, int>{};

    for (final log in recent) {
      final h = log.timestamp.hour;
      sums[h] = (sums[h] ?? 0) + log.level;
      counts[h] = (counts[h] ?? 0) + 1;
    }

    final averages = <int, double>{};
    for (final h in sums.keys) {
      averages[h] = sums[h]! / counts[h]!;
    }
    return averages;
  }

  /// Find peak hour (highest average energy)
  static int findPeakHour(Map<int, double> hourlyAvgs) {
    if (hourlyAvgs.isEmpty) return 10; // default
    return hourlyAvgs.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Find dip hour (lowest average energy)
  static int findDipHour(Map<int, double> hourlyAvgs) {
    if (hourlyAvgs.isEmpty) return 14; // default
    return hourlyAvgs.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  /// Compute day-of-week averages
  /// Returns `Map<weekday(1=Mon..7=Sun), average>`
  static Map<int, double> computeWeekdayAverages(List<EnergyLog> logs) {
    final sums = <int, double>{};
    final counts = <int, int>{};

    for (final log in logs) {
      final day = log.timestamp.weekday;
      sums[day] = (sums[day] ?? 0) + log.level;
      counts[day] = (counts[day] ?? 0) + 1;
    }

    final averages = <int, double>{};
    for (final day in sums.keys) {
      averages[day] = sums[day]! / counts[day]!;
    }
    return averages;
  }

  /// Compute tag correlations: average energy when tag is present vs absent
  /// Returns `Map<tagId, delta>` (positive = tag boosts energy)
  static Map<String, double> computeTagCorrelations(List<EnergyLog> logs) {
    if (logs.length < 5) return {};

    final overallAvg = logs.map((l) => l.level).reduce((a, b) => a + b) / logs.length;
    final correlations = <String, double>{};

    final tagGroups = <String, List<int>>{};
    for (final log in logs) {
      for (final tag in log.tags) {
        tagGroups.putIfAbsent(tag, () => []).add(log.level);
      }
    }

    for (final entry in tagGroups.entries) {
      if (entry.value.length >= 2) {
        final tagAvg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        correlations[entry.key] = tagAvg - overallAvg;
      }
    }

    return correlations;
  }

  /// Compute week-over-week trend percentage
  /// Positive = improving, negative = declining
  static double computeTrend(List<EnergyLog> logs) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(const Duration(days: 7));
    final lastWeekStart = now.subtract(const Duration(days: 14));

    final thisWeek = logs.where((l) =>
        l.timestamp.isAfter(thisWeekStart)).toList();
    final lastWeek = logs.where((l) =>
        l.timestamp.isAfter(lastWeekStart) && l.timestamp.isBefore(thisWeekStart)).toList();

    if (thisWeek.isEmpty || lastWeek.isEmpty) return 0;

    final thisAvg = thisWeek.map((l) => l.level).reduce((a, b) => a + b) / thisWeek.length;
    final lastAvg = lastWeek.map((l) => l.level).reduce((a, b) => a + b) / lastWeek.length;

    if (lastAvg == 0) return 0;
    return ((thisAvg - lastAvg) / lastAvg * 100).roundToDouble();
  }

  /// Build a full EnergyProfile from logs
  static EnergyProfile buildProfile(List<EnergyLog> logs) {
    if (logs.isEmpty) return const EnergyProfile();

    final hourlyAvgs = computeHourlyAverages(logs);
    final peakHour = findPeakHour(hourlyAvgs);
    final dipHour = findDipHour(hourlyAvgs);
    final weekdayAvgs = computeWeekdayAverages(logs);
    final tagCorrelations = computeTagCorrelations(logs);
    final trend = computeTrend(logs);
    final overallAvg = logs.map((l) => l.level).reduce((a, b) => a + b) / logs.length;

    return EnergyProfile(
      hourlyAverages: hourlyAvgs,
      peakHour: peakHour,
      dipHour: dipHour,
      averageEnergy: overallAvg,
      trendPercent: trend,
      weekdayAverages: weekdayAvgs,
      tagCorrelations: tagCorrelations,
      totalLogs: logs.length,
    );
  }

  /// Get 4 key hours for timeline visualization
  static List<MapEntry<int, double>> getKeyHours(Map<int, double> hourlyAvgs) {
    const targetHours = [7, 12, 17, 22]; // morning, midday, evening, night
    final result = <MapEntry<int, double>>[];

    for (final target in targetHours) {
      // Find closest available hour
      int? closestHour;
      int minDist = 999;
      for (final h in hourlyAvgs.keys) {
        final dist = (h - target).abs();
        if (dist < minDist) {
          minDist = dist;
          closestHour = h;
        }
      }
      if (closestHour != null) {
        result.add(MapEntry(closestHour, hourlyAvgs[closestHour]!));
      } else {
        result.add(MapEntry(target, 50)); // neutral fallback
      }
    }

    return result;
  }
}
