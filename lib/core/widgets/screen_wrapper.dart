import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ScreenWrapper({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF051024), Color(0xFF0A1F3D)],
        ),
      ),
      child: child,
    )
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeInOut)
        .blurXY(begin: 10, end: 0, duration: 800.ms, curve: Curves.easeInOut);
  }
}
