import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pomodoro_app/main.dart' as app;
import 'package:flutter_pomodoro_app/state/deeplink_handler.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/utils/sounds.dart';

class _FakeScheduler implements NotificationScheduler {
  String? lastSoundId;
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
    lastSoundId = soundId;
  }

  @override
  Future<void> processPendingTapLaunch() async {}
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end: tap notification shows scripture banner', (tester) async {
    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: app.MyApp()),
      ),
    );
    await tester.pumpAndSettle();

    // Simulate a notification tap deep-link.
    DeepLinkDispatcher.notify(const {'action': 'open_timer'});
    await tester.pumpAndSettle();

    // Alarm banner should be visible; overlay remains hidden on deep-link path.
    expect(container.read(alarmBannerVisibleProvider), isTrue);
    expect(container.read(scriptureOverlayVisibleProvider), isFalse);
    expect(find.byKey(const Key('alarm_banner')), findsOneWidget);

    await binding.takeScreenshot('artifacts/ios/_flow.png');
  });

  testWidgets('Background completion posts notification with mapped sound and deep-links',
      (tester) async {
    final fake = _FakeScheduler();
    final container = ProviderContainer(overrides: [
      isAppForegroundProvider.overrideWith((ref) => false),
      notificationSchedulerProvider.overrideWithValue(fake),
    ]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: app.MyApp()),
      ),
    );
    await tester.pumpAndSettle();

    // Ensure a specific sound is selected
    container.read(localSettingsProvider.notifier).updateSoundId('beep');

    // Simulate completion while backgrounded
    container.read(timerProvider.notifier).triggerComplete();
    await tester.pumpAndSettle();

    // Our debug key appears if a system notification was logically posted
    expect(find.byKey(const Key('notification_alarm')), findsOneWidget);
    // Sound id should be mapped via platformSoundBase
    expect(fake.lastSoundId, platformSoundBase('beep'));

    // Simulate user tapping the system notification
    DeepLinkDispatcher.notify(const {'action': 'open_timer'});
    await tester.pumpAndSettle();

    // Banner is visible now; overlay remains hidden until explicitly shown in foreground.
    expect(container.read(alarmBannerVisibleProvider), isTrue);
    expect(container.read(scriptureOverlayVisibleProvider), isFalse);
    expect(find.byKey(const Key('alarm_banner')), findsOneWidget);

    await binding.takeScreenshot('artifacts/ios/_flow.png');
  });
}
