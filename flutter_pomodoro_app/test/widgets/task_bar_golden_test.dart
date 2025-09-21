import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_pomodoro_app/components/timer/task_bar.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_pomodoro_app/design/app_dimensions.dart';

class _Dummy extends StatelessWidget {
  final String label;
  const _Dummy(this.label);
  @override
  Widget build(BuildContext context) => Icon(Icons.circle, key: Key('icon_$label'));
}

void main() {
  group('TaskBar golden distribution', () {
    testGoldens('actions distribution variants', (tester) async {
      const width = 360.0;
      // Provide generous vertical space to prevent overflow: each scenario ~ bar height + label + padding.
      const height = (AppSizes.taskBarHeight + 48.0) * 5 +
          64.0; // (bar + approx label/padding) * scenarios + extra buffer
      final builder = GoldenBuilder.column()
        ..addScenario(
            '1 action', const SizedBox(width: width, child: TaskBar(actions: [GearIconButton()])))
        ..addScenario('2 actions',
            const SizedBox(width: width, child: TaskBar(actions: [GearIconButton(), _Dummy('b')])))
        ..addScenario(
            '3 actions',
            const SizedBox(
                width: width,
                child: TaskBar(actions: [_Dummy('a'), GearIconButton(), _Dummy('b')])))
        ..addScenario(
            '4 actions',
            const SizedBox(
                width: width,
                child: TaskBar(actions: [_Dummy('0'), GearIconButton(), _Dummy('2'), _Dummy('3')])))
        ..addScenario(
            '5 actions',
            const SizedBox(
                width: width,
                child: TaskBar(actions: [
                  _Dummy('0'),
                  GearIconButton(),
                  _Dummy('2'),
                  _Dummy('3'),
                  _Dummy('4')
                ])));

      await tester.pumpWidgetBuilder(builder.build(), surfaceSize: const Size(width + 64, height));
      await tester.pumpAndSettle();
      const goldenName = '../goldens/task_bar_distribution';
      final goldenFile = File('test/goldens/task_bar_distribution.png');
      if (!goldenFile.existsSync()) {
        debugPrint(
            'Golden baseline missing for TaskBar; skipping (run with --update-goldens to create).');
        return;
      }
      await screenMatchesGolden(tester, goldenName);
    });
  });
}
