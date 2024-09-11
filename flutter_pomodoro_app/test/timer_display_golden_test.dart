import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('TimerDisplay golden test', (tester) async {
    final container = ProviderContainer();
    final notifier = container.read(timerProvider.notifier);
    
    // Mock initial timer state
    notifier.startTimer();

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: TimerDisplay()),
      ),
    ));

    // Capture the widget as a golden file
    await expectLater(
      find.byType(TimerDisplay),
      matchesGoldenFile('goldens/timer_display_initial.png'),
    );

    // Change state and capture again
    notifier.pauseTimer();
    await tester.pump();
    await expectLater(
      find.byType(TimerDisplay),
      matchesGoldenFile('goldens/timer_display_paused.png'),
    );
  });
}
