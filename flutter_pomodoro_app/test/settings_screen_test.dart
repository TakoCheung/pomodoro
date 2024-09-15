import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Settings Screen Tests', () {
    testWidgets('Settings screen layout adjusts for mobile', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SettingsScreen(),
        ),
      );

      // Verify the mobile layout
      expect(find.byKey(const Key('timeSection')), findsOneWidget);
      expect(find.byKey(const Key('fontSection')), findsOneWidget);
      expect(find.byKey(const Key('colorSection')), findsOneWidget);
    });

    testWidgets('Settings screen layout adjusts for tablet', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1024, 768); // Set to tablet size
      await tester.pumpWidget(
        const ProviderScope(
          child: SettingsScreen(),
        ),
      );

      // Verify the tablet layout
      expect(find.byKey(const Key('timeSection')), findsOneWidget);
      expect(find.byKey(const Key('fontSection')), findsOneWidget);
      expect(find.byKey(const Key('colorSection')), findsOneWidget);

      // Clear the window size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}