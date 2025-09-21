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

class _EmptyScriptureRepository extends ScriptureRepository {
  _EmptyScriptureRepository() : super(service: _StubService());
  @override
  List<Passage> get history => const [];
}

void main() {
  group('Cached Verses Panel Empty (RED)', () {
    testWidgets('Empty history shows empty state', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          scriptureRepositoryProvider.overrideWithValue(_EmptyScriptureRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TaskBar(actions: []),
          ),
        ),
      ));
      await tester.pump();

      final btn = find.byKey(const Key('taskbar_cached_verses_button'));
      expect(btn, findsOneWidget); // RED: should fail until button added.
      await tester.tap(btn);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cached_verses_panel')), findsOneWidget);
      expect(find.byKey(const Key('cached_verses_empty')), findsOneWidget);
      expect(find.byKey(const Key('cached_verses_list')), findsNothing);
    });
  });
}
