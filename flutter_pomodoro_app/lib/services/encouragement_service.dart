import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Loads long break encouragement/context text mapped by verse id
/// from a bundled JSON asset. Keys are verse ids like 'NAM.1.1'.
class EncouragementService {
  final AssetBundle _bundle;
  // Cache per-book map, e.g. 'NAM' -> loaded JSON map
  final Map<String, Map<String, dynamic>> _cacheByBook = {};

  EncouragementService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  Future<Map<String, dynamic>> _loadForBook(String book) async {
    final upper = book.toUpperCase();
    final cached = _cacheByBook[upper];
    if (cached != null) return cached;
    final lower = upper.toLowerCase();
    final path = 'assets/scripture_mapping/cc-from-$lower.json';
    try {
      final jsonStr = await _bundle.loadString(path);
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      _cacheByBook[upper] = jsonMap;
      return jsonMap;
    } catch (e) {
      if (kDebugMode) debugPrint('EncouragementService: load failed for $path: $e');
      _cacheByBook[upper] = const {};
      return const {};
    }
  }

  /// Returns the encouragement/context text for a verse id, or null if not found.
  Future<String?> forVerseId(String verseId) async {
    // Expect verseId like 'NAM.1.1'
    final parts = verseId.split('.');
    if (parts.isEmpty || parts.first.isEmpty) return null;
    final book = parts.first;
    final map = await _loadForBook(book);
    final val = map[verseId];
    if (val is String && val.isNotEmpty) return val;
    return null;
  }
}
