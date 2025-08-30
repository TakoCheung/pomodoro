import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('TimerDisplay shows formatted time and button label',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // set a specific timeRemaining so formatted text appears
    final notifier = container.read(timerProvider.notifier);
    notifier.state =
        notifier.state.copyWith(isRunning: false, timeRemaining: 65);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: TimerDisplay())),
    ));

    expect(find.text('01:05'), findsOneWidget);
    expect(find.text('RESTART'), findsOneWidget);
  });
}
