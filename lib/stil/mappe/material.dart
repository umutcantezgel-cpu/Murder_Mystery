import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Deterministischer Zufall für Materialien (Fasern, Flecken, Körnung): gleiche
/// Größe und gleicher [samen] ergeben immer dasselbe Bild. Keine Spiellogik,
/// nur Darstellung; deshalb ein eigener kleiner Generator statt `dart:math`.
class MaterialZufall {
  MaterialZufall(int samen) : _z = (samen ^ 0x9E3779B9) & 0x7fffffff;
  int _z;

  /// Gleichverteilt in [0, 1).
  double naechste() {
    _z = (_z * 1103515245 + 12345) & 0x7fffffff;
    return _z / 0x80000000;
  }

  double zwischen(double a, double b) => a + (b - a) * naechste();
}

/// Arten eines Papiers.
enum PapierArt {
  /// Aktenpapier: warm, mit Fasern, Stockflecken und dunklerem Rand.
  akte,

  /// Karteikarte: kühler, mit roter Kopflinie und blauen Linien.
  karteikarte,

  /// Notizblock: liniert, mit rotem Rand und Lochung.
  notiz,

  /// Telegramm: gelbliches Formular.
  telegramm,

  /// Fotoabzug: weißer Rand, matter Glanz.
  foto,
}

/// Malt ein gealtertes Blatt: Grundverlauf, Fasern, Flecken, Ränder, optional
/// Linien, Lochung und ein Knick. Wird einmal gezeichnet und gecacht
/// (RepaintBoundary um das Blatt).
class PapierMaler extends CustomPainter {
  const PapierMaler({
    this.art = PapierArt.akte,
    this.samen = 7,
    this.knick = false,
    this.flecken = true,
    this.zeilenAbstand = 26,
    this.kopf = 0,
  });

  final PapierArt art;
  final int samen;

  /// Waagerechter Knick in der Mitte (gefaltetes Schreiben).
  final bool knick;

  /// Stockflecken und Kaffeerand.
  final bool flecken;

  /// Abstand der Linien bei Karteikarte und Notiz.
  final double zeilenAbstand;

  /// Höhe des Kopfbereichs (Karteikarte: über der roten Linie).
  final double kopf;

  Color get _grund => switch (art) {
        PapierArt.akte => MRoh.blatt,
        PapierArt.karteikarte => MRoh.karteikarte,
        PapierArt.notiz => const Color(0xFFF6F1E3),
        PapierArt.telegramm => const Color(0xFFF1E3B8),
        PapierArt.foto => const Color(0xFFF8F6F0),
      };

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final z = MaterialZufall(samen * 7919 + size.width.round() * 31 + size.height.round());
    final g = _grund;

    // Grund: leichter Verlauf vom Licht oben links zum Schatten unten rechts.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [Color.lerp(g, Colors.white, 0.35)!, g, Color.lerp(g, MRoh.blattSchatten, 0.55)!],
          const [0, 0.55, 1],
        ),
    );

    // Wolkige Unruhe im Papier (große, sehr blasse Flecken).
    final wolke = Paint();
    final wolken = (size.width * size.height / 9000).clamp(4, 60).toInt();
    for (var i = 0; i < wolken; i++) {
      final c = Offset(z.naechste() * size.width, z.naechste() * size.height);
      final r = z.zwischen(18, 70);
      wolke.shader = ui.Gradient.radial(c, r, [MRoh.blattSchatten.withValues(alpha: z.zwischen(0.05, 0.12)), MRoh.blattSchatten.withValues(alpha: 0)]);
      canvas.drawCircle(c, r, wolke);
    }

    // Fasern: kurze, blasse Striche.
    final faser = Paint()
      ..strokeWidth = 0.6
      ..strokeCap = StrokeCap.round;
    final fasern = (size.width * size.height / 350).clamp(20, 900).toInt();
    for (var i = 0; i < fasern; i++) {
      final p = Offset(z.naechste() * size.width, z.naechste() * size.height);
      final w = z.zwischen(-0.6, 0.6);
      final l = z.zwischen(2, 7);
      faser.color = (z.naechste() < 0.5 ? MRoh.tinte : Colors.white).withValues(alpha: z.zwischen(0.03, 0.08));
      canvas.drawLine(p, p + Offset(l, l * w), faser);
    }

    // Feine Pünktchen.
    final punkt = Paint();
    final punkte = (size.width * size.height / 700).clamp(10, 500).toInt();
    for (var i = 0; i < punkte; i++) {
      punkt.color = MRoh.tinte.withValues(alpha: z.zwischen(0.04, 0.14));
      canvas.drawCircle(Offset(z.naechste() * size.width, z.naechste() * size.height), z.zwischen(0.2, 0.8), punkt);
    }

    // Stockflecken und ein Kaffeerand (nur Aktenpapier).
    if (flecken && art == PapierArt.akte) {
      final fleck = Paint();
      final anzahl = 2 + (z.naechste() * 4).floor();
      for (var i = 0; i < anzahl; i++) {
        final c = Offset(z.naechste() * size.width, z.naechste() * size.height);
        final r = z.zwischen(3, 11);
        fleck.shader = ui.Gradient.radial(c, r, [const Color(0x33966A2E), const Color(0x00966A2E)]);
        canvas.drawCircle(c, r, fleck);
      }
      if (z.naechste() < 0.45 && size.width > 160) {
        final c = Offset(size.width * z.zwischen(0.65, 0.9), size.height * z.zwischen(0.65, 0.9));
        final r = z.zwischen(26, 38);
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = z.zwischen(1.6, 2.6)
            ..color = const Color(0x1F7A4A1E),
        );
      }
    }

    // Linien.
    if (art == PapierArt.karteikarte || art == PapierArt.notiz) {
      final blau = Paint()
        ..color = MRoh.linieBlau
        ..strokeWidth = 1;
      final start = art == PapierArt.karteikarte ? (kopf > 0 ? kopf : 34.0) : 30.0;
      for (var y = start + zeilenAbstand; y < size.height - 4; y += zeilenAbstand) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), blau);
      }
      final rot = Paint()
        ..color = MRoh.linieRot
        ..strokeWidth = art == PapierArt.karteikarte ? 1.6 : 1.1;
      if (art == PapierArt.karteikarte) {
        canvas.drawLine(Offset(0, start), Offset(size.width, start), rot);
      } else {
        canvas.drawLine(const Offset(30, 0), Offset(30, size.height), rot);
      }
    }
    if (art == PapierArt.notiz) {
      final loch = Paint()..color = MRoh.leder.withValues(alpha: 0.75);
      for (var y = 28.0; y < size.height - 12; y += 68) {
        canvas.drawCircle(Offset(12, y), 4.2, loch);
      }
    }
    if (art == PapierArt.telegramm) {
      final band = Paint()..color = const Color(0x22A3242F);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 6), band);
    }

    // Knick: Schatten unter, Licht über der Faltlinie.
    if (knick) {
      final y = size.height * 0.5;
      canvas.drawRect(
        Rect.fromLTWH(0, y - 6, size.width, 12),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, y - 6),
            Offset(0, y + 6),
            [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.35), MRoh.tinte.withValues(alpha: 0.10), MRoh.tinte.withValues(alpha: 0)],
            const [0, 0.45, 0.55, 1],
          ),
      );
    }

    // Dunklerer, leicht gealterter Rand.
    final rand = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = const Color(0x2E8A6A3A);
    canvas.drawRect(rect.deflate(2), rand);
  }

  @override
  bool shouldRepaint(covariant PapierMaler alt) =>
      alt.art != art || alt.samen != samen || alt.knick != knick || alt.flecken != flecken || alt.zeilenAbstand != zeilenAbstand || alt.kopf != kopf;
}

/// Malt Manilakarton (Aktendeckel): Längsfasern, abgegriffene Kanten.
class ManilaMaler extends CustomPainter {
  const ManilaMaler({this.samen = 3, this.farbe = MRoh.manila});

  final int samen;
  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final z = MaterialZufall(samen * 104729 + size.width.round());
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [Color.lerp(farbe, Colors.white, 0.18)!, farbe, Color.lerp(farbe, MRoh.manilaDunkel, 0.7)!],
          const [0, 0.5, 1],
        ),
    );
    final faser = Paint()..strokeWidth = 0.7;
    final n = (size.width * size.height / 260).clamp(20, 1200).toInt();
    for (var i = 0; i < n; i++) {
      final p = Offset(z.naechste() * size.width, z.naechste() * size.height);
      faser.color = (z.naechste() < 0.55 ? MRoh.manilaDunkel : Colors.white).withValues(alpha: z.zwischen(0.06, 0.16));
      canvas.drawLine(p, p + Offset(z.zwischen(4, 14), z.zwischen(-0.4, 0.4)), faser);
    }
    // Abgegriffene, dunklere Ränder.
    canvas.drawRect(
      rect.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = MRoh.manilaDunkel.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant ManilaMaler alt) => alt.samen != samen || alt.farbe != farbe;
}

/// Malt eine Korkwand.
class KorkMaler extends CustomPainter {
  const KorkMaler({this.samen = 11});

  final int samen;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final z = MaterialZufall(samen * 15485863 + size.height.round());
    canvas.drawRect(rect, Paint()..color = MRoh.kork);
    final p = Paint();
    final n = (size.width * size.height / 40).clamp(200, 6000).toInt();
    for (var i = 0; i < n; i++) {
      final t = z.naechste();
      p.color = Color.lerp(MRoh.korkDunkel, const Color(0xFFC79465), t)!.withValues(alpha: z.zwischen(0.35, 0.8));
      canvas.drawCircle(Offset(z.naechste() * size.width, z.naechste() * size.height), z.zwischen(0.5, 2.2), p);
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(rect.center, size.longestSide * 0.7, [Colors.transparent, Colors.black.withValues(alpha: 0.35)]),
    );
  }

  @override
  bool shouldRepaint(covariant KorkMaler alt) => alt.samen != samen;
}

/// Verlauf für gebürstetes Messing (Schilder, Beschläge).
LinearGradient messingVerlauf({bool gedrueckt = false}) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: gedrueckt
          ? const [MRoh.messingMitte, MRoh.messingDunkel, MRoh.messingMitte]
          : const [MRoh.messingHell, MRoh.messingMitte, Color(0xFFA77A28), MRoh.messingMitte],
      stops: gedrueckt ? const [0, 0.6, 1] : const [0, 0.45, 0.8, 1],
    );

/// Feine waagerechte Bürstung über einer Messingfläche.
class BuerstungMaler extends CustomPainter {
  const BuerstungMaler();

  @override
  void paint(Canvas canvas, Size size) {
    final z = MaterialZufall(size.width.round() * 13 + size.height.round());
    final p = Paint()..strokeWidth = 0.6;
    for (var y = 1.0; y < size.height; y += 1.4) {
      p.color = (z.naechste() < 0.5 ? Colors.white : MRoh.messingDunkel).withValues(alpha: z.zwischen(0.04, 0.12));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant BuerstungMaler alt) => false;
}

/// Malt das Leder einer Schreibtischunterlage (Körnung, Lampenschein, Abnutzung).
class LederMaler extends CustomPainter {
  const LederMaler({this.schein = MRoh.akzent});

  /// Farbe des Lampenscheins.
  final Color schein;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final z = MaterialZufall(size.width.round() * 7 + size.height.round() * 3);
    final p = Paint();
    final n = (size.width * size.height / 260).clamp(200, 5000).toInt();
    for (var i = 0; i < n; i++) {
      p.color = (z.naechste() < 0.5 ? Colors.black : MRoh.lederHell).withValues(alpha: z.zwischen(0.05, 0.16));
      canvas.drawCircle(Offset(z.naechste() * size.width, z.naechste() * size.height), z.zwischen(0.6, 2.0), p);
    }
    // Warmer Lampenschein von oben.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * 0.5, -size.height * 0.08),
          size.longestSide * 0.75,
          [schein.withValues(alpha: 0.20), schein.withValues(alpha: 0.05), Colors.transparent],
          const [0, 0.45, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant LederMaler alt) => alt.schein != schein;
}
