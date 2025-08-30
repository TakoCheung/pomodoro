import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('PomodoroTimerScreen smoke test', (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));
    await tester.pumpAndSettle();
    expect(find.text('pomodoro'), findsWidgets);
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
