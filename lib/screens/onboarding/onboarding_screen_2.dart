import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_button.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.cloud, size: 40, color: AppColors.accent),
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 32),
                Text(
                  'Immersive Environments',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 16),
                Text(
                  'Experience rain, ocean waves, forest sounds and more. Each environment is designed to calm your mind.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'Next',
                        onTap: () => context.go('/onboarding-3'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
