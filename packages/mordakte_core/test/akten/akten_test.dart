// Akten-Test: jede Akte aus content/party/akten.json besteht die Prüfungen des Akten-Prüfers (bin/akte_pruefen.dart)
// über dieselben Bibliotheksfunktionen, dazu ein bestes Spiel mit Salz-Würfeln und die Privatsphäre am Schlosskeller-Raum.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart' show leseJson, repoWurzel;
import '../runden/befragung_treiber.dart';

const _lang = Timeout(Duration(minutes: 2));

/// Akte wie der Prüfer geladen: `roh` nur mit eigenen Texten, `texte` mit ui-Texten aus der eingefrorenen Basis.
class _Akte {
  _Akte(this.id) {
    Map<String, Object?> lies(String f) => leseJson('$repoWurzel/content/party/$id/$f');
    kanon = Kanon.lade(lies);
    roh = Textsammlung.lade(lies);
    final sammlung = Textsammlung.lade(lies);
    if (id != 'schlosskeller') sammlung.ergaenzeUi(Textsammlung.lade((f) => leseJson('$repoWurzel/content/party/basis-ui/$f')));
    texte = Texte(kanon, sammlung);
  }
  final String id;
  late final Kanon kanon;
  late final Textsammlung roh;
  late final Texte texte;
}

List<Map<String, Object?>> _liste(Object? wert) => [for (final v in wert as List) (v as Map).cast<String, Object?>()];

/// Bestes Spiel: richtige Option je Entscheidung, Gruppenwahl einstimmig, Anklage der Täterperson.
RundenPartie _bestesSpiel(_Akte a, String pfad, int n) {
  final k = a.kanon;
  final erm = Ermittlung(k);
  final p = RundenPartie(k, quelle: SalzWuerfel('akte:${a.id}:$pfad:$n'), ermittlung: erm)
    ..einrichten(Einstellungen(rollen: n, detektiv: n.isEven ? 'm' : 'w', code: FallCode.fuerPfad(pfad, k.pfade)));
  for (var schritt = 0; p.phase != PartyPhase.ende; schritt++) {
    expect(schritt, lessThan(400), reason: '$pfad, $n Rollen: Ablauf ohne Ende');
    final e = p.zug == null ? p.naechsteEntscheidung : null;
    if (e != null) {
      p.waehle(e.richtig[pfad]!, gruendlich: istSuche(e) && n.isEven);
    } else if (p.zug == null) {
      if (p.phase == PartyPhase.gruppenwahl) p.abstimmen(kooperativ: n - 1, taeterSabotiert: false);
      if (p.phase == PartyPhase.anklage) p.anklagen(pfad);
      p.weiter();
      continue;
    }
    while (p.zug != null) { // Zug zu Ende: Aktion, Wurf (Salz), Tischruf, Fund
      switch (p.zug!.phase) {
        case RundenZugPhase.aktion: p.aktionFertig(p.zug!.aktion);
        case RundenZugPhase.wurf: p.wuerfeln();
        case RundenZugPhase.tischruf: p.tischruf(n.isEven ? Tischruf.umweg : Tischruf.nochmal);
        case RundenZugPhase.fund: p.fundGelesen();
      }
    }
  }
  expect(p.spiel.punkte, erm.entscheidungen.length, reason: '$pfad, $n Rollen: Punkte');
  return p;
}

/// Ein Schritt des Gastgebers (bestes Spiel), nur über Nachrichten und öffentliche bzw. eigene Ansichten.
void _schritt(SchlosskellerRaum r, Ermittlung erm, Map<String, Object?> s, String pfad) {
  void tu(String id, String typ, [Map<String, Object?> d = const {}]) => r.nachricht(id, {'typ': typ, ...d});
  final zug = s['zug'] as Map?;
  switch (s['phase']) {
    case 'rollen':
      for (final t in _liste(s['spieler'])) { if (t['rolle'] != null && t['online'] == true) tu(t['id'] as String, 'rollenGelesen'); }
      tu('p0', 'weiter');
    case 'entscheidungen' when zug != null:
      switch (zug['phase']) {
        case 'aktion': tu('p0', 'aktionFertig', {'aktion': zug['aktion']});
        case 'wurf': tu(s['wuerfelPate'] as String, 'wurf');
        case 'tischruf': tu('p0', 'tischruf', {'ruf': (zug['aktion'] as int).isEven ? 'nochmal' : 'umweg'});
        case 'fund': tu('p0', 'fundGelesen');
      }
    case 'entscheidungen' when s['entscheidung'] != null:
      tu('p0', 'wahl', {'option': erm.entscheidung((s['entscheidung'] as Map)['id'] as String).richtig[pfad]!});
    case 'gespraeche':
      befragungenErledigen(s, (typ, d) => tu('p0', typ, d));
      tu('p0', 'weiter');
    case 'gruppenwahl':
      for (final t in _liste(s['spieler'])) { final privat = r.zustandFuer(t['id'] as String)['privat'] as Map; if (privat['rolle'] != null && privat['hatGestimmt'] == false) tu(t['id'] as String, 'stimme', {'kooperativ': true}); }
      tu('p0', 'weiter');
    case 'anklage':
      tu('p0', 'anklage', {'person': pfad});
      tu('p0', 'weiter');
    default:
      tu('p0', 'weiter');
  }
}

void main() {
  final akten = [for (final a in _liste(leseJson('$repoWurzel/content/party/akten.json')['akten'])) a['id'] as String];
  for (final id in akten) {
    group('Akte $id', () {
      test('Bundle lädt; Verweise, Simulation, Beweise und Textlücken sind leer', () {
        final a = _Akte(id);
        final k = a.kanon;
        expect(kanonVerweise(k), isEmpty);
        final sim = Simulator(k);
        expect(sim.pruefe(), isEmpty);
        expect(sim.pruefeSchwellen(), isEmpty);
        // Wie der Prüfer: Akten mit Simulation bekommen den Plausibilitätsprüfer dazu.
        final plausibel = k.hatSimulation ? Plausibilitaet(k) : null;
        expect(Beweise(k, plausibel).pruefe(), isEmpty);
        if (plausibel != null) expect([for (final v in plausibel.pruefe()) '$v'], isEmpty);
        expect(textLuecken(k, a.roh), isEmpty);
      }, timeout: _lang);

      test('bestes Spiel mit Salz-Würfeln endet im Meister-Ende (min und max Rollen)', () {
        final a = _Akte(id);
        for (final pfad in a.kanon.pfade) {
          for (final n in {a.texte.besetzung.minRollen, a.texte.besetzung.maxRollen}) {
            final p = _bestesSpiel(a, pfad, n);
            expect(p.spiel.ende.id, 'ende_meister', reason: '$pfad, $n Rollen');
            expect(p.spiel.restmenge(), {pfad}, reason: '$pfad, $n Rollen');
          }
        }
      }, timeout: _lang);

      test('Privatsphäre: vor dem Finale zeigt keine Ansicht Pfad, Fall-Code, Salz oder fremde Tarnung (min Rollen)', () {
        final a = _Akte(id);
        final n = a.texte.besetzung.minRollen;
        final erm = Ermittlung(a.kanon);
        for (final pfad in a.kanon.pfade) {
          final fall = FallCode.fuerPfad(pfad, a.kanon.pfade);
          final salz = 'q7x-${a.id}-$pfad-zz';
          final tarnung = a.texte.sammlung.taeter[pfad]!.tarnung;
          final verboten = ['pfad', 'fallCode', 'salz', salz, fall.code];
          final r = SchlosskellerRaum(raumCode: 'ABCD', kanon: a.kanon, texte: a.texte, akte: a.id, fallCode: fall, salz: salz);
          for (var i = 0; i <= n; i++) { expect(r.beitreten('p$i', 'Person $i'), isTrue); r.nachricht('p$i', {'typ': 'bereit', 'wert': true}); }
          r.nachricht('p0', {'typ': 'start', 'rollen': n});
          for (var schritt = 0;; schritt++) {
            expect(schritt, lessThan(400), reason: '$pfad: Ablauf ohne Ende');
            final host = r.zustandFuer('p0');
            if (host['phase'] == 'ende') break;
            if (!{'finale', 'aufloesung'}.contains(host['phase'])) {
              for (var i = 0; i <= n; i++) {
                final s = r.zustandFuer('p$i');
                final json = jsonEncode(s);
                for (final wort in verboten) { expect(json, isNot(contains(wort)), reason: '$pfad, p$i, ${host['phase']}: „$wort“'); }
                if ((s['privat'] as Map)['rolle'] != pfad) expect(json, isNot(contains(tarnung)), reason: '$pfad, p$i: fremde Tarnung');
              }
            }
            _schritt(r, erm, host, pfad);
          }
        }
      }, timeout: _lang);
    });
  }
}
