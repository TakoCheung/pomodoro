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
      child: Container(
        height: 490,
        width: 540,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
            const CustomDivider(spaceBefore: 20, spaceAfter: 20),
            const Text(
              'TIME (MINUTES)',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 10),
            isTablet
                ? _buildTimeRow(localSettings)
                : _buildTimeColumn(localSettings),
            const CustomDivider(spaceBefore: 20, spaceAfter: 20),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                'FONT',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 10),
              Container(
                child: isTablet
                    ? _buildFontRow(
                        timerState, localSettings, localSettingsNotifier)
                    : _buildFontColumn(
                        timerState, localSettings, localSettingsNotifier),
              )
            ]),
            const CustomDivider(spaceBefore: 20, spaceAfter: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                'COLOR',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 10),
              isTablet
                  ? _buildColorRow(localSettings)
                  : _buildColorColumn(localSettings),
            ]),
            const CustomDivider(spaceBefore: 20, spaceAfter: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  timerNotifier.updateSettings(localSettings);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Apply', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(localSettings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNumberInput('Pomodoro', localSettings.initPomodoro, 25, 60,
            localSettings.initPomodoro),
        _buildNumberInput('Short Break', localSettings.initShortBreak, 5, 15,
            localSettings.initShortBreak),
        _buildNumberInput('Long Break', localSettings.initLongBreak, 15, 30,
            localSettings.initLongBreak),
      ],
    );
  }

  Widget _buildTimeColumn(localSettings) {
    return Column(
      children: [
        _buildNumberInput('Pomodoro', localSettings.initPomodoro, 25, 60,
            localSettings.initPomodoro),
        _buildNumberInput('Short Break', localSettings.initShortBreak, 5, 15,
            localSettings.initShortBreak),
        _buildNumberInput('Long Break', localSettings.initLongBreak, 15, 30,
            localSettings.initLongBreak),
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
          width: 10,
        ),
        _buildFontOption('Aa', AppTextStyles.robotoSlab, timerState,
            localSettings, localSettingsNotifier),
        const SizedBox(
          width: 10,
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
          width: 10,
        ),
        _buildFontOption('Aa', AppTextStyles.robotoSlab, timerState,
            localSettings, localSettingsNotifier),
        const SizedBox(
          width: 10,
        ),
        _buildFontOption('Aa', AppTextStyles.spaceMono, timerState,
            localSettings, localSettingsNotifier),
      ],
    );
  }

  Widget _buildColorRow(localSettings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildColorOption(
            AppColors.orangeRed, localSettings.color == AppColors.orangeRed,
            () {
          localSettings.color = AppColors.orangeRed;
        }),
        const SizedBox(
          width: 10,
        ),
        _buildColorOption(
            AppColors.lightBlue, localSettings.color == AppColors.lightBlue,
            () {
          localSettings = AppColors.lightBlue;
        }),
        const SizedBox(
          width: 10,
        ),
        _buildColorOption(
            AppColors.lightPurle, localSettings.color == AppColors.lightPurle,
            () {
          localSettings = AppColors.lightPurle;
        }),
      ],
    );
  }

  Widget _buildColorColumn(localSettings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColorOption(
            AppColors.orangeRed, localSettings.color == AppColors.orangeRed,
            () {
          localSettings.color = AppColors.orangeRed;
        }),
        const SizedBox(
          width: 10,
        ),
        _buildColorOption(
            AppColors.lightBlue, localSettings.color == AppColors.lightBlue,
            () {
          localSettings = AppColors.lightBlue;
        }),
        const SizedBox(
          width: 10,
        ),
        _buildColorOption(
            AppColors.lightPurle, localSettings.color == AppColors.lightPurle,
            () {
          localSettings = AppColors.lightPurle;
        }),
      ],
    );
  }

  Widget _buildNumberInput(
      String title, int time, int min, int max, int value) {
    return NumberInput(
      title: title,
      initialValue: time ~/ 60,
      minValue: min,
      maxValue: max,
      onValueChanged: (value) => value * 60,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: currentActive ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: localSettings.fontFamily == fontFamily
                ? Colors.transparent
                : Colors.grey.shade300,
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

  Widget _buildColorOption(Color color, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color,
        radius: 25,
        child: isActive ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const SettingsScreen(),
  );
}
