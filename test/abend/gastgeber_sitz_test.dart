// M3: Der Gastgeber sitzt auf dem Detektiv- oder dem Erzähler-Sitz. Die
// Gastgeber-Sitzung kennt Sitz, Detektiv-Gerät und Vorleser; den Erzähltext
// liest sie über das Fenster des Raums (`erzaehlerAb`), nicht aus dem
// öffentlichen Teil, der ihn nicht mehr trägt. Randgespräche führt der
// Gastgeber nur auf dem Detektiv-Sitz, „Weiter“ nur, wenn er leitet. Die
// Gastansicht zeigt den Erzähltext nur dem Vorleser und den Detektiv am Platz
// des Detektiv-Sitzes. Drei Konstellationen: Host = Erzähler + Gast = Detektiv,
// Host = Detektiv ohne Erzähler, Host = Detektiv + Gast = Erzähler.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/gast_ansicht.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../party_widgets/hilfe.dart' show akteDaten;
import 'online_hilfe.dart';

/// Schlosskeller mit Randgesprächen.
PartyDaten get _daten => akteDaten('schlosskeller');

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();

/// Ein Raum mit Anna (Gastgeberin), Ben (`g1`), Cleo (`g2`) und Dora (`g3`); die
/// Sitze vergibt die Lobby. [erzaehler] und [detektiv] sind Geräte.
SchlosskellerRaum _raum({String detektiv = 'gastgeber', String? erzaehler}) => sitzRaum(detektiv: detektiv, erzaehler: erzaehler);

/// Spielt bis zum Abschnitt [phase] (siehe [spieleBisSitz]).
void _bis(SchlosskellerRaum raum, String phase, {required String detektiv, required String leiter, bool ersteEntscheidung = false}) =>
    spieleBisSitz(raum, phase, detektiv: detektiv, leiter: leiter, ersteEntscheidung: ersteEntscheidung);

Future<void> _warten() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// Die Gastseite von [id] als Widget mit der Ansicht des Raums.
Future<void> _gastSeite(WidgetTester tester, SchlosskellerRaum raum, String id) =>
    zeigeImThema(tester, (context) => gastSeite(context, raum.zustandFuer(id), spieler: id));

void main() {
  final texte = _daten.texte;

  test('Host = Detektiv ohne Erzähler: Sitz, Vorleser, Fenster aus dem Raum, Randgespräche', () async {
    final raum = _raum();
    final s = GastgeberSitzung(SitzDienst(raum));
    expect([s.sitz, s.istDetektiv, s.istVorleser, s.detektivGeraet, s.leitet], [Sitz.detektiv, true, true, 'gastgeber', true]);
    _bis(raum, 'gespraeche', detektiv: 'gastgeber', leiter: 'gastgeber');
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    // Das Erzählerfenster kommt aus dem Raum; der öffentliche Teil trägt keinen Erzähltext.
    expect(s.erzaehler, raum.partieFuerGastgeber!.spiel.bausteine.sublist(raum.erzaehlerAb));
    expect(s.erzaehler, contains('runde.1.start'));
    expect(s.dienst.ansicht.containsKey('erzaehler'), isFalse);
    expect([for (final k in s.erzaehler) texte.baustein(k)], _map(s.dienst.ansicht['privat'])['erzaehler']);
    PartySkript.befragungenErledigen(s);
    await _warten();
    s.weiter();
    await _warten();
    _bis(raum, 'entscheidungen', detektiv: 'gastgeber', leiter: 'gastgeber', ersteEntscheidung: true);
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect(_daten.erzaehlung!.gespraeche.any((g) => s.randgespraechMoeglich(g.figur)), isTrue, reason: 'Der Detektiv spricht Zeugen an');
  });

  test('Host = Erzähler + Gast = Detektiv: kein Randgespräch, keine Ermittlung, der Gastgeber liest und leitet', () async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    final s = GastgeberSitzung(SitzDienst(raum));
    expect([s.sitz, s.istDetektiv, s.istVorleser, s.detektivGeraet, s.detektivKlasse, s.leitet],
        [Sitz.erzaehler, false, true, 'g1', 'profiler', true]);
    expect(s.menschenRollen, hasLength(2), reason: 'Ben ermittelt und spielt keine Figur');
    _bis(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber', ersteEntscheidung: true);
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect(s.phase, PartyPhase.entscheidungen);
    expect(_daten.erzaehlung!.gespraeche.any((g) => s.randgespraechMoeglich(g.figur)), isFalse,
        reason: 'Der Erzähler spricht keine Zeugen an (keine Aufforderung)');
    expect(s.randgespraechBeginnen(_daten.erzaehlung!.gespraeche.first.figur), isFalse);
    // Ermittlung nur vom Detektiv-Sitz: Der Raum lehnt die Anklage des Gastgebers ab.
    s.anklagen('ahmet');
    await _warten();
    expect(s.letzterFehler, 'not_detective');
    s.fehlerQuittieren();
    // Der Gast-Detektiv bekommt das npc-Wissen als Notiz, der Gastgeber liest es vor.
    final notizen = (_map(raum.zustandFuer('g1')['privat'])['erzaehlerNotizen'] as List).cast<String>();
    expect(notizen, [for (final k in s.erzaehlerNotizen) texte.baustein(k)]);
    expect(notizen, isNotEmpty);
  });

  test('Host = Detektiv + Gast = Erzähler: der Gastgeber liest nicht und leitet nur, wenn der Erzähler fehlt', () async {
    final raum = _raum(erzaehler: 'g3');
    final s = GastgeberSitzung(SitzDienst(raum));
    expect([s.sitz, s.istDetektiv, s.istVorleser, s.detektivGeraet, s.leitet], [Sitz.detektiv, true, false, 'gastgeber', false]);
    for (final g in ['g1', 'g2']) {
      raum.nachricht(g, {'typ': 'rollenGelesen'});
    }
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect(s.dienst.ansicht['kannWeiter'], isTrue, reason: 'Der Raum wäre bereit');
    expect(s.kannWeiter, isFalse, reason: 'Weiter drückt der Erzähler');
    // Fällt der Erzähler aus, übernimmt der Gastgeber erst nach der Frist (Plan M3: zwei Minuten).
    final frist = GastgeberSitzung.erzaehlerFrist;
    GastgeberSitzung.erzaehlerFrist = const Duration(milliseconds: 30);
    addTearDown(() => GastgeberSitzung.erzaehlerFrist = frist);
    raum.verbunden('g3', false);
    expect([s.uebernahmeFrist, s.leitet, s.kannWeiter, s.istVorleser], [true, false, false, false], reason: 'Die Frist läuft');
    expect(s.vorleserName, 'Dora', reason: 'Bis dahin steht der getrennte Erzähler da');
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect([s.uebernahmeFrist, s.leitet, s.kannWeiter], [false, true, true], reason: 'Nach der Frist leitet der Gastgeber');
    raum.verbunden('g3', true);
    expect([s.uebernahmeFrist, s.leitet], [false, false], reason: 'Zurück leitet wieder der Erzähler');
    raum.nachricht('g3', {'typ': 'weiter'});
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect(s.phase, PartyPhase.intro);
    // Den Erzähltext hat der Erzähler; der Gastgeber sieht nur, dass vorgelesen wird.
    final host = s.dienst.ansicht;
    expect([host['erzaehlerLiest'], _map(host['privat']).containsKey('erzaehler')], [true, false]);
    expect(_map(raum.zustandFuer('g3')['privat'])['erzaehler'], [for (final k in s.erzaehler) texte.baustein(k)]);
  });

  testWidgets('Gastansicht: Erzähltext nur beim Vorleser, der Detektiv sitzt am Platz des Detektiv-Sitzes', (tester) async {
    // Host = Detektiv + Gast = Erzähler: Dora liest vor, die Rollen hören zu.
    final raum = _raum(erzaehler: 'g3');
    _bis(raum, 'intro', detektiv: 'gastgeber', leiter: 'g3');
    final start = texte.baustein(raum.partieFuerGastgeber!.spiel.bausteine.sublist(raum.erzaehlerAb).first).substring(0, 40);
    await _gastSeite(tester, raum, 'g3');
    expect(find.textContaining(start), findsOneWidget, reason: 'Die Erzählerin liest vor');
    for (final id in ['g1', 'g2']) {
      await _gastSeite(tester, raum, id);
      expect(find.textContaining(start), findsNothing, reason: '$id hört zu');
    }
    // Host = Erzähler + Gast = Detektiv: Ben ermittelt; am Tisch heißt der Detektiv Ben, nicht die Gastgeberin.
    final zwei = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    _bis(zwei, 'intro', detektiv: 'g1', leiter: 'gastgeber');
    await _gastSeite(tester, zwei, 'g1');
    expect(find.textContaining(start), findsNothing, reason: 'Der Gast-Detektiv hört zu');
    final c = GastKontext(
      context: tester.element(find.byType(Scaffold).first),
      dienst: TestGast(zwei.zustandFuer('g2'), spielerId: 'g2'),
      befehl: (_) async {},
      belohnung: null,
    );
    expect(c.personAmTisch(Besetzung.detektiv), 'Ben');
    expect([for (final p in c.spieler) p.sitz], [Sitz.erzaehler, Sitz.detektiv, Sitz.rolle, Sitz.rolle]);
    expect([c.vorleser, c.erzaehlerTexte, c.sitz], [false, isEmpty, Sitz.rolle]);
    final detektiv = GastKontext(
      context: tester.element(find.byType(Scaffold).first),
      dienst: TestGast(zwei.zustandFuer('g1'), spielerId: 'g1'),
      befehl: (_) async {},
      belohnung: null,
    );
    expect([detektiv.sitz, detektiv.dossier, detektiv.vorleser], [Sitz.detektiv, null, false]);
  });
}
