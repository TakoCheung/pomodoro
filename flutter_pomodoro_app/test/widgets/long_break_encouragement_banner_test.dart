import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/state/alarm_banner_provider.dart';
import 'package:flutter_pomodoro_app/state/encouragement_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/services/encouragement_service.dart';
import 'package:flutter/services.dart';

class _FakeBundle extends CachingAssetBundle {
  final Map<String, String> files;
  _FakeBundle(this.files);
  @override
  Future<ByteData> load(String key) async {
    final str = files[key];
    if (str == null) throw StateError('not found');
    final list = Uint8List.fromList(str.codeUnits);
    return ByteData.view(list.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final str = files[key];
    if (str == null) throw StateError('not found');
    return str;
  }
}

void main() {
  testWidgets('Long break shows encouragement appended to banner snippet', (tester) async {
    final data = '{"NAM.1.1": "Test Encouragement"}';
    final svc = EncouragementService(
        bundle: _FakeBundle({
      'assets/scripture_mapping/cc-from-nam.json': data,
    }));
    final container = ProviderContainer(overrides: [
      encouragementServiceProvider.overrideWithValue(svc),
    ]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: PomodoroTimerScreen()),
      ),
    );
    await tester.pump();

    // Seed state
    container.read(timerProvider.notifier).setForTest(mode: TimerMode.longBreak);
    container.read(shownScriptureProvider.notifier).state = Passage(
      reference: 'NAM.1.1',
      text: 'Verse text',
      verses: [
        {'id': 'NAM.1.1'},
      ],
    );
    container.read(alarmBannerVisibleProvider.notifier).state = true;

    await tester.pumpAndSettle();

    // Banner present
    expect(find.byKey(const Key('alarm_banner')), findsOneWidget);
    // Encouragement appended
    expect(find.textContaining('Test Encouragement'), findsOneWidget);
  });

  testWidgets('Pomodoro mode does not append encouragement', (tester) async {
    final data = '{"NAM.1.1": "Test Encouragement"}';
    final svc = EncouragementService(
        bundle: _FakeBundle({
      'assets/scripture_mapping/cc-from-nam.json': data,
    }));
    final container = ProviderContainer(overrides: [
      encouragementServiceProvider.overrideWithValue(svc),
    ]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: PomodoroTimerScreen()),
      ),
    );
    await tester.pump();

    container.read(timerProvider.notifier).setForTest(mode: TimerMode.pomodoro);
    container.read(shownScriptureProvider.notifier).state = Passage(
      reference: 'NAM.1.1',
      text: 'Verse text',
      verses: [
        {'id': 'NAM.1.1'},
      ],
    );
    container.read(alarmBannerVisibleProvider.notifier).state = true;

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('alarm_banner')), findsOneWidget);
    expect(find.textContaining('Test Encouragement'), findsNothing);
  });
}
