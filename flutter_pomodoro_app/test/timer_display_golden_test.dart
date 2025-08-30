import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Pomodoro Timer smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));

    // basic smoke checks (title may appear more than once in different styles)
    expect(find.text('pomodoro'), findsWidgets);
    expect(find.byType(PomodoroTimerScreen), findsOneWidget);
  });
}
