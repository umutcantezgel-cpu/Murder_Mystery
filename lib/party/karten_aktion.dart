import 'dart:math' as math;

import 'package:mordakte_core/mordakte_core.dart';

/// Sichtbarer A*-Lauf zu einer frei erreichbaren Nachbarkachel der Quelle,
/// anschließend eine Handlungspose. Kein Fall-Code, Würfel oder Fundtext hier.
class KartenAktion {
  KartenAktion._(this.weg, this.zielX, this.zielY, this.suchen, this.x, this.y, this.facing, {double tempo = 1}) {
    var sx = x, sy = y;
    for (final p in weg) {
      _laenge += dist(sx, sy, p.$1, p.$2);
      (sx, sy) = p;
    }
    // Ein schnellerer Schritt (Laufschritt, A-055) kürzt nur den sichtbaren Lauf.
    _laufDauer = _laenge < 0.001 ? 0 : (_laenge / 4).clamp(1.8, 8.5) / tempo;
    _posenDauer = math.max(1.5, 4 - _laufDauer);
  }

  /// null bedeutet wirklich unerreichbar, niemals Teleport durch eine Wand.
  ///
  /// [personen] sind die Standorte der anderen Figuren (in allen Pfaden
  /// gleich, nie die Rückblende). Der Detektiv stellt sich nicht auf sie, und
  /// der Weg geht um sie herum, solange es einen freien Platz gibt.
  ///
  /// [tempo] ist der Tempofaktor der Detektivklasse: nur Darstellung. Weg und
  /// Ziel bleiben gleich, die Dauer hängt nur von Weg und Tempo ab und ist so
  /// in allen Pfaden gleich.
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
    List<(double, double)> personen = const [],
    double tempo = 1,
  }) {
    if (!raster.canStand(startX, startY, Tuning.playerRadius)) return null;
    final start = Pt(startX.floor(), startY.floor());
    final belegt = {for (final (px, py) in personen) Pt(px.floor(), py.floor())};
    bool aufPerson(double x, double y) => personen.any((p) => dist(x, y, p.$1, p.$2) < _personenAbstand);
    final kandidaten = <({Pt p, List<Pt> pfad, double kosten, bool frei})>[];
    void pruefe(Pt p, {required bool ring}) {
      final x = p.x + 0.5, y = p.y + 0.5;
      final abstand = dist(x, y, zielX, zielY);
      if (abstand < 0.6 || (ring && abstand > 1.6) || !raster.canStand(x, y, Tuning.playerRadius)) return;
      if (raster.roomAtPos(x, y)?.id != raum) return;
      final sicht = raster.lineOfSight(x, y, zielX, zielY);
      if (ring && !sicht) return;
      // Ein Umweg nimmt eine andere Seite, ohne die Quelle auszutauschen.
      if (umweg && dist(startX, startY, x, y) < 0.9) return;
      final pfad = raster.findPath(start, p, extraBlockiert: belegt);
      if (pfad == null) return;
      var kosten = 0.0;
      var vorher = start;
      for (final schritt in pfad) {
        kosten += dist(vorher.x.toDouble(), vorher.y.toDouble(), schritt.x.toDouble(), schritt.y.toDouble());
        vorher = schritt;
      }
      kandidaten.add((
        p: p,
        pfad: pfad,
        // Außerhalb des Rings zählt zuerst die Nähe zum Ziel, dann die Sicht darauf.
        kosten: ring ? kosten + abstand / 10 : 100 + abstand * 10 + (sicht ? 0 : 50) + kosten / 100,
        frei: !aufPerson(x, y),
      ));
    }

    for (var dy = -2; dy <= 2; dy++) {
      for (var dx = -2; dx <= 2; dx++) {
        pruefe(Pt(zielX.floor() + dx, zielY.floor() + dy), ring: true);
      }
    }
    // Rückfall: Stehen um das Ziel nur Personen, gilt die nächste freie Kachel
    // im Raum. Gibt es auch die nicht, bleibt der alte Platz: lieber neben
    // jemandem stehen als ein Ziel unerreichbar machen.
    final raumDef = raster.map.roomById[raum];
    if (raumDef != null && !kandidaten.any((k) => k.frei)) {
      for (var y = raumDef.y; y < raumDef.y + raumDef.h; y++) {
        for (var x = raumDef.x; x < raumDef.x + raumDef.w; x++) {
          pruefe(Pt(x, y), ring: false);
        }
      }
    }
    final freie = kandidaten.where((k) => k.frei).toList();
    final auswahl = freie.isNotEmpty ? freie : kandidaten;
    auswahl.sort((a, b) {
      final k = a.kosten.compareTo(b.kosten);
      if (k != 0) return k;
      final y = a.p.y.compareTo(b.p.y);
      return y != 0 ? y : a.p.x.compareTo(b.p.x);
    });
    if (auswahl.isEmpty) return null;
    final punkte = [
      // Erst zur eigenen Kachelmitte; auch ein frei gesteuerter Start nahe der
      // Wand darf beim ersten diagonalen Schritt keine Ecke schneiden.
      (start.x + 0.5, start.y + 0.5),
      for (final p in auswahl.first.pfad) (p.x + 0.5, p.y + 0.5),
    ];
    return KartenAktion._(List.unmodifiable(_glaetten(raster, startX, startY, punkte, personen)), zielX, zielY, suchen, startX, startY, facing,
        tempo: tempo > 0 && tempo.isFinite ? tempo : 1);
  }

  /// Längste sichtbare Aktion: Lauf höchstens 8,5 s (beim Tempo 1), danach die
  /// Pose mindestens 1,5 s. Kürzer wird sie nur durch ein höheres Tempo. Der
  /// Gastgeber meldet damit ersatzweise das Ende, wenn ein Gast-Detektiv
  /// ermittelt und dessen Gerät schweigt (`GastgeberSitzung`).
  static const hoechstDauer = Duration(seconds: 10);

  /// Abstand, unter dem eine Kachelmitte als „auf einer Person“ gilt.
  static const _personenAbstand = 0.6;

  /// Mindestabstand einer geglätteten Strecke zu einer Person.
  static const _vorbeiAbstand = 0.5;

  /// Fadenziehen: von jedem Punkt gerade zum entferntesten Wegpunkt, zu dem
  /// der Körper frei durchkommt ([TileGrid.freieBahn]) und an keiner Person
  /// vorbeistreift. Nachbarpunkte des A*-Wegs sind immer frei, so bleibt
  /// jede Strecke kollisionsfrei; nur die Treppenstufen verschwinden.
  static List<(double, double)> _glaetten(TileGrid raster, double sx, double sy, List<(double, double)> punkte, List<(double, double)> personen) {
    bool frei((double, double) a, (double, double) b) =>
        raster.freieBahn(a.$1, a.$2, b.$1, b.$2) &&
        personen.every((p) => distToSegment(p.$1, p.$2, a.$1, a.$2, b.$1, b.$2) >= _vorbeiAbstand);
    final weg = <(double, double)>[];
    var von = (sx, sy);
    var i = 0;
    while (i < punkte.length) {
      var j = punkte.length - 1;
      while (j > i && !frei(von, punkte[j])) {
        j--;
      }
      weg.add(punkte[j]);
      von = punkte[j];
      i = j + 1;
    }
    return weg;
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
    final dt = math.min(sekunden, 0.25);
    var rest = dt;
    final tempo = _laufDauer > 0 ? _laenge / _laufDauer : 1.0;
    var richtung = facing;
    while (geht && rest > 0) {
      final p = weg[_punkt];
      final d = dist(x, y, p.$1, p.$2);
      if (d < 0.00001) { _punkt++; continue; }
      richtung = math.atan2(p.$2 - y, p.$1 - x);
      final strecke = math.min(d, tempo * rest);
      x += (p.$1 - x) * strecke / d;
      y += (p.$2 - y) * strecke / d;
      _gelaufen += strecke;
      rest -= strecke / tempo;
      if (strecke >= d - 0.00001) _punkt++;
    }
    // Der Blick dreht weich in die Laufrichtung und am Ende zum Ziel, statt an
    // jedem Wegpunkt zu springen.
    final blick = geht ? richtung : math.atan2(zielY - y, zielX - x);
    facing = _drehe(facing, blick, 1 - math.exp(-dt * 10));
    if (!geht) _pose = math.min(_posenDauer, _pose + rest);
  }

  /// Winkel [a] um den Anteil [k] zum Winkel [b] auf dem kürzeren Weg.
  static double _drehe(double a, double b, double k) {
    var d = (b - a) % (math.pi * 2);
    if (d > math.pi) d -= math.pi * 2;
    final w = a + d * k;
    return math.atan2(math.sin(w), math.cos(w));
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
