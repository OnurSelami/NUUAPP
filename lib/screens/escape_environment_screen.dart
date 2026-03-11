import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/glass_card.dart';
import '../widgets/bottom_nav.dart';

class EscapeEnvironmentScreen extends StatelessWidget {
  const EscapeEnvironmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final environments = [
      _Env('Ocean Waves', '15 min', Icons.water, const Color(0xFF1E3A5F)),
      _Env('Soft Rain', '20 min', Icons.cloud, const Color(0xFF1A2742)),
      _Env('Forest Light', '25 min', Icons.forest, const Color(0xFF1A3D2C)),
      _Env('Starry Night', '30 min', Icons.star, const Color(0xFF0F1B3D)),
      _Env('Calm Lake', '20 min', Icons.waves, const Color(0xFF1A3040)),
      _Env('Sunset Glow', '15 min', Icons.wb_sunny, const Color(0xFF3D2A1A)),
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Escape Environments',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 24),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: environments.length,
                      itemBuilder: (context, i) {
                        final env = environments[i];
                        return GlassCard(
                          onTap: () => context.go('/escape-player/$i'),
                          padding: const EdgeInsets.all(0),
                          borderRadius: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [env.color, env.color.withValues(alpha: 0.3)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(env.icon, color: AppColors.accent, size: 22),
                                ),
                                const Spacer(),
                                Text(
                                  env.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  env.duration,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 100 * i))
                            .scaleXY(begin: 0.9, end: 1);
                      },
                    ),
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

class _Env {
  final String title;
  final String duration;
  final IconData icon;
  final Color color;
  _Env(this.title, this.duration, this.icon, this.color);
}
