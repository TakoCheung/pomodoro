import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/services/alarm_service.dart';
import 'package:flutter_pomodoro_app/services/haptics_service.dart';

final alarmServiceProvider = Provider<AlarmService>((_) => NoopAlarmService());
final hapticsServiceProvider = Provider<HapticsService>((_) => NoopHapticsService());

/// Whether the device supports haptics. Override in tests to simulate no-support devices.
final hapticsSupportedProvider = Provider<bool>((_) => true);
