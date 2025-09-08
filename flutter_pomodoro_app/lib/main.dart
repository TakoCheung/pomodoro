import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pomodoro_app/state/settings_persistence.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';
import 'package:flutter_pomodoro_app/services/flutter_local_notifications_scheduler.dart';
import 'package:flutter_pomodoro_app/state/deeplink_handler.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_haptics_providers.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/permission_coordinator.dart';
import 'package:flutter_pomodoro_app/state/alarm_scheduler_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro_app/services/alarm_scheduler.dart';
// import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
// import 'package:flutter_pomodoro_app/env_config.dart';

Future<void> main() async {
  try {
    // Explicitly request the `.env` file in the project root so we don't
    // depend on platform defaults or cwd quirks when running from different
    // working directories.
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If there's no .env (common in CI/tests), continue without failing.
  }
  // Debug: confirm env presence without leaking secrets
  try {
    final apiKey = dotenv.env['SCRIPTURE_API_KEY'];
    final bibleId = dotenv.env['BIBLE_ID'];
    debugPrint(
        'main: SCRIPTURE_API_KEY present=${apiKey != null && apiKey.isNotEmpty}, BIBLE_ID=${bibleId ?? '(default)'}');
  } catch (_) {}
  // Enable local notifications/alarm scheduling by default for real runs.
  // You can disable explicitly by setting ENABLE_LOCAL_NOTIFICATIONS=false in .env
  final enableLocalNotifications =
      dotenv.env['ENABLE_LOCAL_NOTIFICATIONS']?.toLowerCase() != 'false';
  final overrides = <Override>[
    if (enableLocalNotifications)
      notificationSchedulerProvider.overrideWithValue(
        FlutterLocalNotificationsScheduler(),
      ),
    if (enableLocalNotifications)
      alarmSchedulerProvider.overrideWithValue(
        FlutterLocalNotificationsAlarmScheduler(FlutterLocalNotificationsPlugin()),
      ),
  ];
  runApp(ProviderScope(overrides: overrides, child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  LifecycleObserver? _observer;

  @override
  void initState() {
    super.initState();
    // Attach lifecycle observer to keep foreground/background state accurate.
    _observer = LifecycleObserver(ref, onChange: (ref, state) {
      if (state == AppLifecycleState.resumed) {
        // Reschedule active timers or process overdue completion once
        ref.read(timerProvider.notifier).resyncAndProcessOverdue();
      }
    });
    WidgetsBinding.instance.addObserver(_observer!);
    // Prompt notification permission at first launch: show rationale, then OS sheet upon accept.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auto = ref.read(permissionAutostartProvider);
      if (auto) {
        ref.read(permissionCoordinatorProvider.notifier).initialize();
      }
    });
    // Handle notification taps: show scripture overlay and stop any ongoing alarm.
    DeepLinkDispatcher.onNotificationTap = (payload) {
      // Only one action for now: open timer/scripture overlay.
      final action = payload['action'] as String?;
      if (action == null || action == 'open_timer') {
        try {
          // Show only the banner with verse when user taps the notification.
          ref.read(scriptureOverlayVisibleProvider.notifier).state = false;
          ref.read(alarmBannerVisibleProvider.notifier).state = true;
          // Stop any ongoing alarm sound, banner will be visible.
          final alarm = ref.read(alarmServiceProvider);
          alarm.stop();
        } catch (_) {}
      }
    };
  }

  @override
  void dispose() {
    if (_observer != null) {
      WidgetsBinding.instance.removeObserver(_observer!);
    }
    // Clear handler to avoid leaks in hot reload scenarios.
    DeepLinkDispatcher.onNotificationTap = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure settings are hydrated/persisted at startup; the bool return isn't used.
    ref.watch(settingsPersistenceInitializerProvider);
    // Also resync once on first frame to handle cold-start overdue detection.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerProvider.notifier).resyncAndProcessOverdue();
    });
    return const MaterialApp(home: PomodoroTimerScreen());
  }
}
