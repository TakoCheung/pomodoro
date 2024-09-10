import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/setting/divider.dart';
import 'package:flutter_pomodoro_app/components/setting/number_input.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalSettings {
  int initPomodoro;
  int initShortBreak;
  int initLongBreak;
  String fontFamily;
  Color color;

  LocalSettings({
    required this.initPomodoro,
    required this.initShortBreak,
    required this.initLongBreak,
    required this.fontFamily,
    required this.color,
  });

  LocalSettings copyWith(
      {int? initPomodoro,
      int? initLongBreak,
      int? initShortBreak,
      String? fontFamily,
      Color? color}) {
    return LocalSettings(
        initLongBreak: initLongBreak ?? this.initLongBreak,
        initPomodoro: initPomodoro ?? this.initPomodoro,
        initShortBreak: initShortBreak ?? this.initShortBreak,
        fontFamily: fontFamily ?? this.fontFamily,
        color: color ?? this.color);
  }
}

final localSettingsProvider = StateProvider<LocalSettings>((ref) {
  final globalSettings = ref.read(timerProvider);
  return LocalSettings(
    initPomodoro: globalSettings.initPomodoro,
    initShortBreak: globalSettings.initShortBreak,
    initLongBreak: globalSettings.initLongBreak,
    fontFamily: globalSettings.fontFamily,
    color: globalSettings.color,
  );
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localSettings = ref.watch(localSettingsProvider);
    final timerState = ref.read(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
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
                    ? _buildFontRow(localSettings)
                    : _buildFontColumn(localSettings),
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
            (value) {
          localSettings.initPomodoro = value * 60;
        }),
        _buildNumberInput('Short Break', localSettings.initShortBreak, 5, 15,
            (value) {
          localSettings.initShortBreak = value * 60;
        }),
        _buildNumberInput('Long Break', localSettings.initLongBreak, 15, 30,
            (value) {
          localSettings.initLongBreak = value * 60;
        }),
      ],
    );
  }

  Widget _buildTimeColumn(localSettings) {
    return Column(
      children: [
        _buildNumberInput('Pomodoro', localSettings.initPomodoro, 25, 60,
            (value) {
          localSettings.initPomodoro = value * 60;
        }),
        _buildNumberInput('Short Break', localSettings.initShortBreak, 5, 15,
            (value) {
          localSettings.initShortBreak = value * 60;
        }),
        _buildNumberInput('Long Break', localSettings.initLongBreak, 15, 30,
            (value) {
          localSettings.initLongBreak = value * 60;
        }),
      ],
    );
  }

  Widget _buildFontRow(localSettings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFontOption('Aa', AppTextStyles.kumbhSans,
            localSettings.fontFamily == AppTextStyles.kumbhSans, () {
          localSettings.fontFamily = AppTextStyles.kumbhSans;
        }),
        const SizedBox(
          width: 10,
        ),
        _buildFontOption('Aa', AppTextStyles.spaceMono,
            localSettings.fontFamily == AppTextStyles.spaceMono, () {
          localSettings = AppTextStyles.spaceMono;
        }),
        const SizedBox(
          width: 10,
        ),
        _buildFontOption('Aa', AppTextStyles.robotoSlab,
            localSettings.fontFamily == AppTextStyles.robotoSlab, () {
          localSettings = AppTextStyles.robotoSlab;
        }),
      ],
    );
  }

  Widget _buildFontColumn(localSettings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFontOption('Aa', AppTextStyles.kumbhSans,
            localSettings.fontFamily == AppTextStyles.kumbhSans, () {
          localSettings.fontFamily = AppTextStyles.kumbhSans;
        }),
        const SizedBox(
          width: 10,
        ),
        _buildFontOption('Aa', AppTextStyles.spaceMono,
            localSettings.fontFamily == AppTextStyles.spaceMono, () {
          localSettings = AppTextStyles.spaceMono;
        }),
        const SizedBox(
          width: 10,
        ),
        _buildFontOption('Aa', AppTextStyles.robotoSlab,
            localSettings.fontFamily == AppTextStyles.robotoSlab, () {
          localSettings = AppTextStyles.robotoSlab;
        }),
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
      String title, int time, int min, int max, Function(int) onValueChanged) {
    return NumberInput(
      title: title,
      initialValue: time ~/ 60,
      minValue: min,
      maxValue: max,
      onValueChanged: onValueChanged,
    );
  }

  Widget _buildFontOption(
      String text, String fontFamily, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: AppTextStyles.h3FontSize,
            color: isActive ? Colors.white : Colors.black,
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
