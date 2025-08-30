import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PomodoroTimerScreen());
  }
}
