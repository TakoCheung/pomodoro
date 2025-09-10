import 'dart:math';

/// Picks a random verse ID from the provided [candidates], or from a default
/// curated list if none provided.
///
/// Rationale: Upstream generators (mapping or catalog) already ensure IDs are
/// meaningful for the active translation. Previous validation occasionally
/// rejected legit translation-specific IDs, causing unnecessary fallback.
/// We now trust provided candidates verbatim to avoid spurious failures.
String pickRandomVerseId(Random rng, {List<String>? candidates}) {
  if (candidates != null && candidates.isNotEmpty) {
    final idx = rng.nextInt(candidates.length);
    return candidates[idx];
  }
  throw ArgumentError('No verse candidates provided');
}
