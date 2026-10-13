// F4-BAUMEISTER-01: Einrichtungsbildschirm (Master 7.6, Schritt 2). Jeder Test prüft eine Sache.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte/party/bildschirme/einrichtung.dart';
import 'package:mordakte/stil/stil.dart' show MFotoabzug;
import 'package:mordakte/party/sitzung.dart';

import 'hilfe.dart';

/// Frische Sitzung in der Einrichtung (der Titel ist durch).
PartySitzung _einrichtung() {
  final s = neueSitzung();
  s.zurEinrichtung();
  return s;
}

/// Setzt die Ansicht auf [breite] × [hoehe] Pixel bei Dichte 1.
void _ansicht(WidgetTester t, double breite, double hoehe) {
  t.view.physicalSize = Size(breite, hoehe);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
}

/// Tippt auf [f]. Liegt das Ziel in einer Scrollfläche, wird vorher dorthin gescrollt.
Future<void> _tippe(WidgetTester t, Finder f) async {
  if (find.ancestor(of: f, matching: find.byType(Scrollable)).evaluate().isNotEmpty) {
    await t.ensureVisible(f);
  }
  await t.tap(f);
  await t.pump();
}

/// Schreibt [text] in das Feld [f].
Future<void> _schreibe(WidgetTester t, Finder f, String text) async {
  await t.ensureVisible(f);
  await t.enterText(f, text);
  await t.pump();
}

/// Die Zeilen der besetzten Rollen (je Zeile ein Fotoabzug der Figur).
Finder _zeilen() => find.byType(MFotoabzug);

void main() {
  testWidgets('Vorgabe 7 zeigt 7 besetzte Rollen', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    expect(_zeilen(), findsNWidgets(7));
  });

  testWidgets('Eine Person mehr zeigt 8 Rollen', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    await _tippe(t, find.byTooltip(s.ui('ui.einrichtung.mehr')));
    expect(_zeilen(), findsNWidgets(8));
  });

  testWidgets('Auf 4 Personen zeigt genau die vier Rollen der Besetzung', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    for (var i = 0; i < 3; i++) {
      await _tippe(t, find.byTooltip(s.ui('ui.einrichtung.weniger')));
    }
    expect(_zeilen(), findsNWidgets(4));
    for (final r in s.rollenBei(4)) {
      expect(find.byKey(ValueKey('rolle-$r')), findsOneWidget, reason: r);
    }
  });

  testWidgets('Rollen über der Besetzung von 4 verschwinden beim Senken', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    for (var i = 0; i < 3; i++) {
      await _tippe(t, find.byTooltip(s.ui('ui.einrichtung.weniger')));
    }
    for (final r in s.rollenBei(7).skip(4)) {
      expect(find.byKey(ValueKey('rolle-$r')), findsNothing, reason: r);
    }
  });

  testWidgets('Spielername wird beim Start in der Sitzung übernommen', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    await _schreibe(t, find.byKey(const ValueKey('name-fatma')), 'Lena');
    await _tippe(t, find.text(s.ui('ui.einrichtung.start')));
    expect(s.spielerName('fatma'), 'Lena');
  });

  testWidgets('Spielernamen bleiben erhalten, wenn sich die Anzahl ändert', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    await _schreibe(t, find.byKey(const ValueKey('name-fatma')), 'Lena');
    for (var i = 0; i < 3; i++) {
      await _tippe(t, find.byTooltip(s.ui('ui.einrichtung.weniger')));
    }
    await _tippe(t, find.byTooltip(s.ui('ui.einrichtung.mehr')));
    final feld = t.widget<TextField>(find.byKey(const ValueKey('name-fatma')));
    expect(feld.controller!.text, 'Lena');
  });

  testWidgets('Die Detektivin oder der Detektiv wird beim Start übernommen', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    await _tippe(t, find.text(s.ui('ui.einrichtung.detektiv_m')));
    await _tippe(t, find.text(s.ui('ui.einrichtung.start')));
    expect(s.einstellungen.detektiv, 'm');
  });

  testWidgets('ungültiger Code sperrt den Start und zeigt die Fehlerzeile', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    await _tippe(t, find.text(s.ui('ui.einrichtung.code_eingabe')));
    await _schreibe(t, find.byKey(const ValueKey('code')), 'AB');
    expect(find.text(s.ui('ui.einrichtung.code_fehler')), findsOneWidget);
    final knopf = t.widget<FilledButton>(find.widgetWithText(FilledButton, s.ui('ui.einrichtung.start')));
    expect(knopf.onPressed, isNull);
  });

  testWidgets('gültiger Code wird zum Fall der Sitzung', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    final code = FallCode.fuerPfad('olli', partyDaten.kanon.pfade).code;
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    await _tippe(t, find.text(s.ui('ui.einrichtung.code_eingabe')));
    await _schreibe(t, find.byKey(const ValueKey('code')), code);
    await _tippe(t, find.text(s.ui('ui.einrichtung.start')));
    expect(s.fallCode.code, code);
  });

  testWidgets('Rundendauer 45 Minuten wird übernommen', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    await _tippe(t, find.text(s.ui('ui.einrichtung.minuten', {'minuten': '45'})));
    await _tippe(t, find.text(s.ui('ui.einrichtung.start')));
    expect(s.rundendauer, const Duration(minutes: 45));
  });

  testWidgets('Druckspiel wird übernommen', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    await _tippe(t, find.text(s.ui('ui.einrichtung.spiel_druck')));
    await _tippe(t, find.text(s.ui('ui.einrichtung.start')));
    expect(s.einstellungen.druck, isTrue);
  });

  testWidgets('Erzählerstimme an wird beim Start übernommen', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    await _tippe(t, find.text(s.ui('ui.einrichtung.stimme_schalter')));
    await _tippe(t, find.text(s.ui('ui.einrichtung.start')));
    expect(s.stimmeAn, isTrue);
  });

  testWidgets('ohne Überlauf auf 1280 × 800 mit 20 Rollen', (t) async {
    _ansicht(t, 1280, 800);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    for (var i = 0; i < 13; i++) {
      await _tippe(t, find.byTooltip(s.ui('ui.einrichtung.mehr')));
    }
    expect(_zeilen(), findsNWidgets(20));
    expect(t.takeException(), isNull);
  });

  testWidgets('ohne Überlauf auf 390 × 844 mit 20 Rollen', (t) async {
    _ansicht(t, 390, 844);
    final s = _einrichtung();
    await t.pumpWidget(rahmen(EinrichtungBildschirm(sitzung: s)));
    for (var i = 0; i < 13; i++) {
      await _tippe(t, find.byTooltip(s.ui('ui.einrichtung.mehr')));
    }
    expect(_zeilen(), findsNWidgets(20));
    expect(t.takeException(), isNull);
  });
}
