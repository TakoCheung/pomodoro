import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/passage.dart';

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
    final uri = Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/passages/$passageId');
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final resp = await client.get(uri, headers: {'api-key': apiKey}).timeout(const Duration(seconds: 5));
        if (resp.statusCode == 200) {
          final json = jsonDecode(resp.body) as Map<String, dynamic>;
          return Passage.fromJson(json);
        } else if (resp.statusCode == 404) {
          throw HttpException('Passage not found', uri: uri);
        } else if (resp.statusCode == 429 || resp.statusCode >= 500) {
          if (attempt > maxRetries) {
            throw HttpException('Failed after $attempt attempts: ${resp.statusCode}', uri: uri);
          }
          await Future.delayed(Duration(milliseconds: retryDelay.inMilliseconds * attempt));
          continue;
        } else {
          throw HttpException('Failed to fetch passage: ${resp.statusCode}', uri: uri);
        }
      } on TimeoutException catch (_) {
  if (attempt > maxRetries) rethrow;
  await Future.delayed(Duration(milliseconds: retryDelay.inMilliseconds * attempt));
      }
    }
  }
}
