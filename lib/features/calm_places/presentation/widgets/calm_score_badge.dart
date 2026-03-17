import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Circular calm score badge with gradient ring and color-coded display
class CalmScoreBadge extends StatelessWidget {
  final int score;
  final double size;

  const CalmScoreBadge({super.key, required this.score, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor;
    final progress = score / 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          // Score ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Score text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              if (size >= 48)
                Text(
                  'calm',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: size * 0.16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _scoreColor {
    if (score >= 80) return const Color(0xFF4ADE80); // green
    if (score >= 60) return AppColors.accent; // cyan
    if (score >= 40) return const Color(0xFFFBBF24); // amber
    return const Color(0xFFF87171); // red
  }
}
