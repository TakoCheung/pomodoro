import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';

void main() {
  group('TimerNotifier targeted tests', () {
    test('progress uses modulo 60 correctly', () {
      final notifier = TimerNotifier();
      notifier.state = notifier.state
          .copyWith(timeRemaining: 125); // 5*60 + 5 -> progress 5/60
      expect(notifier.progress(), closeTo(5 / 60, 1e-6));
    });

    test('timeFormatted pads single digit seconds/minutes', () {
      final notifier = TimerNotifier();
      expect(notifier.timeFormatted(5), '00:05');
      expect(notifier.timeFormatted(65), '01:05');
    });

    test('updateSettings calls setMode and updates timeRemaining accordingly',
        () {
      final notifier = TimerNotifier();
      final local = LocalSettings(
          initPomodoro: 1200,
          initShortBreak: 300,
          initLongBreak: 600,
          fontFamily: 'F',
          color: Colors.blue);
      notifier.state = notifier.state.copyWith(mode: TimerMode.shortBreak);
      notifier.updateSettings(local);
      expect(notifier.state.initPomodoro, 1200);
      // timeRemaining should match the mode's initial duration
      expect(notifier.state.timeRemaining,
          notifier.getInitialDuration(TimerMode.shortBreak));
    });
  });
}
