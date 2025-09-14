import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pomodoro_app/screens/setting_screen.dart';
import 'package:flutter_pomodoro_app/models/bible_version.dart';
import 'package:flutter_pomodoro_app/services/bible_catalog_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_repository.dart'
    show sharedPreferencesProvider;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'Bible version dropdown shows abbreviationLocal when available and header is uppercase',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final fakeList = [
      BibleVersion(
          id: 'id1',
          name: 'English Standard Version',
          abbreviation: 'ESV',
          language: 'English',
          abbreviationLocal: 'ESV-local'),
      BibleVersion(
          id: 'id2',
          name: 'Sample Version',
          abbreviation: 'SV',
          language: 'English',
          abbreviationLocal: ''),
    ];

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        bibleCatalogServiceProvider.overrideWithValue(_FakeCatalog(fakeList)),
      ],
      child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
    ));

    // Allow FutureProvider to resolve and UI to rebuild with fetched list
    await tester.pump();
    await tester.pumpAndSettle();

    // Header label should be uppercase like other section headers
    expect(find.text('BIBLE VERSION'), findsOneWidget);

    // Scroll into view and open dropdown, then verify abbreviations appear
    final dropdown = find.byKey(const Key('bible_version_dropdown'));
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    expect(find.text('ESV-local'), findsWidgets);
    // Depending on mapping, label may be 'SV' or full name; accept either.
    expect(
        find.text('SV').evaluate().isNotEmpty || find.text('Sample Version').evaluate().isNotEmpty,
        isTrue);
  });
}

class _FakeCatalog implements BibleCatalogServiceInterface {
  final List<BibleVersion> list;
  _FakeCatalog(this.list);
  @override
  Future<List<BibleVersion>> fetchBibles() async => list;
}
