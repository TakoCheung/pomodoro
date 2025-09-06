import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_pomodoro_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Enable debug mode and apply settings (no FAB present)', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Open settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Toggle Debug Mode switch on
    final debugSwitch = find.byType(Switch);
    expect(debugSwitch, findsWidgets);
    await tester.tap(debugSwitch.first);
    await tester.pumpAndSettle();

    // Apply for next session (non-interrupting)
    await tester.tap(find.byKey(const Key('apply_next_session_button')));
    await tester.pumpAndSettle();

    // Main title still visible
    expect(find.byKey(const Key('pomodoro_title')), findsOneWidget);

    // No debug FAB anymore
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
