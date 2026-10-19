// M6: Die Karte des Detektivs: Auftrag und Regeln als Stichpunkte (R17), die
// Klasse auf der Karte (nur in Akten mit Klassen) und wie Befragungen laufen.
// Die Prosa des Kanons bleibt dem Druck. Sie liegt in der Rollenphase als
// Eintrag aus und passt auf ein schmales Handy, auch mit doppelter Schrift.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/l10n/lookup.dart';
import 'package:mordakte/party/bildschirme/detektiv_karte.dart';
import 'package:mordakte/party/bildschirme/rollen.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart' show FallCode;

import 'hilfe.dart';
import 'klasse_hilfe.dart';

final _l = LDe();

/// Wörter einer Zeile, gezählt wie im Gerüchte-Prüfer.
int _worte(String z) => RegExp(r'[\p{L}\p{N}]+', unicode: true).allMatches(z).length;

/// Bildschirm im Rahmen, mit deutschen Texten, in einem festen Fenster.
Future<void> _zeige(WidgetTester t, Widget kind, {Size groesse = const Size(390, 844), double schrift = 1}) async {
  t.view.physicalSize = groesse;
  t.view.devicePixelRatio = 1;
  t.platformDispatcher.textScaleFactorTestValue = schrift;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  await t.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    home: Scaffold(body: kind),
  ));
  await t.pump();
}

PartySitzung _sitzung(String akte, {String detektiv = 'w'}) {
  final d = klassenDaten(akte);
  final s = PartySitzung(d);
  s.einrichten(rollen: 4, detektiv: detektiv, code: FallCode.fuerPfad(d.kanon.pfade.first, d.kanon.pfade).code);
  return s;
}

void main() {
  for (final g in ['m', 'w']) {
    testWidgets('Schlosskeller ($g): Auftrag, Regeln, Klasse und Befragungen', (t) async {
      final s = _sitzung('schlosskeller', detektiv: g);
      await _zeige(t, SingleChildScrollView(child: DetektivKarte(sitzung: s, klasse: 'journalist')));
      for (final text in [
        _l.detektiv_karte_auftrag, _l.detektiv_karte_regeln, _l.detektiv_karte_klasse, _l.detektiv_karte_befragungen,
        _l.detektiv_karte_auftrag_1, _l.detektiv_karte_auftrag_2(3, 9), _l.detektiv_karte_auftrag_3,
        _l.detektiv_karte_regel_1, _l.detektiv_karte_regel_2, _l.detektiv_karte_regel_3,
        _l.detektiv_karte_befragung_1, _l.detektiv_karte_befragung_2, _l.detektiv_karte_befragung_3, _l.detektiv_karte_belohnung,
        _l.className('journalist'), '${_l.klasseFaehigkeitName('journalist')}: ${_l.klasseFaehigkeit('journalist')}', _l.abend_klasse_fair,
      ]) {
        expect(find.text(text, skipOffstage: false), findsOneWidget, reason: text);
      }
      expect(find.textContaining('Geburtstag', skipOffstage: false), findsNothing, reason: 'neutrale Feier (A-061)');
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('Akte ohne Klassen (Gewölbe): keine Fähigkeit auf der Karte, nur die Belohnung', (t) async {
    final s = _sitzung('gewoelbe');
    await _zeige(t, SingleChildScrollView(child: DetektivKarte(sitzung: s, klasse: 'forensic')));
    expect(find.text(_l.detektiv_karte_auftrag_2(3, 9), skipOffstage: false), findsOneWidget);
    expect(find.text(_l.className('forensic'), skipOffstage: false), findsOneWidget);
    expect(find.textContaining(_l.klasseFaehigkeit('forensic'), skipOffstage: false), findsNothing);
    expect(find.text(_l.abend_klasse_fair, skipOffstage: false), findsNothing);
    expect(find.text(_l.detektiv_karte_belohnung, skipOffstage: false), findsOneWidget);
  });

  // R17: Was Spieler auf dem Handy lesen, ist eine Karte mit höchstens drei
  // Stichpunkten zu je höchstens acht Wörtern; die Prosa des Kanons bleibt dem Druck.
  for (final akte in ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
    testWidgets('$akte: Kartenformat R17, keine Prosa aus dem Druck', (t) async {
      final s = _sitzung(akte);
      final kanonProsa = [
        for (final g in ['m', 'w']) ...['detektiv.$g.wer', 'detektiv.$g.auftrag'],
        for (final r in ['entscheidungen', 'hinweise', 'punkte', 'anklage']) 'detektiv.regeln.$r',
      ];
      for (final klasse in [null, 'forensic', 'profiler', 'excop', 'journalist', 'medic']) {
        await _zeige(t, SingleChildScrollView(child: DetektivKarte(sitzung: s, klasse: klasse)));
        final karte = find.byType(DetektivKarte);
        final zeilen = [for (final w in t.widgetList<Text>(find.descendant(of: karte, matching: find.byType(Text)))) w.data!];
        expect(zeilen, isNotEmpty);
        for (final z in zeilen) {
          expect(_worte(z), lessThanOrEqualTo(8), reason: '$akte, $klasse: „$z“');
        }
        for (final k in kanonProsa) {
          if (s.hatText(k)) expect(zeilen, isNot(contains(s.text(k))), reason: '$akte: $k gehört in den Druck');
        }
        // Je Abschnitt höchstens drei Stichpunkte; die Klasse trägt ihren Namen als Kopf.
        for (final (titel, hoechstens) in [
          (_l.detektiv_karte_auftrag, 3),
          (_l.detektiv_karte_regeln, 3),
          (_l.detektiv_karte_klasse, klasse == null ? 3 : 4),
          (_l.detektiv_karte_befragungen, 3),
        ]) {
          final abschnitt = find.ancestor(of: find.text(titel), matching: find.byType(Column)).first;
          final texte = find.descendant(of: abschnitt, matching: find.byType(Text)).evaluate().length - 1;
          expect(texte, inInclusiveRange(1, hoechstens), reason: '$akte, $klasse: $titel');
        }
      }
      expect(t.takeException(), isNull);
    });
  }

  for (final (breite, schrift) in [(320.0, 2.0), (390.0, 1.0)]) {
    testWidgets('Rollenphase: der Eintrag öffnet die Karte, ohne Überlauf bei $breite px und Schrift $schrift', (t) async {
      final s = neueSitzung(rollen: 7, pfad: 'fatma');
      await _zeige(t, RollenBildschirm(sitzung: s), groesse: Size(breite, 844), schrift: schrift);
      final eintrag = find.byType(DetektivKarteEintrag);
      expect(eintrag, findsOneWidget);
      expect(s.verdeckt, isNull, reason: 'die Karte des Detektivs ist nicht verdeckt');
      await t.ensureVisible(eintrag);
      await t.tap(eintrag);
      await t.pumpAndSettle();
      expect(find.text(_l.detektiv_karte_titel), findsWidgets);
      expect(find.text(_l.detektiv_karte_auftrag_1, skipOffstage: false), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.tap(find.text(_l.common_close));
      await t.pumpAndSettle();
      expect(find.text(_l.detektiv_karte_auftrag_1, skipOffstage: false), findsNothing);
      expect(t.takeException(), isNull);
    });
  }
}
