import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';

import '../../../core/widgets/bottom_nav.dart';
import '../data/models/calm_place.dart';
import 'calm_places_controller.dart';
import 'widgets/weather_chip.dart';
import 'widgets/place_card.dart';
import 'widgets/category_filter.dart';
import 'widgets/calm_score_badge.dart';
import 'widgets/best_time_badge.dart';
import 'place_detail_sheet.dart';

class CalmPlacesHomeScreen extends ConsumerStatefulWidget {
  const CalmPlacesHomeScreen({super.key});

  @override
  ConsumerState<CalmPlacesHomeScreen> createState() => _CalmPlacesHomeScreenState();
}

class _CalmPlacesHomeScreenState extends ConsumerState<CalmPlacesHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load places when screen opens
    Future.microtask(() {
      ref.read(calmPlacesProvider.notifier).loadNearbyPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calmPlacesProvider);

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.bgDark,
                      onRefresh: () => ref.read(calmPlacesProvider.notifier).loadNearbyPlaces(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(state),
                            const SizedBox(height: 24),

                            // Weather
                            if (state.weather != null)
                              WeatherChip(weather: state.weather!)
                                  .animate()
                                  .fadeIn(duration: 500.ms, delay: 100.ms),
                            const SizedBox(height: 24),

                            // Best Right Now — Top 3
                            if (state.bestNow.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(LucideIcons.sparkles, color: AppColors.accent, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Best Right Now',
                                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 170,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.bestNow.length,
                                  separatorBuilder: (_, i) => const SizedBox(width: 12),
                                  itemBuilder: (context, i) {
                                    final place = state.bestNow[i];
                                    return _BestNowCard(
                                      place: place,
                                      onTap: () => _showDetail(place),
                                    ).animate().fadeIn(
                                          duration: 500.ms,
                                          delay: Duration(milliseconds: 300 + i * 100),
                                        ).slideX(begin: 0.1, end: 0);
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],

                            // Categories
                            CategoryFilter(
                              selected: state.selectedCategory,
                              onSelected: (cat) =>
                                  ref.read(calmPlacesProvider.notifier).filterByCategory(cat),
                            ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                            const SizedBox(height: 20),

                            // Nearby discoveries
                            Row(
                              children: [
                                const Text(
                                  'Nearby Discoveries',
                                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => context.push('/calm-places/map'),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.map, color: AppColors.accent, size: 14),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Map',
                                        style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
                            const SizedBox(height: 12),

                            if (state.filteredPlaces.isEmpty && !state.isLoading)
                              _buildEmptyState(),

                            ...state.filteredPlaces.asMap().entries.map((entry) {
                              final i = entry.key;
                              final place = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: PlaceCard(
                                  place: place,
                                  onTap: () => _showDetail(place),
                                ).animate().fadeIn(
                                      duration: 400.ms,
                                      delay: Duration(milliseconds: 600 + i * 80),
                                    ).slideY(begin: 0.05, end: 0),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
            ),
            const BottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CalmPlacesState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find Calm',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
              ),
              Text(
                'Near You',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        // Saved places button
        GestureDetector(
          onTap: () => context.push('/calm-places/saved'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(LucideIcons.bookmark, color: Colors.white, size: 20),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(LucideIcons.mapPin, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'No calm places found nearby',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Try expanding the search radius or changing the category.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDetail(CalmPlace place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PlaceDetailSheet(place: place),
    );
  }
}

/// Horizontal scrolling "Best Right Now" card
class _BestNowCard extends StatelessWidget {
  final CalmPlace place;
  final VoidCallback? onTap;

  const _BestNowCard({required this.place, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accent.withValues(alpha: 0.1),
              AppColors.accentSecondary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CalmScoreBadge(score: place.calmScore, size: 40),
                const Spacer(),
                if (place.calmScore >= 80) const BestTimeBadge(text: 'Best now'),
              ],
            ),
            const Spacer(),
            Text(
              place.name,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(LucideIcons.mapPin, color: AppColors.accent, size: 12),
                const SizedBox(width: 4),
                Text(
                  place.walkingTime,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (place.calmReasons.isNotEmpty)
              Text(
                place.calmReasons.first.text,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
