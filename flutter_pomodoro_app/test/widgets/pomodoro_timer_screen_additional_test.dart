import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('PomodoroTimerScreen contains title and gear button',
      (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));

    // The title text may appear in multiple places (different styles), assert it exists
    expect(find.text('pomodoro'), findsWidgets);
    expect(find.byType(GearIconButton), findsOneWidget);
  });
}
