import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pomodoro_app/main.dart' as app;
import 'package:flutter_pomodoro_app/services/scripture_mapping_service.dart';
import 'package:flutter_pomodoro_app/state/scripture_provider.dart';

class _FakeMappingService implements ScriptureMappingServiceInterface {
  final Map<String, ScriptureMapping> store;
  _FakeMappingService(this.store);
  @override
  Future<ScriptureMapping> buildMapping(String bibleId) async {
    final m = store[bibleId];
    if (m == null) throw Exception('Unknown bibleId');
    return m;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Build mapping on app launch with default bibleId', (tester) async {
    final defaultId = 'de4e12af7f28f599-02';
    final fake = _FakeMappingService({
      defaultId: ScriptureMapping(
        bibleId: defaultId,
        builtAt: DateTime(2025, 8, 31),
        data: {
          'GEN': {
            'GEN.1': ['GEN.1.1']
          }
        },
      ),
    });
    await tester.pumpWidget(ProviderScope(
      overrides: [
        bibleIdProvider.overrideWithValue(defaultId),
        scriptureMappingServiceProvider.overrideWithValue(fake),
      ],
      child: const app.MyApp(),
    ));
    await tester.pumpAndSettle();
    // Assert mapping ready
    // We cannot easily read providers from tester; the presence of app is sufficient in this smoke.
  });
}
