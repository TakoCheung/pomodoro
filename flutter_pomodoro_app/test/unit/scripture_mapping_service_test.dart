import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_pomodoro_app/services/scripture_mapping_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart'
    show sharedPreferencesProvider;

class _MockHttpClient extends Mock implements http.Client {}

class _RecordingService implements ScriptureMappingServiceInterface {
  int calls = 0;
  final ScriptureMapping mapping;
  _RecordingService(this.mapping);
  @override
  Future<ScriptureMapping> buildMapping(String bibleId) async {
    calls++;
    return mapping;
  }
}

class _ThrowingService implements ScriptureMappingServiceInterface {
  @override
  Future<ScriptureMapping> buildMapping(String _) async => throw StateError('should not call');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // No global mocktail setup needed

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ScriptureMapping model', () {
    test('toJson/fromJson roundtrip', () {
      final m = ScriptureMapping(
        bibleId: 'BIBLE',
        builtAt: DateTime(2025, 8, 31, 12, 30, 0),
        data: {
          'GEN': {
            'GEN.1': ['GEN.1.1', 'GEN.1.2'],
          }
        },
      );
      final map = m.toJson();
      final decoded = ScriptureMapping.fromJson(map);
      expect(decoded.bibleId, 'BIBLE');
      expect(decoded.data['GEN']!['GEN.1']!.length, 2);
      expect(decoded.builtAt, DateTime(2025, 8, 31, 12, 30, 0));
      expect(m.isEmpty, isFalse);
    });
  });

  group('ScriptureMappingService', () {
    test('buildMapping fetches books and chapters with api-key header', () async {
      final client = _MockHttpClient();
      const apiKey = 'KEY';
      const bibleId = 'de4e12af7f28f599-02';

      final booksUri = Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/books');
      when(() => client.get(booksUri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': [
                  {'id': 'GEN'},
                  {'id': 'EXO'},
                ]
              }),
              200));

      final genChUri =
          Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/books/GEN/chapters');
      when(() => client.get(genChUri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': [
                  {'id': 'GEN.1'},
                  {'id': 'GEN.2'},
                  {'id': 'GEN.3'},
                ]
              }),
              200));

      final exoChUri =
          Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/books/EXO/chapters');
      when(() => client.get(exoChUri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': [
                  {'id': 'EXO.1'},
                  {'id': 'EXO.2'},
                ]
              }),
              200));

      final gen1Uri =
          Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/chapters/GEN.1/verses');
      when(() => client.get(gen1Uri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': [
                  {'id': 'GEN.1.1'},
                  {'id': 'GEN.1.2'},
                ]
              }),
              200));

      final gen2Uri =
          Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/chapters/GEN.2/verses');
      when(() => client.get(gen2Uri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': [
                  {'id': 'GEN.2.1'}
                ]
              }),
              200));

      final gen3Uri =
          Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/chapters/GEN.3/verses');
      when(() => client.get(gen3Uri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': [
                  {'id': 'GEN.3.1'}
                ]
              }),
              200));

      final exo1Uri =
          Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/chapters/EXO.1/verses');
      when(() => client.get(exo1Uri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': [
                  {'id': 'EXO.1.1'}
                ]
              }),
              200));

      final exo2Uri =
          Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/chapters/EXO.2/verses');
      when(() => client.get(exo2Uri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': [
                  {'id': 'EXO.2.1'},
                  {'id': 'EXO.2.2'}
                ]
              }),
              200));

      final svc = ScriptureMappingService(client: client, apiKey: apiKey);
      final mapping = await svc.buildMapping(bibleId);

      // Verifications
      verify(() => client.get(booksUri, headers: {'api-key': apiKey})).called(1);
      verify(() => client.get(genChUri, headers: {'api-key': apiKey})).called(1);
      verify(() => client.get(exoChUri, headers: {'api-key': apiKey})).called(1);
      verify(() => client.get(gen1Uri, headers: {'api-key': apiKey})).called(1);
      verify(() => client.get(gen2Uri, headers: {'api-key': apiKey})).called(1);
      verify(() => client.get(gen3Uri, headers: {'api-key': apiKey})).called(1);
      verify(() => client.get(exo1Uri, headers: {'api-key': apiKey})).called(1);
      verify(() => client.get(exo2Uri, headers: {'api-key': apiKey})).called(1);

      expect(mapping.bibleId, bibleId);
      expect(mapping.data.containsKey('GEN'), isTrue);
      expect(mapping.data['GEN']!.containsKey('GEN.1'), isTrue);
      expect(mapping.data['GEN']!['GEN.1']!.first, 'GEN.1.1');
      expect(mapping.data['EXO']!['EXO.2']!.last, 'EXO.2.2');
      expect(mapping.builtAt.difference(DateTime.now()).inDays.abs() <= 1, isTrue);
    });

    test('throws when books request fails; skips when chapters/verses fail', () async {
      final client = _MockHttpClient();
      const apiKey = 'KEY';
      const bibleId = 'BID';

      // Books non-200 -> throws
      final booksUri = Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/books');
      when(() => client.get(booksUri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response('nope', 500));

      final svc = ScriptureMappingService(client: client, apiKey: apiKey);
      await expectLater(svc.buildMapping(bibleId), throwsA(isA<Exception>()));

      // Now make books ok but chapters/verses fail to ensure skip behavior
      reset(client);
      when(() => client.get(booksUri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'data': [
                  {'id': 'GEN'}
                ]
              }),
              200));
      final chUri =
          Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/books/GEN/chapters');
      when(() => client.get(chUri, headers: {'api-key': apiKey}))
          .thenAnswer((_) async => http.Response('nope', 500));

      final mapping2 = await svc.buildMapping(bibleId);
      expect(mapping2.data['GEN']?.isEmpty ?? true, isTrue, reason: 'chapters error skipped');
    });
  });

  group('Providers: scriptureMappingProvider & ready', () {
    test('caches to SharedPreferences and reuses cache (service not called again)', () async {
      final prefs = await SharedPreferences.getInstance();
      final mapping = ScriptureMapping(
        bibleId: 'BIBLE',
        builtAt: DateTime(2025, 8, 31),
        data: {
          'GEN': {
            'GEN.1': ['GEN.1.1']
          }
        },
      );
      final recording = _RecordingService(mapping);

      final c1 = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        scriptureMappingServiceProvider.overrideWithValue(recording),
      ]);
      addTearDown(c1.dispose);

      final m1 = await c1.read(scriptureMappingProvider('BIBLE').future);
      expect(m1.isEmpty, isFalse);
      expect(recording.calls, 1);

      final c2 = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        scriptureMappingServiceProvider.overrideWithValue(_ThrowingService()),
      ]);
      addTearDown(c2.dispose);
      final m2 = await c2.read(scriptureMappingProvider('BIBLE').future);
      expect(m2.isEmpty, isFalse);
    });

    test('corrupted cached json (old daily key) is ignored and service is used', () async {
      // Seed bad cache for today key
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final prefsMap = <String, Object>{
        // Seed using legacy daily key format to verify graceful migration/ignore
        'scripture_mapping_v1:BIBLE:$dateKey': '{not json}',
      };
      SharedPreferences.setMockInitialValues(prefsMap);
      final prefs = await SharedPreferences.getInstance();
      final mapping = ScriptureMapping(bibleId: 'BIBLE', data: const {}, builtAt: today);
      final svc = _RecordingService(mapping);

      final c = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        scriptureMappingServiceProvider.overrideWithValue(svc),
      ]);
      addTearDown(c.dispose);
      final m = await c.read(scriptureMappingProvider('BIBLE').future);
      expect(m.bibleId, 'BIBLE');
      expect(svc.calls, 1, reason: 'service should be called when cache is corrupt');
    });

    test('ready provider reflects loading and data states', () async {
      final prefs = await SharedPreferences.getInstance();
      final nonEmpty = ScriptureMapping(
        bibleId: 'BIBLE',
        builtAt: DateTime(2025, 1, 1),
        data: const {
          'GEN': {
            'GEN.1': ['GEN.1.1']
          }
        },
      );
      final svc = _RecordingService(nonEmpty);
      final c = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        scriptureMappingServiceProvider.overrideWithValue(svc),
      ]);
      addTearDown(c.dispose);

      // Initially false during load
      expect(c.read(scriptureMappingReadyProvider('BIBLE')), isFalse);

      // After load with non-empty mapping -> true
      await c.read(scriptureMappingProvider('BIBLE').future);
      expect(c.read(scriptureMappingReadyProvider('BIBLE')), isTrue);

      // Empty mapping results in false
      final emptySvc = _RecordingService(ScriptureMapping(
        bibleId: 'BIBLE2',
        builtAt: DateTime(2025, 1, 1),
        data: const {},
      ));
      final c2 = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        scriptureMappingServiceProvider.overrideWithValue(emptySvc),
      ]);
      addTearDown(c2.dispose);
      await c2.read(scriptureMappingProvider('BIBLE2').future);
      expect(c2.read(scriptureMappingReadyProvider('BIBLE2')), isFalse);
    });

    test('scriptureMappingServiceProvider throws when SCRIPTURE_API_KEY missing', () async {
      dotenv.dotenv.testLoad(fileInput: '');
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(
        () => c.read(scriptureMappingServiceProvider),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
