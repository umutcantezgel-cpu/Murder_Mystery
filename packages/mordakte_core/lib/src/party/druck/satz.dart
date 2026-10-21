import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../diashow.dart';
import '../kanon/kanon.dart';
import '../texte.dart';
import 'aufloesung.dart';
import 'karten.dart';
import 'modell.dart';
import 'rollen.dart';
import 'satz_stil.dart';
import 'spielleitung.dart';

/// Alles, was ein Druckteil zum Setzen braucht (F5). Texte kommen nur über
/// [text] und [ui] (Bausteine `ui.druck.*` in `texte/ui-druck-*.json`) oder aus
/// den Daten des [satz]; kein Druckteil erzeugt Text (F-11).
class DruckKontext {
  DruckKontext(this.kanon, this.texte, this.satz, this.stil, {this.diashow});

  final Kanon kanon;
  final Texte texte;
  final DruckSatz satz;
  final DruckStil stil;

  /// Diashow zur Einleitung (`content/welt/<akte>/diashow.json`, M4): Ihre
  /// Bildnummern stehen im Erzählerheft als Stichwort. Ohne: ein Dia je Baustein.
  final Diashow? diashow;

  String get fallTitel => kanon.fall['titel'] as String;

  String text(String kennung) => texte.baustein(kennung);

  String ui(String kennung, [Map<String, String> werte = const {}]) {
    var t = texte.baustein(kennung);
    for (final e in werte.entries) {
      t = t.replaceAll('{${e.key}}', e.value);
    }
    return t;
  }

  String figurName(String id) => kanon.figur(id)!['name'] as String;
  String figurTitel(String id) => (kanon.figur(id)!['roleTitle'] ?? '') as String;
}

/// Eine fertige PDF-Datei. Die Dateien des Druckspiels ([druckDateien],
/// [druckAlles]) tragen nur eine Nummer und den Teil, nie einen Pfad oder eine
/// Person. Steckbriefe und Rollenhefte je Person dürfen den Figurennamen tragen
/// (A-059): Jede Figur hat in jedem Pfad dasselbe Heft, der Name verrät nichts.
class DruckDatei {
  final String name;
  final Uint8List bytes;

  /// Figur, für die die Datei ist (Steckbrief, Rollenheft je Person); sonst null.
  final String? figur;
  const DruckDatei(this.name, this.bytes, {this.figur});
}

/// Ein Teil des Druckspiels: Dateiname, Baustein des Titels (`ui.druck.datei.*`)
/// und Setzfunktion.
typedef DruckTeil = ({String datei, String titel, void Function(pw.Document, DruckKontext) setzen});

/// Die acht Teile des Druckspiels in fester Reihenfolge.
final List<DruckTeil> druckTeile = List.unmodifiable(<DruckTeil>[
  (datei: '00-erzaehlerheft.pdf', titel: 'ui.druck.datei.spielleitung', setzen: erzaehlerheft),
  (datei: '01-detektivbogen.pdf', titel: 'ui.druck.datei.detektivbogen', setzen: detektivbogen),
  (datei: '10-rollenhefte.pdf', titel: 'ui.druck.datei.rollenhefte', setzen: rollenhefte),
  (datei: '11-fassungen.pdf', titel: 'ui.druck.datei.fassungen', setzen: fassungen),
  (datei: '12-stimmkarten.pdf', titel: 'ui.druck.datei.stimmkarten', setzen: stimmkarten),
  (datei: '20-indizkarten.pdf', titel: 'ui.druck.datei.indizkarten', setzen: indizkarten),
  (datei: '21-umschlaege.pdf', titel: 'ui.druck.datei.umschlaege', setzen: umschlaege),
  (datei: '90-aufloesung-versiegelt.pdf', titel: 'ui.druck.datei.aufloesung', setzen: aufloesungsheft),
]);

/// Setzt alle Teile des Druckspiels, je Teil eine Datei.
Future<List<DruckDatei>> druckDateien(DruckKontext k) async => [
      for (final t in druckTeile) await teilDatei(k, t),
    ];

/// Ein Teil des Druckspiels als eigene Datei (erst beim Tipp, M5).
Future<DruckDatei> teilDatei(DruckKontext k, DruckTeil t) => setzeDatei(k, t.datei, k.ui(t.titel), t.setzen);

/// Setzt [setzen] als eigene Datei [name] mit dem Titel „Falltitel · [titel]“.
Future<DruckDatei> setzeDatei(DruckKontext k, String name, String titel, void Function(pw.Document, DruckKontext) setzen, {String? figur}) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · $titel');
  setzen(doc, k);
  return DruckDatei(name, await doc.save(), figur: figur);
}

/// Das Erzählerheft als Datei; ohne [druckspiel] für einen Abend am Bildschirm
/// (nur Vorlesen und der Tisch, A-052), aus jeder Rollenvergabe reihum erhältlich.
Future<DruckDatei> erzaehlerheftDatei(DruckKontext k, {bool druckspiel = true}) => setzeDatei(
      k,
      druckTeile.first.datei,
      k.ui(druckTeile.first.titel),
      (doc, k) => erzaehlerheft(doc, k, druckspiel: druckspiel),
    );

/// Alle acht Teile in einem PDF, in der Reihenfolge von [druckDateien]: ein
/// Download, ein Druckauftrag. Die Seitenzahlen laufen durch.
Future<DruckDatei> druckAlles(DruckKontext k) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.datei.alles')}');
  for (final t in druckTeile) {
    t.setzen(doc, k);
  }
  return DruckDatei('druckspiel-alles.pdf', await doc.save());
}

/// Ein Wort für Dateinamen: klein, ohne Umlaute, nur Buchstaben, Ziffern und Bindestriche.
String dateiWort(String text) {
  final t = text
      .toLowerCase()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return t.replaceAll(RegExp(r'^-+|-+$'), '');
}
