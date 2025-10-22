import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/services/alarm_service.dart';

void main() {
  test('NoopAlarmService toggles isPlaying on play/stop', () async {
    final svc = NoopAlarmService();
    expect(svc.isPlaying, isFalse);

    await svc.play(assetName: 'assets/audio/bell.mp4', loopFor: const Duration(seconds: 1));
    expect(svc.isPlaying, isTrue);

    await svc.stop();
    expect(svc.isPlaying, isFalse);
  });
}
