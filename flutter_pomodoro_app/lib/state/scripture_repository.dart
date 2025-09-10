import 'dart:math';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_pomodoro_app/utils/verse_picker.dart';

/// A small repository that picks a random passage id from a list and fetches it
/// from the provided [ScriptureServiceInterface]. It caches the fetched passage
/// for a single day (based on the provided [now] function) so repeated calls
/// within the same day return the cached passage.
class ScriptureRepository {
  final ScriptureServiceInterface service;
  final DateTime Function() now;
  Passage? _cached;
  String? _cachedBibleId;
  DateTime? _cachedDate;
  final SharedPreferences? _prefs;
  final Random _rng;
  final List<Passage> _history = <Passage>[];
  // New: per-bibleId cache entries in-memory for same-day reuse.
  final Map<String, _CacheEntry> _perIdCache = <String, _CacheEntry>{};
  // New V2 history with bibleId metadata for selection by version.
  final List<_HistoryItem> _historyV2 = <_HistoryItem>[];

  ScriptureRepository(
      {required this.service, DateTime Function()? now, Random? rng, SharedPreferences? prefs})
      : now = now ?? DateTime.now,
        _rng = rng ?? Random(),
        _prefs = prefs {
    // Attempt to hydrate from SharedPreferences if available.
    if (_prefs != null) {
      final jsonStr = _prefs.getString(_prefsKeyCachedPassage);
      final dateStr = _prefs.getString(_prefsKeyCachedDate);
      final cachedId = _prefs.getString(_prefsKeyCachedBibleId);
      if (jsonStr != null && dateStr != null) {
        try {
          _cached = Passage.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
          _cachedDate = DateTime.parse(dateStr);
          _cachedBibleId = cachedId;
          // Hydrate in-memory per-id cache for the persisted entry too.
          if (_cached != null && _cachedBibleId != null && _cachedDate != null) {
            _perIdCache[_cachedBibleId!] = _CacheEntry(passage: _cached!, date: _cachedDate!);
          }
        } catch (_) {
          // ignore and leave cache empty
          _cached = null;
          _cachedDate = null;
          _cachedBibleId = null;
        }
      }
      // Hydrate history
      final historyStr = _prefs.getString(_prefsKeyHistory);
      if (historyStr != null) {
        try {
          final list = json.decode(historyStr) as List<dynamic>;
          _history.clear();
          for (final e in list) {
            if (e is Map<String, dynamic>) {
              _history.add(Passage.fromJson(e));
            } else if (e is Map) {
              _history.add(Passage.fromJson(e.cast<String, dynamic>()));
            }
          }
        } catch (_) {
          // ignore corrupt history
          _history.clear();
        }
      }
      // Hydrate V2 history (if present)
      final history2Str = _prefs.getString(_prefsKeyHistoryV2);
      if (history2Str != null) {
        try {
          final list = json.decode(history2Str) as List<dynamic>;
          _historyV2.clear();
          for (final e in list) {
            if (e is Map<String, dynamic>) {
              _historyV2.add(_HistoryItem.fromJson(e));
            } else if (e is Map) {
              _historyV2.add(_HistoryItem.fromJson(e.cast<String, dynamic>()));
            }
          }
        } catch (_) {
          _historyV2.clear();
        }
      }
    }
  }

  /// The last cached passage for today, if any.
  Passage? get cachedPassage {
    if (_cached == null || _cachedDate == null) return null;
    final today = DateTime(now().year, now().month, now().day);
    final cachedDay = DateTime(_cachedDate!.year, _cachedDate!.month, _cachedDate!.day);
    return cachedDay == today ? _cached : null;
  }

  /// Returns today's cached passage, but only if it was fetched with the
  /// provided bibleId. This ensures we don't show an ESV passage when the
  /// user switched to another version.
  Passage? cachedPassageForBible(String bibleId) {
    // Prefer new per-id cache.
    final entry = _perIdCache[bibleId];
    if (entry != null) {
      final today = DateTime(now().year, now().month, now().day);
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (day == today) return entry.passage;
    }
    // Back-compat: fall back to single cached slot, but only if it matches id and today.
    final p = cachedPassage;
    if (p == null) return null;
    if (_cachedBibleId == null) return null;
    return _cachedBibleId == bibleId ? p : null;
  }

  Future<Passage> selectPassageForBreak(
      {required String bibleId, required List<String> passageIds}) async {
    final today = DateTime(now().year, now().month, now().day);
    // Check per-id cache first
    final existing = _perIdCache[bibleId];
    if (existing != null) {
      final day = DateTime(existing.date.year, existing.date.month, existing.date.day);
      if (day == today) return existing.passage;
    }
    // Back-compat single-slot: only use if same id and today
    if (_cached != null && _cachedDate != null && _cachedBibleId == bibleId) {
      final cachedDay = DateTime(_cachedDate!.year, _cachedDate!.month, _cachedDate!.day);
      if (cachedDay == today) {
        return _cached!;
      }
    }
    // New behavior: return one of the cached passages for this bibleId if any exist.
    final priorForId = _historyV2.where((h) => h.bibleId == bibleId).toList();
    if (priorForId.isNotEmpty) {
      final chosen = priorForId[_rng.nextInt(priorForId.length)].passage;
      // Mark as today's cache for subsequent quick access; do not append to history.
      _cached = chosen;
      _cachedBibleId = bibleId;
      _cachedDate = now();
      _perIdCache[bibleId] = _CacheEntry(passage: chosen, date: _cachedDate!);
      return chosen;
    }
    if (passageIds.isEmpty) {
      throw StateError('No verse candidates provided');
    }
    final passageId = pickRandomVerseId(_rng, candidates: passageIds);
    final p = await service.fetchPassage(bibleId: bibleId, passageId: passageId);
    _cached = p;
    _cachedBibleId = bibleId;
    _cachedDate = now();
    _perIdCache[bibleId] = _CacheEntry(passage: p, date: _cachedDate!);
    // persist if prefs available
    if (_prefs != null) {
      try {
        await _prefs.setString(_prefsKeyCachedPassage, json.encode(p.toJson()));
        if (_cachedDate != null) {
          await _prefs.setString(_prefsKeyCachedDate, _cachedDate!.toIso8601String());
        }
        await _prefs.setString(_prefsKeyCachedBibleId, bibleId);
        // Also append to history and persist
        _history.add(p);
        _historyV2.add(_HistoryItem(bibleId: bibleId, passage: p, date: _cachedDate!));
        await _persistHistory();
      } catch (_) {
        // ignore persistence errors
      }
    }
    return p;
  }

  /// Always fetches a new random passage and updates the cache for today,
  /// regardless of whether a passage has already been cached.
  Future<Passage> fetchAndCacheRandomPassage(
      {required String bibleId, required List<String> passageIds}) async {
    if (passageIds.isEmpty) {
      throw StateError('No verse candidates provided');
    }
    final passageId = pickRandomVerseId(_rng, candidates: passageIds);
    final p = await service.fetchPassage(bibleId: bibleId, passageId: passageId);
    _cached = p;
    _cachedBibleId = bibleId;
    _cachedDate = now();
    _perIdCache[bibleId] = _CacheEntry(passage: p, date: _cachedDate!);
    if (_prefs != null) {
      try {
        await _prefs.setString(_prefsKeyCachedPassage, json.encode(p.toJson()));
        await _prefs.setString(_prefsKeyCachedDate, _cachedDate!.toIso8601String());
        await _prefs.setString(_prefsKeyCachedBibleId, bibleId);
        // Append to history and persist
        _history.add(p);
        _historyV2.add(_HistoryItem(bibleId: bibleId, passage: p, date: _cachedDate!));
        await _persistHistory();
      } catch (_) {}
    }
    return p;
  }

  /// Test helper to seed the cache for today without fetching.
  @visibleForTesting
  void setCachedForToday(Passage passage) {
    _cached = passage;
    _cachedDate = now();
  }

  /// Read-only history of all fetched passages (order of fetch).
  List<Passage> get history => List.unmodifiable(_history);

  Future<void> _persistHistory() async {
    if (_prefs == null) return;
    try {
      final list = _history.map((p) => p.toJson()).toList(growable: false);
      await _prefs.setString(_prefsKeyHistory, json.encode(list));
      final list2 = _historyV2.map((h) => h.toJson()).toList(growable: false);
      await _prefs.setString(_prefsKeyHistoryV2, json.encode(list2));
    } catch (_) {
      // ignore persistence errors
    }
  }

  /// Returns any cached passage for the given bibleId (most recent),
  /// or null if none have ever been cached.
  Passage? anyCachedForBible(String bibleId) {
    final entry = _perIdCache[bibleId];
    if (entry != null) return entry.passage;
    for (var i = _historyV2.length - 1; i >= 0; i--) {
      final h = _historyV2[i];
      if (h.bibleId == bibleId) return h.passage;
    }
    return null;
  }
}

const _prefsKeyCachedPassage = 'scripture_cached_passage';
const _prefsKeyCachedDate = 'scripture_cached_date';
const _prefsKeyCachedBibleId = 'scripture_cached_bible_id';
const _prefsKeyHistory = 'scripture_history';
const _prefsKeyHistoryV2 = 'scripture_history_v2';

class _CacheEntry {
  final Passage passage;
  final DateTime date;
  _CacheEntry({required this.passage, required this.date});
}

class _HistoryItem {
  final String bibleId;
  final Passage passage;
  final DateTime date;
  _HistoryItem({required this.bibleId, required this.passage, required this.date});
  Map<String, dynamic> toJson() => {
        'bibleId': bibleId,
        'passage': passage.toJson(),
        'date': date.toIso8601String(),
      };
  factory _HistoryItem.fromJson(Map<String, dynamic> jsonMap) => _HistoryItem(
        bibleId: jsonMap['bibleId'] as String,
        passage: Passage.fromJson(jsonMap['passage'] as Map<String, dynamic>),
        date: DateTime.parse(jsonMap['date'] as String),
      );
}

final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {
  final svc = ref.read(scriptureServiceProvider);
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  if (prefsAsync is AsyncData<SharedPreferences>) {
    return ScriptureRepository(service: svc, prefs: prefsAsync.value);
  }
  // If prefs not ready, return repository without persistence; callers can override in tests.
  return ScriptureRepository(service: svc);
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});
