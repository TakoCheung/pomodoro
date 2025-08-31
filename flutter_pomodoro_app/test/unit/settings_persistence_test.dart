import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/settings_persistence.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsPersistence', () {
    test('First launch shows defaults when no cache exists', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final sp = SettingsPersistence(prefs);
      final ls = sp.loadOrDefaults();
      expect(ls.initPomodoro, 25 * 60);
      expect(ls.initShortBreak, 5 * 60);
      expect(ls.initLongBreak, 15 * 60);
      expect(ls.fontFamily, isNotEmpty);
    });

    test('Changing a setting writes to cache', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final sp = SettingsPersistence(prefs);
      final container = ProviderContainer(overrides: []);
      addTearDown(container.dispose);
      final notifier = LocalSettingsNotifier(
        sp.loadOrDefaults(),
      );
      notifier.updateTime(TimerMode.pomodoro, 30);
      await sp.persist(notifier.state);
      final jsonStr = prefs.getString('settings_v1');
      expect(jsonStr, isNotNull);
      final map = json.decode(jsonStr!);
      expect(map['pomodoro'], 30 * 60);
    });

    test('Relaunch loads from cache', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'settings_v1': json.encode({
          'pomodoro': 30 * 60,
          'shortBreak': 5 * 60,
          'longBreak': 15 * 60,
          'fontFamily': 'System',
          'primaryColor': '#FF3B30',
        })
      });
      final prefs = await SharedPreferences.getInstance();
      final sp = SettingsPersistence(prefs);
      final ls = sp.loadOrDefaults();
      expect(ls.initPomodoro, 30 * 60);
    });

    test('Partial cached settings merge over defaults', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'settings_v1': json.encode({'primaryColor': '#34C759'})
      });
      final prefs = await SharedPreferences.getInstance();
      final sp = SettingsPersistence(prefs);
      final ls = sp.loadOrDefaults();
      // Font and pomodoro should be defaults
      expect(ls.fontFamily, 'KumbhSans');
      expect(ls.initPomodoro, 25 * 60);
    });

    test('Corrupted cache falls back to defaults and logs error', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{'settings_v1': '{this is not json}'});
      final prefs = await SharedPreferences.getInstance();
      final sp = SettingsPersistence(prefs);
      final ls = sp.loadOrDefaults();
      expect(ls.initPomodoro, 25 * 60);
    });

    test('Multiple settings persist after change', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final sp = SettingsPersistence(prefs);
      final ls = sp.loadOrDefaults();
      final notifier = LocalSettingsNotifier(ls);
      notifier.updateFont('Inter');
      notifier.updateTime(TimerMode.pomodoro, 50);
      await sp.persist(notifier.state);
      final map = json.decode(prefs.getString('settings_v1')!);
      expect(map['fontFamily'], 'Inter');
      expect(map['pomodoro'], 50 * 60);
    });
  });
}
