import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';

class _FakeScheduler implements NotificationScheduler {
  bool requested = false;
  bool shown = false;
  @override
  Future<void> createAndroidChannel(
      {required String id,
      required String name,
      required String description,
      int importance = 4}) async {}
  @override
  Future<void> ensureInitialized() async {}
  @override
  Future<bool> requestPermission({bool provisional = false}) async {
    requested = true;
    return true;
  }

  @override
  Future<void> show(
      {required String channelId,
      required String title,
      required String body,
      required Map<String, dynamic> payload,
      String? soundId}) async {
    shown = true;
  }

  @override
  Future<void> processPendingTapLaunch() async {}
}

class _FakeService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return Passage(reference: 'John 3:16', text: 'For God so loved the world ...');
  }
}

void main() {
  test('Respect user notification preference: off means no schedule/prompt', () async {
    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(_FakeScheduler()),
      scriptureRepositoryProvider
          .overrideWith((ref) => ScriptureRepository(service: _FakeService())),
    ]);
    addTearDown(container.dispose);
    // Turn notifications off
    container.read(localSettingsProvider.notifier).updateNotificationsEnabled(false);
    // Simulate background
    container.read(isAppForegroundProvider.notifier).state = false;
    final notifier = container.read(timerProvider.notifier);
    // trigger complete
    notifier.triggerComplete();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final fake = container.read(notificationSchedulerProvider) as _FakeScheduler;
    expect(fake.requested, isFalse);
    expect(fake.shown, isFalse);
  });

  test('Foreground completion shows banner/audio instead of a system notification', () async {
    final fake = _FakeScheduler();
    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(fake),
      scriptureRepositoryProvider
          .overrideWith((ref) => ScriptureRepository(service: _FakeService())),
    ]);
    addTearDown(container.dispose);
    container.read(localSettingsProvider.notifier).updateNotificationsEnabled(true);
    container.read(isAppForegroundProvider.notifier).state = true;
    final notifier = container.read(timerProvider.notifier);
    notifier.triggerComplete();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(container.read(alarmBannerVisibleProvider), isTrue);
    expect(fake.shown, isFalse);
  });
}
