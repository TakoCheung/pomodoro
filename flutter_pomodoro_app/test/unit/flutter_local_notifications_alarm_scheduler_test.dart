import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro_app/services/alarm_scheduler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    // Fallbacks for mocktail any() of complex types
    registerFallbackValue(tz.TZDateTime.now(tz.UTC));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(const AndroidInitializationSettings('@mipmap/ic_launcher'));
    registerFallbackValue(const DarwinInitializationSettings());
    registerFallbackValue(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
    registerFallbackValue(UILocalNotificationDateInterpretation.absoluteTime);
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
  });

  test('scheduleExact delegates to zonedSchedule with expected id and payload', () async {
    final plugin = _MockPlugin();

    when(() => plugin.initialize(any(),
            onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse')))
        .thenAnswer((_) async => true);
    when(() => plugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          uiLocalNotificationDateInterpretation:
              any(named: 'uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    final scheduler = FlutterLocalNotificationsAlarmScheduler(plugin);

    final timerId = 'abc123';
    final endUtc = DateTime.utc(2025, 10, 21, 12, 0, 0);

    await scheduler.scheduleExact(timerId: timerId, endUtc: endUtc, soundId: 'bell');

    verify(() => plugin.zonedSchedule(
          timerId.hashCode,
          any(),
          any(),
          any(that: isA<tz.TZDateTime>()),
          any(that: isA<NotificationDetails>()),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: null,
          payload: '{"action":"open_timer"}',
        )).called(1);
  });

  test('cancel delegates to plugin.cancel with hashCode of timerId', () async {
    final plugin = _MockPlugin();
    when(() => plugin.initialize(any(),
            onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse')))
        .thenAnswer((_) async => true);
    when(() => plugin.cancel(any())).thenAnswer((_) async => true);

    final scheduler = FlutterLocalNotificationsAlarmScheduler(plugin);

    const timerId = 'cancel-me';
    await scheduler.cancel(timerId: timerId);

    verify(() => plugin.cancel(timerId.hashCode)).called(1);
  });
}
