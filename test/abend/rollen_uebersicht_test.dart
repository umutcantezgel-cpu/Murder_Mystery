// Langer Abend M3b: „Wer macht was“. Für Detektiv, Erzähler, Rolle und
// Assistenz gibt es je Spielweise (allein, ein Gerät, eigene Geräte) in jedem
// Abschnitt eine aktive Aufgabe, höchstens acht Wörter (R17). Solo gibt es nur
// den Detektiv, an einem Gerät keine Assistenz.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/einrichtung/abend_neu_seite.dart' show Spielweise;
import 'package:mordakte/abend/rollen_uebersicht.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte_core/runden.dart' show Sitz;

import 'online_hilfe.dart';

final l = LDe();

void main() {
  test('Sitzzeitplan: jeder Sitz hat in jedem Abschnitt eine Aufgabe von höchstens acht Wörtern', () {
    expect(sitzeBei(Spielweise.solo), [Sitz.detektiv]);
    expect(sitzeBei(Spielweise.reihum), isNot(contains(Sitz.assistenz)));
    expect(sitzeBei(Spielweise.eigene), Sitz.values);
    for (final w in Spielweise.values) {
      for (final s in sitzeBei(w)) {
        for (final p in UebersichtPhase.values) {
          final a = aufgabe(l, w, s, p);
          expect(a.trim(), isNotEmpty, reason: '$w $s $p');
          expect(a.split(RegExp(r'\s+')).length, lessThanOrEqualTo(8), reason: '$w $s $p: „$a“');
        }
      }
    }
    // Reihum liest der Erzähler am verdeckten Pult, online nicht.
    expect(aufgabe(l, Spielweise.reihum, Sitz.erzaehler, UebersichtPhase.intro), l.aufgabe_erzaehler_reihum);
    expect(aufgabe(l, Spielweise.eigene, Sitz.erzaehler, UebersichtPhase.intro), l.aufgabe_erzaehler_intro);
  });

  testWidgets('Übersicht: eigener Sitz oben und offen, Spielweise umschaltbar, ohne Überlauf', (tester) async {
    for (final (groesse, schrift) in const [(Size(320, 640), 2.0), (Size(390, 844), 1.0)]) {
      await zeigeImThema(
        tester,
        (c) => Scaffold(body: Center(child: Builder(builder: (c) => RollenUebersichtKnopf(hervorheben: Sitz.erzaehler)))),
        groesse: groesse,
        schrift: schrift,
      );
      await tester.tap(find.byKey(const ValueKey('wer-macht-was')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('rollen-uebersicht')), findsOneWidget);
      expect(tester.getTopLeft(find.byKey(const ValueKey('uebersicht-erzaehler'))).dy,
          lessThan(tester.getTopLeft(find.byKey(const ValueKey('uebersicht-detektiv'))).dy));
      expect(find.text(l.aufgabe_erzaehler_intro), findsOneWidget, reason: 'Der eigene Sitz ist offen');
      expect(find.byKey(const ValueKey('uebersicht-assistenz')), findsOneWidget);
      await tester.tap(find.text(l.uebersicht_weise_solo));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('uebersicht-assistenz')), findsNothing);
      expect(find.byKey(const ValueKey('uebersicht-erzaehler')), findsNothing, reason: 'Solo ohne Erzähler');
      expect(tester.takeException(), isNull, reason: '$groesse');
    }
  });

  testWidgets('Einstimmung (A-063): nur bei Abenden mit Vorgeschichte und Vorstellung ein eigener Abschnitt', (tester) async {
    expect(uebersichtPhasen(), isNot(contains(UebersichtPhase.einstimmung)));
    expect(uebersichtPhasen(mitEinstimmung: true), UebersichtPhase.values);
    expect(aufgabe(l, Spielweise.reihum, Sitz.erzaehler, UebersichtPhase.einstimmung), l.aufgabe_erzaehler_reihum, reason: 'Reihum am Pult');
    expect(aufgabe(l, Spielweise.eigene, Sitz.erzaehler, UebersichtPhase.einstimmung), l.aufgabe_erzaehler_einstimmung);
    for (final mit in [false, true]) {
      await zeigeImThema(
        tester,
        (c) => Scaffold(body: Center(child: Builder(builder: (c) => RollenUebersichtKnopf(hervorheben: Sitz.rolle, mitEinstimmung: mit)))),
      );
      await tester.tap(find.byKey(const ValueKey('wer-macht-was')));
      await tester.pumpAndSettle();
      expect(find.text(l.uebersicht_phase_einstimmung.toUpperCase()), mit ? findsOneWidget : findsNothing, reason: '$mit');
      expect(find.text(l.aufgabe_rolle_einstimmung), mit ? findsOneWidget : findsNothing, reason: '$mit');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('Altakten (ohne Erzähler-Sitz): kein Erzähler-Platz, der Detektiv heißt wie in der Akte', (tester) async {
    expect(sitzeBei(Spielweise.reihum, mitErzaehler: false), [Sitz.detektiv, Sitz.rolle]);
    expect(sitzeBei(Spielweise.eigene, mitErzaehler: false), [Sitz.detektiv, Sitz.rolle, Sitz.assistenz]);
    await zeigeImThema(
      tester,
      (c) => Scaffold(
        body: Center(
          child: Builder(builder: (c) => const RollenUebersichtKnopf(weise: Spielweise.reihum, mitErzaehler: false, detektivWort: 'Inspektor')),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('wer-macht-was')));
    await tester.pumpAndSettle();
    for (final weise in [l.uebersicht_weise_reihum, l.uebersicht_weise_online]) {
      await tester.tap(find.text(weise));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('uebersicht-erzaehler')), findsNothing, reason: weise);
      expect(find.text('Inspektor'), findsOneWidget, reason: weise);
      expect(find.text(l.uebersicht_sitz_detektiv), findsNothing, reason: weise);
    }
  });
}
