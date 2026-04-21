import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NoDataWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final double? widgetSize;
  const NoDataWidget({
    super.key,
    this.message,
    this.icon,
    this.widgetSize = 500,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        height: widgetSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Iconsax.note_text,
              size: 50,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            Text(
              message ?? "No data found",
              textAlign: .center,
              style: theme.textTheme.bodyLarge!.copyWith(
                color: theme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
