import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/components/timer/task_bar.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';

Widget _wrap(Widget child) => ProviderScope(child: MaterialApp(home: Scaffold(body: child)));

class _Dummy extends StatelessWidget {
  final String label;
  const _Dummy(this.label);
  @override
  Widget build(BuildContext context) => Icon(Icons.circle, key: Key('icon_$label'));
}

void main() {
  group('TaskBar initial presence', () {
    testWidgets('Task bar renders with key task_bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())),
      );
      await tester.pump();
      expect(find.byKey(const Key('task_bar')), findsOneWidget);
    });

    testWidgets('Settings GearIconButton relocated into TaskBar (center)', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PomodoroTimerScreen())),
      );
      await tester.pump();
      expect(find.byKey(const Key('task_bar_settings')), findsOneWidget);
    });
  });

  group('TaskBar dynamic actions (RED)', () {
    testWidgets('Single action (settings) centers at slot 2', (tester) async {
      await tester.pumpWidget(_wrap(const TaskBar(actions: [GearIconButton()])));
      await tester.pump();
      expect(find.byKey(const Key('task_bar_settings')), findsOneWidget);
      // Should expose slot key for center only.
      expect(find.byKey(const Key('task_bar_slot_2')), findsOneWidget);
      expect(find.byKey(const Key('task_bar_slot_0')), findsNothing);
    });

    testWidgets('Three actions produce slots 1,2,3 populated', (tester) async {
      await tester.pumpWidget(_wrap(const TaskBar(actions: [
        _Dummy('a'),
        GearIconButton(),
        _Dummy('b'),
      ])));
      await tester.pump();
      expect(find.byKey(const Key('task_bar_slot_1')), findsOneWidget);
      expect(find.byKey(const Key('task_bar_slot_2')), findsOneWidget);
      expect(find.byKey(const Key('task_bar_slot_3')), findsOneWidget);
    });

    testWidgets('Five actions fill slots 0..4', (tester) async {
      await tester.pumpWidget(_wrap(const TaskBar(actions: [
        _Dummy('0'),
        _Dummy('1'),
        GearIconButton(),
        _Dummy('3'),
        _Dummy('4'),
      ])));
      await tester.pump();
      for (var i = 0; i < 5; i++) {
        expect(find.byKey(Key('task_bar_slot_$i')), findsOneWidget);
      }
    });

    testWidgets('More than five actions drops extras silently', (tester) async {
      await tester.pumpWidget(_wrap(const TaskBar(actions: [
        _Dummy('0'),
        _Dummy('1'),
        GearIconButton(),
        _Dummy('3'),
        _Dummy('4'),
        _Dummy('EXTRA'),
      ])));
      await tester.pump();
      for (var i = 0; i < 5; i++) {
        expect(find.byKey(Key('task_bar_slot_$i')), findsOneWidget);
      }
      // Extra should not render its icon key.
      expect(find.byKey(const Key('icon_EXTRA')), findsNothing);
    });
  });
}
