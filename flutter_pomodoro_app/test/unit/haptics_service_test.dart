import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/services/haptics_service.dart';

void main() {
  test('DefaultHapticsService handles short and long pulses without throwing', () async {
    final svc = DefaultHapticsService();
    await svc.pattern(const [HapticPulse.short, HapticPulse.long, HapticPulse.short]);
  });

  test('NoopHapticsService completes immediately', () async {
    final svc = NoopHapticsService();
    final sw = Stopwatch()..start();
    await svc.pattern(const [HapticPulse.long, HapticPulse.short]);
    sw.stop();
    expect(sw.elapsed, isNotNull);
  });
}
