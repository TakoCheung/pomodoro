import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_magic_number.dart';
import 'package:flutter_pomodoro_app/state/timer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/data/bible_versions.dart';

/// Local settings live in their own provider and start from safe defaults.
/// We avoid reading `timerProvider` at provider creation time to prevent
/// NotInitializedError (ProviderScope initialization ordering issues).
final localSettingsProvider = StateNotifierProvider<LocalSettingsNotifier, LocalSettings>((ref) {
  return LocalSettingsNotifier(
    LocalSettings(
      initPomodoro: TimerDefaults.pomodoroDefault,
      initShortBreak: TimerDefaults.shortBreakDefault,
      initLongBreak: TimerDefaults.longBreakDefault,
      fontFamily: AppTextStyles.kumbhSans,
      color: AppColors.orangeRed,
      bibleVersionName: kDefaultBibleVersionName,
    ),
  );
});

class LocalSettings {
  int initPomodoro;
  int initShortBreak;
  int initLongBreak;
  String fontFamily;
  Color color;
  bool debugMode;
  bool notificationsEnabled;
  bool soundEnabled; // legacy; retained for backward-compat only
  bool hapticsEnabled;
  String soundId; // e.g., classic_bell, gentle_chime, beep
  String bibleVersionName;
  String? bibleVersionId;

  LocalSettings({
    required this.initPomodoro,
    required this.initShortBreak,
    required this.initLongBreak,
    required this.fontFamily,
    required this.color,
    this.debugMode = false,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.soundId = 'classic_bell',
    this.bibleVersionName = kDefaultBibleVersionName,
    this.bibleVersionId,
  });

  LocalSettings copyWith(
      {int? initPomodoro,
      int? initLongBreak,
      int? initShortBreak,
      String? fontFamily,
      Color? color,
      bool? debugMode,
      bool? notificationsEnabled,
      bool? soundEnabled,
      bool? hapticsEnabled,
      String? soundId,
      String? bibleVersionName,
      String? bibleVersionId}) {
    return LocalSettings(
        initLongBreak: initLongBreak ?? this.initLongBreak,
        initPomodoro: initPomodoro ?? this.initPomodoro,
        initShortBreak: initShortBreak ?? this.initShortBreak,
        fontFamily: fontFamily ?? this.fontFamily,
        color: color ?? this.color,
        debugMode: debugMode ?? this.debugMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        soundId: soundId ?? this.soundId,
        bibleVersionName: bibleVersionName ?? this.bibleVersionName,
        bibleVersionId: bibleVersionId ?? this.bibleVersionId);
  }
}

class LocalSettingsNotifier extends StateNotifier<LocalSettings> {
  LocalSettingsNotifier(super.state);

  /// Replace the entire settings snapshot atomically. Intended for commits
  /// from SettingsRepository.apply() to ensure the app reads a consistent
  /// committed view.
  void replace(LocalSettings next) {
    state = next;
  }

  void updateFont(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
  }

  void updateColor(Color color) {
    state = state.copyWith(color: color);
  }

  void updateBibleVersionName(String name) {
    // When only the name is set (e.g., during loading fallback), clear the id to avoid stale mismatch.
    state = state.copyWith(bibleVersionName: name, bibleVersionId: null);
  }

  void updateBibleVersion(String name, String id) {
    state = state.copyWith(bibleVersionName: name, bibleVersionId: id);
  }

  void updateTime(TimerMode mode, int timeInMin) {
    switch (mode) {
      case TimerMode.pomodoro:
        state = state.copyWith(initPomodoro: _calcSeconds(timeInMin));
        break;
      case TimerMode.shortBreak:
        state = state.copyWith(initShortBreak: _calcSeconds(timeInMin));
        break;
      case TimerMode.longBreak:
        state = state.copyWith(initLongBreak: _calcSeconds(timeInMin));
        break;
    }
  }

  int _calcSeconds(int timeInMin) {
    // If debug mode is enabled and user sets minutes to 0, treat it as 1 second for quick testing.
    if (state.debugMode && timeInMin == 0) return 1;
    return timeInMin * AppMagicNumber.sixty;
  }

  void updateDebugMode(bool enabled) {
    // When enabling debug mode, force all timers to zero for fast flows.
    // When disabling, keep current values (user can adjust back manually).
    if (enabled) {
      state = state.copyWith(
        debugMode: true,
        initPomodoro: 0,
        initShortBreak: 0,
        initLongBreak: 0,
      );
    } else {
      state = state.copyWith(debugMode: false);
    }
  }

  void updateNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void updateSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
  }

  void updateHapticsEnabled(bool enabled) {
    state = state.copyWith(hapticsEnabled: enabled);
  }

  void updateSoundId(String id) {
    state = state.copyWith(soundId: id);
  }

  String getName(TimerMode mode) {
    switch (mode) {
      case TimerMode.pomodoro:
        return "Pomodoro";
      case TimerMode.shortBreak:
        return "Short Break";
      case TimerMode.longBreak:
        return "Long Break";
    }
  }
}
