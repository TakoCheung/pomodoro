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
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/state/passage_id_provider.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/state/clock_provider.dart';
import 'package:flutter_pomodoro_app/state/active_timer_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_scheduler_provider.dart';
// import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';
// import 'package:flutter_pomodoro_app/state/alarm_haptics_providers.dart';
// import 'package:flutter_pomodoro_app/services/haptics_service.dart';
// ...existing code...

final scriptureOverlayVisibleProvider = StateProvider<bool>((ref) => false);
// Show a simple overlay when a completion is detected on cold start/resume.
final missedAlarmOverlayVisibleProvider = StateProvider<bool>((ref) => false);
// Re-entrancy guard to avoid duplicate concurrent processing; resets after completion.
final _completionInFlightProvider = StateProvider<bool>((_) => false);

/// Whether to show the debug FAB. Read from .env if available; tests can override.
// Debug FAB removed: provider no longer needed.

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
    // Clear persisted active timer and cancel scheduled alarm
    if (ref != null) {
      final r = ref!;
      unawaited(r.read(activeTimerProvider.notifier).clear());
      final alarm = r.read(alarmSchedulerProvider);
      unawaited(alarm.cancel(timerId: 'active'));
    }
  }

  void toggleTimer() {
    state = state.copyWith(isRunning: !state.isRunning);
    if (state.isRunning) {
      startTimer();
      // Persist and schedule background-resilient alarm
      if (ref != null) {
        final r = ref!;
        final now = r.read(clockProvider)();
        // Use remaining time if resuming; otherwise use initial duration.
        final remaining = state.timeRemaining;
        final int seconds = remaining > 0 ? remaining : getInitialDuration(state.mode);
        final duration = Duration(seconds: seconds);
        final endUtc = now.add(duration);
        final timerId = 'active';
        final label = state.mode.name;
        // Ensure notification permission/channel once so iOS can deliver scheduled alarms.
        try {
          final notif = r.read(notificationSchedulerProvider);
          unawaited(ensureChannelCreatedOnce(r, notif));
          unawaited(ensureNotificationPermissionOnce(r, notif, provisional: true));
        } catch (_) {}
        unawaited(r.read(activeTimerProvider.notifier).save(
              ActiveTimer(timerId: timerId, startUtc: now, endUtc: endUtc, label: label),
            ));
        final alarm = r.read(alarmSchedulerProvider);
        unawaited(alarm.scheduleExact(timerId: timerId, endUtc: endUtc));
      }
    }
  }

  void setMode(TimerMode mode) {
    // On any explicit session (re)start, pull staged durations from LocalSettings
    // so that next sessions use the latest values without altering a running session.
    _syncDurationsFromLocalSettings();
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

  @visibleForTesting
  void setForTest({int? timeRemaining, bool? isRunning, TimerMode? mode}) {
    state = state.copyWith(
      timeRemaining: timeRemaining,
      isRunning: isRunning,
      mode: mode,
    );
  }

  /// Apply only live settings (font/color) immediately without touching
  /// session durations or timeRemaining.
  void applyLiveSettings(LocalSettings localSettings) {
    state = state.copyWith(
      fontFamily: localSettings.fontFamily,
      color: localSettings.color,
    );
  }

  /// Backward-compatible apply used by existing tests: applies both live and
  /// duration settings immediately and resets the current session.
  void updateSettings(LocalSettings localSettings) {
    state = state.copyWith(
      initPomodoro: localSettings.initPomodoro,
      initShortBreak: localSettings.initShortBreak,
      initLongBreak: localSettings.initLongBreak,
      fontFamily: localSettings.fontFamily,
      color: localSettings.color,
    );
    setMode(state.mode);
  }

  /// Apply staged durations now and reset current session (with confirmation in UI).
  void applyStagedDurationsNow() {
    _syncDurationsFromLocalSettings();
    // Reset current session using current mode and new durations.
    setMode(state.mode);
  }

  /// Pull staged durations from LocalSettings into the active timer state.
  void _syncDurationsFromLocalSettings() {
    if (ref == null) return;
    final s = ref!.read(localSettingsProvider);
    state = state.copyWith(
      initPomodoro: s.initPomodoro,
      initShortBreak: s.initShortBreak,
      initLongBreak: s.initLongBreak,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Resync on app init/resume: ensure single scheduled alarm or process overdue completion once.
  Future<void> resyncAndProcessOverdue() async {
    if (ref == null) return;
    final r = ref!;
    final at = r.read(activeTimerProvider);
    if (at == null) return;
    final now = r.read(clockProvider)();
    if (now.isBefore(at.endUtc)) {
      // Update remaining time based on persisted end time.
      final remaining = at.endUtc.difference(now).inSeconds;
      state = state.copyWith(timeRemaining: remaining > 0 ? remaining : 0, isRunning: true);
      // Restart the ticking timer to continue countdown in foreground.
      _timer?.cancel();
      if (state.timeRemaining > 0) {
        startTimer();
      }
      // Ensure an exact alarm is scheduled once.
      final alarm = r.read(alarmSchedulerProvider);
      // Ensure permission/channel before scheduling (no-op if already handled)
      try {
        final notif = r.read(notificationSchedulerProvider);
        await ensureChannelCreatedOnce(r, notif);
        await ensureNotificationPermissionOnce(r, notif, provisional: true);
      } catch (_) {}
      await alarm.cancel(timerId: at.timerId);
      await alarm.scheduleExact(
          timerId: at.endUtc.isAfter(now) ? at.timerId : 'active', endUtc: at.endUtc);
      return;
    }
    // Overdue: clear and handle completion once
    await r.read(activeTimerProvider.notifier).clear();
    // Show missed overlay (UI)
    r.read(missedAlarmOverlayVisibleProvider.notifier).state = true;
    await _handleComplete();
  }

  Future<void> _handleComplete() async {
    // If ref is not provided (legacy tests constructing TimerNotifier directly),
    // skip scripture logic entirely.
    if (ref == null) return;
    final r = ref!;
    // Reentrancy guard
    final inflight = r.read(_completionInFlightProvider);
    if (inflight == true) return;
    r.read(_completionInFlightProvider.notifier).state = true;
    // Ensure timer is stopped and persistence cleared on completion.
    _timer?.cancel();
    state = state.copyWith(isRunning: false, timeRemaining: 0);
    try {
      await r.read(activeTimerProvider.notifier).clear();
    } catch (_) {}
    try {
      final alarm = r.read(alarmSchedulerProvider);
      await alarm.cancel(timerId: 'active');
    } catch (_) {}
    final show = r.read(scriptureShowDeciderProvider)();
    if (!show) return;
    debugPrint('TimerNotifier: onComplete triggered');
    try {
      final repo = r.read(scriptureRepositoryProvider);
      final bibleId = r.read(bibleIdProvider);
      // Helper to lazily generate a passage id only when needed.
      String generateIdAvoidingRepeat() {
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
          final generatedId = generateIdAvoidingRepeat();
          passage =
              await repo.fetchAndCacheRandomPassage(bibleId: bibleId, passageIds: [generatedId]);
          // Persist the id we used to reduce immediate repeats.
          r.read(lastPassageIdProvider.notifier).state = generatedId;
          break;
        case TimerMode.shortBreak:
        case TimerMode.longBreak:
          final cached = repo.cachedPassageForBible(bibleId);
          if (cached != null) {
            debugPrint('TimerNotifier: using cached passage ${cached.reference} for break');
            passage = cached;
          } else {
            debugPrint('TimerNotifier: no cache for today; fetching once for break');
            final generatedId = generateIdAvoidingRepeat();
            passage = await repo.selectPassageForBreak(bibleId: bibleId, passageIds: [generatedId]);
            r.read(lastPassageIdProvider.notifier).state = generatedId;
          }
          break;
      }
      debugPrint('TimerNotifier: fetched passage ${passage.reference}');
      r.read(shownScriptureProvider.notifier).state = passage;
      // Decide whether to show overlay or system notification based on app state and user pref
      final settings = r.read(localSettingsProvider);
      final isFg = r.read(isAppForegroundProvider);
      final overlayVisible = r.read(scriptureOverlayVisibleProvider);
      final notificationsEnabled = settings.notificationsEnabled;
      if (isFg && notificationsEnabled) {
        // Foreground: show scripture overlay only; banner will be shown on notification tap.
        r.read(scriptureOverlayVisibleProvider.notifier).state = true;
      } else if (notificationsEnabled && !overlayVisible) {
        final scheduler = r.read(notificationSchedulerProvider);
        // Ensure initialized & channel exists; do not mutate providers here
        await ensureChannelCreatedOnce(r, scheduler);
        // Ask for permission once per app lifecycle
        final granted = await ensureNotificationPermissionOnce(r, scheduler, provisional: true);
        if (granted) {
          final res = NotificationContentBuilder.build(
            bibleId: bibleId,
            passageId: r.read(lastPassageIdProvider) ?? 'unknown',
            passage: passage,
            maxLen: 140,
          );
          await scheduler.show(
            channelId: NotificationChannel.alarmId,
            title: res.title,
            body: res.body,
            payload: res.payload,
          );
          r.read(lastNotificationPostedProvider.notifier).state = true;
        } else {
          // Record a non-blocking message by setting overlay with fallback hint (no-op UI here)
        }
      }
      // If notifications are disabled, still show overlay in foreground; in background do nothing.
      if (isFg && !notificationsEnabled) {
        r.read(scriptureOverlayVisibleProvider.notifier).state = true;
      }
    } catch (e) {
      debugPrint('TimerNotifier: fetch failed, using fallback: $e');
      final fallback = Passage(
        reference: 'Genesis 1:1',
        text: 'In the beginning God created the heavens and the earth.',
        verses: [],
      );
      debugPrint('TimerNotifier: using fallback passage ${fallback.reference}');
      r.read(shownScriptureProvider.notifier).state = fallback;
      final settings = r.read(localSettingsProvider);
      final isFg = r.read(isAppForegroundProvider);
      if (isFg) {
        // Foreground: show scripture overlay only; banner will be shown on notification tap.
        r.read(scriptureOverlayVisibleProvider.notifier).state = true;
      } else if (settings.notificationsEnabled) {
        final scheduler = r.read(notificationSchedulerProvider);
        await ensureChannelCreatedOnce(r, scheduler);
        final granted = await ensureNotificationPermissionOnce(r, scheduler, provisional: true);
        if (granted) {
          final res = NotificationContentBuilder.fallback();
          await scheduler.show(
            channelId: NotificationChannel.alarmId,
            title: res.title,
            body: res.body,
            payload: res.payload,
          );
          r.read(lastNotificationPostedProvider.notifier).state = true;
        }
      }
    } finally {
      // Allow future completion events (e.g., next session) while still preventing concurrent dupes.
      r.read(_completionInFlightProvider.notifier).state = false;
    }
  }
}
