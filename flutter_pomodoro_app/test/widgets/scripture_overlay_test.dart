import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_pomodoro_app/widgets/scripture_overlay.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/models/scripture_request.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

void main() {
  testWidgets('ScriptureOverlay shows passage when provider has data', (tester) async {
    // Override the family provider to immediately return our test passage for any request.
    final overrides = [
      scriptureProvider.overrideWith((ref, req) async {
        return Passage(reference: 'Genesis 1:1', text: 'In the beginning God created the heavens and the earth.');
      }),
    ];
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              ScriptureOverlay(bibleId: 'eng-ESV', passageId: 'GEN.1.1'),
            ],
          ),
        ),
      ),
    ),
  );

  // Allow async provider to resolve; pump twice for async provider + widget rebuild
  await tester.pump();
  await tester.pump();

  expect(find.byKey(const Key('scripture_reference')), findsOneWidget);
  expect(find.byKey(const Key('scripture_text')), findsOneWidget);
  });
}

class FakeScriptureService implements ScriptureServiceInterface {
  static bool wasCalled = false;

  FakeScriptureService();

  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    wasCalled = true;
    return Passage(reference: 'Genesis 1:1', text: 'In the beginning God created the heavens and the earth.');
  }
}
