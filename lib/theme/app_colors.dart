import 'package:flutter/material.dart';

class AppColors {
  // Primary backgrounds
  static const Color bgDark = Color(0xFF051024);
  static const Color bgMedium = Color(0xFF0A1F3D);

  // Accent colors
  static const Color accent = Color(0xFF6EE7FF);
  static const Color accentSecondary = Color(0xFF3A8DFF);

  // Glass
  static const Color glassWhite = Color(0x1AFFFFFF); // white/10
  static const Color glassBorder = Color(0x33FFFFFF); // white/20
  static const Color glassHover = Color(0x0DFFFFFF); // white/5

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x99FFFFFF); // white/60
  static const Color textMuted = Color(0x66FFFFFF); // white/40

  // Status
  static const Color danger = Color(0xFFF87171);

  // Gradients
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgDark, bgMedium],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentSecondary],
  );

  // Glow shadow for accent elements
  static List<BoxShadow> accentGlow({double blur = 60, double opacity = 0.5}) {
    return [
      BoxShadow(
        color: accent.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: 0,
      ),
    ];
  }
}
