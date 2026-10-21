// F4-BAUMEISTER-08: Titel, Intro, Bonus-Hinweis und Zwischenresümee (Master 7.6 Schritte 1, 4, 5; 7.12).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/bildschirme/resuemee.dart';
import 'package:mordakte/party/bildschirme/titel.dart';
import 'package:mordakte/party/sitzung.dart';

import 'hilfe.dart';

/// Desktop und Telefon, wie im Auftrag.
const _groessen = [Size(1280, 800), Size(390, 844)];

/// Erster Erzählerbaustein mit diesem Präfix, etwa `resuemee.rest.`.
String _baustein(PartySitzung s, String praefix) => s.erzaehler.firstWhere((k) => k.startsWith(praefix));

void main() {
  testWidgets('Titel zeigt Titel und Untertitel aus fall.json', (t) async {
    final s = neueSitzung();
    await t.pumpWidget(rahmen(TitelBildschirm(sitzung: s)));
    expect(find.text(s.kanon.fall['titel'] as String), findsOneWidget);
    expect(find.text(s.kanon.fall['untertitel'] as String), findsOneWidget);
  });

  testWidgets('Titel zeigt den Hinweis, dass der Detektiv wegschaut', (t) async {
    final s = neueSitzung();
    await t.pumpWidget(rahmen(TitelBildschirm(sitzung: s)));
    expect(find.text(s.ui('ui.titel.hinweis')), findsOneWidget);
  });

  testWidgets('Das Kerzenlicht auf dem Titel flackert ohne Fehler', (t) async {
    final s = neueSitzung();
    await t.pumpWidget(rahmen(TitelBildschirm(sitzung: s)));
    await t.pump(const Duration(seconds: 3));
    expect(t.takeException(), isNull);
  });

  testWidgets('Knopf Abend vorbereiten führt zur Einrichtung', (t) async {
    final s = neueSitzung();
    await t.pumpWidget(rahmen(TitelBildschirm(sitzung: s)));
    await t.tap(find.text(s.ui('ui.titel.start')));
    await t.pump();
    expect(s.phase, PartyPhase.einrichtung);
  });

  testWidgets('Intro zeigt jeden Erzählerbaustein wortgleich', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.intro);
    await t.pumpWidget(rahmen(IntroBildschirm(sitzung: s)));
    expect(s.erzaehler, isNotEmpty);
    for (final k in s.erzaehler) {
      expect(find.text(s.text(k)), findsOneWidget, reason: k);
    }
  });

  testWidgets('Weiter im Intro beginnt die erste Runde', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.intro);
    await t.pumpWidget(rahmen(IntroBildschirm(sitzung: s)));
    await t.tap(find.text(s.ui('ui.intro.weiter')));
    await t.pump();
    expect(s.phase, PartyPhase.gespraeche);
    expect(s.runde, 1);
  });

  testWidgets('Bonus zeigt Rahmen und Hinweis', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.bonus, runde: 1);
    await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
    expect(s.erzaehler, hasLength(2));
    for (final k in s.erzaehler) {
      expect(find.text(s.text(k)), findsOneWidget, reason: k);
    }
  });

  testWidgets('Bonus nennt nicht, ob der Hinweis wahr, neutral oder falsch ist', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.bonus, runde: 1);
    await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
    for (final wort in ['wahr', 'falsch', 'neutral']) {
      expect(find.text(wort), findsNothing, reason: wort);
    }
  });

  testWidgets('Resümee zeigt die drei Fächer-Überschriften', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.resuemee, runde: 1);
    await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
    for (final k in ['ui.resuemee.fach_gruppe', 'ui.resuemee.fach_rest', 'ui.resuemee.fach_lage']) {
      expect(find.text(s.ui(k)), findsOneWidget, reason: k);
    }
  });

  testWidgets('Resümee zeigt Gruppe, Rest und Lage in dieser Reihenfolge', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.resuemee, runde: 1);
    await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
    final hoehen = [
      for (final praefix in ['resuemee.gruppe.', 'resuemee.rest.', 'resuemee.lage.'])
        t.getTopLeft(find.text(s.text(_baustein(s, praefix)))).dy,
    ];
    expect(hoehen, orderedEquals([...hoehen]..sort()));
  });

  testWidgets('Resümee nach Runde 1 hat den Knopf Nächste Runde', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.resuemee, runde: 1);
    await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
    expect(find.text(s.ui('ui.resuemee.naechste_runde')), findsOneWidget);
  });

  testWidgets('Resümee nach Runde 3 hat den Knopf Zur Anklage', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.resuemee, runde: 3);
    await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
    expect(find.text(s.ui('ui.resuemee.zur_anklage')), findsOneWidget);
  });

  testWidgets('Weiter im Resümee beginnt die nächste Runde', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.resuemee, runde: 1);
    await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
    await t.tap(find.text(s.ui('ui.resuemee.naechste_runde')));
    await t.pump();
    expect(s.phase, PartyPhase.gespraeche);
    expect(s.runde, 2);
  });

  for (final groesse in _groessen) {
    testWidgets('Alle vier Bildschirme laufen bei ${groesse.width.toInt()} x ${groesse.height.toInt()} ohne Überlauf', (t) async {
      t.view.physicalSize = groesse;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final s = neueSitzung();
      await t.pumpWidget(rahmen(TitelBildschirm(sitzung: s)));
      expect(t.takeException(), isNull, reason: 'Titel');
      spieleBis(s, PartyPhase.intro);
      await t.pumpWidget(rahmen(IntroBildschirm(sitzung: s)));
      expect(t.takeException(), isNull, reason: 'Intro');
      spieleBis(s, PartyPhase.bonus, runde: 1);
      await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
      expect(t.takeException(), isNull, reason: 'Bonus');
      spieleBis(s, PartyPhase.resuemee, runde: 1);
      await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
      expect(t.takeException(), isNull, reason: 'Resümee');
    });
  }
}
