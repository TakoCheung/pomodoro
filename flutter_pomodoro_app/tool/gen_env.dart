// Small tool to generate lib/env_config.dart from a .env file at project root.
// Usage:
//   dart run tool/gen_env.dart

import 'dart:io';

void main() {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('.env not found; writing default env_config.dart with safe defaults');
  }
  final lines = envFile.existsSync() ? envFile.readAsLinesSync() : <String>[];
  final map = <String, String>{};
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final idx = line.indexOf('=');
    if (idx <= 0) continue;
    final key = line.substring(0, idx).trim();
    final val = line.substring(idx + 1).trim();
    map[key] = val;
  }

  final enableDebugFab = (map['ENABLE_DEBUG_FAB']?.toLowerCase() == 'true');
  final forceShow = (map['FORCE_SHOW_SCRIPTURE_ON_COMPLETE']?.toLowerCase() == 'true');

  final out = StringBuffer();
  out.writeln("// GENERATED - do not edit. Run `dart run tool/gen_env.dart` to regenerate.");
  out.writeln("class EnvConfig {");
  out.writeln("  static const bool enableDebugFab = $enableDebugFab;");
  out.writeln("  static const bool forceShowScriptureOnComplete = $forceShow;");
  out.writeln("}");

  final outFile = File('lib/env_config.dart');
  outFile.writeAsStringSync(out.toString());
  print('Wrote lib/env_config.dart');
}
