import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';

final _refCaptureProvider = Provider<Ref>((ref) => ref);

class _SpyScheduler implements NotificationScheduler {
  int channelCreates = 0;
  int permissionRequests = 0;
  @override
  Future<void> createAndroidChannel(
      {required String id,
      required String name,
      required String description,
      int importance = 4}) async {
    channelCreates++;
  }

  @override
  Future<void> ensureInitialized() async {}
  @override
  Future<bool> requestPermission({bool provisional = false}) async {
    permissionRequests++;
    return true;
  }

  @override
  Future<void> show(
      {required String channelId,
      required String title,
      required String body,
      required Map<String, dynamic> payload}) async {}
}

void main() {
  test('Android notification channel is created once', () async {
    final spy = _SpyScheduler();
    final c = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(spy),
    ]);
    addTearDown(c.dispose);
    final ref = c.read(_refCaptureProvider);
    await ensureChannelCreatedOnce(ref, spy);
    await ensureChannelCreatedOnce(ref, spy);
    expect(spy.channelCreates, 1);
  });

  test('iOS authorization state is cached to avoid repeated prompts', () async {
    final spy = _SpyScheduler();
    final c = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(spy),
    ]);
    addTearDown(c.dispose);
    final ref = c.read(_refCaptureProvider);
    final first = await ensureNotificationPermissionOnce(ref, spy, provisional: true);
    final second = await ensureNotificationPermissionOnce(ref, spy, provisional: true);
    expect(first, isTrue);
    expect(second, isTrue);
    expect(spy.permissionRequests, 1);
  });
}
