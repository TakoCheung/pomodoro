// Lightweight shared types for timer-related code.
// Extracted to break circular imports between providers.
enum TimerMode {
  pomodoro,
  shortBreak,
  longBreak,
}

class TimerDefaults {
  /// Default durations in seconds
  static const int pomodoroDefault = 1500; // 25 * 60
  static const int shortBreakDefault = 300; // 5 * 60
  static const int longBreakDefault = 900; // 15 * 60
}
