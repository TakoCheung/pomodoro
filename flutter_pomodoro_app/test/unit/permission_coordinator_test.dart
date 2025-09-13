import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/state/permission_coordinator.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';

class _FakeScheduler implements NotificationScheduler {
  bool requested = false;
  bool granted = true;
  @override
  Future<void> ensureInitialized() async {}
  @override
  Future<bool> requestPermission({bool provisional = false}) async {
    requested = true;
    return granted;
  }

  @override
  Future<void> show(
      {required String channelId,
      required String title,
      required String body,
      required Map<String, dynamic> payload,
      String? soundId}) async {}

  @override
  Future<void> createAndroidChannel(
      {required String id,
      required String name,
      required String description,
      int importance = 4}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('First launch sets flag and notDetermined state shows rationale', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(_FakeScheduler()),
      platformSnapshotProvider
          .overrideWithValue(const PlatformSnapshot(platform: TargetPlatform.iOS)),
    ]);
    final coord = container.read(permissionCoordinatorProvider.notifier);
    await coord.initialize();
    expect(container.read(notifRationaleVisibleProvider), isTrue);
  });

  test('Accept rationale caches authorized', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeScheduler()..granted = true;
    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(fake),
      platformSnapshotProvider
          .overrideWithValue(const PlatformSnapshot(platform: TargetPlatform.iOS)),
    ]);
    final coord = container.read(permissionCoordinatorProvider.notifier);
    await coord.initialize();
    await coord.requestPermission(provisional: true);
    expect(container.read(permissionCoordinatorProvider), NotifAuthStatus.provisional);
    expect(container.read(notifRationaleVisibleProvider), isFalse);
  });

  test('Defer increments counter and does not request OS', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeScheduler();
    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(fake),
      platformSnapshotProvider
          .overrideWithValue(const PlatformSnapshot(platform: TargetPlatform.iOS)),
    ]);
    final coord = container.read(permissionCoordinatorProvider.notifier);
    await coord.initialize();
    await coord.deferPrompt();
    expect(fake.requested, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('notif_prompt_deferred_count'), 1);
  });

  test('Android pre-13 skips runtime request and creates channel', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeScheduler();
    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(fake),
      platformSnapshotProvider.overrideWithValue(
          const PlatformSnapshot(platform: TargetPlatform.android, androidSdkInt: 31)),
    ]);
    final coord = container.read(permissionCoordinatorProvider.notifier);
    await coord.requestPermission();
    expect(container.read(permissionCoordinatorProvider), NotifAuthStatus.authorized);
  });

  test('Respect permanentlyDenied does not re-prompt', () async {
    SharedPreferences.setMockInitialValues({'notif_auth_status': 'permanentlyDenied'});
    final fake = _FakeScheduler();
    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(fake),
      platformSnapshotProvider.overrideWithValue(
          const PlatformSnapshot(platform: TargetPlatform.android, androidSdkInt: 33)),
    ]);
    final coord = container.read(permissionCoordinatorProvider.notifier);
    await coord.initialize();
    await coord.requestPermission();
    expect(fake.requested, isFalse);
    expect(container.read(permissionCoordinatorProvider), NotifAuthStatus.permanentlyDenied);
  });
}
