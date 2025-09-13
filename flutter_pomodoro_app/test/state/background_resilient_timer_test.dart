import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/clock_provider.dart';
import 'package:flutter_pomodoro_app/state/active_timer_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_scheduler_provider.dart';
import 'package:flutter_pomodoro_app/services/alarm_scheduler.dart';

class _FakeAlarm implements AlarmScheduler {
  int scheduleCalls = 0;
  int cancelCalls = 0;
  DateTime? lastEnd;
  String? lastId;
  @override
  Future<void> cancel({required String timerId}) async {
    cancelCalls++;
    lastId = timerId;
  }

  @override
  Future<void> scheduleExact(
      {required String timerId, required DateTime endUtc, String? soundId}) async {
    scheduleCalls++;
    lastId = timerId;
    lastEnd = endUtc;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  test('Scheduling on start persists endUtc and sets exact trigger', () async {
    final fakeAlarm = _FakeAlarm();
    final container = ProviderContainer(overrides: [
      clockProvider.overrideWithValue(() => DateTime.utc(2025, 9, 5, 12, 0, 0)),
      alarmSchedulerProvider.overrideWithValue(fakeAlarm),
    ]);
    final n = container.read(timerProvider.notifier);
    n.setForTest(timeRemaining: 1500, isRunning: false, mode: TimerMode.pomodoro);
    n.toggleTimer();
    await Future<void>.value();
    final at = container.read(activeTimerProvider);
    expect(at, isNotNull);
    expect(at!.endUtc, DateTime.utc(2025, 9, 5, 12, 25, 0));
    expect(fakeAlarm.scheduleCalls, 1);
  });

  test('Idempotent rescheduling after process restart', () async {
    final fakeAlarm = _FakeAlarm();
    final container = ProviderContainer(overrides: [
      clockProvider.overrideWithValue(() => DateTime.utc(2025, 9, 5, 11, 0, 0)),
      alarmSchedulerProvider.overrideWithValue(fakeAlarm),
    ]);
    // Seed an active timer in prefs via notifier
    await container.read(activeTimerProvider.notifier).save(ActiveTimer(
          timerId: 'active',
          startUtc: DateTime.utc(2025, 9, 5, 11, 0, 0),
          endUtc: DateTime.utc(2025, 9, 5, 12, 0, 0),
          label: 'pomodoro',
        ));
    final n = container.read(timerProvider.notifier);
    await n.resyncAndProcessOverdue();
    expect(fakeAlarm.cancelCalls, 1);
    expect(fakeAlarm.scheduleCalls, 1);
  });

  test('Overdue detection on cold start', () async {
    final fakeAlarm = _FakeAlarm();
    final container = ProviderContainer(overrides: [
      clockProvider.overrideWithValue(() => DateTime.utc(2025, 9, 5, 12, 0, 1)),
      alarmSchedulerProvider.overrideWithValue(fakeAlarm),
    ]);
    await container.read(activeTimerProvider.notifier).save(ActiveTimer(
          timerId: 'active',
          startUtc: DateTime.utc(2025, 9, 5, 11, 35, 0),
          endUtc: DateTime.utc(2025, 9, 5, 12, 0, 0),
          label: 'pomodoro',
        ));
    final n = container.read(timerProvider.notifier);
    await n.resyncAndProcessOverdue();
    // Completed -> cleared, no reschedule
    expect(container.read(activeTimerProvider), isNull);
    expect(fakeAlarm.scheduleCalls, 0);
  });

  test('Cancel updates schedules and clears persisted timer', () async {
    final fakeAlarm = _FakeAlarm();
    final container = ProviderContainer(overrides: [
      clockProvider.overrideWithValue(() => DateTime.utc(2025, 9, 5, 12, 0, 0)),
      alarmSchedulerProvider.overrideWithValue(fakeAlarm),
    ]);
    final n = container.read(timerProvider.notifier);
    n.setForTest(timeRemaining: 60, isRunning: false, mode: TimerMode.pomodoro);
    n.toggleTimer();
    await Future<void>.value();
    n.pauseTimer();
    await Future<void>.value();
    expect(container.read(activeTimerProvider), isNull);
    expect(fakeAlarm.cancelCalls, greaterThanOrEqualTo(1));
  });
}
