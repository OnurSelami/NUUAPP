import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import 'calm_places_controller.dart';
import 'widgets/place_card.dart';
import 'widgets/category_filter.dart';
import 'place_detail_sheet.dart';

class CalmPlacesListScreen extends ConsumerWidget {
  const CalmPlacesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calmPlacesProvider);

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
                    const Text(
                      'All Calm Places',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${state.filteredPlaces.length} places',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
              const SizedBox(height: 16),
              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CategoryFilter(
                  selected: state.selectedCategory,
                  onSelected: (cat) =>
                      ref.read(calmPlacesProvider.notifier).filterByCategory(cat),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 16),
              // List
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.accent),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        itemCount: state.filteredPlaces.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final place = state.filteredPlaces[i];
                          return PlaceCard(
                            place: place,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (_) => PlaceDetailSheet(place: place),
                              );
                            },
                          ).animate().fadeIn(
                                duration: 400.ms,
                                delay: Duration(milliseconds: 200 + i * 60),
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
}
