import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/glass_card.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/particles.dart';

class SleepModeScreen extends StatefulWidget {
  const SleepModeScreen({super.key});

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen> {
  int selectedTimer = 30;
  String selectedSound = 'Rain';

  final sounds = [
    _Sound('Rain', LucideIcons.cloudRain),
    _Sound('Ocean', LucideIcons.waves),
    _Sound('Wind', LucideIcons.wind),
    _Sound('Forest', LucideIcons.treePine),
    _Sound('Fire', LucideIcons.flame),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Starry background
            const Positioned.fill(
              child: Particles(count: 80, color: Colors.white),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.moon, color: AppColors.accent, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Sleep Mode',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Drift into peaceful sleep with calming sounds',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

                    const SizedBox(height: 40),

                    // Sleep timer
                    const Text(
                      'Sleep Timer',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [15, 30, 45, 60, 90].map((min) {
                        final isSelected = min == selectedTimer;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTimer = min),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.glassWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.accent : AppColors.glassBorder,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${min}m',
                                style: TextStyle(
                                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

                    const SizedBox(height: 40),

                    // Sound selection
                    const Text(
                      'Sleep Sounds',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 16),
                    ...sounds.asMap().entries.map((entry) {
                      final i = entry.key;
                      final sound = entry.value;
                      final isSelected = sound.name == selectedSound;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          onTap: () => setState(() => selectedSound = sound.name),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accent.withValues(alpha: 0.2)
                                      : AppColors.glassWhite,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(sound.icon,
                                    color: isSelected ? AppColors.accent : AppColors.textSecondary,
                                    size: 22),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                sound.name,
                                style: TextStyle(
                                  color: isSelected ? AppColors.accent : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 500 + i * 80)),
                      );
                    }),

                    const SizedBox(height: 32),

                    // Start button
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: AppColors.accentGlow(blur: 30, opacity: 0.4),
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.moon, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Start Sleep', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
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

class _Sound {
  final String name;
  final IconData icon;
  _Sound(this.name, this.icon);
}
