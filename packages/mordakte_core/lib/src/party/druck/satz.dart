import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

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
  DruckKontext(this.kanon, this.texte, this.satz, this.stil);

  final Kanon kanon;
  final Texte texte;
  final DruckSatz satz;
  final DruckStil stil;

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

/// Die acht Teile des Druckspiels in fester Reihenfolge: Dateiname, Baustein
/// des Titels, Setzfunktion.
List<(String, String, void Function(pw.Document, DruckKontext))> get _teile => [
      ('00-erzaehlerheft.pdf', 'ui.druck.datei.spielleitung', erzaehlerheft),
      ('01-detektivbogen.pdf', 'ui.druck.datei.detektivbogen', detektivbogen),
      ('10-rollenhefte.pdf', 'ui.druck.datei.rollenhefte', rollenhefte),
      ('11-fassungen.pdf', 'ui.druck.datei.fassungen', fassungen),
      ('12-stimmkarten.pdf', 'ui.druck.datei.stimmkarten', stimmkarten),
      ('20-indizkarten.pdf', 'ui.druck.datei.indizkarten', indizkarten),
      ('21-umschlaege.pdf', 'ui.druck.datei.umschlaege', umschlaege),
      ('90-aufloesung-versiegelt.pdf', 'ui.druck.datei.aufloesung', aufloesungsheft),
    ];

/// Setzt alle Teile des Druckspiels, je Teil eine Datei.
Future<List<DruckDatei>> druckDateien(DruckKontext k) async => [
      for (final (name, titel, teil) in _teile) await druckTeil(k, name, k.ui(titel), teil),
    ];

/// Ein Teil als eigene Datei mit dem Titel „Falltitel · [titel]“.
Future<DruckDatei> druckTeil(DruckKontext k, String name, String titel, void Function(pw.Document, DruckKontext) teil, {String? figur}) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · $titel');
  teil(doc, k);
  return DruckDatei(name, await doc.save(), figur: figur);
}

/// Alle acht Teile in einem PDF, in der Reihenfolge von [druckDateien]: ein
/// Download, ein Druckauftrag. Die Seitenzahlen laufen durch.
Future<DruckDatei> druckAlles(DruckKontext k) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.datei.alles')}');
  for (final (_, _, teil) in _teile) {
    teil(doc, k);
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
