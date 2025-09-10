import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
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

  ScriptureService(
      {http.Client? client, required this.apiKey, this.maxRetries = 3, Duration? retryDelay})
      : client = client ?? http.Client(),
        retryDelay = retryDelay ?? const Duration(milliseconds: 300);

  @override
  Future<Passage> fetchPassage({required String bibleId, required String passageId}) async {
    void log(String msg) {
      if (kDebugMode) debugPrint('ScriptureService: $msg');
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
}
