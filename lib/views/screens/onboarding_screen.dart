import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:malist/core/constants/storage_keys.dart';
import 'package:malist/core/local/secure_storage_service.dart';
import 'package:malist/service_locator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _motionController;

  int _currentPage = 0;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      title: 'Welcome to Malist.',
      subtitle: 'Zero clutter. Absolute focus.',
      body:
          'Experience a completely unified digital vault. Notes, tasks, and passwords, refined into a single, distraction-free environment.',
      button: 'Next',
      glyph: _GlyphType.focus,
    ),
    _OnboardingPageData(
      title: 'True Black.',
      subtitle: 'Designed for your eyes and your battery.',
      body:
          'Malist features a deep #000000 AMOLED aesthetic. No harsh lights, no OLED smearing. Just pure, immersive contrast.',
      button: 'Next',
      glyph: _GlyphType.black,
    ),
    _OnboardingPageData(
      title: 'Uncompromising Security.',
      subtitle: 'Your data belongs only to you.',
      body:
          'Everything you store in Malist is secured locally using device-level hardware encryption. No cloud tracking. No external servers.',
      button: 'Next',
      glyph: _GlyphType.vault,
    ),
    _OnboardingPageData(
      title: 'Built for Speed.',
      subtitle: 'Keep the interface clean with intuitive gestures.',
      body:
          'Press and hold a task to delete it from your to-do list. Swipe left to instantly delete secure passwords. No extra buttons, just seamless control.',
      button: 'Next',
      glyph: _GlyphType.gesture,
    ),
    _OnboardingPageData(
      title: 'Ready to Focus.',
      subtitle: 'The vault is generated and locked to this device.',
      body:
          'Leave the noise behind. Start building your secure, minimalist digital workspace.',
      button: 'Enter Malist',
      glyph: _GlyphType.ready,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    if (_currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await sl<SecureStorageService>().setBool(
      StorageKeys.hasCompletedOnboarding,
      true,
    );

    if (mounted) context.go('/home');
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 580),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _motionController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _OnboardingAtmospherePainter(
                      progress: _motionController.value,
                      page: _currentPage,
                    ),
                  );
                },
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                  child: Row(
                    children: [
                      Text(
                        'M A L I S T',
                        style: theme.textTheme.labelLarge?.copyWith(
                          letterSpacing: 4,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: _currentPage == _pages.length - 1 ? 0 : 1,
                        duration: const Duration(milliseconds: 220),
                        child: IgnorePointer(
                          ignoring: _currentPage == _pages.length - 1,
                          child: TextButton(
                            onPressed: _skip,
                            child: const Text('SKIP'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (value) {
                      setState(() => _currentPage = value);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: _pages[index],
                        index: index,
                        currentIndex: _currentPage,
                        motion: _motionController,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  child: Column(
                    children: [
                      _ProgressRail(
                        length: _pages.length,
                        activeIndex: _currentPage,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _handlePrimaryAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.28),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _pages[_currentPage].button.toUpperCase(),
                              key: ValueKey(_currentPage),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.index,
    required this.currentIndex,
    required this.motion,
  });

  final _OnboardingPageData data;
  final int index;
  final int currentIndex;
  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = index == currentIndex;

    return AnimatedOpacity(
      opacity: visible ? 1 : 0.36,
      duration: const Duration(milliseconds: 420),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0.035, 0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 560;
              final glyphHeight = math.min(
                275.0,
                math.max(154.0, constraints.maxHeight * (compact ? 0.34 : 0.4)),
              );

              return SingleChildScrollView(
                physics: compact
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: compact
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      SizedBox(height: compact ? 4 : 12),
                      SizedBox(
                        height: glyphHeight,
                        child: AnimatedBuilder(
                          animation: motion,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _GlyphPainter(
                                type: data.glyph,
                                progress: motion.value,
                                isActive: visible,
                              ),
                              child: Center(
                                child: _GlyphCore(
                                  type: data.glyph,
                                  active: visible,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 320),
                          style:
                              theme.textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                height: 0.95,
                                letterSpacing: -1.2,
                                fontSize: compact ? 34 : 42,
                              ) ??
                              const TextStyle(),
                          child: Text(data.title),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          data.subtitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.86),
                            height: 1.15,
                            fontSize: compact ? 18 : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          data.body,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.58),
                            height: 1.52,
                            fontWeight: FontWeight.w400,
                            fontSize: compact ? 14 : null,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GlyphCore extends StatelessWidget {
  const _GlyphCore({required this.type, required this.active});

  final _GlyphType type;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      _GlyphType.focus => Icons.center_focus_strong_rounded,
      _GlyphType.black => Icons.dark_mode_outlined,
      _GlyphType.vault => Icons.enhanced_encryption_outlined,
      _GlyphType.gesture => Icons.swipe_left_alt_rounded,
      _GlyphType.ready => Icons.verified_user_outlined,
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

class _ProgressRail extends StatelessWidget {
  const _ProgressRail({required this.length, required this.activeIndex});

  final int length;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(length, (index) {
        final active = index == activeIndex;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutCubic,
            height: 3,
            margin: EdgeInsets.only(right: index == length - 1 ? 0 : 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: active ? 1 : 0.16),
              borderRadius: BorderRadius.circular(99),
              boxShadow: [
                if (active)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.36),
                    blurRadius: 12,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.type,
    required this.progress,
    required this.isActive,
  });

  final _GlyphType type;
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

    canvas.rotate(rotation * 0.42);
    final arcRect = Rect.fromCircle(
      center: Offset.zero,
      radius: minSide * 0.35,
    );
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 0.92, false, bright);

    switch (type) {
      case _GlyphType.focus:
        _drawFocus(canvas, minSide, bright, fill, pulse);
      case _GlyphType.black:
        _drawBlack(canvas, minSide, bright, fill, pulse);
      case _GlyphType.vault:
        _drawVault(canvas, minSide, bright, fill, pulse);
      case _GlyphType.gesture:
        _drawGesture(canvas, minSide, bright, fill, pulse);
      case _GlyphType.ready:
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

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.button,
    required this.glyph,
  });

  final String title;
  final String subtitle;
  final String body;
  final String button;
  final _GlyphType glyph;
}

enum _GlyphType { focus, black, vault, gesture, ready }
