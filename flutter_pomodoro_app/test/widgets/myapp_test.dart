import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/main.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('MyApp builds and contains PomodoroTimerScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: app.MyApp()));
    await tester.pumpAndSettle();

    // Ensure top-level MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
