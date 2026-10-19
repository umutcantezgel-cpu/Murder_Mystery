import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/painting.dart' show TextPainter;
import 'package:mordakte_core/mordakte_core.dart';

import '../iso_math.dart';
import '../szenen_erweiterung.dart';
import 'markers.dart' show TextCache;
import 'palette.dart';
import 'static_scene.dart';

/// Eine Figur für die Zeichen über den Köpfen: Kennung, Kopfpunkt in
/// Bildschirmpixeln und Abstand zum eigenen Detektiv in Kacheln.
typedef KlassenFigur = ({String id, Offset kopf, double abstand});

/// Was die Detektivklasse in der Szene zeigt (A-055, M6): Leuchten im Umkreis,
/// Umrisse von Türen und Treppen, Sprechblasen-Marker, Stimmungszeichen und
/// Gerüchte. Nur Zeichnen: Die Ebene liest die [SzenenKlasse] und die Szene,
/// sie nimmt keine Eingabe an und ändert nichts am Abend.
class KlassenEbene {
  KlassenEbene(this.pal, this.text);

  final ScenePalette pal;
  final TextCache text;

  /// Ab diesem Abstand (Kacheln) hört der Detektiv ein Gerücht.
  static const geruechtAbstand = 2.2;

  /// Deckkraft der Gerüchtblase je Figur (0..1), weich ein- und ausgeblendet.
  final Map<String, double> _geruecht = {};

  /// Sichtbare Gerüchtblasen mit ihrer Deckkraft (Tests).
  @visibleForTesting
  Map<String, double> get geruechtDeckkraft => Map.unmodifiable(_geruecht);

  static const _gold = Color(0xFFFFD27A);
  static const _tuer = Color(0xFFE8B45A);
  static const _verschlossen = Color(0xFFE0604E);
  static const _treppe = Color(0xFF7FD8E8);

  /// Bodenzeichen im Weltbild, über dem Nebel: offene Hotspots der Szene und
  /// Glanzpunkte ([glanz]) leuchten im [SzenenKlasse.glanzRadius] um den
  /// Detektiv bei [ich]; mit [SzenenKlasse.tuerenZeigen] sind Türen,
  /// verschlossene Türen (ohne die geöffneten [offen]) und Treppen umrandet.
  void boden(
    Canvas c,
    SzenenKlasse k, {
    required StaticScene scene,
    required CaseView? fall,
    required List<SzenenGlanzPunkt> glanz,
    required Offset ich,
    required Set<Pt> offen,
    required Rect cull,
    required double t,
    bool ruhig = false,
  }) {
    final r = k.glanzRadius;
    if (r > 0) {
      final s = scene.scenario;
      final orte = <Offset>[
        for (final e in fall?.hotspots.entries ?? const <MapEntry<String, String>>[])
          if (e.value == HotspotState.open)
            if (s.hotspotById[e.key] case final h?) Offset(h.x + 0.5, h.y + 0.5),
        for (final g in glanz) Offset(g.x, g.y),
      ];
      for (final o in orte) {
        final d = (o - ich).distance;
        if (d > r) continue;
        final p = Iso.toScreen(o.dx, o.dy);
        if (!cull.contains(p)) continue;
        // Je näher, desto kräftiger; ein ruhiges Atmen statt Flackern.
        final a = 0.35 + 0.65 * (1 - d / r);
        final puls = ruhig ? 0.5 : 0.5 + 0.5 * math.sin(t * 2.4 + o.dx * 1.7 + o.dy);
        c.save();
        c.translate(p.dx, p.dy);
        Iso.applyGround(c);
        c.drawCircle(
          Offset.zero,
          0.75,
          Paint()..shader = Gradient.radial(Offset.zero, 0.75, [withAlpha(_gold, (0.32 + 0.12 * puls) * a), withAlpha(_gold, 0)]),
        );
        c.drawCircle(
          Offset.zero,
          0.48 + 0.05 * puls,
          Paint()
            ..color = withAlpha(_gold, 0.7 * a)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.045,
        );
        c.restore();
      }
    }
    if (!k.tuerenZeigen) return;
    for (final d in scene.doors) {
      final info = d.door!;
      final zu = info.locked && !offen.contains(Pt(info.x, info.y));
      _umriss(c, info.x, info.y, zu ? _verschlossen : _tuer, cull);
    }
    for (final e in scene.propAt.entries) {
      final typ = e.value.prop?.type ?? '';
      if (typ.contains('treppe') || typ.contains('stair') || typ.contains('stufe')) _umriss(c, e.key.x, e.key.y, _treppe, cull);
    }
  }

  /// Umriss der Kachel ([x], [y]) auf dem Boden: eine helle Linie mit weichem Rand.
  void _umriss(Canvas c, int x, int y, Color farbe, Rect cull) {
    final p = Iso.toScreen(x.toDouble(), y.toDouble());
    if (!cull.contains(p.translate(0, Iso.halfH))) return;
    c.save();
    c.translate(p.dx, p.dy);
    Iso.applyGround(c);
    const kachel = Rect.fromLTWH(0.06, 0.06, 0.88, 0.88);
    final rr = RRect.fromRectAndRadius(kachel, const Radius.circular(0.12));
    c.drawRRect(rr, Paint()..color = withAlpha(farbe, 0.12));
    c.drawRRect(
      rr,
      Paint()
        ..color = withAlpha(farbe, 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05,
    );
    c.restore();
  }

  /// Zeichen über den Köpfen in Bildschirmpixeln: Sprechblasen-Marker an
  /// Figuren mit Randgespräch, das Stimmungszeichen der [gespraech]-Figur und
  /// das Gerücht der nächsten Figur in [geruechtAbstand]. [dt] blendet die
  /// Gerüchtblasen weich ein und aus.
  void ueberKoepfen(
    Canvas c,
    SzenenKlasse k, {
    required List<KlassenFigur> figuren,
    required ({String npc, SzenenGeste geste})? gespraech,
    required double t,
    required double dt,
  }) {
    KlassenFigur? naechste;
    for (final f in figuren) {
      if (f.abstand <= geruechtAbstand && (naechste == null || f.abstand < naechste.abstand) && k.geruechtFuer(f.id) != null) naechste = f;
    }
    for (final f in figuren) {
      final alt = _geruecht[f.id] ?? 0;
      final neu = f.id == naechste?.id ? math.min(1.0, alt + dt / 0.25) : math.max(0.0, alt - dt / 0.6);
      if (neu <= 0) {
        _geruecht.remove(f.id);
      } else {
        _geruecht[f.id] = neu;
      }
    }
    for (final f in figuren) {
      var oben = f.kopf;
      if (gespraech != null && gespraech.npc == f.id && k.stimmungZeigen) {
        _stimmung(c, oben.translate(16, -4), gespraech.geste);
      } else if (k.gespraechsMarker(f.id)) {
        _marker(c, oben.translate(0, math.sin(t * 2 + f.id.hashCode % 7) * 1.5));
        oben = oben.translate(0, -24);
      }
      final a = _geruecht[f.id] ?? 0;
      final zeile = a > 0.01 ? k.geruechtFuer(f.id) : null;
      if (zeile != null) _geruechtBlase(c, oben, zeile, a);
    }
  }

  /// Kleine Sprechblase mit drei Punkten: Hier wartet ein Randgespräch.
  void _marker(Canvas c, Offset unten) {
    final r = RRect.fromRectAndRadius(Rect.fromCenter(center: unten.translate(0, -14), width: 26, height: 18), const Radius.circular(8));
    final bg = Paint()..color = withAlpha(const Color(0xFFF4EFE4), 0.92);
    c.drawRRect(r, bg);
    c.drawPath(
      Path()
        ..moveTo(unten.dx - 4, r.bottom - 0.5)
        ..lineTo(unten.dx + 3, r.bottom - 0.5)
        ..lineTo(unten.dx - 2, r.bottom + 5)
        ..close(),
      bg,
    );
    final tinte = Paint()..color = const Color(0xFF2A2230);
    for (var i = -1; i <= 1; i++) {
      c.drawCircle(r.center.translate(i * 6.0, 0), 1.8, tinte);
    }
  }

  /// Stimmungszeichen neben dem Kopf: Abwehr, Nachdenken oder Zuhören.
  void _stimmung(Canvas c, Offset o, SzenenGeste geste) {
    final (zeichen, farbe) = switch (geste) {
      SzenenGeste.abwehr => ('!', _verschlossen),
      SzenenGeste.nachdenken => ('?', _treppe),
      SzenenGeste.zuhoeren => ('…', _gold),
    };
    c.drawCircle(o, 9, Paint()..color = withAlpha(const Color(0xFF0C0A10), 0.75));
    c.drawCircle(
      o,
      9,
      Paint()
        ..color = farbe
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final tp = text.get(zeichen, 12, farbe, weight: FontWeight.w800);
    tp.paint(c, o - Offset(tp.width / 2, tp.height / 2));
  }

  /// Gerüchtblase über [unten]: Papierton, höchstens zwei Zeilen.
  void _geruechtBlase(Canvas c, Offset unten, String zeile, double alpha) {
    final zeilen = _umbrechen(zeile);
    final tinte = withAlpha(const Color(0xFF2A2230), alpha);
    final teile = <TextPainter>[for (final z in zeilen) text.get(z, 11, tinte, weight: FontWeight.w500)];
    final breite = teile.map((p) => p.width).reduce(math.max) + 16;
    final hoehe = teile.fold<double>(0, (h, p) => h + p.height) + 10;
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(unten.dx - breite / 2, unten.dy - hoehe - 8, breite, hoehe), const Radius.circular(7));
    final bg = Paint()..color = withAlpha(const Color(0xFFF4EFE4), 0.94 * alpha);
    c.drawRRect(r, bg);
    c.drawPath(
      Path()
        ..moveTo(unten.dx - 5, r.bottom - 0.5)
        ..lineTo(unten.dx + 4, r.bottom - 0.5)
        ..lineTo(unten.dx - 1, unten.dy - 1)
        ..close(),
      bg,
    );
    var y = r.top + 5;
    for (final p in teile) {
      p.paint(c, Offset(unten.dx - p.width / 2, y));
      y += p.height;
    }
  }

  /// Lange Zeilen an der Lücke nahe der Mitte in zwei Zeilen teilen.
  static List<String> _umbrechen(String zeile) {
    if (zeile.length <= 26) return [zeile];
    final mitte = zeile.length ~/ 2;
    var beste = -1;
    for (var i = 0; i < zeile.length; i++) {
      if (zeile[i] == ' ' && (beste < 0 || (i - mitte).abs() < (beste - mitte).abs())) beste = i;
    }
    return beste < 0 ? [zeile] : [zeile.substring(0, beste), zeile.substring(beste + 1)];
  }
}
