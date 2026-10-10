import 'dart:math' as math;

import 'package:mordakte_core/mordakte_core.dart';

/// Sichtbarer A*-Lauf zu einer frei erreichbaren Nachbarkachel der Quelle,
/// anschließend eine Handlungspose. Kein Fall-Code, Würfel oder Fundtext hier.
class KartenAktion {
  KartenAktion._(this.weg, this.zielX, this.zielY, this.suchen, this.x, this.y, this.facing) {
    var sx = x, sy = y;
    for (final p in weg) {
      _laenge += dist(sx, sy, p.$1, p.$2);
      (sx, sy) = p;
    }
    _laufDauer = _laenge < 0.001 ? 0 : (_laenge / 4).clamp(1.8, 8.5);
    _posenDauer = math.max(1.5, 4 - _laufDauer);
  }

  /// null bedeutet wirklich unerreichbar, niemals Teleport durch eine Wand.
  static KartenAktion? planen({
    required TileGrid raster,
    required double startX,
    required double startY,
    required double facing,
    required double zielX,
    required double zielY,
    required String raum,
    required bool suchen,
    bool umweg = false,
  }) {
    if (!raster.canStand(startX, startY, Tuning.playerRadius)) return null;
    final start = Pt(startX.floor(), startY.floor());
    final kandidaten = <({Pt p, List<Pt> pfad, double kosten})>[];
    for (var dy = -2; dy <= 2; dy++) {
      for (var dx = -2; dx <= 2; dx++) {
        final p = Pt(zielX.floor() + dx, zielY.floor() + dy);
        final x = p.x + 0.5, y = p.y + 0.5;
        final abstand = dist(x, y, zielX, zielY);
        if (abstand < 0.6 || abstand > 1.6 || !raster.canStand(x, y, Tuning.playerRadius)) continue;
        if (raster.roomAtPos(x, y)?.id != raum || !raster.lineOfSight(x, y, zielX, zielY)) continue;
        // Ein Umweg nimmt eine andere Seite, ohne die Quelle auszutauschen.
        if (umweg && dist(startX, startY, x, y) < 0.9) continue;
        final pfad = raster.findPath(start, p);
        if (pfad == null) continue;
        var kosten = 0.0;
        var vorher = start;
        for (final schritt in pfad) {
          kosten += dist(vorher.x.toDouble(), vorher.y.toDouble(), schritt.x.toDouble(), schritt.y.toDouble());
          vorher = schritt;
        }
        kandidaten.add((p: p, pfad: pfad, kosten: kosten + abstand / 10));
      }
    }
    kandidaten.sort((a, b) {
      final k = a.kosten.compareTo(b.kosten);
      if (k != 0) return k;
      final y = a.p.y.compareTo(b.p.y);
      return y != 0 ? y : a.p.x.compareTo(b.p.x);
    });
    if (kandidaten.isEmpty) return null;
    final pfad = kandidaten.first.pfad;
    return KartenAktion._(List.unmodifiable([
      // Erst zur eigenen Kachelmitte; auch ein frei gesteuerter Start nahe der
      // Wand darf beim ersten diagonalen Schritt keine Ecke schneiden.
      (start.x + 0.5, start.y + 0.5),
      for (final p in pfad) (p.x + 0.5, p.y + 0.5),
    ]), zielX, zielY, suchen, startX, startY, facing);
  }

  final List<(double, double)> weg;
  final double zielX, zielY;
  final bool suchen;
  double x, y, facing;
  double _laenge = 0, _laufDauer = 0, _posenDauer = 0;
  double _gelaufen = 0, _pose = 0;
  int _punkt = 0;
  bool get geht => _punkt < weg.length;
  bool get fertig => !geht && _pose >= _posenDauer;
  double get posenFortschritt => (_pose / _posenDauer).clamp(0, 1);
  double get dauer => _laufDauer + _posenDauer;
  double get fortschritt => ((_gelaufen / math.max(_laenge, 0.001) * _laufDauer + _pose) / dauer).clamp(0, 1);

  /// dt wird begrenzt: Ein schlafender Tab überspringt beim Aufwachen keine Szene.
  void schritt(double sekunden) {
    if (!sekunden.isFinite || sekunden <= 0 || fertig) return;
    var rest = math.min(sekunden, 0.25);
    final tempo = _laufDauer > 0 ? _laenge / _laufDauer : 1.0;
    while (geht && rest > 0) {
      final p = weg[_punkt];
      final d = dist(x, y, p.$1, p.$2);
      if (d < 0.00001) { _punkt++; continue; }
      facing = math.atan2(p.$2 - y, p.$1 - x);
      final strecke = math.min(d, tempo * rest);
      x += (p.$1 - x) * strecke / d;
      y += (p.$2 - y) * strecke / d;
      _gelaufen += strecke;
      rest -= strecke / tempo;
      if (strecke >= d - 0.00001) _punkt++;
    }
    if (!geht) {
      facing = math.atan2(zielY - y, zielX - x);
      _pose = math.min(_posenDauer, _pose + rest);
    }
  }

  /// Ausschließlich bewusster „Szene abkürzen“-Tipp bzw. reduzierte Bewegung.
  /// Der Endpunkt stammt weiterhin aus A*, die Zielpose bleibt kurz sichtbar.
  void abkuerzen() {
    final p = weg.last;
    x = p.$1;
    y = p.$2;
    facing = math.atan2(zielY - y, zielX - x);
    _punkt = weg.length;
    _gelaufen = _laenge;
    _pose = math.max(_pose, _posenDauer - 0.2);
  }
}
