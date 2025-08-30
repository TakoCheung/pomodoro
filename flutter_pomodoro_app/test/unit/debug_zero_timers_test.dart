import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';

void main() {
  test('LocalSettings.updateDebugMode(true) zero minutes maps to 1 second per timer', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(localSettingsProvider.notifier);
    notifier.updateDebugMode(true);

    final s = container.read(localSettingsProvider);
    expect(s.debugMode, isTrue);
  // updateDebugMode(true) itself only toggles debug; minutes stay as previous until updated.
  // When user sets 0 minutes under debug, it maps to 1 second via updateTime.
  notifier.updateTime(TimerMode.pomodoro, 0);
  notifier.updateTime(TimerMode.shortBreak, 0);
  notifier.updateTime(TimerMode.longBreak, 0);
  final s2 = container.read(localSettingsProvider);
  expect(s2.initPomodoro, 1);
  expect(s2.initShortBreak, 1);
  expect(s2.initLongBreak, 1);
  });

  test('TimerNotifier.updateSettings with debug 0 minutes results in 1 second remaining', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timer = container.read(timerProvider.notifier);
    final settingsNotifier = container.read(localSettingsProvider.notifier);

  // Enable debug and set all to zero minutes -> 1 second each
    settingsNotifier.updateDebugMode(true);
  settingsNotifier.updateTime(TimerMode.pomodoro, 0);
  settingsNotifier.updateTime(TimerMode.shortBreak, 0);
  settingsNotifier.updateTime(TimerMode.longBreak, 0);
    final settings = container.read(localSettingsProvider);

    // Apply to timer
    timer.updateSettings(settings);
    final timerState = container.read(timerProvider);
  expect(timerState.initPomodoro, 1);
  expect(timerState.initShortBreak, 1);
  expect(timerState.initLongBreak, 1);
  // Current mode is pomodoro by default, so timeRemaining should be 1
  expect(timerState.timeRemaining, 1);

    // Switching mode should also reflect zero
    timer.setMode(TimerMode.shortBreak);
    final afterSwitch = container.read(timerProvider);
  expect(afterSwitch.timeRemaining, 1);
  });
}
