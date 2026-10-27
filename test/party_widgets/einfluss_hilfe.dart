// Testhilfe für „Dein Moment“ (Finale §3): der Schlosskeller mit seinem
// Eintrag in akten.json und den Regeln aus content/party/zusatz/schlosskeller.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte/detektei/akten.dart' show AkteInfo;
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

Map<String, Object?> _json(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as Map<String, Object?>;

PartyDaten? _daten;

/// Der Schlosskeller wie in der App, mit „Dein Moment“ (Zusatz `einfluss`).
PartyDaten get einflussDaten => _daten ??= () {
      final akten = _json('content/party/akten.json');
      final e = (akten['akten'] as List).cast<Map<String, Object?>>().firstWhere((a) => a['id'] == 'schlosskeller');
      return PartyDaten.aus(
        (p) => _json('content/party/schlosskeller/$p'),
        _json('content/scenarios/ravensmoor.json'),
        akte: AkteInfo(
          id: 'schlosskeller',
          titel: e['titel'] as String,
          untertitel: e['untertitel'] as String,
          ton: e['ton'] as String,
          faehigkeiten: {for (final f in e['faehigkeiten'] as List) f as String},
        ),
        einfluss: _json('content/party/zusatz/schlosskeller/einfluss.json'),
      );
    }();

/// Eine eingerichtete Sitzung mit „Dein Moment“ (gesalzene Würfel, wenn nichts anderes verlangt).
PartySitzung einflussSitzung({int rollen = 4, String pfad = 'ahmet', bool solo = false, String salz = 'moment-test', WuerfelQuelle? wuerfel, bool einfluss = true}) {
  final s = PartySitzung(einflussDaten, salz: salz, wuerfel: wuerfel);
  s.einrichten(rollen: rollen, detektiv: 'w', solo: solo, code: FallCode.fuerPfad(pfad, einflussDaten.kanon.pfade).code, einfluss: einfluss);
  return s;
}

/// Ein fester Zug je Rolle und Runde: Ahmet deckt sich, die Zweite zeigt auf
/// Ahmet, die Dritte hilft, alle anderen lauschen bei Ahmet oder helfen. In der
/// Tipp-Runde tippen alle auf Ahmet.
({ZugArt art, String? ziel, String? tipp}) planZug(PartySitzung s, String rolle) {
  final m = s.momentSicht(rolle);
  final tipp = m.tipps.isEmpty ? null : m.tipps.first;
  final i = s.besetzt.indexOf(rolle);
  if (rolle == 'ahmet' && m.arten.contains(ZugArt.decken)) return (art: ZugArt.decken, ziel: 'ahmet', tipp: tipp);
  if (i == 1 && m.arten.contains(ZugArt.zeigen)) return (art: ZugArt.zeigen, ziel: 'ahmet', tipp: tipp);
  if (i == 3 && m.arten.contains(ZugArt.lauschen)) return (art: ZugArt.lauschen, ziel: 'ahmet', tipp: tipp);
  return (art: ZugArt.helfen, ziel: null, tipp: tipp);
}

/// Reihum zieht jede Person verdeckt ihren geplanten Zug.
void alleZiehen(PartySitzung s, {({ZugArt art, String? ziel, String? tipp}) Function(PartySitzung s, String rolle) plan = planZug}) {
  for (final r in [...s.momentOffen]) {
    s.momentZeigen(r);
    final z = plan(s, r);
    s.momentZug(r, z.art, ziel: z.ziel, tipp: z.tipp);
  }
}

/// Spielt bis [ziel] (wie [spieleBis]); in den Gesprächen ziehen vorher alle ihren Moment.
/// Einstimmung und Vorspiel der Einleitung werden übersprungen.
void einflussBis(PartySitzung s, PartyPhase ziel, {int? runde}) {
  for (var i = 0; i < 400; i++) {
    if (s.phase == ziel && (runde == null || s.runde == runde) && !(ziel == PartyPhase.entscheidungen && s.zug?.istAuftakt == true)) return;
    if (s.phase == PartyPhase.gespraeche) alleZiehen(s);
    if (s.folgenOffen) s.folgenGelesen();
    if (s.phase == PartyPhase.gespraeche || s.phase == PartyPhase.entscheidungen) {
      spieleBis(s, s.phase == PartyPhase.gespraeche ? PartyPhase.entscheidungen : PartyPhase.bonus);
      continue;
    }
    if (s.phase == ziel) return;
    switch (s.phase) {
      case PartyPhase.anklage:
        if (s.angeklagt == null) s.anklagen(s.spiel.pfad);
        s.weiter();
      // Einstimmung (A-063) und Vorspiel (M7b) überspringt der Test wie in [spieleBis].
      case PartyPhase.intro when s.einstimmung != null:
        s.einstimmungUeberspringen();
      case PartyPhase.intro when s.rundgang != null:
        s.rundgangUeberspringen();
      default:
        s.weiter();
    }
  }
  throw StateError('Phase $ziel nicht erreicht');
}
