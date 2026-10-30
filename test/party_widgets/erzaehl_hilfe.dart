// Testhilfe für Einstimmung und Erzählerakte (Finale Schlosskeller, A-063):
// der Schlosskeller wie in der App, mit Eintrag in akten.json (Zusätze samt
// einstimmung, erzaehlerakte, einfluss), Diashow, Vorspiel und Morgen,
// Steckbriefen, Erzählerakte und den Sternen der Einfluss-Schicht als Ziele
// (`PartyDaten.erzaehlerakteFuer(einfluss: true)`). Die Abende hier spielen ohne
// die Schicht; ihre Erzählerakte nennt die Ziele des Kanons. Für die Erzählerakte
// als PDF: kleine Ersatzporträts und die Datei, wie der Kern sie setzt.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart' show addTearDown;
import 'package:mordakte/detektei/akten.dart' show AkteInfo;
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/druck_portraets.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/party_druck.dart';

Map<String, Object?> _json(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as Map<String, Object?>;

PartyDaten? _daten;

/// Der Schlosskeller mit allem, was `PartyDaten.laden` für den Erzählteil liest.
PartyDaten get erzaehlDaten => _daten ??= () {
      final e = (_json('content/party/akten.json')['akten'] as List).cast<Map<String, Object?>>().firstWhere((a) => a['id'] == 'schlosskeller');
      return PartyDaten.aus(
        (p) => _json('content/party/schlosskeller/$p'),
        jsonDecode(File('content/scenarios/ravensmoor.json').readAsStringSync()) as Map<String, dynamic>,
        welt: _json('content/welt/schlosskeller/welt.json'),
        akte: AkteInfo(
          id: 'schlosskeller',
          titel: e['titel'] as String,
          untertitel: e['untertitel'] as String,
          ton: e['ton'] as String,
          faehigkeiten: {for (final f in e['faehigkeiten'] as List) f as String},
        ),
        diashow: _json('content/welt/schlosskeller/diashow.json'),
        vorspielMorgen: _json('content/welt/schlosskeller/vorspiel_morgen.json'),
        erzaehlerakte: _json('content/party/schlosskeller/erzaehlerakte.json'),
        erzaehlerZiele: _json('content/party/zusatz/schlosskeller/einfluss.json'),
        steckbriefe: _json('content/party/schlosskeller/steckbriefe.json'),
      );
    }();

/// Eingerichteter Abend mit [erzaehlDaten]: [rollen] Personen, Pfad ahmet, Würfel aus dem Salz.
PartySitzung erzaehlSitzung({
  int rollen = 7,
  bool solo = false,
  bool einstimmung = true,
  String erzaehler = '',
  Map<String, String> namen = const {},
  String detektivName = '',
  String detektiv = 'w',
  Abendfassung fassung = Abendfassung.kurz,
}) =>
    PartySitzung(erzaehlDaten, salz: 'einstimmung-test-salz')
      ..einrichten(
        rollen: rollen,
        detektiv: detektiv,
        solo: solo,
        code: FallCode.fuerPfad('ahmet', erzaehlDaten.kanon.pfade).code,
        erzaehlerName: erzaehler,
        namen: namen,
        detektivName: detektivName,
        fassung: fassung,
        einstimmung: einstimmung,
      );

/// Die Rollen gelesen: weiter bis in die Einleitung (ohne Einstimmung zu berühren).
void bisZurEinleitung(PartySitzung s) {
  while (s.phase != PartyPhase.intro) {
    s.weiter();
  }
}

/// Ein Porträt als PNG mit 2 × 2 Pixeln in Papierton: ersetzt in Tests den
/// Zeichner, damit die Erzählerakte schnell entsteht.
final ersatzPng = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEElEQVR4nGM4uXMeEDFAKAA8OgiBeEZPGQAAAABJRU5ErkJggg==');

/// Die Ersatzporträts: [ersatzPng] für jedes Porträt der Druckfassung.
Map<String, Uint8List> ersatzPortraets(Kanon kanon) => {for (final id in druckLooks(kanon).keys) id: ersatzPng};

/// Setzt für diesen Test die Ersatzporträts statt des Zeichners ein; die Liste
/// zählt, für welche Akten die App Porträts angefragt hat.
List<Kanon> mitErsatzPortraets() {
  final angefragt = <Kanon>[];
  final vorher = druckPortraetsUeber;
  druckPortraetsUeber = (k) async {
    angefragt.add(k);
    return ersatzPortraets(k);
  };
  addTearDown(() => druckPortraetsUeber = vorher);
  return angefragt;
}

/// Der festliche Stil mit den Schriften aus `assets/fonts` (wie die Kommandozeile).
FestStil festStilAusDateien() {
  Uint8List schrift(String name) => File('assets/fonts/$name').readAsBytesSync();
  return FestStil(
    titel: schrift('PlayfairDisplay-Variabel.ttf'),
    text: schrift('Lora-Variabel.ttf'),
    kursiv: schrift('Lora-Kursiv-Variabel.ttf'),
    hand: schrift('Caveat-Variabel.ttf'),
    maschine: schrift('SpecialElite-Regular.ttf'),
    funktion: schrift('Inter-Regular.ttf'),
    funktionStark: schrift('Inter-SemiBold.ttf'),
  );
}

/// Die Erzählerakte von [daten], wie der Kern sie setzt: Fassung nach [einfluss]
/// ([PartyDaten.erzaehlerakteFuer]), [rollen] Personen, die Ersatzporträts.
Future<Uint8List> erzaehlerakteSoll(PartyDaten daten, {required bool einfluss, required int rollen}) async {
  final k = ErzaehlerakteKontext(
    daten.kanon,
    daten.texte,
    daten.erzaehlerakteFuer(einfluss: einfluss)!,
    stil: festStilAusDateien(),
    rollen: rollen,
    portraets: FestPortraets(ersatzPortraets(daten.kanon)),
  );
  return (await festErzaehlerakteDatei(k)).bytes;
}
