import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';
import 'package:flutter_pomodoro_app/state/permission_coordinator.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';

void main() {
  testWidgets(
      'TaskBar coexists with scripture overlay and alarm banner; rationale hidden by banner',
      (tester) async {
    final container = ProviderContainer(overrides: [
      // Force overlay + banner visible.
      scriptureOverlayVisibleProvider.overrideWith((ref) => true),
      alarmBannerVisibleProvider.overrideWith((ref) => true),
      // Autostart + rationale request would normally show sheet but banner should suppress it.
      permissionAutostartProvider.overrideWith((ref) => true),
      notifRationaleVisibleProvider.overrideWith((ref) => true),
      // Provide scripture passage so overlay renders content.
      shownScriptureProvider
          .overrideWith((ref) => Passage(reference: 'Genesis 1:1', text: 'In the beginning')),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PomodoroTimerScreen()),
    ));
    await tester.pump();

    expect(find.byKey(const Key('task_bar')), findsOneWidget);
    expect(find.byKey(const Key('task_bar_settings')), findsOneWidget);
    expect(find.byKey(const Key('alarm_banner')), findsOneWidget);
    expect(find.byKey(const Key('notif_rationale_sheet')), findsNothing,
        reason: 'Banner suppresses rationale sheet');
    // Scripture overlay content appears above main stack content.
    expect(find.byKey(const Key('scripture_reference')), findsOneWidget);
  });

  testWidgets('TaskBar with rationale sheet (no banner) both visible', (tester) async {
    final container = ProviderContainer(overrides: [
      scriptureOverlayVisibleProvider.overrideWith((ref) => false),
      alarmBannerVisibleProvider.overrideWith((ref) => false),
      permissionAutostartProvider.overrideWith((ref) => true),
      notifRationaleVisibleProvider.overrideWith((ref) => true),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PomodoroTimerScreen()),
    ));
    await tester.pump();

    expect(find.byKey(const Key('task_bar')), findsOneWidget);
    expect(find.byKey(const Key('notif_rationale_sheet')), findsOneWidget);
  });
}
