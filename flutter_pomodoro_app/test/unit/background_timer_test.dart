import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/clock_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_scheduler_provider.dart';
import 'package:flutter_pomodoro_app/state/active_timer_provider.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';

import 'package:flutter_pomodoro_app/services/alarm_scheduler.dart';

class _FakeAlarmScheduler implements AlarmScheduler {
  DateTime? scheduledAt;
  String? scheduledId;
  String? canceledId;
  int scheduleCount = 0;
  int cancelCount = 0;
  @override
  Future<void> cancel({required String timerId}) async {
    canceledId = timerId;
    cancelCount++;
  }

  @override
  Future<void> scheduleExact(
      {required String timerId, required DateTime endUtc, String? soundId}) async {
    scheduledId = timerId;
    scheduledAt = endUtc.toUtc();
    scheduleCount++;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Scheduling on start persists endUtc and sets exact trigger', () async {
    final fakeAlarm = _FakeAlarmScheduler();
    final fixedNow = DateTime.utc(2025, 9, 5, 12, 0, 0);
    final container = ProviderContainer(overrides: [
      clockProvider.overrideWithValue(() => fixedNow),
      alarmSchedulerProvider.overrideWithValue(fakeAlarm),
    ]);

    final notifier = container.read(timerProvider.notifier);
    // Ensure mode is pomodoro default 25m
    notifier.setForTest(isRunning: false);
    notifier.toggleTimer();

    // Persisted state should exist with expected endUtc
    final at = container.read(activeTimerProvider);
    expect(at, isNotNull);
    expect(at!.endUtc, DateTime.utc(2025, 9, 5, 12, 25, 0));
    // Alarm scheduled once with same instant
    expect(fakeAlarm.scheduleCount, 1);
    expect(fakeAlarm.scheduledAt, DateTime.utc(2025, 9, 5, 12, 25, 0));
  });

  test('Idempotent (re)scheduling after process restart', () async {
    final fakeAlarm = _FakeAlarmScheduler();
    final now = DateTime.utc(2025, 9, 5, 11, 0, 0);
    final end = now.add(const Duration(minutes: 10));
    final container = ProviderContainer(overrides: [
      clockProvider.overrideWithValue(() => now),
      alarmSchedulerProvider.overrideWithValue(fakeAlarm),
    ]);
    // Seed active timer
    await container.read(activeTimerProvider.notifier).save(
          ActiveTimer(timerId: 'active', startUtc: now, endUtc: end, label: 'pomodoro'),
        );

    await container.read(timerProvider.notifier).resyncAndProcessOverdue();

    expect(fakeAlarm.cancelCount, 1);
    expect(fakeAlarm.scheduleCount, 1);
    expect(fakeAlarm.canceledId, 'active');
    expect(fakeAlarm.scheduledAt, end);
  });

  test('Overdue detection on cold start processes completion exactly once', () async {
    final fakeAlarm = _FakeAlarmScheduler();
    final end = DateTime.utc(2025, 9, 5, 12, 0, 0);
    final now = DateTime.utc(2025, 9, 5, 12, 0, 1);
    final container = ProviderContainer(overrides: [
      clockProvider.overrideWithValue(() => now),
      alarmSchedulerProvider.overrideWithValue(fakeAlarm),
      // App starts in foreground
      isAppForegroundProvider.overrideWith((ref) => true),
    ]);
    await container.read(activeTimerProvider.notifier).save(
          ActiveTimer(
              timerId: 'active',
              startUtc: end.subtract(const Duration(minutes: 25)),
              endUtc: end,
              label: 'pomodoro'),
        );

    await container.read(timerProvider.notifier).resyncAndProcessOverdue();
    // Alarm banner becomes visible in foreground on overdue completion
    expect(container.read(alarmBannerVisibleProvider), isTrue);
    // Second resync should be idempotent (still visible, no crash)
    await container.read(timerProvider.notifier).resyncAndProcessOverdue();
    expect(container.read(alarmBannerVisibleProvider), isTrue);
  });

  test('Cancel updates schedules and clears persisted activeTimer', () async {
    final fakeAlarm = _FakeAlarmScheduler();
    final now = DateTime.utc(2025, 9, 5, 12, 0, 0);
    final container = ProviderContainer(overrides: [
      clockProvider.overrideWithValue(() => now),
      alarmSchedulerProvider.overrideWithValue(fakeAlarm),
    ]);

    final notifier = container.read(timerProvider.notifier);
    notifier.toggleTimer(); // start
    expect(container.read(activeTimerProvider), isNotNull);

    notifier.pauseTimer();
    expect(fakeAlarm.cancelCount, 1);
    expect(container.read(activeTimerProvider), isNull);
  });

  group('Exact scheduling for various durations', () {
    final fixedNow = DateTime.utc(2025, 9, 5, 12, 0, 0);
    test('5m', () async {
      final fake = _FakeAlarmScheduler();
      final container = ProviderContainer(overrides: [
        clockProvider.overrideWithValue(() => fixedNow),
        alarmSchedulerProvider.overrideWithValue(fake),
      ]);
      final n = container.read(timerProvider.notifier);
      container.read(localSettingsProvider.notifier).updateTime(TimerMode.pomodoro, 5);
      n.setMode(TimerMode.pomodoro);
      n.toggleTimer();
      expect(fake.scheduledAt, fixedNow.add(const Duration(minutes: 5)));
    });
    test('30m', () async {
      final fake = _FakeAlarmScheduler();
      final container = ProviderContainer(overrides: [
        clockProvider.overrideWithValue(() => fixedNow),
        alarmSchedulerProvider.overrideWithValue(fake),
      ]);
      final n = container.read(timerProvider.notifier);
      container.read(localSettingsProvider.notifier).updateTime(TimerMode.pomodoro, 30);
      n.setMode(TimerMode.pomodoro);
      n.toggleTimer();
      expect(fake.scheduledAt, fixedNow.add(const Duration(minutes: 30)));
    });
    test('2h', () async {
      final fake = _FakeAlarmScheduler();
      final container = ProviderContainer(overrides: [
        clockProvider.overrideWithValue(() => fixedNow),
        alarmSchedulerProvider.overrideWithValue(fake),
      ]);
      final n = container.read(timerProvider.notifier);
      container.read(localSettingsProvider.notifier).updateTime(TimerMode.pomodoro, 120);
      n.setMode(TimerMode.pomodoro);
      n.toggleTimer();
      expect(fake.scheduledAt, fixedNow.add(const Duration(hours: 2)));
    });
    test('8h', () async {
      final fake = _FakeAlarmScheduler();
      final container = ProviderContainer(overrides: [
        clockProvider.overrideWithValue(() => fixedNow),
        alarmSchedulerProvider.overrideWithValue(fake),
      ]);
      final n = container.read(timerProvider.notifier);
      container.read(localSettingsProvider.notifier).updateTime(TimerMode.pomodoro, 480);
      n.setMode(TimerMode.pomodoro);
      n.toggleTimer();
      expect(fake.scheduledAt, fixedNow.add(const Duration(hours: 8)));
    });
    test('24h', () async {
      final fake = _FakeAlarmScheduler();
      final container = ProviderContainer(overrides: [
        clockProvider.overrideWithValue(() => fixedNow),
        alarmSchedulerProvider.overrideWithValue(fake),
      ]);
      final n = container.read(timerProvider.notifier);
      container.read(localSettingsProvider.notifier).updateTime(TimerMode.pomodoro, 1440);
      n.setMode(TimerMode.pomodoro);
      n.toggleTimer();
      expect(fake.scheduledAt, fixedNow.add(const Duration(hours: 24)));
    });
  });
}
