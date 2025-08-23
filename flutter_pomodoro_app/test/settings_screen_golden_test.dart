import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testWidgets('Settings Screen renders for mobile and tablet', (WidgetTester tester) async {
    // Mobile
    tester.binding.window.physicalSizeTestValue = const Size(375, 667);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: SettingsScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    // Tablet
    tester.binding.window.physicalSizeTestValue = const Size(1366, 1024);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: SettingsScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });
}