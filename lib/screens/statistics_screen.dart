import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/glass_card.dart';
import '../widgets/bottom_nav.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        const Icon(LucideIcons.barChart3, color: AppColors.accent, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Your Journey',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Track your moments of calm and focus',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

                    const SizedBox(height: 32),

                    // Weekly Overview
                    Row(
                      children: [
                        _StatCard(
                          title: 'Total Mindful',
                          value: '12',
                          unit: 'hours',
                          icon: LucideIcons.clock,
                        ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),
                        const SizedBox(width: 16),
                        _StatCard(
                          title: 'Current Streak',
                          value: '5',
                          unit: 'days',
                          icon: LucideIcons.flame,
                          isHighlight: true,
                        ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: 0.1, end: 0),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Weekly chart placeholder
                    const Text(
                      'This Week',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 16),

                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _Bar(height: 40, day: 'M'),
                              _Bar(height: 60, day: 'T'),
                              _Bar(height: 30, day: 'W'),
                              _Bar(height: 80, day: 'T', isToday: true),
                              _Bar(height: 20, day: 'F'),
                              _Bar(height: 50, day: 'S'),
                              _Bar(height: 0, day: 'S'),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).scaleXY(begin: 0.95, end: 1),

                    const SizedBox(height: 32),

                    // Recent achievements
                    const Text(
                      'Recent Achievements',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                    const SizedBox(height: 16),

                    _Achievement(
                      icon: LucideIcons.star,
                      title: 'Deep Diver',
                      desc: 'Completed 5 focus sessions',
                    ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
                    const SizedBox(height: 12),
                    _Achievement(
                      icon: LucideIcons.moonStar,
                      title: 'Night Owl',
                      desc: 'Used sleep mode 3 days in a row',
                    ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isHighlight ? AppColors.accent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isHighlight ? AppColors.accent : Colors.white, size: 20),
            ),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(unit, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ),
              ],
            ),
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
          height: 120,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 24,
            height: height == 0 ? 0 : height + 10,
            decoration: BoxDecoration(
              gradient: isToday ? AppColors.accentGradient : LinearGradient(
                colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isToday ? AppColors.accentGlow(blur: 15, opacity: 0.3) : null,
            ),
          )
              .animate(delay: 600.ms)
              .scaleY(begin: 0, end: 1, duration: 800.ms, curve: Curves.easeOutBack, alignment: Alignment.bottomCenter),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: TextStyle(
            color: isToday ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
