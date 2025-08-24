import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:math';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

class MockScriptureService extends Mock implements ScriptureServiceInterface {}

void main() {
  test('returns cached passage when called multiple times same day', () async {
    final mock = MockScriptureService();
    when(() => mock.fetchPassage(bibleId: any(named: 'bibleId'), passageId: any(named: 'passageId')))
        .thenAnswer((_) async => Passage(reference: 'Ref', text: 'Text'));

    // Fix the current date
  final fixedNow = DateTime(2025, 8, 24, 10, 0, 0);
  final repo = ScriptureRepository(service: mock, now: () => fixedNow, rng: Random(0));

    final p1 = await repo.getRandomPassageOncePerDay(bibleId: 'eng-ESV', passageIds: ['A', 'B', 'C']);
    final p2 = await repo.getRandomPassageOncePerDay(bibleId: 'eng-ESV', passageIds: ['A', 'B', 'C']);

    expect(identical(p1, p2), isTrue);
    verify(() => mock.fetchPassage(bibleId: any(named: 'bibleId'), passageId: any(named: 'passageId'))).called(1);
  });

  test('fetches again on different day', () async {
    final mock = MockScriptureService();
    when(() => mock.fetchPassage(bibleId: any(named: 'bibleId'), passageId: any(named: 'passageId')))
        .thenAnswer((_) async => Passage(reference: 'Ref', text: 'Text'));

  DateTime now = DateTime(2025, 8, 24, 10, 0, 0);
  final repo = ScriptureRepository(service: mock, now: () => now, rng: Random(0));

    await repo.getRandomPassageOncePerDay(bibleId: 'eng-ESV', passageIds: ['A']);
    // advance day
    now = now.add(const Duration(days: 1));
    await repo.getRandomPassageOncePerDay(bibleId: 'eng-ESV', passageIds: ['A']);

    verify(() => mock.fetchPassage(bibleId: any(named: 'bibleId'), passageId: any(named: 'passageId'))).called(2);
  });
}


