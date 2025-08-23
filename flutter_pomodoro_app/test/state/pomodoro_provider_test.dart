import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter/material.dart';

void main() {
  group('TimerNotifier (unit)', () {
    test('initial state matches defaults', () {
      final notifier = TimerNotifier();

      expect(notifier.state.timeRemaining, TimerState.pomodoroDefaut);
      expect(notifier.state.isRunning, isFalse);
      expect(notifier.state.mode, TimerMode.pomodoro);
      expect(notifier.getInitialDuration(TimerMode.shortBreak),
          notifier.state.initShortBreak);

      // formatting helpers
      expect(notifier.timeFormatted(65), '01:05');
      expect(notifier.minuteFormatted(125), '02');

      notifier.dispose();
    });

    test('decrementTimer lowers time and does not go negative', () {
      final notifier = TimerNotifier();
      notifier.state = notifier.state.copyWith(timeRemaining: 1);

      notifier.decrementTimer();
      expect(notifier.state.timeRemaining, 0);

      // calling again should keep at 0
      notifier.decrementTimer();
      expect(notifier.state.timeRemaining, 0);

      notifier.dispose();
    });

    test('setMode updates mode, timeRemaining and stops running', () {
      final notifier = TimerNotifier();
      notifier.state = notifier.state.copyWith(isRunning: true);

      notifier.setMode(TimerMode.shortBreak);

      expect(notifier.state.mode, TimerMode.shortBreak);
      expect(notifier.state.timeRemaining, notifier.getInitialDuration(TimerMode.shortBreak));
      expect(notifier.state.isRunning, isFalse);

      notifier.dispose();
    });

    test('updateSettings applies LocalSettings values', () {
      final notifier = TimerNotifier();
      final ls = LocalSettings(
        initPomodoro: 1200,
        initShortBreak: 100,
        initLongBreak: 800,
        fontFamily: 'TestFont',
        color: Colors.green,
      );

      notifier.updateSettings(ls);

      expect(notifier.state.initPomodoro, 1200);
      expect(notifier.state.initShortBreak, 100);
      expect(notifier.state.initLongBreak, 800);
      expect(notifier.state.fontFamily, 'TestFont');
      expect(notifier.state.color, Colors.green);

      notifier.dispose();
    });
  });
}
