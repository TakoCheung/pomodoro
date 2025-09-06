import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

// A minimal service stub; not used by the test logic.
class _SvcStub implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    throw UnimplementedError();
  }
}

class _FakeRepo extends ScriptureRepository {
  final List<Passage> _fakeHistory;
  _FakeRepo(this._fakeHistory) : super(service: _SvcStub());
  @override
  List<Passage> get history => List.unmodifiable(_fakeHistory);
}

void main() {
  testWidgets('Debug button shows cached passages dialog listing history', (tester) async {
    final fakeHistory = [
      Passage(reference: 'Genesis 1:1', text: 'In the beginning God created...'),
      Passage(reference: 'John 3:16', text: 'For God so loved the world...'),
    ];

    // Start with normal settings; we'll toggle the switch to enable debug.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        scriptureRepositoryProvider.overrideWithValue(_FakeRepo(fakeHistory)),
      ],
      child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
    ));

    await tester.pumpAndSettle();

    // Toggle Debug Mode switch on (use specific key to avoid ambiguity)
    expect(find.text('Debug Mode'), findsOneWidget);
    final debugSwitch = find.byKey(const Key('debug_mode_switch'));
    expect(debugSwitch, findsOneWidget);
    await tester.tap(debugSwitch);
    await tester.pumpAndSettle();

    // Button should be visible
    final btn = find.byKey(const Key('view_cached_passages_button'));
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle();

    // Dialog shows the items
    expect(find.byKey(const Key('cached_passages_dialog')), findsOneWidget);
    expect(find.text('Genesis 1:1'), findsWidgets);
    expect(find.text('John 3:16'), findsWidgets);
  });
}
