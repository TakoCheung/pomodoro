import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/data/bible_versions.dart';

const String _prefsKeySettings = 'settings_v1';

Map<String, dynamic> _defaultsJson() => <String, dynamic>{
      'pomodoro': TimerDefaults.pomodoroDefault,
      'shortBreak': TimerDefaults.shortBreakDefault,
      'longBreak': TimerDefaults.longBreakDefault,
      'fontFamily': AppTextStyles.kumbhSans,
      'primaryColor': '#FF3B30', // iOS system Red; map to closest AppColors below
      'bibleVersionName': kDefaultBibleVersionName,
      // Prefer explicit default id to avoid lookup latency/flicker on cold start.
      'bibleVersionId': '32664dc3288a28df-01',
      'debugMode': false,
      'notificationsEnabled': true,
      'soundEnabled': true,
      'hapticsEnabled': true,
    };

Color _colorFromHex(String hex) {
  var value = hex.replaceAll('#', '').toUpperCase();
  if (value.length == 6) value = 'FF$value';
  final intColor = int.tryParse(value, radix: 16) ?? 0xFFFF3B30;
  return Color(intColor);
}

String _toHex(Color color) => '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

LocalSettings _mergeIntoDefaults(Map<String, dynamic> jsonMap) {
  final d = _defaultsJson();
  // Merge: jsonMap values override defaults.
  d.addAll(jsonMap);
  // Map primaryColor to closest of our defined palette if not exact.
  final desired = _colorFromHex(d['primaryColor'] as String? ?? '#FF3B30');
  Color chosen = AppColors.orangeRed;
  // simple heuristic: if blue-ish, pick lightBlue; if purple-ish, pick lightPurle.
  if (desired.blue > desired.red && desired.blue > desired.green) {
    chosen = AppColors.lightBlue;
  } else if (desired.red > desired.blue && desired.blue > desired.green) {
    chosen = AppColors.lightPurle;
  }
  return LocalSettings(
    initPomodoro: (d['pomodoro'] as int?) ?? TimerDefaults.pomodoroDefault,
    initShortBreak: (d['shortBreak'] as int?) ?? TimerDefaults.shortBreakDefault,
    initLongBreak: (d['longBreak'] as int?) ?? TimerDefaults.longBreakDefault,
    fontFamily: (d['fontFamily'] as String?) ?? AppTextStyles.kumbhSans,
    color: chosen,
    debugMode: (d['debugMode'] as bool?) ?? false,
    notificationsEnabled: (d['notificationsEnabled'] as bool?) ?? true,
    soundEnabled: (d['soundEnabled'] as bool?) ?? true,
    hapticsEnabled: (d['hapticsEnabled'] as bool?) ?? true,
    bibleVersionName: (d['bibleVersionName'] as String?) ?? kDefaultBibleVersionName,
    bibleVersionId: d['bibleVersionId'] as String?,
  );
}

Map<String, dynamic> _toJson(LocalSettings s) => <String, dynamic>{
      'pomodoro': s.initPomodoro,
      'shortBreak': s.initShortBreak,
      'longBreak': s.initLongBreak,
      'fontFamily': s.fontFamily,
      'primaryColor': _toHex(s.color),
      'bibleVersionName': s.bibleVersionName,
      'bibleVersionId': s.bibleVersionId,
      'debugMode': s.debugMode,
      'notificationsEnabled': s.notificationsEnabled,
      'soundEnabled': s.soundEnabled,
      'hapticsEnabled': s.hapticsEnabled,
    };

/// Exposes helpers to load and persist LocalSettings into SharedPreferences.
class SettingsPersistence {
  final SharedPreferences prefs;
  SettingsPersistence(this.prefs);

  LocalSettings loadOrDefaults() {
    final raw = prefs.getString(_prefsKeySettings);
    if (raw == null || raw.isEmpty) {
      return _mergeIntoDefaults(const <String, dynamic>{});
    }
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return _mergeIntoDefaults(map);
    } catch (e) {
      debugPrint('SettingsPersistence: failed to decode cache: $e');
      return _mergeIntoDefaults(const <String, dynamic>{});
    }
  }

  Future<void> persist(LocalSettings s) async {
    try {
      await prefs.setString(_prefsKeySettings, json.encode(_toJson(s)));
    } catch (e) {
      debugPrint('SettingsPersistence: failed to persist: $e');
    }
  }

  Future<void> resetToDefaults() async {
    try {
      await prefs.remove(_prefsKeySettings);
    } catch (_) {}
  }
}

final settingsPersistenceProvider = Provider<SettingsPersistence?>((ref) {
  final sp = ref.watch(sharedPreferencesProvider);
  return sp.maybeWhen<SettingsPersistence?>(
    data: (prefs) => SettingsPersistence(prefs),
    orElse: () => null,
  );
});

// Internal flag to ensure we hydrate only once per app lifecycle.
final _settingsHydratedFlagProvider = StateProvider<bool>((ref) => false);

/// Initializes LocalSettings from cache and keeps it persisted on change.
/// Also applies settings to TimerNotifier at hydration time to avoid long-lived
/// mismatches between UI theme and stored settings.
final settingsPersistenceInitializerProvider = Provider<bool>((ref) {
  final persistence = ref.watch(settingsPersistenceProvider);
  if (persistence == null) return false;

  final hydrated = ref.read(_settingsHydratedFlagProvider);
  if (!hydrated) {
    // Defer updates to after first frame to avoid modifying providers during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(localSettingsProvider.notifier);
      final loaded = persistence.loadOrDefaults();
      // Live settings: apply immediately.
      notifier.updateFont(loaded.fontFamily);
      notifier.updateColor(loaded.color);
      notifier.updateBibleVersionName(loaded.bibleVersionName);
      if (loaded.bibleVersionId != null) {
        notifier.updateBibleVersion(loaded.bibleVersionName, loaded.bibleVersionId!);
      }
      notifier.updateDebugMode(loaded.debugMode);
      notifier.updateNotificationsEnabled(loaded.notificationsEnabled);
      notifier.updateSoundEnabled(loaded.soundEnabled);
      notifier.updateHapticsEnabled(loaded.hapticsEnabled);
      // Stage session-scoped settings into LocalSettings only; timer picks them up
      // at the next session boundary.
      notifier.updateTime(TimerMode.pomodoro, loaded.initPomodoro ~/ 60);
      notifier.updateTime(TimerMode.shortBreak, loaded.initShortBreak ~/ 60);
      notifier.updateTime(TimerMode.longBreak, loaded.initLongBreak ~/ 60);
      // Apply live settings to timer immediately without affecting time remaining.
      ref.read(timerProvider.notifier).applyLiveSettings(loaded);
      ref.read(_settingsHydratedFlagProvider.notifier).state = true;
    });
  }

  // Persist on every settings change.
  ref.listen<LocalSettings>(localSettingsProvider, (prev, next) {
    if (prev == next) return;
    persistence.persist(next);
  });

  return true;
});
