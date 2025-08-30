import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/utils/verse_picker.dart';
import 'package:flutter_pomodoro_app/data/verse_ids_esv.dart';

void main() {
  group('isLikelyValidVerseId', () {
    test('accepts valid ids like GEN.1.1 and JOH.3.16', () {
      expect(isLikelyValidVerseId('GEN.1.1'), isTrue);
      expect(isLikelyValidVerseId('JOH.3.16'), isTrue);
    });

    test('rejects invalid patterns and books', () {
      expect(isLikelyValidVerseId('FOO.1.1'), isFalse);
      expect(isLikelyValidVerseId('GEN.0.1'), isFalse);
      expect(isLikelyValidVerseId('GEN.1.0'), isFalse);
      expect(isLikelyValidVerseId('JOH.3'), isFalse);
      expect(isLikelyValidVerseId('JOH-3-16'), isFalse);
    });
  });

  group('pickRandomVerseId', () {
    test('uses provided candidates verbatim (deterministic with single item)', () {
      final rng = Random(42);
      final id = pickRandomVerseId(rng, candidates: const ['JOH.3.16']);
      expect(id, equals('JOH.3.16'));
    });

    test('chooses from curated list when no candidates provided', () {
      final rng = Random(1);
      final id = pickRandomVerseId(rng);
      expect(esvVerseIds.contains(id), isTrue);
      expect(isLikelyValidVerseId(id), isTrue);
    });
  });
}

