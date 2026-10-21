// Testhilfe für die Klassenfähigkeiten auf der Karte (A-055, M6): der
// Schlosskeller mit Randgesprächen, Gerüchten und seinem Eintrag aus
// akten.json, Sitzungen mit Karte und ein Zugtreiber, der den sichtbaren Lauf
// über die Karte abspielt statt ihn zu überspringen.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte/party/klasse_wirkung.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

Map<String, Object?> _json(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as Map<String, Object?>;

/// Eintrag der Akte [fall] aus `content/party/akten.json` (mit ihren Zusätzen).
AkteInfo akteAusKatalog(String fall) {
  final e = (_json('content/party/akten.json')['akten'] as List).cast<Map<String, Object?>>().firstWhere((a) => a['id'] == fall);
  return AkteInfo(
    id: fall,
    titel: e['titel'] as String,
    untertitel: e['untertitel'] as String,
    ton: e['ton'] as String,
    faehigkeiten: {for (final f in (e['faehigkeiten'] as List? ?? const [])) f as String},
  );
}

final _daten = <String, PartyDaten>{};

/// Einmal geladene Daten einer Akte wie in der App: Gespräche mit Wahl,
/// Gerüchte und Zusätze aus akten.json.
PartyDaten klassenDaten([String fall = 'schlosskeller']) => _daten[fall] ??= () {
      final erzaehlung = File('content/erzaehlung/$fall/gespraeche.json');
      final welt = File('content/welt/$fall/welt.json');
      final weltJson = welt.existsSync() ? _json(welt.path) : null;
      final geruechte = weltJson?['geruechte'] is String ? File('content/welt/$fall/${weltJson!['geruechte']}') : null;
      final setting = _json('content/party/$fall/setting.json');
      final vorlage = ((setting['darstellung'] as Map?)?['vorlage'] as String?) ?? 'content/scenarios/ravensmoor.json';
      return PartyDaten.aus(
        (p) => _json('content/party/$fall/$p'),
        _json(vorlage),
        fall: fall,
        basis: fall == 'schlosskeller' ? null : (p) => _json('content/party/basis-ui/$p'),
        welt: weltJson,
        erzaehlung: erzaehlung.existsSync() ? _json(erzaehlung.path) : null,
        akte: akteAusKatalog(fall),
        geruechte: geruechte == null ? null : _json(geruechte.path),
      );
    }();

/// Erkundungsorte der Akte (`content/party/zusatz/<fall>/abstecher.json`).
List<AbstecherOrt> abstecherVon(String fall) {
  final f = File('content/party/zusatz/$fall/abstecher.json');
  return f.existsSync() ? AbstecherOrt.liste(_json(f.path)) : const [];
}

/// Ein eingerichteter Abend mit [n] Rollen im Pfad [pfad]; auf Wunsch mit
/// Erkundungsorten und Karten auf dem Tisch.
PartySitzung klassenSitzung({
  String fall = 'schlosskeller',
  required int n,
  required String pfad,
  bool solo = false,
  WuerfelQuelle? wuerfel,
  String? salz,
  bool mitAbstecher = false,
  TischVorrat? vorrat,
}) {
  final d = klassenDaten(fall);
  // Mit Salz würfelt der Abend gesalzen (SalzWuerfel), sonst neutral.
  final s = PartySitzung(d, wuerfel: wuerfel ?? (salz == null ? const FesterWuerfel.neutral() : null), salz: salz);
  if (mitAbstecher || vorrat != null) s.kartenAnlegen(vorrat: vorrat, abstecher: mitAbstecher ? abstecherVon(fall) : const []);
  s.einrichten(rollen: n, detektiv: 'w', solo: solo, code: FallCode.fuerPfad(pfad, d.kanon.pfade).code);
  return s;
}

/// Die Karte des Abends, mit der Wirkung der Klasse [f] (`null`: ohne Klasse).
/// Wie in der App entscheidet `KlasseWirkung.fuer` über die Zusätze der Akte.
PartyKartenSession karteMit(PartySitzung s, KlassenFaehigkeit? f) =>
    PartyKartenSession(s, klasse: f == null ? null : KlasseWirkung.fuer(s, f.klasse));

/// Bild für Bild, wie der Renderer die Szene vorantreibt (30 Bilder je Sekunde).
const bildDauer = 1 / 30;

/// Spielt den laufenden Zug: den Lauf sichtbar über die Karte ([k]), dann
/// Wurf, Tischruf und Fund. Liefert die Zahl der Bilder, die der Lauf brauchte.
int spieleZugAufKarte(PartySitzung s, PartyKartenSession k, {Tischruf ruf = Tischruf.umweg}) {
  var bilder = 0;
  for (var i = 0; i < 40; i++) {
    final z = s.zug;
    if (z == null) {
      if (s.letzterFund != null) s.fundGelesen();
      return bilder;
    }
    switch (z.phase) {
      case RundenZugPhase.aktion:
        final nr = z.aktion;
        while (s.zug?.phase == RundenZugPhase.aktion && s.zug?.aktion == nr) {
          if (++bilder > 30 * 60) throw StateError('Lauf endet nicht: ${z.id}');
          k.szenenSchritt(bildDauer);
        }
      case RundenZugPhase.wurf:
        s.wuerfeln();
      case RundenZugPhase.tischruf:
        s.tischruf(ruf);
      case RundenZugPhase.fund:
        s.fundGelesen();
        return bilder;
    }
  }
  throw StateError('Zug nicht beendet');
}
