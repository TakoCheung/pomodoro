import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_haptics_providers.dart';
import 'package:flutter_pomodoro_app/services/alarm_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';

class TestAlarmService extends NoopAlarmService {}

class _FakeScriptureService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return Passage(reference: 'R', text: 'T');
  }
}

void main() {
  test('Foreground completion shows banner and plays in-app alarm (no system notif)', () async {
    final container = ProviderContainer(overrides: [
      isAppForegroundProvider.overrideWith((_) => true),
      alarmServiceProvider.overrideWithValue(TestAlarmService()),
      scriptureServiceProvider.overrideWithValue(_FakeScriptureService()),
    ]);
    addTearDown(container.dispose);
    // Ensure settings default to enabled
    final notifier = container.read(localSettingsProvider.notifier);
    notifier.updateSoundEnabled(true);
    notifier.updateHapticsEnabled(true);

    // Trigger completion
    final timer = container.read(timerProvider.notifier);
    timer.triggerComplete();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // Foreground should show in-app banner and start alarm sound.
    expect(container.read(alarmBannerVisibleProvider), isTrue);
    expect(container.read(alarmServiceProvider).isPlaying, isTrue);
  });
}
