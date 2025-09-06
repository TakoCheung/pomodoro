import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_pomodoro_app/main.dart' as app;
import 'package:flutter_pomodoro_app/state/deeplink_handler.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end: tap notification opens scripture overlay', (tester) async {
    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: app.MyApp()),
      ),
    );
    await tester.pumpAndSettle();

    // Simulate a playing alarm/banner, then simulate notification tap deep-link.
    container.read(alarmBannerVisibleProvider.notifier).state = true;
    DeepLinkDispatcher.notify(const {'action': 'open_timer'});
    await tester.pumpAndSettle();

    // Alarm banner should be dismissed and overlay flag set to true.
    expect(container.read(alarmBannerVisibleProvider), isFalse);
    expect(container.read(scriptureOverlayVisibleProvider), isTrue);

    await binding.takeScreenshot('artifacts/ios/_flow.png');
  });
}
