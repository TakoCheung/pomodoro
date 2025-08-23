import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_mode_switch_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('PomodoroTimerScreen shows title and child widgets',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: PomodoroTimerScreen()),
    ));

    await tester.pumpAndSettle();

  // The title may appear multiple times (dialog, small labels) in the
  // widget tree during tests; ensure at least one instance is present.
  expect(find.text('pomodoro'), findsWidgets);
    expect(find.byType(TimerDisplay), findsOneWidget);
    expect(find.byType(GearIconButton), findsOneWidget);
    expect(find.byType(TimerModeSwitcherUI), findsOneWidget);
  });
}
