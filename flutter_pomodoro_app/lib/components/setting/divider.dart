import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';

class CustomDivider extends StatelessWidget {
  final double spaceBefore;
  final double spaceAfter;
  final Color color;

  const CustomDivider({
    super.key,
    this.spaceBefore = 20,
    this.spaceAfter = 20,
    this.color = AppColors.divider, // Assuming AppColors.divider is defined elsewhere
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: spaceBefore),
        Divider(height: 1, color: color, ),
        SizedBox(height: spaceAfter),
      ],
    );
  }
}
