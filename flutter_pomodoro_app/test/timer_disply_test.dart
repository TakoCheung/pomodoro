import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pomodoro Timer Screen Tests', () {
    testWidgets('Timer starts and displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PomodoroTimerScreen(),
        ),
      );

      // Verify default timer state
      expect(find.text('25:00'), findsOneWidget);

      // Simulate start of the timer and test the behavior
      await tester.tap(find.byKey(const Key('restart')));
      await tester.pumpAndSettle();
      // Verify that timer is started
    });

    testWidgets('Timer can be customized', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PomodoroTimerScreen(),
        ),
      );

      // Customize the timer
      await tester.tap(find.byKey(const Key('customizeButton')));
      await tester.pumpAndSettle();

      // Check if customization options are displayed
      expect(find.text('Set Pomodoro Duration'), findsOneWidget);
    });
  });
}