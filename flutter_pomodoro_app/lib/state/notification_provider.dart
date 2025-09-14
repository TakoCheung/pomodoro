import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';

// Default is Noop for tests; main.dart overrides to real local notifications.
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NoopNotificationScheduler();
});

class NotificationChannel {
  static const id = 'pomodoro_notifications';
  static const name = 'Pomodoro';
  static const description = 'Timer completion and scripture';
  // High-importance channel for exact timer alarms
  static const alarmId = 'timer_alarm';
  static const alarmName = 'Timer Alarm';
  static const alarmDescription = 'Timer completion alarm notifications';
}

final _authStateProvider = StateProvider<bool?>((_) => null);
final _channelCreatedProvider = StateProvider<bool>((_) => false);

/// Test/diagnostic marker: set to true when a system notification is posted via
/// NotificationScheduler.show. Integration tests can assert Key('notification_alarm')
/// is present without requiring real platform I/O.
final lastNotificationPostedProvider = StateProvider<bool>((_) => false);

Future<bool> ensureNotificationPermissionOnce(
  Ref ref,
  NotificationScheduler sched, {
  bool provisional = false,
}) async {
  final cached = ref.read(_authStateProvider);
  // If previously granted, short-circuit.
  if (cached == true) return true;
  // If previously denied and caller only wants provisional behavior, honor the cached denial
  // to avoid spamming the user with OS prompts.
  if (cached == false && provisional) return false;
  // Otherwise (no cache, or denied but now explicitly asking for full permission),
  // attempt to request again and update the cache with the latest answer.
  final granted = await sched.requestPermission(provisional: provisional);
  ref.read(_authStateProvider.notifier).state = granted;
  return granted;
}

Future<void> ensureChannelCreatedOnce(Ref ref, NotificationScheduler sched) async {
  final created = ref.read(_channelCreatedProvider);
  if (created) return;
  await sched.ensureInitialized();
  await sched.createAndroidChannel(
    id: NotificationChannel.id,
    name: NotificationChannel.name,
    description: NotificationChannel.description,
    importance: 4,
  );
  await sched.createAndroidChannel(
    id: NotificationChannel.alarmId,
    name: NotificationChannel.alarmName,
    description: NotificationChannel.alarmDescription,
    importance: 4,
  );
  ref.read(_channelCreatedProvider.notifier).state = true;
}
