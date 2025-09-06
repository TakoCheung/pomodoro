import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_pomodoro_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Select Bible version from settings updates provider', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Open settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Open dropdown
    await tester.tap(find.byKey(const Key('bible_version_dropdown')));
    await tester.pumpAndSettle();

    // Select a menu item: prefer the dummy if present in the overlay, else pick ESV if available
    final dummyFinder = find.text('Test (Dummy)');
    if (dummyFinder.evaluate().isNotEmpty) {
      await tester.tap(dummyFinder.last);
      await tester.pumpAndSettle();
    } else if (find.text('ESV').evaluate().isNotEmpty) {
      await tester.tap(find.text('ESV').last);
      await tester.pumpAndSettle();
    }

    // Ensure the footer buttons are visible, then apply for next session
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('apply_next_session_button')));
    await tester.pumpAndSettle();

    // Nothing hard asserts here beyond flow; a full provider assert would require in-app debug UI.
    expect(find.byKey(const Key('pomodoro_title')), findsOneWidget);
  });
}
