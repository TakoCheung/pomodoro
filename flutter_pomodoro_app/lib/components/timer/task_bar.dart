import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/widgets/cached_verses_panel.dart';
import 'package:flutter_pomodoro_app/design/app_dimensions.dart';

class TaskBarDefaults {
  static const double height = AppSizes.taskBarHeight;
  static const int maxSlots = 5;
}

/// TaskBar with up to 5 action slots.
/// Distribution strategy ("evenly from center"):
///  count=1 -> [2]
///  count=2 -> [1,3]
///  count=3 -> [1,2,3]
///  count=4 -> [0,1,3,4] (symmetric pairs; center left empty for balance)
///  count>=5 -> [0,1,2,3,4]
class TaskBar extends StatelessWidget {
  const TaskBar({super.key, this.actions});

  /// Caller-provided actions (include the GearIconButton among them if custom).
  /// If null, defaults to a single centered GearIconButton.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final defaultActions = <Widget>[
      const GearIconButton(),
      // New cached verses button
      _CachedVersesButton(),
    ];
    final provided = (actions == null || actions!.isEmpty)
        ? defaultActions
        : actions!.take(TaskBarDefaults.maxSlots).toList();
    final count = provided.length;

    List<int> slots;
    switch (count) {
      case 1:
        slots = const [2];
        break;
      case 2:
        slots = const [1, 3];
        break;
      case 3:
        slots = const [1, 2, 3];
        break;
      case 4:
        slots = const [0, 1, 3, 4];
        break;
      default:
        slots = List.generate(count, (i) => i).take(TaskBarDefaults.maxSlots).toList();
    }

    final slotChildren = <int, Widget>{};
    for (var i = 0; i < slots.length; i++) {
      final slotIndex = slots[i];
      final child = provided[i];
      Widget wrapped = child;
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
        padding: AppInsets.horizontalPage,
        child: Row(
          children: List.generate(TaskBarDefaults.maxSlots, (i) {
            return Expanded(child: slotChildren[i] ?? const SizedBox());
          }),
        ),
      ),
    );
  }
}

class _CachedVersesButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      key: const Key('taskbar_cached_verses_button'),
      icon: const Icon(Icons.bookmark_added_rounded, color: AppColors.lightBlueGray),
      tooltip: 'Cached Verses',
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => const CachedVersesPanel(),
        );
      },
    );
  }
}
