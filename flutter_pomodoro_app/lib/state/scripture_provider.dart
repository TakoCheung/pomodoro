import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/models/scripture_request.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter/foundation.dart';

/// Configurable Bible ID, defaults to '32664dc3288a28df-01' for tests/backwards-compat.
final bibleIdProvider = Provider<String>((ref) {
  try {
    final id = dotenv.env['BIBLE_ID'];
    if (id != null && id.isNotEmpty) return id;
  } catch (_) {
    // dotenv may not be initialized in tests
  }
  return '32664dc3288a28df-01';
});

final scriptureServiceProvider = Provider<ScriptureServiceInterface>((ref) {
  final key = dotenv.env['SCRIPTURE_API_KEY'];
  if (key == null || key.isEmpty) {
    throw UnimplementedError('SCRIPTURE_API_KEY not set; override scriptureServiceProvider in tests or set env');
  }
  if (kDebugMode) {
    try {
      // Log presence without leaking the key value
      debugPrint('scriptureServiceProvider: SCRIPTURE_API_KEY detected (len=${key.length})');
    } catch (_) {}
  }
  return ScriptureService(apiKey: key);
});

final scriptureProvider = FutureProvider.family<Passage, ScriptureRequest>((ref, req) async {
  final bibleId = req.bibleId;
  final passageId = req.passageId;
  final service = ref.read(scriptureServiceProvider);
  return service.fetchPassage(bibleId: bibleId, passageId: passageId);
});
