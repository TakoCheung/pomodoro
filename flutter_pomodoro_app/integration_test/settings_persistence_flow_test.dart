import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Persisted settings drive initial UI without flicker', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings_v1':
          '{"pomodoro":1800,"shortBreak":300,"longBreak":900,"fontFamily":"SpaceMono","primaryColor":"#0A84FF","bibleVersionName":"ESV","bibleVersionId":"32664dc3288a28df-01","debugMode":false}'
    });
    app.main();
    await tester.pumpAndSettle();
    // Open settings and ensure the pomodoro field shows 30 immediately via value text
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();
    final valueFinder = find.byKey(const Key('pomodoro_value'));
    expect(valueFinder, findsOneWidget);
    final textWidget = tester.widget<Text>(valueFinder);
    expect(textWidget.data, '30');
  });

  testWidgets('User resets settings to defaults', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settingsButton')));
    await tester.pumpAndSettle();
    // Change pomodoro once, then reset
    await tester.tap(find.byKey(const Key('pomodoro_inc')));
    await tester.pump();
    final resetBtn = find.byKey(const Key('reset_defaults_button'));
    await tester.ensureVisible(resetBtn);
    await tester.tap(resetBtn);
    await tester.pumpAndSettle();
    // Verify defaults are shown immediately in the dialog (25)
    final valueFinder2 = find.byKey(const Key('pomodoro_value'));
    expect(valueFinder2, findsOneWidget);
    final textWidget2 = tester.widget<Text>(valueFinder2);
    expect(textWidget2.data, '25');
  });
}
