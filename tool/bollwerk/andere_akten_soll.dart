// FINALE · Schnappschuss T-N der fünf Akten vor der Einfluss-Schicht (SPEZIFIKATION §0.1, §4): einmal
// vor jeder Codeänderung erzeugt, Vergleichsstand für einfluss_gating_test, nie neu schreiben, um ein
// Tor grün zu machen. Schreibt nur, wenn die Datei fehlt.
// Aufruf (im Wurzelordner): dart run tool/bollwerk/andere_akten_soll.dart --schreibe
import 'dart:io';

import '../../packages/mordakte_core/test/runden/andere_akten_lauf.dart';

void main(List<String> args) {
  if (!args.contains('--schreibe')) {
    stdout.writeln('Aufruf: dart run tool/bollwerk/andere_akten_soll.dart --schreibe');
    exit(2);
  }
  final bw = File(Platform.script.toFilePath()).parent.parent.parent.path;
  final f = File('$bw/packages/mordakte_core/test/runden/andere_akten_soll.g.dart');
  if (f.existsSync()) {
    stdout.writeln('Schnappschuss existiert schon – Vergleichsstände werden nie neu geschrieben.');
    exit(1);
  }
  final summen = andereAktenSummen();
  final aus = StringBuffer()
    ..writeln('// GENERIERT von tool/bollwerk/andere_akten_soll.dart (VM) – Schnappschuss T-N der fünf Akten vor der')
    ..writeln('// Einfluss-Schicht (Finale §0.1, §4), Serialisierung in andere_akten_lauf.dart. Nie neu schreiben.')
    ..writeln('const Map<String, String> andereAktenSoll = {');
  for (final k in summen.keys.toList()..sort()) {
    aus.writeln("  '$k': '${summen[k]}',");
  }
  aus.writeln('};');
  f.writeAsStringSync(aus.toString());
  stdout.writeln('geschrieben: ${summen.length} Summen');
}
