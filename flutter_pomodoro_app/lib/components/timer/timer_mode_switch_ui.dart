import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerModeSwitcherUI extends ConsumerWidget {
  const TimerModeSwitcherUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.watch(timerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cobalt,
        borderRadius: BorderRadius.circular(31.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      width: 373,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildModeButton(
              context: context,
              label: 'pomodoro',
              isActive: timerState.mode == TimerMode.pomodoro,
              onPressed: () => timerNotifier.setMode(TimerMode.pomodoro),
              state: timerState),
          _buildModeButton(
              context: context,
              label: 'short break',
              isActive: timerState.mode == TimerMode.shortBreak,
              onPressed: () => timerNotifier.setMode(TimerMode.shortBreak),
              state: timerState),
          _buildModeButton(
              context: context,
              label: 'long break',
              isActive: timerState.mode == TimerMode.longBreak,
              onPressed: () => timerNotifier.setMode(TimerMode.longBreak),
              state: timerState),
        ],
      ),
    );
  }

  Widget _buildModeButton(
      {required BuildContext context,
      required String label,
      required bool isActive,
      required VoidCallback onPressed,
      required TimerState state}) {
    return Center(
      // child: Padding(
      // padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isActive ? state.color : Colors.transparent,
          maximumSize: const Size(120, 48),
          minimumSize: const Size(120, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTextStyles.bodyFontSize,
            color: isActive ? AppColors.darkBlue : AppColors.lightBlueGray,
            fontFamily: state.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // ),
    );
  }
}
