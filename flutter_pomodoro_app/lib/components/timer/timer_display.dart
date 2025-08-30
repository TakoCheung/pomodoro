import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 410,
              height: 410,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [AppColors.midnightNavy, AppColors.twilightBlue],
                      transform: GradientRotation(0.785398)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shawdowBlue,
                      spreadRadius: 0,
                      blurRadius: 100,
                      offset: Offset(-50, -50),
                    ),
                    BoxShadow(
                      color: AppColors.shawdowDarkBlue,
                      spreadRadius: 0,
                      blurRadius: 100,
                      offset: Offset(50, 50),
                    ),
                  ]),
            ),
            Container(
              width: 373,
              height: 373,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkDarkBlue,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4)),
                  ]),
            ),
            SizedBox(
              width: 339,
              height: 339,
              child: CircularProgressIndicator(
                strokeAlign: BorderSide.strokeAlignCenter,
                value: ref.read(timerProvider.notifier).progress(),
                strokeWidth: 11,
                valueColor:
                    AlwaysStoppedAnimation<Color>(timerState.color),
                backgroundColor: Colors.transparent,
                strokeCap: StrokeCap.round,
              ),
            ),
            // Timer text and button
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  key: const Key('timer_text'),
                  ref.read(timerProvider.notifier).timeFormatted(timerState.timeRemaining),
                  style: TextStyle(
                    fontSize: AppTextStyles.h1FontSize,
                    color: timerState.color,
                    letterSpacing: AppTextStyles.h1LetterSpacing,
                    height: AppTextStyles.h1LineSpacing,
                    fontFamily: timerState.fontFamily,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    if (timerState.isRunning) {
                      ref.read(timerProvider.notifier).pauseTimer();
                    } else {
                      ref.read(timerProvider.notifier).toggleTimer();
                    }
                  },
                  child: Text(
                    key: const Key('pauseRestart'),
                    timerState.isRunning ? 'PAUSE' : 'RESTART',
                    style: TextStyle(
                        fontSize: AppTextStyles.h3FontSize,
                        color: timerState.color,
                        letterSpacing: AppTextStyles.h3LetterSpacing,
                        height: AppTextStyles.h3LineSpacing,
                        fontFamily: timerState.fontFamily),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
