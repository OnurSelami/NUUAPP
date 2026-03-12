import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_button.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Background ambient glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Header with Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                          ),
                          child: const Text('PRO', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ).animate().fadeIn(duration: 800.ms),
                        const SizedBox(width: 50), // Balance the row
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Hero Graphic
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.accentGradient,
                              boxShadow: AppColors.accentGlow(blur: 40, opacity: 0.4),
                            ),
                            child: const Icon(LucideIcons.crown, color: Colors.white, size: 60),
                          ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),

                          const SizedBox(height: 32),
                          const Text(
                            'Unlock Infinite Calm',
                            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 12),
                          Text(
                            'Access all environments, premium sleep stories, and high-fidelity soundscapes.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 40),

                          // Features
                          _FeatureRow(icon: LucideIcons.mountain, title: 'All 50+ Environments', delay: 400),
                          const SizedBox(height: 20),
                          _FeatureRow(icon: LucideIcons.moon, title: 'Deep Sleep Library', delay: 500),
                          const SizedBox(height: 20),
                          _FeatureRow(icon: LucideIcons.headphones, title: 'Lossless Spatial Audio', delay: 600),
                          const SizedBox(height: 20),
                          _FeatureRow(icon: LucideIcons.barChart2, title: 'Advanced Insights & Journals', delay: 700),

                          const SizedBox(height: 48),

                          // Pricing / Action
                          GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Text('7 Days Free', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Then \$4.99 / month. Cancel anytime.', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                                const SizedBox(height: 24),
                                GlassButton(
                                  label: 'Start Free Trial',
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 32),
                          Text('Restore Purchases', style: TextStyle(color: AppColors.textSecondary, decoration: TextDecoration.underline))
                              .animate().fadeIn(delay: 1000.ms),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int delay;

  const _FeatureRow({required this.icon, required this.title, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: AppColors.accent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}
