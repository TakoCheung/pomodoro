import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/passage_id_provider.dart';
import 'package:flutter_pomodoro_app/data/verse_ids_esv.dart';

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
    expect(isLikelyValidVerseId(id), isTrue);
    expect(id.startsWith('GEN.'), isTrue);
  });

  test('passageIdProvider falls back to curated list when catalog empty', () {
    final container = ProviderContainer(overrides: [
      rngProvider.overrideWithValue(Random(7)),
      verseCatalogProvider.overrideWithValue(const VerseCatalog({})),
    ]);
    final id = container.read(passageIdProvider);
    expect(isLikelyValidVerseId(id), isTrue);
  });
}
