import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/utils/verse_picker.dart';

void main() {
  group('pickRandomVerseId basics', () {
    test('returns one of provided candidates; deterministic with single item', () {
      final rng = Random(42);
      final id = pickRandomVerseId(rng, candidates: const ['JHN.3.16']);
      expect(id, equals('JHN.3.16'));
    });
  });

  group('pickRandomVerseId errors', () {
    test('throws ArgumentError when no candidates provided', () {
      final rng = Random(1);
      expect(() => pickRandomVerseId(rng), throwsArgumentError);
    });
  });
}
