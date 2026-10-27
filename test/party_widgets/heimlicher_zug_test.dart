// Der heimliche Zug (Finale §3.2): Raster der sechs Zugarten, Zielwahl mit
// Fotoabzügen, „Ich selbst“ beim Decken, Tipp in Runde drei und „Das ist mein
// Zug“. Bei 320 und 390 Pixel Breite, mit normaler und doppelter Schrift: kein
// Überlauf, jede Kachel und jedes Ziel erreichbar.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/moment.dart';
import 'package:mordakte/party/einfluss_sicht.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/stil/stil.dart' show MKnopf;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'einfluss_hilfe.dart';
import 'hilfe.dart';

Future<void> _zeigen(WidgetTester t, Widget kind, double breite, double schrift) async {
  t.view.physicalSize = Size(breite, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(
    theme: ThemeData.dark(),
    builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(schrift)), child: child!),
    home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: kind)),
  ));
  await t.pump();
}

Future<void> _tippe(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.pump();
  await t.tap(f);
  await t.pump();
}

/// Moment von [rolle] in den Gesprächen von [runde] (verdeckt geöffnet).
(PartySitzung, MomentSicht) _moment(String rolle, {int runde = 1}) {
  final s = einflussSitzung(rollen: 5);
  einflussBis(s, PartyPhase.gespraeche, runde: runde);
  s.momentZeigen(rolle);
  return (s, s.momentSicht(rolle));
}

void main() {
  setUpAll(echteSchriften);

  for (final breite in [320.0, 390.0]) {
    for (final schrift in [1.0, 2.0]) {
      testWidgets('Raster und Zielwahl bei $breite px, Schrift ${schrift * 100} %', (t) async {
        final (s, m) = _moment('fatma');
        ({ZugArt art, String? ziel, String? tipp})? gezogen;
        await _zeigen(
          t,
          HeimlicherZug(moment: m, rolle: 'fatma', darstellung: EinflussDarstellung.sitzung(s), onZug: (a, z, tipp) => gezogen = (art: a, ziel: z, tipp: tipp)),
          breite,
          schrift,
        );
        // Sechs Kacheln mit Titel; ohne Wahl ruht der Knopf.
        for (final a in ZugArt.waehlbar) {
          expect(find.byKey(ValueKey('zug-${a.name}')), findsOneWidget);
          expect(find.text(s.text('einfluss.zug.${a.name}.titel')), findsOneWidget);
        }
        expect(t.widget<MKnopf>(find.byKey(const ValueKey('moment-bestaetigen'))).onPressed, isNull);
        // Zeigen braucht ein Ziel: die anderen besetzten Figuren, nie sie selbst.
        await _tippe(t, find.byKey(const ValueKey('zug-zeigen')));
        expect(find.text(s.text('einfluss.zug.zeigen.wahl')), findsOneWidget);
        expect(find.byKey(const ValueKey('ziel-fatma')), findsNothing);
        for (final r in s.besetzt.where((r) => r != 'fatma')) {
          expect(find.byKey(ValueKey('ziel-$r')), findsOneWidget);
        }
        expect(t.widget<MKnopf>(find.byKey(const ValueKey('moment-bestaetigen'))).onPressed, isNull);
        await _tippe(t, find.byKey(const ValueKey('ziel-olli')));
        await _tippe(t, find.byKey(const ValueKey('moment-bestaetigen')));
        expect(gezogen, (art: ZugArt.zeigen, ziel: 'olli', tipp: null));
        // Decken auch auf sich selbst: „Ich selbst“.
        await _tippe(t, find.byKey(const ValueKey('zug-decken')));
        expect(find.byKey(const ValueKey('ziel-fatma')), findsOneWidget);
        expect(find.text(momentTexte(t.element(find.byType(HeimlicherZug))).moment_ich_selbst), findsOneWidget);
        await _tippe(t, find.byKey(const ValueKey('ziel-fatma')));
        await _tippe(t, find.byKey(const ValueKey('moment-bestaetigen')));
        expect(gezogen, (art: ZugArt.decken, ziel: 'fatma', tipp: null));
        // Helfen hat kein Ziel.
        await _tippe(t, find.byKey(const ValueKey('zug-helfen')));
        expect(find.text(s.text('einfluss.zug.zeigen.wahl')), findsNothing);
        await _tippe(t, find.byKey(const ValueKey('moment-bestaetigen')));
        expect(gezogen, (art: ZugArt.helfen, ziel: null, tipp: null));
        // Bei zwei Spalten liegen Zeigen und Decken nebeneinander, bei einer untereinander.
        final zeigen = t.getTopLeft(find.byKey(const ValueKey('zug-zeigen')));
        final decken = t.getTopLeft(find.byKey(const ValueKey('zug-decken')));
        expect(zeigen.dy == decken.dy, schrift == 1.0, reason: 'zwei Spalten nur bei normaler Schrift');
      });

      testWidgets('Tipp in Runde 3 bei $breite px, Schrift ${schrift * 100} %', (t) async {
        final (s, m) = _moment('olli', runde: 3);
        expect(m.tipps, [...s.kernverdaechtige, tippKeiner]);
        ({ZugArt art, String? ziel, String? tipp})? gezogen;
        await _zeigen(
          t,
          HeimlicherZug(moment: m, rolle: 'olli', darstellung: EinflussDarstellung.sitzung(s), onZug: (a, z, tipp) => gezogen = (art: a, ziel: z, tipp: tipp)),
          breite,
          schrift,
        );
        expect(find.text(s.text('einfluss.tipp.wahl')), findsOneWidget);
        await _tippe(t, find.byKey(const ValueKey('zug-helfen')));
        // Ohne Tipp ruht der Knopf.
        expect(t.widget<MKnopf>(find.byKey(const ValueKey('moment-bestaetigen'))).onPressed, isNull);
        await _tippe(t, find.byKey(const ValueKey('tipp-keiner')));
        await _tippe(t, find.byKey(const ValueKey('moment-bestaetigen')));
        expect(gezogen, (art: ZugArt.helfen, ziel: null, tipp: tippKeiner));
      });
    }
  }

  testWidgets('Ein Einmal-Zug ist ausgegraut und lässt sich nicht wählen', (t) async {
    final s = einflussSitzung(rollen: 5);
    einflussBis(s, PartyPhase.gespraeche);
    alleZiehen(s, plan: (s, r) => r == 'leyla' ? (art: ZugArt.auspacken, ziel: null, tipp: null) : planZug(s, r));
    einflussBis(s, PartyPhase.gespraeche, runde: 2);
    s.momentZeigen('leyla');
    final m = s.momentSicht('leyla');
    await _zeigen(t, HeimlicherZug(moment: m, rolle: 'leyla', darstellung: EinflussDarstellung.sitzung(s), onZug: (_, _, _) {}), 390, 1);
    final l = momentTexte(t.element(find.byType(HeimlicherZug)));
    expect(find.text(l.moment_einmal), findsOneWidget);
    await _tippe(t, find.byKey(const ValueKey('zug-auspacken')));
    expect(t.widget<MKnopf>(find.byKey(const ValueKey('moment-bestaetigen'))).onPressed, isNull);
    // „Wie letzte Runde“ fehlt: Auspacken geht nur einmal.
    expect(find.byKey(const ValueKey('moment-wie-letzte')), findsNothing);
  });
}
