import 'dart:io';

void main(List<String> args) {
  final input = args.isNotEmpty ? args[0] : 'coverage/lcov.info';
  final out = args.length > 1 ? args[1] : 'coverage/coverage.csv';
  final file = File(input);
  if (!file.existsSync()) {
    stderr.writeln('Input lcov file not found: $input');
    exit(2);
  }

  final lines = file.readAsLinesSync();
  final buffer = StringBuffer();
  buffer.writeln('file,lines_found,lines_hit,percent');
  String? current;
  int lf = 0, lh = 0;
  for (var line in lines) {
    if (line.startsWith('SF:')) {
      current = line.substring(3);
      lf = 0;
      lh = 0;
    } else if (line.startsWith('LF:')) {
      lf = int.tryParse(line.substring(3)) ?? 0;
    } else if (line.startsWith('LH:')) {
      lh = int.tryParse(line.substring(3)) ?? 0;
    } else if (line.trim() == 'end_of_record') {
      if (current != null) {
        final pct = lf == 0 ? 100.0 : (lh / lf) * 100.0;
        buffer.writeln('$current,$lf,$lh,${pct.toStringAsFixed(1)}');
      }
      current = null;
      lf = 0;
      lh = 0;
    }
  }

  File(out).writeAsStringSync(buffer.toString());
  print('Wrote coverage CSV to $out');
}
