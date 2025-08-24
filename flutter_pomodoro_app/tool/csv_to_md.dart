import 'dart:io';

void main(List<String> args) {
  final input = args.isNotEmpty ? args[0] : 'coverage/coverage.csv';
  final out = args.length > 1 ? args[1] : 'coverage/README.md';
  final file = File(input);
  if (!file.existsSync()) {
    stderr.writeln('Input CSV not found: $input');
    exit(2);
  }

  final lines = file.readAsLinesSync();
  if (lines.isEmpty) {
    stderr.writeln('CSV empty');
    exit(2);
  }

  final buffer = StringBuffer();
  buffer.writeln('# Coverage per file');
  buffer.writeln();
  buffer.writeln('| File | Lines Found | Lines Hit | Percent |');
  buffer.writeln('|---|---:|---:|---:|');

  for (var i = 1; i < lines.length; i++) {
    final cols = lines[i].split(',');
    if (cols.length < 4) continue;
    buffer.writeln('| ${cols[0]} | ${cols[1]} | ${cols[2]} | ${cols[3]}% |');
  }

  File(out).writeAsStringSync(buffer.toString());
  print('Wrote $out');
}
