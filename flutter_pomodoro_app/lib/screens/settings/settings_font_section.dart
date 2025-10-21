import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/settings_controller.dart';

class SettingsFontSection extends StatelessWidget {
  const SettingsFontSection({
    super.key,
    required this.timerState,
    required this.staged,
    required this.settingsCtlNotifier,
    required this.isTablet,
  });

  final TimerState timerState;
  final SettingsControllerState staged;
  final SettingsController settingsCtlNotifier;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return isTablet
        ? Row(
            key: const Key('fontSection'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FONT', style: AppTextStyles.h4),
              const SizedBox(height: 10),
              // Using Flexible to avoid overflow while keeping row alignment
              Flexible(
                child: _FontRow(
                  timerState: timerState,
                  staged: staged,
                  settingsCtlNotifier: settingsCtlNotifier,
                ),
              ),
            ],
          )
        : Column(
            key: const Key('fontSection'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FONT', style: AppTextStyles.h4),
              const SizedBox(height: 10),
              _FontRow(
                timerState: timerState,
                staged: staged,
                settingsCtlNotifier: settingsCtlNotifier,
              ),
            ],
          );
  }
}

class _FontRow extends StatelessWidget {
  const _FontRow({
    required this.timerState,
    required this.staged,
    required this.settingsCtlNotifier,
  });

  final TimerState timerState;
  final SettingsControllerState staged;
  final SettingsController settingsCtlNotifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FontOption('Aa', AppTextStyles.kumbhSans, timerState, staged, settingsCtlNotifier),
        const SizedBox(width: 16),
        _FontOption('Aa', AppTextStyles.robotoSlab, timerState, staged, settingsCtlNotifier),
        const SizedBox(width: 16),
        _FontOption('Aa', AppTextStyles.spaceMono, timerState, staged, settingsCtlNotifier),
      ],
    );
  }
}

class _FontOption extends StatelessWidget {
  const _FontOption(
      this.text, this.fontFamily, this.timerState, this.staged, this.settingsCtlNotifier);

  final String text;
  final String fontFamily;
  final TimerState timerState;
  final SettingsControllerState staged;
  final SettingsController settingsCtlNotifier;

  @override
  Widget build(BuildContext context) {
    final currentActive = timerState.fontFamily == fontFamily;
    return GestureDetector(
      onTap: () => settingsCtlNotifier.updateStaged(fontFamily: fontFamily),
      child: Container(
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
