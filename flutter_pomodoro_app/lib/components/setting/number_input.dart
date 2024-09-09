import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';

class NumberInput extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final void Function(int) onValueChanged;

  const NumberInput({
    super.key,
    required this.initialValue,
    this.minValue = 0,
    this.maxValue = 100,
    required this.onValueChanged,
  });

  @override
  _NumberInputState createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  int _value = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _increment() {
    if (_value < widget.maxValue) {
      setState(() {
        _value++;
      });
      widget.onValueChanged(_value);
    }
  }

  void _decrement() {
    if (_value > widget.minValue) {
      setState(() {
        _value--;
      });
      widget.onValueChanged(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
          color: AppColors.lightGray,
        ),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_value'),
              Column(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  onPressed: _increment,
                  constraints: const BoxConstraints(maxHeight: 20),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: _decrement,
                  constraints: const BoxConstraints(maxHeight: 20),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
              ])
            ],
          ),
        ));
  }
}
