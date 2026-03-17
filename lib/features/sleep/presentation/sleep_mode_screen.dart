import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/particles.dart';
import 'sleep_controller.dart';

class SleepModeScreen extends ConsumerStatefulWidget {
  const SleepModeScreen({super.key});

  @override
  ConsumerState<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends ConsumerState<SleepModeScreen> {
  String selectedSound = 'Rain';

  final sounds = [
    _Sound('Rain', LucideIcons.cloudRain),
    _Sound('Ocean', LucideIcons.waves),
    _Sound('Forest', LucideIcons.trees),
    _Sound('Fireplace', LucideIcons.flame),
    _Sound('Wind', LucideIcons.wind),
    _Sound('Night', LucideIcons.moon),
  ];

  @override
  Widget build(BuildContext context) {
    final sleepState = ref.watch(sleepProvider);
    final sleepNotifier = ref.read(sleepProvider.notifier);
    
    final selectedTimer = sleepState.selectedDuration;
    final isPlaying = sleepState.isPlaying;

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Stack(
          children: [
            // Deep gradient background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.bgGradient,
                ),
              ),
            ),
            
            // Subtle slow particles
            const Positioned.fill(
              child: Particles(count: 30, color: AppColors.textMuted),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'REST',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4.0,
                          ),
                        ).animate().fadeIn(duration: 800.ms),
                        Icon(
                          LucideIcons.moon,
                          color: AppColors.sageGreen,
                          size: 20,
                        ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Main typography
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: const Text(
                        'Drift into\ndeep recovery.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 42,
                          fontWeight: FontWeight.w200,
                          height: 1.1,
                          letterSpacing: -1.0,
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                    ),

                    const SizedBox(height: 60),

                    // Sleep timer
                    const Text(
                      'DURATION',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2.0),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [0, 15, 30, 45, 60, 90].map((min) {
                        final isSelected = min == selectedTimer;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => sleepNotifier.setDuration(min),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.glassHover : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.glassBorder : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                min == 0 ? '∞' : '${min}m',
                                style: TextStyle(
                                  color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

                    const SizedBox(height: 40),

                    // Sound selection
                    const Text(
                      'AMBIENCE',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2.0),
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: sounds.length,
                      itemBuilder: (context, i) {
                        final sound = sounds[i];
                        final isSelected = sound.name == selectedSound;
                        return GlassCard(
                          onTap: () => setState(() => selectedSound = sound.name),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                sound.icon,
                                size: 28,
                                color: isSelected ? AppColors.sageGreen : AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                sound.name,
                                style: TextStyle(
                                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: 700 + i * 50));
                      },
                    ),

                    const SizedBox(height: 48),

                    // Main Action Area (Play/Pause)
                    Center(
                      child: GestureDetector(
                        onTap: () => sleepNotifier.toggleSleep(),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPlaying ? AppColors.glassHover : Colors.transparent,
                            border: Border.all(
                              color: isPlaying ? AppColors.sageGreen : AppColors.glassBorder,
                              width: 1,
                            ),
                            boxShadow: isPlaying ? AppColors.glow(color: AppColors.sageGreen, blur: 30, opacity: 0.2) : [],
                          ),
                          child: Icon(
                            isPlaying ? LucideIcons.pause : LucideIcons.play,
                            color: isPlaying ? AppColors.textPrimary : AppColors.textSecondary,
                            size: 32,
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: 1000.ms).scaleXY(begin: 0.9, end: 1.0),
                    ),
                    
                    const SizedBox(height: 120), // Space for bottom nav
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
