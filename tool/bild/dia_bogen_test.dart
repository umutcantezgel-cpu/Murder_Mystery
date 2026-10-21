// Kontaktbogen der Diashow zur Einleitung (Langer Abend M4): alle Bilder der
// Akte nebeneinander als Fotoabzüge, mitten in ihrer Fahrt, als PNG unter
// build/bild/dia_bogen_<akte>.png (zum Ansehen nach BILD-CHECKLISTE B6/B8).
// Geprüft wird nur, was sich ohne Auge prüfen lässt: kein Überlauf, keine
// Schrift im Bild (B6), im Bild nur die Figuren des Dias und der Prüfer ohne
// Befund (R15: nichts Pfadabhängiges, B8).
// Dazu ein Helligkeitsmaß je Bild (M7b): mittlere Luminanz der Szene im Abzug
// und ihrer Mitte (dort steht die erste Figur), und Bild 2 groß und allein
// unter build/m7b-belege/dia2.png für die Sichtprüfung (nicht einchecken).
// Aufruf: flutter test tool/bild/dia_bogen_test.dart  (AKTE=<id> für eine andere Akte mit Diashow)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/game_view.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/dia_session.dart';
import 'package:mordakte/party/diashow_ansicht.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../test/party_widgets/hilfe.dart' show echteSchriften;
import '../../test/party_widgets/luminanz.dart';

void main() {
  setUpAll(echteSchriften);

  testWidgets('Kontaktbogen der Diashow', (t) async {
    final fall = Platform.environment['AKTE'] ?? 'schlosskeller';
    final d = (await t.runAsync(() => PartyDaten.laden(rootBundle, fall: fall)))!;
    final show = d.diashow;
    expect(show, isNotNull, reason: '$fall hat keine Diashow');
    expect(pruefeDiashow(show!, d.kanon, (k) => d.texte.sammlung.bausteine[k]), isEmpty);
    const breite = 380.0, spalten = 3;
    final zeilen = (show.dias.length / spalten).ceil();
    t.view.physicalSize = Size(breite * spalten + 40, zeilen * 300 + 40);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    const bogen = ValueKey('dia-bogen');
    await t.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF1B1712),
        body: RepaintBoundary(
          key: bogen,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: [
                for (var i = 0; i < show.dias.length; i++)
                  SizedBox(
                    width: breite,
                    // Mitten in der Fahrt: Schwenk und Zoom sind zu sehen.
                    child: DiashowAnsicht(daten: d, nr: i, beschriftung: '${i + 1}', testUhr: () => DiaSession.fahrtSekunden / 2),
                  ),
              ],
            ),
          ),
        ),
      ),
    ));
    // Die Engine lädt Bilder und Figuren wirklich nebenläufig.
    for (var i = 0; i < 12; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 120)));
      await t.pump(const Duration(milliseconds: 120));
    }
    expect(t.takeException(), isNull);
    final ansichten = find.byType(DiashowAnsicht);
    expect(ansichten, findsNWidgets(show.dias.length));
    // B6: kein Text im Bild (die Beschriftung liest nur der Bildschirmleser).
    expect(find.descendant(of: ansichten, matching: find.byType(Text)), findsNothing);
    // Im Bild stehen genau die Figuren des Dias (der Detektiv als Fotoabzug am Rand).
    final sessions = [for (final g in t.widgetList<GameView>(find.byType(GameView))) g.session as DiaSession];
    expect(sessions, hasLength(show.dias.length));
    for (final s in sessions) {
      final soll = {for (final f in s.dia.figuren) ?d.npcKennung[f]};
      expect({for (final n in s.figurenAnsicht().npcs) n.id}, soll, reason: 'Bild ${s.nr + 1}');
    }
    final grenze = t.renderObject<RenderRepaintBoundary>(find.byKey(bogen));
    final ursprung = t.getTopLeft(find.byKey(bogen));
    // Szene je Bild: der Ausschnitt (ClipRect) um die GameView, ohne den Rand des Abzugs.
    final szenen = [
      for (var i = 0; i < show.dias.length; i++)
        t.getRect(find.ancestor(of: find.byKey(const ValueKey('dia-szene')).at(i), matching: find.byType(ClipRect)).first).shift(-ursprung),
    ];
    final aus = await t.runAsync(() async {
      final bild = await grenze.toImage();
      final png = (await bild.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      final roh = (await bild.toByteData())!;
      final breite = bild.width, hoehe = bild.height;
      bild.dispose();
      return (png: png, roh: roh, breite: breite, hoehe: hoehe);
    });
    Directory('build/bild').createSync(recursive: true);
    File('build/bild/dia_bogen_$fall.png').writeAsBytesSync(aus!.png);
    // ignore: avoid_print
    print('$fall: ${show.dias.length} Bilder → build/bild/dia_bogen_$fall.png');
    for (final (i, r) in szenen.indexed) {
      final ganz = mittlereLuminanz(aus.roh, aus.breite, aus.hoehe, r.deflate(r.shortestSide * 0.05));
      final mitte = mittlereLuminanz(aus.roh, aus.breite, aus.hoehe, Rect.fromCenter(center: r.center, width: r.width * 0.4, height: r.height * 0.4));
      expect(ganz, inInclusiveRange(0.0, 1.0));
      // ignore: avoid_print
      print('Bild ${i + 1} (${show.dias[i].stimmung.name}): Luminanz Szene ${ganz.toStringAsFixed(4)}, Mitte ${mitte.toStringAsFixed(4)}');
    }

    // Bild 2 groß und allein für die Sichtprüfung (M7b, nicht einchecken).
    if (show.dias.length > 1) {
      const gross = ValueKey('dia-2-gross');
      t.view.physicalSize = const Size(940, 700);
      await t.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF1B1712),
          body: Center(
            child: RepaintBoundary(
              key: gross,
              child: SizedBox(width: 900, child: DiashowAnsicht(daten: d, nr: 1, beschriftung: '2', testUhr: () => DiaSession.fahrtSekunden / 2)),
            ),
          ),
        ),
      ));
      for (var i = 0; i < 12; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 120)));
        await t.pump(const Duration(milliseconds: 120));
      }
      expect(t.takeException(), isNull);
      final png = await t.runAsync(() async {
        final bild = await t.renderObject<RenderRepaintBoundary>(find.byKey(gross)).toImage();
        final png = (await bild.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
        bild.dispose();
        return png;
      });
      Directory('build/m7b-belege').createSync(recursive: true);
      File('build/m7b-belege/dia2.png').writeAsBytesSync(png!);
      // ignore: avoid_print
      print('Bild 2 groß → build/m7b-belege/dia2.png');
    }
    await t.pumpWidget(const SizedBox.shrink());
  });
}
