import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('Settings Screen Golden Test', (WidgetTester tester) async {
    final builder = GoldenBuilder.column()
      ..addScenario('Settings Screen Mobile', const SettingsScreen());

    tester.binding.window.physicalSizeTestValue = const Size(375, 667); // iPhone size
    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'setting_screen_mobile');

    tester.binding.window.physicalSizeTestValue = const Size(1024, 768); // Tablet size
    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'setting_screen_tablet');

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });
}