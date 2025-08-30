import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/models/bible_version.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart'
    show sharedPreferencesProvider;

abstract class BibleCatalogServiceInterface {
  Future<List<BibleVersion>> fetchBibles();
}

class BibleCatalogService implements BibleCatalogServiceInterface {
  final http.Client client;
  final String apiKey;

  BibleCatalogService({http.Client? client, required this.apiKey})
      : client = client ?? http.Client();

  @override
  Future<List<BibleVersion>> fetchBibles() async {
    final uri = Uri.parse('https://api.scripture.api.bible/v1/bibles');
    if (kDebugMode) debugPrint('BibleCatalogService: GET $uri');
    final resp = await client.get(uri,
        headers: {'api-key': apiKey}).timeout(const Duration(seconds: 5));
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch bibles: ${resp.statusCode}');
    }
    final body = json.decode(resp.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => BibleVersion.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}

const _prefsKeyBibleVersions = 'bible_versions_cache_v1';

final bibleCatalogServiceProvider =
    Provider<BibleCatalogServiceInterface>((ref) {
  final key = dotenv.env['SCRIPTURE_API_KEY'];
  if (key == null || key.isEmpty) {
    throw UnimplementedError(
        'SCRIPTURE_API_KEY not set; cannot fetch bible catalog');
  }
  return BibleCatalogService(apiKey: key);
});

final bibleVersionsProvider = FutureProvider<List<BibleVersion>>((ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  // Try cache first
  final cached = prefs.getString(_prefsKeyBibleVersions);
  if (cached != null && cached.isNotEmpty) {
    try {
      final list = (json.decode(cached) as List<dynamic>)
          .map((e) => BibleVersion.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      if (list.isNotEmpty) return list;
    } catch (_) {
      // ignore corrupt cache and refetch
    }
  }
  // Fetch from API
  final svc = ref.read(bibleCatalogServiceProvider);
  final fetched = await svc.fetchBibles();
  // Persist cache (best-effort)
  try {
    final enc =
        json.encode(fetched.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_prefsKeyBibleVersions, enc);
  } catch (_) {}
  return fetched;
});
