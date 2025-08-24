import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/models/scripture_request.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';

final scriptureServiceProvider = Provider<ScriptureServiceInterface>((ref) {
  final key = dotenv.env['SCRIPTURE_API_KEY'];
  if (key == null || key.isEmpty) {
    throw UnimplementedError('SCRIPTURE_API_KEY not set; override scriptureServiceProvider in tests or set env');
  }
  return ScriptureService(apiKey: key);
});

final scriptureProvider = FutureProvider.family<Passage, ScriptureRequest>((ref, req) async {
  final bibleId = req.bibleId;
  final passageId = req.passageId;
  final service = ref.read(scriptureServiceProvider);
  return service.fetchPassage(bibleId: bibleId, passageId: passageId);
});
