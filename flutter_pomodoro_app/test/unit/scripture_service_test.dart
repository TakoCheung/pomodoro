import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import '../fixtures/fixture_reader.dart';

void main() {
  test('fetchPassage sends api-key header and parses 200 response', () async {
    final fixture = await fixtureReader('passage_gen_1_1.json');
    final client = MockClient((request) async {
      expect(request.headers['api-key'], equals('test-key'));
  // Ensure we use the `verses/{id}` endpoint per API docs
  expect(request.url.path, contains('/bibles/32664dc3288a28df-01/verses/GEN.1.1'));
      return http.Response(fixture, 200, headers: {
        'content-type': 'application/json'
      });
    });

    final service = ScriptureService(client: client, apiKey: 'test-key');
    final p = await service.fetchPassage(bibleId: '32664dc3288a28df-01', passageId: 'GEN.1.1');
    expect(p.reference, equals('Genesis 1:1'));
    expect(p.text, contains('In the beginning'));
  });

  test('fetchPassage throws on 404', () async {
    final client = MockClient((request) async {
      return http.Response('{}', 404);
    });
  final service = ScriptureService(client: client, apiKey: 'test-key');
  expect(service.fetchPassage(bibleId: '32664dc3288a28df-01', passageId: 'MISSING'), throwsException);
  });

  test('fetchPassage retries on 500 and eventually throws', () async {
    int calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('{}', 500);
    });
  final service = ScriptureService(client: client, apiKey: 'test-key', maxRetries: 2, retryDelay: Duration(milliseconds: 1));
  await expectLater(service.fetchPassage(bibleId: '32664dc3288a28df-01', passageId: 'GEN.1.1'), throwsException);
  // ensure multiple calls occurred (retries)
  expect(calls > 1, isTrue);
  });
}
