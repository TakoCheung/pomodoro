import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/design/app_colors.dart';
import 'package:flutter_pomodoro_app/design/app_text_styles.dart';

class NumberInput extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final String title;
  final void Function(int) onValueChanged;
  final bool isTablet;

  const NumberInput(
      {super.key,
      required this.initialValue,
      required this.title,
      this.minValue = 0,
      this.maxValue = 60,
      required this.onValueChanged,
      required this.isTablet});

  @override
  State<StatefulWidget> createState() {
    return _NumberInputState();
  }

  // @override
  // _NumberInputState createState() => _NumberInputState();
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
    return widget.isTablet
        ? LayoutBuilder(builder: (context, constraints) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getWidgets());
          })
        : LayoutBuilder(builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Align vertically center
              children: _getWidgets(),
            );
          });
  }

  List<Widget> _getWidgets() {
    return [
      Text(
        widget.title,
        style: const TextStyle(
            fontFamily: AppTextStyles.kumbhSans,
            fontSize: AppTextStyles.body2FontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
            height: AppTextStyles.body2LineSpacing),
      ),
      const SizedBox(height: 10),
      Container(
          width: 140,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: AppColors.lightGray,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  '$_value',
                  style: const TextStyle(
                      fontSize: AppTextStyles.bodyFontSize,
                      fontFamily: AppTextStyles.kumbhSans,
                      fontWeight: FontWeight.bold,
                      height: AppTextStyles
                          .body2LineSpacing), // Adjust font size to fit
                ),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up),
                          onPressed: _increment,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          onPressed: _decrement,
                          padding: EdgeInsets.zero,
                        ),
                      )
                    ],
                  )),
            ],
          )),
    ];
  }
}
