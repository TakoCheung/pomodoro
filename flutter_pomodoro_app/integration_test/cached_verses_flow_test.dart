import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pomodoro_app/main.dart' as app;
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

class _FakeRepo extends ScriptureRepository {
  _FakeRepo() : super(service: _FakeService());
  @override
  List<Passage> get history => _history;
  final List<Passage> _history = [
    Passage(reference: 'Gen 1:1', text: 'In the beginning God created the heavens and the earth.'),
    Passage(
        reference: 'John 3:16',
        text: 'For God so loved the world that he gave his one and only Son...'),
  ];
}

class _FakeService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return Passage(reference: 'Ps 23:1', text: 'The Lord is my shepherd; I shall not want.');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Task bar button opens and closes Cached Verses panel showing history',
      (tester) async {
    final container = ProviderContainer(overrides: [
      scriptureRepositoryProvider.overrideWithValue(_FakeRepo()),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: app.MyApp()),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure task bar present
    expect(find.byKey(const Key('task_bar')), findsOneWidget);
    // New cached verses button present
    final buttonFinder = find.byKey(const Key('taskbar_cached_verses_button'));
    expect(buttonFinder, findsOneWidget);

    // Tap to open panel
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Panel and list appear, with two entries
    expect(find.byKey(const Key('cached_verses_panel')), findsOneWidget);
    expect(find.byKey(const Key('cached_verses_list')), findsOneWidget);
    expect(find.byKey(const Key('cached_verse_tile_0')), findsOneWidget);
    expect(find.byKey(const Key('cached_verse_tile_1')), findsOneWidget);

    // Close panel
    await tester.tap(find.byKey(const Key('cached_verses_close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cached_verses_panel')), findsNothing);

    // Re-open to verify it still works
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cached_verses_panel')), findsOneWidget);
  });
}
