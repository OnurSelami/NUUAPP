import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/bottom_nav.dart';
import 'focus_controller.dart';

class FocusModeScreen extends ConsumerWidget {
  const FocusModeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusProvider);
    final focusNotifier = ref.read(focusProvider.notifier);

    final selectedMinutes = focusState.selectedDuration;
    final isRunning = focusState.isPlaying;
    
    // Format timer
    final minStr = focusState.minRemaining.toString().padLeft(2, '0');
    final secStr = focusState.secRemaining.toString().padLeft(2, '0');
    
    final durations = [25, 45, 60, 90];
    
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
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FOCUS',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4.0,
                          ),
                        ).animate().fadeIn(duration: 800.ms),
                        Icon(
                          LucideIcons.focus,
                          color: AppColors.accent,
                          size: 20,
                        ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                      ],
                    ),

                    const Spacer(),

                    // Timer Typography (Massive, elegant)
                    Center(
                      child: GestureDetector(
                        onTap: () => focusNotifier.toggleFocus(),
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          '$minStr:$secStr',
                          style: TextStyle(
                            fontSize: 100, // Massive font size
                            fontWeight: FontWeight.w200,
                            color: isRunning ? AppColors.textPrimary : AppColors.textSecondary,
                            height: 1.0,
                            letterSpacing: -2.0,
                            shadows: isRunning ? AppColors.glow(color: AppColors.accent, blur: 40, opacity: 0.2) : [],
                          ),
                        ),
                      ).animate().fadeIn(duration: 1000.ms, delay: 400.ms).scaleXY(begin: 0.95, end: 1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isRunning ? 'Tap to pause' : 'Tap to start',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 600.ms),

                    const Spacer(),

                    // Duration Selection (Pills)
                    AnimatedOpacity(
                      opacity: isRunning ? 0.0 : 1.0,
                      duration: 400.ms,
                      child: IgnorePointer(
                        ignoring: isRunning,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: durations.map((d) {
                            final isSelected = d == selectedMinutes;
                            return GestureDetector(
                              onTap: () => focusNotifier.setDuration(d),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.glassHover : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected ? AppColors.glassBorder : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  '${d}m',
                                  style: TextStyle(
                                    color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
                    
                    const SizedBox(height: 100), // Space for bottom nav
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
