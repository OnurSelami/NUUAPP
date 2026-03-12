import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/environment_card.dart';
import '../widgets/glass_card.dart';
import '../../features/escape/presentation/escape_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Environments',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/escape'),
                          child: Text(
                            'View All',
                            style: TextStyle(color: AppColors.accent, fontSize: 14),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms),
                    const SizedBox(height: 16),

                    // Environment cards with Unsplash images
                    // Environment cards with Unsplash images
                    ...availableEnvironments.asMap().entries.map((entry) {
                      final i = entry.key;
                      final env = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EnvironmentCard(
                          title: env.title,
                          subtitle: env.subtitle,
                          imageUrl: env.imageUrl,
                          baseColor: env.baseColor,
                          onTap: () {
                            ref.read(escapeProvider.notifier).selectEnvironment(env);
                            context.go('/escape-player/${env.id}');
                          },
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

