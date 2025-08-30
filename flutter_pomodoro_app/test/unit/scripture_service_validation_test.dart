import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

void main() {
  test('fetchPassage throws Exception for invalid verse id format', () async {
    final service = ScriptureService(apiKey: 'dummy');
    expect(
      service.fetchPassage(bibleId: 'eng-ESV', passageId: 'INVALID'),
      throwsException,
    );
  });
}

