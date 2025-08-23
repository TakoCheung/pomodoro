import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_mode_switch_ui.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Pomodoro screen interactions: switch modes and open settings',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PomodoroTimerScreen()),
      ),
    );

    // Check mode switcher exists
    expect(find.byType(TimerModeSwitcherUI), findsOneWidget);

    // Tap the 'short break' button and expect the label to still exist
    final shortBreakFinder = find.text('short break');
    expect(shortBreakFinder, findsOneWidget);
    await tester.tap(shortBreakFinder);
    await tester.pumpAndSettle();

    // Tap 'long break' and ensure no exceptions
    final longBreakFinder = find.text('long break');
    expect(longBreakFinder, findsOneWidget);
    await tester.tap(longBreakFinder);
    await tester.pumpAndSettle();

    // Open settings via gear icon and expect SettingsScreen dialog appears
    final gearFinder = find.byType(GearIconButton);
    expect(gearFinder, findsOneWidget);
    await tester.tap(gearFinder);
    await tester.pumpAndSettle();

    // The dialog contains the 'Settings' text
    expect(find.text('Settings'), findsWidgets);
  });
}
