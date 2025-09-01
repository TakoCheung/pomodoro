import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';

class FlutterLocalNotificationsScheduler implements NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel? _channel;

  @override
  Future<void> ensureInitialized() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings, onDidReceiveNotificationResponse: (response) {
      // Deep-link handling would be wired here by parsing response.payload
      if (kDebugMode) debugPrint('Notification tapped: ${response.payload}');
    });
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
    );
    _channel = android;
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(android);
  }

  @override
  Future<bool> requestPermission({bool provisional = false}) async {
    // iOS: request alert/badge/sound permissions.
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final settings = await ios.requestPermissions(alert: true, badge: true, sound: true);
      return settings ?? true;
    }
    // Android: many devices grant by default; for Android 13+, apps should add POST_NOTIFICATIONS permission.
    // The plugin version in use may not expose a runtime request; return true here.
    return true;
  }

  @override
  Future<void> show(
      {required String channelId,
      required String title,
      required String body,
      required Map<String, dynamic> payload}) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _channel?.name ?? 'Pomodoro',
      channelDescription: _channel?.description,
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(0, title, body, details, payload: jsonEncode(payload));
  }
}
