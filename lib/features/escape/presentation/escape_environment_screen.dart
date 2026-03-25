import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import 'escape_controller.dart';

class EscapeEnvironmentScreen extends ConsumerWidget {
  const EscapeEnvironmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environments = availableEnvironments;

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
                        const Expanded(
                          child: Text(
                            'Sounds',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/focus'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.glassWhite,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.focus, color: AppColors.accent, size: 16),
                                const SizedBox(width: 8),
                                const Text(
                                  'Focus Timer',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
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
                          onTap: () {
                            ref.read(escapeProvider.notifier).selectEnvironment(env);
                            context.go('/escape-player/$i');
                          },
                          padding: const EdgeInsets.all(0),
                          borderRadius: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [env.baseColor, env.baseColor.withValues(alpha: 0.3)],
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
                                  'Explore',
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
