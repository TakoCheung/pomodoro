import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_audio_providers.dart';

class _Harness {
  late ProviderContainer container;
  _Harness() {
    container = ProviderContainer();
  }
}

void main() {
  group('scriptureAudioEnabledProvider', () {
    test('enabled only when soundEnabled && soundId == tts_scripture', () {
      final h = _Harness();
      final notifier = h.container.read(localSettingsProvider.notifier);
      // baseline defaults
      expect(h.container.read(scriptureAudioEnabledProvider), false);
      notifier.updateSoundId('tts_scripture');
      expect(h.container.read(scriptureAudioEnabledProvider), true);
      notifier.updateSoundEnabled(false);
      expect(h.container.read(scriptureAudioEnabledProvider), false);
      notifier.updateSoundEnabled(true);
      notifier.updateSoundId('beep');
      expect(h.container.read(scriptureAudioEnabledProvider), false);
    });
  });
}
