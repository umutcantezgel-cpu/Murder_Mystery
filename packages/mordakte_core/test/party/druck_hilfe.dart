// Testhilfe für den Drucksatz (F5): Kontext aus Repo-Dateien, PDF-Prüfung
// über pdfinfo und pdftotext (poppler-utils). Für Einstimmung und Erzählerakte
// (A-063) nehmen die Tests die echten Inhalte, sobald es sie gibt, sonst die
// Fixtures aus einstimmung_hilfe.dart.
import 'dart:io';
import 'dart:typed_data';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/src/party/druck/modell.dart';
import 'package:mordakte_core/src/party/druck/satz.dart';
import 'package:mordakte_core/src/party/druck/satz_stil.dart';

import 'einstimmung_hilfe.dart';
import 'kanon_hilfe.dart';

Texte? _texte;
DruckStil? _stil;

Texte get druckTexte => _texte ??= Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));

DruckStil get druckStil => _stil ??= DruckStil(
      regular: File('$repoWurzel/assets/fonts/Inter-Regular.ttf').readAsBytesSync(),
      fett: File('$repoWurzel/assets/fonts/Inter-Bold.ttf').readAsBytesSync(),
      schreibmaschine: File('$repoWurzel/assets/fonts/SpecialElite-Regular.ttf').readAsBytesSync(),
    );

/// Kontext für Pfad [pfad], [n] Personen und Detektiv [detektiv]; mit [diashow]
/// tragen die Intro-Bausteine im Erzählerheft deren Bildnummern (M4).
DruckKontext druckKontext({String pfad = 'ahmet', int n = 12, String detektiv = 'w', int? dauer, Diashow? diashow}) => DruckKontext(
    kanon, druckTexte, DruckSatz.aus(kanon, druckTexte, FallCode.fuerPfad(pfad, kanon.pfade), rollen: n, detektiv: detektiv, rundendauerMinuten: dauer), druckStil,
    diashow: diashow);

/// Nennt der echte Kanon schon eine Vorgeschichte (`setting.vorgeschichte`)?
bool get echteEinstimmung => Einstimmung.aus(kanon) != null;

Texte? _texteEinstimmung;
Kanon? _ohneEinstimmung;

/// Kanon mit Einstimmung: der echte, sobald er eine hat, sonst die Fixture.
Kanon get druckKanonEinstimmung => echteEinstimmung ? kanon : einstimmungKanon;

/// Texte zu [druckKanonEinstimmung]: die echten oder die Fixture-Texte der Einstimmung.
Texte get druckTexteEinstimmung => _texteEinstimmung ??= echteEinstimmung ? druckTexte : einstimmungTexteMit();

/// Kanon ohne Einstimmung: `setting.json` ohne Vorgeschichte und Vorstellung.
Kanon get kanonOhneEinstimmung => _ohneEinstimmung ??= kanonMit(
      setting: {...leseJson('$repoWurzel/content/party/schlosskeller/setting.json')}
        ..remove('vorgeschichte')
        ..remove('vorstellung'),
    );

/// Druckkontext für einen beliebigen Kanon [k] mit Texten [t].
DruckKontext druckKontextMit(Kanon k, Texte t, {String pfad = 'ahmet', int n = 12, String detektiv = 'w', Diashow? diashow}) =>
    DruckKontext(k, t, DruckSatz.aus(k, t, FallCode.fuerPfad(pfad, k.pfade), rollen: n, detektiv: detektiv), druckStil, diashow: diashow);

/// Inhalt der Erzählerakte: `erzaehlerakte.json`, sobald es sie gibt, sonst die Fixture.
Map<String, Object?> erzaehlerakteDaten() {
  final datei = File('$repoWurzel/content/party/schlosskeller/erzaehlerakte.json');
  return datei.existsSync() ? leseJson(datei.path) : erzaehlerakteFixture();
}

/// Seitenzahl, Format und Text einer PDF-Datei.
typedef PdfBefund = ({int seiten, bool a4, String text, List<String> seitenText});

PdfBefund pdfPruefen(Uint8List bytes) {
  final dir = Directory.systemTemp.createTempSync('druck_test');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final info = Process.runSync('pdfinfo', [f.path]).stdout as String;
    final seiten = int.parse(RegExp(r'Pages:\s+(\d+)').firstMatch(info)!.group(1)!);
    final a4 = RegExp(r'Page size:\s+595\.\d+ x 841\.\d+').hasMatch(info);
    final text = Process.runSync('pdftotext', ['-layout', f.path, '-']).stdout as String;
    return (seiten: seiten, a4: a4, text: text, seitenText: text.split('\f').where((s) => s.trim().isNotEmpty || true).toList());
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Text ohne Zeilenumbrüche und doppelte Leerzeichen (pdftotext bricht um).
String flach(String s) => s.replaceAll(RegExp(r'\s+'), ' ').replaceAll('- ', '').trim();
