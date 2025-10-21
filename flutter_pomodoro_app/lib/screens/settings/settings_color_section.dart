import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/settings_controller.dart';

class SettingsColorSection extends StatelessWidget {
  const SettingsColorSection({
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
    final row = _ColorRow(
      staged: staged,
      settingsCtlNotifier: settingsCtlNotifier,
      timerState: timerState,
    );
    return isTablet
        ? Row(
            key: const Key('colorSection'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('COLOR', style: AppTextStyles.h4),
              const SizedBox(height: 10),
              row,
            ],
          )
        : Column(
            key: const Key('colorSection'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('COLOR', style: AppTextStyles.h4),
              const SizedBox(height: 10),
              row,
            ],
          );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.staged,
    required this.settingsCtlNotifier,
    required this.timerState,
  });

  final SettingsControllerState staged;
  final SettingsController settingsCtlNotifier;
  final TimerState timerState;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ColorOption(AppColors.orangeRed, staged, settingsCtlNotifier, timerState),
        const SizedBox(width: 16),
        _ColorOption(AppColors.lightBlue, staged, settingsCtlNotifier, timerState),
        const SizedBox(width: 16),
        _ColorOption(AppColors.lightPurle, staged, settingsCtlNotifier, timerState),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption(this.color, this.staged, this.settingsCtlNotifier, this.timerState);
  final Color color;
  final SettingsControllerState staged;
  final SettingsController settingsCtlNotifier;
  final TimerState timerState;

  @override
  Widget build(BuildContext context) {
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
            width: 2.0,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: timerState.color == color
              ? const Icon(Icons.check, color: AppColors.darkDarkBlue)
              : null,
        ),
      ),
    );
  }
}
