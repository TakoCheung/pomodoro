import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/alarm_haptics_providers.dart';

final alarmBannerVisibleProvider = StateProvider<bool>((_) => false);

void dismissAlarmBanner(WidgetRef ref) {
  ref.read(alarmBannerVisibleProvider.notifier).state = false;
  // Stop alarm sound if any
  ref.read(alarmServiceProvider).stop();
}
