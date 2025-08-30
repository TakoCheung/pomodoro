import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/timer_model.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';

void main() {
  test('getInitialDuration maps zero to 1 second per mode', () {
    final notifier = TimerNotifier();
    // Seed state with zeros
    notifier.updateSettings(
      LocalSettings(
        initPomodoro: 0,
        initShortBreak: 0,
        initLongBreak: 0,
        fontFamily: 'x',
        color: notifier.state.color,
      ),
    );
    expect(notifier.getInitialDuration(TimerMode.pomodoro), 1);
    expect(notifier.getInitialDuration(TimerMode.shortBreak), 1);
    expect(notifier.getInitialDuration(TimerMode.longBreak), 1);
  });

  test('decrementTimer completes from 1 to 0 without crashing (no ref)', () {
    final notifier = TimerNotifier();
    notifier.updateSettings(
      LocalSettings(
        initPomodoro: 1,
        initShortBreak: 1,
        initLongBreak: 1,
        fontFamily: 'x',
        color: notifier.state.color,
      ),
    );
    // Ensure mode is pomodoro with 1 second remaining
    notifier.setMode(TimerMode.pomodoro);
    expect(notifier.state.timeRemaining, 1);
    notifier.decrementTimer();
    expect(notifier.state.timeRemaining, 0);
  });
}
