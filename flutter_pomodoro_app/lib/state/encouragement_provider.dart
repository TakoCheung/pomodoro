import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/encouragement_service.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';

final encouragementServiceProvider = Provider<EncouragementService>((ref) {
  return EncouragementService();
});

/// Resolves an encouragement/context string for the currently shown passage
/// when in long break mode. Returns null otherwise.
final encouragementForCurrentPassageProvider = FutureProvider<String?>((ref) async {
  final mode = ref.watch(timerProvider).mode;
  if (mode != TimerMode.longBreak) return null;
  final passage = ref.watch(shownScriptureProvider);
  if (passage == null) return null;
  final id = _deriveVerseId(passage);
  if (id == null) return null;
  final svc = ref.read(encouragementServiceProvider);
  return svc.forVerseId(id);
});

String? _deriveVerseId(Passage p) {
  // Prefer explicit verse id from API payload if present
  if (p.verses.isNotEmpty) {
    final first = p.verses.first;
    if (first is Map && first['id'] is String) {
      return first['id'] as String;
    }
  }
  // Fallback: if the reference already looks like a verse id (e.g., NAM.1.1)
  final refStr = p.reference;
  final idLike = RegExp(r'^[A-Z0-9]{3}\.\d+\.\d+$');
  if (idLike.hasMatch(refStr)) return refStr;
  return null;
}
