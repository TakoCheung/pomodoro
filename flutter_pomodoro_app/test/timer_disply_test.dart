import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';

void main() {
  testWidgets('TimerDisplay shows correct time and button label', (WidgetTester tester) async {
    final container = ProviderContainer();
    final notifier = container.read(timerProvider.notifier);
    // final state = container.read(timerProvider);

    // Mock initial timer state
    notifier.startTimer();

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: TimerDisplay()),
      ),
    ));

    // Verify timer display
    expect(find.text('25:00'), findsOneWidget); // Update to actual formatted time
    expect(find.text('RESTART'), findsOneWidget);

    // Tap the button and verify label change
    await tester.tap(find.text('RESTART'));
    await tester.pump();
    expect(find.text('PAUSE'), findsOneWidget);
  });
}
