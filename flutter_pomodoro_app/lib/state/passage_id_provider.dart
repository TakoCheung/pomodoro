import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/services/scripture_mapping_service.dart';

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
    // John: include chapter 3 only (36 verses), so JHN.3.1..36 are valid.
    'JHN': [0, 0, 36],
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
  // Try dynamic mapping when available
  final bibleId = ref.read(bibleIdProvider);
  final mappingAsync = ref.watch(scriptureMappingProvider(bibleId));
  return mappingAsync.maybeWhen(
    data: (m) {
      // Flatten all verseIds across all books/chapters
      final verseIds = <String>[];
      m.data.forEach((_, chapters) {
        chapters.forEach((_, verses) => verseIds.addAll(verses));
      });
      if (verseIds.isNotEmpty) {
        return verseIds[rng.nextInt(verseIds.length)];
      }
      // If mapping is oddly empty, fall back on catalog; otherwise no source available.
      if (!catalog.isEmpty) return catalog.pickRandom(rng);
      throw StateError('No verse source available');
    },
    error: (e, st) {
      // Unknown/invalid bibleId mapping requested
      throw StateError('Unknown bibleId');
    },
    orElse: () {
      // Mapping not yet loaded — use catalog fallback; otherwise no source available
      if (!catalog.isEmpty) return catalog.pickRandom(rng);
      throw StateError('No verse source available');
    },
  );
});

/// Provides a generator function that yields a new random valid verse id on each call.
final nextPassageIdProvider = Provider<String Function()>((ref) {
  final rng = ref.read(rngProvider);
  final catalog = ref.read(verseCatalogProvider);
  return () {
    final bibleId = ref.read(bibleIdProvider);
    final mappingAsync = ref.watch(scriptureMappingProvider(bibleId));
    final verseIds = <String>[];
    mappingAsync.when(
      data: (m) {
        m.data.forEach((_, chapters) {
          chapters.forEach((_, verses) => verseIds.addAll(verses));
        });
      },
      loading: () {},
      error: (_, __) {
        throw StateError('Unknown bibleId');
      },
    );
    if (verseIds.isNotEmpty) {
      return verseIds[rng.nextInt(verseIds.length)];
    }
    if (!catalog.isEmpty) {
      return catalog.pickRandom(rng);
    }
    throw StateError('No verse source available');
  };
});
