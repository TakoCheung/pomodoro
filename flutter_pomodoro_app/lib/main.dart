import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/env_config.dart';

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
    debugPrint('main: SCRIPTURE_API_KEY present=${apiKey != null && apiKey.isNotEmpty}, BIBLE_ID=${bibleId ?? '(default)'}');
  } catch (_) {}
  // Determine debug-FAB flag from .env (if present) and override the provider so
  // the UI can read a stable value regardless of widget build timing.
  // Prefer build-time config when available. EnvConfig is intended to be
  // generated during CI or set to a safe default for local dev.
  bool enableDebugFab = EnvConfig.enableDebugFab;
  String? rawEnableDebugFab;
  try {
    rawEnableDebugFab = dotenv.env['ENABLE_DEBUG_FAB'];
    // If the .env defines a value, prefer it (useful for local overrides).
    if (rawEnableDebugFab != null) {
      enableDebugFab = rawEnableDebugFab.toLowerCase() == 'true';
    }
  } catch (_) {
    // ignore: noop
  }
  debugPrint('main: EnvConfig.enableDebugFab=${EnvConfig.enableDebugFab}, .env=$rawEnableDebugFab -> enableDebugFab=$enableDebugFab');

  runApp(ProviderScope(overrides: [enableDebugFabProvider.overrideWithValue(enableDebugFab)], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PomodoroTimerScreen());
  }
}
