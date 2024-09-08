import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer shadow layer
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: timerState.mode == TimerMode.pomodoro
                        ? const Color(0xFFFF6D6D).withOpacity(0.5)
                        : timerState.mode == TimerMode.shortBreak
                            ? const Color(0xFF70F3F8).withOpacity(0.5)
                            : const Color(0xFF9B5DE5).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Inner glow layer
            Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    timerState.mode == TimerMode.pomodoro
                        ? const Color(0xFFFF6D6D).withOpacity(0.3)
                        : timerState.mode == TimerMode.shortBreak
                            ? const Color(0xFF70F3F8).withOpacity(0.3)
                            : const Color(0xFF9B5DE5).withOpacity(0.3),
                    Colors.transparent,
                  ],
                  center: Alignment.center,
                  radius: 0.85,
                ),
              ),
            ),
            // Circular progress indicator with ShaderMask
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    timerState.mode == TimerMode.pomodoro
                        ? const Color(0xFFFF6D6D)
                        : timerState.mode == TimerMode.shortBreak
                            ? const Color(0xFF70F3F8)
                            : const Color(0xFF9B5DE5),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              child: CircularProgressIndicator(
                value: ref.read(timerProvider.notifier).progress(),
                strokeWidth: 10,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            // Timer text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ref.read(timerProvider.notifier).timeFormatted(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontFamily: 'RobotoSlab',
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Implement restart/pause functionality here
                  },
                  child: Text(
                    timerState.isRunning ? 'PAUSE' : 'RESTART',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'RobotoSlab',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement settings functionality here
        },
        child: const Icon(Icons.settings),
      ),
    );
  }
}
