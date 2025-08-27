import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';

class IslamicPatternHeader extends StatelessWidget {
  final String title;
  final double height;
  final VoidCallback? onSettingsPressed; // optional action

  const IslamicPatternHeader({
    super.key,
    required this.title,
    this.height = 60,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: IslamicColors.desertSand, // flat beige
        borderRadius: const BorderRadius.only(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: CustomPaint(
                painter: IslamicPatternPainter(),
              ),
            ),
          ),

          // Settings icon top-right
          if (onSettingsPressed != null)
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                onPressed: onSettingsPressed,
                icon: const Icon(Icons.settings, color: IslamicColors.calligraphyBlack),
                tooltip: 'Settings',
              ),
            ),

          // Left-aligned title/subtitle
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: IslamicColors.calligraphyBlack,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IslamicColors.calligraphyBlack.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;

    _drawStarPattern(canvas, center, radius, paint);
    _drawHexagonPattern(canvas, center, radius * 0.6, paint);
    _drawDiamondPattern(canvas, center, radius * 0.4, paint);
  }

  void _drawStarPattern(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const sides = 8;
    const angleStep = 2 * math.pi / sides;
    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagonPattern(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const sides = 6;
    const angleStep = 2 * math.pi / sides;
    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamondPattern(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const sides = 4;
    const angleStep = 2 * math.pi / sides;
    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
