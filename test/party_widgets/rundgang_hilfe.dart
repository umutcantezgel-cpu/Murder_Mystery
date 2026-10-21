// Testhilfe für Vorspiel und Morgen (Langer Abend M7b): der Schlosskeller mit
// Eintrag in akten.json (langfassung), Diashow und vorspiel_morgen.json, dazu
// Ebenen und Szenarien aus den Repo-Dateien für den Rundgang-Bildschirm.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte/detektei/akten.dart' show AkteInfo;
import 'package:mordakte/party/bildschirme/rundgang.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';

Map<String, Object?> _json(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as Map<String, Object?>;

PartyDaten? _daten;

/// Der Schlosskeller wie in der App im langen Abend: Zusätze aus akten.json,
/// Diashow, welt.json und Vorspiel und Morgen.
PartyDaten get rundgangDaten => _daten ??= () {
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
      );
    }();

/// Der Rundgang-Bildschirm lädt Ebenen und Szenarien aus den Repo-Dateien statt aus den Assets.
void rundgangWeltAusDateien() => RundgangBildschirm.weltLaden = (_) async => (weltEbenen, ebenenSzenarien);

/// Eingerichteter Abend mit [rundgangDaten]: [rollen] Personen, Pfad [pfad], Fassung [fassung], Würfel aus dem Salz.
PartySitzung rundgangSitzung({int rollen = 4, String pfad = 'ahmet', bool solo = true, Abendfassung fassung = Abendfassung.lang, String erzaehler = ''}) {
  // Würfel aus dem Salz wie in der App: So spielt ein Journal denselben Abend nach.
  final s = PartySitzung(rundgangDaten, salz: 'rundgang-test-salz');
  s.einrichten(
    rollen: rollen,
    detektiv: 'w',
    solo: solo,
    code: FallCode.fuerPfad(pfad, rundgangDaten.kanon.pfade).code,
    fassung: fassung,
    erzaehlerName: erzaehler,
  );
  return s;
}

/// Geht den laufenden Rundgang bis zum Ende ab.
void rundgangAbgehen(PartySitzung s) {
  for (var i = 0; i < 20 && s.rundgang != null; i++) {
    s.rundgangWeiter();
  }
}
