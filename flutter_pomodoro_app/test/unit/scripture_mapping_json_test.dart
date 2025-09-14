import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/services/scripture_mapping_service.dart';

void main() {
  test('ScriptureMapping JSON round-trip', () {
    final original = ScriptureMapping(
      bibleId: 'X',
      builtAt: DateTime.parse('2025-09-01T12:34:56.000Z'),
      data: {
        'GEN': {
          'GEN.1': ['GEN.1.1', 'GEN.1.2']
        },
        'EXO': {'EXO.1': []},
      },
    );
    final jsonStr = json.encode(original.toJson());
    final decoded = ScriptureMapping.fromJson(json.decode(jsonStr) as Map<String, dynamic>);

    expect(decoded.bibleId, original.bibleId);
    expect(decoded.builtAt.toUtc(), original.builtAt.toUtc());
    expect(decoded.data.keys.toSet(), original.data.keys.toSet());
    expect(decoded.data['GEN']!['GEN.1'], ['GEN.1.1', 'GEN.1.2']);
  });
}
