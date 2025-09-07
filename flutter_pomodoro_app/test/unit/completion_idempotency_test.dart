import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

class _CountRepo extends ScriptureRepository {
  int calls = 0;
  _CountRepo() : super(service: _DummyService());
  @override
  Future<Passage> fetchAndCacheRandomPassage(
      {required String bibleId, required List<String> passageIds}) async {
    calls++;
    return Passage(reference: 'R', text: 'X', verses: []);
  }
}

class _DummyService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    throw UnimplementedError();
  }
}

void main() {
  test('No duplicate completion from concurrent signals', () async {
    final repo = _CountRepo();
    final container = ProviderContainer(overrides: [
      scriptureRepositoryProvider.overrideWithValue(repo),
    ]);
    final n = container.read(timerProvider.notifier);
    n.setMode(TimerMode.pomodoro);
    // Two concurrent triggers
    n.triggerComplete();
    n.triggerComplete();
    await Future.delayed(const Duration(milliseconds: 50));
    expect(repo.calls, 1);
  });
}
