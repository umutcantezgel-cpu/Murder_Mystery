/// Dateien des Kammerspiel-Drucks (ARCHITEKTUR A2, MECH 10.1, 10.3): die acht
/// Teile in fester Reihenfolge, alles in einer Datei, die Einzeldatei je
/// besetzter Rolle. Dateinamen und Titel kommen aus `ui/*.json`.
///
/// Gleiche Eingaben ergeben gleiche Bytes ([festeBytes]). Die Dateien tragen
/// nur Nummer und Teil; die Einzeldateien tragen den Rollennamen (A-059).
/// Teil 90 gibt es nie als Einzeldatei.
library;

import 'package:pdf/widgets.dart' as pw;

import '../satz.dart';
import '../satz_fest.dart';
import 'aufloesung.dart';
import 'detektivbogen.dart';
import 'erzaehlerheft.dart';
import 'fassungen.dart';
import 'inhalt.dart';
import 'karten.dart';
import 'kontext.dart';
import 'rollenhefte.dart';
import 'tisch.dart';

/// Setzt einen Teil in ein Dokument.
typedef KammerSetzer = void Function(pw.Document doc, KammerKontext k);

/// Ein Teil des Kammerspiels: Nummer (`00` … `90`), Dateiname und Titel aus
/// `ui/<nr>.json` (`datei`, `titel`), Setzfunktion.
class KammerTeil {
  const KammerTeil(this.nr, this.datei, this.titel, this.setzen);
  final String nr;
  final String datei;
  final String titel;
  final KammerSetzer setzen;

  @override
  String toString() => '$nr $datei';
}

/// Die Setzfunktion je Teil.
const Map<String, KammerSetzer> kammerSetzer = {
  '00': kammerErzaehlerheft,
  '01': kammerDetektivbogen,
  '02': kammerTisch,
  '10': kammerRollenhefte,
  '11': kammerFassungen,
  '12': kammerZusatzhefte,
  '20': kammerKarten,
  '90': kammerAufloesung,
};

/// Die acht Teile in fester Reihenfolge 00, 01, 02, 10, 11, 12, 20, 90
/// ([kammerTeile]).
List<KammerTeil> kammerDruckteile(KammerKontext k) => [for (final nr in kammerTeile) kammerTeil(k, nr)];

/// Teil [nr] (`00` … `90`); unbekannt: [ArgumentError].
KammerTeil kammerTeil(KammerKontext k, String nr) {
  final setzen = kammerSetzer[nr] ?? (throw ArgumentError.value(nr, 'nr', 'kein Teil des Kammerspiels'));
  return KammerTeil(nr, k.ui(nr, 'datei'), k.teilTitel(nr), setzen);
}

/// Setzt [setzen] in ein neues Dokument mit Titel [titel] und speichert es
/// reproduzierbar.
Future<DruckDatei> _datei(KammerKontext k, String name, String titel, void Function(pw.Document doc) setzen, {String? figur}) async {
  final doc = k.stil.neuesDokument(titel);
  setzen(doc);
  return DruckDatei(name, festeBytes(await doc.save()), figur: figur);
}

/// Teil [t] als eigene Datei.
Future<DruckDatei> kammerTeilDatei(KammerKontext k, KammerTeil t) => _datei(k, t.datei, k.kopfText(t.titel), (doc) => t.setzen(doc, k));

/// Die acht Teile, je eine Datei, in fester Reihenfolge.
Future<List<DruckDatei>> kammerTeilDateien(KammerKontext k) async => [
      for (final t in kammerDruckteile(k)) await kammerTeilDatei(k, t),
    ];

/// Alle acht Teile in einer Datei (`ui/gemeinsam.json` → `datei.alles`): ein
/// Download, ein Druckauftrag. Jeder Teil zählt seine Seiten selbst; die
/// Seitenzahl der Datei ist die Summe der Teile.
Future<DruckDatei> kammerAlles(KammerKontext k) => _datei(
      k,
      k.uiGemeinsam('datei.alles'),
      k.kopfText(k.uiGemeinsam('titel.alles')),
      (doc) {
        for (final t in kammerDruckteile(k)) {
          t.setzen(doc, k);
        }
      },
    );

/// Was eine besetzte Rolle vorab bekommt (MECH 10.3): ihr Rollenheft (Platz
/// 1–10, Teil 10) bzw. Zusatzheft (Platz 11–18, Teil 12) und eine Abbildung
/// ihrer Aktionskarte. Dateiname aus `ui/10.json` bzw. `ui/12.json` →
/// `dateiEinzeln` mit dem Rollennamen ([dateiWort]); [DruckDatei.figur] ist die
/// Rollen-ID. Nicht besetzt: [ArgumentError].
Future<DruckDatei> kammerEinzeldatei(KammerKontext k, KammerPlatz p) {
  if (!k.besetzung.istBesetzt(p.id)) throw ArgumentError.value(p.id, 'p', 'heute nicht besetzt');
  final teil = p.art == KammerArt.zusatz ? '12' : '10';
  return _datei(
    k,
    k.ui(teil, 'dateiEinzeln', {'figur': dateiWort(p.name)}),
    '${k.kopfText(k.teilTitel(teil))} · ${p.name}',
    (doc) {
      if (teil == '12') {
        kammerZusatzheft(doc, k, p);
      } else {
        kammerRollenheft(doc, k, p);
      }
      kammerAktionskarteSeite(doc, k, p);
    },
    figur: p.id,
  );
}

/// Die Einzeldateien aller besetzten Rollen in Platzreihenfolge.
Future<List<DruckDatei>> kammerEinzeldateien(KammerKontext k) async => [
      for (final p in k.besetzung.besetzt) await kammerEinzeldatei(k, p),
    ];

/// Alle Dateien für einen Ordner: die acht Teile und die Einzeldateien; mit
/// [alles] zuerst `kammerspiel-alles.pdf`. Ohne [teile] nur Alles und
/// Einzeldateien, ohne [einzeln] keine Einzeldateien.
Future<List<DruckDatei>> kammerDateien(KammerKontext k, {bool alles = false, bool teile = true, bool einzeln = true}) async => [
      if (alles) await kammerAlles(k),
      if (teile) ...await kammerTeilDateien(k),
      if (einzeln) ...await kammerEinzeldateien(k),
    ];
