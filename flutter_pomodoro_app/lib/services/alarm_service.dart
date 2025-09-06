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
