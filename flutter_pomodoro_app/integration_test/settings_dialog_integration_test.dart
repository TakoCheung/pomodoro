import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Settings dialog full integration flow', (tester) async {
    // This integration test requires a real device/emulator. It is safe to keep
    // as a file in the repo; CI should run it in a separate job that has an emulator.
    app.main();
    await tester.pumpAndSettle();

    // Tap the gear icon to open settings (integration will perform real taps)
    final gear = find.byIcon(Icons.settings);
    expect(gear, findsOneWidget);
    await tester.tap(gear);
    await tester.pumpAndSettle();

    // Toggle Debug Mode on
    final debugSwitch = find.byType(Switch);
    expect(debugSwitch, findsWidgets);
    await tester.tap(debugSwitch.first);
    await tester.pumpAndSettle();

    // Find Apply Next Session button and tap
    final apply = find.byKey(const Key('apply_next_session_button'));
    expect(apply, findsOneWidget);
    await tester.tap(apply);
    await tester.pumpAndSettle();

    // Validate the main screen still shows and timer reflects debug mapping
    expect(find.byKey(const Key('pomodoro_title')), findsOneWidget);
    final timerTextFinder = find.byKey(const Key('timer_text'));
    expect(timerTextFinder, findsOneWidget);
    // Timer text should be a mm:ss value; don't assert exact seconds to avoid flakiness.
    final text = tester.widget<Text>(timerTextFinder).data ?? '';
    expect(RegExp(r'^\d{2}:\d{2}$').hasMatch(text), isTrue);
  });
}
