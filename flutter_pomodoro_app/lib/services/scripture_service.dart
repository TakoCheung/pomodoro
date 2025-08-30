import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_pomodoro_app/data/verse_ids_esv.dart';
import '../models/passage.dart';
import 'package:flutter/foundation.dart';

abstract class ScriptureServiceInterface {
  Future<Passage> fetchPassage({required String bibleId, required String passageId});
}

class ScriptureService implements ScriptureServiceInterface {
  final http.Client client;
  final String apiKey;
  final int maxRetries;
  final Duration retryDelay;

  ScriptureService({http.Client? client, required this.apiKey, this.maxRetries = 3, Duration? retryDelay})
      : client = client ?? http.Client(),
        retryDelay = retryDelay ?? const Duration(milliseconds: 300);

  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    void _log(String msg) {
      if (kDebugMode) debugPrint('ScriptureService: ' + msg);
    }
    // The API docs recommend using the /verses/{verseId} endpoint for specific verses.
    // See: https://docs.api.bible/tutorials/getting-a-specific-verse
    // We validate the ID format lightly, then request via /verses.
    if (!isLikelyValidVerseId(passageId)) {
      // Throw an Exception type so tests using `throwsException` pass.
      _log('Invalid verse ID format: ' + passageId);
      throw FormatException('Invalid verse ID format: $passageId');
    }
    final uri = Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/verses/$passageId');
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final started = DateTime.now();
        _log('GET ' + uri.toString() + ' (attempt ' + attempt.toString() + ')');
        final resp = await client.get(uri, headers: {'api-key': apiKey}).timeout(const Duration(seconds: 5));
        final elapsed = DateTime.now().difference(started).inMilliseconds;
        _log('Status ' + resp.statusCode.toString() + ' in ' + elapsed.toString() + 'ms');
        if (resp.statusCode == 200) {
          final json = jsonDecode(resp.body) as Map<String, dynamic>;
          final passage = Passage.fromJson(json);
          _log('Fetched passage: ' + passage.reference);
          return passage;
        } else if (resp.statusCode == 404) {
          _log('404 Not Found for ' + uri.toString());
          throw HttpException('Passage not found', uri: uri);
        } else if (resp.statusCode == 429 || resp.statusCode >= 500) {
          if (attempt > maxRetries) {
            _log('Giving up after ' + attempt.toString() + ' attempts; last status ' + resp.statusCode.toString());
            throw HttpException('Failed after $attempt attempts: ${resp.statusCode}', uri: uri);
          }
          final backoffMs = retryDelay.inMilliseconds * attempt;
          _log('Retrying after ' + backoffMs.toString() + 'ms');
          await Future.delayed(Duration(milliseconds: backoffMs));
          continue;
        } else {
          _log('Request failed with status ' + resp.statusCode.toString());
          throw HttpException('Failed to fetch passage: ${resp.statusCode}', uri: uri);
        }
      } on TimeoutException catch (_) {
  if (attempt > maxRetries) {
    _log('Timeout on attempt ' + attempt.toString() + '; giving up');
    rethrow;
  }
  final backoffMs = retryDelay.inMilliseconds * attempt;
  _log('Timeout on attempt ' + attempt.toString() + '; retrying after ' + backoffMs.toString() + 'ms');
  await Future.delayed(Duration(milliseconds: backoffMs));
      }
    }
  }
}
