import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';

void main() {
  group('Notification payload builder', () {
    test('Build notification payload from scripture with truncation', () {
      final p = Passage(
        reference: 'John 3:16',
        text: 'For God so loved the world that he gave his one and only Son, that whoever believes '
            'in him shall not perish but have eternal life.',
      );
      final res = NotificationContentBuilder.build(
        bibleId: 'ESV',
        passageId: 'JHN.3.16',
        passage: p,
        maxLen: 80,
      );
      expect(res.title, 'John 3:16');
      expect(res.payload['bibleId'], 'ESV');
      expect(res.payload['passageId'], 'JHN.3.16');
      expect(res.payload['reference'], 'John 3:16');
      final body = res.body;
      expect(body.length <= 80, isTrue);
      expect(body.endsWith('…'), isTrue);
    });

    test('Handle scripture fetch failure with graceful fallback', () {
      final res = NotificationContentBuilder.fallback();
      expect(res.title, 'Session complete');
      expect(res.body, 'Great job! Open to view your verse.');
      expect(res.payload.containsKey('bibleId'), isFalse);
      expect(res.payload.containsKey('passageId'), isFalse);
    });

    test('Deterministic truncation at 140 chars', () {
      final longText = List.generate(300, (i) => 'x').join();
      final p = Passage(reference: 'Psa 23:1', text: longText);
      final res = NotificationContentBuilder.build(
        bibleId: 'ESV',
        passageId: 'PSA.23.1',
        passage: p,
        maxLen: 140,
      );
      expect(res.body.length, lessThanOrEqualTo(140));
      expect(res.body.endsWith('…'), isTrue);
      // Exact string check for determinism
      final expected = 'x' * 139 + '…';
      expect(res.body, expected);
    });
  });
}
