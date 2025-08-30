import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Settings apply logic updates TimerNotifier when called',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(timerProvider.notifier);
    final localNotifier = container.read(localSettingsProvider.notifier);

    // Simulate user changing settings via the local settings notifier
    localNotifier.updateFont('SpaceMono');
    localNotifier.updateColor(const Color(0xFF00FF00));
    localNotifier.updateTime(TimerMode.pomodoro, 10);

    // Simulate pressing Apply which calls timerNotifier.updateSettings(localSettings)
    notifier.updateSettings(localNotifier.state);

    expect(notifier.state.fontFamily, equals(localNotifier.state.fontFamily));
    expect(notifier.state.color, equals(localNotifier.state.color));
    expect(
        notifier.state.initPomodoro, equals(localNotifier.state.initPomodoro));
  });
}
