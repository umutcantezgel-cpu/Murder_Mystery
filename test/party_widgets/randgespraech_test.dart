// M6: Randgespräche mit Zeugen auf der Karte und das Nachspiel. Ein Gespräch
// kostet keine Zeit, würfelt nicht und schreibt nie in die Wertung
// (ERZAEHLREGELN.md R1–R12); nur unbesetzte Zeugen lassen sich ansprechen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte/l10n/gen/app_localizations.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/aufloesung.dart';
import 'package:mordakte/game/szenen_erweiterung.dart';
import 'package:mordakte/party/bildschirme/gespraech_szene.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte/party/sitzung.dart';

import 'hilfe.dart';

final _de = LDe();

/// Ravensmoor mit vier Rollen: Gärtner, Köchin, Zofe und Anwalt bleiben Zeugen.
PartySitzung _sitzung({String akte = 'ravensmoor', String pfad = 'butler', int rollen = 4}) {
  final s = PartySitzung(akteDaten(akte), wuerfel: const FesterWuerfel.neutral());
  s.einrichten(rollen: rollen, detektiv: 'w', code: FallCode.fuerPfad(pfad, s.kanon.pfade).code);
  spieleBis(s, PartyPhase.entscheidungen, runde: 1);
  return s;
}

/// Ein ganzer Abend mit festen Optionen (je Entscheidung die erste): zu Beginn
/// jeder Runde, was an den Figuren steht, und alle Gespräche, die sich dann
/// führen lassen (je Schritt die erste Wahl ohne Vorlegen).
List<Object> _gespraechsVerlauf(String akte, String pfad) {
  final s = _sitzung(akte: akte, pfad: pfad);
  final karte = PartyKartenSession(s);
  final protokoll = <Object>[];
  for (var r = 1; r <= 3; r++) {
    spieleBis(s, PartyPhase.entscheidungen, runde: r);
    final npcs = [for (final f in s.karte.figuren) s.daten.npcKennung[f.id]!];
    protokoll.add({for (final n in npcs) n: karte.npcAktion(n)});
    for (final f in s.karte.figuren) {
      if (!s.randgespraechBeginnen(f.id)) continue;
      while (!s.gespraech!.fertig) {
        s.randgespraechWaehlen(s.gespraech!.wahlen.firstWhere((w) => w.haltung != Haltung.vorlegen));
      }
      protokoll.add([f.id, for (final v in s.gespraech!.verlauf) v.figur]);
      s.randgespraechBeenden();
    }
    protokoll.add(s.erzaehlFlags.toList()..sort());
    for (var i = 0; i < 3; i++) {
      s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
      s.bestaetigen();
      spieleZug(s);
    }
  }
  karte.dispose();
  return protokoll;
}

/// Was ein Gespräch nie berühren darf.
Object _stand(PartySitzung s) => (
      s.restMinuten,
      s.reserveMinuten,
      s.marken,
      s.wuerfe.length,
      s.spiel.punkte,
      s.funde.values.fold(0, (a, f) => a + f.length),
      s.laufendeEntscheidung?.id,
      s.runde,
    );

Widget _bild(Widget kind, {bool rollen = true}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('de'),
      // Ruhig: die Schreibmaschine zeigt die Zeile sofort ganz.
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
      home: Scaffold(body: rollen ? SingleChildScrollView(child: kind) : kind),
    );

void main() {
  test('nur unbesetzte Zeugen, nur zwischen zwei Zügen', () {
    final s = _sitzung();
    expect(s.daten.erzaehlung, isNotNull);
    for (final kern in s.besetzt) {
      expect(s.randgespraechMoeglich(kern), isFalse, reason: kern);
    }
    expect(s.randgespraechMoeglich('gaertner'), isTrue);
    s.erzaehltiefe = Erzaehltiefe.aus;
    expect(s.randgespraechMoeglich('gaertner'), isFalse);
    s.erzaehltiefe = Erzaehltiefe.voll;
    s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
    expect(s.randgespraechMoeglich('gaertner'), isFalse, reason: 'Vorschlag offen');
  });

  for (final akte in ['ravensmoor', 'schlosskeller']) {
    test('$akte: Zeugen, Gespräche und Flags sind in allen Pfaden gleich (R1)', () {
      final pfade = akteDaten(akte).kanon.pfade;
      final erster = _gespraechsVerlauf(akte, pfade.first);
      expect(erster.whereType<List>().where((e) => e.isNotEmpty && e.first is String && e.length > 1), isNotEmpty, reason: 'Gespräche geführt');
      for (final p in pfade.skip(1)) {
        expect(_gespraechsVerlauf(akte, p), erster, reason: p);
      }
    });
  }

  test('Gespräch: kein Würfel, keine Zeit, keine Wertung; Flags gelten danach', () {
    final s = _sitzung();
    final vorher = _stand(s);
    expect(s.randgespraechBeginnen('gaertner'), isTrue);
    expect(s.randgespraechMoeglich('koechin'), isFalse, reason: 'ein Gespräch zur Zeit');
    while (!s.gespraech!.fertig) {
      s.randgespraechWaehlen(s.gespraech!.wahlen.first);
    }
    final flags = s.gespraech!.neueFlags.toSet();
    expect(s.erzaehlFlags, isEmpty, reason: 'erst nach dem Ende');
    s.randgespraechBeenden();
    expect(s.gespraech, isNull);
    expect(s.erzaehlFlags, flags);
    expect(_stand(s), vorher);
    // Das erste Gespräch ist geführt; es kommt nicht wieder.
    expect(s.daten.erzaehlung!.offenFuer('gaertner', ErzaehlUmwelt(runde: 1, flags: s.erzaehlFlags), gefuehrt: {'silas_erstes'})?.id,
        isNot('silas_erstes'));
  });

  test('Karte: Ansprechen am Zeugen, Eingabe gesperrt, die Figur spielt die Zeile', () {
    final s = _sitzung();
    final karte = PartyKartenSession(s);
    final npc = s.daten.npcKennung['gaertner']!;
    expect(karte.npcAktion(npc), _de.gespraech_ansprechen);
    expect(karte.gespraechsGeste, isNull);
    s.randgespraechBeginnen('gaertner');
    expect(karte.eingabeGesperrt, isTrue);
    expect(karte.npcAktion(npc), isNull);
    expect(karte.figurenPose, SzenenPose.befragen);
    expect(karte.gespraechsGeste, (npc: npc, geste: SzenenGeste.nachdenken));
    s.randgespraechWaehlen(s.gespraech!.wahlen.firstWhere((w) => w.haltung == Haltung.bluffen));
    expect(karte.gespraechsGeste?.geste, SzenenGeste.abwehr);
    s.randgespraechBeenden();
    expect(karte.gespraechsGeste, isNull);
    expect(karte.eingabeGesperrt, isFalse);
  });

  testWidgets('Vernehmungsprotokoll: Zeile, Haltungen, eigener Satz, Ende', (tester) async {
    final s = _sitzung();
    s.randgespraechBeginnen('gaertner');
    await tester.pumpWidget(_bild(ListenableBuilder(listenable: s, builder: (_, _) => GespraechsSzene(sitzung: s))));
    await tester.pump();
    final lauf = s.gespraech!;
    expect(find.text(_de.gespraech_marke), findsOneWidget);
    expect(find.text(s.figurName('gaertner')), findsWidgets);
    expect(find.text(lauf.knoten.text, findRichText: true), findsOneWidget);
    for (final w in lauf.wahlen) {
      expect(find.text(w.text), findsOneWidget);
    }
    final erste = lauf.wahlen.first;
    await tester.tap(find.text(erste.text));
    await tester.pump();
    expect(find.text('${_de.gespraech_ich}: ${erste.text}'), findsOneWidget);
    expect(find.text(s.gespraech!.knoten.text, findRichText: true), findsOneWidget);
    while (!s.gespraech!.fertig) {
      await tester.tap(find.text(s.gespraech!.wahlen.first.text));
      await tester.pump();
    }
    expect(find.text(_de.gespraech_beenden), findsOneWidget);
    await tester.tap(find.text(_de.gespraech_beenden));
    await tester.pump();
    expect(s.gespraech, isNull);
    expect(find.byKey(const ValueKey('randgespraech')), findsNothing);
  });

  testWidgets('Nachspiel in der Auflösung nur nach Gesprächen', (tester) async {
    final ohne = _sitzung();
    spieleBis(ohne, PartyPhase.aufloesung);
    expect(ohne.nachspiel.where((e) => e.figur == 'gaertner'), isEmpty);

    final s = _sitzung();
    s.randgespraechBeginnen('gaertner');
    while (!s.gespraech!.fertig) {
      s.randgespraechWaehlen(s.gespraech!.wahlen.first);
    }
    s.randgespraechBeenden();
    spieleBis(s, PartyPhase.aufloesung);
    final satz = s.nachspiel.firstWhere((e) => e.figur == 'gaertner');
    await tester.pumpWidget(_bild(AufloesungBildschirm(sitzung: s), rollen: false));
    await tester.pump();
    expect(find.text(_de.nachspiel_titel), findsOneWidget);
    expect(find.text(satz.text), findsOneWidget);
  });
}
