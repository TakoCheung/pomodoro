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

    // Find Apply button and tap
    final apply = find.text('Apply');
    expect(apply, findsOneWidget);
    await tester.tap(apply);
    await tester.pumpAndSettle();

  // Validate that after applying, the main screen still shows (smoke check)
  expect(find.byKey(const Key('pomodoro_title')), findsOneWidget);
  });
}
