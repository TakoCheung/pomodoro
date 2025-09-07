import 'package:flutter/material.dart';

class MissedAlarmOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  const MissedAlarmOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const Key('missed_alarm_overlay'),
      children: [
        // Dark scrim; tapping anywhere outside the dialog dismisses it.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: Container(color: Colors.black54),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Timer completed while you were away'),
                  const SizedBox(height: 12),
                  TextButton(
                    key: const Key('missed_alarm_dismiss'),
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
