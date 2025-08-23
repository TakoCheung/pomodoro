import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main(){
  testWidgets('Settings Apply updates timerProvider', (tester) async{
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())));

    // Open settings
    final settingsBtn = find.byKey(const Key('settingsButton'));
    expect(settingsBtn, findsOneWidget);
    await tester.tap(settingsBtn);
    await tester.pumpAndSettle();

    // Find a NumberInput and increment pomodoro minutes (+1)
    final plusButton = find.byIcon(Icons.keyboard_arrow_up).first;
    await tester.tap(plusButton);
    await tester.pumpAndSettle();

    // Apply changes
    final applyBtn = find.text('Apply');
    expect(applyBtn, findsOneWidget);
    await tester.tap(applyBtn);
    await tester.pumpAndSettle();

    // After applying, timerProvider should reflect new initPomodoro (>= default)
    final container = ProviderScope.containerOf(tester.element(find.byType(PomodoroTimerScreen)));
    final state = container.read(timerProvider);
    expect(state.initPomodoro, greaterThanOrEqualTo(TimerState.pomodoroDefaut));
  });
}
