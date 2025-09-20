import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';

/// Interface for a TTS engine. Tests will provide a fake.
abstract class ITtsEngine {
  Future<void> speak(String text);
  Future<void> stop();

  /// Emits true while the engine is actively speaking.
  Stream<bool> get isSpeaking;
}

/// Default no-op implementation used in app unless overridden (e.g. real platform TTS later).
class NoopTtsEngine implements ITtsEngine {
  final _ctrl = StreamController<bool>.broadcast();
  @override
  Stream<bool> get isSpeaking => _ctrl.stream;
  @override
  Future<void> speak(String text) async {
    // Emit a brief speaking pulse for UI feedback in debug builds.
    _ctrl.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    _ctrl.add(false);
  }

  @override
  Future<void> stop() async {
    _ctrl.add(false);
  }
}

/// Real implementation backed by flutter_tts (only used in app runtime, not tests).
class RealTtsEngine implements ITtsEngine {
  final FlutterTts _tts = FlutterTts();
  final _speaking = StreamController<bool>.broadcast();
  bool _isSpeaking = false;

  RealTtsEngine() {
    _tts.setStartHandler(() {
      _isSpeaking = true;
      _speaking.add(true);
    });
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _speaking.add(false);
    });
    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      _speaking.add(false);
      debugPrint('RealTtsEngine error: $msg');
    });
  }

  @override
  Stream<bool> get isSpeaking => _speaking.stream;

  @override
  Future<void> speak(String text) async {
    try {
      await _tts.stop();
    } catch (_) {}
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } finally {
      if (_isSpeaking) {
        _isSpeaking = false;
        _speaking.add(false);
      }
    }
  }
}

/// Provides the TTS engine (override in tests with a FakeTtsEngine).
final ttsEngineProvider = Provider<ITtsEngine>((ref) => NoopTtsEngine());

/// Derived enablement: active only when sound is enabled and soundId == 'tts_scripture'.
final scriptureAudioEnabledProvider = Provider<bool>((ref) {
  final s = ref.watch(localSettingsProvider);
  return s.soundEnabled && s.soundId == 'tts_scripture';
});

/// Speaking state (mirrors engine stream while feature enabled).
final isScriptureSpeakingProvider = StateProvider<bool>((ref) => false);

/// Controller coordinating scripture TTS behavior.
class ScriptureAudioController {
  ScriptureAudioController(this._ref) {
    // Watch enablement; when disabled, ensure engine is stopped and state cleared.
    _enableSub = _ref.listen<bool>(scriptureAudioEnabledProvider, (prev, next) async {
      if (prev == true && next == false) {
        // Stop playback on disable transition.
        try {
          await _ref.read(ttsEngineProvider).stop();
        } catch (e) {
          debugPrint('ScriptureAudioController: stop on disable failed: $e');
        }
        _ref.read(isScriptureSpeakingProvider.notifier).state = false;
      }
    });
    // Mirror engine speaking stream.
    final engine = _ref.read(ttsEngineProvider);
    _speakSub = engine.isSpeaking.listen((v) {
      _ref.read(isScriptureSpeakingProvider.notifier).state =
          v && _ref.read(scriptureAudioEnabledProvider);
    });
  }

  final Ref _ref;
  late final ProviderSubscription<bool> _enableSub;
  late final StreamSubscription<bool> _speakSub;
  bool _eventInFlight = false; // idempotency guard

  Future<void> playForCurrentPassage({bool forceRestart = false}) async {
    if (!_ref.read(scriptureAudioEnabledProvider)) return;
    if (_eventInFlight) return; // collapse simultaneous triggers
    _eventInFlight = true;
    try {
      final engine = _ref.read(ttsEngineProvider);
      Passage? passage = _ref.read(shownScriptureProvider);
      if (passage == null) {
        // Attempt to derive from last passage id if overlay not yet shown (background notification tap path)
        // In this minimal implementation we simply abort: no scripture available.
        return;
      }
      final text = (passage.text.isNotEmpty ? passage.text : passage.reference).trim();
      try {
        await engine.stop();
      } catch (e) {
        debugPrint('ScriptureAudioController: stop before speak failed: $e');
      }
      try {
        await engine.speak(text);
      } catch (e) {
        debugPrint('ScriptureAudioController: speak failed: $e');
      }
    } finally {
      _eventInFlight = false;
    }
  }

  Future<void> stop() async {
    try {
      await _ref.read(ttsEngineProvider).stop();
    } catch (e) {
      debugPrint('ScriptureAudioController: stop failed: $e');
    }
    _ref.read(isScriptureSpeakingProvider.notifier).state = false;
  }

  void dispose() {
    _enableSub.close();
    _speakSub.cancel();
  }
}

final scriptureAudioControllerProvider = Provider<ScriptureAudioController>((ref) {
  final c = ScriptureAudioController(ref);
  ref.onDispose(c.dispose);
  return c;
});
