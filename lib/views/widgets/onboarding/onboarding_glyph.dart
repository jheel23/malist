import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:malist/data/models/onboarding/onboarding_page_data.dart';

class OnboardingGlyph extends StatelessWidget {
  const OnboardingGlyph({
    super.key,
    required this.type,
    required this.progress,
    required this.isActive,
  });

  final GlyphType type;
  final double progress;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlyphPainter(
        type: type,
        progress: progress,
        isActive: isActive,
      ),
      child: Center(
        child: _GlyphCore(type: type, active: isActive),
      ),
    );
  }
}

class _GlyphCore extends StatelessWidget {
  const _GlyphCore({required this.type, required this.active});

  final GlyphType type;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      GlyphType.focus => Icons.center_focus_strong_rounded,
      GlyphType.black => Icons.dark_mode_outlined,
      GlyphType.vault => Icons.enhanced_encryption_outlined,
      GlyphType.gesture => Icons.swipe_left_alt_rounded,
      GlyphType.ready => Icons.verified_user_outlined,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      width: active ? 104 : 90,
      height: active ? 104 : 90,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: active ? 0.08 : 0.04),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: active ? 0.34 : 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: active ? 0.08 : 0),
            blurRadius: 42,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white.withValues(alpha: active ? 0.94 : 0.5),
        size: 42,
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.type,
    required this.progress,
    required this.isActive,
  });

  final GlyphType type;
  final double progress;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final minSide = math.min(size.width, size.height);
    final intensity = isActive ? 1.0 : 0.42;

    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.15 * intensity);

    final bright = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.58 * intensity);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.045 * intensity);

    final rotation = progress * math.pi * 2;
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 0.12);

    for (var i = 0; i < 4; i++) {
      final radius = minSide * (0.21 + i * 0.085) + pulse * 4;
      canvas.drawCircle(Offset.zero, radius, thin);
    }

    canvas.rotate(rotation * 0.88);
    final arcRect = Rect.fromCircle(
      center: Offset.zero,
      radius: minSide * 0.35,
    );
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 0.92, false, bright);

    switch (type) {
      case GlyphType.focus:
        _drawFocus(canvas, minSide, bright, fill, pulse);
      case GlyphType.black:
        _drawBlack(canvas, minSide, bright, fill, pulse);
      case GlyphType.vault:
        _drawVault(canvas, minSide, bright, fill, pulse);
      case GlyphType.gesture:
        _drawGesture(canvas, minSide, bright, fill, pulse);
      case GlyphType.ready:
        _drawReady(canvas, minSide, bright, fill, pulse);
    }

    canvas.restore();
  }

  void _drawFocus(
    Canvas canvas,
    double side,
    Paint line,
    Paint fill,
    double pulse,
  ) {
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(math.pi / 2 * i);
      canvas.drawLine(
        Offset(0, -side * 0.44),
        Offset(0, -side * (0.34 + pulse * 0.02)),
        line,
      );
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, side * 0.13, fill);
  }

  void _drawBlack(
    Canvas canvas,
    double side,
    Paint line,
    Paint fill,
    double pulse,
  ) {
    final path = Path()
      ..moveTo(-side * 0.22, -side * 0.16)
      ..lineTo(side * 0.2, -side * 0.26)
      ..lineTo(side * (0.26 + pulse * 0.02), side * 0.13)
      ..lineTo(-side * 0.17, side * 0.24)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, line);
  }

  void _drawVault(
    Canvas canvas,
    double side,
    Paint line,
    Paint fill,
    double pulse,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: side * 0.38,
        height: side * 0.28,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, line);
    canvas.drawCircle(Offset.zero, side * (0.04 + pulse * 0.008), line);
  }

  void _drawGesture(
    Canvas canvas,
    double side,
    Paint line,
    Paint fill,
    double pulse,
  ) {
    final startX = side * (0.18 - pulse * 0.06);
    final path = Path()
      ..moveTo(startX, -side * 0.08)
      ..cubicTo(
        -side * 0.02,
        -side * 0.18,
        -side * 0.26,
        -side * 0.08,
        -side * 0.28,
        side * 0.12,
      );
    canvas.drawPath(path, line);
    canvas.drawCircle(Offset(startX, -side * 0.08), side * 0.055, fill);
  }

  void _drawReady(
    Canvas canvas,
    double side,
    Paint line,
    Paint fill,
    double pulse,
  ) {
    final shield = Path()
      ..moveTo(0, -side * 0.27)
      ..lineTo(side * 0.2, -side * 0.18)
      ..lineTo(side * 0.16, side * 0.16)
      ..quadraticBezierTo(
        0,
        side * (0.28 + pulse * 0.02),
        -side * 0.16,
        side * 0.16,
      )
      ..lineTo(-side * 0.2, -side * 0.18)
      ..close();
    canvas.drawPath(shield, fill);
    canvas.drawPath(shield, line);
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.type != type ||
        oldDelegate.isActive != isActive;
  }
}
