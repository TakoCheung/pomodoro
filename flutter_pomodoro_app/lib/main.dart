import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';

Future<void> main() async {
  try {
    await dotenv.load();
  } catch (e) {
    // If there's no .env (common in CI/tests), continue without failing.
  }
  // Determine debug-FAB flag from .env (if present) and override the provider so
  // the UI can read a stable value regardless of widget build timing.
  bool enableDebugFab = false;
  try {
    enableDebugFab = dotenv.env['ENABLE_DEBUG_FAB']?.toLowerCase() == 'true';
  } catch (_) {
    enableDebugFab = false;
  }

  runApp(ProviderScope(overrides: [enableDebugFabProvider.overrideWithValue(enableDebugFab)], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PomodoroTimerScreen());
  }
}
