import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/state/alarm_haptics_providers.dart';

final alarmBannerVisibleProvider = StateProvider<bool>((_) => false);

/// When a system notification is posted while the app is backgrounded,
/// set this to true so that the next resume shows the in-app banner even if
/// the platform does not deliver a tap callback reliably.
final bannerPendingOnNextResumeProvider = StateProvider<bool>((_) => false);

void dismissAlarmBanner(WidgetRef ref) {
  ref.read(alarmBannerVisibleProvider.notifier).state = false;
  // Stop alarm sound if any
  ref.read(alarmServiceProvider).stop();
}
