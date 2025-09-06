import 'package:flutter/foundation.dart';

/// Simple singleton-style dispatcher to broadcast notification tap payloads
/// to the app layer without coupling the plugin adapter to Riverpod directly.
class DeepLinkDispatcher {
  DeepLinkDispatcher._();

  static void Function(Map<String, dynamic> payload)? _onNotificationTap;

  /// Register a callback to be invoked when a notification is tapped.
  static set onNotificationTap(void Function(Map<String, dynamic>)? handler) {
    _onNotificationTap = handler;
  }

  /// Invoked by platform notification adapters with the decoded JSON payload.
  static void notify(Map<String, dynamic> payload) {
    try {
      final handler = _onNotificationTap;
      if (handler != null) handler(payload);
    } catch (e) {
      if (kDebugMode) debugPrint('DeepLinkDispatcher: handler error: $e');
    }
  }
}
