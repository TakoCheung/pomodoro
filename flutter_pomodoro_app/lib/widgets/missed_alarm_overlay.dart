import 'package:flutter/material.dart';

class MissedAlarmOverlay extends StatelessWidget {
  const MissedAlarmOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('missed_alarm_overlay'),
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: const Text('Timer completed while you were away'),
      ),
    );
  }
}
