import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/components/setting/number_input.dart';

void main() {
  testWidgets('NumberInput increments and decrements within bounds',
      (tester) async {
    int changed = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NumberInput(
          initialValue: 2,
          title: 'Test',
          minValue: 0,
          maxValue: 5,
          onValueChanged: (v) => changed = v,
          isTablet: false,
        ),
      ),
    ));

    expect(find.text('2'), findsOneWidget);

    // tap increment
    final incrementButton = find.byIcon(Icons.keyboard_arrow_up);
    await tester.tap(incrementButton);
    await tester.pumpAndSettle();
    expect(changed, 3);

    // tap decrement
    final decrementButton = find.byIcon(Icons.keyboard_arrow_down);
    await tester.tap(decrementButton);
    await tester.pumpAndSettle();
    expect(changed, 2);
  });
}
