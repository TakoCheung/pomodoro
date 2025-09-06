import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';

void main() {
  test('LocalSettings defaults enable sound and haptics', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final settings = container.read(localSettingsProvider);
    expect(settings.soundEnabled, isTrue);
    expect(settings.hapticsEnabled, isTrue);
  });
}
