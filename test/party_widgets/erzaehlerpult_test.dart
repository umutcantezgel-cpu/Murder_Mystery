// Langer Abend M3b: Erzähler beim Spiel an einem Gerät. Sitzt ein Erzähler am
// Tisch, liegen die Erzähltexte vor dem Finale zugedeckt im Erzählerpult; nur
// der Erzähler öffnet es („Ich bin …, zeig her“) und deckt nach dem Vorlesen zu.
// Ohne Erzähler, im Solo und in den Altakten bleibt alles wie bisher. Der Name
// des Detektivs heißt jetzt `detektivName`; ein alter Abendstand mit
// `geburtstagskind` lässt sich weiter fortsetzen.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/erzaehlerpult.dart';
import 'package:mordakte/party/bildschirme/finale.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/bildschirme/resuemee.dart';
import 'package:mordakte/party/erzaehler_ausgabe.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';

final _de = LDe();

/// Eingerichtete Sitzung (Pfad ahmet, vier Rollen), auf Wunsch mit Erzählerin Mia.
PartySitzung _sitzung({String erzaehler = 'Mia'}) => PartySitzung(partyDaten, salz: '00aa11bb22cc33dd')
  ..einrichten(rollen: 4, detektiv: 'w', code: FallCode.fuerPfad('ahmet', partyDaten.kanon.pfade).code, erzaehlerName: erzaehler);

void main() {
  test('Einrichten: Erzähler nie im Solo und nie in einer Akte ohne Erzähler-Sitz', () {
    expect(() => PartySitzung(partyDaten).einrichten(rollen: 4, detektiv: 'w', solo: true, erzaehlerName: 'Mia'), throwsArgumentError);
    expect(() => PartySitzung(akteDaten('gewoelbe')).einrichten(rollen: 4, detektiv: 'w', erzaehlerName: 'Mia'), throwsArgumentError);
    for (final fall in ['gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
      expect(akteDaten(fall).mitErzaehlerSitz, isFalse, reason: '$fall bleibt wie bisher');
    }
    expect(partyDaten.mitErzaehlerSitz, isTrue);
    final s = PartySitzung(partyDaten)..einrichten(rollen: 4, detektiv: 'w', solo: true, detektivName: 'Ada');
    expect([s.detektivName, s.erzaehlerName, s.erzaehlerAmPult], ['Ada', '', false]);
  });

  test('Abendstand: Erzähler und Detektivname überstehen das Neuladen, der alte Schlüssel wird gelesen', () {
    final s = PartySitzung(partyDaten, salz: '00aa11bb22cc33dd')
      ..einrichten(rollen: 4, detektiv: 'w', code: FallCode.fuerPfad('ahmet', partyDaten.kanon.pfade).code, erzaehlerName: 'Mia', detektivName: 'Ada');
    final stand = jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>;
    final f = PartySitzung.fortsetzen(partyDaten, stand);
    expect([f.erzaehlerName, f.detektivName, f.erzaehlerAmPult, f.pultOffen], ['Mia', 'Ada', true, false]);
    // Ein Abend von vor M3: Der Detektivname lag unter `geburtstagskind`, einen Erzähler gab es nicht.
    final befehle = [
      for (final b in stand['befehle'] as List)
        if ((b as Map)['b'] == 'einrichten') ({...b}..remove('detektivName')..remove('erzaehler')..['geburtstagskind'] = 'Bo') else b,
    ];
    final alt = PartySitzung.fortsetzen(partyDaten, {...stand, 'befehle': befehle});
    expect([alt.detektivName, alt.erzaehlerName, alt.erzaehlerAmPult], ['Bo', '', false]);
    expect(alt.personAmTisch(Besetzung.detektiv), 'Bo');
  });

  test('Das Pult öffnet nur mit Erzähler, schließt bei jedem neuen Schritt und gilt nicht nach dem Finale', () {
    final ohne = _sitzung(erzaehler: '');
    expect(ohne.erzaehlerAmPult, isFalse);
    expect(ohne.pultZeigen, throwsStateError);
    final s = _sitzung();
    spieleBis(s, PartyPhase.intro);
    expect([s.erzaehlerAmPult, s.pultOffen, erzaehltextOffen(s)], [true, false, false]);
    s.pultZeigen();
    expect([s.pultOffen, erzaehltextOffen(s)], [true, true]);
    s.weiter();
    expect(s.pultOffen, isFalse, reason: 'Neue Texte liegen wieder zugedeckt');
    spieleBis(s, PartyPhase.finale);
    expect([s.erzaehlerAmPult, erzaehltextOffen(s)], [false, true], reason: 'Die Auflösung lesen alle');
  });

  testWidgets('Intro mit Erzählerin: zugedeckt, dann nur für Mia offen, danach wieder zu', (t) async {
    final s = _sitzung();
    spieleBis(s, PartyPhase.intro);
    final start = s.text('intro.start');
    await t.pumpWidget(rahmen(IntroBildschirm(sitzung: s)));
    await t.pump();
    expect(find.text(start), findsNothing, reason: 'Der Tisch sieht keinen Erzähltext');
    expect(find.byType(ErzaehlerpultZu), findsOneWidget);
    expect(find.text(_de.erzaehlerpult_geben('Mia')), findsOneWidget);
    expect(find.text(_de.erzaehlerpult_texte(s.erzaehler.length)), findsOneWidget);
    await t.tap(find.text(_de.erzaehlerpult_zeigen('Mia')));
    await t.pump();
    expect(find.text(start), findsOneWidget, reason: 'Mia liest');
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerpult-zudecken')));
    await t.tap(find.byKey(const ValueKey('erzaehlerpult-zudecken')));
    await t.pump();
    expect(find.text(start), findsNothing);
    expect(find.byType(ErzaehlerpultZu), findsOneWidget);
  });

  testWidgets('Ohne Erzähler steht der Text offen wie bisher', (t) async {
    final s = _sitzung(erzaehler: '');
    spieleBis(s, PartyPhase.intro);
    await t.pumpWidget(rahmen(IntroBildschirm(sitzung: s)));
    await t.pump();
    expect(find.text(s.text('intro.start')), findsOneWidget);
    expect(find.byType(ErzaehlerpultZu), findsNothing);
    expect(find.byKey(const ValueKey('erzaehlerpult-zudecken')), findsNothing);
  });

  testWidgets('Resümee: Der Bericht ist Erzähltext und liegt mit im Pult', (t) async {
    final s = _sitzung();
    spieleBis(s, PartyPhase.resuemee);
    final lage = s.erzaehler.firstWhere((k) => k.startsWith('resuemee.lage.'));
    // Wie im Ablauf baut ein Zuhörer den Bildschirm bei jeder Änderung der Sitzung neu.
    await t.pumpWidget(rahmen(ListenableBuilder(listenable: s, builder: (_, _) => ResuemeeBildschirm(sitzung: s))));
    await t.pump();
    expect(find.text(s.text(lage)), findsNothing);
    s.pultZeigen();
    await t.pump();
    expect(find.text(s.text(lage)), findsOneWidget);
    // „Gelesen, zudecken“ steht unter dem Bericht, nicht über ihm (Nachschliff M3).
    final zudecken = find.byKey(const ValueKey('erzaehlerpult-zudecken'));
    expect(zudecken, findsOneWidget);
    expect(t.getTopLeft(zudecken).dy, greaterThan(t.getBottomLeft(find.text(s.text(lage))).dy));
  });

  testWidgets('Finale: alle lesen, das Pult ist weg', (t) async {
    final s = _sitzung();
    spieleBis(s, PartyPhase.finale);
    await t.pumpWidget(rahmen(FinaleBildschirm(sitzung: s)));
    await t.pump();
    expect(find.byType(ErzaehlerpultZu), findsNothing);
    final k = s.erzaehler.firstWhere((k) => k.startsWith('finale.'), orElse: () => s.erzaehler.first);
    expect(find.text(s.text(k)), findsWidgets);
  });
}
