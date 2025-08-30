import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('PomodoroTimerScreen smoke test hits build tree', (tester) async {
    // no special window sizing required for this smoke test

    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));
    // Ensure title and gear button exist which touches the build
    expect(find.byKey(const Key('pomodoro_title')), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
