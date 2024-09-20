import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/screens/setting_screen.dart';

class GearIconButton extends StatelessWidget {
  const GearIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('settingsButton'),
      iconSize: 28,
      icon: const Icon(
        Icons.settings,
        color: AppColors.lightBlueGray,//TODO: did not match figma
      ),
      onPressed: () {
        showSettingsDialog(context);
      },
    );
  }
}
