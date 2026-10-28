// FINALE · Soll-Liste der Einfluss-Schicht (SPEZIFIKATION §4, Determinismus): 1.000 Codes, je Abend eine
// FNV-Summe (packages/mordakte_core/test/runden/einfluss_lauf.dart). Vergleichsstand für
// einfluss_determinismus_test, nie neu schreiben, um ein Tor grün zu machen; eine gewollte Änderung der Schicht
// bekommt eine eigene Datei. Schreibt nur, wenn die Datei fehlt.
// Aufruf (im Wurzelordner): dart run tool/bollwerk/einfluss_soll.dart --schreibe
import 'dart:io';

import '../../packages/mordakte_core/test/runden/einfluss_lauf.dart';

void main(List<String> args) {
  if (!args.contains('--schreibe')) {
    stdout.writeln('Aufruf: dart run tool/bollwerk/einfluss_soll.dart --schreibe');
    exit(2);
  }
  final bw = File(Platform.script.toFilePath()).parent.parent.parent.path;
  final f = File('$bw/packages/mordakte_core/test/runden/einfluss_soll.g.dart');
  if (f.existsSync()) {
    stdout.writeln('Soll-Liste existiert schon – Vergleichsstände werden nie neu geschrieben.');
    exit(1);
  }
  final l = einflussDeterminismusListe();
  final aus = StringBuffer()
    ..writeln('// GENERIERT von tool/bollwerk/einfluss_soll.dart (VM) – Vergleichsstand der Einfluss-Schicht (Finale §4),')
    ..writeln('// Serialisierung in einfluss_lauf.dart. Nie neu schreiben.')
    ..writeln('const List<int> einflussSoll = [');
  for (var i = 0; i < l.length; i += 8) {
    aus.writeln('  ${l.skip(i).take(8).join(', ')},');
  }
  aus.writeln('];');
  f.writeAsStringSync(aus.toString());
  stdout.writeln('geschrieben: ${l.length} Summen');
}
