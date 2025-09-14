import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle, Clipboard, ClipboardData;
import 'package:flutter_pomodoro_app/state/scripture_repository.dart'
    show sharedPreferencesProvider;

class ScriptureMapping {
  final String bibleId;
  // bookId -> chapterId -> [verseIds]
  final Map<String, Map<String, List<String>>> data;
  final DateTime builtAt;
  const ScriptureMapping({required this.bibleId, required this.data, required this.builtAt});

  bool get isEmpty => data.isEmpty;

  Map<String, dynamic> toJson() => {
        'bibleId': bibleId,
        'builtAt': builtAt.toIso8601String(),
        'data': data.map(
            (book, chapters) => MapEntry(book, chapters.map((ch, verses) => MapEntry(ch, verses)))),
      };

  factory ScriptureMapping.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] as Map<String, dynamic>? ?? const {};
    final map = <String, Map<String, List<String>>>{};
    raw.forEach((book, chapters) {
      final chMap = <String, List<String>>{};
      if (chapters is Map<String, dynamic>) {
        chapters.forEach((ch, verses) {
          if (verses is List) {
            chMap[ch] = verses.map((e) => e.toString()).toList(growable: false);
          }
        });
      }
      map[book] = chMap;
    });
    return ScriptureMapping(
      bibleId: json['bibleId'] as String,
      data: map,
      builtAt: DateTime.parse(json['builtAt'] as String),
    );
  }
}

abstract class ScriptureMappingServiceInterface {
  Future<ScriptureMapping> buildMapping(String bibleId);
}

class ScriptureMappingService implements ScriptureMappingServiceInterface {
  final http.Client client;
  final String apiKey;
  ScriptureMappingService({http.Client? client, required this.apiKey})
      : client = client ?? http.Client();

  @override
  Future<ScriptureMapping> buildMapping(String bibleId) async {
    // Production implementation can be heavy; keep minimal and allow tests to override service.
    // We'll fetch books and one chapter each as a placeholder to avoid long runtime if called.
    Future<http.Response> get(Uri uri) => client.get(uri, headers: {'api-key': apiKey});
    final booksUri = Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/books');
    if (kDebugMode) debugPrint('ScriptureMappingService: GET $booksUri');
    final booksResp = await get(booksUri);
    if (booksResp.statusCode != 200) {
      throw Exception('Failed to fetch books: ${booksResp.statusCode}');
    }
    final booksBody = json.decode(booksResp.body) as Map<String, dynamic>;
    final books = (booksBody['data'] as List<dynamic>? ?? const [])
        .map((e) => (e as Map<String, dynamic>)['id'] as String)
        .toList(growable: false);
    final data = <String, Map<String, List<String>>>{};
    // Limit to first 1-2 books to keep it light.
    for (final bookId in books) {
      final chaptersUri =
          Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/books/$bookId/chapters');
      if (kDebugMode) debugPrint('ScriptureMappingService: GET $chaptersUri');
      final chResp = await get(chaptersUri);
      if (chResp.statusCode != 200) continue;
      final chBody = json.decode(chResp.body) as Map<String, dynamic>;
      final chapters = (chBody['data'] as List<dynamic>? ?? const [])
          .map((e) => (e as Map<String, dynamic>)['id'] as String)
          .toList(growable: false);
      final chMap = <String, List<String>>{};
      for (final chId in chapters) {
        final versesUri =
            Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/chapters/$chId/verses');
        if (kDebugMode) debugPrint('ScriptureMappingService: GET $versesUri');
        final vResp = await get(versesUri);
        if (vResp.statusCode != 200) continue;
        final vBody = json.decode(vResp.body) as Map<String, dynamic>;
        final verses = (vBody['data'] as List<dynamic>? ?? const [])
            .map((e) => (e as Map<String, dynamic>)['id'] as String)
            .toList(growable: false);
        chMap[chId] = verses;
      }
      data[bookId] = chMap;
    }
    return ScriptureMapping(bibleId: bibleId, data: data, builtAt: DateTime.now());
  }
}

const _prefsKeyPrefix = 'scripture_mapping_v1';

/// Injectable [AssetBundle] to allow overriding in tests.
final assetBundleProvider = Provider<AssetBundle>((ref) => rootBundle);

final scriptureMappingServiceProvider = Provider<ScriptureMappingServiceInterface>((ref) {
  final key = dotenv.env['SCRIPTURE_API_KEY'];
  if (key == null || key.isEmpty) {
    throw UnimplementedError(
        'SCRIPTURE_API_KEY not set; override scriptureMappingServiceProvider in tests');
  }
  return ScriptureMappingService(apiKey: key);
});

final scriptureMappingProvider =
    FutureProvider.family<ScriptureMapping, String>((ref, bibleId) async {
  // 1) Try bundled asset first for fast/offline startup.
  try {
    final bundle = ref.read(assetBundleProvider);
    final assetPath = 'assets/scripture_mapping/$bibleId.json';
    final jsonStr = await bundle.loadString(assetPath);
    final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
    final mapping = ScriptureMapping.fromJson(jsonMap);
    // Backfill SharedPreferences cache best-effort.
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final key = '$_prefsKeyPrefix:$bibleId';
      await prefs.setString(key, json.encode(mapping.toJson()));
    } catch (_) {}
    return mapping;
  } catch (_) {
    // Asset miss or parse error: fall through.
  }

  // 2) Try SharedPreferences cache.
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final key = '$_prefsKeyPrefix:$bibleId';
  final cached = prefs.getString(key);
  if (cached != null) {
    try {
      final jsonMap = json.decode(cached) as Map<String, dynamic>;
      if (kDebugMode) {
        try {
          final pretty = const JsonEncoder.withIndent('  ').convert(jsonMap);
          // is it possible to save the pretty into the clipboard for easier inspection?
          try {
            await Clipboard.setData(ClipboardData(text: pretty));
            debugPrint('Copied cached scripture mapping JSON for $bibleId to clipboard');
          } catch (_) {
            // ignore clipboard errors
          }
        } catch (_) {
          debugPrint('Cached scripture mapping JSON (raw) for $bibleId: $jsonMap');
        }
      }
      if (kDebugMode) debugPrint('Loaded scripture mapping for $bibleId from cache');
      final mapping = ScriptureMapping.fromJson(jsonMap);
      return mapping;
    } catch (_) {
      // ignore corrupt cache
    }
  }

  // 3) Fallback to network service and cache result.
  final service = ref.read(scriptureMappingServiceProvider);
  final mapping = await service.buildMapping(bibleId);
  try {
    await prefs.setString(key, json.encode(mapping.toJson()));
  } catch (_) {}
  return mapping;
});

/// True when the mapping for the given bibleId has been loaded and is non-empty.
final scriptureMappingReadyProvider = Provider.family<bool, String>((ref, bibleId) {
  final async = ref.watch(scriptureMappingProvider(bibleId));
  return async.maybeWhen(data: (m) => !m.isEmpty, orElse: () => false);
});
