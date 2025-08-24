import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/scripture_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';

/// A small repository that picks a random passage id from a list and fetches it
/// from the provided [ScriptureServiceInterface]. It caches the fetched passage
/// for a single day (based on the provided [now] function) so repeated calls
/// within the same day return the cached passage.
class ScriptureRepository {
  final ScriptureServiceInterface service;
  final DateTime Function() now;
  Passage? _cached;
  DateTime? _cachedDate;
  final Random _rng;

  ScriptureRepository({required this.service, DateTime Function()? now, Random? rng})
      : now = now ?? DateTime.now,
        _rng = rng ?? Random();

  Future<Passage> getRandomPassageOncePerDay({required String bibleId, required List<String> passageIds}) async {
    final today = DateTime(now().year, now().month, now().day);
    if (_cached != null && _cachedDate != null) {
      final cachedDay = DateTime(_cachedDate!.year, _cachedDate!.month, _cachedDate!.day);
      if (cachedDay == today) {
        return _cached!;
      }
    }

    if (passageIds.isEmpty) throw ArgumentError('passageIds must not be empty');
    final idx = _rng.nextInt(passageIds.length);
    final passageId = passageIds[idx];
    final p = await service.fetchPassage(bibleId: bibleId, passageId: passageId);
    _cached = p;
    _cachedDate = now();
    return p;
  }
}

final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {
  final svc = ref.read(scriptureServiceProvider);
  return ScriptureRepository(service: svc);
});
