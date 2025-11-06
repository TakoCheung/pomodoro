import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/passage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

abstract class ScriptureServiceInterface {
  Future<Passage> fetchPassage({required String bibleId, required String passageId});
}

class ScriptureService implements ScriptureServiceInterface {
  final http.Client client;
  final String apiKey;
  final int maxRetries;
  final Duration retryDelay;
  final AssetBundle _bundle;

  // Simple in-memory cache to avoid repeatedly decoding large verse maps.
  final Map<String, Map<String, dynamic>> _verseMapCache = {};

  ScriptureService(
      {http.Client? client,
      required this.apiKey,
      this.maxRetries = 3,
      Duration? retryDelay,
      AssetBundle? bundle})
      : client = client ?? http.Client(),
        retryDelay = retryDelay ?? const Duration(milliseconds: 300),
        _bundle = bundle ?? rootBundle;

  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    void log(String msg) {
      if (kDebugMode) debugPrint('ScriptureService: $msg');
    }

    // Offline/instant path: check bundled verse text map first. If the
    // passageId exists locally, return immediately without any network call.
    try {
      final local = await _loadVerseTextIfPresent(bibleId: bibleId, passageId: passageId);
      if (local != null) {
        log('Using bundled verse text for $passageId (${local.length} chars)');
        return Passage(reference: passageId, text: local);
      }
    } catch (_) {
      // If anything goes wrong, fall back to network.
    }

    final uri = Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/verses/$passageId');
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final started = DateTime.now();
        log('GET $uri (attempt $attempt)');
        final resp =
            await client.get(uri, headers: {'api-key': apiKey}).timeout(const Duration(seconds: 5));
        final elapsed = DateTime.now().difference(started).inMilliseconds;
        log('Status ${resp.statusCode} in ${elapsed}ms');
        if (resp.statusCode == 200) {
          final json = jsonDecode(resp.body) as Map<String, dynamic>;
          final passage = Passage.fromJson(json);
          log('Fetched passage: ${passage.reference}');
          return passage;
        } else if (resp.statusCode == 404) {
          log('404 Not Found for $uri');
          throw HttpException('Passage not found', uri: uri);
        } else if (resp.statusCode == 429 || resp.statusCode >= 500) {
          if (attempt > maxRetries) {
            log('Giving up after $attempt attempts; last status ${resp.statusCode}');
            throw HttpException('Failed after $attempt attempts: ${resp.statusCode}', uri: uri);
          }
          final backoffMs = retryDelay.inMilliseconds * attempt;
          log('Retrying after ${backoffMs}ms');
          await Future.delayed(Duration(milliseconds: backoffMs));
          continue;
        } else {
          log('Request failed with status ${resp.statusCode}');
          throw HttpException('Failed to fetch passage: ${resp.statusCode}', uri: uri);
        }
      } on TimeoutException catch (_) {
        if (attempt > maxRetries) {
          log('Timeout on attempt $attempt; giving up');
          rethrow;
        }
        final backoffMs = retryDelay.inMilliseconds * attempt;
        log('Timeout on attempt $attempt; retrying after ${backoffMs}ms');
        await Future.delayed(Duration(milliseconds: backoffMs));
      }
    }
  }

  Future<String?> _loadVerseTextIfPresent(
      {required String bibleId, required String passageId}) async {
    // Load and cache the verses map for this bibleId lazily.
    Map<String, dynamic>? map = _verseMapCache[bibleId];
    if (map == null) {
      final path = 'assets/scripture_mapping/$bibleId-verses.json';
      try {
        final jsonStr = await _bundle.loadString(path);
        final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
        _verseMapCache[bibleId] = jsonMap;
        map = jsonMap;
      } catch (e) {
        // Asset missing or invalid; propagate as null result.
        return null;
      }
    }
    final val = map[passageId];
    if (val is String && val.isNotEmpty) return val;
    return null;
  }
}
