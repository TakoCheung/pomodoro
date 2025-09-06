import 'package:flutter/services.dart' show HapticFeedback;

enum HapticPulse { short, long }

abstract class HapticsService {
  Future<void> pattern(List<HapticPulse> pulses);
}

class DefaultHapticsService implements HapticsService {
  @override
  Future<void> pattern(List<HapticPulse> pulses) async {
    for (final p in pulses) {
      try {
        if (p == HapticPulse.long) {
          await HapticFeedback.heavyImpact();
        } else {
          await HapticFeedback.mediumImpact();
        }
      } catch (_) {
        // In unit tests without a WidgetsBinding or on platforms without haptics,
        // ignore failures to keep behavior non-fatal.
      }
    }
  }
}

class NoopHapticsService implements HapticsService {
  @override
  Future<void> pattern(List<HapticPulse> pulses) async {
    // no-op
  }
}
