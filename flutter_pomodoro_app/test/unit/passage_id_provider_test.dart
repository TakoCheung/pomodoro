import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/passage_id_provider.dart';

void main() {
  test('passageIdProvider returns valid BOOK.CHAPTER.VERSE from catalog', () {
    final container = ProviderContainer(overrides: [
      // Deterministic RNG
      rngProvider.overrideWithValue(Random(42)),
      // Minimal catalog with deterministic selection
      verseCatalogProvider.overrideWithValue(const VerseCatalog({
        'GEN': [31], // GEN.1.1..31
      })),
    ]);
    final id = container.read(passageIdProvider);
    expect(id.startsWith('GEN.'), isTrue);
  });

  test('passageIdProvider throws when both mapping and catalog are unavailable', () {
    final container = ProviderContainer(overrides: [
      rngProvider.overrideWithValue(Random(7)),
      verseCatalogProvider.overrideWithValue(const VerseCatalog({})),
    ]);
    expect(() => container.read(passageIdProvider), throwsA(isA<StateError>()));
  });
}
