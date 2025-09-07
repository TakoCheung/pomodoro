import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';

void main() {
  testWidgets('Foreground completion shows scripture overlay, no system notif', (tester) async {
    final container = ProviderContainer(overrides: [
      isAppForegroundProvider.overrideWith((ref) => true),
    ]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: PomodoroTimerScreen()),
      ),
    );
    await tester.pump();

    // Simulate completion results: shown scripture + overlay visible
    container.read(shownScriptureProvider.notifier).state =
        Passage(reference: 'Genesis 1:1', text: 'In the beginning...');
    container.read(scriptureOverlayVisibleProvider.notifier).state = true;
    await tester.pump();

    // Foreground path shows scripture overlay (banner is only on notification tap)
    expect(find.byKey(const Key('scripture_reference')), findsOneWidget);
    // Debug key that indicates a system notif was posted should not exist in foreground-only path
    expect(find.byKey(const Key('notification_alarm')), findsNothing);
  });
}

// No inline repo needed; this widget test focuses on UI reaction to providers.
