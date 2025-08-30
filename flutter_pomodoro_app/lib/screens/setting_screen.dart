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
                            value: localSettings.debugMode,
                            onChanged: (v) => localSettingsNotifier.updateDebugMode(v),
                          )
                        ],
                      ),
                      const CustomDivider(spaceBefore: 30),
                      // Bible Version selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bible Version', style: AppTextStyles.h4),
                          Consumer(builder: (context, ref, _) {
                            final AsyncValue<List<BibleVersion>> versionsAsync = ref.watch(bibleVersionsProvider);
                            final values = versionsAsync.when<List<String>>(
                              data: (list) => list.map((v) => v.displayName).toList(growable: false),
                              loading: () => kBibleVersions.keys.toList(growable: false),
                              error: (_, __) => kBibleVersions.keys.toList(growable: false),
                            );
                            final items = values
                                .map((name) => DropdownMenuItem<String>(value: name, child: Text(name)))
                                .toList(growable: false);
                            // Ensure current value is in the list
                            final current = localSettings.bibleVersionName;
                            final dropdownValue = values.contains(current) ? current : (values.isNotEmpty ? values.first : current);
                            return Flexible(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: isTablet ? 240 : 180,
                                  child: DropdownButton<String>(
                                    key: const Key('bible_version_dropdown'),
                                    isExpanded: true,
                                    value: dropdownValue,
                                    items: items,
                                    onChanged: (v) {
                                      if (v != null) localSettingsNotifier.updateBibleVersionName(v);
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const CustomDivider(),
                      _buildFonts(timerState, localSettings, localSettingsNotifier, isTablet),
                      const CustomDivider(),
                      _buildColor(timerState, localSettings, localSettingsNotifier, isTablet),
                      const SizedBox(height: 20),
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

  Widget _buildTimeRow(LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier, bool isTablet) {
    // Use Expanded to prevent horizontal overflow on narrow layouts while keeping a single row on tablets.
    return Row(
      key: const Key('timeSection'),
      children: [
        Expanded(
          child: _buildNumberInput(
              TimerMode.pomodoro,
              localSettings.initPomodoro,
              localSettings.debugMode ? 0 : 25,
              60,
              localSettingsNotifier,
              isTablet),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberInput(
              TimerMode.shortBreak,
              localSettings.initShortBreak,
              localSettings.debugMode ? 0 : 5,
              15,
              localSettingsNotifier,
              isTablet),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberInput(
              TimerMode.longBreak,
              localSettings.initLongBreak,
              localSettings.debugMode ? 0 : 15,
              30,
              localSettingsNotifier,
              isTablet),
        ),
      ],
    );
  }

  Widget _buildTimeColumn(LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier, bool isTablet) {
    return Column(
      key: const Key('timeSection'),
      children: [
    _buildNumberInput(TimerMode.pomodoro, localSettings.initPomodoro,
      localSettings.debugMode ? 0 : 25, 60, localSettingsNotifier, isTablet),
        const SizedBox(height: 10),
    _buildNumberInput(TimerMode.shortBreak, localSettings.initShortBreak,
      localSettings.debugMode ? 0 : 5, 15, localSettingsNotifier, isTablet),
        const SizedBox(height: 10),
    _buildNumberInput(TimerMode.longBreak, localSettings.initLongBreak,
      localSettings.debugMode ? 0 : 15, 30, localSettingsNotifier, isTablet),
      ],
    );
  }

  Widget _buildFonts(
      TimerState timerState, LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier, bool isTablet) {
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
                Container(
                    child: _buildFontRow(
                        timerState, localSettings, localSettingsNotifier))
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
                Container(
                    child: _buildFontRow(
                        timerState, localSettings, localSettingsNotifier))
              ]);
  }

  Widget _buildFontRow(TimerState timerState, LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFontOption('Aa', AppTextStyles.kumbhSans, timerState,
            localSettings, localSettingsNotifier),
        const SizedBox(
          width: 16,
        ),
        _buildFontOption('Aa', AppTextStyles.robotoSlab, timerState,
            localSettings, localSettingsNotifier),
        const SizedBox(
          width: 16,
        ),
        _buildFontOption('Aa', AppTextStyles.spaceMono, timerState,
            localSettings, localSettingsNotifier),
      ],
    );
  }

  Widget _buildColor(
      TimerState timerState, LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier, bool isTablet) {
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
                _buildColorRow(
                    localSettings, localSettingsNotifier, timerState),
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
                _buildColorRow(
                    localSettings, localSettingsNotifier, timerState),
              ]);
  }

  Widget _buildColorRow(LocalSettings localSettings, LocalSettingsNotifier localSettingsNotifier, TimerState timerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorOption(AppColors.orangeRed, localSettings,
            localSettingsNotifier, timerState),
        const SizedBox(
          width: 16,
        ),
        _buildColorOption(AppColors.lightBlue, localSettings,
            localSettingsNotifier, timerState),
        const SizedBox(
          width: 16,
        ),
        _buildColorOption(AppColors.lightPurle, localSettings,
            localSettingsNotifier, timerState),
      ],
    );
  }

  Widget _buildNumberInput(
      TimerMode mode, int timeInSec, int min, int max, LocalSettingsNotifier localSettingsNotifier, bool isTablet) {
    return NumberInput(
        title: localSettingsNotifier.getName(mode),
        initialValue: timeInSec ~/ 60,
        minValue: min,
        maxValue: max,
        onValueChanged: (value) =>
            localSettingsNotifier.updateTime(mode, value),
        isTablet: isTablet);
  }

  Widget _buildFontOption(
      String text,
      String fontFamily,
      TimerState timerState,
      LocalSettings localSettings,
      LocalSettingsNotifier localSettingsNotifier) {
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
            color: localSettings.fontFamily != fontFamily
                ? Colors.transparent
                : AppColors.lightGray,
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
              color: localSettings.color != color
                  ? Colors.transparent
                  : AppColors.lightGray,
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
