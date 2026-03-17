import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/minimal_chart.dart';
import 'stats_controller.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(gradient: AppColors.bgGradient),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'YOUR JOURNEY',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 4.0),
                        ),
                        Icon(LucideIcons.barChart2, color: AppColors.sageGreen, size: 24),
                      ],
                    ).animate().fadeIn(duration: 600.ms),
                    
                    const SizedBox(height: 48),

                    // Massive Stat Display
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '${(stats.totalMinutes / 60).floor()}',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 100,
                              fontWeight: FontWeight.w200,
                              height: 1.0,
                              letterSpacing: -4,
                              shadows: [Shadow(color: AppColors.sageGreen.withValues(alpha: 0.2), blurRadius: 40)],
                            ),
                          ).animate().fadeIn(duration: 800.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                          Text(
                            'MINDFUL HOURS',
                            style: TextStyle(color: AppColors.sageGreen, fontSize: 12, letterSpacing: 4.0, fontWeight: FontWeight.w600),
                          ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                        ],
                      ),
                    ),

                    const SizedBox(height: 64),

                    // Streaks & Highlights
                    Row(
                      children: [
                        _StatCard(
                          title: 'CURRENT STREAK',
                          value: '${stats.currentStreak}',
                          unit: 'DAYS',
                          icon: LucideIcons.flame,
                          isHighlight: true,
                        ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: -0.1, end: 0),
                        const SizedBox(width: 16),
                        _StatCard(
                          title: 'SESSIONS',
                          value: '${stats.sessionsCompleted}',
                          unit: 'TOTAL',
                          icon: LucideIcons.checkCircle2,
                        ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: 0.1, end: 0),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Category Breakdown
                    const Text(
                      'BREAKDOWN',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2.0),
                    ).animate().fadeIn(duration: 600.ms, delay: 450.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _SmallStatCard(title: 'FOCUS', value: (stats.focusMinutes / 60).toStringAsFixed(1), unit: 'H', color: AppColors.textPrimary),
                        const SizedBox(width: 12),
                        _SmallStatCard(title: 'SLEEP', value: (stats.sleepMinutes / 60).toStringAsFixed(1), unit: 'H', color: AppColors.textPrimary),
                        const SizedBox(width: 12),
                        _SmallStatCard(title: 'ESCAPE', value: (stats.escapeMinutes / 60).toStringAsFixed(1), unit: 'H', color: AppColors.textPrimary),
                      ],
                    ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                    const SizedBox(height: 48),

                    // 7-Day Abstract Activity
                    const Text(
                      'PAST 7 DAYS',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2.0),
                    ).animate().fadeIn(duration: 600.ms, delay: 550.ms),
                    const SizedBox(height: 16),

                    GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: Builder(
                        builder: (context) {
                          // Calculate dynamic heights based on last 7 days
                          final now = DateTime.now();
                          final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          
                          // Get minutes for the last 7 days ending today
                          final List<int> dailyVals = [];
                          for (int i = 6; i >= 0; i--) {
                            final date = now.subtract(Duration(days: i));
                            final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                            dailyVals.add(stats.dailyMinutes[dateStr] ?? 0);
                          }
                          
                          // Find max to scale bars relative to 80.0 height
                          final maxVal = dailyVals.isEmpty ? 0 : dailyVals.reduce((a, b) => a > b ? a : b);
                          final List<double> heights = dailyVals.map((v) => maxVal > 0 ? (v / maxVal) * 60.0 : 0.0).toList();
                          
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (int i = 0; i < 7; i++)
                                _Bar(
                                  height: heights[i], 
                                  day: weekDays[i], 
                                  isToday: i == 6 // The last element is always today in our rolling 7-day scale
                                ),
                            ],
                          );
                        }
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).scaleXY(begin: 0.95, end: 1),

                    const SizedBox(height: 48),

                    // Monthly Abstract Flow
                    const Text(
                      'MONTHLY FLOW',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2.0),
                    ).animate().fadeIn(duration: 600.ms, delay: 650.ms),
                    const SizedBox(height: 16),

                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: MinimalChart(
                        dataPoints: [0.1, 0.3, 0.2, 0.6, 0.4, 0.8, 1.0], // Abstract wave for aesthetics
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 700.ms).scaleXY(begin: 0.95, end: 1),

                    const SizedBox(height: 48),
                    
                    // Recent achievements
                    const Text(
                      'ACHIEVEMENTS',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2.0),
                    ).animate().fadeIn(duration: 600.ms, delay: 750.ms),
                    const SizedBox(height: 16),

                    _Achievement(
                      icon: LucideIcons.sparkles,
                      title: 'Deep Diver',
                      desc: 'Completed 5 focus sessions',
                    ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
                    const SizedBox(height: 12),
                    _Achievement(
                      icon: LucideIcons.moon,
                      title: 'Night Owl',
                      desc: 'Used sleep mode 3 days in a row',
                    ).animate().fadeIn(duration: 500.ms, delay: 900.ms),

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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final bool isHighlight;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isHighlight ? AppColors.sageGreen : AppColors.textMuted, size: 24),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary, 
                    fontSize: 40, 
                    fontWeight: FontWeight.w300,
                    shadows: isHighlight ? [Shadow(color: AppColors.sageGreen.withValues(alpha: 0.3), blurRadius: 20)] : [],
                  ),
                ),
                const SizedBox(width: 8),
                Text(unit, style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 2)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final String day;
  final bool isToday;

  const _Bar({required this.height, required this.day, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 80,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Container(
            width: 12, // Thinner, more elegant bars
            height: height == 0 ? 0 : height + 10,
            decoration: BoxDecoration(
              color: isToday ? AppColors.sageGreen : AppColors.glassHover,
              borderRadius: BorderRadius.circular(6),
              boxShadow: isToday ? AppColors.glow(color: AppColors.sageGreen, blur: 20, opacity: 0.3) : null,
            ),
          )
              .animate(delay: 600.ms)
              .scaleY(begin: 0, end: 1, duration: 1000.ms, curve: Curves.easeOutCubic, alignment: Alignment.bottomCenter),
        ),
        const SizedBox(height: 16),
        Text(
          day,
          style: TextStyle(
            color: isToday ? AppColors.textPrimary : AppColors.textMuted,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;

  const _SmallStatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w400)),
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _Achievement extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _Achievement({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.glassHover,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
            child: Icon(icon, color: AppColors.sageGreen, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 16, letterSpacing: 1.0)),
                const SizedBox(height: 6),
                Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
