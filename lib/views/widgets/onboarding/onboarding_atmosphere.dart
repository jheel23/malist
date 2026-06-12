import 'dart:math' as math;
import 'package:flutter/material.dart';

class OnboardingAtmosphere extends StatelessWidget {
  const OnboardingAtmosphere({
    super.key,
    required this.progress,
    required this.page,
  });

  final double progress;
  final int page;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OnboardingAtmospherePainter(progress: progress, page: page),
    );
  }
}

class _OnboardingAtmospherePainter extends CustomPainter {
  const _OnboardingAtmospherePainter({
    required this.progress,
    required this.page,
  });

  final double progress;
  final int page;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final center = Offset(size.width * 0.5, size.height * 0.34);
    final t = progress * math.pi * 2;
    final drift = math.sin(t + page) * 18;

    for (var i = 0; i < 8; i++) {
      paint
        ..strokeWidth = 0.55
        ..color = Colors.white.withValues(alpha: 0.018 + i * 0.006);

      final radius = 90.0 + i * 38 + math.sin(t + i) * 10;
      final rect = Rect.fromCircle(
        center: Offset(center.dx + drift, center.dy - drift * 0.42),
        radius: radius,
      );

      canvas.drawArc(
        rect,
        t * (0.03 + i * 0.006),
        math.pi * (0.42 + (i % 3) * 0.12),
        false,
        paint,
      );
    }

    final gradientPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.075),
              Colors.white.withValues(alpha: 0.012),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(center.dx + drift, center.dy),
              radius: size.width * 0.78,
            ),
          );

    canvas.drawCircle(
      Offset(center.dx + drift, center.dy),
      size.width * 0.78,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OnboardingAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.page != page;
  }
}
