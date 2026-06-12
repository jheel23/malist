import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:malist/data/models/onboarding/onboarding_page_data.dart';
import 'package:malist/views/widgets/onboarding/onboarding_glyph.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.data,
    required this.index,
    required this.currentIndex,
    required this.motion,
  });

  final OnboardingPageData data;
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
                            return OnboardingGlyph(
                              type: data.glyph,
                              progress: motion.value,
                              isActive: visible,
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
