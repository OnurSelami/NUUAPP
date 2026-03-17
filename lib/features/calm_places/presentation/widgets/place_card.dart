import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/calm_place.dart';
import 'calm_score_badge.dart';

/// Reusable glass card for a calm place
class PlaceCard extends StatelessWidget {
  final CalmPlace place;
  final VoidCallback? onTap;
  final bool showTopReason;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
    this.showTopReason = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Category icon container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _categoryColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(_categoryIcon, color: _categoryColor, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          // Info
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, color: AppColors.accent, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      place.distanceDisplay,
                      style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${place.category.label}',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                if (showTopReason && place.calmReasons.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    place.calmReasons.first.text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Score
          CalmScoreBadge(score: place.calmScore, size: 44),
        ],
      ),
    );
  }

  IconData get _categoryIcon {
    switch (place.category) {
      case PlaceCategory.park:
        return LucideIcons.trees;
      case PlaceCategory.forest:
        return LucideIcons.treeDeciduous;
      case PlaceCategory.beach:
        return LucideIcons.waves;
      case PlaceCategory.cafe:
        return LucideIcons.coffee;
      case PlaceCategory.library:
        return LucideIcons.bookOpen;
      case PlaceCategory.meditation:
        return LucideIcons.sparkles;
      case PlaceCategory.wellness:
        return LucideIcons.heart;
      case PlaceCategory.trail:
        return LucideIcons.footprints;
    }
  }

  Color get _categoryColor {
    switch (place.category) {
      case PlaceCategory.park:
      case PlaceCategory.forest:
      case PlaceCategory.trail:
        return const Color(0xFF4ADE80); // green
      case PlaceCategory.beach:
        return const Color(0xFF38BDF8); // sky blue
      case PlaceCategory.cafe:
        return const Color(0xFFFBBF24); // amber
      case PlaceCategory.library:
        return const Color(0xFFA78BFA); // violet
      case PlaceCategory.meditation:
      case PlaceCategory.wellness:
        return const Color(0xFFF472B6); // pink
    }
  }
}
