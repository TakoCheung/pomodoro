import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localSettingsProvider =
    StateNotifierProvider<LocalSettingsNotifier, LocalSettings>((ref) {
  final globalSettings = ref.read(timerProvider);
  return LocalSettingsNotifier(
    LocalSettings(
      initPomodoro: globalSettings.initPomodoro,
      initShortBreak: globalSettings.initShortBreak,
      initLongBreak: globalSettings.initLongBreak,
      fontFamily: globalSettings.fontFamily,
      color: globalSettings.color,
    ),
  );
});

class LocalSettings {
  int initPomodoro;
  int initShortBreak;
  int initLongBreak;
  String fontFamily;
  Color color;

  LocalSettings({
    required this.initPomodoro,
    required this.initShortBreak,
    required this.initLongBreak,
    required this.fontFamily,
    required this.color,
  });

  LocalSettings copyWith(
      {int? initPomodoro,
      int? initLongBreak,
      int? initShortBreak,
      String? fontFamily,
      Color? color}) {
    return LocalSettings(
        initLongBreak: initLongBreak ?? this.initLongBreak,
        initPomodoro: initPomodoro ?? this.initPomodoro,
        initShortBreak: initShortBreak ?? this.initShortBreak,
        fontFamily: fontFamily ?? this.fontFamily,
        color: color ?? this.color);
  }
}

class LocalSettingsNotifier extends StateNotifier<LocalSettings> {
  LocalSettingsNotifier(super.state);

  void updateFont(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
  }

  void updateColor(Color color) {
    state = state.copyWith(color: color);
  }
}
