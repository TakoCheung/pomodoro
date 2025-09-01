import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NoopNotificationScheduler();
});

class NotificationChannel {
  static const id = 'pomodoro_notifications';
  static const name = 'Pomodoro';
  static const description = 'Timer completion and scripture';
}

final _authStateProvider = StateProvider<bool?>((_) => null);
final _channelCreatedProvider = StateProvider<bool>((_) => false);

Future<bool> ensureNotificationPermissionOnce(Ref ref, NotificationScheduler sched,
    {bool provisional = false}) async {
  final cached = ref.read(_authStateProvider);
  if (cached != null) return cached;
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
  ref.read(_channelCreatedProvider.notifier).state = true;
}
