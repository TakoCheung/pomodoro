import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';

class _FakeSvc implements ScriptureServiceInterface {
  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    return Passage(reference: '$bibleId:$passageId', text: 'T');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('cachedPassageForBible returns only when bibleId matches', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = ScriptureRepository(service: _FakeSvc(), now: () => DateTime(2025, 8, 30), prefs: prefs);
    // Cache passage for idA
    await repo.fetchAndCacheRandomPassage(bibleId: 'idA', passageIds: ['GEN.1.1']);
    expect(repo.cachedPassageForBible('idA')?.reference.startsWith('idA'), isTrue);
    expect(repo.cachedPassageForBible('idB'), isNull);

    // Rehydrate new repo from prefs and verify same behavior
    final repo2 = ScriptureRepository(service: _FakeSvc(), now: () => DateTime(2025, 8, 30), prefs: prefs);
    expect(repo2.cachedPassageForBible('idA')?.reference.startsWith('idA'), isTrue);
    expect(repo2.cachedPassageForBible('idB'), isNull);
  });
}
