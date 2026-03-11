import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/bottom_nav.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  int selectedMinutes = 25;
  bool isRunning = false;
  double progress = 0.0;

  final durations = [15, 25, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  children: [
                    const Text(
                      'Deep Focus',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Eliminate distractions. Enter the zone.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

                    const Spacer(),

                    // Timer circle
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress ring
                          CustomPaint(
                            size: const Size(240, 240),
                            painter: _RingPainter(progress: progress),
                          ),
                          // Timer text
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$selectedMinutes:00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(color: AppColors.accent.withValues(alpha: 0.5), blurRadius: 20),
                                  ],
                                ),
                              ),
                              Text('minutes', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms).scaleXY(begin: 0.9, end: 1),

                    const SizedBox(height: 40),

                    // Duration selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: durations.map((d) {
                        final isSelected = d == selectedMinutes;
                        return GestureDetector(
                          onTap: () => setState(() => selectedMinutes = d),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.glassWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.accent : AppColors.glassBorder,
                              ),
                            ),
                            child: Text(
                              '${d}m',
                              style: TextStyle(
                                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                    const Spacer(),

                    // Start button
                    GestureDetector(
                      onTap: () => setState(() => isRunning = !isRunning),
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppColors.accentGlow(blur: 30, opacity: 0.4),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isRunning ? LucideIcons.pause : LucideIcons.play,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isRunning ? 'Pause' : 'Start Focus',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
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

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.glassWhite
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.accent, AppColors.accentSecondary],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}
