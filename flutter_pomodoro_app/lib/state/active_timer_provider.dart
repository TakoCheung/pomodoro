import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

final _prefsProvider =
    FutureProvider<SharedPreferences>((_) async => SharedPreferences.getInstance());

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
    final prefs = await ref.read(_prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    state = ActiveTimer.fromJson(map);
  }

  Future<void> save(ActiveTimer t) async {
    state = t;
    final prefs = await ref.read(_prefsProvider.future);
    await prefs.setString(_key, jsonEncode(t.toJson()));
  }

  Future<void> clear() async {
    state = null;
    final prefs = await ref.read(_prefsProvider.future);
    await prefs.remove(_key);
  }
}
