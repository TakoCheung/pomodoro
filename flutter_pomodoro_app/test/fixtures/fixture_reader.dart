import 'dart:io';
import 'package:path/path.dart' as p;

Future<String> fixtureReader(String name) async {
  // Use the package root (Directory.current) so tests can locate fixtures reliably.
  final root = Directory.current.path;
  final fixturePath = p.normalize(p.join(root, 'test', 'fixtures', name));
  return File(fixturePath).readAsString();
}
