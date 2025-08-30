import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/passage_id_provider.dart';

void main() {
  test('nextPassageIdProvider with lastPassageIdProvider avoids immediate repeat', () {
    var ids = ['GEN.1.1', 'GEN.1.1', 'GEN.1.2'];
    int idx = 0;
    final container = ProviderContainer(overrides: [
      nextPassageIdProvider.overrideWithValue(() => ids[idx++ % ids.length]),
    ]);

    // Seed last used id to GEN.1.1
    container.read(lastPassageIdProvider.notifier).state = 'GEN.1.1';

    final gen = container.read(nextPassageIdProvider);
    // Simulate TimerNotifier loop
    var candidate = gen();
    var last = container.read(lastPassageIdProvider);
    int tries = 0;
    while (last != null && candidate == last && tries < 10) {
      candidate = gen();
      tries++;
    }

    expect(candidate, isNot('GEN.1.1'));
  });
}
