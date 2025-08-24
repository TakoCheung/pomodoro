import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_magic_number.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/timer_model.dart';
export 'package:flutter_pomodoro_app/state/timer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';

final scriptureOverlayVisibleProvider = StateProvider<bool>((ref) => false);

/// The currently shown scripture passage (if any).
final shownScriptureProvider = StateProvider<Passage?>((ref) => null);

typedef BoolCallback = bool Function();

/// Decides whether to show scripture on timer completion. By default this is
/// randomized, but tests can override this provider to force deterministic behavior.
final scriptureShowDeciderProvider = Provider<BoolCallback>((ref) {
  final rng = Random();
  return () => rng.nextBool();
});

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  // Note: randomness and repository are part of the onComplete behavior. We capture
  // them here so the TimerNotifier can trigger the side-effect when the timer ends.
  return TimerNotifier(onComplete: () async {
    // Randomly decide whether to show scripture on timer end. Read repository lazily
    // at callback time so tests or environments without SCRIPTURE_API_KEY don't
    // fail at provider creation.
  final show = ref.read(scriptureShowDeciderProvider)();
    if (!show) return;
    try {
      final repo = ref.read(scriptureRepositoryProvider);
      final passage = await repo.getRandomPassageOncePerDay(bibleId: 'eng-ESV', passageIds: ['GEN.1.1']);
      ref.read(shownScriptureProvider.notifier).state = passage;
      ref.read(scriptureOverlayVisibleProvider.notifier).state = true;
    } catch (_) {
      // ignore fetch errors for now
    }
  });
});

class TimerState {
  // Backwards-compatible constants used by existing tests.
  static const int pomodoroDefaut = TimerDefaults.pomodoroDefault;
  static const int shortBreakDefaut = TimerDefaults.shortBreakDefault;
  static const int longBreakDefaut = TimerDefaults.longBreakDefault;
  final int timeRemaining;
  final bool isRunning;
  final TimerMode mode;
  final int initPomodoro;
  final int initShortBreak;
  final int initLongBreak;
  final String fontFamily;
  final Color color;

  TimerState(
      {required this.timeRemaining,
      required this.isRunning,
      required this.mode,
      required this.initLongBreak,
      required this.initShortBreak,
      required this.initPomodoro,
      required this.fontFamily,
      required this.color});

  TimerState copyWith(
      {int? timeRemaining,
      bool? isRunning,
      TimerMode? mode,
      int? initLongBreak,
      int? initPomodoro,
      int? initShortBreak,
      String? fontFamily,
      Color? color}) {
    return TimerState(
        timeRemaining: timeRemaining ?? this.timeRemaining,
        isRunning: isRunning ?? this.isRunning,
        mode: mode ?? this.mode,
        initLongBreak: initLongBreak ?? this.initLongBreak,
        initPomodoro: initPomodoro ?? this.initPomodoro,
        initShortBreak: initShortBreak ?? this.initShortBreak,
        fontFamily: fontFamily ?? this.fontFamily,
        color: color ?? this.color);
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  final void Function()? onComplete;

  TimerNotifier({this.onComplete})
      : super(TimerState(
            timeRemaining: TimerDefaults.pomodoroDefault,
            isRunning: false,
            mode: TimerMode.pomodoro,
            initLongBreak: TimerDefaults.longBreakDefault,
            initPomodoro: TimerDefaults.pomodoroDefault,
            initShortBreak: TimerDefaults.shortBreakDefault,
            fontFamily: AppTextStyles.kumbhSans,
            color: AppColors.orangeRed));
  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      final newRemaining = state.timeRemaining - 1;
      state = state.copyWith(timeRemaining: newRemaining);
      if (newRemaining == 0) {
        try {
          onComplete?.call();
        } catch (_) {}
      }
    }
  }

  /// Test helper: trigger the onComplete callback synchronously.
  @visibleForTesting
  void triggerComplete() {
    try {
      onComplete?.call();
    } catch (_) {}
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
      timeRemaining: getInitialDuration(mode),
      isRunning: false,
    );
  }

  double progress() {
    return state.timeRemaining % AppMagicNumber.sixty / AppMagicNumber.sixty;
  }

  String timeFormatted(int time) {
    final minutes = (time ~/ AppMagicNumber.sixty).toString().padLeft(2, '0');
    final secs = (time % AppMagicNumber.sixty).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String minuteFormatted(int time) {
    return (time ~/ AppMagicNumber.sixty).toString().padLeft(2, '0');
  }

  int getInitialDuration(TimerMode mode) {
    switch (mode) {
      case TimerMode.pomodoro:
        return state.initPomodoro;
      case TimerMode.shortBreak:
        return state.initShortBreak;
      case TimerMode.longBreak:
        return state.initLongBreak;
    }
  }

  updateSettings(LocalSettings localSettings) {
    state = state.copyWith(
        initPomodoro: localSettings.initPomodoro,
        initLongBreak: localSettings.initLongBreak,
        initShortBreak: localSettings.initShortBreak,
        fontFamily: localSettings.fontFamily,
        color: localSettings.color);
    setMode(state.mode);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
