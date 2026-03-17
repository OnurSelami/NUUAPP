import 'package:flutter/material.dart';

class AppColors {
  // Primary backgrounds (Deep, grounding darks)
  static const Color bgDark = Color(0xFF030712); // Very deep slate
  static const Color bgMedium = Color(0xFF0F172A); // Slightly lighter slate
  static const Color bgSurface = Color(0xFF1E293B);

  // Accents (Subtle, calming tones)
  static const Color sageGreen = Color(0xFF8B9A8A); // Calming sage
  static const Color mutedSand = Color(0xFFD4BBA5); // Warmth
  static const Color softIris = Color(0xFF7A859E); // Cool/sleepy focus

  // Keeping legacy accent names but shifting their colors for compatibility
  static const Color accent = sageGreen;
  static const Color accentSecondary = softIris;

  // Glassmorphism System
  static const Color glassWhite = Color(0x05FFFFFF); // extremely subtle white overlay
  static const Color glassBorder = Color(0x10FFFFFF); // subtle border
  static const Color glassHover = Color(0x0AFFFFFF); // hover state

  // Text Typography
  static const Color textPrimary = Color(0xFFF1F5F9); // Very legible off-white
  static const Color textSecondary = Color(0xFF94A3B8); // Muted slate-gray
  static const Color textMuted = Color(0xFF475569); // Darker gray for deep background contrast

  // Status
  static const Color danger = Color(0xFF991B1B);

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

  // Soft, diffuse glow for the "niş" feel
  static List<BoxShadow> glow({Color color = sageGreen, double blur = 60, double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: 0,
      ),
    ];
  }

  // Legacy compatibility for accentGlow
  static List<BoxShadow> accentGlow({double blur = 60, double opacity = 0.5}) {
    return glow(color: accent, blur: blur, opacity: opacity);
  }
}
