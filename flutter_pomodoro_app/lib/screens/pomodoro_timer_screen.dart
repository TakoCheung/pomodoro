import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_mode_switch_ui.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PomodoroTimerScreen extends ConsumerWidget {
  const PomodoroTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'pomodoro',
              style: TextStyle(
                fontSize: AppTextStyles.title,
                color: AppColors.lightBlueGray,
                fontWeight: FontWeight.bold
              ),
            ),
            Flexible(child:  SizedBox(height: 45,)),
            TimerModeSwitcherUI(),
            Flexible(child: SizedBox(height: 48)),
            TimerDisplay(),
            Flexible(child: SizedBox(height: 40)),
            GearIconButton(),
          ],
        ),
      ),
    );
  }
}