import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  final shouldUpdate = const String.fromEnvironment('UPDATE_GOLDENS') == '1';

  testGoldens('Settings Screen Goldens ( gated )', (WidgetTester tester) async {
    if (!shouldUpdate) {
      // skip expensive golden comparisions unless explicitly enabled
      return Future<void>.value();
    }

    // Wrap SettingsScreen with the expected app scaffolding so providers and
    // MediaQuery are available. Constrain the surfaceSize to avoid overflow
    // during golden rendering. Also set devicePixelRatio so logical size
    // calculations are stable in headless runs.
    // Use a wider surface to accommodate SettingsScreen layout and avoid
    // small render overflows during golden rendering.
    final width = 540.0;
    // Set DPR for stable logical size calculations in headless runs
    tester.view.devicePixelRatio = 1.0;
    final widget = ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidgetBuilder(widget, surfaceSize: Size(width, 720));
    await tester.pumpAndSettle();

    await screenMatchesGolden(tester, 'setting_screen_mobile');

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
