import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../domain/surface_type.dart';
import 'tactile_surface_screen.dart';

class TactileMenuScreen extends StatelessWidget {
  const TactileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'TACTILE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Sensory Resets',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Explore soothing surfaces to ground your mind in the present.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 48),

                // Cards
                Expanded(
                  child: ListView(
                    children: const [
                      _TactileMenuCard(
                        type: SurfaceType.water,
                        index: 0,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TactileMenuCard extends StatelessWidget {
  final SurfaceType type;
  final int index;

  const _TactileMenuCard({
    required this.type,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final Color hintColor = const Color(0xFF4A90E2); // Soft blue

    return GlassCard(
      padding: const EdgeInsets.all(0), // Custom internal padding
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                TactileSurfaceScreen(type: type),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Subtle gradient hinting at the surface
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              hintColor.withValues(alpha: 0.05),
              hintColor.withValues(alpha: 0.15),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    type.title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.draw_rounded, // Simple abstract icon for sensory action
              color: hintColor.withValues(alpha: 0.4),
              size: 32,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: (200 + (100 * index)).ms).slideX(begin: 0.1, end: 0);
  }
}
