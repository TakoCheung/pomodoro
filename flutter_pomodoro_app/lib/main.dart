import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/component/pomodoro_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'KumbhSans'),
        ),
      ),
      home: const PomodoroTimerScreen()
    );
  }
}
