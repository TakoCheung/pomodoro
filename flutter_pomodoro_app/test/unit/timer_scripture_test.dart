import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _FakeService implements ScriptureServiceInterface {
  final Passage passage;
  _FakeService(this.passage);
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return passage;
  }
}

class _BadService implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    throw Exception('service failed');
  }
}

void main() {
  test('onComplete sets shownScriptureProvider to fetched passage when repo returns', () async {
    final repo = ScriptureRepository(service: _FakeService(Passage(reference: 'TestRef', text: 'TestText', verses: [])));
    final container = ProviderContainer(overrides: [scriptureRepositoryProvider.overrideWithValue(repo)]);

    final notifier = container.read(timerProvider.notifier);
    notifier.triggerComplete();
    // Allow async to complete
    await Future.delayed(const Duration(milliseconds: 10));

    final shown = container.read(shownScriptureProvider);
    expect(shown, isNotNull);
    expect(shown!.reference, 'TestRef');
  });

  test('onComplete falls back to local passage when repo throws', () async {
    final repo = ScriptureRepository(service: _BadService());
    final container = ProviderContainer(overrides: [scriptureRepositoryProvider.overrideWithValue(repo)]);

    final notifier = container.read(timerProvider.notifier);
    notifier.triggerComplete();
    await Future.delayed(const Duration(milliseconds: 10));

    final shown = container.read(shownScriptureProvider);
    expect(shown, isNotNull);
    expect(shown!.reference, 'Genesis 1:1');
  });
}
