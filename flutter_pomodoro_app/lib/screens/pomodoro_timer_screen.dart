import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_mode_switch_ui.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/widgets/scripture_overlay.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
// import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';

class PomodoroTimerScreen extends ConsumerWidget {
  const PomodoroTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showScripture = ref.watch(scriptureOverlayVisibleProvider);
  final bibleId = ref.watch(bibleIdProvider);
  // Log basic debug info when needed.
  // debugPrint('PomodoroTimerScreen: bibleId=$bibleId');
  return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'pomodoro',
                  key: Key('pomodoro_title'),
                  style: TextStyle(
                    fontSize: AppTextStyles.title,
                    color: AppColors.lightBlueGray,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Flexible(child:  SizedBox(height: 45,)),
                TimerModeSwitcherUI(),
                Flexible(child: SizedBox(height: 48)),
                TimerDisplay(),
                Flexible(child: SizedBox(height: 40)),
                GearIconButton(),
              ],
            ),
          ),
          // Overlay the scripture on top of main content when visible
      if (showScripture)
            Align(
              alignment: Alignment.center,
        child: ScriptureOverlay(bibleId: bibleId, passageId: 'GEN.1.1'),
            ),
        ],
      ),
  // No debug FAB.
    );
  }
}