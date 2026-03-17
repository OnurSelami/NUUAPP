import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/calm_place.dart';
import 'widgets/calm_score_badge.dart';
import 'calm_places_controller.dart';

/// Full place detail as a bottom sheet
class PlaceDetailSheet extends ConsumerWidget {
  final CalmPlace place;

  const PlaceDetailSheet({super.key, required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score + Name header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CalmScoreBadge(score: place.calmScore, size: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _tag(place.category.label, AppColors.accent),
                                const SizedBox(width: 8),
                                _tag(
                                  place.isOpenNow ? 'Open now' : 'Closed',
                                  place.isOpenNow
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFFF87171),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Distance info
                  _infoRow(LucideIcons.mapPin, '${place.distanceDisplay} — ${place.walkingTime}'),
                  if (place.address != null)
                    _infoRow(LucideIcons.navigation, place.address!),
                  const SizedBox(height: 20),

                  // Calm reasons
                  if (place.calmReasons.isNotEmpty) ...[
                    const Text(
                      'Why it\'s calming',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: place.calmReasons.map((reason) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            reason.text,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Score breakdown
                  _buildScoreBreakdown(),
                  const SizedBox(height: 28),

                  // Action buttons
                  _buildActions(context, ref),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Calm Score Breakdown',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _scoreBar('Category', _categoryPct, const Color(0xFF4ADE80)),
              _scoreBar('Distance', _distancePct, AppColors.accent),
              _scoreBar('Weather', 0.7, const Color(0xFFFBBF24)),
              _scoreBar('Time of Day', _timePct, const Color(0xFFA78BFA)),
            ],
          ),
        ),
      ),
    );
  }

  double get _categoryPct {
    // Nature-type categories get high scores
    if (place.category == PlaceCategory.forest || place.category == PlaceCategory.beach) return 0.95;
    if (place.category == PlaceCategory.park || place.category == PlaceCategory.trail) return 0.9;
    if (place.category == PlaceCategory.meditation) return 0.95;
    if (place.category == PlaceCategory.library) return 0.88;
    return 0.7;
  }

  double get _distancePct {
    if (place.distanceMeters < 500) return 1.0;
    if (place.distanceMeters < 1000) return 0.85;
    if (place.distanceMeters < 2000) return 0.7;
    if (place.distanceMeters < 3000) return 0.5;
    return 0.3;
  }

  double get _timePct {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour <= 9) return 1.0;
    if (hour >= 17 && hour <= 19) return 0.95;
    if (hour >= 10 && hour <= 16) return 0.7;
    return 0.3;
  }

  Widget _scoreBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Spacer(),
              Text('${(value * 100).round()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(calmPlacesProvider).savedPlaceIds.contains(place.id);

    return Row(
      children: [
        // Save button
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isSaved) {
                ref.read(calmPlacesProvider.notifier).removeSavedPlace(place.id);
              } else {
                ref.read(calmPlacesProvider.notifier).savePlace(place.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSaved ? AppColors.accent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSaved ? AppColors.accent : Colors.white.withValues(alpha: 0.1)),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.bookmark, 
                    color: isSaved ? AppColors.accent : Colors.white, 
                    size: 18
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSaved ? 'Saved' : 'Save', 
                    style: TextStyle(color: isSaved ? AppColors.accent : Colors.white, fontWeight: FontWeight.w600)
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Navigate button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _openNavigation(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.accentGlow(blur: 20, opacity: 0.3),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.navigation, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Navigate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openNavigation() async {
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
