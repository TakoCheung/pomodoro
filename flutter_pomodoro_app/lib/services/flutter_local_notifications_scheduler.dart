import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/state/deeplink_handler.dart';

class FlutterLocalNotificationsScheduler implements NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel? _channel;

  @override
  Future<void> ensureInitialized() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Gate iOS OS sheet behind our own banner; don't auto-request on init.
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings, onDidReceiveNotificationResponse: (response) {
      // Route notification taps into app deep-link dispatcher.
      if (kDebugMode) debugPrint('Notification tapped: ${response.payload}');
      try {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          final map = jsonDecode(payload) as Map<String, dynamic>;
          DeepLinkDispatcher.notify(map);
        } else {
          DeepLinkDispatcher.notify(const {'action': 'open_timer'});
        }
      } catch (_) {
        // Fallback to opening timer screen if payload was malformed.
        DeepLinkDispatcher.notify(const {'action': 'open_timer'});
      }
    });
  }

  @override
  Future<void> processPendingTapLaunch() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      final resp = details?.notificationResponse;
      if (resp != null) {
        if (kDebugMode) debugPrint('Notification launch tap: ${resp.payload}');
        try {
          final payload = resp.payload;
          if (payload != null && payload.isNotEmpty) {
            final map = jsonDecode(payload) as Map<String, dynamic>;
            DeepLinkDispatcher.notify(map);
          } else {
            DeepLinkDispatcher.notify(const {'action': 'open_timer'});
          }
        } catch (_) {
          DeepLinkDispatcher.notify(const {'action': 'open_timer'});
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> createAndroidChannel(
      {required String id,
      required String name,
      required String description,
      int importance = 4}) async {
    final android = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(<int>[0, 200, 100, 200]),
    );
    _channel = android;
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(android);
  }

  @override
  Future<bool> requestPermission({bool provisional = false}) async {
    // iOS: request alert/badge/sound permissions; this shows the OS sheet.
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final settings = await ios.requestPermissions(alert: true, badge: true, sound: true);
      return settings ?? true;
    }
    // Android 13+ requires the POST_NOTIFICATIONS runtime permission. Request if available.
    final android =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final bool? granted = await android.requestNotificationsPermission();
      return granted ?? true;
    }
    return true;
  }

  @override
  Future<void> show(
      {required String channelId,
      required String title,
      required String body,
      required Map<String, dynamic> payload,
      String? soundId}) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _channel?.name ?? 'Pomodoro',
      channelDescription: _channel?.description,
      importance: Importance.max,
      priority: Priority.high,
      sound: soundId != null ? RawResourceAndroidNotificationSound(soundId) : null,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(<int>[0, 200, 100, 200]),
    );
    // On iOS, ensure a sound is presented. If custom sounds aren't bundled,
    // presentSound=true will use the default system sound.
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
      // Custom sound file (e.g., '<id>.caf') can be set when bundled.
      // sound: soundId != null ? '${soundId}.caf' : null,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(0, title, body, details, payload: jsonEncode(payload));
  }
}
