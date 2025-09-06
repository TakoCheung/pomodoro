import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/services/notification_service.dart';
import 'package:flutter_pomodoro_app/state/deeplink_handler.dart';

void main() {
  test('Notification payload includes deep-link action', () {
    final res = NotificationContentBuilder.build(
      bibleId: 'B',
      passageId: 'P',
      passage: _P('R', 'T'),
      maxLen: 10,
    );
    expect(res.payload['action'], 'open_timer');
    final fb = NotificationContentBuilder.fallback();
    expect(fb.payload['action'], 'open_timer');
  });

  test('DeepLinkDispatcher forwards payload to handler', () async {
    Map<String, dynamic>? got;
    DeepLinkDispatcher.onNotificationTap = (p) => got = p;
    DeepLinkDispatcher.notify({'action': 'open_timer'});
    expect(got, isNotNull);
    expect(got!['action'], 'open_timer');
    DeepLinkDispatcher.onNotificationTap = null;
  });
}

class _P {
  final String reference;
  final String text;
  _P(this.reference, this.text);
}
