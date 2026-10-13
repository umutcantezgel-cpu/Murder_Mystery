// F4-BAUMEISTER-05: Erzählerfeld, Erzählerstimme und Wortgleich-Prüfung (Master 7.12).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/erzaehler_ausgabe.dart';
import 'package:mordakte/party/party_stil.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/stimme.dart';
import 'package:mordakte/stil/stil.dart';

import 'hilfe.dart';

/// Das Feld im Kellerrahmen, so wie es auf den Bildschirmen steht.
Widget _feld(PartySitzung s, List<String> kennungen) => rahmen(PartyRahmen(child: ErzaehlerFeld(sitzung: s, kennungen: kennungen)));

/// Alle Intro-Bausteine des Kanons.
List<String> _intro() => [
      for (final k in partyDaten.texte.sammlung.bausteine.keys)
        if (k.startsWith('intro.')) k,
    ];

/// Alle Texte im Feld im Stil der Erzählertexte (ohne Kopfzeile).
Iterable<Text> _erzaehlerTexte(WidgetTester t) => t.widgetList<Text>(find.byType(Text)).where((x) => x.style == MPapierSchrift.erzaehler);

void main() {
  testWidgets('zeigt intro.start und runde.1.start genau einmal, wortgleich', (t) async {
    final s = neueSitzung();
    await t.pumpWidget(_feld(s, ['intro.start', 'runde.1.start']));
    expect(find.text(s.text('intro.start')), findsOneWidget);
    expect(find.text(s.text('runde.1.start')), findsOneWidget);
    expect(_erzaehlerTexte(t), hasLength(2));
  });

  testWidgets('der Lacher-Baustein trägt die Rückblick-Marke', (t) async {
    final s = neueSitzung();
    await t.pumpWidget(_feld(s, ['intro.lacher.lacher_ruestung.besetzt']));
    expect(find.text(s.ui('ui.erzaehler.rueckblick').toUpperCase()), findsOneWidget);
  });

  testWidgets('Bausteine ohne Lacher haben keine Rückblick-Marke', (t) async {
    final s = neueSitzung();
    await t.pumpWidget(_feld(s, ['intro.start', 'runde.1.start']));
    expect(find.text(s.ui('ui.erzaehler.rueckblick').toUpperCase()), findsNothing);
  });

  testWidgets('der Schalter setzt sitzung.stimmeAn auf an', (t) async {
    final s = neueSitzung();
    await t.pumpWidget(_feld(s, ['intro.start']));
    await t.tap(find.byType(MSchalter));
    await t.pump();
    expect(s.stimmeAn, isTrue);
  });

  testWidgets('der Schalter setzt sitzung.stimmeAn auf aus', (t) async {
    final s = neueSitzung()..stimmeAn = true;
    await t.pumpWidget(_feld(s, ['intro.start']));
    await t.tap(find.byType(MSchalter));
    await t.pump();
    expect(s.stimmeAn, isFalse);
  });

  testWidgets('mit Stub-Stimme gibt es bei stimmeAn = true keinen Absturz', (t) async {
    final s = neueSitzung()..stimmeAn = true;
    await t.pumpWidget(_feld(s, ['intro.start', 'runde.1.start']));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });

  testWidgets('ohne verfügbare Stimme gibt es keinen Knopf „Noch einmal vorlesen“', (t) async {
    final s = neueSitzung()..stimmeAn = true;
    await t.pumpWidget(_feld(s, ['intro.start']));
    expect(find.text(s.ui('ui.erzaehler.nochmal')), findsNothing);
  });

  testWidgets('ohne verfügbare Stimme sagt das Feld es, wenn die Stimme an ist', (t) async {
    final s = neueSitzung()..stimmeAn = true;
    await t.pumpWidget(_feld(s, ['intro.start']));
    expect(find.text(s.ui('ui.erzaehler.keine_stimme')), findsOneWidget);
  });

  test('wortgleich ist wahr für den echten Text und falsch für einen veränderten', () {
    final s = neueSitzung();
    final echt = s.text('intro.start');
    expect(wortgleich(s, 'intro.start', echt), isTrue);
    expect(wortgleich(s, 'intro.start', '$echt '), isFalse);
  });

  test('wortgleich ist für eine unbekannte Kennung nie wahr', () {
    final s = neueSitzung();
    expect(wortgleich(s, 'gibt.es.nicht', 'Irgendein Text.'), isFalse);
  });

  test('Stub-Stimme: nichts verfügbar, nichts wird gesprochen', () async {
    final stimme = Stimme.erzeugen();
    expect(stimme.verfuegbar, isFalse);
    expect(await stimme.sprich('Ein Test.'), isFalse);
    stimme.stopp();
  });

  test('unbekannte Kennung: sitzung.text wirft ArgumentError', () {
    expect(() => neueSitzung().text('gibt.es.nicht'), throwsArgumentError);
  });

  testWidgets('das Feld zeigt nur Texte aus sitzung.text, unbekannte Kennungen fallen weg', (t) async {
    final s = neueSitzung();
    await t.pumpWidget(_feld(s, ['gibt.es.nicht', 'intro.start']));
    expect(t.takeException(), isNull);
    final erlaubt = {s.text('intro.start'), s.ui('ui.erzaehler.stimme')};
    for (final x in t.widgetList<Text>(find.byType(Text))) {
      expect(erlaubt, contains(x.data), reason: 'Text, der nicht aus einem Baustein kommt: ${x.data}');
    }
  });

  testWidgets('kein Überlauf bei 390 × 844 mit allen Intro-Bausteinen', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = neueSitzung()..stimmeAn = false;
    await t.pumpWidget(_feld(s, _intro()));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });

  testWidgets('kein Überlauf bei 1280 × 800 mit allen Intro-Bausteinen', (t) async {
    t.view.physicalSize = const Size(1280, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = neueSitzung()..stimmeAn = false;
    await t.pumpWidget(_feld(s, _intro()));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
}
