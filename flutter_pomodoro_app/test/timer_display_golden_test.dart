import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('Pomodoro Timer Golden Test', (WidgetTester tester) async {
    final builder = GoldenBuilder.column()
      ..addScenario('Pomodoro Timer Default', const PomodoroTimerScreen());

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'pomodoro_timer_screen');
  });
}