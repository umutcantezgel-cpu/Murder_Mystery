// M6 (A-055): Die Klassenfähigkeiten sind pfadgleich und reine Darstellung.
// Fünf Klassen (und die Karte ohne Klasse) × vier Pfade: An jeder Stelle der
// neun Entscheidungen und jedes Abstechers ist die Momentaufnahme der Karte in
// allen Pfaden gleich, die Wirkung der Klasse eingeschlossen. Gegenüber der
// Karte ohne Klasse unterscheidet sich nur die Darstellung (Leuchten, Umrisse,
// Marken, Gerüchte, Tempo des sichtbaren Laufs); Wege, Ziele, Figuren,
// Hotspots, Nachtminuten und Würfe bleiben gleich.
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte/party/klasse_wirkung.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'klasse_hilfe.dart';

/// Ohne Klasse und jede der fünf Klassen.
const _klassen = <KlassenFaehigkeit?>[null, ...KlassenFaehigkeit.values];

List<String> get _pfade => klassenDaten().kanon.pfade;

/// Zahl auf sechs Stellen, damit Rundungsreste des Laufs nicht zählen.
double _r(double x) => (x * 1e6).roundToDouble() / 1e6;

List<String>? _sortiert(Set<String>? menge) => menge == null ? null : (menge.toList()..sort());

/// Was der Renderer an der Karte zeigt, getrennt in Sache (gleich mit und ohne
/// Klasse) und Darstellung der Klasse (gleich in allen Pfaden).
({Map<String, Object?> sache, Map<String, Object?> darstellung}) _aufnahme(PartyKartenSession k, String stelle, {int bilder = 0}) {
  final s = k.sitzung;
  final welt = k.world.value!;
  final fall = k.caseView.value!;
  final licht = k.licht;
  final a = k.kartenAktion;
  final ich = welt.detectives.first;
  return (
    sache: {
      'stelle': stelle,
      'entscheidung': s.laufendeEntscheidung?.id,
      'zug': s.zug == null ? null : (s.zug!.id, s.zug!.phase.name),
      'hotspots': {for (final h in fall.hotspots.keys.toList()..sort()) h: fall.hotspots[h]},
      'npcs': [for (final n in welt.npcs) (n.id, _r(n.x), _r(n.y), n.talkingTo)],
      'npcAktion': {for (final n in welt.npcs) n.id: k.npcAktion(n.id)},
      'hotspotAktion': {for (final h in s.daten.szenario.hotspots) h.id: k.hotspotAktion(h.id)},
      'licht': licht == null ? null : [licht.dunkel, _sortiert(licht.helleRaeume), for (final p in licht.punkte) (p.x, p.y, p.radius, p.farbe.toARGB32())],
      'sichtbar': [for (final f in s.karte.figuren) _sortiert(k.sichtbareRaeume(f.x, f.y))],
      'glanz': [for (final g in k.glanzpunkte) (g.id, g.x, g.y)],
      'kameraZiele': [for (final z in k.kameraZiele) (_r(z.dx), _r(z.dy))],
      'detektiv': (_r(ich.x), _r(ich.y)),
      'aktion': a == null ? null : [for (final p in a.weg) p, a.zielX, a.zielY, a.suchen],
      'rest': (s.restMinuten, s.reserveMinuten, s.marken),
      'wuerfe': [for (final w in s.wuerfe) w.zeile],
      'gewaehlt': {...s.spiel.gewaehlt},
      'abstecher': {for (final e in s.abstecherErgebnis.entries) e.key: e.value.name},
    },
    darstellung: {
      'glanzRadius': k.glanzRadius,
      'tempo': k.tempoFaktor,
      'tueren': k.tuerenZeigen,
      'stimmung': k.stimmungZeigen,
      'marker': {for (final n in welt.npcs) n.id: k.gespraechsMarker(n.id)},
      'geruecht': {for (final n in welt.npcs) n.id: k.geruechtFuer(n.id)},
      'dauer': a == null ? null : _r(a.dauer),
      'bilder': bilder,
    },
  );
}

/// Die festen Optionen: je Entscheidung die erste oder die letzte Option.
Map<String, String> _festeWahl({required bool letzte, String fall = 'schlosskeller'}) => {
      for (final e in klassenDaten(fall).karte.ermittlung.entscheidungen) e.id: letzte ? e.optionen.last.id : e.optionen.first.id,
    };

/// Ein ganzer Ermittlungsteil mit Klasse [f]: je Runde zuerst ein Abstecher,
/// dann die drei Entscheidungen mit Vorschlag, Bestätigung und sichtbarem Lauf.
/// Aufgenommen wird vor dem Vorschlag, bei offenem Vorschlag, beim Start des
/// Laufs und nach dem Zug.
List<({Map<String, Object?> sache, Map<String, Object?> darstellung})> _verlauf(
    KlassenFaehigkeit? f, {required String pfad, required int n, required bool solo, required Map<String, String> wahl, String fall = 'schlosskeller'}) {
  final s = klassenSitzung(fall: fall, n: n, pfad: pfad, solo: solo, mitAbstecher: true);
  // Akten ohne den Zusatz klassen: die Wirkung trotzdem anlegen, um zu zeigen,
  // dass sie dort ebenso pfadgleich wäre (freigeschaltet ist sie dort nicht).
  final k = fall == 'schlosskeller' || f == null ? karteMit(s, f) : PartyKartenSession(s, klasse: KlasseWirkung.amTisch(s, f));
  addTearDown(k.dispose);
  final aufnahmen = <({Map<String, Object?> sache, Map<String, Object?> darstellung})>[];
  for (var r = 1; r <= 3; r++) {
    _bisEntscheidungen(s, k, r);
    final ab = s.abstecherOffen.firstOrNull;
    if (ab != null) {
      s.starteAbstecher(ab.id);
      aufnahmen.add(_aufnahme(k, 'abstecher ${ab.id} los'));
      final bilder = spieleZugAufKarte(s, k);
      aufnahmen.add(_aufnahme(k, 'abstecher ${ab.id} fertig', bilder: bilder));
    }
    for (var i = 0; i < 3; i++) {
      final e = s.laufendeEntscheidung!;
      aufnahmen.add(_aufnahme(k, '${e.id} vor'));
      s.schlageVor(wahl[e.id]!);
      aufnahmen.add(_aufnahme(k, '${e.id} vorschlag'));
      s.bestaetigen();
      aufnahmen.add(_aufnahme(k, '${e.id} lauf'));
      final bilder = spieleZugAufKarte(s, k);
      aufnahmen.add(_aufnahme(k, '${e.id} fertig', bilder: bilder));
    }
  }
  return aufnahmen;
}

/// Bis zu den Entscheidungen der Runde [runde] (Auftakt über die Karte, Gruppe: alle A).
void _bisEntscheidungen(PartySitzung s, PartyKartenSession k, int runde) {
  for (var i = 0; i < 200; i++) {
    if (s.phase == PartyPhase.entscheidungen && s.runde == runde && s.zug == null && s.laufendeEntscheidung != null) return;
    switch (s.phase) {
      case PartyPhase.gespraeche:
        for (final g in s.soloGespraeche) {
          s.soloGespraechGelesen(g.id);
        }
        s.weiter();
      case PartyPhase.entscheidungen:
        if (s.zug != null) {
          spieleZugAufKarte(s, k);
        } else {
          s.weiter();
        }
      case PartyPhase.gruppenwahl:
        if (s.offeneWaehler.isEmpty) {
          s.weiter();
        } else {
          final w = s.offeneWaehler.first;
          s.zeigeVerdeckt(w);
          s.stimme(w, kooperativ: true);
        }
      default:
        s.weiter();
    }
  }
  throw StateError('Runde $runde nicht erreicht');
}

void main() {
  for (final (n, solo) in [(4, false), (12, false), (7, true)]) {
    for (final letzte in [false, true]) {
      final wo = solo ? 'Solo mit $n Bots' : '$n Personen';
      group('$wo, ${letzte ? 'letzte' : 'erste'} Optionen', () {
        final wahl = _festeWahl(letzte: letzte);
        final ohne = <String, List<({Map<String, Object?> sache, Map<String, Object?> darstellung})>>{};

        for (final f in _klassen) {
          final name = f?.name ?? 'ohne Klasse';
          test('$name: alle vier Pfade gleich, Sache wie ohne Klasse', () {
            final verlaeufe = {for (final p in _pfade) p: _verlauf(f, pfad: p, n: n, solo: solo, wahl: wahl)};
            final erster = verlaeufe[_pfade.first]!;
            expect(erster.length, greaterThanOrEqualTo(36), reason: 'neun Entscheidungen zu je vier Stellen');
            expect(erster.any((a) => a.sache['aktion'] != null), isTrue, reason: 'die Wege gehören zum Vergleich');
            for (final p in _pfade.skip(1)) {
              expect(verlaeufe[p], hasLength(erster.length), reason: 'Pfad $p: Zahl der Stellen');
              for (var i = 0; i < erster.length; i++) {
                expect(verlaeufe[p]![i].sache, equals(erster[i].sache), reason: '$name, Pfad $p: Sache bei ${erster[i].sache['stelle']}');
                expect(verlaeufe[p]![i].darstellung, equals(erster[i].darstellung), reason: '$name, Pfad $p: Darstellung bei ${erster[i].sache['stelle']}');
              }
            }
            if (f == null) {
              ohne.addAll(verlaeufe);
              return;
            }
            // Gegenüber der Karte ohne Klasse: dieselbe Sache in jedem Pfad.
            for (final p in _pfade) {
              final basis = ohne[p] ?? _verlauf(null, pfad: p, n: n, solo: solo, wahl: wahl);
              expect(verlaeufe[p], hasLength(basis.length), reason: '$name, Pfad $p: Zahl der Stellen');
              for (var i = 0; i < basis.length; i++) {
                expect(verlaeufe[p]![i].sache, equals(basis[i].sache), reason: '$name, Pfad $p: ${basis[i].sache['stelle']} weicht ab');
              }
            }
            // Gegenprobe: Die Klasse zeigt wirklich etwas, die Karte ohne Klasse nicht.
            final basis = ohne[_pfade.first] ?? _verlauf(null, pfad: _pfade.first, n: n, solo: solo, wahl: wahl);
            final anders = [
              for (var i = 0; i < basis.length; i++)
                if (erster[i].darstellung.toString() != basis[i].darstellung.toString()) erster[i].sache['stelle'],
            ];
            expect(anders, isNotEmpty, reason: '$name wirkt nirgends auf die Darstellung');
            switch (f) {
              case KlassenFaehigkeit.spurenblick:
                expect(erster.first.darstellung['glanzRadius'], 6);
              case KlassenFaehigkeit.ortskundig:
                expect(erster.first.darstellung['tueren'], isTrue);
              case KlassenFaehigkeit.menschenkenner:
                expect(erster.any((a) => (a.darstellung['marker'] as Map).values.contains(true)), isTrue, reason: 'kein Gesprächsmarker');
              case KlassenFaehigkeit.geruechte:
                expect(erster.any((a) => (a.darstellung['geruecht'] as Map).values.any((g) => g != null)), isTrue, reason: 'kein Gerücht');
              case KlassenFaehigkeit.laufschritt:
                final schneller = [
                  for (var i = 0; i < basis.length; i++)
                    if ((erster[i].darstellung['bilder'] as int) < (basis[i].darstellung['bilder'] as int)) i,
                ];
                expect(schneller, isNotEmpty, reason: 'der Laufschritt ist nirgends schneller');
            }
          });
        }
      });
    }
  }

  // Die anderen Akten haben den Zusatz klassen nicht (Besitzer: nachweislich
  // unverändert). Ihr Lauf zeigt nur, dass die Mechanik dort ebenso pfadgleich
  // und reine Darstellung wäre.
  group('Andere Akten (nicht freigeschaltet)', () {
    for (final fall in ['gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
      test('$fall: jede Klasse in allen Pfaden gleich, Sache wie ohne Klasse', () {
        final pfade = klassenDaten(fall).kanon.pfade;
        final wahl = _festeWahl(letzte: false, fall: fall);
        final n = (klassenDaten(fall).kanon.besetzungJson['minRollen'] as int).clamp(4, 20);
        final ohne = {for (final p in pfade) p: _verlauf(null, pfad: p, n: n, solo: false, wahl: wahl, fall: fall)};
        for (final f in KlassenFaehigkeit.values) {
          final verlaeufe = {for (final p in pfade) p: _verlauf(f, pfad: p, n: n, solo: false, wahl: wahl, fall: fall)};
          for (final p in pfade) {
            expect(verlaeufe[p], hasLength(ohne[p]!.length), reason: '$fall, ${f.name}, Pfad $p');
            for (var i = 0; i < ohne[p]!.length; i++) {
              expect(verlaeufe[p]![i].sache, equals(ohne[p]![i].sache), reason: '$fall, ${f.name}, Pfad $p: ${ohne[p]![i].sache['stelle']}');
              expect(verlaeufe[p]![i].darstellung, equals(verlaeufe[pfade.first]![i].darstellung), reason: '$fall, ${f.name}, Pfad $p: Darstellung');
            }
          }
        }
      });
    }
  });

  group('Gating und Gerüchte', () {
    test('ohne den Zusatz klassen gibt es keine Wirkung, ebenso ohne bekannte Klasse', () {
      final s = klassenSitzung(n: 4, pfad: klassenDaten().kanon.pfade.first);
      expect(KlasseWirkung.fuer(s, 'forensic'), isNotNull, reason: 'der Schlosskeller hat Klassen');
      expect(KlasseWirkung.fuer(s, 'unbekannt'), isNull);
      expect(KlasseWirkung.fuer(s, null), isNull);
      for (final akte in ['gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
        final andere = klassenSitzung(fall: akte, n: 4, pfad: klassenDaten(akte).kanon.pfade.first);
        expect(andere.daten.hat('klassen'), isFalse, reason: akte);
        expect(KlasseWirkung.fuer(andere, 'forensic'), isNull, reason: akte);
        expect(andere.daten.geruechte, isNull, reason: '$akte: Gerüchte nur im Schlosskeller');
      }
    });

    test('eine Rolle, die ein Mensch spielt, sagt kein Gerücht (R14); im Solo sprechen alle', () {
      final pfad = klassenDaten().kanon.pfade.first;
      for (final solo in [false, true]) {
        final s = klassenSitzung(n: 7, pfad: pfad, solo: solo);
        final k = karteMit(s, KlassenFaehigkeit.geruechte);
        addTearDown(k.dispose);
        final rollen = {for (final f in s.kanon.figuren) f['id'] as String};
        for (final f in s.karte.figuren) {
          final npc = s.daten.npcKennung[f.id]!;
          final zeile = k.geruechtFuer(npc);
          if (!rollen.contains(f.id)) {
            expect(zeile, isNull, reason: '${f.id} ist keine Rolle');
          } else if (!solo && s.besetzt.contains(f.id)) {
            expect(zeile, isNull, reason: '${f.id} spielt ein Mensch');
          } else {
            expect(zeile, isNotNull, reason: '${f.id}: ${solo ? 'Solo' : 'unbesetzt'}');
            expect(s.daten.geruechte!.zeilen(f.id, s.runde.clamp(1, 3)), contains(zeile));
          }
        }
      }
    });
  });
}
