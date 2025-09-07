import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isAppForegroundProvider = StateProvider<bool>((_) => true);

class LifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;
  final void Function(WidgetRef ref, AppLifecycleState state)? onChange;
  LifecycleObserver(this.ref, {this.onChange});
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(isAppForegroundProvider.notifier).state = state == AppLifecycleState.resumed;
    // Allow callers to react (e.g., resync timers on resume)
    onChange?.call(ref, state);
  }
}
