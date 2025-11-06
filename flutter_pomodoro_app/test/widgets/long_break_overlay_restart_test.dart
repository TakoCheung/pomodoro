import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pomodoro_app/screens/pomodoro_timer_screen.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';
import 'package:flutter_pomodoro_app/models/passage.dart';
import 'package:flutter_pomodoro_app/state/encouragement_provider.dart';
import 'package:flutter_pomodoro_app/services/encouragement_service.dart';

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
  testWidgets('Long break RESTART shows overlay with encouragement text', (tester) async {
    final data = '{"NAM.1.1": "Overlay Encouragement"}';
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

    // Prepare long break mode and a current passage with a resolvable verse id
    container.read(timerProvider.notifier).setForTest(mode: TimerMode.longBreak);
    container.read(shownScriptureProvider.notifier).state = Passage(
      reference: 'NAM.1.1',
      text: 'Verse text',
      verses: [
        {'id': 'NAM.1.1'},
      ],
    );

    // Tap RESTART
    await tester.tap(find.byKey(const Key('pauseRestart')));
    await tester.pumpAndSettle();

    // Overlay should be visible and include encouragement
    expect(find.byKey(const Key('scripture_encouragement')), findsOneWidget);
    expect(find.textContaining('Overlay Encouragement'), findsOneWidget);

    // Timer should have started on long break restart per new behavior
    expect(container.read(timerProvider).isRunning, isTrue);

    // Dispose container to cancel timers and avoid pending timers in test teardown
    container.dispose();
  });
}
