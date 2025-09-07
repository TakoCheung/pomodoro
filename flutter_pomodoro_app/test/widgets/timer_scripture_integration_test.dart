import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/widgets/scripture_overlay.dart';

class FakeRepo extends ScriptureRepository {
  FakeRepo() : super(service: _FakeService());
}

class _FakeService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return Passage(reference: 'Genesis 1:1', text: 'In the beginning...');
  }
}

void main() {
  testWidgets('timer onComplete shows scripture via repository override', (tester) async {
    final fakeRepo = FakeRepo();
    final container = ProviderContainer(overrides: [
      scriptureRepositoryProvider.overrideWithValue(fakeRepo),
      scriptureShowDeciderProvider.overrideWithValue(() => true),
      scriptureProvider.overrideWith((ref, req) async {
        return Passage(reference: 'Genesis 1:1', text: 'In the beginning...');
      }),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            home: Scaffold(
                body: Stack(children: [
          ScriptureOverlay(bibleId: '32664dc3288a28df-01', passageId: 'GEN.1.1')
        ])))));

    // Initially overlay should be hidden
    expect(container.read(scriptureOverlayVisibleProvider), isFalse);

    // Trigger timer completion
    final notifier = container.read(timerProvider.notifier);
    notifier.triggerComplete();

    // Allow async operations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The overlay widget should be present (reference key)
    expect(find.byKey(const Key('scripture_reference')), findsOneWidget);
  });
}
