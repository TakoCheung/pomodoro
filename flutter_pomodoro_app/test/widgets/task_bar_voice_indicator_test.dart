import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/state/scripture_audio_providers.dart';
import 'package:flutter_pomodoro_app/components/timer/task_bar.dart';

void main() {
  testWidgets('Voice indicator sits above task bar with extra bottom padding', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      // Force scripture speaking true
      isScriptureSpeakingProvider.overrideWith((ref) => true),
    ], child: const MaterialApp(home: PomodoroTimerScreen())));
    await tester.pump();

    final voiceFinder = find.byKey(const Key('scripture_voice_playing'));
    expect(voiceFinder, findsOneWidget);
    final barFinder = find.byKey(const Key('task_bar'));
    expect(barFinder, findsOneWidget);

    // RED: Expect padding bottom >= 24 + TaskBarDefaults.height
    final voiceWidget = tester
        .widget<Padding>(find.ancestor(of: voiceFinder, matching: find.byType(Padding)).first);
    final pad = voiceWidget.padding as EdgeInsets;
    expect(pad.bottom, greaterThanOrEqualTo(24 + TaskBarDefaults.height));
  });
}
