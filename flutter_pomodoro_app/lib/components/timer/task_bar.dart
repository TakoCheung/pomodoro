import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';

class TaskBarDefaults {
  static const double height = 72.0; // Will be reused in later steps
  static const int maxSlots = 5;
}

/// TaskBar with up to 5 action slots. Actions are centered; single action
/// (default settings) sits at slot index 2.
class TaskBar extends StatelessWidget {
  const TaskBar({super.key, this.actions});

  /// Caller-provided actions (include the GearIconButton among them if custom).
  /// If null, defaults to a single centered GearIconButton.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final provided = (actions == null || actions!.isEmpty)
        ? <Widget>[const GearIconButton()]
        : actions!.take(TaskBarDefaults.maxSlots).toList();
    final count = provided.length;
    final start = (TaskBarDefaults.maxSlots - count) ~/ 2; // center block

    // Map slot index -> widget
    final slotChildren = <int, Widget>{};
    for (var i = 0; i < count; i++) {
      final slotIndex = start + i;
      final child = provided[i];
      Widget wrapped = child;
      // Identify GearIconButton to apply special key.
      if (child is GearIconButton) {
        wrapped = Semantics(
          label: 'Settings',
          child: SizedBox(key: const Key('task_bar_settings'), child: child),
        );
      }
      wrapped = Center(
        child: Container(
          key: Key('task_bar_slot_$slotIndex'),
          alignment: Alignment.center,
          child: wrapped,
        ),
      );
      slotChildren[slotIndex] = wrapped;
    }

    return SafeArea(
      top: false,
      child: Container(
        key: const Key('task_bar'),
        height: TaskBarDefaults.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(TaskBarDefaults.maxSlots, (i) {
            return Expanded(child: slotChildren[i] ?? const SizedBox());
          }),
        ),
      ),
    );
  }
}
