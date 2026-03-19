import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/particles.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

                  // Orbiting Actions
                  Center(
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _AltarAction(
                            icon: LucideIcons.focus,
                            label: 'Focus',
                            angle: -math.pi / 4, // Top Left
                            onTap: () => context.go('/focus'),
                          ),
                          _AltarAction(
                            icon: LucideIcons.moon,
                            label: 'Sleep',
                            angle: math.pi / 4, // Top Right
                            onTap: () => context.go('/sleep'),
                          ),
                          _AltarAction(
                            icon: LucideIcons.waves,
                            label: 'Tactile',
                            angle: 3 * math.pi / 4, // Bottom Right
                            onTap: () => context.push('/tactile'),
                          ),
                          _AltarAction(
                            icon: LucideIcons.wind,
                            label: 'Escape',
                            angle: -3 * math.pi / 4, // Bottom Left
                            onTap: () => context.go('/escape'),
                          ),
                          _AltarAction(
                            icon: LucideIcons.zap,
                            label: 'Go',
                            angle: math.pi / 2, // Bottom Center
                            onTap: () => context.push('/go-mode'),
                          ),
                        ],
                      ),
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

class _AltarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final double angle;
  final VoidCallback onTap;

  const _AltarAction({
    required this.icon,
    required this.label,
    required this.angle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Distance from center
    const double radius = 130.0;
    
    return Transform.translate(
      offset: Offset(
        radius * math.cos(angle),
        radius * math.sin(angle),
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glassWhite,
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 800.ms, delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
}
