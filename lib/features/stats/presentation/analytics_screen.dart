import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import 'stats_controller.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Week', 'Month', 'Year'];
  int _offsetPeriods = 0;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);

    final now = DateTime.now();
    List<double> chartValues = [];
    List<String> chartLabels = [];
    int totalPeriodMinutes = 0;
    String dateRangeStr = '';
    int avgMins = 0;

    if (_selectedPeriod == 'Week') {
      final int offsetDays = _offsetPeriods * 7;
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: offsetDays + i));
        final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final mins = stats.dailyMinutes[dateStr] ?? 0;
        chartValues.add(mins.toDouble());
        chartLabels.add(DateFormat('E').format(d).substring(0, 3));
        totalPeriodMinutes += mins;
      }
      final startDate = now.subtract(Duration(days: offsetDays + 6));
      final endDate = now.subtract(Duration(days: offsetDays));
      dateRangeStr = '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}';
      avgMins = (totalPeriodMinutes / 7).round();
    } else if (_selectedPeriod == 'Month') {
      final int offsetDays = _offsetPeriods * 28;
      for (int w = 3; w >= 0; w--) {
        int weekSum = 0;
        final weekEnd = now.subtract(Duration(days: offsetDays + (w * 7)));
        final weekStart = weekEnd.subtract(const Duration(days: 6));
        for (int i = 0; i < 7; i++) {
          final d = weekStart.add(Duration(days: i));
          final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          weekSum += stats.dailyMinutes[dateStr] ?? 0;
        }
        chartValues.add(weekSum.toDouble());
        chartLabels.add('W${4 - w}');
        totalPeriodMinutes += weekSum;
      }
      final startDate = now.subtract(Duration(days: offsetDays + 27));
      final endDate = now.subtract(Duration(days: offsetDays));
      dateRangeStr = '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}';
      avgMins = (totalPeriodMinutes / 28).round();
    } else if (_selectedPeriod == 'Year') {
      final int offsetMonths = _offsetPeriods * 6;
      int endM = now.month - offsetMonths;
      int endY = now.year;
      while (endM <= 0) { endM += 12; endY -= 1; }
      
      for (int m = 5; m >= 0; m--) {
        int monthSum = 0;
        int targetM = endM - m;
        int y = endY;
        while (targetM <= 0) { targetM += 12; y -= 1; }
        
        final targetMonth = DateTime(y, targetM, 1);
        final prefix = '${targetMonth.year}-${targetMonth.month.toString().padLeft(2, '0')}';
        
        stats.dailyMinutes.forEach((dateStr, mins) {
          if (dateStr.startsWith(prefix)) monthSum += mins;
        });
        
        chartValues.add(monthSum.toDouble());
        chartLabels.add(DateFormat('MMM').format(targetMonth));
        totalPeriodMinutes += monthSum;
      }
      
      int startM = endM - 5;
      int startY = endY;
      while (startM <= 0) { startM += 12; startY -= 1; }
      
      final startDate = DateTime(startY, startM, 1);
      final endDate = DateTime(endY, endM, 1);
      dateRangeStr = '${DateFormat('MMM yyyy').format(startDate)} - ${DateFormat('MMM yyyy').format(endDate)}';
      avgMins = (totalPeriodMinutes / (6 * 30)).round();
    }

    final double maxVal = chartValues.isEmpty || chartValues.every((v) => v == 0) 
        ? 10.0 
        : chartValues.reduce((a, b) => a > b ? a : b);

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.barChart2, color: AppColors.accent, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Insights',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),

                    const SizedBox(height: 32),

                    // Breathing Exercise Summary Card
                    _TopSummaryCard(
                      title: 'Breathing Exercise',
                      val1Label: 'Total Breaths',
                      val1: '${stats.totalBreaths}',
                      val1Unit: '',
                      val2Label: 'Guided Time',
                      val2: '${stats.breatheMinutes}',
                      val2Unit: 'm',
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // The Big Bar Chart Card
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Segmented Control
                          Container(
                            height: 40,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Row(
                              children: _periods.map((period) {
                                final isSelected = _selectedPeriod == period;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPeriod = period;
                                        _offsetPeriods = 0;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.accent : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: isSelected ? [
                                          BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 10)
                                        ] : [],
                                      ),
                                      child: Text(
                                        period,
                                        style: TextStyle(
                                          color: isSelected ? AppColors.bgDark : AppColors.textSecondary,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Date Range & Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _offsetPeriods++),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary, size: 20),
                                ),
                              ),
                              Text(dateRangeStr, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                              GestureDetector(
                                onTap: _offsetPeriods > 0 ? () => setState(() => _offsetPeriods--) : null,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(LucideIcons.chevronRight, color: _offsetPeriods > 0 ? AppColors.textPrimary : AppColors.textMuted.withValues(alpha: 0.3), size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TOTAL $totalPeriodMinutes min', style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              Text('AVG $avgMins min/day', style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                          const SizedBox(height: 24),

                          // Bar Chart
                          SizedBox(
                            height: 160,
                            child: _BarChartWidget(
                              values: chartValues,
                              labels: chartLabels,
                              maxValue: maxVal,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),

                    // Secondary Focus Card
                    _TopSummaryCard(
                      title: 'Focus & Escape',
                      val1Label: 'Focus Time',
                      val1: '${stats.focusMinutes}',
                      val1Unit: 'm',
                      val2Label: 'Current Streak',
                      val2: '${stats.currentStreak}',
                      val2Unit: 'd',
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),
            const BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _TopSummaryCard extends StatelessWidget {
  final String title;
  final String val1Label;
  final String val1;
  final String val1Unit;
  final String val2Label;
  final String val2;
  final String val2Unit;

  const _TopSummaryCard({
    required this.title,
    required this.val1Label,
    required this.val1,
    required this.val1Unit,
    required this.val2Label,
    required this.val2,
    required this.val2Unit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
              Icon(LucideIcons.barChart, color: AppColors.textMuted, size: 16),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(val1Label, style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(val1, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w300)),
                        if (val1Unit.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(val1Unit, style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.1)),
              Expanded(
                child: Column(
                  children: [
                    Text(val2Label, style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(val2, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w300)),
                        if (val2Unit.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(val2Unit, style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double maxValue;

  const _BarChartWidget({
    required this.values,
    required this.labels,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(values.length, (index) {
            final val = values[index];
            final pct = maxValue > 0 ? (val / maxValue).clamp(0.0, 1.0) : 0.0;
            final isHighlight = val > 0 && val == maxValue; // Highest bar
            
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // The Bar
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        width: 12,
                        height: (constraints.maxHeight - 24) * pct, // space for label
                        decoration: BoxDecoration(
                          color: isHighlight ? AppColors.accent : AppColors.accent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isHighlight ? [
                            BoxShadow(color: AppColors.accent.withValues(alpha: 0.6), blurRadius: 10, spreadRadius: 0)
                          ] : [],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // The Label
                  Text(
                    labels[index],
                    style: TextStyle(
                      color: isHighlight ? Colors.white : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
