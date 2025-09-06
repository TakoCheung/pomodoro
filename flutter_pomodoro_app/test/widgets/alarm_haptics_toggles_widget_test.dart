import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Settings shows and toggles sound/haptics switches', (tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: Scaffold(body: Center(child: SettingsScreen())))));
    await tester.pumpAndSettle();

    final soundFinder = find.byKey(const Key('settings_sound_toggle'));
    final hapticsFinder = find.byKey(const Key('settings_haptics_toggle'));
    expect(soundFinder, findsOneWidget);
    expect(hapticsFinder, findsOneWidget);

    // Toggle both and verify state updated
    // Ensure visible in case of small surface and scrollable content
    await tester.ensureVisible(soundFinder);
    await tester.tap(soundFinder, warnIfMissed: false);
    await tester.pump();
    await tester.ensureVisible(hapticsFinder);
    await tester.tap(hapticsFinder, warnIfMissed: false);
    await tester.pump();

    // Read provider to confirm
    final settings = ProviderScope.containerOf(tester.element(find.byType(SettingsScreen)))
        .read(localSettingsProvider);
    // Because initial defaults are true, after taps they should be false.
    expect(settings.soundEnabled, isFalse);
    expect(settings.hapticsEnabled, isFalse);
  });
}
