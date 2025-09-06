import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';

class AlarmBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const AlarmBanner({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('alarm_banner'),
      width: double.infinity,
      color: AppColors.orangeRed,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Time\'s up! 🎯',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            key: const Key('alarm_dismiss'),
            onPressed: onDismiss,
            child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
