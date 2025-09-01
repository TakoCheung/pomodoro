import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_pomodoro_app/main.dart' as app;
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';

class _FakeScheduler implements NotificationScheduler {
  bool createdChannel = false;
  bool requested = false;
  bool shown = false;
  String? title;
  String? body;
  Map<String, dynamic>? payload;
  @override
  Future<void> createAndroidChannel(
      {required String id,
      required String name,
      required String description,
      int importance = 4}) async {
    createdChannel = true;
  }

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
      required Map<String, dynamic> payload}) async {
    shown = true;
    this.title = title;
    this.body = body;
    this.payload = payload;
  }
}

class _FakeService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return Passage(reference: 'John 3:16', text: 'For God so loved the world ...');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Background completion shows a notification with scripture', (tester) async {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    final fakeScheduler = _FakeScheduler();

    final container = ProviderContainer(overrides: [
      notificationSchedulerProvider.overrideWithValue(fakeScheduler),
      isAppForegroundProvider.overrideWithProvider(
        StateProvider<bool>((_) => false),
      ), // simulate background
      scriptureRepositoryProvider.overrideWithValue(
        ScriptureRepository(service: _FakeService()),
      ),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: app.MyApp()),
      ),
    );

    await tester.pumpAndSettle();

    // Trigger timer completion directly
    container.read(timerProvider.notifier).triggerComplete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(fakeScheduler.createdChannel, isTrue);
    expect(fakeScheduler.requested, isTrue);
    expect(fakeScheduler.shown, isTrue);
    expect(fakeScheduler.title, 'John 3:16');
    expect(fakeScheduler.body, isNotEmpty);
    expect(fakeScheduler.payload, isNotNull);
    expect(fakeScheduler.payload!['bibleId'], isNotNull);
    expect(fakeScheduler.payload!['passageId'], isNotNull);

    // Save a screenshot artifact
    await binding.takeScreenshot('artifacts/ios/notification_flow');
  });
}
