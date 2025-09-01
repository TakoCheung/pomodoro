import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';

void main() {
  test('Payload includes bible-scoped identifiers', () {
    final cases = [
      ['de4e12af7f28f599-02', 'JHN.3.16'],
      ['06125adad2d5898a-01', 'PSA.23.1'],
    ];
    for (final c in cases) {
      final res = NotificationContentBuilder.build(
        bibleId: c[0],
        passageId: c[1],
        passage: Passage(reference: 'X', text: 'Y'),
        maxLen: 10,
      );
      expect(res.payload['bibleId'], c[0]);
      expect(res.payload['passageId'], c[1]);
    }
  });
}
