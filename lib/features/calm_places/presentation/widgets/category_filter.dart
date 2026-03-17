import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/calm_place.dart';

/// Horizontal scrollable category filter pills
class CategoryFilter extends StatelessWidget {
  final PlaceCategory? selected;
  final ValueChanged<PlaceCategory?> onSelected;

  const CategoryFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _categories = PlaceCategory.values;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // "All" chip
          _FilterChip(
            label: 'All',
            icon: Icons.grid_view_rounded,
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          ..._categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: cat.label,
                  icon: _categoryIcon(cat),
                  isSelected: selected == cat,
                  onTap: () => onSelected(cat),
                ),
              )),
        ],
      ),
    );
  }

  IconData _categoryIcon(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.park:
        return Icons.park;
      case PlaceCategory.forest:
        return Icons.forest;
      case PlaceCategory.beach:
        return Icons.beach_access;
      case PlaceCategory.cafe:
        return Icons.local_cafe;
      case PlaceCategory.library:
        return Icons.local_library;
      case PlaceCategory.meditation:
        return Icons.self_improvement;
      case PlaceCategory.wellness:
        return Icons.spa;
      case PlaceCategory.trail:
        return Icons.hiking;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.bgDark : Colors.white.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.bgDark : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
