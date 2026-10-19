// M6: Die Karte des Detektivs: Einweisung und Regeln aus dem Kanon der Akte,
// die Klasse auf der Karte (nur in Akten mit Klassen) und wie Befragungen
// laufen. Sie liegt in der Rollenphase als Eintrag aus und passt auf ein
// schmales Handy, auch mit doppelter Schrift.
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
    testWidgets('Schlosskeller ($g): Einweisung, Regeln, Klasse und Befragungen', (t) async {
      final s = _sitzung('schlosskeller', detektiv: g);
      await _zeige(t, SingleChildScrollView(child: DetektivKarte(sitzung: s, klasse: 'journalist')));
      for (final k in ['detektiv.$g.wer', 'detektiv.$g.auftrag', for (final r in DetektivKarte.regeln) 'detektiv.regeln.$r']) {
        expect(find.text(s.text(k), skipOffstage: false), findsOneWidget, reason: k);
      }
      for (final text in [
        _l.detektiv_karte_wer, _l.detektiv_karte_auftrag, _l.detektiv_karte_regeln, _l.detektiv_karte_klasse, _l.detektiv_karte_befragungen,
        _l.detektiv_karte_befragung_1, _l.detektiv_karte_befragung_2, _l.detektiv_karte_befragung_3,
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
    expect(find.text(s.text('detektiv.w.auftrag'), skipOffstage: false), findsOneWidget);
    expect(find.text(_l.className('forensic'), skipOffstage: false), findsOneWidget);
    expect(find.textContaining(_l.klasseFaehigkeit('forensic'), skipOffstage: false), findsNothing);
    expect(find.text(_l.abend_klasse_fair, skipOffstage: false), findsNothing);
    expect(find.text(_l.abend_klasse_hinweis, skipOffstage: false), findsOneWidget);
  });

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
      expect(find.text(s.text('detektiv.w.auftrag'), skipOffstage: false), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.tap(find.text(_l.common_close));
      await t.pumpAndSettle();
      expect(find.text(s.text('detektiv.w.auftrag'), skipOffstage: false), findsNothing);
      expect(t.takeException(), isNull);
    });
  }
}
