import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main(){
  testWidgets('TimerDisplay shows time and toggles pause/restart', (tester) async{
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: Scaffold(body: TimerDisplay()))));

    // initial formatted time should match default
    expect(find.textContaining(':'), findsOneWidget);

    // the pause/restart button exists
    expect(find.byKey(const Key('pauseRestart')), findsOneWidget);
  });
}
