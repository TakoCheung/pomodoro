import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_display.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_gearicon_button.dart';
import 'package:flutter_pomodoro_app/components/timer/timer_mode_switch_ui.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/widgets/scripture_overlay.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/permission_coordinator.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/widgets/alarm_banner.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';
import 'package:flutter_pomodoro_app/state/notification_provider.dart';

class PomodoroTimerScreen extends ConsumerWidget {
  const PomodoroTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showScripture = ref.watch(scriptureOverlayVisibleProvider);
    final showBanner = ref.watch(alarmBannerVisibleProvider);
    final notifPosted = ref.watch(lastNotificationPostedProvider);
    final settings = ref.watch(localSettingsProvider);
    final shown = ref.watch(shownScriptureProvider);
    final bibleId = ref.watch(bibleIdProvider);
    // Rationale visibility is driven by the coordinator (initialized at app start).
    final auto = ref.watch(permissionAutostartProvider);
    // Ensure the alarm banner is never obscured by the permission rationale.
    final rationaleVisible = auto && ref.watch(notifRationaleVisibleProvider) && !showBanner;
    // Log basic debug info when needed.
    // debugPrint('PomodoroTimerScreen: bibleId=$bibleId');
    return Scaffold(
      key: const Key('timer_screen'),
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        children: [
          // Deep link target key
          const SizedBox.shrink(key: Key('deep_link_timer')),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'pomodoro',
                  key: const Key('pomodoro_title'),
                  style: TextStyle(
                      fontSize: AppTextStyles.title,
                      color: AppColors.lightBlueGray,
                      fontWeight: FontWeight.bold),
                ),
                Flexible(
                    child: SizedBox(
                  height: 45,
                )),
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
          if (showBanner)
            Align(
              alignment: Alignment.topCenter,
              child: AlarmBanner(
                onDismiss: () => dismissAlarmBanner(ref),
                backgroundColor: settings.color,
                fontFamily: settings.fontFamily,
                reference: shown?.reference,
                snippet: shown?.text,
              ),
            ),
          if (notifPosted)
            const Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox.shrink(key: Key('notification_alarm')),
            ),
          // Topmost: in-app permission rationale banner. Render last so it paints above everything.
          if (rationaleVisible)
            Align(
              alignment: Alignment.topCenter,
              child: Material(
                // Solid banner so it isn’t transparent behind the system sheet
                color: const Color(0xFF111214),
                child: Container(
                  key: const Key('notif_rationale_sheet'),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Allow notifications to get alerts when timers finish. You can change this later in Settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            key: const Key('notif_rationale_later'),
                            onPressed: () =>
                                ref.read(permissionCoordinatorProvider.notifier).deferPrompt(),
                            child: const Text('Later'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            key: const Key('notif_rationale_accept'),
                            onPressed: () => ref
                                .read(permissionCoordinatorProvider.notifier)
                                .requestPermission(provisional: false),
                            child: const Text('Allow'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      // No debug FAB.
    );
  }
}
