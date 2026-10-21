// F4-BAUMEISTER-04: Gruppenwahl reihum und verdeckt (Master 7.8, E-025).
// Jede Person kommt einzeln dran. Keine Ansicht zeigt eine Stimmenzahl oder
// was jemand gewählt hat. Nur die Täterrolle sieht in der eigenen verdeckten
// Ansicht die Sabotage als B.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/gruppenwahl.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';

const _quer = Size(1280, 800);
const _hoch = Size(390, 844);

/// Testansicht in der gewünschten Größe; danach wieder zurückgesetzt.
void _groesse(WidgetTester t, Size g) {
  t.view.physicalSize = g;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
}

/// Gruppenwahl der Runde 1 bei fünf Personen (Reihe: Ahmet, Fatma, Olli, Can, Leyla).
Future<PartySitzung> _aufbau(WidgetTester t, {String pfad = 'can', Size groesse = _quer}) async {
  _groesse(t, groesse);
  final s = neueSitzung(rollen: 5, pfad: pfad);
  spieleBis(s, PartyPhase.gruppenwahl);
  await t.pumpWidget(rahmen(GruppenwahlBildschirm(sitzung: s)));
  return s;
}

/// Antippen, nachdem das Ziel sichtbar gescrollt ist.
Future<void> _tippe(WidgetTester t, Finder ziel) async {
  await t.ensureVisible(ziel);
  await t.tap(ziel);
  await t.pump();
}

/// Knopf „Ich bin …, zeig her“ der Person.
Future<void> _zeigeHer(WidgetTester t, PartySitzung s, String rolle) =>
    _tippe(t, find.text(s.ui('ui.verdeckt.frage', {'name': s.spielerName(rolle)})));

/// Eine Stimme über die Oberfläche: aufdecken, Karte antippen, bestätigen.
Future<void> _stimme(WidgetTester t, PartySitzung s, String rolle, {required bool a}) async {
  await _zeigeHer(t, s, rolle);
  final w = s.wahl(rolle);
  await _tippe(t, find.text(a ? w.a : w.b));
  await _tippe(t, find.text(s.ui('ui.gruppenwahl.bestaetigen')));
}

/// Alle sichtbaren Texte der Ansicht.
List<String> _sichtbar(WidgetTester t) => [
      for (final w in t.widgetList<Text>(find.byType(Text))) w.data ?? w.textSpan?.toPlainText() ?? '',
    ];

/// Sichtbare Texte mit einer Ziffer, außer den ausdrücklich erlaubten.
List<String> _ziffernFremd(WidgetTester t, Set<String> erlaubt) => [
      for (final x in _sichtbar(t)) if (RegExp(r'\d').hasMatch(x) && !erlaubt.contains(x)) x,
    ];

/// Das Symbol in der Zeile einer Person (Häkchen oder leerer Kreis).
Finder _symbolBei(String rolle, IconData symbol) => find.descendant(of: find.byKey(ValueKey(rolle)), matching: find.byIcon(symbol));

/// Alle fünf Personen wählen nacheinander; auf dieser Größe darf nichts überlaufen.
Future<void> _ueberlauf(WidgetTester t, Size g) async {
  final s = await _aufbau(t, groesse: g);
  expect(t.takeException(), isNull, reason: 'neutrale Ansicht bei $g');
  for (final r in s.besetzt) {
    await _zeigeHer(t, s, r);
    expect(t.takeException(), isNull, reason: 'verdeckte Ansicht von $r bei $g');
    await _tippe(t, find.text(s.wahl(r).b));
    await _tippe(t, find.text(s.ui('ui.gruppenwahl.bestaetigen')));
    expect(t.takeException(), isNull, reason: 'nach der Wahl von $r bei $g');
  }
  expect(find.text(s.ui('ui.allgemein.weiter')), findsOneWidget);
  expect(t.takeException(), isNull, reason: 'alle gewählt bei $g');
}

void main() {
  testWidgets('neutral: nennt die erste Person und zeigt keinen Wahltext', (t) async {
    final s = await _aufbau(t);
    expect(s.offeneWaehler.first, s.besetzt.first);
    expect(find.text(s.ui('ui.verdeckt.weitergeben', {'name': s.spielerName(s.besetzt.first)})), findsOneWidget);
    for (final r in s.besetzt) {
      final w = partyDaten.texte.sammlung.wahlen['gw_${r}_1']!;
      expect(find.text(w.a), findsNothing, reason: r);
      expect(find.text(w.b), findsNothing, reason: r);
    }
  });

  testWidgets('der Detektiv wählt nicht mit und steht in keiner Liste', (t) async {
    final s = await _aufbau(t);
    expect(s.offeneWaehler, isNot(contains(Besetzung.detektiv)));
    expect(find.byKey(const ValueKey(Besetzung.detektiv)), findsNothing);
  });

  testWidgets('„Ich bin …, zeig her“ öffnet die verdeckte Ansicht mit Name, Rundenname und Frage', (t) async {
    final s = await _aufbau(t);
    await _zeigeHer(t, s, 'ahmet');
    expect(s.verdeckt, 'ahmet');
    expect(find.text(s.spielerName('ahmet')), findsOneWidget);
    expect(find.text(s.rundenName.toUpperCase()), findsOneWidget);
    expect(find.text(s.ui('ui.gruppenwahl.frage')), findsOneWidget);
  });

  testWidgets('verdeckt: beide Wahlkarten sichtbar, A steht oben', (t) async {
    final s = await _aufbau(t);
    await _zeigeHer(t, s, 'ahmet');
    final w = s.wahl('ahmet');
    expect(find.text(w.a), findsOneWidget);
    expect(find.text(w.b), findsOneWidget);
    expect(t.getCenter(find.text(w.a)).dy, lessThan(t.getCenter(find.text(w.b)).dy));
  });

  testWidgets('Täter: in der eigenen Ansicht steht als B die Sabotage', (t) async {
    final s = await _aufbau(t);
    for (final r in ['ahmet', 'fatma', 'olli']) {
      await _stimme(t, s, r, a: true);
    }
    expect(s.offeneWaehler.first, 'can');
    await _zeigeHer(t, s, 'can');
    final w = partyDaten.texte.sammlung.wahlen['gw_can_1']!;
    expect(find.text(w.sabotage!), findsOneWidget);
    expect(find.text(w.b), findsNothing);
  });

  testWidgets('andere Person: als B der normale Text, nie die Sabotage', (t) async {
    final s = await _aufbau(t);
    await _zeigeHer(t, s, 'ahmet');
    final w = partyDaten.texte.sammlung.wahlen['gw_ahmet_1']!;
    expect(find.text(w.b), findsOneWidget);
    expect(find.text(w.sabotage!), findsNothing);
  });

  testWidgets('nach der Wahl: zugedeckt, Person bei „Schon gewählt“, nächste Person ist dran', (t) async {
    final s = await _aufbau(t);
    await _stimme(t, s, 'ahmet', a: true);
    expect(s.verdeckt, isNull);
    expect(find.text(s.ui('ui.verdeckt.neutral')), findsOneWidget);
    expect(find.text(s.ui('ui.verdeckt.weitergeben', {'name': s.spielerName('fatma')})), findsOneWidget);
    expect(_symbolBei('ahmet', Icons.check), findsOneWidget);
    expect(_symbolBei('fatma', Icons.radio_button_unchecked), findsOneWidget);
  });

  testWidgets('Zudecken ohne Wahl zählt nicht als Stimme', (t) async {
    final s = await _aufbau(t);
    await _zeigeHer(t, s, 'ahmet');
    await _tippe(t, find.text(s.ui('ui.verdeckt.schliessen')));
    expect(s.verdeckt, isNull);
    expect(s.offeneWaehler.first, 'ahmet');
    expect(_symbolBei('ahmet', Icons.radio_button_unchecked), findsOneWidget);
  });

  testWidgets('„Das ist meine Wahl“ ist erst aktiv, wenn eine Karte angetippt ist', (t) async {
    final s = await _aufbau(t);
    await _zeigeHer(t, s, 'ahmet');
    final knopf = find.ancestor(of: find.text(s.ui('ui.gruppenwahl.bestaetigen')), matching: find.byType(FilledButton));
    expect(t.widget<FilledButton>(knopf).onPressed, isNull);
    await _tippe(t, find.text(s.wahl('ahmet').b));
    expect(t.widget<FilledButton>(knopf).onPressed, isNotNull);
  });

  testWidgets('Weiter erscheint erst, wenn alle gewählt haben, und führt in die Bonusphase', (t) async {
    final s = await _aufbau(t);
    for (final r in s.besetzt.take(4)) {
      await _stimme(t, s, r, a: true);
    }
    expect(find.text(s.ui('ui.allgemein.weiter')), findsNothing);
    await _stimme(t, s, s.besetzt.last, a: true);
    expect(s.alleGestimmt, isTrue);
    expect(find.text(s.ui('ui.gruppenwahl.alle')), findsOneWidget);
    await _tippe(t, find.text(s.ui('ui.allgemein.weiter')));
    expect(s.phase, PartyPhase.bonus);
  });

  testWidgets('keine Ziffer außer der Rundenanzeige; Wahltexte aus dem Kanon sind die einzige Ausnahme', (t) async {
    final s = await _aufbau(t);
    final runde = s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}).toUpperCase();
    expect(_ziffernFremd(t, {runde}), isEmpty, reason: 'neutrale Ansicht');
    await _zeigeHer(t, s, 'ahmet');
    final w = s.wahl('ahmet');
    expect(_ziffernFremd(t, {w.a, w.b}), isEmpty, reason: 'verdeckte Ansicht');
  });

  testWidgets('1280 × 800: ohne Überlauf durch alle Stimmen bis Weiter', (t) async {
    await _ueberlauf(t, _quer);
  });

  testWidgets('390 × 844: ohne Überlauf durch alle Stimmen bis Weiter', (t) async {
    await _ueberlauf(t, _hoch);
  });
}
