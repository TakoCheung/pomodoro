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
    return Passage(
        reference: 'Gen 1:1', text: 'In the beginning God created the heavens and the earth.');
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

void main() {
  testWidgets('CachedVersesPanel golden – light & dark, non-empty & empty', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(600, 900);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final passages = [
      Passage(
          reference: 'Gen 1:1', text: 'In the beginning God created the heavens and the earth.'),
      Passage(
          reference: 'John 3:16',
          text: 'For God so loved the world that he gave his one and only Son...'),
    ];

    Future<void> pumpPanel({required List<Passage> seed, required ThemeMode mode}) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [scriptureRepositoryProvider.overrideWithValue(_FakeRepo(seed))],
        child: MaterialApp(
          themeMode: mode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const Scaffold(body: Center(child: CachedVersesPanel())),
        ),
      ));
      await tester.pumpAndSettle();
    }

    // Light / non-empty
    await pumpPanel(seed: passages, mode: ThemeMode.light);
    await expectLater(find.byType(CachedVersesPanel),
        matchesGoldenFile('../goldens/cached_verses_panel_light_non_empty.png'));
    // Light / empty
    await pumpPanel(seed: const [], mode: ThemeMode.light);
    await expectLater(find.byType(CachedVersesPanel),
        matchesGoldenFile('../goldens/cached_verses_panel_light_empty.png'));
    // Dark / non-empty
    await pumpPanel(seed: passages, mode: ThemeMode.dark);
    await expectLater(find.byType(CachedVersesPanel),
        matchesGoldenFile('../goldens/cached_verses_panel_dark_non_empty.png'));
    // Dark / empty
    await pumpPanel(seed: const [], mode: ThemeMode.dark);
    await expectLater(find.byType(CachedVersesPanel),
        matchesGoldenFile('../goldens/cached_verses_panel_dark_empty.png'));

    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
