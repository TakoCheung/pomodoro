import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pomodoro_app/state/settings_controller.dart';

class _FakeRepo implements SettingsRepository {
  AppSettings committed;
  int persistCount = 0;
  _FakeRepo(this.committed);

  @override
  AppSettings getCommitted() => committed;

  @override
  Future<void> persistCommitted(AppSettings next) async {
    committed = next;
    persistCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsController', () {
    late _FakeRepo repo;
    late ProviderContainer container;

    setUp(() {
      repo = _FakeRepo(const AppSettings(
        initPomodoro: 25 * 60,
        initShortBreak: 5 * 60,
        initLongBreak: 15 * 60,
        fontFamily: 'KumbhSans',
        color: Color(0xFFFF3B30),
        debugMode: false,
        notificationsEnabled: true,
        soundEnabled: true,
        hapticsEnabled: true,
        soundId: 'classic_bell',
        bibleVersionName: 'KJV',
        bibleVersionId: '32664dc3288a28df-01',
      ));
      container = ProviderContainer(overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);
    });

    test('Opening stages from committed: staged==committed, isDirty=false', () {
      final ctl = container.read(settingsControllerProvider.notifier);
      ctl.stageFromCommitted();
      final s = container.read(settingsControllerProvider);
      expect(s.staged, equals(s.committed));
      expect(s.isDirty, isFalse);
    });

    test('Toggling updates staged only; isDirty==true', () {
      final ctl = container.read(settingsControllerProvider.notifier);
      ctl.stageFromCommitted();
      ctl.updateStaged(soundEnabled: false);
      final s = container.read(settingsControllerProvider);
      expect(s.committed.soundEnabled, isTrue);
      expect(s.staged.soundEnabled, isFalse);
      expect(s.isDirty, isTrue);
    });

    test('Apply writes staged to committed via repository and resets dirty', () async {
      final ctl = container.read(settingsControllerProvider.notifier);
      ctl.stageFromCommitted();
      ctl.updateStaged(hapticsEnabled: false, notificationsEnabled: false, soundId: 'beep');
      await ctl.apply();
      final s = container.read(settingsControllerProvider);
      expect(repo.persistCount, 1);
      expect(s.isDirty, isFalse);
      expect(s.committed.hapticsEnabled, isFalse);
      expect(s.committed.notificationsEnabled, isFalse);
      expect(s.committed.soundId, 'beep');
    });

    test('Revert reloads latest committed snapshot', () async {
      final ctl = container.read(settingsControllerProvider.notifier);
      ctl.stageFromCommitted();
      // External commit happens elsewhere
      repo.committed = const AppSettings(
        initPomodoro: 25 * 60,
        initShortBreak: 5 * 60,
        initLongBreak: 15 * 60,
        fontFamily: 'KumbhSans',
        color: Color(0xFFFF3B30),
        debugMode: false,
        notificationsEnabled: false,
        soundEnabled: false,
        hapticsEnabled: true,
        soundId: 'gentle_chime',
        bibleVersionName: 'KJV',
        bibleVersionId: '32664dc3288a28df-01',
      );
      // Staged changed locally but we revert
      ctl.updateStaged(soundEnabled: true);
      ctl.revert();
      final s = container.read(settingsControllerProvider);
      expect(s.isDirty, isFalse);
      expect(s.committed, equals(repo.committed));
      expect(s.staged, equals(repo.committed));
    });

    test('No writes until apply()', () async {
      final ctl = container.read(settingsControllerProvider.notifier);
      ctl.stageFromCommitted();
      ctl.updateStaged(notificationsEnabled: false);
      expect(repo.persistCount, 0);
      ctl.revert();
      expect(repo.persistCount, 0);
      await ctl.apply();
      expect(repo.persistCount, 1);
    });
  });
}
