import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A generic [CustomPainter] that renders a fragment shader
/// with pre-set uniforms full-screen.
class ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;

  ShaderPainter({required this.shader});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) => true;
}
