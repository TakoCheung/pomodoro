import 'dart:async';
// ...existing code...

import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_magic_number.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/timer_model.dart';
export 'package:flutter_pomodoro_app/state/timer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/state/passage_id_provider.dart';
// ...existing code...

final scriptureOverlayVisibleProvider = StateProvider<bool>((ref) => false);

/// Whether to show the debug FAB. Read from .env if available; tests can override.
final enableDebugFabProvider = Provider<bool>((ref) {
  try {
    return dotenv.env['ENABLE_DEBUG_FAB']?.toLowerCase() == 'true';
  } catch (_) {
    return false;
  }
});

/// The currently shown scripture passage (if any).
final shownScriptureProvider = StateProvider<Passage?>((ref) => null);

typedef BoolCallback = bool Function();

/// Decides whether to show scripture on timer completion. By default this is
/// randomized, but tests can override this provider to force deterministic behavior.

// Always show scripture on timer completion — this is an app feature, not a
// debug-only behavior. The provider returns true unconditionally so the
// onComplete handler will display the scripture overlay (and attempt to
// fetch a passage, falling back to a local passage when needed).
final scriptureShowDeciderProvider = Provider<BoolCallback>((ref) {
  return () => true;
});

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref: ref);
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
  final Ref? ref;

  TimerNotifier({this.ref})
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
  unawaited(_handleComplete());
      }
    }
  }

  /// Test helper: trigger the onComplete callback synchronously.
  @visibleForTesting
  void triggerComplete() {
  unawaited(_handleComplete());
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
    int seconds;
    switch (mode) {
      case TimerMode.pomodoro:
        seconds = state.initPomodoro;
        break;
      case TimerMode.shortBreak:
        seconds = state.initShortBreak;
        break;
      case TimerMode.longBreak:
        seconds = state.initLongBreak;
        break;
    }
    // Debug semantics: zero minutes selected means "1 second left" for fast flows.
    return seconds == 0 ? 1 : seconds;
  }

  void updateSettings(LocalSettings localSettings) {
  // If debug mode is enabled and settings were zeroed, keep zero seconds.
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

  Future<void> _handleComplete() async {
    // If ref is not provided (legacy tests constructing TimerNotifier directly),
    // skip scripture logic entirely.
    if (ref == null) return;
    final r = ref!;
    final show = r.read(scriptureShowDeciderProvider)();
    if (!show) return;
    debugPrint('TimerNotifier: onComplete triggered');
    try {
      final repo = r.read(scriptureRepositoryProvider);
      final bibleId = r.read(bibleIdProvider);
      // Helper to lazily generate a passage id only when needed.
      String _generateIdAvoidingRepeat() {
        final gen = r.read(nextPassageIdProvider);
        final lastId = r.read(lastPassageIdProvider);
        String id = gen();
        int tries = 0;
        while (lastId != null && id == lastId && tries < 10) {
          id = gen();
          tries++;
        }
        return id;
      }
      final mode = state.mode;
      Passage passage;
      switch (mode) {
        case TimerMode.pomodoro:
          final generatedId = _generateIdAvoidingRepeat();
          passage = await repo.fetchAndCacheRandomPassage(bibleId: bibleId, passageIds: [generatedId]);
          // Persist the id we used to reduce immediate repeats.
          r.read(lastPassageIdProvider.notifier).state = generatedId;
          break;
        case TimerMode.shortBreak:
        case TimerMode.longBreak:
          final cached = repo.cachedPassage;
          if (cached != null) {
            debugPrint('TimerNotifier: using cached passage ${cached.reference} for break');
            passage = cached;
          } else {
            debugPrint('TimerNotifier: no cache for today; fetching once for break');
            final generatedId = _generateIdAvoidingRepeat();
            passage = await repo.getRandomPassageOncePerDay(bibleId: bibleId, passageIds: [generatedId]);
            r.read(lastPassageIdProvider.notifier).state = generatedId;
          }
          break;
      }
      debugPrint('TimerNotifier: fetched passage ${passage.reference}');
      r.read(shownScriptureProvider.notifier).state = passage;
      r.read(scriptureOverlayVisibleProvider.notifier).state = true;
    } catch (e) {
      debugPrint('TimerNotifier: fetch failed, using fallback: $e');
      final fallback = Passage(
        reference: 'Genesis 1:1',
        text: 'In the beginning God created the heavens and the earth.',
        verses: [],
      );
      debugPrint('TimerNotifier: using fallback passage ${fallback.reference}');
      r.read(shownScriptureProvider.notifier).state = fallback;
      r.read(scriptureOverlayVisibleProvider.notifier).state = true;
    }
  }
}
