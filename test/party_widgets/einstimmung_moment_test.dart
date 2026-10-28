// Finale Schlosskeller: Einstimmung (A-063) und „Dein Moment“ (§3) an einem
// Abend. Langer Abend reihum mit Erzählerin: Rollen → Vorgeschichte und
// Vorstellung → Vorspiel → Diashow → Runde 1 mit dem Moment. Beide Schichten
// stehen im Journal und kommen beim Fortsetzen zurück; die Einstimmung ändert
// am Spiel nichts (gleiche Folgen, Funde, Sterne und Endwert wie ohne). Die
// Erzählerakte zeigt als Ziele die Sterne, die die Rollen am Gerät sehen.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/detektei/akten.dart' show AkteInfo;
import 'package:mordakte/party/bildschirme/einstimmung.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/bildschirme/moment.dart' show MomentListe;
import 'package:mordakte/party/bildschirme/rundgang.dart';
import 'package:mordakte/party/bildschirme/streifzug.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/erzaehlerakte_ansicht.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'einfluss_hilfe.dart';
import 'erzaehl_hilfe.dart' show bisZurEinleitung;
import 'hilfe.dart';

Map<String, Object?> _json(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as Map<String, Object?>;

PartyDaten? _gesamt;

/// Der Schlosskeller, wie `PartyDaten.laden` ihn lädt: Welt, Diashow, Vorspiel
/// und Morgen, Steckbriefe, Erzählerakte und die Regeln von „Dein Moment“
/// (aus denen die Erzählerakte ihre Ziele nimmt).
PartyDaten get _daten => _gesamt ??= () {
      final e = (_json('content/party/akten.json')['akten'] as List).cast<Map<String, Object?>>().firstWhere((a) => a['id'] == 'schlosskeller');
      return PartyDaten.aus(
        (p) => _json('content/party/schlosskeller/$p'),
        _json('content/scenarios/ravensmoor.json'),
        welt: _json('content/welt/schlosskeller/welt.json'),
        akte: AkteInfo(
          id: 'schlosskeller',
          titel: e['titel'] as String,
          untertitel: e['untertitel'] as String,
          ton: e['ton'] as String,
          faehigkeiten: {for (final f in e['faehigkeiten'] as List) f as String},
        ),
        diashow: _json('content/welt/schlosskeller/diashow.json'),
        vorspielMorgen: _json('content/welt/schlosskeller/vorspiel_morgen.json'),
        einfluss: _json('content/party/zusatz/schlosskeller/einfluss.json'),
        erzaehlerakte: _json('content/party/schlosskeller/erzaehlerakte.json'),
        steckbriefe: _json('content/party/schlosskeller/steckbriefe.json'),
      );
    }();

/// Langer Abend reihum mit Erzählerin Mia, fünf Rollen, Pfad ahmet.
PartySitzung _abend({bool einstimmung = true, Abendfassung fassung = Abendfassung.lang, bool einfluss = true}) => PartySitzung(_daten, salz: 'einstimmung-moment')
  ..einrichten(
    rollen: 5,
    detektiv: 'w',
    code: FallCode.fuerPfad('ahmet', _daten.kanon.pfade).code,
    erzaehlerName: 'Mia',
    namen: const {'ahmet': 'Ben', 'fatma': 'Cleo'},
    fassung: fassung,
    einstimmung: einstimmung,
    einfluss: einfluss,
  );

Map<String, Object?> _einrichten(PartySitzung s) =>
    (s.abendstand['befehle'] as List).cast<Map<String, Object?>>().firstWhere((b) => b['b'] == 'einrichten');

PartySitzung _wiederAuf(PartySitzung s) => PartySitzung.fortsetzen(_daten, jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>);

/// Einstimmung Schritt für Schritt, dann das Vorspiel Station für Station.
void _einleitungDurch(PartySitzung s) {
  while (s.einstimmung != null) {
    s.einstimmungWeiter();
  }
  while (s.rundgang != null) {
    s.rundgangWeiter();
  }
}

/// Text der Sterne, wie die Rolle sie im Moment sieht.
List<String> _sterneVon(PartySitzung s, String rolle) {
  s.momentZeigen(rolle);
  final texte = [for (final z in s.zielStaende(rolle)) _daten.texte.einflussText(z.schluessel, figur: rolle)];
  s.verdecken();
  return texte;
}

void main() {
  test('Langer Abend: Einstimmung, Vorspiel, Diashow, dann Runde 1 mit „Dein Moment“; beides im Journal', () {
    final s = _abend();
    expect([s.mitEinstimmung, s.einfluss, s.lang], [true, true, true]);
    final e = _einrichten(s);
    expect([e['einstimmung'], e['einfluss'], e['fassung']], [true, true, 'lang']);
    expect(s.abendstand['format'], PartySitzung.abendstandFormat);

    bisZurEinleitung(s);
    final bausteine = s.spiel.bausteine.length;
    // Zuerst die Einstimmung: Vorspiel und Diashow warten, kein Moment.
    expect([s.einstimmung?.teil, s.rundgang, s.kannWeiter], [EinstimmungTeil.vorgeschichte, null, false]);
    expect(bildschirm(s), isA<EinstimmungBildschirm>());
    expect([s.momentOffen, s.momentFertig, s.folgenOffen], [isEmpty, isTrue, isFalse]);
    expect(() => s.momentZeigen('ahmet'), throwsStateError, reason: 'Kein Moment in der Einleitung');

    // Mitten in der Einstimmung abgelegt und fortgesetzt: Schritt, Schicht und Fassung bleiben.
    s
      ..einstimmungWeiter()
      ..einstimmungWeiter();
    final mitten = _wiederAuf(s);
    expect([mitten.einstimmungNr, mitten.mitEinstimmung, mitten.einfluss, mitten.lang, mitten.phase], [s.einstimmungNr, true, true, true, PartyPhase.intro]);
    mitten.dispose();

    // Vorgeschichte und Vorstellung bis zum Ende, dann das Vorspiel.
    while (s.einstimmung != null) {
      s.einstimmungWeiter();
    }
    expect(s.spiel.bausteine.length, bausteine, reason: 'Kein Text der Einstimmung in spiel.bausteine');
    expect([s.rundgang, s.kannWeiter], [RundgangTeil.vorspiel, false]);
    expect(bildschirm(s), isA<RundgangBildschirm>());
    while (s.rundgang != null) {
      s.rundgangWeiter();
    }
    // Die Einleitung mit der Diashow.
    expect([s.phase, s.kannWeiter], [PartyPhase.intro, true]);
    expect(s.diashow, isNotNull);
    expect(bildschirm(s), isA<IntroBildschirm>());
    s.weiter();

    // Runde 1: Streifzug mit dem Moment; ohne Züge geht es nicht weiter.
    expect([s.phase, s.runde], [PartyPhase.gespraeche, 1]);
    expect(bildschirm(s), isA<StreifzugBildschirm>());
    expect(s.momentOffen, s.besetzt);
    PartySkript.befragungenErledigen(s);
    expect(s.kannWeiter, isFalse, reason: 'Erst ziehen alle ihren Moment');
    alleZiehen(s);
    expect([s.momentOffen, s.kannWeiter], [isEmpty, isTrue]);
    s.weiter();
    expect(s.phase, PartyPhase.entscheidungen);
    expect(s.folgenOffen, isTrue);
    expect(s.erzaehler.first, 'einfluss.folgen.start.1');
    expect(s.erzaehler.where((k) => k.startsWith('vorgeschichte.') || k.startsWith('vorstellung.')), isEmpty);

    // Das Journal spielt beides zurück: dieselben Züge, Folgen und Bausteine.
    final b = _wiederAuf(s);
    expect([b.phase, b.runde, b.mitEinstimmung, b.einstimmung, b.einfluss], [PartyPhase.entscheidungen, 1, true, null, true]);
    for (final r in s.besetzt) {
      expect(b.einflussAbend!.stand.zug(1, r)?.art, s.einflussAbend!.stand.zug(1, r)?.art, reason: r);
    }
    expect(b.einflussAbend!.stand.folgenVon(1)?.toJson(), s.einflussAbend!.stand.folgenVon(1)?.toJson());
    expect(b.spiel.bausteine, s.spiel.bausteine);
    b.dispose();
    s.dispose();
  });

  test('Die Einstimmung ändert am Abend nichts: gleiche Folgen, Funde, Sterne und Endwert wie ohne', () {
    final mit = _abend(), ohne = _abend(einstimmung: false);
    for (final s in [mit, ohne]) {
      bisZurEinleitung(s);
      _einleitungDurch(s);
      einflussBis(s, PartyPhase.aufloesung);
    }
    expect([mit.phase, ohne.phase, mit.mitEinstimmung, ohne.mitEinstimmung], [PartyPhase.aufloesung, PartyPhase.aufloesung, true, false]);
    expect(mit.spiel.bausteine, containsAll(['einfluss.folgen.start.1', 'einfluss.folgen.start.2', 'einfluss.folgen.start.3']));
    expect(mit.spiel.bausteine, ohne.spiel.bausteine);
    final a = mit.einflussAbend!, o = ohne.einflussAbend!;
    for (var r = 1; r <= 3; r++) {
      expect(a.stand.folgenVon(r)?.toJson(), o.stand.folgenVon(r)?.toJson(), reason: 'Folgen Runde $r');
    }
    expect({for (final f in a.funde.entries) f.key: f.value.toJson()}, {for (final f in o.funde.entries) f.key: f.value.toJson()});
    expect(a.sterne(), o.sterne());
    expect(a.auszeichnungen().toJson(), o.auszeichnungen().toJson());
    expect(mit.spiel.endwert, ohne.spiel.endwert);
    mit.dispose();
    ohne.dispose();
  });

  test('Die Erzählerakte nennt als Ziele die Sterne von „Dein Moment“, wie die Rollen sie sehen', () {
    final s = _abend();
    final akte = _daten.erzaehlerakteFuer(einfluss: s.einfluss)!;
    einflussBis(s, PartyPhase.gespraeche);
    expect(s.erzaehlerakteSichtbar, isTrue);
    for (final r in s.besetzt) {
      final sterne = _sterneVon(s, r);
      expect(sterne, hasLength(2), reason: r);
      expect([for (final z in akte.figur(r)!.ziele) z.text], sterne, reason: r);
    }
    // Auch die Figuren ohne Spieler tragen ihre zwei Sterne, nie das Ziel des Kanons.
    for (final f in akte.figuren) {
      expect(f.ziele, hasLength(2), reason: f.figur);
      expect(f.ziele.map((z) => z.text), isNot(contains(_daten.kanon.figur(f.figur)?['persoenlichesZiel'])), reason: f.figur);
    }
    s.dispose();
  });

  testWidgets('Ohne „Dein Moment“ nennt die Erzählerakte die Ziele des Kanons, wie Rollenkarte und Dossier', (t) async {
    final s = _abend(einfluss: false, fassung: Abendfassung.kurz, einstimmung: false);
    addTearDown(s.dispose);
    expect([s.einfluss, s.erzaehlerakteSichtbar], [false, true]);
    final ziel = _daten.kanon.figur('leyla')!['persoenlichesZiel'] as String;
    expect([for (final z in _daten.erzaehlerakteFuer(einfluss: s.einfluss)!.figur('leyla')!.ziele) z.text], [ziel]);
    final sterne = [for (final z in _daten.erzaehlerakte!.figur('leyla')!.ziele) z.text];
    expect(sterne, hasLength(2));
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(rahmen(MediaQuery(
      data: const MediaQueryData(disableAnimations: true, size: Size(390, 844)),
      child: Builder(builder: (c) => TextButton(onPressed: () => erzaehlerakteZeigen(c, s), child: const Text('akte'))),
    )));
    await t.tap(find.text('akte'));
    await t.pumpAndSettle();
    final liste = find.descendant(of: find.byKey(const ValueKey('erzaehlerakte-figuren')), matching: find.byType(Scrollable)).first;
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-leyla')), 300, scrollable: liste);
    await t.ensureVisible(find.byKey(const ValueKey('akte-figur-leyla')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('akte-figur-leyla')));
    await t.pump();
    expect(find.text(ziel, skipOffstage: false), findsOneWidget);
    for (final stern in sterne) {
      expect(find.text(stern, skipOffstage: false), findsNothing, reason: stern);
    }
    expect(t.takeException(), isNull);
  });

  testWidgets('Am Gerät: Einstimmung, Vorspiel, Diashow, Runde 1 mit Moment-Liste; die Erzählerakte zeigt die Sterne', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = _abend();
    addTearDown(s.dispose);
    bisZurEinleitung(s);
    await t.pumpWidget(rahmen(MediaQuery(
      data: const MediaQueryData(disableAnimations: true, size: Size(390, 844)),
      child: PartyAblauf(sitzung: s),
    )));
    await t.pump();
    expect(find.byType(EinstimmungBildschirm), findsOneWidget);
    s.einstimmungUeberspringen();
    s.einstimmungUeberspringen();
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(EinstimmungBildschirm), findsNothing);
    expect(find.byType(RundgangBildschirm), findsOneWidget);
    s.rundgangUeberspringen();
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(IntroBildschirm), findsOneWidget);
    s.weiter();
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(StreifzugBildschirm), findsOneWidget);
    expect(find.byType(MomentListe), findsOneWidget);
    expect(t.takeException(), isNull);

    // Die Erzählerakte der Erzählerin: Ahmet (gespielt von Ben) mit seinen zwei Sternen.
    final sterne = _sterneVon(s, 'ahmet');
    await t.pumpWidget(rahmen(MediaQuery(
      data: const MediaQueryData(disableAnimations: true, size: Size(390, 844)),
      child: Builder(builder: (c) => TextButton(onPressed: () => erzaehlerakteZeigen(c, s), child: const Text('akte'))),
    )));
    await t.tap(find.text('akte'));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsOneWidget);
    final liste = find.descendant(of: find.byKey(const ValueKey('erzaehlerakte-figuren')), matching: find.byType(Scrollable)).first;
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-ahmet')), 300, scrollable: liste);
    await t.ensureVisible(find.byKey(const ValueKey('akte-figur-ahmet')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('akte-figur-ahmet')));
    await t.pump();
    for (final stern in sterne) {
      expect(find.text(stern, skipOffstage: false), findsOneWidget, reason: stern);
      await t.ensureVisible(find.text(stern, skipOffstage: false));
      await t.pump();
      expect(find.text(stern), findsOneWidget);
    }
    expect(find.text(_daten.kanon.figur('ahmet')!['persoenlichesZiel'] as String), findsNothing);
    expect(t.takeException(), isNull);
  });
}
