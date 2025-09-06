import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/services/alarm_scheduler.dart';

final alarmSchedulerProvider = Provider<AlarmScheduler>((_) => NoopAlarmScheduler());
