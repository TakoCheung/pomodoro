import 'dart:async';

import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});

enum TimerMode {
  pomodoro,
  shortBreak,
  longBreak,
}

class TimerState {
  static const int pomodoroDefaut = 1500;
  static const int longBreakDefaut = 900;
  static const int shortBreakDefaut = 600;
  final int timeRemaining;
  final bool isRunning;
  final TimerMode mode;
  final int initPomodoro;
  final int initShortBreak;
  final int initLongBreak;
  final String fontFamily;

  TimerState(
      {required this.timeRemaining,
      required this.isRunning,
      required this.mode,
      required this.initLongBreak,
      required this.initShortBreak,
      required this.initPomodoro,
      required this.fontFamily});

  TimerState copyWith(
      {int? timeRemaining,
      bool? isRunning,
      TimerMode? mode,
      int? initLongBreak,
      int? initPomodoro,
      int? initShortBreak,
      String? fontFamily}) {
    return TimerState(
        timeRemaining: timeRemaining ?? this.timeRemaining,
        isRunning: isRunning ?? this.isRunning,
        mode: mode ?? this.mode,
        initLongBreak: initLongBreak ?? longBreakDefaut,
        initPomodoro: initPomodoro ?? pomodoroDefaut,
        initShortBreak: initShortBreak ?? shortBreakDefaut,
        fontFamily: fontFamily ?? AppTextStyles.kumbhSans);
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  static const int sixty = 60;
  TimerNotifier()
      : super(TimerState(
            timeRemaining: TimerState.pomodoroDefaut,
            isRunning: false,
            mode: TimerMode.pomodoro,
            initLongBreak: TimerState.longBreakDefaut,
            initPomodoro: TimerState.pomodoroDefaut,
            initShortBreak: TimerState.shortBreakDefaut,
            fontFamily: AppTextStyles.kumbhSans));

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isRunning) {
        timer.cancel();
      } else if (state.timeRemaining > 0) {
        decrementTimer();
      } else {
        timer.cancel();
      }
    });
  }

  void decrementTimer() {
    if (state.timeRemaining > 0) {
      state = state.copyWith(timeRemaining: state.timeRemaining - 1);
    }
  }

  void pauseTimer() {
    state = state.copyWith(isRunning: false);
  }

  void toggleTimer() {
    state = state.copyWith(isRunning: !state.isRunning);
    if (state.isRunning) startTimer();
  }

  void setMode(TimerMode mode) {
    state = state.copyWith(
      mode: mode,
      timeRemaining: getInitialDuration(),
      isRunning: false,
    );
  }

  double progress() {
    return state.timeRemaining % sixty / sixty;
  }

  String timeFormatted(int time) {
    final minutes = (time ~/ sixty).toString().padLeft(2, '0');
    final secs = (time % sixty).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String minuteFormatted(int time) {
    return (time ~/ sixty).toString().padLeft(2, '0');
  }

  int getInitialDuration() {
    switch (state.mode) {
      case TimerMode.pomodoro:
        return state.initPomodoro;
      case TimerMode.shortBreak:
        return state.initShortBreak;
      case TimerMode.longBreak:
        return state.initLongBreak;
      default:
        return state.initPomodoro;
    }
  }

  updatePomodoroDuration(int value) {
    state = state.copyWith(initPomodoro: value * 60);
  }

  updateShortBreakDuration(int value) {
    state = state.copyWith(initShortBreak: value);
  }

  updateLongBreakDuration(int value) {
    state = state.copyWith(initLongBreak: value);
  }
}
