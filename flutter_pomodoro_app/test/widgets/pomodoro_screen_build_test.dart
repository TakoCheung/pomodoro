import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('PomodoroTimerScreen builds and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PomodoroTimerScreen(),
        ),
      ),
    );

  // There may be multiple Text widgets containing 'pomodoro' (different styles),
  // ensure at least one is present.
  expect(find.text('pomodoro'), findsWidgets);
    expect(find.byType(TimerDisplay), findsOneWidget);
    expect(find.byType(GearIconButton), findsOneWidget);
  });
}
