import 'models/energy_log.dart';

/// Types of insights
enum InsightType { wow, predictive, behavioral }

/// A single generated insight
class EnergyInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final String emoji;
  final double confidence; // 0-1

  const EnergyInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.emoji,
    required this.confidence,
  });
}

/// Generates personalized insights from energy profile data
class EnergyInsightEngine {
  /// Generate ranked insights from a profile
  static List<EnergyInsight> generateInsights(EnergyProfile profile, List<EnergyLog> logs) {
    final insights = <EnergyInsight>[];
    final conf = profile.confidence;

    // ─── WOW INSIGHTS ────────────────────────────────────

    // 1. Peak hour insight
    if (profile.hourlyAverages.isNotEmpty && conf >= 0.3) {
      final peakScore = profile.hourlyAverages[profile.peakHour]?.round() ?? 0;
      insights.add(EnergyInsight(
        id: 'peak_hour',
        title: 'Your peak is ${formatHour(profile.peakHour)}',
        description: 'Your brain is sharpest around ${formatHour(profile.peakHour)} with an average energy of $peakScore. Schedule important work here.',
        type: InsightType.wow,
        emoji: '⚡',
        confidence: conf,
      ));
    }

    // 2. Post-lunch dip
    if (profile.hourlyAverages.isNotEmpty && conf >= 0.3) {
      final dipScore = profile.hourlyAverages[profile.dipHour]?.round() ?? 0;
      final peakScore = profile.hourlyAverages[profile.peakHour]?.round() ?? 0;
      final drop = peakScore - dipScore;
      if (drop > 10) {
        insights.add(EnergyInsight(
          id: 'energy_dip',
          title: 'Energy drops by $drop points',
          description: 'Your energy dips around ${formatHour(profile.dipHour)}. A 10-minute walk could offset this.',
          type: InsightType.wow,
          emoji: '📉',
          confidence: conf,
        ));
      }
    }

    // 3. Best/worst day of week
    if (profile.bestDayName != null && profile.worstDayName != null && conf >= 0.6) {
      insights.add(EnergyInsight(
        id: 'weekly_pattern',
        title: '${profile.bestDayName}s are your strongest',
        description: '${profile.bestDayName}s are your highest energy days. ${profile.worstDayName}s are your lowest. Plan accordingly.',
        type: InsightType.wow,
        emoji: '📅',
        confidence: conf,
      ));
    }

    // 4. Tag correlation insights
    for (final entry in profile.tagCorrelations.entries) {
      final delta = entry.value.round();
      if (delta.abs() >= 10) {
        final tagObj = EnergyTag.all.where((t) => t.id == entry.key).firstOrNull;
        final label = tagObj?.label ?? entry.key;
        final emoji = tagObj?.emoji ?? '🏷️';

        if (delta > 0) {
          insights.add(EnergyInsight(
            id: 'tag_boost_${entry.key}',
            title: '$label boosts energy by +$delta',
            description: 'When you tag "$label", your energy averages $delta points higher than normal.',
            type: InsightType.wow,
            emoji: emoji,
            confidence: conf,
          ));
        } else {
          insights.add(EnergyInsight(
            id: 'tag_drain_${entry.key}',
            title: '$label drops energy by $delta',
            description: 'When you tag "$label", your energy averages ${delta.abs()} points lower than normal.',
            type: InsightType.wow,
            emoji: emoji,
            confidence: conf,
          ));
        }
      }
    }

    // 5. Trend insight
    if (profile.trendPercent != 0 && conf >= 0.6) {
      final trending = profile.trendPercent > 0;
      insights.add(EnergyInsight(
        id: 'trend',
        title: trending
            ? 'Energy up ${profile.trendPercent.abs().round()}% this week'
            : 'Energy down ${profile.trendPercent.abs().round()}% this week',
        description: trending
            ? 'Your energy has improved ${profile.trendPercent.abs().round()}% compared to last week. Keep it up!'
            : 'Your energy dropped ${profile.trendPercent.abs().round()}% compared to last week. Consider getting more rest.',
        type: InsightType.wow,
        emoji: trending ? '📈' : '📉',
        confidence: conf,
      ));
    }

    // ─── PREDICTIVE INSIGHTS ─────────────────────────────

    final now = DateTime.now();
    final currentHour = now.hour;

    // 6. Upcoming dip warning
    if (profile.dipHour > currentHour && (profile.dipHour - currentHour) <= 3 && conf >= 0.6) {
      insights.add(EnergyInsight(
        id: 'upcoming_dip',
        title: 'Energy dip in ~${profile.dipHour - currentHour}h',
        description: 'Based on your pattern, energy typically dips around ${formatHour(profile.dipHour)}. Good time to plan a break.',
        type: InsightType.predictive,
        emoji: '⏰',
        confidence: conf,
      ));
    }

    // 7. Upcoming peak
    if (profile.peakHour > currentHour && (profile.peakHour - currentHour) <= 3 && conf >= 0.6) {
      insights.add(EnergyInsight(
        id: 'upcoming_peak',
        title: 'Peak zone in ~${profile.peakHour - currentHour}h',
        description: 'Your energy peak is coming at ${formatHour(profile.peakHour)}. Save your most important task for then.',
        type: InsightType.predictive,
        emoji: '🎯',
        confidence: conf,
      ));
    }

    // 8. Tomorrow's forecast
    final tomorrowWeekday = (now.weekday % 7) + 1;
    final tomorrowAvg = profile.weekdayAverages[tomorrowWeekday];
    if (tomorrowAvg != null && conf >= 0.6) {
      final worse = tomorrowAvg < profile.averageEnergy;
      if (worse) {
        insights.add(EnergyInsight(
          id: 'tomorrow_forecast',
          title: 'Tomorrow may be lower energy',
          description: '${EnergyProfile.dayName(tomorrowWeekday)}s typically average ${tomorrowAvg.round()} energy. Consider lighter tasks.',
          type: InsightType.predictive,
          emoji: '🔮',
          confidence: conf,
        ));
      }
    }

    // ─── BEHAVIORAL RECOMMENDATIONS ──────────────────────

    // 9. Focus mode timing
    if (conf >= 0.3) {
      insights.add(EnergyInsight(
        id: 'focus_timing',
        title: 'Best deep work: ${formatHour(profile.peakHour)}',
        description: 'Your peak energy window is ${formatHour(profile.peakHour)}-${formatHour(profile.peakHour + 2)}. Try Focus Mode during this time.',
        type: InsightType.behavioral,
        emoji: '🧠',
        confidence: conf,
      ));
    }

    // 10. Rest recommendation at dip
    if (conf >= 0.3) {
      insights.add(EnergyInsight(
        id: 'rest_timing',
        title: 'Recharge at ${formatHour(profile.dipHour)}',
        description: 'Your energy dips around ${formatHour(profile.dipHour)}. Try Calm Pulse or a short walk to recover.',
        type: InsightType.behavioral,
        emoji: '🌿',
        confidence: conf,
      ));
    }

    // Sort: wow first, then predictive, then behavioral. Higher confidence first.
    insights.sort((a, b) {
      final typeOrder = a.type.index.compareTo(b.type.index);
      if (typeOrder != 0) return typeOrder;
      return b.confidence.compareTo(a.confidence);
    });

    return insights;
  }

  /// Format hour as readable string
  static String formatHour(int hour) {
    final h = hour % 24;
    if (h == 0) return '12 AM';
    if (h < 12) return '$h AM';
    if (h == 12) return '12 PM';
    return '${h - 12} PM';
  }

  /// Quick mini-insight after logging
  static String? getMiniInsight(EnergyLog log, EnergyProfile profile) {
    if (profile.totalLogs < 3) {
      final remaining = 3 - profile.totalLogs;
      return '$remaining more logs to unlock your first insight ✨';
    }

    final hourAvg = profile.hourlyAverages[log.timestamp.hour];
    if (hourAvg != null) {
      final diff = log.level - hourAvg.round();
      if (diff > 15) return 'Higher than your usual ${formatHour(log.timestamp.hour)} energy! 🔥';
      if (diff < -15) return 'Lower than normal. Take it easy 🌿';
    }

    if (log.level >= 75) return 'Great energy! Perfect time for important work ⚡';
    if (log.level <= 30) return 'Low energy detected. How about a Calm Pulse? 🫧';

    return 'Logged ✓ Your pattern is getting clearer.';
  }
}
