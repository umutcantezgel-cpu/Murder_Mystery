// Stil: der Nebel bleibt durchscheinend, jede Akte hat einen eigenen Akzent, die
// Spielkarte nennt Name, Seltenheit und Wirkung und dreht sich bei „Bewegung reduzieren“ nicht.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/scene/nebel.dart';
import 'package:mordakte/karten/widgets/spielkarte.dart';
import 'package:mordakte/stil/stil.dart';

/// Eine Spielkarte im Thema des Spiels; [ruhig] schaltet „Bewegung reduzieren“ ein.
Widget karte({required bool ruhig}) => MaterialApp(
      theme: buildMordakteTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: ruhig),
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 220,
            child: SpielKarte(
              name: 'Mira Vance',
              farbe: const Color(0xFF6FC3C8),
              seltenheit: KartenSeltenheit.messing,
              seltenheitText: 'Messing',
              wirkung: 'Sieht die letzte Spur.',
              akte: 'SK',
              rueckseitenSemantik: 'Kartenrückseite',
            ),
          ),
        ),
      ),
    );

/// Deckkraft des nächsten Bildes um [text] (Vorder- oder Rückseite).
double deckkraft(WidgetTester tester, String text) =>
    tester.widget<Opacity>(find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first).opacity;

/// Alle Drehungen im Baum der Karte.
Iterable<Matrix4> drehungen(WidgetTester tester) =>
    tester.widgetList<Transform>(find.descendant(of: find.byType(SpielKarte), matching: find.byType(Transform))).map((t) => t.transform);

void main() {
  test('Der Nebel bleibt nie undurchsichtig (höchstens 0,65)', () {
    for (final erinnert in [true, false]) {
      for (var i = 0; i <= 100; i++) {
        expect(nebelDeckkraft(i / 100, erinnert: erinnert), inInclusiveRange(0.0, 0.65), reason: 'sicht ${i / 100}, erinnert $erinnert');
      }
    }
    expect(nebelDeckkraft(0, erinnert: false), closeTo(0.62, 1e-9));
    expect(nebelDeckkraft(0, erinnert: true), closeTo(0.38, 1e-9));
    expect(nebelDeckkraft(1, erinnert: false), closeTo(0, 1e-9));
  });

  test('Jede Akte hat einen eigenen Akzent', () {
    const ids = ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm'];
    final stile = [for (final id in ids) AkteStil.fuer(id)];
    expect([for (final s in stile) s.id], ids);
    expect({for (final s in stile) s.akzent}, hasLength(ids.length));
    expect(AkteStil.fuer('unbekannt').akzent, AkteStil.kerzenmessing.akzent);
  });

  testWidgets('Die Beschriftung nennt Name, Seltenheit und Wirkung', (tester) async {
    final semantik = tester.ensureSemantics();
    try {
      await tester.pumpWidget(karte(ruhig: false));
      expect(find.bySemanticsLabel(RegExp('Mira Vance.*Messing.*Sieht die letzte Spur')), findsOneWidget);
    } finally {
      semantik.dispose();
    }
  });

  testWidgets('Nach dem Umdrehen nennt die Beschriftung die Rückseite', (tester) async {
    final semantik = tester.ensureSemantics();
    try {
      await tester.pumpWidget(karte(ruhig: false));
      await tester.tap(find.byType(SpielKarte));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.bySemanticsLabel('Kartenrückseite'), findsOneWidget);
    } finally {
      semantik.dispose();
    }
  });

  testWidgets('Bewegung reduzieren: Umdrehen blendet über, ohne Drehung', (tester) async {
    await tester.pumpWidget(karte(ruhig: true));
    expect(deckkraft(tester, 'Mira Vance'), 1);
    await tester.tap(find.byType(SpielKarte));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(deckkraft(tester, 'MORDAKTE'), 1, reason: 'die Rückseite ist oben');
    expect(deckkraft(tester, 'Mira Vance'), 0, reason: 'die Vorderseite ist verborgen');
    for (final m in drehungen(tester)) {
      expect(m.entry(0, 2), closeTo(0, 1e-9), reason: 'keine Drehung um die senkrechte Achse');
      expect(m.entry(3, 2), closeTo(0, 1e-9), reason: 'keine Perspektive');
    }
  });

  testWidgets('Ohne Bewegung reduzieren dreht die Karte mit Perspektive', (tester) async {
    await tester.pumpWidget(karte(ruhig: false));
    await tester.tap(find.byType(SpielKarte));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(drehungen(tester).any((m) => m.entry(3, 2) != 0), isTrue, reason: 'Gegenprobe: die Drehung ist messbar');
  });
}
