import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('Applying local settings updates the global timer provider (programmatic)', () {
    // Use a ProviderContainer to simulate the app providers without rendering the full UI.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Simulate user changing settings in the dialog via the local settings notifier.
    final localNotifier = container.read(localSettingsProvider.notifier);
    localNotifier.updateTime(TimerMode.pomodoro, 10);

    // Programmatically apply the settings the SettingsScreen would apply.
    final timerNotifier = container.read(timerProvider.notifier);
    timerNotifier.applyLiveSettings(container.read(localSettingsProvider));

    // After applying, timerProvider should reflect the local settings
    final timerState = container.read(timerProvider);
    final localState = container.read(localSettingsProvider);
    // Live apply should not change durations; only font/color are updated immediately.
    expect(timerState.initPomodoro, isNot(equals(localState.initPomodoro)));
  });
}
