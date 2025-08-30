import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_mode_switch_ui.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/widgets/scripture_overlay.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';

class PomodoroTimerScreen extends ConsumerWidget {
  const PomodoroTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showScripture = ref.watch(scriptureOverlayVisibleProvider);
  final bibleId = ref.watch(bibleIdProvider);
  // Read debug FAB flag from provider (which safely reads dotenv). Tests can
  // override this provider when needed.
  final enableDebugFab = ref.watch(enableDebugFabProvider);

  // Log debug info to help diagnose why the debug FAB may not appear.
  debugPrint('PomodoroTimerScreen: kDebugMode=$kDebugMode, enableDebugFab=$enableDebugFab, bibleId=$bibleId');
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
    // Debug-only quick trigger to set debug settings and mark the timer complete.
    // Controlled by `.env` flag `ENABLE_DEBUG_FAB=true` to allow CI/dev toggle.
  // NOTE: previously this also required `kDebugMode` which hides the FAB in
  // profile/release builds even when the env flag is set. Use only the env flag
  // so CI/devs can enable the FAB regardless of build mode.
  floatingActionButton: (kDebugMode && enableDebugFab)
      ? Consumer(builder: (context, ref, _) {
              return FloatingActionButton(
                key: const Key('debug_trigger_complete'),
                onPressed: () {
                  // Force debug mode and set all timers to zero minutes (maps to 1 second in debug)
                  final localSettingsNotifier = ref.read(localSettingsProvider.notifier);
                  localSettingsNotifier.updateDebugMode(true);
                  // Zero all modes; NumberInput and Timer state will update via apply
                  localSettingsNotifier.updateTime(TimerMode.pomodoro, 0);
                  localSettingsNotifier.updateTime(TimerMode.shortBreak, 0);
                  localSettingsNotifier.updateTime(TimerMode.longBreak, 0);
                  // Apply to the timer notifier
                  ref.read(timerProvider.notifier).updateSettings(ref.read(localSettingsProvider));
                  // Trigger timer completion to run the normal scripture fetch flow
                  // debug-only test helper: trigger timer completion.
                  // ignore: invalid_use_of_visible_for_testing_member
                  ref.read(timerProvider.notifier).triggerComplete();
                },
                child: const Icon(Icons.bolt),
              );
            })
          : null,
    );
  }
}