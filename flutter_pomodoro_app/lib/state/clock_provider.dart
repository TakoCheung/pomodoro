import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple time source abstraction for testability.
typedef NowFn = DateTime Function();

final clockProvider = Provider<NowFn>((_) => () => DateTime.now().toUtc());
