import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';

class TimerModeSwitcher {
  TimerMode mode;

  TimerModeSwitcher({this.mode = TimerMode.pomodoro});

  int getInitialDuration() {
    switch (mode) {
      case TimerMode.pomodoro:
        return 1500; // 25 minutes
      case TimerMode.shortBreak:
        return 300; // 5 minutes
      case TimerMode.longBreak:
        return 900; // 15 minutes
      default:
        return 1500;
    }
  }

  void setMode(TimerMode newMode) {
    mode = newMode;
  }
}
