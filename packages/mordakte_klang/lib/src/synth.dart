import 'dart:math' as math;
import 'dart:typed_data';

/// Abtastrate aller Klänge (Mono).
const int klangRate = 22050;

/// Deterministischer Zufall (LCG, 32 Bit) für Rauschen und Streuung.
class KlangZufall {
  KlangZufall(int samen) : _s = samen & 0xffffffff;
  int _s;

  /// Gleichverteilt in [0, 1).
  double naechste() {
    _s = (_s * 1664525 + 1013904223) & 0xffffffff;
    return _s / 4294967296.0;
  }

  /// Weißes Rauschen in [-1, 1).
  double rauschen() => naechste() * 2 - 1;
}

/// Biquad-Filter nach dem RBJ-Kochbuch.
class Biquad {
  Biquad._(this._b0, this._b1, this._b2, this._a1, this._a2);
  final double _b0, _b1, _b2, _a1, _a2;
  double _x1 = 0, _x2 = 0, _y1 = 0, _y2 = 0;

  factory Biquad.tiefpass(double f, {double q = 0.707}) {
    final w = 2 * math.pi * f / klangRate, c = math.cos(w), a = math.sin(w) / (2 * q);
    final a0 = 1 + a;
    return Biquad._((1 - c) / 2 / a0, (1 - c) / a0, (1 - c) / 2 / a0, -2 * c / a0, (1 - a) / a0);
  }

  factory Biquad.hochpass(double f, {double q = 0.707}) {
    final w = 2 * math.pi * f / klangRate, c = math.cos(w), a = math.sin(w) / (2 * q);
    final a0 = 1 + a;
    return Biquad._((1 + c) / 2 / a0, -(1 + c) / a0, (1 + c) / 2 / a0, -2 * c / a0, (1 - a) / a0);
  }

  factory Biquad.bandpass(double f, {double q = 1}) {
    final w = 2 * math.pi * f / klangRate, c = math.cos(w), a = math.sin(w) / (2 * q);
    final a0 = 1 + a;
    return Biquad._(a / a0, 0, -a / a0, -2 * c / a0, (1 - a) / a0);
  }

  double schritt(double x) {
    final y = _b0 * x + _b1 * _x1 + _b2 * _x2 - _a1 * _y1 - _a2 * _y2;
    _x2 = _x1;
    _x1 = x;
    _y2 = _y1;
    _y1 = y;
    return y;
  }
}

/// Braunes Rauschen (integriert, mit Leck) aus weißem.
class BraunRauschen {
  BraunRauschen(this._z);
  final KlangZufall _z;
  double _v = 0;
  double schritt() {
    _v = (_v + _z.rauschen() * 0.02) * 0.998;
    return _v * 3.5;
  }
}

/// Puffer mit Hilfen zum Mischen.
class Spur {
  Spur(double sekunden) : p = Float64List((sekunden * klangRate).round());
  final Float64List p;
  int get laenge => p.length;

  /// Addiert [f](i, t) ab Probe [ab] für [n] Proben.
  void mische(int ab, int n, double Function(int i, double t) f) {
    for (var i = 0; i < n && ab + i < p.length; i++) {
      if (ab + i < 0) continue;
      p[ab + i] += f(i, i / klangRate);
    }
  }

  /// Einfacher Raumhall (vier Kammfilter, zwei Allpässe).
  void hall({double mix = 0.25, double raum = 0.78}) {
    const kamm = [1116, 1188, 1277, 1356];
    const allpass = [556, 441];
    final trocken = Float64List.fromList(p);
    final nass = Float64List(p.length);
    for (final k in kamm) {
      final d = (k * klangRate / 44100).round();
      final puffer = Float64List(d);
      var j = 0;
      for (var i = 0; i < p.length; i++) {
        final y = puffer[j];
        puffer[j] = trocken[i] + y * raum;
        nass[i] += y * 0.25;
        j = (j + 1) % d;
      }
    }
    for (final a in allpass) {
      final d = (a * klangRate / 44100).round();
      final puffer = Float64List(d);
      var j = 0;
      for (var i = 0; i < p.length; i++) {
        final b = puffer[j];
        final y = -nass[i] + b;
        puffer[j] = nass[i] + b * 0.5;
        nass[i] = y;
        j = (j + 1) % d;
      }
    }
    for (var i = 0; i < p.length; i++) {
      p[i] = trocken[i] * (1 - mix) + nass[i] * mix;
    }
  }

  /// Auf Spitzenwert [ziel] bringen, Anfang und Ende 2 ms weich.
  Float64List fertig({double ziel = 0.9}) {
    var spitze = 0.0;
    for (final v in p) {
      spitze = math.max(spitze, v.abs());
    }
    final k = spitze < 1e-9 ? 0.0 : ziel / spitze;
    final rand = (0.002 * klangRate).round();
    for (var i = 0; i < p.length; i++) {
      var g = k;
      if (i < rand) g *= i / rand;
      if (i > p.length - rand) g *= (p.length - i) / rand;
      p[i] *= g;
    }
    return p;
  }

  /// Nahtlose Schleife: Der Überhang hinter [sekunden] wird in den Anfang
  /// geblendet (gleiche Leistung). Erwartet eine um [blende] längere Spur.
  Float64List schleife(double sekunden, {double blende = 0.6, double ziel = 0.7}) {
    final n = (sekunden * klangRate).round();
    final x = (blende * klangRate).round();
    final aus = Float64List(n);
    for (var i = 0; i < n; i++) {
      if (i < x && n + i < p.length) {
        final t = i / x;
        aus[i] = p[i] * math.sqrt(t) + p[n + i] * math.sqrt(1 - t);
      } else {
        aus[i] = p[i];
      }
    }
    var spitze = 0.0;
    for (final v in aus) {
      spitze = math.max(spitze, v.abs());
    }
    final k = spitze < 1e-9 ? 0.0 : ziel / spitze;
    for (var i = 0; i < n; i++) {
      aus[i] *= k;
    }
    return aus;
  }
}

/// Exponentielles Abklingen mit Zeitkonstante [tau] (Sekunden).
double abkling(double t, double tau) => math.exp(-t / tau);

/// Anstieg in [a] Sekunden, danach Abklingen mit [tau].
double huelle(double t, double a, double tau) => t < a ? t / a : math.exp(-(t - a) / tau);
