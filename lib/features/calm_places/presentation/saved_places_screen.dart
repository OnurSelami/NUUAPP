import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import 'calm_places_controller.dart';
import 'widgets/calm_score_badge.dart';

class SavedPlacesScreen extends ConsumerWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calmPlacesProvider);
    final savedPlaces = state.places
        .where((p) => state.savedPlaceIds.contains(p.id))
        .toList();

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.bookmark, color: AppColors.accent, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Saved Places',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
              const SizedBox(height: 24),
              // Content
              Expanded(
                child: savedPlaces.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        itemCount: savedPlaces.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final place = savedPlaces[i];
                          return GlassCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CalmScoreBadge(score: place.calmScore, size: 42),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${place.category.label} · ${place.distanceDisplay}',
                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ref.read(calmPlacesProvider.notifier).removeSavedPlace(place.id);
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.trash2, color: AppColors.danger, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(
                                duration: 400.ms,
                                delay: Duration(milliseconds: 100 + i * 80),
                              ).slideY(begin: 0.05, end: 0);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.bookmark, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'No saved places yet',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Save calm places to revisit them later.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
