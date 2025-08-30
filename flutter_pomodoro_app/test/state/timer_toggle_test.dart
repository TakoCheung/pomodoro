import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';

void main() {
  test('toggleTimer flips running state and startTimer schedules', () {
    final notifier = TimerNotifier();

    expect(notifier.state.isRunning, isFalse);
    notifier.toggleTimer();
    // toggled to running
    expect(notifier.state.isRunning, isTrue);

    // simulate a single tick by calling decrementTimer
    final before = notifier.state.timeRemaining;
    notifier.decrementTimer();
    expect(notifier.state.timeRemaining, before - 1);

    notifier.pauseTimer();
    expect(notifier.state.isRunning, isFalse);

    notifier.dispose();
  });
}
