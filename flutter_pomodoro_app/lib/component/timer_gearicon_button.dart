import 'package:flutter/material.dart';

class GearIconButton extends StatelessWidget {
  const GearIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.settings,
        color: Colors.white.withOpacity(0.5),
      ),
      onPressed: () {
        // Implement the restart timer logic
      },
    );
  }
}
