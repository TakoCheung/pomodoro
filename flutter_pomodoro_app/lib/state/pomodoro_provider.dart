import 'dart:async';

import 'package:flutter_pomodoro_app/component/timer_mode_switch.dart';
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
  final int timeRemaining;
  final bool isRunning;
  final TimerMode mode;


  TimerState({
    required this.timeRemaining,
    required this.isRunning,
    required this.mode,
  });

  TimerState copyWith({
    int? timeRemaining,
    bool? isRunning,
    TimerMode? mode,
  }) {
    return TimerState(
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isRunning: isRunning ?? this.isRunning,
      mode: mode ?? this.mode,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  final TimerModeSwitcher _modeSwitcher = TimerModeSwitcher();

  TimerNotifier()
      : super(TimerState(
          timeRemaining: 1500, // Default to 25 minutes (1500 seconds)
          isRunning: false,
          mode: TimerMode.pomodoro,
        ));

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
    _modeSwitcher.setMode(mode);
    state = state.copyWith(
      mode: mode,
      timeRemaining: _modeSwitcher.getInitialDuration(),
      isRunning: false,
    );
  }

  double progress(){
    return state.timeRemaining % 60 / 60;
  }

  String timeFormatted() {
    final minutes = (state.timeRemaining ~/ 60).toString().padLeft(2, '0');
    final secs = (state.timeRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
