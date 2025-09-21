import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/widgets/cached_verses_panel.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

class _FakeService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return Passage(reference: 'Ps 23:1', text: 'The Lord is my shepherd; I shall not want.');
  }
}

class _FakeRepo extends ScriptureRepository {
  _FakeRepo(List<Passage> seed)
      : _seed = seed,
        super(service: _FakeService());
  final List<Passage> _seed;
  @override
  List<Passage> get history => _seed;
}

Widget _host(double width, List<Passage> seed) => ProviderScope(
      overrides: [scriptureRepositoryProvider.overrideWithValue(_FakeRepo(seed))],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: width, child: const CachedVersesPanel()),
          ),
        ),
      ),
    );

void main() {
  testWidgets('CachedVersesPanel multi-width golden', (tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue = const Size(1200, 1000);

    final passages = [
      Passage(
          reference: 'Gen 1:1', text: 'In the beginning God created the heavens and the earth.'),
      Passage(
          reference: 'John 3:16',
          text: 'For God so loved the world that he gave his one and only Son...'),
      Passage(reference: 'Ps 23:1', text: 'The Lord is my shepherd; I shall not want.'),
    ];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _host(320, passages)),
            Expanded(child: _host(480, passages)),
            Expanded(child: _host(640, passages)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
        find.byType(Row), matchesGoldenFile('../goldens/cached_verses_panel_multi_width.png'));

    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
