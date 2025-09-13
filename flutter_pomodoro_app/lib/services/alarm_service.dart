import 'dart:async';

abstract class AlarmService {
  Future<void> play({required String assetName, required Duration loopFor});
  Future<void> stop();
  bool get isPlaying;
}

class NoopAlarmService implements AlarmService {
  bool _playing = false;
  @override
  bool get isPlaying => _playing;

  @override
  Future<void> play({required String assetName, required Duration loopFor}) async {
    _playing = true;
  }

  @override
  Future<void> stop() async {
    _playing = false;
  }
}

/// Simple implementation using audioplayers to play bundled asset audio.
class AssetAlarmService implements AlarmService {
  // Placeholder implementation that simulates playback timing without audio engine.
  Timer? _timer;
  bool _playing = false;

  @override
  bool get isPlaying => _playing;

  @override
  Future<void> play({required String assetName, required Duration loopFor}) async {
    await stop();
    _playing = true;
    _timer = Timer(loopFor, () => stop());
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _playing = false;
  }
}
