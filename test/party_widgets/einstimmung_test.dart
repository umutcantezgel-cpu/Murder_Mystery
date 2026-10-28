// Finale Schlosskeller (A-063, SPEZIFIKATION §1): die Einstimmung an einem
// Gerät. Vorgeschichte und Vorstellung laufen als Unterzustand der Einleitung
// vor Vorspiel und Diashow; „Weiter“ ist bis zum Ende gesperrt, kein Text geht
// in `spiel.bausteine`. Je Schritt genau ein Baustein im Erzählerfeld (die
// Stimme liest wortgleich); die Vorstellungskarte nennt, wer die Figur spielt,
// nie im Vorlesetext. Journal: Schritt und Überspringen; alte Stände ohne den
// Schlüssel laufen wie bisher.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/einstimmung.dart';
import 'package:mordakte/party/bildschirme/erzaehlerpult.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/bildschirme/rundgang.dart';
import 'package:mordakte/party/erzaehler_ausgabe.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/stil/stil.dart' show MFotoabzug;
import 'package:mordakte_core/mordakte_core.dart';

import 'erzaehl_hilfe.dart';
import 'hilfe.dart';

final _de = LDe();

/// Der Eintrag `einrichten` im Journal von [s].
Map<String, Object?> _einrichten(PartySitzung s) =>
    (s.abendstand['befehle'] as List).cast<Map<String, Object?>>().firstWhere((b) => b['b'] == 'einrichten');

/// Weiter bis zum Schritt der Figur [figur] (Vorgeschichte übersprungen).
void _bisFigur(PartySitzung s, String figur) {
  if (s.einstimmung?.teil == EinstimmungTeil.vorgeschichte) s.einstimmungUeberspringen();
  while (s.einstimmung != null && s.einstimmung!.figur != figur) {
    s.einstimmungWeiter();
  }
}

/// Text innerhalb der Vorstellungskarte bzw. des Erzählerfelds.
Finder _inKarte(Finder f) => find.descendant(of: find.byType(VorstellungsKarte), matching: f);
Finder _imFeld(Finder f) => find.descendant(of: find.byType(ErzaehlerFeld), matching: f);

/// Handyformat mit reduzierter Bewegung.
Future<void> _zeige(WidgetTester t, Widget kind) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(MediaQuery(data: const MediaQueryData(disableAnimations: true, size: Size(390, 844)), child: kind)));
  await t.pump();
}

void main() {
  test('Einrichten: nur in Akten mit Einstimmung; das Journal merkt sie nur, wenn sie an ist', () {
    expect(partyDaten.einstimmung, isNull, reason: 'Ohne Eintrag in akten.json kein Zusatz');
    expect(() => PartySitzung(partyDaten).einrichten(rollen: 4, detektiv: 'w', einstimmung: true), throwsArgumentError);
    expect(erzaehlDaten.einstimmung, isNotNull);
    final aus = erzaehlSitzung(einstimmung: false), an = erzaehlSitzung();
    expect(_einrichten(aus).keys.toSet(), {'b', 'rollen', 'detektiv', 'code', 'druck', 'solo', 'minuten', 'namen', 'detektivName'},
        reason: 'Ohne Einstimmung bleibt der Eintrag wie bisher');
    expect(_einrichten(an)['einstimmung'], isTrue);
    expect([aus.mitEinstimmung, an.mitEinstimmung, aus.einstimmungSchritte, an.einstimmung], [false, true, isEmpty, null]);
  });

  test('Ablauf: alle Schritte in der Einleitung, Weiter gesperrt bis zum Ende, kein Text in spiel.bausteine', () {
    final s = erzaehlSitzung(rollen: 7);
    final e = erzaehlDaten.einstimmung!;
    bisZurEinleitung(s);
    expect(s.einstimmungSchritte, e.schritte(rollen: 7, detektiv: 'w'));
    expect(s.einstimmungAnzahl, e.teile.length + 1 + 7 + 1 + 1, reason: 'Vorgeschichte, Start, sieben Figuren, Unbesetzte, Detektiv');
    final bausteine = [...s.spiel.bausteine];
    final gelesen = <String>[];
    while (s.einstimmung != null) {
      expect(s.kannWeiter, isFalse);
      expect(s.weiter, throwsStateError);
      gelesen.add(s.einstimmung!.kennung);
      s.einstimmungWeiter();
    }
    expect(gelesen, [for (final x in s.einstimmungSchritte) x.kennung]);
    expect([gelesen.first, gelesen.last], ['vorgeschichte.${e.teile.first}', 'vorstellung.detektiv.w']);
    expect(s.spiel.bausteine, bausteine);
    expect(s.spiel.bausteine.where((k) => k.startsWith('vorgeschichte.') || k.startsWith('vorstellung.')), isEmpty);
    expect(s.kannWeiter, isTrue);
    expect(s.einstimmungWeiter, throwsStateError);
    s.weiter();
    expect(s.phase, PartyPhase.gespraeche);
  });

  test('Überspringen: der Rest des laufenden Teils, aus der Vorgeschichte in die Vorstellung, dann ans Ende', () {
    final s = erzaehlSitzung(rollen: 4);
    bisZurEinleitung(s);
    s.einstimmungWeiter();
    s.einstimmungUeberspringen();
    expect([s.einstimmung!.teil, s.einstimmung!.kennung, s.einstimmung!.nr], [EinstimmungTeil.vorstellung, Einstimmung.start, 1]);
    s.einstimmungUeberspringen();
    expect([s.einstimmung, s.kannWeiter], [null, isTrue]);
    expect(s.einstimmungUeberspringen, throwsStateError);
  });

  test('Fortsetzen mitten in der Einstimmung: derselbe Schritt; ein alter Stand ohne Eintrag läuft ohne', () {
    final s = erzaehlSitzung(rollen: 5);
    bisZurEinleitung(s);
    for (var i = 0; i < 3; i++) {
      s.einstimmungWeiter();
    }
    s.einstimmungUeberspringen();
    s.einstimmungWeiter();
    final stand = jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>;
    expect(stand['format'], PartySitzung.abendstandFormat);
    final f = PartySitzung.fortsetzen(erzaehlDaten, stand);
    expect([f.phase, f.einstimmungNr, f.einstimmung, f.kannWeiter], [PartyPhase.intro, s.einstimmungNr, s.einstimmung, false]);
    f.einstimmungUeberspringen();
    expect(f.kannWeiter, isTrue);
    // Derselbe Abend aus der Zeit vor der Einstimmung: kein Schlüssel, keine Schritte.
    final befehle = [
      for (final b in stand['befehle'] as List)
        if ((b as Map)['b'] == 'einrichten') ({...b}..remove('einstimmung')) else if (b['b'] != 'einstimmung') b,
    ];
    final alt = PartySitzung.fortsetzen(erzaehlDaten, {...stand, 'befehle': befehle});
    expect([alt.mitEinstimmung, alt.einstimmung, alt.phase, alt.kannWeiter], [false, null, PartyPhase.intro, true]);
    expect(_einrichten(alt).containsKey('einstimmung'), isFalse);
  });

  test('Langer Abend: Einstimmung, dann Vorspiel, dann Diashow', () {
    final s = erzaehlSitzung(rollen: 4, fassung: Abendfassung.lang);
    bisZurEinleitung(s);
    expect([s.einstimmung?.teil, s.rundgang, s.kannWeiter], [EinstimmungTeil.vorgeschichte, null, false], reason: 'Das Vorspiel wartet');
    expect(bildschirm(s), isA<EinstimmungBildschirm>());
    while (s.einstimmung != null) {
      s.einstimmungWeiter();
    }
    expect(s.rundgang, RundgangTeil.vorspiel);
    expect(bildschirm(s), isA<RundgangBildschirm>());
    s.rundgangUeberspringen();
    expect([s.rundgang, s.kannWeiter], [null, isTrue]);
    expect(bildschirm(s), isA<IntroBildschirm>());
    expect(s.diashow, isNotNull);
  });

  testWidgets('Solo: Kapitel, Text und Vorstellungskarte; „Die App spielt …“ steht außerhalb des Vorlesetexts', (t) async {
    final s = erzaehlSitzung(rollen: 4, solo: true, detektivName: 'Ada');
    bisZurEinleitung(s);
    await _zeige(t, PartyAblauf(sitzung: s));
    expect(find.byType(EinstimmungBildschirm), findsOneWidget);
    final e = s.einstimmung!;
    expect(find.text(_de.einstimmung_zaehler(_de.einstimmung_vorgeschichte, '1', '${e.von}').toUpperCase()), findsOneWidget);
    expect(find.text(s.ui(e.titel)), findsOneWidget);
    expect(find.text(s.text(e.kennung)), findsOneWidget, reason: 'Solo steht der Text offen');
    expect(find.byType(VorstellungsKarte), findsNothing);
    expect(t.widget<ErzaehlerFeld>(find.byType(ErzaehlerFeld)).kennungen, [e.kennung]);
    // Ahmet: Karte mit Porträt, Name, Rolle, Satz und „Die App spielt Ahmet“.
    _bisFigur(s, 'ahmet');
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    final ahmet = s.einstimmung!;
    expect(find.text(_de.einstimmung_zaehler(_de.einstimmung_vorstellung, '2', '${ahmet.von}').toUpperCase()), findsOneWidget);
    expect(find.text(s.ui(Einstimmung.vorstellungTitel)), findsOneWidget, reason: 'Titel der Vorstellung');
    expect(_inKarte(find.text(s.figurName('ahmet'))), findsOneWidget);
    expect(_inKarte(find.text(s.figurTitel('ahmet'))), findsOneWidget);
    expect(_inKarte(find.text('„${erzaehlDaten.steckbriefe!.je['ahmet']!.satz}“')), findsOneWidget);
    expect(_inKarte(find.byType(MFotoabzug)), findsOneWidget);
    expect(_inKarte(find.text(_de.einstimmung_app_spielt(s.figurName('ahmet')))), findsOneWidget);
    expect(_imFeld(find.textContaining('App spielt')), findsNothing);
    expect(find.text(s.text('vorstellung.ahmet')), findsOneWidget);
    expect(t.widget<ErzaehlerFeld>(find.byType(ErzaehlerFeld)).kennungen, ['vorstellung.ahmet']);
    // Kein eigener Hinweis zum Aufstehen: Den Satz liest der Start vor.
    expect(find.textContaining('steht kurz auf'), findsNothing);
    // Der Detektiv zuletzt: gespielt von Ada.
    _bisFigur(s, Besetzung.detektiv);
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(_inKarte(find.text(s.ui('ui.einrichtung.detektiv_w'))), findsOneWidget);
    expect(_inKarte(find.text(_de.einstimmung_gespielt_von('Ada'))), findsOneWidget);
    expect(_inKarte(find.text('„${erzaehlDaten.steckbriefe!.je[Besetzung.detektiv]!.satz}“')), findsOneWidget);
    expect(find.byKey(const ValueKey('einstimmung-ueberspringen')), findsNothing, reason: 'Letzter Schritt');
    await t.tap(find.byKey(const ValueKey('einstimmung-weiter')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(s.einstimmung, isNull);
    expect(find.byType(IntroBildschirm), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Reihum mit Erzählerin: Das Pult deckt zu, „gespielt von …“ steht offen und nie im Vorlesefeld', (t) async {
    final s = erzaehlSitzung(rollen: 4, erzaehler: 'Mia', namen: const {'ahmet': 'Ben', 'fatma': 'Cleo'});
    bisZurEinleitung(s);
    await _zeige(t, EinstimmungBildschirm(sitzung: s));
    final start = s.einstimmung!.kennung;
    expect(find.byType(ErzaehlerpultZu), findsOneWidget);
    expect(find.text(s.text(start)), findsNothing, reason: 'Der Tisch sieht keinen Erzähltext');
    expect(find.text(s.ui(s.einstimmung!.titel)), findsOneWidget, reason: 'Kapiteltitel für alle');
    _bisFigur(s, 'ahmet');
    await t.pump();
    final k = s.einstimmung!.kennung;
    expect(find.byType(ErzaehlerpultZu), findsOneWidget);
    expect(find.text(s.text(k)), findsNothing);
    expect(_inKarte(find.text(_de.einstimmung_gespielt_von('Ben'))), findsOneWidget, reason: 'Die Karte ist öffentlich');
    expect(t.widget<ErzaehlerFeld>(find.byType(ErzaehlerFeld)).kennungen, [k], reason: 'Die Stimme bekommt genau diesen Baustein');
    s.pultZeigen();
    await t.pump();
    expect(find.text(s.text(k)), findsOneWidget, reason: 'Mia liest');
    expect(_imFeld(find.textContaining('gespielt von')), findsNothing);
    expect(s.text(k).contains('Ben'), isFalse, reason: 'Der Vorlesetext nennt keinen Spieler');
    expect(find.textContaining('steht kurz auf'), findsNothing);
    expect(wortgleich(s, k, s.text(k)), isTrue);
    // Weiter zu Fatma; das Pult bleibt bei Mia.
    await t.ensureVisible(find.byKey(const ValueKey('einstimmung-weiter')));
    await t.tap(find.byKey(const ValueKey('einstimmung-weiter')));
    await t.pump();
    expect(s.einstimmung!.figur, 'fatma');
    expect(_inKarte(find.text(_de.einstimmung_gespielt_von('Cleo'))), findsOneWidget);
    // Ohne eingetragenen Namen steht keine Zeile da (reihum, Olli).
    s.einstimmungWeiter();
    await t.pump();
    expect(s.einstimmung!.figur, 'olli');
    expect(find.byKey(const ValueKey('vorstellung-spieler')), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('Schmal und mit doppelter Schrift ohne Überlauf', (t) async {
    final s = erzaehlSitzung(rollen: 20, namen: const {'ahmet': 'Konstantin Wagenknecht-Papadopoulos'});
    bisZurEinleitung(s);
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    for (final figur in [null, 'ahmet', 'leyla', Besetzung.detektiv]) {
      if (figur != null) _bisFigur(s, figur);
      await t.pumpWidget(rahmen(MediaQuery(
        data: const MediaQueryData(size: Size(320, 640), textScaler: TextScaler.linear(2), disableAnimations: true),
        child: EinstimmungBildschirm(sitzung: s),
      )));
      await t.pump();
      expect(t.takeException(), isNull, reason: '$figur');
    }
  });
}
