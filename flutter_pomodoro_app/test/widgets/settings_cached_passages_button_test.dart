import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pomodoro_app/screens/setting_screen.dart';

void main() {
  testWidgets('Old cached passages debug button removed (migration)', (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: Scaffold(body: SettingsScreen()))));
    await tester.pumpAndSettle();
    // Ensure legacy key no longer present.
    expect(find.byKey(const Key('view_cached_passages_button')), findsNothing);
  });
}
