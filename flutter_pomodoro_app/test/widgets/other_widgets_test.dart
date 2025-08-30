import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_mode_switch_ui.dart';
import 'package:flutter_pomodoro_app/components/setting/divider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('GearIconButton shows settings button and opens dialog',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: Scaffold(body: GearIconButton()))));

    final btn = find.byKey(const Key('settingsButton'));
    expect(btn, findsOneWidget);

    await tester.tap(btn);
    await tester.pumpAndSettle();

    // Settings dialog should appear
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('TimerModeSwitcherUI toggles modes', (tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: Scaffold(body: TimerModeSwitcherUI()))));

    // default mode button should be present
    expect(find.text('pomodoro'), findsWidgets);
    // Tap short break
    await tester.tap(find.text('short break').first);
    await tester.pumpAndSettle();

    // After tapping, expect UI still present
    expect(find.text('short break'), findsWidgets);
  });

  testWidgets('CustomDivider renders spacing and divider', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CustomDivider(spaceBefore: 5, spaceAfter: 7))));

    expect(find.byType(Divider), findsOneWidget);
  });
}
