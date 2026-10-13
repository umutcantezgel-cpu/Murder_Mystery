// Backt alle Klänge als WAV nach assets/klang/ (Repo-Wurzel).
// Aufruf (Repo-Wurzel): dart run packages/mordakte_klang/bin/backen.dart
import 'dart:io';

import 'package:mordakte_klang/mordakte_klang.dart';

void main() {
  var wurzel = Directory.current;
  while (!File('${wurzel.path}/pubspec.yaml').existsSync() || !Directory('${wurzel.path}/content').existsSync()) {
    final oben = wurzel.parent;
    if (oben.path == wurzel.path) {
      stderr.writeln('Repo-Wurzel nicht gefunden.');
      exit(2);
    }
    wurzel = oben;
  }
  final ziel = Directory('${wurzel.path}/assets/klang')..createSync(recursive: true);
  var summe = 0;
  for (final e in {...klangKatalog, ...atmosphaerenKatalog}.entries) {
    final bytes = wavMono16(e.value(), klangRate);
    File('${ziel.path}/${e.key}.wav').writeAsBytesSync(bytes);
    summe += bytes.length;
    stdout.writeln('${e.key}.wav  ${(bytes.length / 1024).toStringAsFixed(1)} KB');
  }
  stdout.writeln('Gesamt ${(summe / 1024).toStringAsFixed(0)} KB');
}
