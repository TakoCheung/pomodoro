import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pomodoro_app/state/settings_persistence.dart';
import 'package:flutter_pomodoro_app/state/app_lifecycle_provider.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/services/flutter_local_notifications_scheduler.dart';
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
  // Conditionally enable real local notifications via env flag to keep tests stable.
  final enableLocalNotifications =
      dotenv.env['ENABLE_LOCAL_NOTIFICATIONS']?.toLowerCase() == 'true';
  final overrides = <Override>[
    if (enableLocalNotifications)
      notificationSchedulerProvider.overrideWithValue(
        FlutterLocalNotificationsScheduler(),
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
    _observer = LifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_observer!);
  }

  @override
  void dispose() {
    if (_observer != null) {
      WidgetsBinding.instance.removeObserver(_observer!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure settings are hydrated/persisted at startup; the bool return isn't used.
    ref.watch(settingsPersistenceInitializerProvider);
    return const MaterialApp(home: PomodoroTimerScreen());
  }
}
