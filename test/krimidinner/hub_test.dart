// Hub: drei gleichrangige Bereiche, beide Partyabende gleich groß und in gleicher
// Titelschrift (am Telefon untereinander, breit nebeneinander), Wege zu /party und
// /gewoelbe, Zurück aus dem Gewölbe in den Hub, kein Überlauf bei 360 px.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte/krimidinner/gewoelbe_seite.dart';
import 'package:mordakte/krimidinner/kanon_laden.dart';
import 'package:mordakte/ui/screens/hub_screen.dart';
import 'package:mordakte/ui/widgets/bento.dart';

import 'hilfe.dart';

Finder kachel(String titel) => find.ancestor(of: find.text(titel), matching: find.byType(BentoTile));

String pfad(WidgetTester tester) => GoRouter.of(tester.element(find.byType(Navigator).first)).state.matchedLocation;

void main() {
  setUpAll(schriftenLaden);

  // Zuerst: Der zwischengespeicherte Kanon wird hier echt geladen (runAsync), danach
  // nutzt der Tipp auf „Spuk im Gewölbe“ dasselbe fertige Ergebnis.
  testWidgets('der Kanon kommt aus dem Asset-Bündel (nur K*.md)', (tester) async {
    final k = await tester.runAsync(ladeGewoelbeKanon);
    expect(k, isNotNull);
    expect(k!.datensaetze.length, greaterThanOrEqualTo(1200));
    expect(k.lesefehler, isEmpty);
    expect(k.datensaetze.values.map((d) => d.datei).every((d) => d.startsWith('K')), isTrue);
    expect(identical(await tester.runAsync(ladeGewoelbeKanon), k), isTrue, reason: 'zwischengespeichert');
  });

  testWidgets('Bereiche in Reihenfolge, Partyabende gleich groß über den Fallakten', (tester) async {
    groesse(tester, const Size(430, 1400));
    await tester.pumpWidget(hubApp());
    await bilder(tester, 8);

    final party = tester.getTopLeft(find.text('Partyabende')).dy;
    final klassisch = tester.getTopLeft(find.text('Klassische Fälle')).dy;
    final meta = tester.getTopLeft(find.text('Sammlung und Profil')).dy;
    expect(party, lessThan(klassisch));
    expect(klassisch, lessThan(meta));

    final keller = kachel('Spuk im Schlosskeller');
    final gewoelbe = kachel('Spuk im Gewölbe');
    expect(keller, findsOneWidget);
    expect(gewoelbe, findsOneWidget);
    expect(tester.getSize(keller).width, closeTo(tester.getSize(gewoelbe).width, 0.5));
    expect(tester.getSize(keller).height, closeTo(tester.getSize(gewoelbe).height, 0.5));
    expect(tester.widget<BentoTile>(keller).highlight, isTrue);
    expect(tester.widget<BentoTile>(gewoelbe).highlight, isTrue);

    final fallakten = kachel('Fallakten');
    expect(fallakten, findsOneWidget);
    expect(tester.getTopLeft(gewoelbe).dy, lessThan(tester.getTopLeft(fallakten).dy));
    expect(tester.getTopLeft(fallakten).dy, greaterThan(klassisch));
    for (final titel in ['Online spielen', 'Sammlung', 'Profil']) {
      expect(kachel(titel), findsOneWidget, reason: titel);
      expect(tester.getTopLeft(kachel(titel)).dy, greaterThan(klassisch), reason: titel);
    }
    expect(tester.getTopLeft(kachel('Sammlung')).dy, greaterThan(meta));
    // Die alte Partykachel ist weg.
    expect(find.text('Partyabend: Spuk im Schlosskeller'), findsNothing);
  });

  // Telefon: untereinander in voller Breite; breit: nebeneinander. In beiden Fällen
  // gleiche Titelgröße (mindestens 20 px), kein Titel wird verkleinert gesetzt oder
  // abgeschnitten, kein Wort getrennt, die Untertitel stehen ganz da.
  for (final (name, s, nebeneinander) in [
    ('Telefon 390×844', const Size(390, 844), false),
    ('Telefon 360×780', const Size(360, 780), false),
    ('Desktop 1280×800', const Size(1280, 800), true),
  ]) {
    testWidgets('Partykacheln gleichrangig: $name', (tester) async {
      groesse(tester, s);
      await tester.pumpWidget(hubApp());
      await bilder(tester, 8);
      expect(tester.takeException(), isNull);

      final keller = kachel('Spuk im Schlosskeller');
      final gewoelbe = kachel('Spuk im Gewölbe');
      expect(tester.getSize(keller).width, closeTo(tester.getSize(gewoelbe).width, 0.5));
      expect(tester.getSize(keller).height, closeTo(tester.getSize(gewoelbe).height, 0.5));
      if (nebeneinander) {
        expect(tester.getTopLeft(keller).dy, closeTo(tester.getTopLeft(gewoelbe).dy, 0.5));
        expect(tester.getTopLeft(keller).dx, lessThan(tester.getTopLeft(gewoelbe).dx));
      } else {
        expect(tester.getTopLeft(keller).dx, closeTo(tester.getTopLeft(gewoelbe).dx, 0.5));
        expect(tester.getTopLeft(keller).dy, lessThan(tester.getTopLeft(gewoelbe).dy));
      }

      RenderParagraph absatz(String text) => tester.renderObject<RenderParagraph>(find.text(text));
      final titelK = absatz('Spuk im Schlosskeller');
      final titelG = absatz('Spuk im Gewölbe');
      final gK = titelK.text.style!.fontSize!;
      final gG = titelG.text.style!.fontSize!;
      expect(gK, gG, reason: 'gleiche Titelgröße');
      expect(gK, greaterThanOrEqualTo(20));
      expect(find.ancestor(of: find.text('Spuk im Schlosskeller'), matching: find.byType(FittedBox)), findsNothing);
      for (final text in [
        'Spuk im Schlosskeller',
        'Spuk im Gewölbe',
        'Party am Gerät oder Solo mit Bots',
        'Krimidinner auf Burg Schartenfels · Besetzung, Steckbriefe, Mappen',
      ]) {
        final p = absatz(text);
        expect(p.didExceedMaxLines, isFalse, reason: text);
        expect(p.overflow, TextOverflow.clip, reason: text);
        expect(p.maxLines, isNull, reason: '$text: keine Zeilengrenze, nichts wird abgeschnitten');
        // Der Absatz liegt ganz in seiner Kachel.
        final kachelRect = tester.getRect(kachel(text == 'Spuk im Schlosskeller' || text.startsWith('Party ') ? 'Spuk im Schlosskeller' : 'Spuk im Gewölbe'));
        final rect = tester.getRect(find.text(text));
        expect(kachelRect.contains(rect.topLeft) && kachelRect.contains(rect.bottomRight - const Offset(0.01, 0.01)), isTrue, reason: text);
      }
      // Kein Wort ist getrennt: Jede Zeile des Titels endet an einer Wortgrenze.
      for (final p in [titelK, titelG]) {
        final text = p.text.toPlainText();
        final zeilen = p.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: text.length));
        expect(zeilen, isNotEmpty);
        for (final wort in text.split(' ')) {
          final start = text.indexOf(wort);
          final kaesten = p.getBoxesForSelection(TextSelection(baseOffset: start, extentOffset: start + wort.length));
          final oben = kaesten.map((b) => b.top.round()).toSet();
          expect(oben, hasLength(1), reason: '„$wort“ steht in einer Zeile');
        }
      }
    });
  }

  testWidgets('Tipp auf „Spuk im Gewölbe“ öffnet den Begleiter', (tester) async {
    groesse(tester, const Size(430, 1400));
    await tester.pumpWidget(hubApp());
    await bilder(tester, 6);
    await tester.tap(find.text('Spuk im Gewölbe'));
    await bilder(tester, 6);
    expect(find.byType(GewoelbeSeite), findsOneWidget);
    expect(pfad(tester), '/gewoelbe');
  });

  testWidgets('Tipp auf „Spuk im Schlosskeller“ führt zu /party', (tester) async {
    groesse(tester, const Size(430, 1400));
    await tester.pumpWidget(hubApp());
    await bilder(tester, 6);
    await tester.tap(find.text('Spuk im Schlosskeller'));
    await bilder(tester, 6);
    expect(pfad(tester), '/party');
    // Wie alle Kacheln im Hub: go, die Adresse im Web zeigt /party.
    expect(find.byType(HubScreen, skipOffstage: false), findsNothing);
  });

  testWidgets('Zurück-Geste im Gewölbe führt in den Hub, statt die App zu verlassen', (tester) async {
    groesse(tester, const Size(430, 1400));
    await tester.pumpWidget(hubApp());
    await bilder(tester, 6);
    await tester.tap(find.text('Spuk im Gewölbe'));
    await bilder(tester, 6);
    expect(pfad(tester), '/gewoelbe');
    final behandelt = await tester.binding.handlePopRoute();
    await bilder(tester, 6);
    expect(behandelt, isTrue, reason: 'die App bleibt offen');
    expect(pfad(tester), '/');
    expect(find.byType(HubScreen), findsOneWidget);
  });

  testWidgets('bei 360 px Breite kein Überlauf', (tester) async {
    groesse(tester, const Size(360, 780));
    await tester.pumpWidget(hubApp());
    await bilder(tester, 8);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -900));
    await bilder(tester, 4);
    expect(tester.takeException(), isNull);
  });
}
