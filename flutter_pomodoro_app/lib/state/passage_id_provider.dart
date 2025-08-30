import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/utils/verse_picker.dart';

/// Provides a Random instance; tests can override with a seeded RNG.
final rngProvider = Provider<Random>((ref) => Random());

/// Catalog of verse counts per book and chapter.
/// Map key is 3-letter book code (e.g., 'GEN', 'JHN').
/// Value is a list where index (chapter-1) gives number of verses in that chapter.
class VerseCatalog {
  final Map<String, List<int>> counts;
  const VerseCatalog(this.counts);

  bool get isEmpty => counts.isEmpty;

  /// Picks a random valid verse id like BOOK.CHAPTER.VERSE from the catalog.
  String pickRandom(Random rng) {
    if (counts.isEmpty) {
      throw StateError('VerseCatalog is empty');
    }
    // Build a flat list of (book, chapterIndex[1-based], verseCount) where verseCount > 0
    final books = <String>[];
    final chapNums = <int>[];
    final verseCounts = <int>[];
    counts.forEach((book, chapterCounts) {
      for (var i = 0; i < chapterCounts.length; i++) {
        final v = chapterCounts[i];
        if (v > 0) {
          books.add(book);
          chapNums.add(i + 1);
          verseCounts.add(v);
        }
      }
    });
    if (books.isEmpty) {
      throw StateError('VerseCatalog has no chapters with verses');
    }
    final idx = rng.nextInt(books.length);
    final verse = rng.nextInt(verseCounts[idx]) + 1;
    return '${books[idx]}.${chapNums[idx]}.$verse';
  }
}

/// Default verse catalog. Keep small and safe; tests can override with full catalogs.
final verseCatalogProvider = Provider<VerseCatalog>((ref) {
  return const VerseCatalog({
    // Cross-translation safe defaults:
    // Genesis: include chapter 1 only.
    'GEN': [31],
    // John: include chapter 3 only (36 verses), so JOH.3.1..36 are valid.
    'JOH': [0, 0, 36],
    // Psalms: include Psalm 23 (6 verses)
    'PSA': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6],
    // Note: Avoid books/chapters that may vary across translations (e.g., JAS.1.26 reported 404 on some ids).
  });
});

/// Stores the last used passage id to reduce immediate repeats.
final lastPassageIdProvider = StateProvider<String?>((ref) => null);

/// Provides a valid verse id string (BOOK.CHAPTER.VERSE).
/// Uses verseCatalogProvider when available; falls back to curated list otherwise.
final passageIdProvider = Provider<String>((ref) {
  final rng = ref.read(rngProvider);
  final catalog = ref.read(verseCatalogProvider);
  if (!catalog.isEmpty) {
    return catalog.pickRandom(rng);
  }
  // Fallback: curated verse list
  return pickRandomVerseId(rng, candidates: null);
});

/// Provides a generator function that yields a new random valid verse id on each call.
final nextPassageIdProvider = Provider<String Function()>((ref) {
  final rng = ref.read(rngProvider);
  final catalog = ref.read(verseCatalogProvider);
  return () {
    if (!catalog.isEmpty) {
      return catalog.pickRandom(rng);
    }
    return pickRandomVerseId(rng, candidates: null);
  };
});
