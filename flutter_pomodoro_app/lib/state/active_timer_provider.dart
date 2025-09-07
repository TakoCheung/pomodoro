import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart'
    show sharedPreferencesProvider;

class ActiveTimer {
  final String timerId;
  final DateTime startUtc;
  final DateTime endUtc;
  final String label;
  ActiveTimer(
      {required this.timerId, required this.startUtc, required this.endUtc, required this.label});

  Map<String, dynamic> toJson() => {
        'timerId': timerId,
        'startUtc': startUtc.toIso8601String(),
        'endUtc': endUtc.toIso8601String(),
        'label': label,
      };

  static ActiveTimer? fromJson(Map<String, dynamic> m) {
    try {
      return ActiveTimer(
        timerId: m['timerId'] as String,
        startUtc: DateTime.parse(m['startUtc'] as String).toUtc(),
        endUtc: DateTime.parse(m['endUtc'] as String).toUtc(),
        label: (m['label'] as String?) ?? '',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('ActiveTimer decode error: $e');
      return null;
    }
  }
}

// Use the app-wide SharedPreferences provider so tests can override it easily.

final activeTimerProvider = StateNotifierProvider<ActiveTimerNotifier, ActiveTimer?>((ref) {
  return ActiveTimerNotifier(ref);
});

class ActiveTimerNotifier extends StateNotifier<ActiveTimer?> {
  final Ref ref;
  static const _key = 'activeTimer';
  ActiveTimerNotifier(this.ref) : super(null) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = ActiveTimer.fromJson(map);
    } catch (_) {
      // In tests or environments without initialized bindings/prefs, skip hydration.
      return;
    }
  }

  Future<void> save(ActiveTimer t) async {
    state = t;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_key, jsonEncode(t.toJson()));
    } catch (_) {
      // Ignore persistence errors in tests
    }
  }

  Future<void> clear() async {
    state = null;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.remove(_key);
    } catch (_) {
      // Ignore persistence errors in tests
    }
  }
}
