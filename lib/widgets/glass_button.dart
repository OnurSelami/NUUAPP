import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isOutline;
  final double? width;

  const GlassButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isOutline = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: isOutline ? null : AppColors.accentGradient,
          borderRadius: BorderRadius.circular(24),
          border: isOutline
              ? Border.all(color: AppColors.glassBorder, width: 1)
              : null,
          boxShadow: isOutline ? null : AppColors.accentGlow(blur: 30, opacity: 0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
