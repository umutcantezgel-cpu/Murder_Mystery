import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../ui/widgets/portrait.dart';

// Porträts für die Druckfassung (Erzählerakte, Druckpaket): je Figur der Akte
// und für den Detektiv (`detektiv-w`, `detektiv-m`) ein Brustbild als PNG auf
// ruhigem, hellem Atelierhintergrund, aus demselben Zeichner wie im Spiel
// (PortraitPainter, Aussehen aus `renderLook`). Die App zeichnet sie beim
// Erstellen der Erzählerakte, die Bildwerkstatt (`tool/bild/druck_portraets_test.dart`)
// für die Kommandozeile in 720 px.

/// Der Detektiv als Detektivin (`w`) oder Detektiv (`m`): Aussehen aus dem Kanon, dazu das
/// Geschlecht für die Darstellung. `m` zeichnet genau die Figur des Spiels (das Spiel kennt
/// nur diese eine Detektivfigur). Die Detektivin trägt dieselbe Kleidung, Hut und Brille;
/// ihre Haarfarbe weicht nur im Blaukanal um eins ab ([detektivinHaar]), damit der Zeichner
/// (Frisur aus dem Hash des Aussehens) lange Haare unter dem Hut zeigt: erkennbar eine Frau.
LookDef detektivLook(Map<String, Object?> detektiv, String g) =>
    LookDef.fromJson({...renderLook(detektiv), 'gender': g, if (g == 'w') 'hair': detektivinHaar});

/// Haarfarbe der Detektivin im Druck (Kanon: `#4b3123`), siehe [detektivLook].
const detektivinHaar = '#4b3122';

/// Das Aussehen aller Porträts der Druckfassung: die Figuren der Akte in ihrer
/// Reihenfolge, dann `detektiv-w` und `detektiv-m`. Das Opfer bekommt keins.
Map<String, LookDef> druckLooks(Kanon kanon) {
  final detektiv = (kanon.figurenJson['detektiv'] as Map).cast<String, Object?>();
  return {
    for (final f in kanon.figuren) f['id'] as String: LookDef.fromJson(renderLook(f)),
    for (final g in ['w', 'm']) 'detektiv-$g': detektivLook(detektiv, g),
  };
}

/// Porträt als PNG mit [groesse] Pixeln Kantenlänge: heller, warmer
/// Atelierhintergrund mit sanfter Vignette, darauf die Büste.
Future<Uint8List> portraetPng(LookDef look, {double groesse = 360}) async {
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  final r = Rect.fromLTWH(0, 0, groesse, groesse);
  c.drawRect(
    r,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.35),
        radius: 1.05,
        colors: [Color(0xFFF4EDE0), Color(0xFFE2D6C1), Color(0xFFC9B99E)],
        stops: [0, 0.55, 1],
      ).createShader(r),
  );
  PortraitPainter(look: look, background: false).paint(c, Size.square(groesse));
  final bild = await rec.endRecording().toImage(groesse.round(), groesse.round());
  try {
    final png = await bild.toByteData(format: ui.ImageByteFormat.png);
    return png!.buffer.asUint8List();
  } finally {
    bild.dispose();
  }
}

/// Alle Porträts der Druckfassung ([druckLooks]) als PNG, Schlüssel wie in
/// `FestPortraets`. Zwischen zwei Bildern kommt die Oberfläche zum Zug (im
/// Browser gibt es keine Isolates), damit der Ladehinweis weiterläuft.
Future<Map<String, Uint8List>> druckPortraets(Kanon kanon, {double groesse = 360}) async {
  final bilder = <String, Uint8List>{};
  for (final e in druckLooks(kanon).entries) {
    bilder[e.key] = await portraetPng(e.value, groesse: groesse);
    await Future<void>.delayed(Duration.zero);
  }
  return bilder;
}

/// Wie die App die Porträts für ihre Druckfassung zeichnet ([druckPortraets]);
/// Tests setzen hier kleine Ersatzbilder ein wie bei `dateiTeilenUeber`.
@visibleForTesting
Future<Map<String, Uint8List>> Function(Kanon kanon) druckPortraetsUeber = druckPortraets;

/// Die Porträts, die die App in die Erzählerakte setzt ([druckPortraetsUeber]).
Future<Map<String, Uint8List>> appDruckPortraets(Kanon kanon) => druckPortraetsUeber(kanon);
