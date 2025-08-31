import 'package:flutter/material.dart';
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
import 'package:flutter_pomodoro_app/state/settings_persistence.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localSettings = ref.watch(localSettingsProvider);
    final localSettingsNotifier = ref.read(localSettingsProvider.notifier);
    final timerNotifier = ref.read(timerProvider.notifier);
    final timerState = ref.read(timerProvider);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Dialog(
      key: const Key('SettingsScreen'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 540 : 327,
          maxHeight: isTablet ? 464 : 575,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                      const CustomDivider(spaceAfter: 30, spaceBefore: 25),
                      const Text(
                        'TIME (MINUTES)',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 10),
                      isTablet
                          ? _buildTimeRow(localSettings, localSettingsNotifier, isTablet)
                          : _buildTimeColumn(localSettings, localSettingsNotifier, isTablet),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Debug Mode', style: AppTextStyles.h4),
                          Switch(
                            key: const Key('debug_mode_switch'),
                            value: localSettings.debugMode,
                            onChanged: (v) => localSettingsNotifier.updateDebugMode(v),
                          )
                        ],
                      ),
                      if (localSettings.debugMode) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            key: const Key('view_cached_passages_button'),
                            icon: const Icon(Icons.history),
                            label: const Text('View cached passages'),
                            onPressed: () => _showCachedPassagesDialog(context, ref),
                          ),
                        ),
                      ],
                      const CustomDivider(spaceBefore: 30),
                      // Bible Version selector
                      Row(
                        children: [
                          const Text('Bible Version', style: AppTextStyles.h4),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Consumer(builder: (context, ref, _) {
                              final AsyncValue<List<BibleVersion>> versionsAsync =
                                  ref.watch(bibleVersionsProvider);
                              return versionsAsync.when(
                                data: (list) {
                                  // Deduplicate by ID in case API contains duplicates.
                                  final Map<String, BibleVersion> byId = {
                                    for (final v in list) v.id: v
                                  };
                                  final uniqueList = byId.values.toList(growable: false);
                                  // Use unique IDs for values to avoid duplicate label assertion.
                                  final items = uniqueList
                                      .map((v) => DropdownMenuItem<String>(
                                            value: v.id,
                                            child: Text(v.label),
                                          ))
                                      .toList(growable: false);

                                  // Determine selected ID from current stored name by matching against common fields.
                                  final currentName = localSettings.bibleVersionName;
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
                                    value: selectedId,
                                    items: items,
                                    onChanged: (id) {
                                      if (id == null) return;
                                      final sel = uniqueList.firstWhere((v) => v.id == id,
                                          orElse: () => match);
                                      // Store both human-friendly label and stable id.
                                      localSettingsNotifier.updateBibleVersion(sel.label, sel.id);
                                    },
                                  );
                                },
                                // During loading/error, fall back to static mapping by names to keep UI usable.
                                loading: () {
                                  // Build items from static map: values are IDs, labels are names.
                                  final entries = kBibleVersions.entries.toList(growable: false);
                                  final items = entries
                                      .map((e) => DropdownMenuItem<String>(
                                          value: e.value, child: Text(e.key)))
                                      .toList(growable: false);
                                  // Choose selected ID from settings (id preferred), else map current name.
                                  final selectedId = localSettings.bibleVersionId ??
                                      kBibleVersions[localSettings.bibleVersionName] ??
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
                                      localSettingsNotifier.updateBibleVersion(e.key, e.value);
                                    },
                                  );
                                },
                                error: (_, __) {
                                  final entries = kBibleVersions.entries.toList(growable: false);
                                  final items = entries
                                      .map((e) => DropdownMenuItem<String>(
                                          value: e.value, child: Text(e.key)))
                                      .toList(growable: false);
                                  final selectedId = localSettings.bibleVersionId ??
                                      kBibleVersions[localSettings.bibleVersionName] ??
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
                                      localSettingsNotifier.updateBibleVersion(e.key, e.value);
                                    },
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                      const CustomDivider(),
                      _buildFonts(timerState, localSettings, localSettingsNotifier, isTablet),
                      const CustomDivider(),
                      _buildColor(timerState, localSettings, localSettingsNotifier, isTablet),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          key: const Key('reset_defaults_button'),
                          onPressed: () async {
                            // Reset by re-initializing default LocalSettings instance
                            final def = LocalSettings(
                              initPomodoro: TimerDefaults.pomodoroDefault,
                              initShortBreak: TimerDefaults.shortBreakDefault,
                              initLongBreak: TimerDefaults.longBreakDefault,
                              fontFamily: AppTextStyles.kumbhSans,
                              color: AppColors.orangeRed,
                              bibleVersionName: kDefaultBibleVersionName,
                            );
                            ref.read(localSettingsProvider.notifier).updateFont(def.fontFamily);
                            ref.read(localSettingsProvider.notifier).updateColor(def.color);
                            ref
                                .read(localSettingsProvider.notifier)
                                .updateBibleVersionName(def.bibleVersionName);
                            ref
                                .read(localSettingsProvider.notifier)
                                .updateTime(TimerMode.pomodoro, def.initPomodoro ~/ 60);
                            ref
                                .read(localSettingsProvider.notifier)
                                .updateTime(TimerMode.shortBreak, def.initShortBreak ~/ 60);
                            ref
                                .read(localSettingsProvider.notifier)
                                .updateTime(TimerMode.longBreak, def.initLongBreak ~/ 60);
                            // Clear persisted copy
                            final sp = ref.read(settingsPersistenceProvider);
                            await sp?.resetToDefaults();
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('Reset to Defaults'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Fixed footer Apply button so it's always visible
              SafeArea(
                top: false,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      timerNotifier.updateSettings(localSettings);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26.5),
                      ),
                      fixedSize: const Size(140, 53),
                    ),
                    child: const Text(
                      'Apply',
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
            ],
          ),
        ),
      ),
    );
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
      LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier, bool isTablet) {
    // Use Expanded to prevent horizontal overflow on narrow layouts while keeping a single row on tablets.
    return Row(
      key: const Key('timeSection'),
      children: [
        Expanded(
          child: _buildNumberInput(TimerMode.pomodoro, localSettings.initPomodoro,
              localSettings.debugMode ? 0 : 25, 60, localSettingsNotifier, isTablet,
              keyPrefix: 'pomodoro'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberInput(TimerMode.shortBreak, localSettings.initShortBreak,
              localSettings.debugMode ? 0 : 5, 15, localSettingsNotifier, isTablet,
              keyPrefix: 'shortBreak'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberInput(TimerMode.longBreak, localSettings.initLongBreak,
              localSettings.debugMode ? 0 : 15, 30, localSettingsNotifier, isTablet,
              keyPrefix: 'longBreak'),
        ),
      ],
    );
  }

  Widget _buildTimeColumn(
      LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier, bool isTablet) {
    return Column(
      key: const Key('timeSection'),
      children: [
        _buildNumberInput(TimerMode.pomodoro, localSettings.initPomodoro,
            localSettings.debugMode ? 0 : 25, 60, localSettingsNotifier, isTablet,
            keyPrefix: 'pomodoro'),
        const SizedBox(height: 10),
        _buildNumberInput(TimerMode.shortBreak, localSettings.initShortBreak,
            localSettings.debugMode ? 0 : 5, 15, localSettingsNotifier, isTablet,
            keyPrefix: 'shortBreak'),
        const SizedBox(height: 10),
        _buildNumberInput(TimerMode.longBreak, localSettings.initLongBreak,
            localSettings.debugMode ? 0 : 15, 30, localSettingsNotifier, isTablet,
            keyPrefix: 'longBreak'),
      ],
    );
  }

  Widget _buildFonts(TimerState timerState, LocalSettings localSettings,
      LocalSettingsNotifier localSettingsNotifier, bool isTablet) {
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
                Container(child: _buildFontRow(timerState, localSettings, localSettingsNotifier))
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
                Container(child: _buildFontRow(timerState, localSettings, localSettingsNotifier))
              ]);
  }

  Widget _buildFontRow(TimerState timerState, LocalSettings localSettings,
      LocalSettingsNotifier localSettingsNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFontOption(
            'Aa', AppTextStyles.kumbhSans, timerState, localSettings, localSettingsNotifier),
        const SizedBox(
          width: 16,
        ),
        _buildFontOption(
            'Aa', AppTextStyles.robotoSlab, timerState, localSettings, localSettingsNotifier),
        const SizedBox(
          width: 16,
        ),
        _buildFontOption(
            'Aa', AppTextStyles.spaceMono, timerState, localSettings, localSettingsNotifier),
      ],
    );
  }

  Widget _buildColor(TimerState timerState, LocalSettings localSettings,
      LocalSettingsNotifier localSettingsNotifier, bool isTablet) {
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
                _buildColorRow(localSettings, localSettingsNotifier, timerState),
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
                _buildColorRow(localSettings, localSettingsNotifier, timerState),
              ]);
  }

  Widget _buildColorRow(LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier,
      TimerState timerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorOption(AppColors.orangeRed, localSettings, localSettingsNotifier, timerState),
        const SizedBox(
          width: 16,
        ),
        _buildColorOption(AppColors.lightBlue, localSettings, localSettingsNotifier, timerState),
        const SizedBox(
          width: 16,
        ),
        _buildColorOption(AppColors.lightPurle, localSettings, localSettingsNotifier, timerState),
      ],
    );
  }

  Widget _buildNumberInput(TimerMode mode, int timeInSec, int min, int max,
      LocalSettingsNotifier localSettingsNotifier, bool isTablet,
      {String? keyPrefix}) {
    return NumberInput(
        title: localSettingsNotifier.getName(mode),
        initialValue: timeInSec ~/ 60,
        minValue: min,
        maxValue: max,
        onValueChanged: (value) => localSettingsNotifier.updateTime(mode, value),
        isTablet: isTablet,
        testKeyPrefix: keyPrefix);
  }

  Widget _buildFontOption(String text, String fontFamily, TimerState timerState,
      LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier) {
    bool currentActive = timerState.fontFamily == fontFamily;
    return GestureDetector(
      onTap: () => localSettingsNotifier.updateFont(fontFamily),
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
                localSettings.fontFamily != fontFamily ? Colors.transparent : AppColors.lightGray,
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

  Widget _buildColorOption(Color color, LocalSettings localSettings,
      LocalSettingsNotifier localSettingsNotifier, TimerState timerState) {
    return GestureDetector(
        onTap: () => localSettingsNotifier.updateColor(color),
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(11.5),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              strokeAlign: 5,
              color: localSettings.color != color ? Colors.transparent : AppColors.lightGray,
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
}

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const SettingsScreen(),
  );
}
