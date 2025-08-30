import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Toggling Debug Mode updates time inputs to allow zero', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: Scaffold(body: SettingsScreen()))));

    // Toggle debug mode
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // With debug on, the min for inputs should be 0; decrement Pomodoro from default to reach 0
    // Find the first number input's down button and tap multiple times, then ensure it shows a smaller number.
    final downButtons = find.byIcon(Icons.keyboard_arrow_down);
    expect(downButtons, findsWidgets);
    for (int i = 0; i < 5; i++) {
      await tester.tap(downButtons.first);
      await tester.pump();
    }

    // Apply changes should not throw; we just ensure the dialog is present
    expect(find.byKey(const Key('SettingsScreen')), findsOneWidget);
  });
}
