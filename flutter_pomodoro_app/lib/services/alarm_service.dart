import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

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
  final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
  Timer? _timer;
  bool _playing = false;

  @override
  bool get isPlaying => _playing;

  @override
  Future<void> play({required String assetName, required Duration loopFor}) async {
    // Stop any ongoing playback first
    await stop();
    _playing = true;

    // Preload the asset and start playing, looping until stopped.
    final assetPath = assetName.replaceFirst('assets/audio/', 'audio/');
    try {
      await _player.setSource(AssetSource(assetPath));
    } catch (_) {
      // Fallback to wav if mp4 fails (platform codec mismatch)
      final wavPath = assetPath.replaceFirst('.mp4', '.wav');
      try {
        await _player.setSource(AssetSource(wavPath));
      } catch (_) {}
    }
    try {
      await _player.resume();
    } catch (_) {}

    // Restart playback every time the audio completes while within loop window.
    // As a simple approach, we use a one-shot timer to stop after loopFor.
    _timer = Timer(loopFor, () async {
      await stop();
    });
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    try {
      await _player.stop();
    } catch (_) {}
    _playing = false;
  }
}
