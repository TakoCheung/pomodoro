import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/main.dart' as app;

void main() {
  testWidgets('main() calls runApp without throwing', (WidgetTester tester) async {
    // Calling main should invoke runApp; pump to let the widget tree build.
    app.main();
    await tester.pump();

    // If runApp executed, the binding should have a root element; no exceptions thrown
    expect(tester.takeException(), isNull);
  });
}
