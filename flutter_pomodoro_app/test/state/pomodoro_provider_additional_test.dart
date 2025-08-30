import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';

void main() {
  group('TimerNotifier additional unit tests', () {
    test('timeFormatted and minuteFormatted produce expected strings', () {
      final notifier = TimerNotifier();
      expect(notifier.timeFormatted(65), '01:05');
      expect(notifier.minuteFormatted(125), '02');
    });

    test('getInitialDuration returns correct initial durations', () {
      final notifier = TimerNotifier();
      notifier.state = notifier.state.copyWith(
        initPomodoro: 1500,
        initShortBreak: 300,
        initLongBreak: 900,
      );
      expect(notifier.getInitialDuration(TimerMode.pomodoro), 1500);
      expect(notifier.getInitialDuration(TimerMode.shortBreak), 300);
      expect(notifier.getInitialDuration(TimerMode.longBreak), 900);
    });

    test('progress calculation and toggle behavior', () async {
      final notifier = TimerNotifier();
      // Set a known timeRemaining
      notifier.state = notifier.state.copyWith(timeRemaining: 90);
      // progress is timeRemaining % 60 / 60 -> 30/60 -> 0.5
      expect(notifier.progress(), closeTo(0.5, 1e-6));

      // Toggle starts the timer (isRunning becomes true) but we won't let it run
      notifier.toggleTimer();
      expect(notifier.state.isRunning, isTrue);

      // Pause stops it
      notifier.pauseTimer();
      expect(notifier.state.isRunning, isFalse);
    });

    test('updateSettings applies LocalSettings values and resets mode time',
        () {
      final notifier = TimerNotifier();
      final settings = LocalSettings(
        initPomodoro: 5 * 60,
        initShortBreak: 2 * 60,
        initLongBreak: 10 * 60,
        fontFamily: 'TestFont',
        color: Colors.green,
      );

      // apply and ensure state changed
      notifier.updateSettings(settings);
      expect(notifier.state.initPomodoro, 300);
      expect(notifier.state.initShortBreak, 120);
      expect(notifier.state.initLongBreak, 600);
      expect(notifier.state.fontFamily, 'TestFont');
      expect(notifier.state.color, Colors.green);
      // setMode is called inside updateSettings and timeRemaining should match current mode initial
      expect(notifier.state.timeRemaining,
          notifier.getInitialDuration(notifier.state.mode));
    });
  });
}
