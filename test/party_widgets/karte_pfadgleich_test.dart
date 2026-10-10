// F4-TEST-02: Die Karte ist vor dem Finale in allen vier Pfaden gleich (F-12,
// E-008). Geprüft wird auf der Ebene, die der Renderer bekommt: die
// PartyKartenSession mit Figuren, Hotspots, Licht, Aktionen und Sicht.
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';

/// Stellen einer Entscheidung, an denen die Karte beobachtet wird.
enum _Stelle { vorVorschlag, mitVorschlag, nachBestaetigung }

List<String> get _pfade => partyDaten.kanon.pfade;

/// Ein Abend mit [n] Personen und Pfad [pfad] bis zu den Entscheidungen, mit seiner Karte.
({PartySitzung s, PartyKartenSession k}) _karte(int n, String pfad) {
  final s = neueSitzung(rollen: n, pfad: pfad);
  final k = PartyKartenSession(s);
  addTearDown(k.dispose);
  return (s: s, k: k);
}

/// Die festen Optionen: je Entscheidung die erste oder die letzte Option des Kanons.
Map<String, String> _festeWahl({required bool letzte}) => {
      for (final e in partyDaten.karte.ermittlung.entscheidungen) e.id: letzte ? e.optionen.last.id : e.optionen.first.id,
    };

/// Spielt die neun Entscheidungen mit den Optionen [wahl] und meldet jede Stelle:
/// vor dem Vorschlag, bei offenem Vorschlag und nach der Bestätigung.
void _spieleEntscheidungen(PartySitzung s, Map<String, String> wahl, void Function(_Stelle, Entscheidung) beobachte) {
  for (var r = 1; r <= 3; r++) {
    spieleBis(s, PartyPhase.entscheidungen, runde: r);
    for (var i = 0; i < 3; i++) {
      final e = s.laufendeEntscheidung!;
      beobachte(_Stelle.vorVorschlag, e);
      s.schlageVor(wahl[e.id]!);
      beobachte(_Stelle.mitVorschlag, e);
      s.bestaetigen();
      beobachte(_Stelle.nachBestaetigung, e);
      spieleZug(s);
    }
  }
}

/// Mengen als sortierte Liste, damit der Vergleich nicht an der Reihenfolge hängt.
List<String>? _sortiert(Set<String>? menge) => menge == null ? null : (menge.toList()..sort());

/// Was der Renderer an der Karte zeigt, in vergleichbarer Form.
Map<String, Object?> _momentaufnahme(PartyKartenSession k, _Stelle stelle) {
  final s = k.sitzung;
  final welt = k.world.value!;
  final fall = k.caseView.value!;
  final licht = k.licht;
  final kamera = k.kamera;
  final aussehen = k.detektivAussehen;
  return {
    'stelle': stelle.name,
    'entscheidung': s.laufendeEntscheidung?.id,
    'hotspots': {for (final h in fall.hotspots.keys.toList()..sort()) h: fall.hotspots[h]},
    'npcs': [for (final n in welt.npcs) (n.id, n.x, n.y)],
    'npcAktion': {for (final n in welt.npcs) n.id: k.npcAktion(n.id)},
    'hotspotAktion': {for (final h in s.daten.szenario.hotspots) h.id: k.hotspotAktion(h.id)},
    'licht': licht == null
        ? null
        : {
            'dunkel': licht.dunkel,
            'taschenlampe': licht.taschenlampe,
            'helleRaeume': _sortiert(licht.helleRaeume),
            'punkte': [for (final p in licht.punkte) (p.x, p.y, p.z, p.radius, p.farbe.toARGB32(), p.flackern)],
          },
    'sichtbar': [for (final f in partyDaten.karte.figuren) _sortiert(k.sichtbareRaeume(f.x, f.y))],
    'kamera': kamera == null ? null : (kamera.dx, kamera.dy),
    'hervorhebung': {for (final n in welt.npcs) n.id: k.hervorhebung(n.id)},
    'aussehen': aussehen == null ? null : (aussehen.coat, aussehen.skin, aussehen.hair, aussehen.hat),
  };
}

/// Momentaufnahmen eines Abends an jeder Stelle der neun Entscheidungen.
List<Map<String, Object?>> _verlauf(int n, String pfad, Map<String, String> wahl) {
  final h = _karte(n, pfad);
  final stellen = <Map<String, Object?>>[];
  _spieleEntscheidungen(h.s, wahl, (stelle, _) => stellen.add(_momentaufnahme(h.k, stelle)));
  return stellen;
}

/// Rückblende eines Pfads nach einigen Ticks: Kamera und Hervorhebung je Person.
Future<Map<String, Object?>> _rueckblende(String pfad) async {
  final s = neueSitzung(rollen: 7, pfad: pfad);
  spieleBis(s, PartyPhase.finale);
  final k = PartyKartenSession(s, rueckblendeModus: true);
  addTearDown(k.dispose);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final kamera = k.kamera;
  return {
    'kamera': kamera == null ? null : (kamera.dx, kamera.dy),
    'hervorhebung': {for (final n in k.world.value!.npcs) n.id: k.hervorhebung(n.id)},
  };
}

void main() {
  group('Karte vor dem Finale (F-12, E-008)', () {
    for (final n in [4, 12, 20]) {
      for (final letzte in [false, true]) {
        final optionen = letzte ? 'letzten' : 'ersten';
        test('bei $n Personen sind die Momentaufnahmen aller vier Pfade mit den $optionen Optionen gleich', () {
          final wahl = _festeWahl(letzte: letzte);
          final verlaeufe = {for (final p in _pfade) p: _verlauf(n, p, wahl)};
          final erster = verlaeufe[_pfade.first]!;
          expect(erster, hasLength(27), reason: 'neun Entscheidungen zu je drei Stellen');
          expect(erster.first['licht'], isNotNull, reason: 'das Licht gehört zum Vergleich');
          expect(erster.first['npcs'], isNotEmpty, reason: 'die Figuren gehören zum Vergleich');
          expect(erster.last['hotspots'], isNotEmpty, reason: 'die Hotspots gehören zum Vergleich');
          for (final p in _pfade.skip(1)) {
            expect(verlaeufe[p], hasLength(erster.length), reason: 'Pfad $p: Zahl der Stellen');
            for (var i = 0; i < erster.length; i++) {
              expect(
                verlaeufe[p]![i],
                equals(erster[i]),
                reason: 'Pfad $p weicht bei ${erster[i]['entscheidung']} (${erster[i]['stelle']}) ab',
              );
            }
          }
        });
      }
    }

    test('vor dem Vorschlag ist nur ansprechbar, wer zur laufenden Entscheidung gehört', () {
      var zielePruefung = 0;
      for (final p in _pfade) {
        final h = _karte(4, p);
        _spieleEntscheidungen(h.s, _festeWahl(letzte: false), (stelle, e) {
          if (stelle != _Stelle.vorVorschlag) return;
          final ziele = {for (final z in partyDaten.karte.zieleVon(e.id)) if (z.person != null) z.person!};
          var ansprechbar = 0;
          for (final n in h.k.world.value!.npcs) {
            final aktion = h.k.npcAktion(n.id);
            final kennung = partyDaten.kanonKennung[n.id];
            if (ziele.contains(kennung)) {
              ansprechbar++;
              expect(aktion, isNotNull, reason: '$p, ${e.id}: $kennung ist ein Ziel');
              expect(aktion!.trim(), isNotEmpty, reason: '$p, ${e.id}: $kennung ist ein Ziel');
            } else {
              expect(aktion, isNull, reason: '$p, ${e.id}: $kennung ist kein Ziel');
            }
          }
          expect(ansprechbar, ziele.length, reason: '$p, ${e.id}: jedes Ziel steht auf der Karte');
          zielePruefung += ziele.length;
        });
      }
      expect(zielePruefung, greaterThan(0), reason: 'es gibt Personen als Ziel, die geprüft werden');
    });

    test('während ein Vorschlag offen ist, ist niemand ansprechbar', () {
      for (final p in _pfade) {
        final h = _karte(4, p);
        _spieleEntscheidungen(h.s, _festeWahl(letzte: false), (stelle, e) {
          if (stelle != _Stelle.mitVorschlag) return;
          for (final n in h.k.world.value!.npcs) {
            expect(h.k.npcAktion(n.id), isNull, reason: '$p, ${e.id}: ${n.id}');
          }
        });
      }
    });

    test('erst nach Aktion und Wurf ist der gewählte Hotspot durchsucht', () {
      for (final p in _pfade) {
        final h = _karte(7, p);
        spieleBis(h.s, PartyPhase.entscheidungen, runde: 2);
        final e = h.s.laufendeEntscheidung!;
        final stellen = [for (final z in partyDaten.karte.zieleVon(e.id)) if (z.person == null) z];
        expect(stellen, isNotEmpty, reason: '${e.id} hat eine Stelle, die man absuchen oder untersuchen kann');
        final ziel = stellen.first;
        h.s.schlageVor(ziel.option);
        expect(h.k.caseView.value!.hotspots[ziel.hotspot], HotspotState.open, reason: '$p: ${ziel.hotspot} vor dem Bestätigen');
        h.s.bestaetigen();
        expect(h.k.caseView.value!.hotspots[ziel.hotspot], HotspotState.open, reason: '$p: noch kein Fund vor der Aktion');
        spieleZug(h.s, lesen: false);
        expect(h.k.caseView.value!.hotspots[ziel.hotspot], HotspotState.searched, reason: '$p: ${ziel.hotspot} erst nach dem Wurf');
      }
    });

    test('die Rückblende zeigt zwischen Täter- und Fremdpfad Unterschiede (Gegenprobe)', () async {
      final ahmet = await _rueckblende('ahmet');
      final can = await _rueckblende('can');
      expect(ahmet, isNot(equals(can)));
    });
  });
}
