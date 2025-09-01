import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/passage_id_provider.dart';
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

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  test('passage_id_provider only returns verseIds from mapping', () async {
    final container = ProviderContainer(overrides: [
      rngProvider.overrideWithValue(Random(1)),
      // Fix bibleId
      bibleIdProvider.overrideWithValue('de4e12af7f28f599-02'),
      sharedPreferencesProvider.overrideWith((ref) => SharedPreferences.getInstance()),
      scriptureMappingServiceProvider.overrideWithValue(
        _FakeMappingService({
          'de4e12af7f28f599-02': ScriptureMapping(
            bibleId: 'de4e12af7f28f599-02',
            builtAt: DateTime(2025, 8, 31),
            data: {
              'GEN': {
                'GEN.1': ['GEN.1.1', 'GEN.1.2', 'GEN.1.3']
              }
            },
          ),
        }),
      ),
    ]);
    addTearDown(container.dispose);

    // Prime mapping provider to ready
    final mapping = await container.read(scriptureMappingProvider('de4e12af7f28f599-02').future);
    expect(mapping.isEmpty, isFalse);

    final id = container.read(passageIdProvider);
    expect(
      ['GEN.1.1', 'GEN.1.2', 'GEN.1.3'].contains(id),
      isTrue,
      reason: 'picked id must come from provided verses',
    );
  });

  test('Mapping lookup fails safely for unknown ids', () async {
    final container = ProviderContainer(overrides: [
      rngProvider.overrideWithValue(Random(1)),
      bibleIdProvider.overrideWithValue('INVALID'),
      sharedPreferencesProvider.overrideWith((ref) => SharedPreferences.getInstance()),
      scriptureMappingServiceProvider.overrideWithValue(_FakeMappingService({})),
    ]);
    addTearDown(container.dispose);
    // Ensure mapping provider resolves to error first
    await expectLater(
      container.read(scriptureMappingProvider('INVALID').future),
      throwsA(isA<Exception>()),
    );
    expect(() => container.read(passageIdProvider), throwsA(isA<StateError>()));
  });
}
