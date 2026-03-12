import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/particles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/onboarding-1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: Particles()),
            // Ambient glow
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      blurRadius: 120,
                      spreadRadius: 60,
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 1, end: 1.2, duration: 3000.ms)
                  .fade(begin: 0.3, end: 0.5, duration: 3000.ms),
            ),
            // Logo
            Center(
              child: Text(
                'NUU',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 12,
                  shadows: [
                    Shadow(
                      color: AppColors.accent.withValues(alpha: 0.8),
                      blurRadius: 60,
                    ),
                    Shadow(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      blurRadius: 100,
                    ),
                  ],
                ),
              )
                  .animate()
                  .scaleXY(begin: 0.8, end: 1, duration: 1000.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 1000.ms),
            ),
          ],
        ),
      ),
    );
  }
}
