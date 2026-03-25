import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/particles.dart';
import '../../features/energy_map/presentation/energy_map_controller.dart';
import '../../features/energy_map/presentation/energy_log_sheet.dart';
import '../../features/let_it_burn/presentation/let_it_burn_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
            
            // Subtle particles
            const Positioned.fill(
              child: Particles(count: 40, color: AppColors.sageGreen),
            ),

            SafeArea(
              child: Stack(
                children: [
                  // Top Greeting
                  Positioned(
                    top: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            'Breathe',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 8.0,
                            ),
                          ).animate().fadeIn(duration: 1200.ms, delay: 200.ms),
                          const SizedBox(height: 8),
                          const Text(
                            'You are exactly where you need to be.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ).animate().fadeIn(duration: 1200.ms, delay: 600.ms),
                        ],
                      ),
                    ),
                  ),

                  // The Altar (Central Pulse)
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push('/calm-pulse'),
                      behavior: HitTestBehavior.opaque,
                      child: const _AltarOrb(),
                    ),
                  ),

                  // Smart Insight, Let It Burn, & Sounds Shortcut
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final insight = ref.watch(energyMapProvider.notifier).getSmartInsight();
                            
                            return Text(
                              insight,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(duration: 800.ms, delay: 800.ms);
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => context.go('/escape'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.glassWhite.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.headphones, color: AppColors.textSecondary, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Sounds',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(duration: 800.ms, delay: 1000.ms),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const EnergyLogSheet(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.glassWhite.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.activity, color: AppColors.sageGreen, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Log Energy',
                                      style: TextStyle(
                                        color: AppColors.sageGreen,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(duration: 800.ms, delay: 1100.ms),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: LetItBurnWidget(),
                        ).animate().fadeIn(duration: 800.ms, delay: 1200.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _AltarOrb extends StatefulWidget {
  const _AltarOrb();

  @override
  State<_AltarOrb> createState() => _AltarOrbState();
}

class _AltarOrbState extends State<_AltarOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.15);
        final glowOpacity = 0.2 + (_controller.value * 0.3);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgSurface.withValues(alpha: 0.5),
              boxShadow: AppColors.glow(
                color: AppColors.accent,
                blur: 40 + (_controller.value * 40),
                opacity: glowOpacity,
              ),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.fingerprint,
                color: AppColors.sageGreen,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }
}

