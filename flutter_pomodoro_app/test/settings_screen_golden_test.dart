import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Settings Screen renders for mobile and tablet', (WidgetTester tester) async {
    // Mobile (constrain width to avoid overflow in headless layout)
    tester.view.physicalSize = const Size(420, 800);
    tester.view.devicePixelRatio = 1.0;
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
    tester.view.physicalSize = const Size(1366, 1024);
    tester.view.devicePixelRatio = 1.0;
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

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
