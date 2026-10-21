import 'dart:math' as math;

/// Kachel-Koordinaten (x = Spalte nach Osten, y = Zeile nach Süden).
class Pt {
  final int x;
  final int y;
  const Pt(this.x, this.y);

  @override
  bool operator ==(Object other) => other is Pt && other.x == x && other.y == y;

  @override
  int get hashCode => x * 73856093 ^ y * 19349663;

  @override
  String toString() => '($x,$y)';

  List<int> toJson() => [x, y];

  static Pt fromJson(Object? j) {
    final l = j as List;
    return Pt((l[0] as num).toInt(), (l[1] as num).toInt());
  }
}

double dist(double ax, double ay, double bx, double by) {
  final dx = ax - bx;
  final dy = ay - by;
  return math.sqrt(dx * dx + dy * dy);
}

double clampD(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

/// Abstand des Punkts (px, py) zur Strecke von (ax, ay) nach (bx, by).
double distToSegment(double px, double py, double ax, double ay, double bx, double by) {
  final dx = bx - ax, dy = by - ay;
  final l2 = dx * dx + dy * dy;
  final k = l2 == 0 ? 0.0 : clampD(((px - ax) * dx + (py - ay) * dy) / l2, 0, 1);
  return dist(px, py, ax + dx * k, ay + dy * k);
}
