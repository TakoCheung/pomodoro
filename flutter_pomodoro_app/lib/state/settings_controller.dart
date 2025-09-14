import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/settings_persistence.dart';

/// An immutable snapshot of all user settings. UI binds to [staged] while the
/// app reads only the committed values via [LocalSettings].
class AppSettings {
  // Durations (seconds)
  final int initPomodoro;
  final int initShortBreak;
  final int initLongBreak;
  // Visuals
  final String fontFamily;
  final Color color;
  // Misc
  final bool debugMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final String soundId;
  // Scripture
  final String bibleVersionName;
  final String? bibleVersionId;

  const AppSettings({
    required this.initPomodoro,
    required this.initShortBreak,
    required this.initLongBreak,
    required this.fontFamily,
    required this.color,
    required this.debugMode,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.soundId,
    required this.bibleVersionName,
    required this.bibleVersionId,
  });

  AppSettings copyWith({
    int? initPomodoro,
    int? initShortBreak,
    int? initLongBreak,
    String? fontFamily,
    Color? color,
    bool? debugMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? soundId,
    String? bibleVersionName,
    String? bibleVersionId,
  }) {
    return AppSettings(
      initPomodoro: initPomodoro ?? this.initPomodoro,
      initShortBreak: initShortBreak ?? this.initShortBreak,
      initLongBreak: initLongBreak ?? this.initLongBreak,
      fontFamily: fontFamily ?? this.fontFamily,
      color: color ?? this.color,
      debugMode: debugMode ?? this.debugMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundId: soundId ?? this.soundId,
      bibleVersionName: bibleVersionName ?? this.bibleVersionName,
      bibleVersionId: bibleVersionId ?? this.bibleVersionId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.initPomodoro == initPomodoro &&
        other.initShortBreak == initShortBreak &&
        other.initLongBreak == initLongBreak &&
        other.fontFamily == fontFamily &&
        other.color == color &&
        other.debugMode == debugMode &&
        other.notificationsEnabled == notificationsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.hapticsEnabled == hapticsEnabled &&
        other.soundId == soundId &&
        other.bibleVersionName == bibleVersionName &&
        other.bibleVersionId == bibleVersionId;
  }

  @override
  int get hashCode => Object.hash(
      initPomodoro,
      initShortBreak,
      initLongBreak,
      fontFamily,
      color,
      debugMode,
      notificationsEnabled,
      soundEnabled,
      hapticsEnabled,
      soundId,
      bibleVersionName,
      bibleVersionId);

  static AppSettings fromLocal(LocalSettings s) => AppSettings(
        initPomodoro: s.initPomodoro,
        initShortBreak: s.initShortBreak,
        initLongBreak: s.initLongBreak,
        fontFamily: s.fontFamily,
        color: s.color,
        debugMode: s.debugMode,
        notificationsEnabled: s.notificationsEnabled,
        soundEnabled: s.soundEnabled,
        hapticsEnabled: s.hapticsEnabled,
        soundId: s.soundId,
        bibleVersionName: s.bibleVersionName,
        bibleVersionId: s.bibleVersionId,
      );
}

class SettingsControllerState {
  final AppSettings committed;
  final AppSettings staged;

  const SettingsControllerState({required this.committed, required this.staged});

  bool get isDirty => committed != staged;

  SettingsControllerState copyWith({AppSettings? committed, AppSettings? staged}) {
    return SettingsControllerState(
      committed: committed ?? this.committed,
      staged: staged ?? this.staged,
    );
  }
}

/// Abstraction for reading/writing committed settings.
abstract class SettingsRepository {
  AppSettings getCommitted();
  Future<void> persistCommitted(AppSettings next);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final Ref ref;
  SettingsRepositoryImpl(this.ref);

  @override
  AppSettings getCommitted() {
    final persistence = ref.read(settingsPersistenceProvider);
    // If persistence is available, prefer it for a fresh snapshot to avoid
    // stale values in long-lived LocalSettings during tests/integration.
    if (persistence != null) {
      final loaded = persistence.loadOrDefaults();
      return AppSettings.fromLocal(loaded);
    }
    // Fallback to in-memory committed copy.
    final local = ref.read(localSettingsProvider);
    return AppSettings.fromLocal(local);
  }

  @override
  Future<void> persistCommitted(AppSettings next) async {
    // Merge all fields into the full LocalSettings and persist explicitly.
    final persistence = ref.read(settingsPersistenceProvider);
    final current = ref.read(localSettingsProvider);
    final merged = current.copyWith(
      initPomodoro: next.initPomodoro,
      initShortBreak: next.initShortBreak,
      initLongBreak: next.initLongBreak,
      fontFamily: next.fontFamily,
      color: next.color,
      debugMode: next.debugMode,
      notificationsEnabled: next.notificationsEnabled,
      soundEnabled: next.soundEnabled,
      hapticsEnabled: next.hapticsEnabled,
      soundId: next.soundId,
      bibleVersionName: next.bibleVersionName,
      bibleVersionId: next.bibleVersionId,
    );
    // Update the in-memory committed provider first so the app uses committed.
    ref.read(localSettingsProvider.notifier).replace(merged);
    await persistence?.persist(merged);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref);
});

class SettingsController extends StateNotifier<SettingsControllerState> {
  final Ref ref;
  SettingsController(this.ref)
      : super(
          SettingsControllerState(
            committed: AppSettings.fromLocal(ref.read(localSettingsProvider)),
            staged: AppSettings.fromLocal(ref.read(localSettingsProvider)),
          ),
        );

  void loadCommitted() {
    final repo = ref.read(settingsRepositoryProvider);
    final committed = repo.getCommitted();
    state = SettingsControllerState(committed: committed, staged: committed);
  }

  void stageFromCommitted() {
    // Ensure we start from the latest committed snapshot (repo-backed) to avoid
    // stale in-memory values.
    final repo = ref.read(settingsRepositoryProvider);
    final committed = repo.getCommitted();
    state = state.copyWith(committed: committed, staged: committed);
  }

  void updateStaged({
    // Durations (seconds)
    int? initPomodoro,
    int? initShortBreak,
    int? initLongBreak,
    // Visuals
    String? fontFamily,
    Color? color,
    // Misc
    bool? debugMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? soundId,
    // Scripture
    String? bibleVersionName,
    String? bibleVersionId,
  }) {
    final next = state.staged.copyWith(
      initPomodoro: initPomodoro,
      initShortBreak: initShortBreak,
      initLongBreak: initLongBreak,
      fontFamily: fontFamily,
      color: color,
      debugMode: debugMode,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      hapticsEnabled: hapticsEnabled,
      soundId: soundId,
      bibleVersionName: bibleVersionName,
      bibleVersionId: bibleVersionId,
    );
    state = state.copyWith(staged: next);
  }

  Future<void> apply() async {
    final repo = ref.read(settingsRepositoryProvider);
    final next = state.staged;
    await repo.persistCommitted(next);
    // After persisting, treat staged as the new committed.
    state = state.copyWith(committed: next, staged: next);
  }

  void revert() {
    // Drop staged changes and refresh committed from the repository.
    final repo = ref.read(settingsRepositoryProvider);
    final committed = repo.getCommitted();
    state = state.copyWith(committed: committed, staged: committed);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsControllerState>((ref) {
  return SettingsController(ref);
});
