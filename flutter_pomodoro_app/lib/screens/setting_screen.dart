import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_pomodoro_app/components/setting/divider.dart';
import 'package:flutter_pomodoro_app/components/setting/number_input.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/data/bible_versions.dart';
import 'package:flutter_pomodoro_app/services/bible_catalog_service.dart';
import 'package:flutter_pomodoro_app/models/bible_version.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/state/settings_controller.dart';
import 'package:flutter_pomodoro_app/state/permission_coordinator.dart';
import 'package:flutter_pomodoro_app/state/alarm_haptics_providers.dart';
import 'package:flutter_pomodoro_app/utils/sounds.dart';
import 'package:flutter_pomodoro_app/state/scripture_audio_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Stage snapshot from committed once on open, after first frame, to avoid
    // provider mutations during the initial build in tests.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(settingsControllerProvider.notifier).stageFromCommitted();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsCtl = ref.watch(settingsControllerProvider);
    final settingsCtlNotifier = ref.read(settingsControllerProvider.notifier);
    // Timer updates are invoked directly via provider reads where needed.
    final timerState = ref.read(timerProvider);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    // Treat debug/web runs as simulator-like so tests and simulator show the toggle; hide in release on device.
    final showDebugControls = kIsWeb || kDebugMode;

    return KeyedSubtree(
      key: const Key('SettingsScreen'),
      child: KeyedSubtree(
        key: const Key('settings_panel'),
        child: PopScope(
          onPopInvokedWithResult: (didPop, result) {
            ref.read(settingsControllerProvider.notifier).revert();
          },
          child: SizedBox(
            width: isTablet ? 540 : 327,
            height: isTablet ? 464 : 575,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                // Use max height so Expanded children can layout correctly within the dialog constraints.
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      // Ensure scrollable content isn’t covered by the fixed footer buttons.
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(builder: (context, constraints) {
                            final bool showCompact = constraints.maxWidth < 500;
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Settings',
                                        style: TextStyle(
                                          fontSize: AppTextStyles.h2FontSize,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppTextStyles.kumbhSans,
                                          height: AppTextStyles.h2LineSpacing,
                                          color: AppColors.darkDarkBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCommitSummary(settingsCtl),
                                        key: const Key('settings_commit_state_summary'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.lightBlueGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!showCompact)
                                  OutlinedButton.icon(
                                    key: const Key('reset_defaults_button'),
                                    onPressed: () async {
                                      // Stage defaults only; do not persist or apply until user taps Apply.
                                      settingsCtlNotifier.updateStaged(
                                        initPomodoro: TimerDefaults.pomodoroDefault,
                                        initShortBreak: TimerDefaults.shortBreakDefault,
                                        initLongBreak: TimerDefaults.longBreakDefault,
                                        fontFamily: AppTextStyles.kumbhSans,
                                        color: AppColors.orangeRed,
                                        bibleVersionName: kDefaultBibleVersionName,
                                        bibleVersionId: kBibleVersions[kDefaultBibleVersionName],
                                      );
                                    },
                                    icon: const Icon(Icons.restore),
                                    label: const Text('Reset to Defaults'),
                                  )
                                else
                                  IconButton(
                                    key: const Key('reset_defaults_button'),
                                    tooltip: 'Reset to Defaults',
                                    icon: const Icon(Icons.restore),
                                    onPressed: () async {
                                      // Stage defaults only; do not persist or apply until user taps Apply.
                                      settingsCtlNotifier.updateStaged(
                                        initPomodoro: TimerDefaults.pomodoroDefault,
                                        initShortBreak: TimerDefaults.shortBreakDefault,
                                        initLongBreak: TimerDefaults.longBreakDefault,
                                        fontFamily: AppTextStyles.kumbhSans,
                                        color: AppColors.orangeRed,
                                        bibleVersionName: kDefaultBibleVersionName,
                                        bibleVersionId: kBibleVersions[kDefaultBibleVersionName],
                                      );
                                    },
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  key: const Key('settings_close'),
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    // Revert staged changes before closing.
                                    ref.read(settingsControllerProvider.notifier).revert();
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          }),
                          const CustomDivider(spaceAfter: 30, spaceBefore: 25),
                          if (settingsCtl.isDirty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                key: const Key('settings_dirty_badge'),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade700,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text('Unapplied changes',
                                    style: TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                            ),
                          if (settingsCtl.isDirty) const SizedBox(height: 8),
                          if (showDebugControls) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Debug Mode', style: AppTextStyles.h4),
                                Switch(
                                  key: const Key('debug_mode_switch'),
                                  value: settingsCtl.staged.debugMode,
                                  onChanged: (v) => settingsCtlNotifier.updateStaged(debugMode: v),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Sound enabled + selection + preview (placed early so it's always visible without scrolling in tests)
                          const Text('ALARM SOUND', style: AppTextStyles.h4),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sound', style: AppTextStyles.h4),
                              Switch(
                                key: const Key('settings_sound_toggle'),
                                value: settingsCtl.staged.soundEnabled,
                                onChanged: (v) => ref
                                    .read(settingsControllerProvider.notifier)
                                    .updateStaged(soundEnabled: v),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  key: const Key('settings_sound_dropdown'),
                                  isExpanded: true,
                                  value: settingsCtl.staged.soundId,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'classic_bell',
                                        key: Key('sound_option_classic_bell'),
                                        child: Text('Classic Bell')),
                                    DropdownMenuItem(
                                        value: 'gentle_chime',
                                        key: Key('sound_option_gentle_chime'),
                                        child: Text('Gentle Chime')),
                                    DropdownMenuItem(
                                        value: 'beep',
                                        key: Key('sound_option_beep'),
                                        child: Text('Beep')),
                                    DropdownMenuItem(
                                        value: 'tts_scripture',
                                        key: Key('sound_option_tts_scripture'),
                                        child: Text('Read Scripture')),
                                  ],
                                  onChanged: (id) {
                                    if (id != null) {
                                      ref
                                          .read(settingsControllerProvider.notifier)
                                          .updateStaged(soundId: id);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                key: const Key('sound_preview'),
                                onPressed: () {
                                  final alarm = ref.read(alarmServiceProvider);
                                  final id = ref.read(settingsControllerProvider).staged.soundId;
                                  final asset = inAppAssetFor(id);
                                  alarm.play(assetName: asset, loopFor: const Duration(seconds: 2));
                                },
                                child: const Text('Preview'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Haptics', style: AppTextStyles.h4),
                              Switch(
                                key: const Key('settings_haptics_toggle'),
                                value: settingsCtl.staged.hapticsEnabled,
                                onChanged: (v) => ref
                                    .read(settingsControllerProvider.notifier)
                                    .updateStaged(hapticsEnabled: v),
                              )
                            ],
                          ),
                          const CustomDivider(spaceBefore: 15),
                          // Bible Version selector
                          Row(
                            children: [
                              const Text('BIBLE VERSION', style: AppTextStyles.h4),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Consumer(builder: (context, ref, _) {
                                  final AsyncValue<List<BibleVersion>> versionsAsync =
                                      ref.watch(bibleVersionsProvider);
                                  return versionsAsync.when(
                                    data: (list) {
                                      final Map<String, BibleVersion> byId = {
                                        for (final v in list) v.id: v
                                      };
                                      final uniqueList = byId.values.toList(growable: false);
                                      final items = uniqueList
                                          .map((v) => DropdownMenuItem<String>(
                                                value: v.id,
                                                child: Text(v.label),
                                              ))
                                          .toList(growable: false);

                                      final currentName = settingsCtl.staged.bibleVersionName;
                                      final match = uniqueList.firstWhere(
                                        (v) =>
                                            v.label == currentName ||
                                            v.displayName == currentName ||
                                            v.name == currentName ||
                                            v.abbreviationLocal == currentName ||
                                            v.abbreviation == currentName,
                                        orElse: () => uniqueList.first,
                                      );
                                      final selectedId = match.id;

                                      return DropdownButton<String>(
                                        key: const Key('bible_version_dropdown'),
                                        isExpanded: true,
                                        value: settingsCtl.staged.bibleVersionId ?? selectedId,
                                        items: items,
                                        onChanged: (id) {
                                          if (id == null) return;
                                          final sel = uniqueList.firstWhere((v) => v.id == id,
                                              orElse: () => match);
                                          settingsCtlNotifier.updateStaged(
                                            bibleVersionName: sel.label,
                                            bibleVersionId: sel.id,
                                          );
                                        },
                                      );
                                    },
                                    loading: () {
                                      final entries =
                                          kBibleVersions.entries.toList(growable: false);
                                      final items = entries
                                          .map((e) => DropdownMenuItem<String>(
                                              value: e.value, child: Text(e.key)))
                                          .toList(growable: false);
                                      final selectedId = settingsCtl.staged.bibleVersionId ??
                                          kBibleVersions[settingsCtl.staged.bibleVersionName] ??
                                          (entries.isNotEmpty ? entries.first.value : null);
                                      return DropdownButton<String>(
                                        key: const Key('bible_version_dropdown'),
                                        isExpanded: true,
                                        value: selectedId,
                                        items: items,
                                        onChanged: (id) {
                                          if (id == null) return;
                                          final e = entries.firstWhere((e) => e.value == id,
                                              orElse: () => entries.first);
                                          settingsCtlNotifier.updateStaged(
                                            bibleVersionName: e.key,
                                            bibleVersionId: e.value,
                                          );
                                        },
                                      );
                                    },
                                    error: (_, __) {
                                      final entries =
                                          kBibleVersions.entries.toList(growable: false);
                                      final items = entries
                                          .map((e) => DropdownMenuItem<String>(
                                              value: e.value, child: Text(e.key)))
                                          .toList(growable: false);
                                      final selectedId = settingsCtl.staged.bibleVersionId ??
                                          kBibleVersions[settingsCtl.staged.bibleVersionName] ??
                                          (entries.isNotEmpty ? entries.first.value : null);
                                      return DropdownButton<String>(
                                        key: const Key('bible_version_dropdown'),
                                        isExpanded: true,
                                        value: selectedId,
                                        items: items,
                                        onChanged: (id) {
                                          if (id == null) return;
                                          final e = entries.firstWhere((e) => e.value == id,
                                              orElse: () => entries.first);
                                          settingsCtlNotifier.updateStaged(
                                            bibleVersionName: e.key,
                                            bibleVersionId: e.value,
                                          );
                                        },
                                      );
                                    },
                                  );
                                }),
                              ),
                            ],
                          ),
                          const CustomDivider(spaceBefore: 15),
                          // Notifications permission status (single-line)
                          Builder(builder: (context) {
                            final statusText = ref.watch(permissionStatusTextProvider);
                            return ListTile(
                              key: const Key('settings_notifications_tile'),
                              leading: const Icon(Icons.notifications_active),
                              title: const Text('Notifications', style: AppTextStyles.h4),
                              // Show the On/Off badge on the same line using trailing.
                              trailing: Container(
                                key: const Key('permission_status_badge'),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusText == 'On'
                                      ? Colors.green.shade600
                                      : Colors.red.shade600,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  statusText,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              onTap: () {},
                            );
                          }),
                          const CustomDivider(spaceBefore: 15),
                          const Text(
                            'TIME (MINUTES)',
                            style: AppTextStyles.h4,
                          ),
                          const SizedBox(height: 10),
                          isTablet
                              ? _buildTimeRow(settingsCtl, settingsCtlNotifier, isTablet)
                              : _buildTimeColumn(settingsCtl, settingsCtlNotifier, isTablet),
                          // (Sound/Haptics section moved earlier)
                          const SizedBox(height: 8),
                          Builder(builder: (context) {
                            bool showNotificationsToggle = false;
                            try {
                              final flag = const String.fromEnvironment(
                                  'ENABLE_NOTIFICATIONS_TOGGLE_UI',
                                  defaultValue: 'false');
                              showNotificationsToggle = flag == 'true';
                            } catch (_) {}
                            if (!showNotificationsToggle) {
                              return const SizedBox.shrink();
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Notifications', style: AppTextStyles.h4),
                                Switch(
                                  key: const Key('settings_notifications_toggle'),
                                  value: settingsCtl.staged.notificationsEnabled,
                                  onChanged: (v) => ref
                                      .read(settingsControllerProvider.notifier)
                                      .updateStaged(notificationsEnabled: v),
                                )
                              ],
                            );
                          }),
                          const CustomDivider(),
                          _buildFonts(timerState, settingsCtl, settingsCtlNotifier, isTablet),
                          const CustomDivider(),
                          _buildColor(timerState, settingsCtl, settingsCtlNotifier, isTablet),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  // Fixed footer Apply button so it's always visible
                  SafeArea(
                    top: false,
                    child: LayoutBuilder(builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 360;
                      final buttons = <Widget>[
                        if (settingsCtl.staged.debugMode)
                          OutlinedButton.icon(
                            key: const Key('view_cached_passages_button'),
                            icon: const Icon(Icons.history),
                            label: const Text('View cached passages'),
                            onPressed: () => _showCachedPassagesDialog(context, ref),
                          ),
                        // Default: Apply next session (non-interrupting). This updates live settings
                        // immediately and stages durations for the next session boundary.
                        KeyedSubtree(
                          key: const Key('apply_next_session_button'),
                          child: Semantics(
                            key: const Key('settings_apply'),
                            // Keep button enabled for backward-compat with existing tests.
                            child: ElevatedButton(
                              onPressed: settingsCtl.isDirty
                                  ? () async {
                                      // Persist all committed settings via controller.
                                      await ref.read(settingsControllerProvider.notifier).apply();
                                      // Apply visuals now regardless of session state.
                                      ref
                                          .read(timerProvider.notifier)
                                          .applyLiveSettings(ref.read(localSettingsProvider));
                                      // Decide immediate vs deferred durations based on active session.
                                      final t = ref.read(timerProvider);
                                      if (!t.isRunning) {
                                        // No active session: apply staged durations now and reset.
                                        ref.read(timerProvider.notifier).applyStagedDurationsNow();
                                      }
                                      if (!context.mounted) return;
                                      Navigator.of(context).pop();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orangeRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26.5),
                                ),
                                fixedSize: const Size(180, 53),
                              ),
                              child: const Text(
                                'Apply (Next Session)',
                                style: TextStyle(
                                  fontSize: AppTextStyles.h3FontSize,
                                  fontFamily: AppTextStyles.kumbhSans,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!isNarrow) const SizedBox(width: 12) else const SizedBox(height: 8),
                      ];
                      return isNarrow
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: buttons,
                            )
                          : Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: buttons,
                            );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCommitSummary(SettingsControllerState s) {
    String onOff(bool v) => v ? 'On' : 'Off';
    final c = s.committed;
    // Derived scripture voice flag via provider (cannot watch in helper; use container read instead).
    try {
      final enabled = ref.read(scriptureAudioEnabledProvider);
      final base = 'Sound ${onOff(c.soundEnabled)} • Haptics ${onOff(c.hapticsEnabled)}';
      return enabled ? '$base • Scripture Voice On' : base;
    } catch (_) {
      return 'Sound ${onOff(c.soundEnabled)} • Haptics ${onOff(c.hapticsEnabled)}';
    }
  }

  void _showCachedPassagesDialog(BuildContext context, WidgetRef ref) {
    final repo = ref.read(scriptureRepositoryProvider);
    final history = repo.history;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        key: const Key('cached_passages_dialog'),
        title: const Text('Cached Passages (today and history)'),
        // Give the dialog content a fixed box; avoid shrinkWrap ListView which
        // conflicts with AlertDialog's IntrinsicWidth during layout.
        content: SizedBox(
          width: 500,
          height: 400,
          child: history.isEmpty
              ? const Text('No passages cached yet.')
              : Scrollbar(
                  child: ListView.separated(
                    key: const Key('cached_passages_list'),
                    primary: false,
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (_, i) {
                      final p = history[i];
                      return ListTile(
                        dense: true,
                        title: Text(p.reference),
                        subtitle: Text(
                          p.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  Widget _buildTimeRow(
      SettingsControllerState staged, SettingsController settingsCtlNotifier, bool isTablet) {
    // Use Expanded to prevent horizontal overflow on narrow layouts while keeping a single row on tablets.
    return Row(
      key: const Key('timeSection'),
      children: [
        Expanded(
          child: _buildNumberInput(TimerMode.pomodoro, staged.staged.initPomodoro,
              staged.staged.debugMode ? 0 : 25, 60, settingsCtlNotifier, isTablet,
              keyPrefix: 'pomodoro'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberInput(TimerMode.shortBreak, staged.staged.initShortBreak,
              staged.staged.debugMode ? 0 : 5, 15, settingsCtlNotifier, isTablet,
              keyPrefix: 'shortBreak'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberInput(TimerMode.longBreak, staged.staged.initLongBreak,
              staged.staged.debugMode ? 0 : 15, 30, settingsCtlNotifier, isTablet,
              keyPrefix: 'longBreak'),
        ),
      ],
    );
  }

  Widget _buildTimeColumn(
      SettingsControllerState staged, SettingsController settingsCtlNotifier, bool isTablet) {
    return Column(
      key: const Key('timeSection'),
      children: [
        _buildNumberInput(TimerMode.pomodoro, staged.staged.initPomodoro,
            staged.staged.debugMode ? 0 : 25, 60, settingsCtlNotifier, isTablet,
            keyPrefix: 'pomodoro'),
        const SizedBox(height: 10),
        _buildNumberInput(TimerMode.shortBreak, staged.staged.initShortBreak,
            staged.staged.debugMode ? 0 : 5, 15, settingsCtlNotifier, isTablet,
            keyPrefix: 'shortBreak'),
        const SizedBox(height: 10),
        _buildNumberInput(TimerMode.longBreak, staged.staged.initLongBreak,
            staged.staged.debugMode ? 0 : 15, 30, settingsCtlNotifier, isTablet,
            keyPrefix: 'longBreak'),
      ],
    );
  }

  Widget _buildFonts(TimerState timerState, SettingsControllerState staged,
      SettingsController settingsCtlNotifier, bool isTablet) {
    return isTablet
        ? Row(
            key: const Key('fontSection'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const Text(
                  'FONT',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 10),
                Container(child: _buildFontRow(timerState, staged, settingsCtlNotifier))
              ])
        : Column(
            key: const Key('fontSection'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const Text(
                  'FONT',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 10),
                Container(child: _buildFontRow(timerState, staged, settingsCtlNotifier))
              ]);
  }

  Widget _buildFontRow(TimerState timerState, SettingsControllerState staged,
      SettingsController settingsCtlNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFontOption('Aa', AppTextStyles.kumbhSans, timerState, staged, settingsCtlNotifier),
        const SizedBox(
          width: 16,
        ),
        _buildFontOption('Aa', AppTextStyles.robotoSlab, timerState, staged, settingsCtlNotifier),
        const SizedBox(
          width: 16,
        ),
        _buildFontOption('Aa', AppTextStyles.spaceMono, timerState, staged, settingsCtlNotifier),
      ],
    );
  }

  Widget _buildColor(TimerState timerState, SettingsControllerState staged,
      SettingsController settingsCtlNotifier, bool isTablet) {
    return isTablet
        ? Row(
            key: const Key('colorSection'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const Text(
                  'COLOR',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 10),
                _buildColorRow(staged, settingsCtlNotifier, timerState),
              ])
        : Column(
            key: const Key('colorSection'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const Text(
                  'COLOR',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 10),
                _buildColorRow(staged, settingsCtlNotifier, timerState),
              ]);
  }

  Widget _buildColorRow(SettingsControllerState staged, SettingsController settingsCtlNotifier,
      TimerState timerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorOption(AppColors.orangeRed, staged, settingsCtlNotifier, timerState),
        const SizedBox(
          width: 16,
        ),
        _buildColorOption(AppColors.lightBlue, staged, settingsCtlNotifier, timerState),
        const SizedBox(
          width: 16,
        ),
        _buildColorOption(AppColors.lightPurle, staged, settingsCtlNotifier, timerState),
      ],
    );
  }

  Widget _buildNumberInput(TimerMode mode, int timeInSec, int min, int max,
      SettingsController settingsCtlNotifier, bool isTablet,
      {String? keyPrefix}) {
    return NumberInput(
        title: _timerModeName(mode),
        initialValue: timeInSec ~/ 60,
        minValue: min,
        maxValue: max,
        onValueChanged: (value) {
          int seconds;
          // Debug semantics: 0 minutes means 1 second for fast flows.
          if (value == 0) {
            seconds = 0; // keep 0 here; TimerNotifier will treat as 1 second
          } else {
            seconds = value * 60;
          }
          switch (mode) {
            case TimerMode.pomodoro:
              settingsCtlNotifier.updateStaged(initPomodoro: seconds);
              break;
            case TimerMode.shortBreak:
              settingsCtlNotifier.updateStaged(initShortBreak: seconds);
              break;
            case TimerMode.longBreak:
              settingsCtlNotifier.updateStaged(initLongBreak: seconds);
              break;
          }
        },
        isTablet: isTablet,
        testKeyPrefix: keyPrefix);
  }

  Widget _buildFontOption(String text, String fontFamily, TimerState timerState,
      SettingsControllerState staged, SettingsController settingsCtlNotifier) {
    bool currentActive = timerState.fontFamily == fontFamily;
    return GestureDetector(
      onTap: () => settingsCtlNotifier.updateStaged(fontFamily: fontFamily),
      child: Container(
        // maybe better to contain the ring inside the container
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(12.5),
        decoration: BoxDecoration(
          color: currentActive ? AppColors.darkDarkBlue : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            strokeAlign: 5,
            color:
                staged.staged.fontFamily != fontFamily ? Colors.transparent : AppColors.lightGray,
            width: 2.0,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontFamily: fontFamily,
              fontSize: AppTextStyles.h3FontSize,
              color: currentActive ? Colors.white : AppColors.darkBlue,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, SettingsControllerState staged,
      SettingsController settingsCtlNotifier, TimerState timerState) {
    return GestureDetector(
        onTap: () => settingsCtlNotifier.updateStaged(color: color),
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(11.5),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              strokeAlign: 5,
              color: staged.staged.color != color ? Colors.transparent : AppColors.lightGray,
              width: 2.0, //different than figma
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: timerState.color == color
                ? const Icon(Icons.check, color: AppColors.darkDarkBlue)
                : null,
          ),
        ));
  }

  String _timerModeName(TimerMode mode) {
    switch (mode) {
      case TimerMode.pomodoro:
        return 'Pomodoro';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }
}

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Stack(children: [
        // A transparent scrim capturing taps; provide a Key for tests.
        Positioned.fill(
          child: GestureDetector(
            key: const Key('settings_scrim'),
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Revert staged changes, then close.
              final container = ProviderScope.containerOf(ctx);
              container.read(settingsControllerProvider.notifier).revert();
              Navigator.of(ctx).pop();
            },
          ),
        ),
        // Ensure a Material ancestor for all Material widgets inside SettingsScreen.
        Center(
          child: Material(
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: const SettingsScreen(),
          ),
        ),
      ]);
    },
  );
}
