import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/scripture_audio_providers.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';

class ManualTtsEngine implements ITtsEngine {
  final _ctrl = StreamController<bool>.broadcast();
  @override
  Stream<bool> get isSpeaking => _ctrl.stream;
  bool speaking = false;
  @override
  Future<void> speak(String text) async {
    speaking = true;
    _ctrl.add(true);
  }

  @override
  Future<void> stop() async {
    speaking = false;
    _ctrl.add(false);
  }
}

void main() {
  testWidgets('indicator appears when speaking', (tester) async {
    final engine = ManualTtsEngine();
    final container = ProviderContainer(overrides: [ttsEngineProvider.overrideWithValue(engine)]);
    addTearDown(container.dispose);
    // enable feature
    container.read(localSettingsProvider.notifier).updateSoundId('tts_scripture');
    container.read(shownScriptureProvider.notifier).state =
        Passage(reference: 'Gen 1:1', text: 'In the beginning', verses: []);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const MaterialApp(home: PomodoroTimerScreen())));
    await container.read(scriptureAudioControllerProvider).playForCurrentPassage();
    await tester.pump();
    expect(find.byKey(const Key('scripture_voice_playing')), findsOneWidget);
  });
}
