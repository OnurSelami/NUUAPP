import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/glass_card.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final environments = [
      _Env('Ocean Waves', 'Sunset ocean ambiance', Icons.water, const Color(0xFF1E3A5F)),
      _Env('Soft Rain', 'Gentle rain in darkness', Icons.cloud, const Color(0xFF1A2742)),
      _Env('Forest Light', 'Foggy forest with light beams', Icons.forest, const Color(0xFF1A3D2C)),
      _Env('Starry Night', 'Calm starry sky', Icons.star, const Color(0xFF0F1B3D)),
    ];

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Find Your Calm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 32),

                    // Quick access
                    Row(
                      children: [
                        _QuickAction(
                          icon: LucideIcons.target,
                          label: 'Focus',
                          onTap: () => context.go('/focus'),
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: LucideIcons.moon,
                          label: 'Sleep',
                          onTap: () => context.go('/sleep'),
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: LucideIcons.mapPin,
                          label: 'Places',
                          onTap: () => context.go('/calm-places'),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 32),

                    // Environments section
                    const Text(
                      'Escape Environments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms),
                    const SizedBox(height: 16),

                    // Environment cards
                    ...environments.asMap().entries.map((entry) {
                      final i = entry.key;
                      final env = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          onTap: () => context.go('/escape-player/$i'),
                          padding: const EdgeInsets.all(0),
                          borderRadius: 20,
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [env.color, env.color.withValues(alpha: 0.3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        env.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        env.subtitle,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(env.icon, color: AppColors.accent, size: 28),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 400 + i * 100))
                            .slideY(begin: 0.2, end: 0),
                      );
                    }),
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 20),
        borderRadius: 20,
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Env {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  _Env(this.title, this.subtitle, this.icon, this.color);
}
