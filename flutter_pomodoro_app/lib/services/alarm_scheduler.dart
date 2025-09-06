abstract class AlarmScheduler {
  Future<void> scheduleExact({required String timerId, required DateTime endUtc});
  Future<void> cancel({required String timerId});
}

class NoopAlarmScheduler implements AlarmScheduler {
  @override
  Future<void> cancel({required String timerId}) async {}

  @override
  Future<void> scheduleExact({required String timerId, required DateTime endUtc}) async {}
}
