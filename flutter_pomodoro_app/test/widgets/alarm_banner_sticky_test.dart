import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';

void main() {
  testWidgets('Alarm banner remains visible until user dismiss', (tester) async {
    // Start with app in foreground and auto permission prompt enabled
    final container = ProviderContainer(overrides: [
      isAppForegroundProvider.overrideWith((ref) => true),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PomodoroTimerScreen()),
    ));
    await tester.pump();

    // Show banner directly
    container.read(alarmBannerVisibleProvider.notifier).state = true;
    await tester.pump();

    expect(find.byKey(const Key('alarm_banner')), findsOneWidget);
    // Ensure rationale is not visible while banner is shown
    expect(find.byKey(const Key('notif_rationale_sheet')), findsNothing);

    // Pump more frames; banner should still be visible
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const Key('alarm_banner')), findsOneWidget);

    // Dismiss explicitly
    await tester.tap(find.byKey(const Key('alarm_dismiss')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('alarm_banner')), findsNothing);
  });
}
