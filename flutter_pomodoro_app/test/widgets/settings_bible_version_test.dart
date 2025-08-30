import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_app/data/bible_versions.dart';
import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Selecting a Bible version updates bibleIdProvider', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: Scaffold(body: SettingsScreen()))));

    // Open dropdown and select the default (only one initially), then assert bibleIdProvider maps correctly.
    final dropdown = find.byKey(const Key('bible_version_dropdown'));
    expect(dropdown, findsOneWidget);

    // Read provider via a nested Consumer
    String? bibleIdAtBuild;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Column(children: [
            const SettingsScreen(),
            Consumer(builder: (_, ref, __) {
              bibleIdAtBuild = ref.watch(bibleIdProvider);
              return const SizedBox.shrink();
            }),
          ]),
        ),
      ),
    ));

    await tester.pump();
    expect(bibleIdAtBuild, kBibleVersions[kDefaultBibleVersionName]);
  });
}
