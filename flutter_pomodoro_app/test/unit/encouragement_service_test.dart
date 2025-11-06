import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pomodoro_app/services/encouragement_service.dart';

class _FakeBundle extends CachingAssetBundle {
  final Map<String, String> files;
  _FakeBundle(this.files);
  @override
  Future<ByteData> load(String key) async {
    final str = files[key];
    if (str == null) throw StateError('not found');
    final list = Uint8List.fromList(str.codeUnits);
    return ByteData.view(list.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final str = files[key];
    if (str == null) throw StateError('not found');
    return str;
  }
}

void main() {
  test('EncouragementService returns content for known id', () async {
    final data = '{"NAM.1.1": "Hello Context"}';
    final bundle = _FakeBundle({'assets/scripture_mapping/cc-from-nam.json': data});
    final svc = EncouragementService(bundle: bundle);
    expect(await svc.forVerseId('NAM.1.1'), 'Hello Context');
    expect(await svc.forVerseId('NAM.1.2'), isNull);
  });
}
