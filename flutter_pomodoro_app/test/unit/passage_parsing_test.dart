import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';

void main() {
  group('Passage.fromJson parsing', () {
    test('strips simple <p> tags and returns plain text', () {
      final jsonStr = json.encode({
        'data': {
          'reference': 'Genesis 1:1',
          'content':
              '<p>In the beginning God created the heavens and the earth.</p>'
        }
      });
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      final p = Passage.fromJson(map);
      expect(p.reference, 'Genesis 1:1');
      expect(p.text, 'In the beginning God created the heavens and the earth.');
    });

    test(
        'removes verse number spans and classed nodes (e.g., <span class="v">27</span>)',
        () {
      final html =
          '<p class="p"><span data-number="27" data-sid="GEN 1:27" class="v">27</span>'
          'God created man in his own image. In God\'s image he created him; male and female he created them.'
          '</p>';
      final jsonStr = json.encode({
        'data': {'reference': 'Genesis 1:27', 'content': html}
      });
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      final p = Passage.fromJson(map);
      expect(p.reference, 'Genesis 1:27');
      expect(p.text.contains('27'), isFalse,
          reason: 'verse number should be removed');
      expect(
        p.text,
        "God created man in his own image. In God's image he created him; male and female he created them.",
      );
    });
  });
}
