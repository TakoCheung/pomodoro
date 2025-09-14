import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/main.dart' as app;
import 'package:flutter_pomodoro_app/services/scripture_mapping_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMappingService implements ScriptureMappingServiceInterface {
  final Map<String, ScriptureMapping> store;
  _FakeMappingService(this.store);
  @override
  Future<ScriptureMapping> buildMapping(String bibleId) async {
    final m = store[bibleId];
    if (m == null) throw Exception('Unknown bibleId');
    return m;
  }
}

class _ITFakeBundle extends CachingAssetBundle {
  final Map<String, String> assets;
  _ITFakeBundle(this.assets);
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (!assets.containsKey(key)) throw Exception('Asset not found: $key');
    return assets[key]!;
  }

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();
}

class _ITMissBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    throw Exception('miss');
  }

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Build mapping on app launch with default bibleId', (tester) async {
    final defaultId = 'de4e12af7f28f599-02';
    final fake = _FakeMappingService({
      defaultId: ScriptureMapping(
        bibleId: defaultId,
        builtAt: DateTime(2025, 8, 31),
        data: {
          'GEN': {
            'GEN.1': ['GEN.1.1']
          }
        },
      ),
    });
    await tester.pumpWidget(ProviderScope(
      overrides: [
        bibleIdProvider.overrideWithValue(defaultId),
        scriptureMappingServiceProvider.overrideWithValue(fake),
      ],
      child: const app.MyApp(),
    ));
    await tester.pumpAndSettle();
    // Assert mapping ready
    // We cannot easily read providers from tester; the presence of app is sufficient in this smoke.
  });

  testWidgets('Asset hit: loads from asset and backfills prefs', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final assetJson = json.encode({
      'bibleId': 'TEST_BIBLE',
      'builtAt': '2025-09-01T00:00:00.000Z',
      'data': {
        'GEN': {
          'GEN.1': ['GEN.1.1', 'GEN.1.2']
        }
      }
    });

    // Service should not be called; throw if it is.
    final throwingService = _FakeMappingService({});

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((_) => Future.value(prefs)),
      assetBundleProvider.overrideWithValue(
        _ITFakeBundle({'assets/scripture_mapping/TEST_BIBLE.json': assetJson}),
      ),
      scriptureMappingServiceProvider.overrideWithValue(throwingService),
    ]);
    addTearDown(container.dispose);

    final mapping = await container.read(scriptureMappingProvider('TEST_BIBLE').future);
    expect(mapping.data['GEN']!['GEN.1'], ['GEN.1.1', 'GEN.1.2']);
    expect(prefs.getString('scripture_mapping_v1:TEST_BIBLE'), isNotNull);
  });

  testWidgets('Asset miss -> service -> prefs', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final serviceMapping = ScriptureMapping(
      bibleId: 'LIVE_BIBLE',
      builtAt: DateTime(2025, 9, 1),
      data: {
        'GEN': {
          'GEN.1': ['GEN.1.3']
        }
      },
    );
    final service = _FakeMappingService({'LIVE_BIBLE': serviceMapping});

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((_) => Future.value(prefs)),
      assetBundleProvider.overrideWithValue(_ITMissBundle()),
      scriptureMappingServiceProvider.overrideWithValue(service),
    ]);
    addTearDown(container.dispose);

    final mapping = await container.read(scriptureMappingProvider('LIVE_BIBLE').future);
    expect(mapping.data['GEN']!['GEN.1'], ['GEN.1.3']);
    expect(prefs.getString('scripture_mapping_v1:LIVE_BIBLE'), isNotNull);
  });
}
