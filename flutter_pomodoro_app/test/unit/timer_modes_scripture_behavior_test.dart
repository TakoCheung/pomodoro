import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/state/passage_id_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';

class _DummyService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    throw UnimplementedError();
  }
}

class _FakeRepo extends ScriptureRepository {
  Passage? _cached;
  int fetchAndCacheCalls = 0;
  int getRandomOnceCalls = 0;
  final Passage pomodoroReturn;
  final Passage fetchOnceReturn;

  _FakeRepo({required this.pomodoroReturn, required this.fetchOnceReturn}) : super(service: _DummyService());

  @override
  Passage? get cachedPassage => _cached;

  void seedCached(Passage? p) {
    _cached = p;
  }

  @override
  Future<Passage> fetchAndCacheRandomPassage({required String bibleId, required List<String> passageIds}) async {
    fetchAndCacheCalls++;
    _cached = pomodoroReturn;
    return pomodoroReturn;
  }

  @override
  Future<Passage> getRandomPassageOncePerDay({required String bibleId, required List<String> passageIds}) async {
    getRandomOnceCalls++;
    _cached = fetchOnceReturn;
    return fetchOnceReturn;
  }
}

void main() {
  test('Pomodoro completion fetches a new passage and updates cache', () async {
    final fakeRepo = _FakeRepo(
      pomodoroReturn: Passage(reference: 'POMO', text: 'Pomodoro Passage', verses: []),
      fetchOnceReturn: Passage(reference: 'ONCE', text: 'Once Passage', verses: []),
    );
    final container = ProviderContainer(overrides: [
      scriptureRepositoryProvider.overrideWithValue(fakeRepo),
      // Fixed id to ensure we pass a valid candidate into repo methods
      passageIdProvider.overrideWithValue('GEN.1.1'),
    ]);

    final notifier = container.read(timerProvider.notifier);
    notifier.setMode(TimerMode.pomodoro);
    notifier.triggerComplete();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(fakeRepo.fetchAndCacheCalls, 1);
    expect(fakeRepo.getRandomOnceCalls, 0);
    final shown = container.read(shownScriptureProvider);
    expect(shown?.reference, 'POMO');
  });

  test('Short break completion shows cached passage if available', () async {
    final fakeRepo = _FakeRepo(
      pomodoroReturn: Passage(reference: 'POMO', text: 'Pomodoro Passage', verses: []),
      fetchOnceReturn: Passage(reference: 'ONCE', text: 'Once Passage', verses: []),
    );
    fakeRepo.seedCached(Passage(reference: 'CACHED', text: 'Cached Passage', verses: []));

    final container = ProviderContainer(overrides: [
      scriptureRepositoryProvider.overrideWithValue(fakeRepo),
      passageIdProvider.overrideWithValue('GEN.1.1'),
    ]);

    final notifier = container.read(timerProvider.notifier);
    notifier.setMode(TimerMode.shortBreak);
    notifier.triggerComplete();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(fakeRepo.fetchAndCacheCalls, 0);
    expect(fakeRepo.getRandomOnceCalls, 0);
    final shown = container.read(shownScriptureProvider);
    expect(shown?.reference, 'CACHED');
  });

  test('Long break completion fetches once when no cache exists', () async {
    final fakeRepo = _FakeRepo(
      pomodoroReturn: Passage(reference: 'POMO', text: 'Pomodoro Passage', verses: []),
      fetchOnceReturn: Passage(reference: 'ONCE', text: 'Once Passage', verses: []),
    );
    // no cache seeded

    final container = ProviderContainer(overrides: [
      scriptureRepositoryProvider.overrideWithValue(fakeRepo),
      passageIdProvider.overrideWithValue('GEN.1.1'),
    ]);

    final notifier = container.read(timerProvider.notifier);
    notifier.setMode(TimerMode.longBreak);
    notifier.triggerComplete();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(fakeRepo.fetchAndCacheCalls, 0);
    expect(fakeRepo.getRandomOnceCalls, 1);
    final shown = container.read(shownScriptureProvider);
    expect(shown?.reference, 'ONCE');
  });

  test('Avoid immediate repeat passage id across consecutive pomodoros', () async {
    final fakeRepo = _FakeRepo(
      pomodoroReturn: Passage(reference: 'POMO', text: 'Pomodoro Passage', verses: []),
      fetchOnceReturn: Passage(reference: 'ONCE', text: 'Once Passage', verses: []),
    );
    var ids = ['GEN.1.1', 'GEN.1.1', 'GEN.1.2'];
    int idx = 0;
    final container = ProviderContainer(overrides: [
      scriptureRepositoryProvider.overrideWithValue(fakeRepo),
      // nextPassageIdProvider yields same id twice then a different one
      nextPassageIdProvider.overrideWithValue(() => ids[idx++ % ids.length]),
    ]);

    final notifier = container.read(timerProvider.notifier);
    notifier.setMode(TimerMode.pomodoro);
    notifier.triggerComplete();
    await Future.delayed(const Duration(milliseconds: 10));

    // Second completion should not re-use GEN.1.1 immediately; our loop will pick GEN.1.2
    notifier.triggerComplete();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(fakeRepo.fetchAndCacheCalls, 2);
  });
}
