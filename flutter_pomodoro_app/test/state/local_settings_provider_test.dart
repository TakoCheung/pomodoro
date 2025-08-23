import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/state/local_settings_provider.dart';
import 'package:flutter_pomodoro_app/state/pomodoro_provider.dart';

void main(){
  group('LocalSettingsNotifier', (){
    test('copyWith and updates work', (){
      final ls = LocalSettings(initPomodoro: 1500, initShortBreak: 300, initLongBreak: 900, fontFamily: 'A', color: Colors.red);
      final notifier = LocalSettingsNotifier(ls);

      notifier.updateFont('B');
      expect(notifier.state.fontFamily, 'B');

      notifier.updateColor(Colors.blue);
      expect(notifier.state.color, Colors.blue);

      notifier.updateTime(TimerMode.pomodoro, 10);
      expect(notifier.state.initPomodoro, 10 * 60);

      notifier.updateTime(TimerMode.shortBreak, 2);
      expect(notifier.state.initShortBreak, 2 * 60);

      notifier.updateTime(TimerMode.longBreak, 5);
      expect(notifier.state.initLongBreak, 5 * 60);
    });

    test('getName returns expected strings', (){
      final ls = LocalSettings(initPomodoro: 1500, initShortBreak: 300, initLongBreak: 900, fontFamily: 'A', color: Colors.red);
      final notifier = LocalSettingsNotifier(ls);

      expect(notifier.getName(TimerMode.pomodoro), 'Pomodoro');
      expect(notifier.getName(TimerMode.shortBreak), 'Short Break');
      expect(notifier.getName(TimerMode.longBreak), 'Long Break');
    });
  });
}
