import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/widgets/scripture_overlay.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _FakeService implements ScriptureServiceInterface {
  final Passage passage;
  _FakeService(this.passage);
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return passage;
  }
}

class _BadService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    throw Exception('network');
  }
}

void main() {
  testWidgets('ScriptureOverlay shows fetched passage from API', (tester) async {
    final fake = _FakeService(Passage(reference: 'John 3:16', text: 'For God so loved the world...', verses: []));

    await tester.pumpWidget(ProviderScope(overrides: [
      scriptureServiceProvider.overrideWithValue(fake),
    ], child: const MaterialApp(home: Scaffold(body: ScriptureOverlay(bibleId: '32664dc3288a28df-01', passageId: 'JOH.3.16')))));

    // Await the FutureProvider to complete
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('scripture_reference')), findsOneWidget);
    expect(find.byKey(const Key('scripture_text')), findsOneWidget);
    expect(find.textContaining('For God so loved'), findsOneWidget);
  });

  testWidgets('ScriptureOverlay hides on fetch error', (tester) async {
    final bad = _BadService();

    await tester.pumpWidget(ProviderScope(overrides: [
      scriptureServiceProvider.overrideWithValue(bad),
    ], child: const MaterialApp(home: Scaffold(body: ScriptureOverlay(bibleId: '32664dc3288a28df-01', passageId: 'GEN.1.1')))));

    // When the provider errors, the widget returns SizedBox.shrink => nothing to find
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('scripture_reference')), findsNothing);
    expect(find.byKey(const Key('scripture_text')), findsNothing);
  });
}
