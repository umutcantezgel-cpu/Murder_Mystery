// Testhilfe für den Kammerspiel-Druck: Inhalt, Stil und Kontext aus dem Repo,
// PDF-Prüfung über pdfinfo und pdftotext (poppler-utils) wie ../druck_hilfe.dart,
// aber mit dem Format jeder einzelnen Seite (A4 hoch oder quer).
import 'dart:io';
import 'dart:typed_data';

import 'package:mordakte_core/kammer_io.dart';
import 'package:mordakte_core/src/party/druck/kammer/kontext.dart';
import 'package:mordakte_core/src/party/druck/satz_stil.dart';

import '../kanon_hilfe.dart';

KammerInhalt? _inhalt;
DruckStil? _stil;

/// Der echte Inhalt aus `content/kammerspiel/schlosskeller/`, einmal geladen.
KammerInhalt get kammerInhalt => _inhalt ??= ladeKammerInhalt(repoWurzel);

/// Der schlichte Druckstil mit den Schriften aus `assets/fonts`.
DruckStil get kammerStil => _stil ??= DruckStil(
      regular: File('$repoWurzel/assets/fonts/Inter-Regular.ttf').readAsBytesSync(),
      fett: File('$repoWurzel/assets/fonts/Inter-Bold.ttf').readAsBytesSync(),
      schreibmaschine: File('$repoWurzel/assets/fonts/SpecialElite-Regular.ttf').readAsBytesSync(),
    );

/// Kontext für [personen] (6 bis 20) und Detektiv [detektiv] (`w` oder `m`).
KammerKontext kammerKontext(int personen, {String detektiv = 'w'}) =>
    KammerKontext(kammerInhalt, personen: personen, stil: kammerStil, detektiv: detektiv);

/// Seitenzahl, Format je Seite (`hoch` oder `quer`; jede Seite muss A4 sein) und Text je Seite.
typedef KammerPdf = ({int seiten, List<String> formate, List<String> seitenText, String text});

/// Prüft eine PDF mit pdfinfo und pdftotext. Wirft [StateError], wenn eine Seite nicht A4 ist.
KammerPdf kammerPdf(Uint8List bytes) {
  final dir = Directory.systemTemp.createTempSync('kammer_pdf');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final info = Process.runSync('pdfinfo', ['-f', '1', '-l', '100000', f.path]).stdout as String;
    final text = Process.runSync('pdftotext', ['-layout', f.path, '-']).stdout as String;
    return _befund(info, text);
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Wie [kammerPdf], aber für viele Dateien nebeneinander (schneller).
Future<List<KammerPdf>> kammerPdfs(Iterable<Uint8List> dateien) => Future.wait([
      for (final bytes in dateien)
        () async {
          final dir = Directory.systemTemp.createTempSync('kammer_pdf');
          try {
            final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
            final r = await Future.wait([
              Process.run('pdfinfo', ['-f', '1', '-l', '100000', f.path]),
              Process.run('pdftotext', ['-layout', f.path, '-']),
            ]);
            return _befund(r[0].stdout as String, r[1].stdout as String);
          } finally {
            dir.deleteSync(recursive: true);
          }
        }(),
    ]);

KammerPdf _befund(String info, String text) {
  final seiten = int.parse(RegExp(r'Pages:\s+(\d+)').firstMatch(info)!.group(1)!);
  bool a4(double x) => (x - 595.28).abs() < 0.5 || (x - 841.89).abs() < 0.5;
  final formate = [
    for (final m in RegExp(r'Page\s+\d+ size:\s+([\d.]+) x ([\d.]+)').allMatches(info))
      () {
        final b = double.parse(m.group(1)!), h = double.parse(m.group(2)!);
        if (!a4(b) || !a4(h) || (b - h).abs() < 1) throw StateError('Seite nicht A4: ${m.group(0)}');
        return b < h ? 'hoch' : 'quer';
      }(),
  ];
  final seitenText = text.split('\f');
  if (seitenText.isNotEmpty && seitenText.last.trim().isEmpty) seitenText.removeLast();
  return (seiten: seiten, formate: formate, seitenText: seitenText, text: text);
}

/// Text ohne Zeilenumbrüche und doppelte Leerzeichen (pdftotext bricht um).
String kammerFlach(String s) => s.replaceAll(RegExp(r'\s+'), ' ').replaceAll('- ', '').trim();

/// Kleinster Abstand (pt) eines Wortes zur Papierkante über alle Seiten, mit Seite und Wort
/// (pdftotext -bbox). Ohne Text: null.
Future<({double abstand, int seite, String wort})?> kammerRandAbstand(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_rand');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final xml = (await Process.run('pdftotext', ['-bbox', f.path, '-'])).stdout as String;
    ({double abstand, int seite, String wort})? knappster;
    final seiten = xml.split('<page ').skip(1).toList();
    for (var i = 0; i < seiten.length; i++) {
      final p = seiten[i];
      final m = RegExp(r'width="([\d.]+)" height="([\d.]+)"').firstMatch(p)!;
      final b = double.parse(m.group(1)!), h = double.parse(m.group(2)!);
      for (final w in RegExp(r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">([^<]*)<').allMatches(p)) {
        final x0 = double.parse(w.group(1)!), y0 = double.parse(w.group(2)!);
        final x1 = double.parse(w.group(3)!), y1 = double.parse(w.group(4)!);
        final a = [x0, y0, b - x1, h - y1].reduce((p, q) => p < q ? p : q);
        if (knappster == null || a < knappster.abstand) knappster = (abstand: a, seite: i + 1, wort: w.group(5)!);
      }
    }
    return knappster;
  } finally {
    dir.deleteSync(recursive: true);
  }
}
