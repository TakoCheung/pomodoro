import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/services/bible_catalog_service.dart';
import 'package:flutter_pomodoro_app/models/bible_version.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

class _ThrowingCatalog implements BibleCatalogServiceInterface {
  @override
  Future<List<BibleVersion>> fetchBibles() => Future.error(Exception('should not be called'));
}

class _FixedCatalog implements BibleCatalogServiceInterface {
  final List<BibleVersion> list;
  _FixedCatalog(this.list);
  @override
  Future<List<BibleVersion>> fetchBibles() async => list;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('BibleCatalogService', () {
    test('fetchBibles sends api-key header and parses list on 200', () async {
      final client = MockHttpClient();
      final body = json.encode({
        'data': [
          {
            'id': 'esv',
            'name': 'English Standard Version',
            'abbreviation': 'ESV',
            'language': {'name': 'English'},
          },
          {
            'id': 'niv',
            'name': 'New International Version',
            'abbreviation': 'NIV',
            'language': {'name': 'English'},
          },
        ]
      });
      when(() => client.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(body, 200));

      final svc = BibleCatalogService(client: client, apiKey: 'KEY');
      final list = await svc.fetchBibles();
      expect(list, hasLength(2));
      expect(list.first.id, 'esv');

      verify(() => client.get(
            Uri.parse('https://api.scripture.api.bible/v1/bibles'),
            headers: {'api-key': 'KEY'},
          )).called(1);
    });

    test('fetchBibles throws on non-200', () async {
      final client = MockHttpClient();
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('nope', 500));
      final svc = BibleCatalogService(client: client, apiKey: 'KEY');
      expect(() => svc.fetchBibles(), throwsA(isA<Exception>()));
    });
  });

  group('bibleVersionsProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('returns cached list when present without calling service', () async {
      final cached = [
        BibleVersion(
                id: 'esv',
                name: 'English Standard Version',
                abbreviation: 'ESV',
                language: 'English')
            .toJson(),
      ];
      SharedPreferences.setMockInitialValues(<String, Object>{
        'bible_versions_cache_v1': json.encode(cached),
      });

      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) => SharedPreferences.getInstance()),
        bibleCatalogServiceProvider.overrideWithValue(_ThrowingCatalog()),
      ]);
      addTearDown(container.dispose);

      final list = await container.read(bibleVersionsProvider.future);
      expect(list, hasLength(1));
      expect(list.first.id, 'esv');
    });

    test('fetches from service and caches when no cache exists', () async {
      final versions = [
        BibleVersion(
                id: 'niv',
                name: 'New International Version',
                abbreviation: 'NIV',
                language: 'English')
            .toJson(),
      ];
      final fake = _FixedCatalog(versions.map((e) => BibleVersion.fromJson(e)).toList());

      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) => SharedPreferences.getInstance()),
        bibleCatalogServiceProvider.overrideWithValue(fake),
      ]);
      addTearDown(container.dispose);

      final list = await container.read(bibleVersionsProvider.future);
      expect(list, hasLength(1));
      expect(list.first.id, 'niv');

      final prefs = await container.read(sharedPreferencesProvider.future);
      final cachedStr = prefs.getString('bible_versions_cache_v1');
      expect(cachedStr, isNotNull);
      final decoded = json.decode(cachedStr!) as List<dynamic>;
      expect(decoded, hasLength(1));
      expect((decoded.first as Map<String, dynamic>)['id'], 'niv');
    });
  });
}
