class NotificationBuildResult {
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  NotificationBuildResult({required this.title, required this.body, required this.payload});
}

class NotificationContentBuilder {
  static NotificationBuildResult build({
    required String bibleId,
    required String passageId,
    required dynamic passage, // expects Passage-like with reference,text
    int maxLen = 140,
  }) {
    final ref = passage.reference as String;
    final text = passage.text as String;
    final body = _truncate(text, maxLen);
    final payload = <String, dynamic>{
      'bibleId': bibleId,
      'passageId': passageId,
      'reference': ref,
      'textSnippet': body,
    };
    return NotificationBuildResult(title: ref, body: body, payload: payload);
  }

  static NotificationBuildResult fallback() {
    return NotificationBuildResult(
      title: 'Session complete',
      body: 'Great job! Open to view your verse.',
      payload: const <String, dynamic>{},
    );
  }

  static String _truncate(String input, int maxLen) {
    if (input.length <= maxLen) return input;
    // Reserve one char for ellipsis when truncating.
    final cut = (maxLen - 1).clamp(0, input.length);
    return input.substring(0, cut) + '…';
  }
}

abstract class NotificationScheduler {
  Future<void> ensureInitialized();
  Future<bool> requestPermission({bool provisional = false});
  Future<void> show(
      {required String channelId,
      required String title,
      required String body,
      required Map<String, dynamic> payload});
  Future<void> createAndroidChannel(
      {required String id, required String name, required String description, int importance = 4});
}

class NoopNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> createAndroidChannel(
      {required String id,
      required String name,
      required String description,
      int importance = 4}) async {}

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<bool> requestPermission({bool provisional = false}) async => true;

  @override
  Future<void> show(
      {required String channelId,
      required String title,
      required String body,
      required Map<String, dynamic> payload}) async {}
}
