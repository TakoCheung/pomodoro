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
  DateTime? _cachedDate;
  final SharedPreferences? _prefs;
  final Random _rng;

  ScriptureRepository({required this.service, DateTime Function()? now, Random? rng, SharedPreferences? prefs})
      : now = now ?? DateTime.now,
        _rng = rng ?? Random(),
        _prefs = prefs {
    // Attempt to hydrate from SharedPreferences if available.
    if (_prefs != null) {
  final jsonStr = _prefs.getString(_prefsKeyCachedPassage);
  final dateStr = _prefs.getString(_prefsKeyCachedDate);
      if (jsonStr != null && dateStr != null) {
        try {
          _cached = Passage.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
          _cachedDate = DateTime.parse(dateStr);
        } catch (_) {
          // ignore and leave cache empty
          _cached = null;
          _cachedDate = null;
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

  Future<Passage> getRandomPassageOncePerDay({required String bibleId, required List<String> passageIds}) async {
    final today = DateTime(now().year, now().month, now().day);
    if (_cached != null && _cachedDate != null) {
      final cachedDay = DateTime(_cachedDate!.year, _cachedDate!.month, _cachedDate!.day);
      if (cachedDay == today) {
        return _cached!;
      }
    }
    // If caller doesn't provide candidates, pick from default curated verse IDs.
    final passageId = pickRandomVerseId(_rng, candidates: passageIds);
    final p = await service.fetchPassage(bibleId: bibleId, passageId: passageId);
    _cached = p;
    _cachedDate = now();
    // persist if prefs available
    if (_prefs != null) {
      try {
        await _prefs.setString(_prefsKeyCachedPassage, json.encode(p.toJson()));
        if (_cachedDate != null) {
          await _prefs.setString(_prefsKeyCachedDate, _cachedDate!.toIso8601String());
        }
      } catch (_) {
        // ignore persistence errors
      }
    }
    return p;
  }

  /// Always fetches a new random passage and updates the cache for today,
  /// regardless of whether a passage has already been cached.
  Future<Passage> fetchAndCacheRandomPassage({required String bibleId, required List<String> passageIds}) async {
    final passageId = pickRandomVerseId(_rng, candidates: passageIds);
    final p = await service.fetchPassage(bibleId: bibleId, passageId: passageId);
    _cached = p;
    _cachedDate = now();
    if (_prefs != null) {
      try {
        await _prefs.setString(_prefsKeyCachedPassage, json.encode(p.toJson()));
        await _prefs.setString(_prefsKeyCachedDate, _cachedDate!.toIso8601String());
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
}

const _prefsKeyCachedPassage = 'scripture_cached_passage';
const _prefsKeyCachedDate = 'scripture_cached_date';

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
