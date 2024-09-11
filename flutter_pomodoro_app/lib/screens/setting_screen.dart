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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            clipBehavior: Clip.none,
            height: 464,
            width: 540,
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
                    ? _buildTimeRow(localSettings, localSettingsNotifier)
                    : _buildTimeColumn(localSettings, localSettingsNotifier),
                const CustomDivider(
                  spaceBefore: 30,
                ),
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FONT',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        child: isTablet
                            ? _buildFontRow(timerState, localSettings,
                                localSettingsNotifier)
                            : _buildFontColumn(timerState, localSettings,
                                localSettingsNotifier),
                      )
                    ]),
                const CustomDivider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'COLOR',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 10),
                      isTablet
                          ? _buildColorRow(
                              localSettings, localSettingsNotifier, timerState)
                          : _buildColorColumn(
                              localSettings, localSettingsNotifier, timerState),
                    ]),
              ],
            ),
          ),
          Positioned(
            bottom: -20,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
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

  Widget _buildTimeRow(localSettings, localSettingsNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNumberInput(TimerMode.pomodoro, localSettings.initPomodoro, 25,
            60, localSettingsNotifier),
        _buildNumberInput(TimerMode.shortBreak, localSettings.initShortBreak, 5,
            15, localSettingsNotifier),
        _buildNumberInput(TimerMode.longBreak, localSettings.initLongBreak, 15,
            30, localSettingsNotifier),
      ],
    );
  }

  Widget _buildTimeColumn(localSettings, localSettingsNotifier) {
    return Column(
      children: [
        _buildNumberInput(TimerMode.pomodoro, localSettings.initPomodoro, 25,
            60, localSettingsNotifier),
        _buildNumberInput(TimerMode.shortBreak, localSettings.initShortBreak, 5,
            15, localSettingsNotifier),
        _buildNumberInput(TimerMode.longBreak, localSettings.initLongBreak, 15,
            30, localSettingsNotifier),
      ],
    );
  }

  Widget _buildFontRow(timerState, localSettings, localSettingsNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  Widget _buildFontColumn(timerState, localSettings, localSettingsNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildColorRow(localSettings, localSettingsNotifier, timerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  Widget _buildColorColumn(localSettings, localSettingsNotifier, timerState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
      TimerMode mode, int timeInSec, int min, int max, localSettingsNotifier) {
    return NumberInput(
      title: localSettingsNotifier.getName(mode),
      initialValue: timeInSec ~/ 60,
      minValue: min,
      maxValue: max,
      onValueChanged: (value) => localSettingsNotifier.updateTime(mode, value),
    );
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
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(12.5),
        decoration: BoxDecoration(
          color: currentActive ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            strokeAlign: 9,
            color: localSettings.fontFamily != fontFamily
                ? Colors.transparent
                : AppColors.lightGray,
            width: 1.0,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: AppTextStyles.h3FontSize,
            color: currentActive ? Colors.white : Colors.black,
          ),
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
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: localSettings.color != color
                  ? Colors.transparent
                  : AppColors.lightGray,
              width: 1.0,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: color,
            // radius: 20,
            child: timerState.color == color
                ? const Icon(Icons.check, color: Colors.white)
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
