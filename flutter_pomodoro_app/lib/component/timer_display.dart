import 'package:flutter/material.dart';
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
                      colors: [Color(0xFF0E112A), Color(0xFF2E325A)],
                      transform: GradientRotation(0.785398)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF27254A),
                      spreadRadius: 0,
                      blurRadius: 100,
                      offset: Offset(-50, -50),
                    ),
                  ]),
            ),
            Container(
              width: 373,
              height: 373,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF161932),
              ),
            ),
            SizedBox(
              width: 339,
              height: 339,
              child: CircularProgressIndicator(
                strokeAlign: BorderSide.strokeAlignCenter,
                value: ref.read(timerProvider.notifier).progress(),
                strokeWidth: 12,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF70F3F8)),
                backgroundColor: Colors.transparent,
              ),
            ),
            // Timer text and button
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ref.read(timerProvider.notifier).timeFormatted(),
                  style: const TextStyle(
                    fontSize: 64,
                    color: Colors.white,
                    fontFamily: 'SpaceMono',
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
                    timerState.isRunning ? 'PAUSE' : 'RESTART',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 3,
                    ),
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
