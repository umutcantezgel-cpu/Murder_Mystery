import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

final _erm = Ermittlung(kanon);
final _sim = Simulator(kanon, ermittlung: _erm);

Einstellungen _einstellungen(String pfad) => Einstellungen(rollen: 7, detektiv: 'm', code: FallCode.fuerPfad(pfad, kanon.pfade));

KartenDef _karte(String figur, String slug, KartenArt art, {int ladungen = 1, int wert = 1}) => KartenDef(
  id: 'schlosskeller:$figur:$slug', akte: 'schlosskeller', figur: figur, seltenheit: Seltenheit.gewoehnlich,
  art: art, ladungen: ladungen, wert: wert, titel: slug, text: slug, quellen: const [KartenQuelle('start')],
);

/// Drei Pools: je höchstens drei Karten und vier Ladungen (Grenzen von TischVorrat), zusammen alle Arten.
final _pools = <List<KartenDef>>[
  [_karte('ahmet', 'g', KartenArt.gruendlich), _karte('can', 'w', KartenArt.werkzeug), _karte('fatma', 'z', KartenArt.zeit, ladungen: 2, wert: 3)],
  [_karte('ahmet', 'n', KartenArt.nochmal), _karte('can', 'u', KartenArt.umweg), _karte('fatma', 'm', KartenArt.marke)],
  [_karte('ahmet', 'a', KartenArt.abstecher, ladungen: 2), _karte('can', 'n2', KartenArt.nochmal), _karte('fatma', 'z2', KartenArt.zeit, wert: 4)],
];

/// Zufällige, aber feste Optionsfolge (eine Option je Entscheidung, Kanon-Reihenfolge).
List<String> _zufaelligeFolge(String pfad, int nr) {
  final rng = Rng(Rng.hashString('invarianz:$pfad:$nr'));
  return [for (final e in _erm.entscheidungen) e.optionen[rng.nextInt(e.optionen.length)].id];
}

class _Lauf {
  _Lauf(this.partie, this.gespielt);
  final RundenPartie partie;

  /// Art jeder ausgespielten Karte, in Reihenfolge.
  final List<KartenArt> gespielt;
}

/// Spielt einen Abend vollständig. Karten werden gespielt, sobald sie legal sind; offene
/// Abstecher werden zwischen den Entscheidungen besucht. Ohne Pool und Orte ist es der reine Abend.
_Lauf _spiele(String pfad, List<String> folge, WuerfelQuelle quelle,
    {List<KartenDef> pool = const [], List<AbstecherOrt> orte = const []}) {
  final vorrat = TischVorrat.aus([for (final k in pool) k.id], KartenKatalog(pool));
  final p = RundenPartie(kanon, quelle: quelle, ermittlung: _erm, vorrat: vorrat, abstecher: orte)
    ..einrichten(_einstellungen(pfad));
  final ids = {for (final k in vorrat.karten) k.art: k.id};
  final gespielt = <KartenArt>[];
  final zeitRunden = <int>{};
  var index = 0;
  var schritte = 0;

  bool verfuegbar(KartenArt art) => ids[art] != null && vorrat.verfuegbar(ids[art]!);
  String nimm(KartenArt art) {
    gespielt.add(art);
    return ids[art]!;
  }

  void zugSchritt() {
    if (++schritte > 5000) fail('Sackgasse in $pfad bei ${p.zug?.id}');
    final z = p.zug!;
    switch (z.phase) {
      case RundenZugPhase.aktion:
        expect(p.aktionFertig(z.aktion), isTrue);
      case RundenZugPhase.wurf:
        final werk = !z.istAuftakt && verfuegbar(KartenArt.werkzeug) ? nimm(KartenArt.werkzeug) : null;
        p.wuerfeln(karte: werk, marke: p.marken > 0);
      case RundenZugPhase.tischruf:
        if (verfuegbar(KartenArt.nochmal)) {
          p.tischruf(Tischruf.nochmal, karte: nimm(KartenArt.nochmal));
        } else if (verfuegbar(KartenArt.umweg)) {
          p.tischruf(Tischruf.umweg, karte: nimm(KartenArt.umweg));
        } else {
          p.tischruf(z.aktion.isEven ? Tischruf.nochmal : Tischruf.umweg);
        }
      case RundenZugPhase.fund:
        p.fundGelesen();
    }
  }

  /// Sofortkarten (Zeit einmal je Runde, Marke) und alle offenen Abstecher, vor jeder Wahl.
  void vorEntscheidung() {
    if (verfuegbar(KartenArt.zeit) && !zeitRunden.contains(p.runde)) {
      zeitRunden.add(p.runde);
      p.karteSpielen(nimm(KartenArt.zeit));
    }
    if (verfuegbar(KartenArt.marke)) p.karteSpielen(nimm(KartenArt.marke));
    while (p.abstecherOffen.isNotEmpty) {
      final ort = p.abstecherOffen.first;
      p.starteAbstecher(ort.id, karte: verfuegbar(KartenArt.abstecher) ? nimm(KartenArt.abstecher) : null);
      while (p.zug != null) {
        zugSchritt();
      }
    }
  }

  while (p.phase != PartyPhase.ende) {
    if (++schritte > 5000) fail('Sackgasse in $pfad, Phase ${p.phase}');
    if (p.zug != null) {
      zugSchritt();
      continue;
    }
    if (p.phase == PartyPhase.entscheidungen) {
      vorEntscheidung();
      if (p.zug != null) continue;
    }
    final e = p.naechsteEntscheidung;
    if (e != null) {
      final option = folge[index++];
      if (istSuche(e) && verfuegbar(KartenArt.gruendlich)) {
        p.waehle(option, gruendlich: true, karte: nimm(KartenArt.gruendlich));
      } else {
        p.waehle(option);
      }
    } else if (p.phase == PartyPhase.gruppenwahl) {
      p.abstimmen(kooperativ: 6, taeterSabotiert: false);
      p.weiter();
    } else if (p.phase == PartyPhase.anklage) {
      p.anklagen(pfad);
      p.weiter();
    } else {
      p.weiter();
    }
  }
  expect(index, folge.length);
  return _Lauf(p, gespielt);
}

/// Fakten, Punkte, Ende und Restmenge müssen dem reinen Kanon-Simulator entsprechen.
void _erwarteWie(_Lauf l, String pfad, List<String> folge, Verlauf soll) {
  final s = l.partie.spiel;
  expect(s.punkte, soll.punkte, reason: '$pfad $folge');
  expect(s.bekannteFakten(), soll.fakten, reason: '$pfad $folge');
  expect(s.restmenge(), soll.rest, reason: '$pfad $folge');
  expect(s.ende.id, _sim.enden.ende(soll.punkte, true).id, reason: '$pfad $folge');
  expect(s.gewaehlt.values.toList(), folge, reason: '$pfad $folge');
  expect(l.partie.abstecherFunde, {for (final e in l.partie.abstecherErgebnis.entries) if (e.value != Stufe.pech) e.key});
}

void main() {
  final orte = [
    AbstecherOrt(id: 'flur', ort: kanon.graph.orte.keys.first, name: 'Flur', erfolg: 'Ein Knopf.', teilerfolg: 'Ein Faden.', pech: 'Nichts.'),
    AbstecherOrt(id: 'vitrine', ort: kanon.graph.orte.keys.elementAt(1), name: 'Vitrine', erfolg: 'Ein Kamm.',
        teilerfolg: 'Staub.', pech: 'Leer.', abRunde: 2),
  ];

  test('Karten und Abstecher ändern Fakten, Punkte und Ende nie (alle Pfade, Folgen, Würfelströme)', () {
    final gespielt = <KartenArt>{};
    var besuche = 0;
    var wuerfelVerschieden = 0;
    for (final pfad in kanon.pfade) {
      final folgen = [
        [for (final e in _erm.entscheidungen) e.richtig[pfad]!],
        for (var nr = 0; nr < 40; nr++) _zufaelligeFolge(pfad, nr),
      ];
      for (var nr = 0; nr < folgen.length; nr++) {
        final folge = folgen[nr];
        final quellen = <WuerfelQuelle>[SalzWuerfel('invarianz:$pfad:$nr'), const FesterWuerfel.pech(), const FesterWuerfel.erfolg()];
        for (final quelle in quellen) {
          final soll = _sim.verlauf(pfad, folge);
          final ohne = _spiele(pfad, folge, quelle);
          _erwarteWie(ohne, pfad, folge, soll);
          final abstecher = _spiele(pfad, folge, quelle, orte: orte);
          _erwarteWie(abstecher, pfad, folge, soll);
          besuche += abstecher.partie.abstecherErgebnis.length;
          for (final pool in _pools) {
            final mit = _spiele(pfad, folge, quelle, pool: pool, orte: orte);
            _erwarteWie(mit, pfad, folge, soll);
            expect(mit.partie.spiel.punkte, ohne.partie.spiel.punkte);
            expect(mit.partie.spiel.ende.id, ohne.partie.spiel.ende.id);
            expect(mit.partie.spiel.bekannteFakten(), ohne.partie.spiel.bekannteFakten());
            gespielt.addAll(mit.gespielt);
            besuche += mit.partie.abstecherErgebnis.length;
            final ohneProtokoll = [for (final w in ohne.partie.wuerfe) w.zeile];
            if ([for (final w in mit.partie.wuerfe) w.zeile].join(';') != ohneProtokoll.join(';')) wuerfelVerschieden++;
          }
        }
      }
    }
    // Die Karten wirken wirklich (Würfel, Kosten), ohne je Fakten oder Wertung zu ändern.
    expect(gespielt, containsAll([KartenArt.gruendlich, KartenArt.werkzeug, KartenArt.zeit, KartenArt.nochmal,
      KartenArt.umweg, KartenArt.marke, KartenArt.abstecher]));
    expect(besuche, greaterThan(0));
    expect(wuerfelVerschieden, greaterThan(0));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('Erkundung: Pech bringt keinen Fund, Erfolg bringt Fund', () {
    final pfad = kanon.pfade.first;
    final folge = [for (final e in _erm.entscheidungen) e.richtig[pfad]!];
    final pech = _spiele(pfad, folge, const FesterWuerfel.pech(), orte: orte).partie;
    expect(pech.abstecherErgebnis.isNotEmpty, isTrue);
    expect(pech.abstecherErgebnis.values.toSet(), {Stufe.pech});
    expect(pech.abstecherFunde, isEmpty);
    final erfolg = _spiele(pfad, folge, const FesterWuerfel.erfolg(), orte: orte).partie;
    expect(erfolg.abstecherErgebnis.isNotEmpty, isTrue);
    expect(erfolg.abstecherFunde, erfolg.abstecherErgebnis.keys.toSet());
    expect(erfolg.spiel.ende.id, 'ende_meister');
  });
}
