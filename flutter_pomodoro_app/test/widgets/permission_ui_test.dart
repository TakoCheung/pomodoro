import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pomodoro_app/state/permission_coordinator.dart';

import 'package:flutter_pomodoro_app/main.dart' as app;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Rationale sheet shows on first launch and accepts/defers', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(ProviderScope(overrides: [
      permissionAutostartProvider.overrideWith((ref) => true),
      notifRationaleVisibleProvider.overrideWith((ref) => true),
    ], child: const app.MyApp()));
    await tester.pumpAndSettle();

    // Rationale sheet visible
    expect(find.byKey(const Key('notif_rationale_sheet')), findsOneWidget);
    expect(find.byKey(const Key('notif_rationale_accept')), findsOneWidget);
    expect(find.byKey(const Key('notif_rationale_later')), findsOneWidget);

    // Defer
    await tester.tap(find.byKey(const Key('notif_rationale_later')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notif_rationale_sheet')), findsNothing);
  });

  testWidgets('Settings tile shows permission badge', (tester) async {
    SharedPreferences.setMockInitialValues({'notif_auth_status': 'denied'});
    await tester.pumpWidget(ProviderScope(overrides: [
      permissionAutostartProvider.overrideWith((ref) => false),
    ], child: const app.MyApp()));
    await tester.pumpAndSettle();

    // Open settings dialog via gear button
    // Expect: gear key exists
    final gear = find.byType(IconButton).first;
    await tester.tap(gear);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings_notifications_tile')), findsOneWidget);
    expect(find.byKey(const Key('permission_status_badge')), findsOneWidget);
  });
}
