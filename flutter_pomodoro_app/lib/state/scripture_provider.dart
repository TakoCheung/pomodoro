import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/data/bible_versions.dart';
import 'package:flutter_pomodoro_app/services/bible_catalog_service.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/models/scripture_request.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter/foundation.dart';

/// Configurable Bible ID, defaults to '32664dc3288a28df-01' for tests/backwards-compat.
final bibleIdProvider = Provider<String>((ref) {
  // If user selected a version in LocalSettings, prefer it.
  final name = ref.watch(localSettingsProvider).bibleVersionName;
  // dynamic mapping from fetched list
  try {
    final asyncList = ref.watch(bibleVersionsProvider);
    final fromRemote = asyncList.maybeWhen<String?>(
      data: (versions) {
        if (versions.isEmpty) return null;
        final match = versions.firstWhere(
          (v) => v.displayName == name || v.name == name || v.abbreviation == name,
          orElse: () => versions.first,
        );
        return match.id;
      },
      orElse: () => null,
    );
    if (fromRemote != null) return fromRemote;
  } catch (_) {}
  // fallback to static map
  final mapped = kBibleVersions[name];
  if (mapped != null && mapped.isNotEmpty) return mapped;
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
