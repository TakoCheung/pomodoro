import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart'
    show sharedPreferencesProvider;

/// App-level representation of notification authorization.
enum NotifAuthStatus {
  notDetermined,
  authorized,
  provisional,
  denied,
  limited,
  permanentlyDenied,
}

extension NotifAuthStatusCodec on NotifAuthStatus {
  String get asString => toString().split('.').last;
  static NotifAuthStatus parse(String? v) {
    switch (v) {
      case 'authorized':
        return NotifAuthStatus.authorized;
      case 'provisional':
        return NotifAuthStatus.provisional;
      case 'denied':
        return NotifAuthStatus.denied;
      case 'limited':
        return NotifAuthStatus.limited;
      case 'permanentlyDenied':
        return NotifAuthStatus.permanentlyDenied;
      case 'notDetermined':
      default:
        return NotifAuthStatus.notDetermined;
    }
  }
}

/// Platform snapshot used to decide Android 13+ runtime permission path.
class PlatformSnapshot {
  final TargetPlatform platform;
  final int? androidSdkInt;
  const PlatformSnapshot({required this.platform, this.androidSdkInt});

  bool get isAndroid => platform == TargetPlatform.android;
  bool get isIOS => platform == TargetPlatform.iOS;
  bool get android13Plus => isAndroid && (androidSdkInt ?? 0) >= 33;
}

final platformSnapshotProvider = Provider<PlatformSnapshot>((_) {
  // Default: best-effort without SDK int; tests can override.
  return PlatformSnapshot(platform: defaultTargetPlatform, androidSdkInt: null);
});

// Rationale sheet visibility during this app lifecycle.
final notifRationaleVisibleProvider = StateProvider<bool>((_) => false);
// Controls whether coordinator auto-initializes on app startup (disabled in unit/widget tests).
final permissionAutostartProvider = StateProvider<bool>((_) => true);

// Public badge text for quick status read in UI.
final permissionStatusTextProvider = Provider<String>((ref) {
  final s = ref.watch(permissionCoordinatorProvider);
  switch (s) {
    case NotifAuthStatus.authorized:
    case NotifAuthStatus.provisional:
      return 'On';
    case NotifAuthStatus.notDetermined:
    case NotifAuthStatus.denied:
    case NotifAuthStatus.limited:
    case NotifAuthStatus.permanentlyDenied:
      return 'Off';
  }
});

class PermissionCoordinator extends StateNotifier<NotifAuthStatus> {
  PermissionCoordinator(this.ref)
      : _scheduler = ref.read(notificationSchedulerProvider),
        _platform = ref.read(platformSnapshotProvider),
        super(NotifAuthStatus.notDetermined);

  final Ref ref;
  SharedPreferences? _prefs;
  final NotificationScheduler _scheduler;
  final PlatformSnapshot _platform;

  static const _kFirstLaunchSeen = 'first_launch_seen';
  static const _kAuthStatus = 'notif_auth_status';
  static const _kPromptLastShownAt = 'notif_prompt_last_shown_at';
  static const _kPromptDeferredCount = 'notif_prompt_deferred_count';

  Future<void> _hydrateFromPrefs() async {
    _prefs ??= await ref.read(sharedPreferencesProvider.future);
    final cached = _prefs!.getString(_kAuthStatus);
    state = NotifAuthStatusCodec.parse(cached);
  }

  // Called once after app boot. Shows rationale sheet on first launch if status is notDetermined.
  Future<void> initialize() async {
    await _hydrateFromPrefs();
    final seen = _prefs!.getBool(_kFirstLaunchSeen) ?? false;
    if (!seen) {
      // Mark seen and show rationale if status undecided.
      await _prefs!.setBool(_kFirstLaunchSeen, true);
      if (state == NotifAuthStatus.notDetermined) {
        ref.read(notifRationaleVisibleProvider.notifier).state = true;
      }
    } else {
      // Respect cached status; no repeat rationale in same lifecycle.
      ref.read(notifRationaleVisibleProvider.notifier).state = false;
    }
  }

  // User chose "Later".
  Future<void> deferPrompt() async {
    await _hydrateFromPrefs();
    final c = _prefs!.getInt(_kPromptDeferredCount) ?? 0;
    await _prefs!.setInt(_kPromptDeferredCount, c + 1);
    await _prefs!.setInt(_kPromptLastShownAt, DateTime.now().millisecondsSinceEpoch);
    ref.read(notifRationaleVisibleProvider.notifier).state = false;
  }

  // Map scheduler result to app status; supports iOS provisional and Android 13 runtime permission.
  Future<void> requestPermission({bool provisional = false}) async {
    // Respect permanentlyDenied; do not prompt.
    if (state == NotifAuthStatus.permanentlyDenied) return;

    if (_platform.isAndroid && !_platform.android13Plus) {
      // Pre-13: ensure channel and treat as authorized.
      await ensureChannelCreatedOnce(ref, _scheduler);
      await _persistStatus(NotifAuthStatus.authorized);
      ref.read(notifRationaleVisibleProvider.notifier).state = false;
      return;
    }

    ref.read(notifRationaleVisibleProvider.notifier).state = false;

    final granted = await _scheduler.requestPermission(provisional: provisional);
    NotifAuthStatus newStatus;
    if (_platform.isIOS && provisional && granted) {
      newStatus = NotifAuthStatus.provisional;
    } else {
      newStatus = granted ? NotifAuthStatus.authorized : NotifAuthStatus.denied;
    }
    await _persistStatus(newStatus);
    // Ensure it's hidden in case the scheduler returned synchronously on some platforms.
    ref.read(notifRationaleVisibleProvider.notifier).state = false;
  }

  Future<void> _persistStatus(NotifAuthStatus s) async {
    await _hydrateFromPrefs();
    state = s;
    await _prefs!.setString(_kAuthStatus, s.asString);
  }

  // Simulate opening system settings. Exposed for mocking in tests.
  void openSystemSettings() {
    // No-op in app; tests override this via [systemSettingsOpenerProvider].
    ref.read(systemSettingsOpenerProvider).call();
  }
}

final systemSettingsOpenerProvider = Provider<VoidCallback>((_) => () {});

final permissionCoordinatorProvider = StateNotifierProvider<PermissionCoordinator, NotifAuthStatus>(
    (ref) => PermissionCoordinator(ref));

/// Initializes the coordinator with concrete dependencies.
final permissionCoordinatorInitializerProvider = Provider<PermissionCoordinator?>((ref) {
  // Coordinator is always available now; initialization triggers on app boot.
  return ref.read(permissionCoordinatorProvider.notifier);
});
