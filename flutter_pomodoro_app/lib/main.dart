import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/component/pomodoro_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PomodoroTimerScreen()
    );
  }
}
