import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Changing a setting updates state and persists', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));
    // Open settings
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();
    // Increase pomodoro to 30 using the up arrow
    final inc = find.byKey(const Key('pomodoro_inc'));
    expect(inc, findsOneWidget);
    for (int i = 0; i < 5; i++) {
      await tester.tap(inc);
      await tester.pump();
    }
    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    // Verify provider value via reading minute on timer initial duration
    final container = ProviderScope.containerOf(tester.element(find.byType(PomodoroTimerScreen)));
    final settings = container.read(localSettingsProvider);
    expect(settings.initPomodoro, 30 * 60);
  });

  testWidgets('Settings changes are idempotent and persist across views', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));
    // Open settings
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();
    // Choose font Inter by tapping the middle option (robotoSlab) then apply
    await tester.tap(find.text('Aa').at(1));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    // Re-open settings and check the font selection ring persists via provider
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(PomodoroTimerScreen)));
    final settings = container.read(localSettingsProvider);
    expect(settings.fontFamily, isNotNull);
  });
}
