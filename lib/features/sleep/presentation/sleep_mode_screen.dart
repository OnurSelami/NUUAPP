import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/particles.dart';
import '../../../core/widgets/glass_button.dart';
import 'sleep_controller.dart';

class SleepModeScreen extends ConsumerStatefulWidget {
  const SleepModeScreen({super.key});

  @override
  ConsumerState<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends ConsumerState<SleepModeScreen> {
  int selectedTimer = 30;
  String selectedSound = 'Rain';

  final sounds = [
    _Sound('Rain', '🌧️'),
    _Sound('Ocean', '🌊'),
    _Sound('Forest', '🌲'),
    _Sound('Fireplace', '🔥'),
    _Sound('Wind', '🍃'),
    _Sound('Night', '✨'),
  ];

  @override
  Widget build(BuildContext context) {
    final sleepState = ref.watch(sleepProvider);
    final sleepNotifier = ref.read(sleepProvider.notifier);
    
    final selectedTimer = sleepState.selectedDuration;
    final isPlaying = sleepState.isPlaying;
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Starry background
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.network(
                  'https://images.unsplash.com/photo-1629446488105-122120352a03?w=800&q=80',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.bgDark.withValues(alpha: 0.6),
                      AppColors.bgDark.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
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
                      children: [0, 15, 30, 45, 60, 90].map((min) {
                        final isSelected = min == selectedTimer;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => sleepNotifier.setDuration(min),
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
                                min == 0 ? '∞' : '${min}m',
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: sounds.length,
                      itemBuilder: (context, i) {
                        final sound = sounds[i];
                        final isSelected = sound.name == selectedSound;
                        return GlassCard(
                          onTap: () => setState(() => selectedSound = sound.name),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accent.withValues(alpha: 0.2)
                                      : AppColors.glassWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: isSelected ? Border.all(color: AppColors.accent) : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(sound.icon, style: const TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                sound.name,
                                style: TextStyle(
                                  color: isSelected ? AppColors.accent : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: 500 + i * 80));
                      },
                    ),

                    const SizedBox(height: 32),

                    // Start button
                    Center(
                      child: GlassButton(
                        label: isPlaying ? 'Pause Sleep' : 'Start Sleep',
                        icon: isPlaying ? LucideIcons.pause : LucideIcons.moon,
                        width: 220,
                        onTap: () => sleepNotifier.toggleSleep(),
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
  final String icon;
  _Sound(this.name, this.icon);
}
