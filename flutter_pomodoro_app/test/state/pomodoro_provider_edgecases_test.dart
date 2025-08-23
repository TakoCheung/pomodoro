import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';

void main() {
  group('TimerNotifier edge case tests', () {
    test('decrementTimer leaves 0 unchanged', () {
      final notifier = TimerNotifier();
      notifier.state = notifier.state.copyWith(timeRemaining: 0);
      notifier.decrementTimer();
      expect(notifier.state.timeRemaining, 0);
    });

    test('startTimer via toggle then dispose does not throw', () {
      final notifier = TimerNotifier();
      // toggleTimer will set isRunning=true and call startTimer()
      notifier.toggleTimer();

      // Immediately disposing should cancel any scheduled timer; ensure no exceptions
      expect(() => notifier.dispose(), returnsNormally);

      // Do not call notifier methods after dispose (StateNotifier will throw when used after unmount)
    });

    test('setMode changes mode and sets timeRemaining accordingly', () {
      final notifier = TimerNotifier();
      notifier.state = notifier.state.copyWith(initPomodoro: 120, initShortBreak: 30, initLongBreak: 60);
      notifier.setMode(TimerMode.shortBreak);
      expect(notifier.state.mode, TimerMode.shortBreak);
      expect(notifier.state.timeRemaining, 30);
      notifier.setMode(TimerMode.longBreak);
      expect(notifier.state.timeRemaining, 60);
    });
  });
}
