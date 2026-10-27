// Testhilfe für Einstimmung und Erzählerakte (Finale Schlosskeller, A-063):
// der Schlosskeller wie in der App, mit Eintrag in akten.json (Zusätze samt
// einstimmung, erzaehlerakte, einfluss), Diashow, Vorspiel und Morgen,
// Steckbriefen, Erzählerakte und den Sternen der Einfluss-Schicht als Ziele.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte/detektei/akten.dart' show AkteInfo;
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';

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
