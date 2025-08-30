import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('TimerDisplay shows PAUSE when running and toggles to paused',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(timerProvider.notifier);
    // start with running state
    notifier.state =
        notifier.state.copyWith(isRunning: true, timeRemaining: 65);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: TimerDisplay())),
    ));

    // When running, button should be PAUSE
    expect(find.text('PAUSE'), findsOneWidget);

    // Tap will call pauseTimer()
    await tester.tap(find.byKey(const Key('pauseRestart')));
    await tester.pumpAndSettle();

    expect(notifier.state.isRunning, isFalse);
  });

  testWidgets('TimerDisplay shows RESTART when stopped and toggles to running',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(timerProvider.notifier);
    notifier.state =
        notifier.state.copyWith(isRunning: false, timeRemaining: 130);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: TimerDisplay())),
    ));

    expect(find.text('RESTART'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pauseRestart')));
    await tester.pumpAndSettle();

    // Tapping RESTART flips running state via toggleTimer
    expect(notifier.state.isRunning, isTrue);
    // Stop the timer so tests don't leave pending timers
    notifier.pauseTimer();
    // Let the timer callback run and cancel itself
    await tester.pump(const Duration(seconds: 2));
  });
}
