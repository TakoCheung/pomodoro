import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Settings Screen renders for mobile and tablet', (WidgetTester tester) async {
  // Mobile (constrain width to avoid overflow in headless layout)
  tester.binding.window.physicalSizeTestValue = const Size(420, 800);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 420, child: const SettingsScreen()),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

  // Tablet (wider surface)
  tester.binding.window.physicalSizeTestValue = const Size(1366, 1024);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 540, child: const SettingsScreen()),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    addTearDown((){
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}