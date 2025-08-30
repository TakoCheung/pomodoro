import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return Passage(reference: passageId, text: 'Text for $passageId', verses: []);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('fetchAndCacheRandomPassage appends every fetched passage to history and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = ScriptureRepository(service: FakeService(), now: () => DateTime(2025, 8, 30), prefs: prefs);

    final p1 = await repo.fetchAndCacheRandomPassage(bibleId: 'b', passageIds: ['GEN.1.1']);
    expect(p1.reference, 'GEN.1.1');
    expect(repo.history.length, 1);
    expect(repo.history.first.reference, 'GEN.1.1');

    final p2 = await repo.fetchAndCacheRandomPassage(bibleId: 'b', passageIds: ['JOH.3.16']);
    expect(p2.reference, 'JOH.3.16');
    expect(repo.history.length, 2);
    expect(repo.history[1].reference, 'JOH.3.16');

    // New repository hydrates persisted history
    final repo2 = ScriptureRepository(service: FakeService(), now: () => DateTime(2025, 8, 30), prefs: prefs);
    expect(repo2.history.length, 2);
    expect(repo2.history.first.reference, 'GEN.1.1');
    expect(repo2.history[1].reference, 'JOH.3.16');
  });

  test('getRandomPassageOncePerDay adds to history only when fetching (first call), not when returning cached', () async {
    final prefs = await SharedPreferences.getInstance();
    DateTime fixedNow() => DateTime(2025, 8, 30, 10, 0, 0);
    final repo = ScriptureRepository(service: FakeService(), now: fixedNow, prefs: prefs);

    final p1 = await repo.getRandomPassageOncePerDay(bibleId: 'b', passageIds: ['PSA.23.1']);
    expect(p1.reference, 'PSA.23.1');
    expect(repo.history.length, 1);

    final p2 = await repo.getRandomPassageOncePerDay(bibleId: 'b', passageIds: ['PSA.23.2']);
    // Should return cached passage and not grow history
    expect(p2.reference, 'PSA.23.1');
    expect(repo.history.length, 1);
  });
}
