import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:malist/config/theme/app_theme.dart';
import 'package:malist/views/screens/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding smoke test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.trueBlackTheme,
        home: const OnboardingScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('M A L I S T'), findsOneWidget);
    expect(find.text('Welcome to Malist.'), findsOneWidget);
    expect(find.text('Zero clutter. Absolute focus.'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));

    expect(find.text('True Black.'), findsOneWidget);
    expect(
      find.text('Designed for your eyes and your battery.'),
      findsOneWidget,
    );
  });
}
