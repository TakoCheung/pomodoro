import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

abstract class AlarmScheduler {
  Future<void> scheduleExact({required String timerId, required DateTime endUtc, String? soundId});
  Future<void> cancel({required String timerId});
}

class NoopAlarmScheduler implements AlarmScheduler {
  @override
  Future<void> cancel({required String timerId}) async {}

  @override
  Future<void> scheduleExact(
      {required String timerId, required DateTime endUtc, String? soundId}) async {}
}

// FlutterLocalNotifications-backed scheduler for exact timer alarms.
// Note: This uses zoned scheduling for reliability; tests keep using NoopAlarmScheduler.

class FlutterLocalNotificationsAlarmScheduler implements AlarmScheduler {
  final FlutterLocalNotificationsPlugin _plugin;
  FlutterLocalNotificationsAlarmScheduler(this._plugin) {
    // Minimal initialization to allow scheduling without a separate init path.
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Do not auto-request iOS permissions on init; we gate the OS sheet behind the in-app banner.
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    _plugin.initialize(initSettings);
    // Ensure timezone database is initialized; set local to UTC to avoid missing tz.local.
    try {
      tzdata.initializeTimeZones();
    } catch (_) {}
    try {
      tz.setLocalLocation(tz.UTC);
    } catch (_) {}
  }

  @override
  Future<void> scheduleExact(
      {required String timerId, required DateTime endUtc, String? soundId}) async {
    // Convert UTC end time to tz.TZDateTime using UTC to avoid requiring tz.local init.
    final tzEnd = tz.TZDateTime.from(endUtc, tz.UTC);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'timer_alarm',
        'Timer Alarm',
        channelDescription: 'Timer completion alarm notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: soundId != null ? RawResourceAndroidNotificationSound(soundId) : null,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      timerId.hashCode,
      'Pomodoro complete',
      'Tap to view your verse',
      tzEnd,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      payload: '{"action":"open_timer"}',
    );
  }

  @override
  Future<void> cancel({required String timerId}) async {
    await _plugin.cancel(timerId.hashCode);
  }
}
