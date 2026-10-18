import 'dart:math' as math;
import 'dart:ui';

import 'package:mordakte_core/mordakte_core.dart';

import 'iso_pen.dart';
import 'palette.dart';

/// Möbel und Dinge des Partymodus (F4-ORCH-06, E-016, Master 7.15): Tafeln
/// und Buffets ohne Flaschen (Teekanne, Tassen, Wasserkaraffe, Brot,
/// Warmhaltebehälter), Theke mit Teekocher und Kaffeemaschine, kalter Kamin,
/// Wendeltreppe, Ritterrüstung, Jackenständer und der umgestoßene
/// Kerzenständer vor der Vorratstür. Elektrische Teelichter stehen genau dort,
/// wo die Karte ihre warmen Lichtpunkte setzt (PartyKarte.dekoKerzen).
class PartyProps {
  PartyProps(this.pal);

  final ScenePalette pal;

  static const _white = Color(0xFFFFFFFF);
  static const _porzellan = Color(0xFFEDE8DF);
  static const _brass = Color(0xFFC8A24A);
  static const _stahl = Color(0xFF9AA0A6);
  static const _wachsRot = Color(0xFFB0283A);
  static const _teelicht = Color(0xFFFFE2B0);

  /// Höhe der Oberkante (Hotspot-Marker auf Props).
  static double? topZ(String type) => switch (type) {
        'party_tafel' || 'party_buffet' => 0.45,
        'party_theke' || 'party_anrichte' || 'party_teekocher' || 'party_kaffee' => 0.61,
        'party_kerzenstaender' => 0.1,
        _ => null,
      };

  /// Zeichnet [p], wenn es ein Party-Prop ist; sonst `false`.
  bool paint(IsoPen pen, PropDef p) {
    final rng = Rng((p.x * 7919 + p.y * 104729 + p.type.hashCode) & 0x7fffffff);
    switch (p.type) {
      case 'party_tafel':
        _tafel(pen, rng, teelicht: p.y.isOdd);
      case 'party_buffet':
        _buffet(pen, rng, teelicht: p.y.isOdd);
      case 'party_theke':
        _thekeKorpus(pen);
        _thekeOben(pen, rng, teelicht: p.x % 3 == 0);
      case 'party_anrichte':
        _thekeKorpus(pen);
        for (var i = 0; i < 4; i++) {
          pen.cylinder(0.32, 0.45, 0.13, 0.61 + i * 0.015, 0.62 + i * 0.015, _porzellan);
        }
        if (p.x % 3 == 0) _teelichtAuf(pen, 0.72, 0.45, 0.61);
      case 'party_teekocher':
        _thekeKorpus(pen);
        _teekocher(pen);
      case 'party_kaffee':
        _thekeKorpus(pen);
        _kaffeemaschine(pen);
      case 'party_kamin':
        _kaminKalt(pen);
      case 'party_wendeltreppe':
        _wendeltreppe(pen);
      case 'party_ruestung':
        _ruestung(pen);
      case 'party_jackenstaender':
        _jackenstaender(pen, rng);
      case 'party_kerzenstaender':
        _kerzenstaenderLiegt(pen);
      default:
        return false;
    }
    return true;
  }

  void _beine(IsoPen pen, double z) {
    for (final (u, v) in [(0.13, 0.17), (0.82, 0.17), (0.13, 0.78), (0.82, 0.78)]) {
      pen.box(u, v, u + 0.05, v + 0.05, 0, z, pal.darkWood);
    }
  }

  void _tischplatte(IsoPen pen) {
    _beine(pen, 0.39);
    final holz = pal.wood;
    pen.box(0.07, 0.11, 0.93, 0.89, 0.38, 0.45, holz, edge: withAlpha(shade(holz, 0.35), 0.6));
    // Tischläufer aus hellem Leinen
    pen.topRect(0.3, 0.11, 0.7, 0.89, 0.451, pen.fill(const Color(0xFFD9D2C3)));
  }

  void _teelichtAuf(IsoPen pen, double u, double v, double z) {
    pen.cylinder(u, v, 0.05, z, z + 0.04, const Color(0xFFE9E4DA));
    pen.sphere(u, v, z + 0.07, 0.022, _teelicht);
  }

  void _tasse(IsoPen pen, double u, double v, double z, Color farbe) {
    pen.oval(u, v, z, 0.06, pen.fill(shade(farbe, -0.1)));
    pen.cylinder(u, v, 0.04, z, z + 0.06, farbe);
    pen.oval(u, v, z + 0.061, 0.03, pen.fill(const Color(0xFF6B3F22)));
  }

  void _teekanne(IsoPen pen, double u, double v, double z) {
    pen.sphere(u, v, z + 0.08, 0.075, _porzellan, squash: 0.85);
    pen.c.drawLine(pen.p(u + 0.06, v, z + 0.08), pen.p(u + 0.13, v, z + 0.13), pen.stroke(_porzellan, 2.2));
    pen.sphere(u, v, z + 0.16, 0.025, shade(_porzellan, -0.1));
  }

  void _karaffe(IsoPen pen, double u, double v, double z) {
    pen.cylinder(u, v, 0.045, z, z + 0.16, const Color(0x99CFE6F2), rTop: 0.03, top: const Color(0xAAE8F4FA));
    pen.cylinder(u, v, 0.04, z, z + 0.1, const Color(0x5596C4DE));
  }

  void _brotkorb(IsoPen pen, double u, double v, double z) {
    pen.oval(u, v, z, 0.11, pen.fill(const Color(0xFF8A6238)));
    pen.cylinder(u, v, 0.1, z, z + 0.04, const Color(0xFF9C7344), rTop: 0.11);
    pen.sphere(u - 0.03, v, z + 0.06, 0.045, const Color(0xFFD4A55E), squash: 0.6);
    pen.sphere(u + 0.04, v + 0.01, z + 0.06, 0.04, const Color(0xFFC99449), squash: 0.6);
  }

  void _tafel(IsoPen pen, Rng rng, {required bool teelicht}) {
    _tischplatte(pen);
    const z = 0.451;
    switch (rng.nextInt(3)) {
      case 0:
        _teekanne(pen, 0.45, 0.5, z);
        _tasse(pen, 0.62, 0.32, z, _porzellan);
        _tasse(pen, 0.62, 0.68, z, const Color(0xFFD7C9A8));
      case 1:
        _karaffe(pen, 0.5, 0.4, z);
        _tasse(pen, 0.4, 0.66, z, _porzellan);
        _tasse(pen, 0.6, 0.7, z, const Color(0xFFC9D6CF));
      default:
        _brotkorb(pen, 0.5, 0.45, z);
        _tasse(pen, 0.58, 0.72, z, _porzellan);
    }
    if (teelicht) _teelichtAuf(pen, 0.38, 0.22, z);
  }

  void _buffet(IsoPen pen, Rng rng, {required bool teelicht}) {
    _tischplatte(pen);
    const z = 0.451;
    // Warmhaltebehälter mit gewölbtem Deckel
    pen.box(0.3, 0.3, 0.7, 0.62, z, z + 0.06, _stahl, edge: withAlpha(_white, 0.3));
    pen.sphere(0.5, 0.46, z + 0.08, 0.16, shade(_stahl, 0.15), squash: 0.35);
    pen.sphere(0.5, 0.46, z + 0.13, 0.025, const Color(0xFF2B2C31));
    if (rng.nextInt(2) == 0) {
      _brotkorb(pen, 0.5, 0.8, z);
    } else {
      pen.cylinder(0.45, 0.8, 0.07, z, z + 0.04, _porzellan, top: const Color(0xFFE2C26B));
      pen.cylinder(0.6, 0.78, 0.06, z, z + 0.04, _porzellan, top: const Color(0xFFB8463A));
    }
    if (teelicht) _teelichtAuf(pen, 0.38, 0.18, z);
  }

  void _thekeKorpus(IsoPen pen) {
    final korpus = mix(pal.wood, const Color(0xFF5E4A3A), 0.4);
    pen.box(0.0, 0.1, 1.0, 0.8, 0, 0.55, korpus);
    pen.onFront(0.8, () {
      final c = pen.c;
      final l = Paint()
        ..color = shade(korpus, -0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.012;
      c.drawRect(const Rect.fromLTRB(0.06, 0.06, 0.47, 0.46), l);
      c.drawRect(const Rect.fromLTRB(0.53, 0.06, 0.94, 0.46), l);
    });
    pen.box(-0.01, 0.08, 1.01, 0.82, 0.55, 0.61, const Color(0xFF8E7A62), edge: withAlpha(_white, 0.25));
  }

  void _thekeOben(IsoPen pen, Rng rng, {required bool teelicht}) {
    const z = 0.61;
    switch (rng.nextInt(3)) {
      case 0:
        for (var i = 0; i < 3; i++) {
          _tasse(pen, 0.3 + i * 0.16, 0.45, z, i.isEven ? _porzellan : const Color(0xFFD7C9A8));
        }
      case 1:
        pen.box(0.35, 0.3, 0.6, 0.55, z, z + 0.05, const Color(0xFFF1EEE6));
        pen.box(0.37, 0.32, 0.58, 0.53, z + 0.05, z + 0.08, const Color(0xFFE6E1D6));
      default:
        _karaffe(pen, 0.45, 0.45, z);
    }
    if (teelicht) _teelichtAuf(pen, 0.78, 0.45, z);
  }

  void _teekocher(IsoPen pen) {
    const z = 0.61;
    pen.cylinder(0.5, 0.45, 0.17, z, z + 0.42, _stahl, rTop: 0.15, top: shade(_stahl, 0.2));
    pen.sphere(0.5, 0.45, z + 0.45, 0.05, const Color(0xFF2B2C31));
    pen.c.drawLine(pen.p(0.5, 0.62, z + 0.1), pen.p(0.5, 0.72, z + 0.08), pen.stroke(const Color(0xFF2B2C31), 2.4));
    // Schild „Tee“ als Farbfläche, ohne Schrift (Master 7.13: keine Texte im Bild)
    pen.onFront(0.62, () => pen.c.drawRect(Rect.fromLTRB(0.4, z + 0.2, 0.6, z + 0.28), Paint()..color = const Color(0xFF7A4B2A)));
  }

  void _kaffeemaschine(IsoPen pen) {
    const z = 0.61;
    pen.box(0.28, 0.25, 0.72, 0.7, z, z + 0.36, const Color(0xFF26272B), edge: withAlpha(_white, 0.2));
    pen.box(0.34, 0.62, 0.66, 0.72, z + 0.2, z + 0.24, const Color(0xFF3A3B40));
    _tasse(pen, 0.5, 0.67, z, _porzellan);
    pen.sphere(0.4, 0.7, z + 0.31, 0.018, const Color(0xFF4FD07A));
  }

  void _kaminKalt(IsoPen pen) {
    final stein = mix(pal.wall, const Color(0xFF6B5E55), 0.55);
    pen.box(0.0, 0.04, 1.0, 0.55, 0, 1.0, stein);
    pen.onFront(0.55, () {
      final c = pen.c;
      final fuge = Paint()
        ..color = withAlpha(shade(stein, -0.4), 0.5)
        ..strokeWidth = 0.008;
      for (var z = 0.12; z < 0.95; z += 0.12) {
        c.drawLine(Offset(0, z), Offset(1, z), fuge);
      }
      final bogen = Path()
        ..moveTo(0.2, 0)
        ..lineTo(0.2, 0.44)
        ..quadraticBezierTo(0.5, 0.66, 0.8, 0.44)
        ..lineTo(0.8, 0)
        ..close();
      c.drawPath(bogen, Paint()..color = shade(stein, -0.3));
      final innen = Path()
        ..moveTo(0.25, 0)
        ..lineTo(0.25, 0.42)
        ..quadraticBezierTo(0.5, 0.6, 0.75, 0.42)
        ..lineTo(0.75, 0)
        ..close();
      c.drawPath(innen, Paint()..color = const Color(0xFF141210));
      // Kalte Asche und angekohlte Scheite: seit dem Qualm um 23:30 aus.
      c.drawRect(const Rect.fromLTRB(0.27, 0.0, 0.73, 0.05), Paint()..color = const Color(0xFF5E5A55));
      final scheit = Paint()..color = const Color(0xFF231A14);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(0.32, 0.04, 0.68, 0.09), const Radius.circular(0.03)), scheit);
    });
    pen.box(-0.03, 0.0, 1.03, 0.62, 0.98, 1.08, shade(stein, 0.18), edge: withAlpha(_white, 0.15));
  }

  void _wendeltreppe(IsoPen pen) {
    final stein = mix(pal.wall, const Color(0xFF8A7F74), 0.5);
    pen.cylinder(0.5, 0.5, 0.08, 0, 1.75, shade(stein, -0.1));
    for (var i = 0; i < 9; i++) {
      final a = i * 0.7;
      final z = 0.05 + i * 0.19;
      final u = 0.5 + math.cos(a) * 0.28, v = 0.5 + math.sin(a) * 0.28;
      pen.part(u, v, () => pen.box(u - 0.14, v - 0.1, u + 0.14, v + 0.1, z, z + 0.06, stein, edge: withAlpha(_white, 0.12)));
    }
    pen.flush();
  }

  void _ruestung(IsoPen pen) {
    const metall = Color(0xFFB9BEC4);
    pen.box(0.2, 0.2, 0.8, 0.8, 0, 0.08, shade(metall, -0.45));
    for (final u in [0.42, 0.58]) {
      pen.cylinder(u, 0.5, 0.06, 0.08, 0.72, shade(metall, -0.1));
    }
    pen.cylinder(0.5, 0.5, 0.17, 0.72, 1.22, metall, rTop: 0.2);
    pen.sphere(0.5, 0.5, 1.24, 0.21, metall, squash: 0.4);
    for (final u in [0.27, 0.73]) {
      pen.cylinder(u, 0.5, 0.05, 0.78, 1.18, shade(metall, -0.05));
    }
    pen.cylinder(0.5, 0.5, 0.11, 1.26, 1.5, metall, rTop: 0.1);
    pen.sphere(0.5, 0.5, 1.52, 0.11, shade(metall, 0.1), squash: 0.7);
    // Visierschlitz
    pen.c.drawLine(pen.p(0.43, 0.6, 1.42), pen.p(0.57, 0.6, 1.42), pen.stroke(const Color(0xFF15161A), 1.4));
    // Hellebarde
    pen.c.drawLine(pen.p(0.82, 0.55, 0.08), pen.p(0.82, 0.55, 1.75), pen.stroke(pal.darkWood, 1.6));
    pen.sphere(0.82, 0.55, 1.75, 0.05, metall, squash: 1.6);
  }

  void _jackenstaender(IsoPen pen, Rng rng) {
    pen.oval(0.5, 0.5, 0.0, 0.18, pen.fill(withAlpha(const Color(0xFF000000), 0.3)));
    pen.cylinder(0.5, 0.5, 0.03, 0.0, 1.55, pal.darkWood);
    const farben = [Color(0xFF2E2B33), Color(0xFF6A5040), Color(0xFF3B4A5C), Color(0xFF5C3A3A)];
    for (var i = 0; i < 3; i++) {
      final a = i * 2.1;
      final u = 0.5 + math.cos(a) * 0.14, v = 0.5 + math.sin(a) * 0.14;
      pen.part(u, v, () => pen.cylinder(u, v, 0.09, 0.75, 1.45, farben[(i + rng.nextInt(4)) % farben.length], rTop: 0.06));
    }
    pen.flush();
    pen.sphere(0.5, 0.5, 1.57, 0.04, _brass);
  }

  void _kerzenstaenderLiegt(IsoPen pen) {
    // Umgestoßen auf dem Steinboden vor der Vorratsraumtür (Kanon: gegenstaende.json, kerzenstaender).
    pen.c.drawLine(pen.p(0.25, 0.6, 0.04), pen.p(0.75, 0.4, 0.04), pen.stroke(_brass, 3.0));
    pen.oval(0.22, 0.62, 0.02, 0.09, pen.fill(shade(_brass, -0.15)));
    for (final (u, v) in [(0.62, 0.28), (0.75, 0.42), (0.7, 0.58)]) {
      pen.c.drawLine(pen.p(0.6, 0.44, 0.04), pen.p(u, v, 0.05), pen.stroke(_brass, 1.6));
      pen.c.drawLine(pen.p(u, v, 0.05), pen.p(u + 0.12, v - 0.04, 0.05), pen.stroke(_wachsRot, 2.4));
    }
    // erstarrte Wachstropfen
    for (final (u, v) in [(0.5, 0.7), (0.58, 0.76), (0.44, 0.78)]) {
      pen.oval(u, v, 0.005, 0.025, pen.fill(_wachsRot));
    }
  }
}
