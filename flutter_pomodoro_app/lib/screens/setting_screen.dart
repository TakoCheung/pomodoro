import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/setting/divider.dart';
import 'package:flutter_pomodoro_app/components/setting/number_input.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            clipBehavior: Clip.none,
            height: isTablet ? 464 : 575,
            width: isTablet ? 540 : 327,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    ]),
                const CustomDivider(spaceAfter: 30, spaceBefore: 25),
                const Text(
                  'TIME (MINUTES)',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 10),
                isTablet
                    ? _buildTimeRow(
                        localSettings, localSettingsNotifier, isTablet)
                    : _buildTimeColumn(
                        localSettings, localSettingsNotifier, isTablet),
                const CustomDivider(
                  spaceBefore: 30,
                ),
                _buildFonts(
                    timerState, localSettings, localSettingsNotifier, isTablet),
                const CustomDivider(),
                _buildColor(
                    timerState, localSettings, localSettingsNotifier, isTablet)
              ],
            ),
          ),
          Positioned(
            bottom: -26.5,
            left: 0,
            right: 0,
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
                    fixedSize: const Size(140, 53)),
                child: const Text('Apply',
                    style: TextStyle(
                        fontSize: AppTextStyles.h3FontSize,
                        fontFamily: AppTextStyles.kumbhSans,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white)),
              ),
            ),
          )
        ]));
  }

  Widget _buildTimeRow(localSettings, localSettingsNotifier, isTablet) {
    return Row(
      key: const Key('timeSection'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNumberInput(TimerMode.pomodoro, localSettings.initPomodoro, 25,
            60, localSettingsNotifier, isTablet),
        _buildNumberInput(TimerMode.shortBreak, localSettings.initShortBreak, 5,
            15, localSettingsNotifier, isTablet),
        _buildNumberInput(TimerMode.longBreak, localSettings.initLongBreak, 15,
            30, localSettingsNotifier, isTablet),
      ],
    );
  }

  Widget _buildTimeColumn(localSettings, localSettingsNotifier, isTablet) {
    return Column(
      key: const Key('timeSection'),
      children: [
        _buildNumberInput(TimerMode.pomodoro, localSettings.initPomodoro, 25,
            60, localSettingsNotifier, isTablet),
        const SizedBox(height: 10),
        _buildNumberInput(TimerMode.shortBreak, localSettings.initShortBreak, 5,
            15, localSettingsNotifier, isTablet),
        const SizedBox(height: 10),
        _buildNumberInput(TimerMode.longBreak, localSettings.initLongBreak, 15,
            30, localSettingsNotifier, isTablet),
      ],
    );
  }

  Widget _buildFonts(
      timerState, localSettings, localSettingsNotifier, isTablet) {
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

  Widget _buildFontRow(timerState, localSettings, localSettingsNotifier) {
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
      timerState, localSettings, localSettingsNotifier, isTablet) {
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

  Widget _buildColorRow(localSettings, localSettingsNotifier, timerState) {
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
      mode, timeInSec, min, max, localSettingsNotifier, isTablet) {
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
