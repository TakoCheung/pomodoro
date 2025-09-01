import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

import 'package:flutter_pomodoro_app/data/bible_versions.dart';
import 'package:flutter_pomodoro_app/models/bible_version.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/models/scripture_request.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/services/bible_catalog_service.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

class _FakeScriptureService implements ScriptureServiceInterface {
  final Passage result;
  _FakeScriptureService(this.result);
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async =>
      result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset dotenv before each test
    dotenv.dotenv.testLoad(fileInput: '');
  });

  group('bibleIdProvider precedence', () {
    test('returns explicit id from LocalSettings when set', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final notifier = c.read(localSettingsProvider.notifier);
      notifier.updateBibleVersion('My Version', 'my-id');
      expect(c.read(bibleIdProvider), 'my-id');
    });

    test('maps name from remote bibleVersionsProvider (match by abbreviation, name, label)',
        () async {
      final versions = <BibleVersion>[
        BibleVersion(id: 'id-1', name: 'Name One', abbreviation: 'ONE', language: 'en'),
        BibleVersion(id: 'id-2', name: 'Second', abbreviation: 'TWO', language: 'en'),
      ];
      final c = ProviderContainer(overrides: [
        // Return our fake list immediately
        bibleVersionsProvider.overrideWith((ref) async => versions),
      ]);
      addTearDown(c.dispose);

      // Ensure remote provider is loaded
      await c.read(bibleVersionsProvider.future);

      // Set name to match by abbreviation/displayName
      c.read(localSettingsProvider.notifier).updateBibleVersionName('ONE — Name One');
      expect(c.read(bibleIdProvider), 'id-1');

      // Now match by name
      c.read(localSettingsProvider.notifier).updateBibleVersionName('Second');
      expect(c.read(bibleIdProvider), 'id-2');
    });

    test('falls back to static map when remote missing and name in kBibleVersions', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      // Default LocalSettings name is kDefaultBibleVersionName (ESV)
      expect(c.read(bibleIdProvider), kBibleVersions[kDefaultBibleVersionName]);
    });

    test('falls back to BIBLE_ID from dotenv when not in map', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      // Use a name that's not in map to force env fallback
      c.read(localSettingsProvider.notifier).updateBibleVersionName('Unknown Version');
      dotenv.dotenv.testLoad(fileInput: 'BIBLE_ID=ENV-ID');
      expect(c.read(bibleIdProvider), 'ENV-ID');
    });

    test('final default when none available', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(localSettingsProvider.notifier).updateBibleVersionName('Not Mapped');
      // No env set
      expect(c.read(bibleIdProvider), '32664dc3288a28df-01');
    });
  });

  group('scriptureServiceProvider', () {
    test('throws when SCRIPTURE_API_KEY missing', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(() => c.read(scriptureServiceProvider), throwsA(isA<UnimplementedError>()));
    });

    test('returns a service when SCRIPTURE_API_KEY present', () {
      dotenv.dotenv.testLoad(fileInput: 'SCRIPTURE_API_KEY=dummy');
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final svc = c.read(scriptureServiceProvider);
      expect(svc, isA<ScriptureServiceInterface>());
    });
  });

  group('scriptureProvider', () {
    test('delegates to service and returns Passage', () async {
      final fakePassage = Passage(reference: 'Gen 1:1', text: 'In the beginning');
      final c = ProviderContainer(overrides: [
        scriptureServiceProvider.overrideWithValue(_FakeScriptureService(fakePassage)),
      ]);
      addTearDown(c.dispose);
      final req = ScriptureRequest(bibleId: 'BID', passageId: 'GEN.1.1');
      final p = await c.read(scriptureProvider(req).future);
      expect(p.reference, 'Gen 1:1');
      expect(p.text, contains('beginning'));
    });
  });
}
