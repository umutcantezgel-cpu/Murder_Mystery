// M6 (A-055): Keine Klasse ändert Optionen, Fakten, Punkte, Ende, Würfe oder
// Nachtminuten. Ganze Abende mit gesalzenen Würfeln in allen vier Pfaden,
// jeder sichtbare Lauf über die Karte abgespielt: Mit jeder der fünf Klassen
// endet der Abend genau wie ohne Klasse. Dazu der Renderer: Der Laufschritt
// macht die eigene Figur schneller, das Zeichnen jeder Klasse läuft ohne
// Fehler, und auch ein über den Renderer gespielter Abend bleibt gleich.
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flame/game.dart' show Vector2;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/mordakte_game.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' hide KartenQuelle;

import 'klasse_hilfe.dart';

const _klassen = <KlassenFaehigkeit?>[null, ...KlassenFaehigkeit.values];

/// Karten des Tisches: Werkzeug, Zeit und Nochmal aus den Klassendecks. Der
/// Treiber spielt sie nie; liegen sie bereit, könnte eine unfaire Wirkung sie
/// missbrauchen (Gegenprobe im Übergabebericht).
TischVorrat _vorrat() {
  final katalog = KartenKatalog.ausDateien([
    for (final f in Directory('content/karten').listSync().whereType<File>())
      if (f.path.endsWith('.json') && !f.path.endsWith('.schema.json')) jsonDecode(f.readAsStringSync()) as Map<String, Object?>,
  ]);
  return TischVorrat.aus(['mordakte:forensic:koefferchen', 'mordakte:medic:notfalltasche', 'mordakte:forensic:abdruck'], katalog);
}

/// Feste, aber je Pfad und Lauf andere Optionsfolge.
Map<String, String> _folge(String pfad, int nr) {
  final rng = Rng(Rng.hashString('klasse_invarianz:$pfad:$nr'));
  return {for (final e in klassenDaten().karte.ermittlung.entscheidungen) e.id: e.optionen[rng.nextInt(e.optionen.length)].id};
}

/// Alles, was eine Klasse nie ändern darf, am Ende des Abends.
Map<String, Object?> _ergebnis(PartySitzung s) => {
      'punkte': s.spiel.punkte,
      'ende': s.ende.id,
      'richtig': s.ende.richtig,
      'gewaehlt': {...s.spiel.gewaehlt},
      'fakten': {for (final e in s.funde.entries) e.key: [for (final a in e.value) (a.fakt, a.entstanden)]},
      'wuerfe': [for (final w in s.wuerfe) w.zeile],
      'nachtminuten': (s.restMinuten, s.reserveMinuten),
      'marken': s.marken,
      'abstecher': {for (final e in s.abstecherErgebnis.entries) e.key: e.value.name},
      'qualitaeten': {for (final e in s.spiel.qualitaeten.entries) e.key: e.value.name},
      'bausteine': [...s.spiel.bausteine],
    };

/// Spielt einen ganzen Abend: Optionen aus [wahl], je Runde zuerst ein
/// Abstecher, jeder Lauf über die Karte ([schritt] treibt die Szene ein Bild
/// weiter), Tischruf abwechselnd, Gruppe gemischt, Anklage abwechselnd richtig.
void _spieleAbend(PartySitzung s, Map<String, String> wahl, void Function() schritt, {required int nr}) {
  var ruf = 0;
  void zug() {
    for (var i = 0; i < 40; i++) {
      final z = s.zug;
      if (z == null) {
        if (s.letzterFund != null) s.fundGelesen();
        return;
      }
      switch (z.phase) {
        case RundenZugPhase.aktion:
          final a = z.aktion;
          var bilder = 0;
          while (s.zug?.phase == RundenZugPhase.aktion && s.zug?.aktion == a) {
            if (++bilder > 30 * 60) throw StateError('Lauf endet nicht: ${z.id}');
            schritt();
          }
        case RundenZugPhase.wurf:
          s.wuerfeln();
        case RundenZugPhase.tischruf:
          s.tischruf((ruf++).isEven ? Tischruf.nochmal : Tischruf.umweg);
        case RundenZugPhase.fund:
          s.fundGelesen();
          return;
      }
    }
    throw StateError('Zug nicht beendet');
  }

  final abgestecht = <int>{};
  for (var i = 0; i < 400; i++) {
    switch (s.phase) {
      case PartyPhase.ende:
        return;
      case PartyPhase.gespraeche:
        for (final g in s.soloGespraeche) {
          s.soloGespraechGelesen(g.id);
        }
        s.weiter();
      case PartyPhase.entscheidungen:
        if (s.zug != null) {
          zug();
          continue;
        }
        final ab = s.abstecherOffen.firstOrNull;
        if (ab != null && abgestecht.add(s.runde)) {
          s.starteAbstecher(ab.id);
          continue;
        }
        final e = s.laufendeEntscheidung;
        if (e == null) {
          s.weiter();
        } else {
          s.schlageVor(wahl[e.id]!);
          s.bestaetigen();
        }
      case PartyPhase.gruppenwahl:
        if (s.offeneWaehler.isEmpty) {
          s.weiter();
        } else {
          final w = s.offeneWaehler.first;
          s.zeigeVerdeckt(w);
          s.stimme(w, kooperativ: (w.length + nr).isEven);
        }
      case PartyPhase.anklage:
        if (s.angeklagt == null) {
          final kern = s.kernverdaechtige;
          s.anklagen(nr.isEven ? s.spiel.pfad : kern[(kern.indexOf(s.spiel.pfad) + 1) % kern.length]);
        }
        s.weiter();
      default:
        s.weiter();
    }
  }
  throw StateError('Abend endet nicht (Phase ${s.phase})');
}

/// Ein Abend mit Klasse [f] im Pfad [pfad], Lauf [nr], über die Karte gespielt.
Map<String, Object?> _abend(KlassenFaehigkeit? f, String pfad, int nr, {int n = 7, bool solo = false}) {
  final s = klassenSitzung(n: n, pfad: pfad, solo: solo, salz: 'klasse:$pfad:$nr', mitAbstecher: true, vorrat: _vorrat());
  final k = karteMit(s, f);
  addTearDown(k.dispose);
  _spieleAbend(s, _folge(pfad, nr), () => k.szenenSchritt(bildDauer), nr: nr);
  return _ergebnis(s);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final pfade = klassenDaten().kanon.pfade;

  group('Ganze Abende mit gesalzenen Würfeln', () {
    for (final pfad in pfade) {
      for (final (nr, n, solo) in [(0, 7, false), (1, 4, false), (2, 7, true)]) {
        test('Pfad $pfad, Lauf $nr (${solo ? 'Solo' : '$n Personen'}): jede Klasse endet wie ohne Klasse', () {
          final ohne = _abend(null, pfad, nr, n: n, solo: solo);
          expect(ohne['wuerfe'], isNotEmpty, reason: 'es wurde gewürfelt');
          expect(ohne['abstecher'], isNotEmpty, reason: 'ein Abstecher gehört dazu');
          for (final f in KlassenFaehigkeit.values) {
            expect(_abend(f, pfad, nr, n: n, solo: solo), equals(ohne), reason: '${f.name} ändert den Abend');
          }
        });
      }
    }

    test('Gegenprobe: der Vergleich sieht eine andere Optionsfolge', () {
      final p = pfade.first;
      expect(_abend(null, p, 0), isNot(equals(_abend(null, p, 1))));
    });
  });

  group('Renderer', () {
    /// Ein Abend in den Entscheidungen mit Klasse [f], dazu der Renderer.
    ({PartySitzung s, PartyKartenSession k, MordakteGame game}) karte(KlassenFaehigkeit? f, {bool solo = false}) {
      final s = klassenSitzung(n: 4, pfad: pfade.first, solo: solo, mitAbstecher: true);
      final k = karteMit(s, f);
      addTearDown(k.dispose);
      final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
      addTearDown(game.dispose);
      _spieleAbend(s, _folge(pfade.first, 0), () => game.update(bildDauer), nr: 0);
      return (s: s, k: k, game: game);
    }

    test('Laufschritt: die frei gesteuerte Figur läuft 1,3-mal so weit, sonst Grundtempo', () {
      double strecke(KlassenFaehigkeit? f) {
        final s = klassenSitzung(n: 4, pfad: pfade.first);
        // Bis in die Entscheidungen ohne laufenden Zug: Die Karte nimmt Eingaben an.
        while (!(s.phase == PartyPhase.entscheidungen && s.zug == null && s.laufendeEntscheidung != null)) {
          if (s.phase == PartyPhase.entscheidungen && s.zug != null) {
            final z = s.zug!;
            switch (z.phase) {
              case RundenZugPhase.aktion:
                s.aktionFertig(z.aktion);
              case RundenZugPhase.wurf:
                s.wuerfeln();
              case RundenZugPhase.tischruf:
                s.tischruf(Tischruf.umweg);
              case RundenZugPhase.fund:
                s.fundGelesen();
            }
          } else {
            s.weiter();
          }
        }
        final k = karteMit(s, f);
        addTearDown(k.dispose);
        final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
        addTearDown(game.dispose);
        // Eine Stelle mit drei Kacheln freier Bahn nach Nordosten (Bildschirm rechts).
        final raster = TileGrid(s.daten.szenario.map);
        const d = 0.7071067811865476;
        final frei = s.kanon.graph.orte.values.firstWhere(
            (o) => raster.canStand(o.x, o.y, Tuning.playerRadius) && raster.freieBahn(o.x, o.y, o.x + 3 * d, o.y - 3 * d, Tuning.playerRadius));
        k.setzeDetektiv(frei.x, frei.y);
        game.update(1 / 60);
        final start = game.eigenePosition;
        // Kurz anlaufen lassen, damit die Trägheit die Messung nicht verzerrt.
        game.stick = const Offset(1, 0);
        for (var i = 0; i < 12; i++) {
          game.update(1 / 60);
        }
        final mitte = game.eigenePosition;
        for (var i = 0; i < 6; i++) {
          game.update(1 / 60);
        }
        expect((mitte - start).distance, greaterThan(0), reason: '${f?.name}: die Figur läuft');
        return (game.eigenePosition - mitte).distance;
      }

      final grund = strecke(null);
      expect(grund, greaterThan(0));
      expect(strecke(KlassenFaehigkeit.laufschritt) / grund, closeTo(1.3, 0.02));
      for (final f in KlassenFaehigkeit.values.where((f) => f != KlassenFaehigkeit.laufschritt)) {
        expect(strecke(f) / grund, closeTo(1, 1e-9), reason: f.name);
      }
    });

    test('jede Klasse zeichnet ohne Fehler, auch mit offenen Hotspots, Randgespräch und Gerüchten', () {
      for (final f in _klassen) {
        for (final solo in [false, true]) {
          final s = klassenSitzung(n: 4, pfad: pfade.first, solo: solo, mitAbstecher: true);
          final k = karteMit(s, f);
          addTearDown(k.dispose);
          final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
          addTearDown(game.dispose);
          void bild() {
            game.update(1 / 60);
            final rec = PictureRecorder();
            game.render(Canvas(rec));
            rec.endRecording().dispose();
          }

          // Auftakt und erste Entscheidung: offene Hotspots, Glanz, Türen.
          var n = 0;
          while (!(s.phase == PartyPhase.entscheidungen && s.zug == null && s.laufendeEntscheidung != null) && n++ < 3000) {
            final z = s.phase == PartyPhase.entscheidungen ? s.zug : null;
            switch (z?.phase) {
              case null:
                for (final g in s.phase == PartyPhase.gespraeche ? s.soloGespraeche : const []) {
                  s.soloGespraechGelesen(g.id);
                }
                s.weiter();
              case RundenZugPhase.aktion:
                bild();
              case RundenZugPhase.wurf:
                s.wuerfeln();
              case RundenZugPhase.tischruf:
                s.tischruf(Tischruf.umweg);
              case RundenZugPhase.fund:
                s.fundGelesen();
            }
          }
          expect(s.laufendeEntscheidung, isNotNull, reason: 'bis zur ersten Entscheidung');
          for (var i = 0; i < 20; i++) {
            bild();
          }
          // Ein Randgespräch, falls möglich: Stimmung und Marker.
          final zeuge = s.karte.figuren.where((z) => s.randgespraechMoeglich(z.id)).firstOrNull;
          if (zeuge != null) {
            expect(s.randgespraechBeginnen(zeuge.id), isTrue);
            for (var i = 0; i < 10; i++) {
              bild();
            }
            s.randgespraechBeenden();
          }
          // Der Detektiv neben jeder Figur: Gerüchte in Hörweite.
          for (final z in s.karte.figuren.take(6)) {
            k.setzeDetektiv(z.x + 0.6, z.y);
            for (var i = 0; i < 30; i++) {
              bild();
            }
          }
          expect(game.eigenePosition, isNotNull, reason: '${f?.name ?? 'ohne Klasse'}${solo ? ', Solo' : ''}');
        }
      }
    });

    test('über den Renderer gespielt: Laufschritt und Spurenblick enden wie ohne Klasse', () {
      final ohne = _ergebnis(karte(null).s);
      expect(_ergebnis(karte(KlassenFaehigkeit.laufschritt).s), equals(ohne));
      expect(_ergebnis(karte(KlassenFaehigkeit.spurenblick).s), equals(ohne));
    });
  });
}
