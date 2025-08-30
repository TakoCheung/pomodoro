import 'dart:math';
import 'package:flutter_pomodoro_app/data/verse_ids_esv.dart';

/// Picks a random verse ID from the provided [candidates], or from a default
/// curated list if none provided. Filters out obviously invalid candidates.
String pickRandomVerseId(Random rng, {List<String>? candidates}) {
  // If the caller provided candidates, respect them verbatim to preserve
  // backwards compatibility with existing tests that pass arbitrary IDs.
  if (candidates != null && candidates.isNotEmpty) {
    final valid =
        candidates.where(isLikelyValidVerseId).toList(growable: false);
    if (valid.isEmpty) {
      throw ArgumentError('No valid verse IDs in candidates');
    }
    final idx = rng.nextInt(valid.length);
    return valid[idx];
  }
  // Otherwise, choose from our curated and pre-validated list.
  if (esvVerseIds.isEmpty) {
    throw ArgumentError('No verse IDs available to choose from');
  }
  final idx = rng.nextInt(esvVerseIds.length);
  return esvVerseIds[idx];
}
