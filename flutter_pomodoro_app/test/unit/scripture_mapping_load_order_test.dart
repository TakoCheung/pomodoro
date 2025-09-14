import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/services/scripture_mapping_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBundle extends CachingAssetBundle {
  final Map<String, String> assets;
  _FakeBundle(this.assets);
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (!assets.containsKey(key)) throw Exception('Asset not found: $key');
    return assets[key]!;
  }

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }
}

class _FakeService implements ScriptureMappingServiceInterface {
  final ScriptureMapping mapping;
  _FakeService(this.mapping);
  @override
  Future<ScriptureMapping> buildMapping(String bibleId) async => mapping;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Asset present: loads from asset and backfills prefs; service not called', () async {
    final prefs = await SharedPreferences.getInstance();
    final assetJson = json.encode({
      'bibleId': 'TEST_BIBLE',
      'builtAt': '2025-09-01T00:00:00.000Z',
      'data': {
        'GEN': {
          'GEN.1': ['GEN.1.1']
        }
      }
    });

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((_) => Future.value(prefs)),
      assetBundleProvider.overrideWithValue(_FakeBundle({
        'assets/scripture_mapping/TEST_BIBLE.json': assetJson,
      })),
      scriptureMappingServiceProvider.overrideWithValue(
        _FakeService(
          ScriptureMapping(bibleId: 'TEST_BIBLE', data: const {}, builtAt: DateTime(2025)),
        ),
      ),
    ]);
    addTearDown(container.dispose);

    final mapping = await container.read(scriptureMappingProvider('TEST_BIBLE').future);
    expect(mapping.bibleId, 'TEST_BIBLE');
    expect(mapping.data['GEN']!['GEN.1'], ['GEN.1.1']);

    final cached = prefs.getString('scripture_mapping_v1:TEST_BIBLE');
    expect(cached, isNotNull);
  });

  test('Prefs present, asset absent: returns cached JSON; service not called', () async {
    final prefs = await SharedPreferences.getInstance();
    final cachedMapping = ScriptureMapping(
      bibleId: 'CACHED',
      builtAt: DateTime(2025, 9, 1),
      data: {
        'GEN': {
          'GEN.1': ['GEN.1.2']
        }
      },
    );
    await prefs.setString('scripture_mapping_v1:CACHED', json.encode(cachedMapping.toJson()));

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((_) => Future.value(prefs)),
      assetBundleProvider.overrideWithValue(_FakeBundle({})),
      scriptureMappingServiceProvider.overrideWithValue(
        _FakeService(
          ScriptureMapping(bibleId: 'CACHED', data: const {}, builtAt: DateTime(2025)),
        ),
      ),
    ]);
    addTearDown(container.dispose);

    final mapping = await container.read(scriptureMappingProvider('CACHED').future);
    expect(mapping.data['GEN']!['GEN.1'], ['GEN.1.2']);
  });

  test('No asset, no prefs: uses service then caches to prefs', () async {
    final prefs = await SharedPreferences.getInstance();
    final serviceMapping = ScriptureMapping(
      bibleId: 'LIVE',
      builtAt: DateTime(2025, 9, 1),
      data: {
        'GEN': {
          'GEN.1': ['GEN.1.3']
        }
      },
    );

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((_) => Future.value(prefs)),
      assetBundleProvider.overrideWithValue(_FakeBundle({})),
      scriptureMappingServiceProvider.overrideWithValue(_FakeService(serviceMapping)),
    ]);
    addTearDown(container.dispose);

    final mapping = await container.read(scriptureMappingProvider('LIVE').future);
    expect(mapping.data['GEN']!['GEN.1'], ['GEN.1.3']);
    expect(prefs.getString('scripture_mapping_v1:LIVE'), isNotNull);
  });
}
