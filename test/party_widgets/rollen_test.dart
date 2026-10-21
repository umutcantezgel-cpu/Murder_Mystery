// F4-BAUMEISTER-02: Verdeckte Rollenvergabe und Dossier (Master 7.6 Schritt 3, 7.11).
// Jeder Test prüft eine Sache. Die Sitzung hat 7 Rollen; die Täterin ist Fatma.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte/party/bildschirme/rollen.dart';
import 'package:mordakte/party/party_stil.dart';
import 'package:mordakte/party/sitzung.dart';

import 'hilfe.dart';

/// Sitzung mit 7 Rollen; die Täterin ist Fatma (Pfad 'fatma').
PartySitzung _sitzung() => neueSitzung(rollen: 7, pfad: 'fatma');

/// Die Rohtexte der Textsammlung (unabhängig vom Pfad).
Textsammlung get _sammlung => partyDaten.texte.sammlung;

/// Bildschirm im Rahmen, in einem festen Fenster.
Future<void> _zeige(WidgetTester t, PartySitzung s, {Size groesse = const Size(1280, 800)}) async {
  t.view.physicalSize = groesse;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(RollenBildschirm(sitzung: s)));
}

/// Scrollt bei Bedarf zum Fund und tippt darauf.
Future<void> _tippe(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pump();
}

/// Die offene Karte über den Knopf am Fuß zudecken.
Future<void> _schliesse(WidgetTester t, PartySitzung s) => _tippe(t, find.text(s.ui('ui.verdeckt.schliessen')));

void main() {
  testWidgets('neutrale Ansicht nennt alle Spielernamen und keinen Dossiertext', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    expect(s.besetzt, hasLength(7));
    for (final r in s.besetzt) {
      expect(find.text(s.spielerName(r)), findsOneWidget, reason: r);
      expect(find.text(_sammlung.dossiers[r]!.wer), findsNothing, reason: r);
    }
  });

  testWidgets('Tippen auf einen Namen zeigt die Zwischenstufe, die Karte bleibt zu', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    final name = s.spielerName('emine');
    await _tippe(t, find.text(name));
    expect(find.text(s.ui('ui.verdeckt.weitergeben', {'name': name})), findsOneWidget);
    expect(find.text(s.ui('ui.verdeckt.frage', {'name': name})), findsOneWidget);
    expect(s.verdeckt, isNull);
    expect(find.text(_sammlung.dossiers['emine']!.wer), findsNothing);
  });

  testWidgets('der Knopf der Zwischenstufe öffnet die verdeckte Ansicht dieser Rolle', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    final name = s.spielerName('emine');
    await _tippe(t, find.text(name));
    await _tippe(t, find.text(s.ui('ui.verdeckt.frage', {'name': name})));
    expect(s.verdeckt, 'emine');
  });

  testWidgets('Zurück in der Zwischenstufe zeigt wieder die Liste', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    final name = s.spielerName('emine');
    await _tippe(t, find.text(name));
    await _tippe(t, find.text(s.ui('ui.allgemein.zurueck')));
    expect(find.text(name), findsOneWidget);
    expect(s.verdeckt, isNull);
  });

  testWidgets('das Dossier zeigt den wer-Text der Rolle', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    s.zeigeVerdeckt('emine');
    await t.pump();
    expect(find.text(_sammlung.dossiers['emine']!.wer), findsOneWidget);
  });

  testWidgets('die Täterin liest unter „Was ich verberge“, dass sie es war, und ihre Tarngeschichte', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    s.zeigeVerdeckt('fatma');
    await t.pump();
    expect(s.istTaeter('fatma'), isTrue);
    expect(find.text(s.ui('ui.rollen.taeter_satz')), findsOneWidget);
    expect(find.text(s.ui('ui.rollen.unschuldig_satz')), findsNothing);
    expect(find.text(_sammlung.taeter['fatma']!.tarnung), findsOneWidget);
    // Keine eigene Tafel mit Warnfarbe: Die Täteransicht sieht aus wie jedes Dossier (E-041).
    expect(find.byWidgetPredicate((w) => w is PartyTafel && w.akzent == Keller.gefahr), findsNothing);
  });

  testWidgets('die Täterin sieht ihre Sabotage in der Rundenwahl', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    s.zeigeVerdeckt('fatma');
    await t.pump();
    expect(find.text(_sammlung.wahlen['gw_fatma_1']!.sabotage!), findsOneWidget);
  });

  testWidgets('eine unschuldige Kernrolle zeigt weder Täter-Tafel noch Sabotage', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    s.zeigeVerdeckt('ahmet');
    await t.pump();
    expect(s.istTaeter('ahmet'), isFalse);
    expect(find.text(s.ui('ui.rollen.taeter_satz')), findsNothing);
    expect(find.text(s.ui('ui.rollen.unschuldig_satz')), findsOneWidget);
    expect(find.text(_sammlung.wahlen['gw_ahmet_1']!.sabotage!), findsNothing);
  });

  testWidgets('Modell befragung: Bei der Rollenübergabe stehen nur die Notizen der ersten Runde', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    s.zeigeVerdeckt('emine');
    await t.pump();
    final d = s.dossier('emine');
    final erste = <String>{};
    for (final (g, _) in d.gespraeche[1]!) {
      expect(find.text(g.ziel), findsWidgets);
      for (final p in g.stichpunkte) {
        expect(find.text(p), findsWidgets, reason: p);
        erste.add(p);
      }
    }
    final z = s.spickzettel('emine', 1);
    for (final x in [...z.sagen, ...z.eigene, ...d.befragungen[1]!.fragen]) {
      expect(find.text(x), findsWidgets, reason: x);
      erste.add(x);
    }
    for (final x in z.behaupten) {
      expect(find.text(s.ui('ui.befragung.behaupte', {'text': x})), findsOneWidget, reason: x);
    }
    for (final r in [2, 3]) {
      for (final (g, _) in d.gespraeche[r]!) {
        for (final p in g.stichpunkte.where((p) => !erste.contains(p))) {
          expect(find.text(p), findsNothing, reason: 'Runde $r: $p');
        }
      }
      for (final f in d.befragungen[r]!.fragen.where((f) => !erste.contains(f))) {
        expect(find.text(f), findsNothing, reason: 'Runde $r: $f');
      }
    }
    expect(find.text(s.ui('ui.rollen.gespraech_eroeffnung')), findsNothing, reason: 'Stichpunkte statt „So fängst du an“');
    expect(find.text(s.ui('ui.befragung.dich')), findsOneWidget);
    expect(find.text(s.ui('ui.befragung.anspricht')), findsOneWidget);
    expect(find.text(s.ui('ui.befragung.runde_eins')), findsOneWidget);
  });

  testWidgets('eine Lüge im Dossier zeigt Behauptung und Wahrheit', (t) async {
    final s = _sitzung();
    // Die erste Rolle mit einer Lüge im Dossier suchen.
    String? rolle;
    DossierZeile? luege;
    for (final r in s.besetzt) {
      s.zeigeVerdeckt(r);
      final luegen = [for (final z in s.dossier(r).verbirgt) if (z.art == 'luege') z];
      s.verdecken();
      if (luegen.isNotEmpty) {
        rolle = r;
        luege = luegen.first;
        break;
      }
    }
    expect(rolle, isNotNull, reason: 'keine Lüge im Dossier der Testsitzung');
    await _zeige(t, s);
    s.zeigeVerdeckt(rolle!);
    await t.pump();
    expect(find.text(luege!.behauptung!), findsOneWidget);
    expect(find.text(luege.text), findsOneWidget);
  });

  testWidgets('Schließen deckt die Karte wieder zu', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    s.zeigeVerdeckt('emine');
    await t.pump();
    await _schliesse(t, s);
    expect(s.verdeckt, isNull);
  });

  testWidgets('nach dem Schließen trägt die Rolle ein Häkchen', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    s.zeigeVerdeckt('emine');
    await t.pump();
    await _schliesse(t, s);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('nach dem Schließen steht kurz die Meldung über der Liste, dann nicht mehr', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    s.zeigeVerdeckt('emine');
    await t.pump();
    await _schliesse(t, s);
    final meldung = s.ui('ui.verdeckt.neutral');
    expect(find.text(meldung), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
    expect(find.text(meldung), findsNothing);
  });

  testWidgets('Weiter führt den Abend zur Intro-Phase', (t) async {
    final s = _sitzung();
    await _zeige(t, s);
    await _tippe(t, find.text(s.ui('ui.rollen.weiter')));
    expect(s.phase, PartyPhase.intro);
  });

  for (final groesse in const [Size(1280, 800), Size(390, 844)]) {
    final name = '${groesse.width.toInt()} × ${groesse.height.toInt()}';
    testWidgets('kein Überlauf: neutrale Ansicht bei $name', (t) async {
      await _zeige(t, _sitzung(), groesse: groesse);
      expect(t.takeException(), isNull);
    });
    testWidgets('kein Überlauf: Dossier der Täterin bei $name', (t) async {
      final s = _sitzung();
      await _zeige(t, s, groesse: groesse);
      s.zeigeVerdeckt('fatma');
      await t.pump();
      expect(t.takeException(), isNull);
    });
  }
}
