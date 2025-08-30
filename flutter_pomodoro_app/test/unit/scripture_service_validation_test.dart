import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

void main() {
  test('fetchPassage throws Exception for invalid verse id format', () async {
    final service = ScriptureService(apiKey: 'dummy');
    expect(
      service.fetchPassage(
          bibleId: '32664dc3288a28df-01', passageId: 'INVALID'),
      throwsException,
    );
  });
}
