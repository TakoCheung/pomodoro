import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/models/bible_version.dart';
import 'package:flutter_pomodoro_app/services/bible_catalog_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart'
    show sharedPreferencesProvider;

class _FakeCatalogService implements BibleCatalogServiceInterface {
  int calls = 0;
  List<BibleVersion> result;
  final bool throwOnFetch;
  _FakeCatalogService(this.result, {this.throwOnFetch = false});

  @override
  Future<List<BibleVersion>> fetchBibles() async {
    calls += 1;
    if (throwOnFetch) {
      throw Exception('fetchBibles should not be called');
    }
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cacheKey = 'bible_versions_cache_v1';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('bibleVersionsProvider returns cached list without calling fetch',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final cached = [
      {
        'id': 'id1',
        'name': 'New Version',
        'abbreviation': 'NV',
        'language': {'id': 'eng', 'name': 'English'}
      }
    ];
    await prefs.setString(cacheKey, json.encode(cached));

    final fake = _FakeCatalogService(const []);
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      bibleCatalogServiceProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);

    final list = await container.read(bibleVersionsProvider.future);
    expect(list, isNotEmpty);
    expect(list.first.id, 'id1');
    expect(fake.calls, 0);
  });

  test(
      'bibleVersionsProvider fetches, persists cache, then next container reads from cache',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final versions = [
      BibleVersion(
          id: 'id2',
          name: 'Another Version',
          abbreviation: 'AV',
          language: 'English'),
    ];
    final fake = _FakeCatalogService(versions);
    final c1 = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      bibleCatalogServiceProvider.overrideWithValue(fake),
    ]);
    addTearDown(c1.dispose);

    final list1 = await c1.read(bibleVersionsProvider.future);
    expect(list1.length, 1);
    expect(list1.first.id, 'id2');
    expect(fake.calls, 1);

    // Ensure cache was written
    final cacheStr = prefs.getString(cacheKey);
    expect(cacheStr, isNotNull);
    final decoded = json.decode(cacheStr!);
    expect(decoded, isA<List<dynamic>>());

    // New container should hit cache and not call fetch (we provide a throwing fake)
    final throwing = _FakeCatalogService(const [], throwOnFetch: true);
    final c2 = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      bibleCatalogServiceProvider.overrideWithValue(throwing),
    ]);
    addTearDown(c2.dispose);
    final list2 = await c2.read(bibleVersionsProvider.future);
    expect(list2.length, 1);
    expect(list2.first.id, 'id2');
    expect(throwing.calls, 0);
  });

  test('corrupt cache is ignored and provider fetches fresh list', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, 'not-json');
    final versions = [
      BibleVersion(
          id: 'id3',
          name: 'Third Version',
          abbreviation: 'TV',
          language: 'English'),
    ];
    final fake = _FakeCatalogService(versions);
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      bibleCatalogServiceProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);
    final list = await container.read(bibleVersionsProvider.future);
    expect(list.length, 1);
    expect(list.first.id, 'id3');
    expect(fake.calls, 1);
  });
}
