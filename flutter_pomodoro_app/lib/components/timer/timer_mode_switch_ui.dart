import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
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
      width: 370,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildModeButton(
            context: context,
            label: 'pomodoro',
            isActive: timerState.mode == TimerMode.pomodoro,
            onPressed: () => timerNotifier.setMode(TimerMode.pomodoro),
          ),
          _buildModeButton(
            context: context,
            label: 'short break',
            isActive: timerState.mode == TimerMode.shortBreak,
            onPressed: () => timerNotifier.setMode(TimerMode.shortBreak),
          ),
          _buildModeButton(
            context: context,
            label: 'long break',
            isActive: timerState.mode == TimerMode.longBreak,
            onPressed: () => timerNotifier.setMode(TimerMode.longBreak),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Center(
      // child: Padding(
        // padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: isActive ? AppColors.lightBlue : Colors.transparent,
            maximumSize: const Size(120, 48),
            minimumSize: const Size(120, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isActive ? Colors.black : Colors.white.withOpacity(0.5),
              fontFamily: 'RobotoSlab',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      // ),
    );
  }
}

