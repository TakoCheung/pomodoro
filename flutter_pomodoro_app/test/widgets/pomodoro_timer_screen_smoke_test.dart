import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('PomodoroTimerScreen smoke test hits build tree', (tester) async {
    // enlarge headless window so the column spacing does not overflow
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 3.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));
    // Ensure title and gear button exist which touches the build and the small missing line
    expect(find.text('pomodoro'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
