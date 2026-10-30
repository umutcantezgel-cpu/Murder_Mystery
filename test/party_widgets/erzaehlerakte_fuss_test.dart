// Erzählerakte und Druckmappe am schmalen Handy mit großer Schrift (A-063, PDF-Paket),
// mit den echten Schriften: Im Browser und in der Android-App ersetzt die fertige Datei
// „Als PDF“ durch einen Knopf je Weg. Im engen Fuß der Erzählerakte stehen dort nur
// „Herunterladen“ und „Teilen“ (der Bildschirmleser hört den Dateinamen), damit die
// Figurenliste bleibt und nichts überläuft. Kein Dateiknopf bricht ein Wort mitten durch,
// auch nicht in der Druckmappe. Während die Datei entsteht, steht eine ruhende Sanduhr da,
// kein Ladekreis.
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/datei_knopf.dart';
import 'package:mordakte/party/druck_portraets.dart';
import 'package:mordakte/party/druck_speichern.dart';
import 'package:mordakte/party/druck_speichern_stub.dart' as app;
import 'package:mordakte/party/druck_tafel.dart';
import 'package:mordakte/party/erzaehlerakte_ansicht.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/stil/widgets/m_ganze_worte.dart' show ganzeWorteGroesse;
import 'package:mordakte_core/mordakte_core.dart';

import 'erzaehl_hilfe.dart';
import 'hilfe.dart';

final _de = LDe();

/// Ein Browser, der Dateien herunterladen und (mit [teilen]) teilen kann.
class _Browser extends DateiGeraet {
  _Browser({this.teilen = true});

  final bool teilen;
  final angeboten = <(String, DateiWeg)>[];

  @override
  bool get zweiterTipp => true;

  @override
  bool get kannHerunterladen => true;

  @override
  bool get herunterladenMitDialog => false;

  @override
  bool kannTeilen(String name, String typ) => teilen;

  @override
  Future<bool> anbieten(String name, Uint8List bytes, {required String typ, Rect? ursprung, required DateiWeg weg}) async {
    angeboten.add((name, weg));
    return true;
  }
}

/// Setzt [browser] für diesen Test als Gerät ein.
void _imBrowser(_Browser browser) {
  final vorher = dateiGeraet;
  dateiGeraet = browser;
  addTearDown(() => dateiGeraet = vorher);
}

Future<void> _zeige(WidgetTester t, Widget kind, {required Size groesse, double schrift = 2}) async {
  t.view.physicalSize = groesse;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(MediaQuery(data: MediaQueryData(disableAnimations: true, size: groesse, textScaler: TextScaler.linear(schrift)), child: kind)));
  await t.pump();
}

/// Wartet in echter Zeit, bis [fertig] gilt (die PDF-Erzeugung läuft wirklich).
Future<void> _warte(WidgetTester t, bool Function() fertig) async {
  for (var i = 0; i < 600 && !fertig(); i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await t.pump(const Duration(milliseconds: 20));
  }
  await t.pump();
}

/// Wörter in den Texten von [f], die im gesetzten Absatz über zwei Zeilen laufen. Nach
/// einem Bindestrich darf die Zeile umbrechen (wie bei [ganzeWorteGroesse]).
List<String> _gebrochen(Finder f) => [
      for (final e in f.evaluate())
        if (e.renderObject case final RenderParagraph p)
          for (final m in RegExp(r'[^\s\-–]+[\-–]?').allMatches(p.text.toPlainText()))
            if (p.getBoxesForSelection(TextSelection(baseOffset: m.start, extentOffset: m.end)).map((b) => b.top.round()).toSet().length > 1) m.group(0)!,
    ];

/// Texte in Knöpfen unter [unter].
Finder _knopfTexte(Finder unter) => find.descendant(of: unter, matching: find.descendant(of: find.byWidgetPredicate((w) => w is ButtonStyleButton), matching: find.byType(RichText)));

void main() {
  setUpAll(echteSchriften);

  for (final (groesse, teilen) in [(const Size(320, 640), true), (const Size(320, 568), true), (const Size(320, 568), false)]) {
    testWidgets('Fuß der Erzählerakte ${groesse.width.round()}×${groesse.height.round()}, Schrift 2, Browser ${teilen ? 'mit' : 'ohne'} Teilen: '
        'nach dem Bauen bleibt die Figurenliste, nichts läuft über, kein Wort bricht', (t) async {
      final s = erzaehlSitzung(rollen: 20, erzaehler: 'Mia', einstimmung: false);
      final portraets = Completer<Map<String, Uint8List>>();
      final vorher = druckPortraetsUeber;
      druckPortraetsUeber = (k) => portraets.future;
      addTearDown(() => druckPortraetsUeber = vorher);
      final browser = _Browser(teilen: teilen);
      _imBrowser(browser);
      await _zeige(t, ErzaehlerakteSeite(daten: s.daten, besetzt: s.besetzt, einfluss: false, rollen: 20, spieler: (f) => s.namen[f]), groesse: groesse);
      final liste = find.byKey(const ValueKey('erzaehlerakte-figuren'));
      final seite = find.byKey(const ValueKey('erzaehlerakte-seite'));
      final vorDemTipp = t.getSize(liste).height;
      expect(t.takeException(), isNull);

      // Während die Datei entsteht: Sanduhr und Hinweis, kein Ladekreis.
      await t.tap(find.text(_de.erzaehlerakte_pdf));
      await t.pump(const Duration(milliseconds: 20));
      await t.pump(const Duration(milliseconds: 20));
      expect(find.text(_de.druck_datei_laedt), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(t.takeException(), isNull);

      portraets.complete(ersatzPortraets(s.daten.kanon));
      final laden = find.text(_de.druck_datei_laden_kurz);
      await _warte(t, () => laden.evaluate().isNotEmpty);
      expect(laden, findsOneWidget);
      expect(find.text(_de.druck_datei_teilen_kurz), teilen ? findsOneWidget : findsNothing);
      expect(t.takeException(), isNull, reason: 'Kein Überlauf im Fuß');
      final danach = t.getSize(liste).height;
      expect(danach, greaterThan(vorDemTipp / 3), reason: 'Die Figurenliste bleibt ($vorDemTipp → $danach px)');
      expect(_gebrochen(_knopfTexte(seite)), isEmpty);

      // Der Bildschirmleser hört den vollen Namen; der Tipp lädt die Erzählerakte herunter.
      final semantik = t.ensureSemantics();
      expect(find.bySemanticsLabel(_de.druck_datei_laden(s.ui('ui.druck.akte.titel'))), findsOneWidget);
      semantik.dispose();
      await t.tap(laden);
      await t.pump();
      expect(browser.angeboten, [('erzaehlerakte.pdf', DateiWeg.herunterladen)]);
    });
  }

  testWidgets('Fuß der Erzählerakte 320×568, Schrift 2, Android-App: „Herunterladen“ und „Teilen“ ohne Überlauf, '
      '„Herunterladen“ öffnet den Speichern-Dialog', (t) async {
    mitErsatzPortraets();
    final vorherAndroid = app.aufAndroid;
    app.aufAndroid = true;
    addTearDown(() => app.aufAndroid = vorherAndroid);
    const kanal = MethodChannel('mordakte/datei');
    final gespeichert = <MethodCall>[];
    final bote = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    bote.setMockMethodCallHandler(kanal, (c) async {
      gespeichert.add(c);
      return true;
    });
    addTearDown(() => bote.setMockMethodCallHandler(kanal, null));
    const groesse = Size(320, 568);
    final s = erzaehlSitzung(rollen: 20, erzaehler: 'Mia', einstimmung: false);
    await _zeige(t, ErzaehlerakteSeite(daten: s.daten, besetzt: s.besetzt, einfluss: false, rollen: 20, spieler: (f) => s.namen[f]), groesse: groesse);
    final liste = find.byKey(const ValueKey('erzaehlerakte-figuren'));
    final vorDemTipp = t.getSize(liste).height;

    await t.tap(find.text(_de.erzaehlerakte_pdf));
    final laden = find.text(_de.druck_datei_laden_kurz);
    await _warte(t, () => laden.evaluate().isNotEmpty);
    expect(laden, findsOneWidget);
    expect(find.text(_de.druck_datei_teilen_kurz), findsOneWidget);
    expect(gespeichert, isEmpty, reason: 'Der erste Tipp baut nur');
    expect(t.takeException(), isNull, reason: 'Kein Überlauf im Fuß');
    expect(t.getSize(liste).height, greaterThan(vorDemTipp / 3), reason: 'Die Figurenliste bleibt');
    expect(_gebrochen(_knopfTexte(find.byKey(const ValueKey('erzaehlerakte-seite')))), isEmpty);

    await t.tap(laden);
    await t.pump();
    final a = gespeichert.single.arguments as Map<Object?, Object?>;
    expect(a['name'], 'erzaehlerakte.pdf');
    expect(String.fromCharCodes((a['bytes']! as Uint8List).take(5)), '%PDF-');
    expect(a['gespeichert'], _de.druck_datei_gespeichert('erzaehlerakte.pdf'));
  });

  testWidgets('Während die Datei entsteht: ruhende Sanduhr statt Ladekreis, auch ohne „Bewegung reduzieren“', (t) async {
    _imBrowser(_Browser());
    final fertig = Completer<FertigeDatei>();
    await t.pumpWidget(rahmen(MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: Center(child: DateiKnopf(text: _de.erzaehlerakte_pdf, bauen: () => fertig.future)),
    )));
    await t.tap(find.text(_de.erzaehlerakte_pdf));
    await t.pump(const Duration(milliseconds: 20));
    await t.pump(const Duration(milliseconds: 20));
    expect(find.text(_de.druck_datei_laedt), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing, reason: 'Ein Ladekreis ließe die Seite bei jedem Zwischenschritt neu zeichnen');
    expect(t.binding.hasScheduledFrame, isFalse, reason: 'Nichts bewegt sich, solange die Datei entsteht');
    fertig.complete((name: 'erzaehlerakte.pdf', bytes: Uint8List.fromList('%PDF-'.codeUnits)));
    await t.pump();
    await t.pump();
    expect(find.text(_de.druck_datei_laden(_de.erzaehlerakte_pdf)), findsOneWidget);
  });

  testWidgets('Druckmappe bei 320 px, Schrift 2: kein Dateiknopf bricht ein Wort, auch nicht im Browser nach dem Bauen', (t) async {
    mitErsatzPortraets();
    _imBrowser(_Browser());
    final d = erzaehlDaten;
    final s = PartySitzung(d)..einrichten(rollen: 6, detektiv: 'w', code: FallCode.fuerPfad('ahmet', d.kanon.pfade).code, druck: true);
    await _zeige(t, SingleChildScrollView(child: DruckTafel(sitzung: s, erzaehlerakte: true)), groesse: const Size(320, 640));
    expect(t.takeException(), isNull);
    final tafel = find.byType(DruckTafel);
    expect(_knopfTexte(tafel), findsWidgets);
    expect(_gebrochen(_knopfTexte(tafel)), isEmpty);

    final titel = s.ui('ui.druck.akte.titel');
    await t.ensureVisible(find.text(titel));
    await t.tap(find.text(titel));
    await t.pump();
    final laden = find.text(_de.druck_datei_laden(titel));
    await _warte(t, () => laden.evaluate().isNotEmpty);
    expect(laden, findsOneWidget, reason: 'In der Druckmappe steht der Dateiname auf dem Knopf');
    expect(t.takeException(), isNull);
    expect(_gebrochen(_knopfTexte(tafel)), isEmpty);
  });
}
