import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isAppForegroundProvider = StateProvider<bool>((_) => true);

class LifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;
  LifecycleObserver(this.ref);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(isAppForegroundProvider.notifier).state = state == AppLifecycleState.resumed;
  }
}
