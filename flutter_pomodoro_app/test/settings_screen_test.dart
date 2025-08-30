import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Settings Screen Tests', () {
    testWidgets('Settings screen layout adjusts for mobile',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body:
                  Center(child: SizedBox(width: 420, child: SettingsScreen())),
            ),
          ),
        ),
      );

      // Verify the mobile layout
      expect(find.byKey(const Key('timeSection')), findsOneWidget);
      expect(find.byKey(const Key('fontSection')), findsOneWidget);
      expect(find.byKey(const Key('colorSection')), findsOneWidget);

      // no platform window modifications required
    });

    testWidgets('Settings screen layout adjusts for tablet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body:
                  Center(child: SizedBox(width: 540, child: SettingsScreen())),
            ),
          ),
        ),
      );

      // Verify the tablet layout
      expect(find.byKey(const Key('timeSection')), findsOneWidget);
      expect(find.byKey(const Key('fontSection')), findsOneWidget);
      expect(find.byKey(const Key('colorSection')), findsOneWidget);

      // no platform window modifications required
    });
  });
}
