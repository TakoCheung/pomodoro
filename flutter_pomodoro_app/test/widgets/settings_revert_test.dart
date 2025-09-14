import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Closing via close or scrim reverts staged changes', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));

    // Open settings
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('SettingsScreen')), findsOneWidget);

    // Toggle haptics off (staged only)
    final hToggle = find.byKey(const Key('settings_haptics_toggle'));
    await tester.tap(hToggle);
    await tester.pump();
    expect(find.byKey(const Key('settings_dirty_badge')), findsOneWidget);

    // Close via X button -> should revert and dismiss
    await tester.tap(find.byKey(const Key('settings_close')));
    await tester.pumpAndSettle();

    // Reopen and ensure no dirty badge and toggles reflect committed
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings_dirty_badge')), findsNothing);

    // Tap on the scrim outside the dialog bounds to close (and revert)
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('SettingsScreen')), findsNothing);
  });

  testWidgets('Apply button enables on dirty and summary shows committed', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();

    final summaryBefore = tester.widget<Text>(
      find.byKey(const Key('settings_commit_state_summary')),
    );
    // Flip sound toggle -> staged only
    await tester.tap(find.byKey(const Key('settings_sound_toggle')));
    await tester.pump();
    // Apply should be enabled and dirty badge visible
    expect(find.byKey(const Key('settings_dirty_badge')), findsOneWidget);

    // Apply next session
    await tester.tap(find.byKey(const Key('apply_next_session_button')));
    await tester.pumpAndSettle();

    // Reopen and summary should reflect the committed change now
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();
    final summaryAfter = tester.widget<Text>(
      find.byKey(const Key('settings_commit_state_summary')),
    );
    expect(summaryAfter.data, isNot(equals(summaryBefore.data)));
    // No dirty state on freshly opened
    expect(find.byKey(const Key('settings_dirty_badge')), findsNothing);
  });
}
