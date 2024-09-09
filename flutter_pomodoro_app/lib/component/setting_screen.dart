import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.read(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('TIME (MINUTES)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeSetting(
                  context,
                  'pomodoro',
                  timerState.initPomodoro,
                  (value) => timerNotifier.updatePomodoroDuration(value!),
                ),
                _buildTimeSetting(
                  context,
                  'short break',
                  timerState.initShortBreak,
                  (value) => timerNotifier.updateShortBreakDuration(value!),
                ),
                _buildTimeSetting(
                  context,
                  'long break',
                  timerState.initLongBreak,
                  (value) => timerNotifier.updateLongBreakDuration(value!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('FONT', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFontOption(context, 'Aa', 'font1'),
                _buildFontOption(context, 'Aa', 'font2'),
                _buildFontOption(context, 'Aa', 'font3'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('COLOR', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorOption(context, Colors.red, 'color1'),
                _buildColorOption(context, Colors.cyan, 'color2'),
                _buildColorOption(context, Colors.purple, 'color3'),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Apply', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSetting(BuildContext context, String label, int initialValue, ValueChanged<int?> onChanged) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 5),
        DropdownButton<int>(
          value: initialValue,
          items: List.generate(60, (index) => index + 1)
              .map((value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFontOption(BuildContext context, String text, String fontFamily) {
    return GestureDetector(
      onTap: () {
        // Update the font in the timer provider
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          text,
          style: TextStyle(fontFamily: fontFamily, fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, Color color, String colorName) {
    return GestureDetector(
      onTap: () {
        // Update the color in the timer provider
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 25,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const SettingsScreen(),
  );
}
