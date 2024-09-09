import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/component/setting_screen.dart';

class GearIconButton extends StatelessWidget {
  const GearIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 28,
      icon: Icon(
        Icons.settings,
        color: Colors.white.withOpacity(0.5),
      ),
      onPressed: () {
        showSettingsDialog(context);
      },
    );
  }
}
