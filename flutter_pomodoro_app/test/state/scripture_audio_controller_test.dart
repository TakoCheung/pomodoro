import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/scripture_audio_providers.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';

class FakeTtsEngine implements ITtsEngine {
  final _ctrl = StreamController<bool>.broadcast();
  final List<String> speaks = [];
  bool stopped = false;
  @override
  Stream<bool> get isSpeaking => _ctrl.stream;
  @override
  Future<void> speak(String text) async {
    speaks.add(text);
    _ctrl.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    _ctrl.add(false);
  }

  @override
  Future<void> stop() async {
    stopped = true;
    _ctrl.add(false);
  }
}

void main() {
  group('ScriptureAudioController', () {
    test('speak on event when enabled', () async {
      final engine = FakeTtsEngine();
      final container = ProviderContainer(overrides: [ttsEngineProvider.overrideWithValue(engine)]);
      addTearDown(container.dispose);
      container.read(localSettingsProvider.notifier).updateSoundId('tts_scripture');
      // Insert passage
      container.read(shownScriptureProvider.notifier).state =
          Passage(reference: 'Gen 1:1', text: 'In the beginning', verses: []);
      await container.read(scriptureAudioControllerProvider).playForCurrentPassage();
      expect(engine.speaks, isNotEmpty);
      expect(engine.speaks.last, contains('In the beginning'));
    });

    test('disabled path does not speak', () async {
      final engine = FakeTtsEngine();
      final container = ProviderContainer(overrides: [ttsEngineProvider.overrideWithValue(engine)]);
      addTearDown(container.dispose);
      // soundId not tts_scripture
      container.read(shownScriptureProvider.notifier).state =
          Passage(reference: 'Gen 1:1', text: 'In the beginning', verses: []);
      await container.read(scriptureAudioControllerProvider).playForCurrentPassage();
      expect(engine.speaks, isEmpty);
    });

    test('restart collapses rapid dual events', () async {
      final engine = FakeTtsEngine();
      final container = ProviderContainer(overrides: [ttsEngineProvider.overrideWithValue(engine)]);
      addTearDown(container.dispose);
      container.read(localSettingsProvider.notifier).updateSoundId('tts_scripture');
      container.read(shownScriptureProvider.notifier).state =
          Passage(reference: 'Gen 1:1', text: 'In the beginning', verses: []);
      // Fire two concurrent calls
      await Future.wait([
        container.read(scriptureAudioControllerProvider).playForCurrentPassage(),
        container.read(scriptureAudioControllerProvider).playForCurrentPassage(),
      ]);
      expect(engine.speaks.length, 1); // collapsed
    });

    test('stop on disable transition', () async {
      final engine = FakeTtsEngine();
      final container = ProviderContainer(overrides: [ttsEngineProvider.overrideWithValue(engine)]);
      addTearDown(container.dispose);
      final local = container.read(localSettingsProvider.notifier);
      local.updateSoundId('tts_scripture');
      container.read(shownScriptureProvider.notifier).state =
          Passage(reference: 'Gen 1:1', text: 'In the beginning', verses: []);
      await container.read(scriptureAudioControllerProvider).playForCurrentPassage();
      expect(engine.speaks.length, 1);
      local.updateSoundEnabled(false); // triggers disable
      // allow microtask
      await Future<void>.delayed(Duration.zero);
      expect(engine.stopped, true);
    });
  });
}
