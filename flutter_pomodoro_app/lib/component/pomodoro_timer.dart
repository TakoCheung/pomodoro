import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/component/timer_display.dart';
import 'package:flutter_pomodoro_app/component/timer_gearicon_button.dart';
import 'package:flutter_pomodoro_app/component/timer_mode_switch_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PomodoroTimerScreen extends ConsumerWidget {
  const PomodoroTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E213F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'pomodoro',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 45),
            TimerModeSwitcherUI(),
            SizedBox(height: 48),
            TimerDisplay(),
            SizedBox(height: 40),
            GearIconButton(),
          ],
        ),
      ),
    );
  }
}