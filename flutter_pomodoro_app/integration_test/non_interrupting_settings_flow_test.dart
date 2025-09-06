import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_pomodoro_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Staged workMinutes applies on next session without interrupting', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Start the timer to simulate running session
    final playPause = find.byKey(const Key('pauseRestart'));
    expect(playPause, findsOneWidget);
    await tester.tap(playPause);
    await tester.pump();

    // Open settings
    final settingsBtn = find.byKey(const Key('settingsButton'));
    expect(settingsBtn, findsOneWidget);
    await tester.tap(settingsBtn);
    await tester.pumpAndSettle();

    // Increase pomodoro (work) minutes from 25 to 30
    final inc = find.byKey(const Key('pomodoro_inc'));
    expect(inc, findsOneWidget);
    for (int i = 0; i < 5; i++) {
      await tester.tap(inc);
      await tester.pump();
    }

    // Apply next session
    await tester.tap(find.byKey(const Key('apply_next_session_button')));
    await tester.pumpAndSettle();

    // Ensure timer remains running and remaining time keeps 25-minute target for this session
    final timeTextFinder = find.byKey(const Key('timer_text'));
    expect(timeTextFinder, findsOneWidget);
    final txt = tester.widget<Text>(timeTextFinder).data ?? '';
    final mm = int.tryParse(txt.split(':').first) ?? 0;
    // Current session should not jump to 30; allow elapsed seconds to reduce minutes slightly.
    expect(mm <= 25, isTrue, reason: 'current session should remain at or below 25 minutes');
    expect(mm, isNot(30), reason: 'current session should not be 30 minutes yet');

    // Move to short break and back to pomodoro to start a new session
    final shortBreakTab = find.byKey(const Key('mode_shortBreak'));
    expect(shortBreakTab, findsOneWidget);
    await tester.tap(shortBreakTab);
    await tester.pumpAndSettle();
    final pomoTab = find.byKey(const Key('mode_pomodoro'));
    expect(pomoTab, findsOneWidget);
    await tester.tap(pomoTab);
    await tester.pumpAndSettle();

    final txt2 = tester.widget<Text>(timeTextFinder).data ?? '';
    expect(txt2.startsWith('30:'), isTrue, reason: 'next session should use staged 30 minutes');
  });
}
