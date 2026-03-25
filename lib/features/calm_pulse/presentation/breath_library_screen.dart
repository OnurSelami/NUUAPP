import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../domain/breath_pattern.dart';

class BreathLibraryScreen extends StatelessWidget {
  const BreathLibraryScreen({super.key});

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
                        const Icon(LucideIcons.wind, color: AppColors.accent, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Practices',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),

                    const SizedBox(height: 8),

                    Text(
                      'Scientifically proven breathing patterns to shift your nervous system.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        letterSpacing: 0.3,
                        height: 1.4,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

                    const SizedBox(height: 32),

                    ...BreathingPatterns.all.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final pattern = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            context.push('/guided-breath', extra: pattern);
                          },
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Icon Box
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDark.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                  ),
                                  child: Icon(
                                    _getIconForPattern(pattern.id), 
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pattern.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pattern.description,
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Play icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent.withValues(alpha: 0.1),
                                  ),
                                  child: const Icon(LucideIcons.play, color: AppColors.accent, size: 16),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: 200 + (idx * 50))).slideY(begin: 0.1, end: 0),
                      );
                    }),
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

  IconData _getIconForPattern(String id) {
    switch (id) {
      case 'resonance': return LucideIcons.activity;
      case '478': return LucideIcons.moon;
      case 'box': return LucideIcons.box;
      case 'physio': return LucideIcons.zap;
      default: return LucideIcons.wind;
    }
  }
}
