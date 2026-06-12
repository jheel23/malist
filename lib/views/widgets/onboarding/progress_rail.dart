import 'package:flutter/material.dart';

class ProgressRail extends StatelessWidget {
  const ProgressRail({
    super.key,
    required this.length,
    required this.activeIndex,
  });

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
