import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('PomodoroTimerScreen constructor + build', (tester) async {
    // no special window sizing required for this constructor test
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: PomodoroTimerScreen(key: Key('pt')))));
    expect(find.byKey(const Key('pt')), findsOneWidget);
    expect(find.byKey(const Key('pomodoro_title')), findsOneWidget);
  });
}
