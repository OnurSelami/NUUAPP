import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../data/models/calm_place.dart';
import 'calm_places_controller.dart';

class GoModeScreen extends ConsumerStatefulWidget {
  const GoModeScreen({super.key});

  @override
  ConsumerState<GoModeScreen> createState() => _GoModeScreenState();
}

class _GoModeScreenState extends ConsumerState<GoModeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger Go Mode immediately on open
    Future.microtask(() {
      ref.read(calmPlacesProvider.notifier).goMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calmPlacesProvider);
    final place = state.goModePlace;

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Stack(
          children: [
            // Deep gradient
            Container(decoration: const BoxDecoration(gradient: AppColors.bgGradient)),

            // Atmospheric glow
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sageGreen.withValues(alpha: 0.08),
                        blurRadius: 120,
                        spreadRadius: 60,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary),
                          onPressed: () => context.pop(),
                        ),
                        const Text(
                          'GO MODE',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4.0,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  Expanded(
                    child: state.isGoModeLoading || state.isLoading
                        ? _buildLoading()
                        : place != null
                            ? _buildRecommendation(place)
                            : _buildNoResult(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'FINDING YOUR\nCALM',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w200,
              letterSpacing: 2,
              height: 1.3,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.4, end: 1.0, duration: 1500.ms),
          const SizedBox(height: 40),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.sageGreen.withValues(alpha: 0.6),
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResult() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.mapPinOff, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 20),
          const Text(
            'No calm places found nearby.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.pop(),
            child: const Text(
              'GO BACK',
              style: TextStyle(
                color: AppColors.sageGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(CalmPlace place) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Category emoji large
          Text(
            place.category.emoji,
            style: const TextStyle(fontSize: 64),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),

          const SizedBox(height: 32),

          // Calm Score — massive
          Text(
            '${place.calmScore}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 72,
              fontWeight: FontWeight.w100,
              letterSpacing: -2,
              shadows: [
                Shadow(
                  color: AppColors.sageGreen.withValues(alpha: 0.4),
                  blurRadius: 40,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 800.ms),

          const SizedBox(height: 4),
          Text(
            'CALM SCORE',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.0,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 40),

          // Place name
          Text(
            place.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 12),

          // Distance + walking time
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.mapPin, color: AppColors.sageGreen, size: 14),
              const SizedBox(width: 6),
              Text(
                '${place.distanceDisplay} • ${place.walkingTime}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14, letterSpacing: 0.5),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 12),

          // First calm reason
          if (place.calmReasons.isNotEmpty)
            Text(
              place.calmReasons.first.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ).animate().fadeIn(delay: 700.ms),

          const Spacer(flex: 2),

          // "TAKE ME THERE" Button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _openNavigation(place);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.sageGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sageGreen.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.navigation, color: AppColors.bgDark, size: 18),
                  SizedBox(width: 12),
                  Text(
                    'TAKE ME THERE',
                    style: TextStyle(
                      color: AppColors.bgDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          // "Try another" subtle link
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(calmPlacesProvider.notifier).goMode();
            },
            child: const Text(
              'TRY ANOTHER',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                decoration: TextDecoration.underline,
              ),
            ),
          ).animate().fadeIn(delay: 1000.ms),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Future<void> _openNavigation(CalmPlace place) async {
    final lat = place.location.latitude;
    final lng = place.location.longitude;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      debugPrint('Could not launch navigation');
    }
  }
}
