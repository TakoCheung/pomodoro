import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/services/alarm_scheduler.dart';

// Default is Noop for tests; main.dart overrides to a real scheduler at app startup.
final alarmSchedulerProvider = Provider<AlarmScheduler>((_) => NoopAlarmScheduler());
