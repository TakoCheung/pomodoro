import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('Live settings apply immediately without changing time', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final t = c.read(timerProvider.notifier);
    final before = c.read(timerProvider);
    // Change live settings only
    final live = LocalSettings(
      initPomodoro: before.initPomodoro,
      initShortBreak: before.initShortBreak,
      initLongBreak: before.initLongBreak,
      fontFamily: 'Inter',
      color: Colors.blue,
    );
    t.applyLiveSettings(live);
    final after = c.read(timerProvider);
    expect(after.fontFamily, 'Inter');
    expect(after.color, Colors.blue);
    expect(after.timeRemaining, before.timeRemaining);
  });

  test('Session-scoped changes are staged and activate next session', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final t = c.read(timerProvider.notifier);
    // Running session with 25 min
    t.setForTest(timeRemaining: TimerDefaults.pomodoroDefault, isRunning: true);
    // Stage new durations via LocalSettings
    final local = c.read(localSettingsProvider.notifier);
    local.updateTime(TimerMode.pomodoro, 30);

    // Current session unchanged
    final st = c.read(timerProvider);
    expect(st.timeRemaining, TimerDefaults.pomodoroDefault);

    // Next session boundary pulls new durations
    t.setMode(TimerMode.shortBreak);
    t.setMode(TimerMode.pomodoro);
    final st2 = c.read(timerProvider);
    expect(st2.timeRemaining, 30 * 60);
  });
}
