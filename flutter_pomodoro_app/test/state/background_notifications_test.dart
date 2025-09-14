import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/utils/sounds.dart';

class _FakeScheduler implements NotificationScheduler {
  bool requested = false;
  bool shown = false;
  String? lastSoundId;
  String? lastChannelId;
  String? lastTitle;
  String? lastBody;
  Map<String, dynamic>? lastPayload;
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
    lastSoundId = soundId;
    lastChannelId = channelId;
    lastTitle = title;
    lastBody = body;
    lastPayload = payload;
  }
}

class _FakeService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return Passage(reference: 'Ps 23:1', text: 'The Lord is my shepherd; I shall not want.');
  }
}

void main() {
  test('Background completion posts system notification with mapped sound id', () async {
    final fake = _FakeScheduler();
    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(fake),
      scriptureRepositoryProvider
          .overrideWith((ref) => ScriptureRepository(service: _FakeService())),
    ]);
    addTearDown(container.dispose);
    // Enable notifications and set a specific sound id
    container.read(localSettingsProvider.notifier).updateNotificationsEnabled(true);
    container.read(localSettingsProvider.notifier).updateSoundId('beep');
    // Simulate background
    container.read(isAppForegroundProvider.notifier).state = false;
    // Trigger complete
    container.read(timerProvider.notifier).triggerComplete();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(fake.requested, isTrue);
    expect(fake.shown, isTrue);
    expect(fake.lastChannelId, NotificationChannel.alarmId);
    // Should map via platformSoundBase
    expect(fake.lastSoundId, platformSoundBase('beep'));
    // Marker provider should be set
    expect(container.read(lastNotificationPostedProvider), isTrue);
  });

  test('Foreground completion does not post system notification', () async {
    final fake = _FakeScheduler();
    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(fake),
      scriptureRepositoryProvider
          .overrideWith((ref) => ScriptureRepository(service: _FakeService())),
    ]);
    addTearDown(container.dispose);
    container.read(localSettingsProvider.notifier).updateNotificationsEnabled(true);
    container.read(isAppForegroundProvider.notifier).state = true;
    container.read(timerProvider.notifier).triggerComplete();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(fake.shown, isFalse);
  });
}
