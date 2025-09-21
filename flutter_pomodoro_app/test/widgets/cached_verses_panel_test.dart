import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/components/timer/task_bar.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

class _StubService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async =>
      Passage(reference: 'Stub 1:1', text: 'stub');
}

class _FakeScriptureRepository extends ScriptureRepository {
  _FakeScriptureRepository({required List<Passage> history})
      : _historyLocal = history,
        super(service: _StubService());
  final List<Passage> _historyLocal;
  @override
  List<Passage> get history => List.unmodifiable(_historyLocal);
}

void main() {
  group('Cached Verses Panel (RED)', () {
    testWidgets('Task bar button opens panel with list items', (tester) async {
      final passages = [
        Passage(reference: 'John 3:16', text: 'For God so loved the world that He gave...'),
        Passage(reference: 'Psalm 23:1', text: 'The Lord is my shepherd I shall not want...'),
      ];
      await tester.pumpWidget(ProviderScope(
        overrides: [
          scriptureRepositoryProvider
              .overrideWithValue(_FakeScriptureRepository(history: passages)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TaskBar(
                actions: []), // Implementation will inject button internally or via consumer.
          ),
        ),
      ));
      await tester.pump();

      // Expect the new task bar cached verses button.
      final btn = find.byKey(const Key('taskbar_cached_verses_button'));
      expect(btn, findsOneWidget); // RED: currently should fail because button not implemented.

      await tester.tap(btn);
      await tester.pumpAndSettle();

      // Panel/dialog shows
      expect(find.byKey(const Key('cached_verses_panel')), findsOneWidget);
      // List key present
      expect(find.byKey(const Key('cached_verses_list')), findsOneWidget);
      // Row keys
      expect(find.byKey(const Key('cached_verse_tile_0')), findsOneWidget);
      expect(find.byKey(const Key('cached_verse_ref_0')), findsOneWidget);
      expect(find.byKey(const Key('cached_verse_text_0')), findsOneWidget);
      expect(find.byKey(const Key('cached_verse_tile_1')), findsOneWidget);
    });
  });
}
