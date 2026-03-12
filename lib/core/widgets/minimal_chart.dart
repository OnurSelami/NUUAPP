import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MinimalChart extends StatelessWidget {
  final List<double> dataPoints; // Values 0.0 to 1.0

  const MinimalChart({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: _MinimalChartPainter(points: dataPoints),
      ),
    );
  }
}

class _MinimalChartPainter extends CustomPainter {
  final List<double> points;

  _MinimalChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final widthStep = size.width / (points.length - 1 == 0 ? 1 : points.length - 1);
    
    for (int i = 0; i < points.length; i++) {
      final x = i * widthStep;
      // Scale data dynamically inside height. Let's assume max is 1.0. 
      // y=size.height at 0.0, y=0.2*size.height at 1.0
      final y = size.height - (points[i] * size.height * 0.8);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * widthStep;
        final prevY = size.height - (points[i - 1] * size.height * 0.8);
        
        final controlPoint1X = prevX + widthStep / 2;
        final controlPoint1Y = prevY;
        final controlPoint2X = x - widthStep / 2;
        final controlPoint2Y = y;
        
        path.cubicTo(controlPoint1X, controlPoint1Y, controlPoint2X, controlPoint2Y, x, y);
      }
    }
    
    // Draw glow
    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, glowPaint);

    // Draw main line
    canvas.drawPath(path, paint);

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accent.withValues(alpha: 0.4),
          AppColors.accent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
