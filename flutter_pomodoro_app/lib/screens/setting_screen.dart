import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/setting/divider.dart';
import 'package:flutter_pomodoro_app/components/setting/number_input.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.watch(timerProvider.notifier);
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
            const CustomDivider(),
            const Text(
              'TIME (MINUTES)',
              style: TextStyle(
                fontSize: AppTextStyles.h4FontSize,
                fontWeight: FontWeight.bold,
                fontFamily: AppTextStyles.kumbhSans,
                letterSpacing: AppTextStyles.h4LetterSpacing,
                height: AppTextStyles.h4LineSpacing,
                color: AppColors.darkDarkBlue,
              ),
            ),
            const SizedBox(height: 10),
            isTablet
                ? _buildTimeRow(timerState, timerNotifier)
                : _buildTimeColumn(timerState, timerNotifier),
            const CustomDivider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              const Text(
                'FONT',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                child: isTablet
                    ? _buildFontRow(timerState, timerNotifier)
                    : _buildFontColumn(timerState, timerNotifier),
              )
            ]),
            const CustomDivider(),
            const Text(
              'COLOR',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            isTablet
                ? _buildColorRow(timerState, timerNotifier)
                : _buildColorColumn(timerState, timerNotifier),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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

  Widget _buildTimeRow(timerState, timerNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNumberInput('Pomodoro', timerState.initPomodoro, 25, 60, (value) {
          timerNotifier.updatePomodoroDuration(value * 60);
        }),
        _buildNumberInput('Short Break', timerState.initShortBreak, 5, 15,
            (value) {
          timerNotifier.updateShortBreakDuration(value * 60);
        }),
        _buildNumberInput('Long Break', timerState.initLongBreak, 15, 30,
            (value) {
          timerNotifier.updateLongBreakDuration(value * 60);
        }),
      ],
    );
  }

  Widget _buildTimeColumn(timerState, timerNotifier) {
    return Column(
      children: [
        _buildNumberInput('Pomodoro', timerState.initPomodoro, 25, 60, (value) {
          timerNotifier.updatePomodoroDuration(value * 60);
        }),
        const SizedBox(height: 10),
        _buildNumberInput('Short Break', timerState.initShortBreak, 5, 15,
            (value) {
          timerNotifier.updateShortBreakDuration(value * 60);
        }),
        const SizedBox(height: 10),
        _buildNumberInput('Long Break', timerState.initLongBreak, 15, 30,
            (value) {
          timerNotifier.updateLongBreakDuration(value * 60);
        }),
      ],
    );
  }

  Widget _buildFontRow(timerState, timerNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFontOption('Aa', AppTextStyles.kumbhSans,
            timerState.fontFamily == AppTextStyles.kumbhSans, () {
          timerNotifier.updateFontFamily(AppTextStyles.kumbhSans);
        }),
        const SizedBox(width: 10,),
        _buildFontOption('Aa', AppTextStyles.spaceMono,
            timerState.fontFamily == AppTextStyles.spaceMono, () {
          timerNotifier.updateFontFamily(AppTextStyles.spaceMono);
        }),
        const SizedBox(width: 10,),
        _buildFontOption('Aa', AppTextStyles.robotoSlab,
            timerState.fontFamily == AppTextStyles.robotoSlab, () {
          timerNotifier.updateFontFamily(AppTextStyles.robotoSlab);
        }),
      ],
    );
  }

  Widget _buildFontColumn(timerState, timerNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFontOption('Aa', AppTextStyles.kumbhSans,
            timerState.fontFamily == AppTextStyles.kumbhSans, () {
          timerNotifier.updateFontFamily(AppTextStyles.kumbhSans);
        }),
        const SizedBox(height: 10),
        _buildFontOption('Aa', AppTextStyles.spaceMono,
            timerState.fontFamily == AppTextStyles.spaceMono, () {
          timerNotifier.updateFontFamily(AppTextStyles.spaceMono);
        }),
        const SizedBox(height: 10),
        _buildFontOption('Aa', AppTextStyles.robotoSlab,
            timerState.fontFamily == AppTextStyles.robotoSlab, () {
          timerNotifier.updateFontFamily(AppTextStyles.robotoSlab);
        }),
      ],
    );
  }

  Widget _buildColorRow(timerState, timerNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildColorOption(Colors.red, 'color1', timerState.color == Colors.red,
            () {
          timerNotifier.updateColor(Colors.red);
        }),
        _buildColorOption(
            Colors.cyan, 'color2', timerState.color == Colors.cyan, () {
          timerNotifier.updateColor(Colors.cyan);
        }),
        _buildColorOption(
            Colors.purple, 'color3', timerState.color == Colors.purple, () {
          timerNotifier.updateColor(Colors.purple);
        }),
      ],
    );
  }

  Widget _buildColorColumn(timerState, timerNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColorOption(Colors.red, 'color1', timerState.color == Colors.red,
            () {
          timerNotifier.updateColor(Colors.red);
        }),
        const SizedBox(height: 10),
        _buildColorOption(
            Colors.cyan, 'color2', timerState.color == Colors.cyan, () {
          timerNotifier.updateColor(Colors.cyan);
        }),
        const SizedBox(height: 10),
        _buildColorOption(
            Colors.purple, 'color3', timerState.color == Colors.purple, () {
          timerNotifier.updateColor(Colors.purple);
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
            fontSize: 20,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(
      Color color, String colorName, bool isActive, VoidCallback onTap) {
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
