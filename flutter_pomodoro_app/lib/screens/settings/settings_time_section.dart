import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/components/setting/number_input.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/settings_controller.dart';

class SettingsTimeSection extends StatelessWidget {
  const SettingsTimeSection({
    super.key,
    required this.staged,
    required this.settingsCtlNotifier,
    required this.isTablet,
  });

  final SettingsControllerState staged;
  final SettingsController settingsCtlNotifier;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return isTablet
        ? Row(
            key: const Key('timeSection'),
            children: [
              Expanded(
                child: _buildNumberInput(
                  TimerMode.pomodoro,
                  staged.staged.initPomodoro,
                  staged.staged.debugMode ? 0 : 25,
                  60,
                  settingsCtlNotifier,
                  isTablet,
                  keyPrefix: 'pomodoro',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberInput(
                  TimerMode.shortBreak,
                  staged.staged.initShortBreak,
                  staged.staged.debugMode ? 0 : 5,
                  15,
                  settingsCtlNotifier,
                  isTablet,
                  keyPrefix: 'shortBreak',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberInput(
                  TimerMode.longBreak,
                  staged.staged.initLongBreak,
                  staged.staged.debugMode ? 0 : 15,
                  30,
                  settingsCtlNotifier,
                  isTablet,
                  keyPrefix: 'longBreak',
                ),
              ),
            ],
          )
        : Column(
            key: const Key('timeSection'),
            children: [
              _buildNumberInput(
                TimerMode.pomodoro,
                staged.staged.initPomodoro,
                staged.staged.debugMode ? 0 : 25,
                60,
                settingsCtlNotifier,
                isTablet,
                keyPrefix: 'pomodoro',
              ),
              const SizedBox(height: 10),
              _buildNumberInput(
                TimerMode.shortBreak,
                staged.staged.initShortBreak,
                staged.staged.debugMode ? 0 : 5,
                15,
                settingsCtlNotifier,
                isTablet,
                keyPrefix: 'shortBreak',
              ),
              const SizedBox(height: 10),
              _buildNumberInput(
                TimerMode.longBreak,
                staged.staged.initLongBreak,
                staged.staged.debugMode ? 0 : 15,
                30,
                settingsCtlNotifier,
                isTablet,
                keyPrefix: 'longBreak',
              ),
            ],
          );
  }

  Widget _buildNumberInput(
    TimerMode mode,
    int timeInSec,
    int min,
    int max,
    SettingsController settingsCtlNotifier,
    bool isTablet, {
    String? keyPrefix,
  }) {
    return NumberInput(
      title: _timerModeName(mode),
      initialValue: timeInSec ~/ 60,
      minValue: min,
      maxValue: max,
      onValueChanged: (value) {
        int seconds;
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
      testKeyPrefix: keyPrefix,
    );
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
