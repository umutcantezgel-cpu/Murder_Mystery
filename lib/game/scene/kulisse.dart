import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:mordakte_core/mordakte_core.dart';

import '../iso_math.dart';
import 'iso_pen.dart';
import 'lighting.dart';
import 'palette.dart';
import 'prop_painter.dart';

/// Ein gebackenes Bildstück der Kulisse in Welt-Bildkoordinaten.
class KulissenStueck {
  final Rect dst;
  final Image? bild;
  final Picture? ersatz;

  KulissenStueck(this.dst, this.bild, this.ersatz);
}

/// Kulisse rund um die Karte (M4, nur Darstellung): Gelände, Bäume, Gleise
/// oder Straße je nach Akte (`theme.backdrop`).
///
/// - Sie liegt unter der Karte und wird einmal in Bildstücke gebacken.
/// - Zum Rand hin läuft sie weich in den Hintergrund aus.
/// - Hohe Dinge stehen nur hinter oder neben der Karte, nie davor. So verdecken
///   sie keine Figur und keinen Fundort.
/// - Alles hängt nur von der Karte ab, nie vom Spielstand oder vom Täterpfad.
class Kulisse {
  Kulisse._(this.stuecke, this.lichter);

  final List<KulissenStueck> stuecke;

  /// Laternen der Kulisse: warme Lichtinseln in der Nacht.
  final List<GlowLight> lichter;

  static Kulisse? baue(ScenarioDef s, ScenePalette pal, PropPainter props, {double aufloesung = 1.0}) {
    final art = s.theme.backdrop;
    if (art == 'none' || !ThemeDef.backdrops.contains(art)) return null;
    final plan = _Plan(s.map, art, pal, props, s.theme.weather)..entwerfen();
    return plan.backen(aufloesung);
  }

  /// Zeichnet die Stücke im Sichtbereich [cull] (Welt-Bildkoordinaten).
  void zeichne(Canvas c, Rect cull, [Paint? paint]) {
    final p = paint ?? (Paint()..filterQuality = FilterQuality.medium);
    for (final s in stuecke) {
      if (!s.dst.overlaps(cull)) continue;
      final b = s.bild;
      if (b != null) {
        c.drawImageRect(b, Rect.fromLTWH(0, 0, b.width.toDouble(), b.height.toDouble()), s.dst, p);
      } else if (s.ersatz != null) {
        c.save();
        c.clipRect(s.dst);
        c.drawPicture(s.ersatz!);
        c.restore();
      }
    }
  }

  void dispose() {
    for (final s in stuecke) {
      s.bild?.dispose();
      s.ersatz?.dispose();
    }
  }
}

/// Ein Ding der Kulisse auf einer Kachel.
class _Ding {
  final String art;
  final int x, y;
  final double groesse;
  final double hoehe;
  final int samen;
  final String? farbe;

  _Ding(this.art, this.x, this.y, this.groesse, this.hoehe, this.samen, {this.farbe});

  Offset get fuss => Iso.toScreen(x + 0.5, y + 0.5);

  Rect get grenzen {
    final f = fuss;
    final breit = (art == 'palme' ? 52.0 : art == 'auto' ? 50.0 : 40.0) * groesse;
    return Rect.fromLTRB(f.dx - breit, f.dy - (hoehe * Iso.unitZ + 30) * groesse, f.dx + breit, f.dy + 22 * groesse);
  }
}

class _Plan {
  _Plan(this.map, this.art, this.pal, this.props, this.wetter);

  final MapDef map;
  final String art;
  final ScenePalette pal;
  final PropPainter props;
  final String wetter;

  late final int reichweite = art == 'keller' ? 7 : 11;

  /// Bis zu diesem Abstand ist die Kulisse voll deckend.
  late final double dicht = art == 'keller' ? 1.6 : 3.5;

  late final bool schnee = wetter == 'snow' || art == 'burg';

  final Map<Pt, int> abstand = {};
  final Map<Pt, String> boden = {};
  final List<_Ding> dinge = [];
  final List<void Function(Canvas)> zeichen = [];
  final List<GlowLight> lichter = [];
  final Set<Pt> belegt = {};
  final Map<int, int> _minTiefe = {}, _maxTiefe = {};

  int get w => map.width;
  int get h => map.height;

  bool karte(int x, int y) => map.charAt(x, y) != TileChar.void_;
  bool wand(int x, int y) {
    final c = map.charAt(x, y);
    return c == TileChar.wall || c == TileChar.window;
  }

  double deckkraft(int d) {
    if (d <= dicht) return 1;
    // Am Rand der Reichweite ganz durchsichtig: kein Umriss am Ende.
    final t = (1 - (d - dicht) / (reichweite - 0.5 - dicht)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  // ---------------------------------------------------------------------------
  // Entwurf

  void entwerfen() {
    _abstaende();
    for (final t in abstand.keys) {
      boden[t] = switch (art) {
        'keller' => 'fels',
        'burg' => 'schnee',
        'gleis' => 'schnee',
        'motel' => 'sand',
        _ => 'rasen',
      };
    }
    switch (art) {
      case 'keller':
        _keller(Rng(0x6b656c));
      case 'burg':
        _burg(Rng(0x627572));
      case 'garten':
        _garten(Rng(0x676172));
      case 'gleis':
        _gleis(Rng(0x676c65));
      case 'motel':
        _motel(Rng(0x6d6f74));
      case 'schloss':
        _schloss(Rng(0x736368));
    }
  }

  void _abstaende() {
    var rand = <Pt>[];
    final besucht = <Pt>{};
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (!karte(x, y)) continue;
        final p = Pt(x, y);
        rand.add(p);
        besucht.add(p);
        final c = x - y, d = x + y;
        _minTiefe[c] = math.min(_minTiefe[c] ?? d, d);
        _maxTiefe[c] = math.max(_maxTiefe[c] ?? d, d);
      }
    }
    for (var d = 1; d <= reichweite; d++) {
      final neu = <Pt>[];
      for (final p in rand) {
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            final q = Pt(p.x + dx, p.y + dy);
            if (besucht.add(q)) {
              abstand[q] = d;
              neu.add(q);
            }
          }
        }
      }
      rand = neu;
    }
  }

  /// Steht ein hohes Ding hier hinter allem, was die Karte in seinen
  /// Bildspalten zeigt? Dann verdeckt es nichts.
  bool _hinten(int x, int y) {
    final c = x - y, d = x + y;
    for (var k = c - 2; k <= c + 2; k++) {
      final m = _minTiefe[k];
      if (m != null && m <= d) return false;
    }
    return true;
  }

  /// Darf ein niedriges Ding der Höhe [hoehe] hier stehen, ohne die Karte zu
  /// überdecken? Je Bildspalte: Liegt die Karte dort ganz davor, ist es
  /// verdeckt und richtig; liegt sie dahinter, braucht es genug Abstand.
  bool _niedrig(int x, int y, double hoehe) {
    final c = x - y, d = x + y;
    for (var k = c - 2; k <= c + 2; k++) {
      final n = _minTiefe[k];
      if (n == null || n > d) continue;
      if (_maxTiefe[k]! > d - 1.5 - hoehe * 2.5) return false;
    }
    return true;
  }

  bool _frei(int x, int y, int rand) {
    for (var dy = -rand; dy <= rand; dy++) {
      for (var dx = -rand; dx <= rand; dx++) {
        if (belegt.contains(Pt(x + dx, y + dy))) return false;
      }
    }
    return true;
  }

  static const _hoehen = {'baum': 2.1, 'tanne': 2.4, 'palme': 2.9, 'laterne': 2.8, 'busch': 0.7, 'fels': 0.45, 'auto': 0.95, 'mauer': 0.9};

  /// Setzt ein Ding, wenn die Kachel zur Kulisse gehört, frei ist und es
  /// nichts von der Karte verdeckt.
  bool setze(String a, int x, int y, Rng rng, {double groesse = 1, String? farbe, int rand = 0}) {
    final t = Pt(x, y);
    final d = abstand[t];
    if (d == null || deckkraft(d) < (a == 'laterne' ? 0.7 : 0.2)) return false;
    final hoehe = (_hoehen[a] ?? 1) * groesse;
    final erlaubt = hoehe > 1.0 ? _hinten(x, y) : _niedrig(x, y, hoehe);
    if (!erlaubt || !_frei(x, y, rand)) return false;
    belegt.add(t);
    dinge.add(_Ding(a, x, y, groesse, _hoehen[a] ?? 1, rng.nextUint32(), farbe: farbe));
    if (a == 'laterne') {
      lichter.add(GlowLight(x + 0.5, y + 0.5, 2.55, 2.9, mix(pal.light, const Color(0xFFFFE2A8), 0.3), 1.0));
    }
    return true;
  }

  void _flaeche(String stil, int x0, int y0, int x1, int y1) {
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final t = Pt(x, y);
        if (abstand.containsKey(t)) boden[t] = stil;
      }
    }
  }

  List<Pt> get _ringGeordnet {
    final l = abstand.keys.toList()..sort((a, b) => a.y != b.y ? a.y.compareTo(b.y) : a.x.compareTo(b.x));
    return l;
  }

  // --- Akten ---------------------------------------------------------------

  void _keller(Rng rng) {
    for (final t in _ringGeordnet) {
      final d = abstand[t]!;
      if (d >= 2 && rng.chance(0.09)) setze('fels', t.x, t.y, rng, groesse: 0.7 + rng.nextDouble() * 0.6, rand: 1);
    }
  }

  void _burg(Rng rng) {
    final r = reichweite;
    // Felsiger Burgfels direkt an der Mauer, eine Straße im Westen.
    for (final t in abstand.keys) {
      if (abstand[t]! <= 1) boden[t] = 'fels';
    }
    _flaeche('kies', -4, -r, -3, h + r);
    for (var y = -r + 2; y < h + r; y += 7) {
      setze('laterne', -5, y, rng);
    }
    for (final t in _ringGeordnet) {
      final d = abstand[t]!;
      if (boden[t] == 'kies') continue;
      if (d >= 2 && rng.chance(d <= 3 ? 0.16 : 0.36)) {
        if (setze('tanne', t.x, t.y, rng, groesse: 0.8 + rng.nextDouble() * 0.6 + (d >= 5 ? 0.2 : 0), rand: 1)) continue;
      }
      if (d >= 2 && rng.chance(0.06)) setze('fels', t.x, t.y, rng, groesse: 0.7 + rng.nextDouble() * 0.7, rand: 1);
    }
  }

  void _garten(Rng rng) {
    final r = reichweite;
    // Kiesauffahrt im Süden, Kiesweg im Westen, Hecke hinter dem Haus.
    _flaeche('kies', -r, h + 2, w + r, h + 3);
    _flaeche('kies', -4, -r, -3, h + 3);
    for (var x = 0; x < w; x++) {
      if (rng.chance(0.75)) setze('busch', x, -1, rng, groesse: 0.85 + rng.nextDouble() * 0.3);
    }
    for (var y = -r + 3; y < h; y += 6) {
      setze('laterne', -2, y, rng);
    }
    for (var x = 4; x < w; x += 9) {
      setze('laterne', x, -3, rng);
    }
    const lacke = ['#5A1E24', '#24384A', '#2E3B2A'];
    setze('auto', (w * 0.28).round(), h + 2, rng, farbe: lacke[0]);
    setze('auto', (w * 0.64).round(), h + 2, rng, farbe: lacke[1]);
    for (final t in _ringGeordnet) {
      final d = abstand[t]!;
      if (boden[t] != 'rasen') continue;
      if (d >= 3 && rng.chance(d <= 4 ? 0.2 : 0.4)) {
        final tanne = rng.chance(0.3);
        final gross = 0.9 + rng.nextDouble() * 0.45 + (d >= 5 ? 0.25 : 0);
        if (setze(tanne ? 'tanne' : 'baum', t.x, t.y, rng, groesse: gross, rand: 1)) continue;
      }
      if (d >= 3 && rng.chance(0.06)) setze('busch', t.x, t.y, rng, groesse: 0.8 + rng.nextDouble() * 0.4);
    }
  }

  void _gleis(Rng rng) {
    final r = reichweite;
    // Gleisbetten: unter beiden Wagenreihen, ein Nachbargleis im Norden und
    // eines im Süden; dazwischen ein Bahnsteig an der Nordseite.
    final gleise = <double>[3.0, 11.0, -5.0, h + 3.0];
    for (final yc in gleise) {
      _flaeche('schotter', -r, yc.floor() - 2, w + r, yc.floor() + 1);
    }
    _flaeche('schotter', -r, 6, w + r, 7);
    _flaeche('beton', -r, -2, w + r, -1);
    zeichen.add((c) {
      for (final yc in gleise) {
        _schienen(c, yc, -r.toDouble(), (w + r).toDouble());
      }
      _bahnsteigKante(c, -0.32, -r.toDouble(), (w + r).toDouble());
    });
    for (var x = 2; x < w; x += 7) {
      setze('laterne', x, -2, rng);
    }
    for (final t in _ringGeordnet) {
      final d = abstand[t]!;
      if (boden[t] != 'schnee') continue;
      if (d >= 2 && rng.chance(0.32)) {
        if (setze('tanne', t.x, t.y, rng, groesse: 0.8 + rng.nextDouble() * 0.6, rand: 1)) continue;
      }
      if (d >= 2 && rng.chance(0.03)) setze('fels', t.x, t.y, rng, groesse: 0.7 + rng.nextDouble() * 0.5, rand: 1);
    }
  }

  void _schloss(Rng rng) {
    final r = reichweite;
    // Ebenen des langen Abends (M7a): Fels am Mauerfuß mit Mauerkronen auf
    // dem Ring dahinter, ein Kiesweg im Westen, dann Rasen mit Tannen und
    // alten Bäumen bis in die Nacht.
    for (final t in abstand.keys) {
      if (abstand[t]! <= 1) boden[t] = 'fels';
    }
    _flaeche('kies', -4, -r, -3, h + r);
    for (final t in _ringGeordnet) {
      if (abstand[t] == 1 && (t.x + t.y).isEven) setze('mauer', t.x, t.y, rng);
    }
    for (var y = -r + 2; y < h + r; y += 8) {
      setze('laterne', -5, y, rng);
    }
    for (final t in _ringGeordnet) {
      final d = abstand[t]!;
      if (boden[t] != 'rasen') continue;
      if (d >= 3 && rng.chance(d <= 4 ? 0.14 : 0.3)) {
        final tanne = rng.chance(0.4);
        final gross = 0.85 + rng.nextDouble() * 0.4 + (d >= 6 ? 0.2 : 0);
        if (setze(tanne ? 'tanne' : 'baum', t.x, t.y, rng, groesse: gross, rand: 1)) continue;
      }
      if (d >= 2 && rng.chance(0.05)) setze('busch', t.x, t.y, rng, groesse: 0.8 + rng.nextDouble() * 0.3);
    }
  }

  void _motel(Rng rng) {
    final r = reichweite;
    // Gehweg, vierspurige Küstenstraße im Süden, Rasenstreifen hinter dem Haus.
    _flaeche('rasen', -r, -2, w + r, -1);
    _flaeche('beton', -r, h, w + r, h);
    _flaeche('asphalt', -r, h + 1, w + r, h + 4);
    _flaeche('beton', -r, h + 5, w + r, h + 5);
    zeichen.add((c) => _strasse(c, h + 1.0, h + 5.0, -r.toDouble(), (w + r).toDouble()));
    for (var x = 0; x < w; x++) {
      if (rng.chance(0.4)) setze('busch', x, -1, rng, groesse: 0.8 + rng.nextDouble() * 0.3);
    }
    for (var x = 3; x < w; x += 10) {
      setze('laterne', x, -3, rng);
    }
    const lacke = ['#E3D6B8', '#7A2E3A', '#2E5E6E'];
    // Nur auf der hinteren Spur: näher am Haus würde das Dach die Mauer schneiden.
    setze('auto', (w * 0.22).round(), h + 3, rng, farbe: lacke[0]);
    setze('auto', (w * 0.58).round(), h + 4, rng, farbe: lacke[1]);
    setze('auto', (w * 0.86).round(), h + 3, rng, farbe: lacke[2]);
    for (final t in _ringGeordnet) {
      final d = abstand[t]!;
      if (boden[t] != 'sand' && boden[t] != 'rasen') continue;
      if (d >= 2 && rng.chance(d <= 3 ? 0.2 : 0.16)) {
        if (setze('palme', t.x, t.y, rng, groesse: 0.85 + rng.nextDouble() * 0.4, rand: 1)) continue;
      }
      if (d >= 3 && rng.chance(0.05)) setze('busch', t.x, t.y, rng, groesse: 0.7 + rng.nextDouble() * 0.3);
    }
  }

  // ---------------------------------------------------------------------------
  // Backen

  Kulisse backen(double res) {
    final ring = _ringGeordnet.where((t) => deckkraft(abstand[t]!) > 0).toList();
    dinge.sort((a, b) {
      final d = (a.x + a.y).compareTo(b.x + b.y);
      return d != 0 ? d : a.x.compareTo(b.x);
    });
    const zelle = 512.0;
    final kacheln = <(int, int), List<Pt>>{};
    final dingeJe = <(int, int), List<_Ding>>{};
    void eintragen<T>(Map<(int, int), List<T>> ziel, Rect r, T wert) {
      for (var j = (r.top / zelle).floor(); j <= (r.bottom / zelle).floor(); j++) {
        for (var i = (r.left / zelle).floor(); i <= (r.right / zelle).floor(); i++) {
          (ziel[(i, j)] ??= []).add(wert);
        }
      }
    }

    for (final t in ring) {
      eintragen(kacheln, Iso.tileBounds(t.x, t.y, 0, 36), t);
    }
    for (final d in dinge) {
      eintragen(dingeJe, d.grenzen, d);
    }
    final maske = _maske();
    final stuecke = <KulissenStueck>[];
    final schluessel = {...kacheln.keys, ...dingeJe.keys}.toList()..sort((a, b) => a.$2 != b.$2 ? a.$2.compareTo(b.$2) : a.$1.compareTo(b.$1));
    for (final k in schluessel) {
      final rect = Rect.fromLTWH(k.$1 * zelle, k.$2 * zelle, zelle, zelle);
      final tiles = kacheln[k] ?? const <Pt>[];
      final ds = dingeJe[k] ?? const <_Ding>[];
      if (!tiles.any((t) => Iso.tileBounds(t.x, t.y, 0).overlaps(rect)) && ds.isEmpty) continue;
      // In Weltkoordinaten aufnehmen, dann gerastert backen.
      final rec = PictureRecorder();
      final c = Canvas(rec);
      c.clipRect(rect);
      c.saveLayer(rect, Paint());
      _zeichneZelle(c, tiles, ds, maske);
      c.restore();
      final welt = rec.endRecording();
      Image? bild;
      try {
        final rec2 = PictureRecorder();
        final c2 = Canvas(rec2);
        c2.scale(res);
        c2.translate(-rect.left, -rect.top);
        c2.drawPicture(welt);
        final pic = rec2.endRecording();
        bild = pic.toImageSync((zelle * res).ceil(), (zelle * res).ceil());
        pic.dispose();
      } catch (_) {
        bild = null;
      }
      if (bild != null) {
        welt.dispose();
        stuecke.add(KulissenStueck(rect, bild, null));
      } else {
        stuecke.add(KulissenStueck(rect, null, welt));
      }
    }
    maske?.dispose();
    return Kulisse._(stuecke, lichter);
  }

  /// Ausblendmaske: ein Bildpunkt je Kachel (0 = Kulisse bleibt, 1 = weg),
  /// beim Zeichnen bilinear geglättet.
  Image? _maske() {
    final r = reichweite;
    final gw = w + 2 * r, gh = h + 2 * r;
    final rec = PictureRecorder();
    final c = Canvas(rec);
    final p = Paint()..isAntiAlias = false;
    for (var j = 0; j < gh; j++) {
      for (var i = 0; i < gw; i++) {
        final x = i - r, y = j - r;
        if (karte(x, y)) continue;
        final d = abstand[Pt(x, y)];
        final a = d == null ? 1.0 : 1 - deckkraft(d);
        if (a <= 0) continue;
        p.color = Color.fromRGBO(0, 0, 0, a);
        c.drawRect(Rect.fromLTWH(i.toDouble(), j.toDouble(), 1, 1), p);
      }
    }
    final pic = rec.endRecording();
    try {
      return pic.toImageSync(gw, gh);
    } catch (_) {
      return null;
    } finally {
      pic.dispose();
    }
  }

  void _zeichneZelle(Canvas c, List<Pt> tiles, List<_Ding> ds, Image? maske) {
    c.save();
    Iso.applyGround(c);
    _grund(c, tiles);
    for (final t in tiles) {
      _muster(c, t);
    }
    _kontaktschatten(c, tiles);
    for (final z in zeichen) {
      z(c);
    }
    c.restore();
    for (final d in ds) {
      _ding(c, d);
    }
    final r = reichweite.toDouble();
    c.save();
    Iso.applyGround(c);
    if (maske != null) {
      c.drawImageRect(
        maske,
        Rect.fromLTWH(0, 0, maske.width.toDouble(), maske.height.toDouble()),
        Rect.fromLTWH(-r, -r, maske.width.toDouble(), maske.height.toDouble()),
        Paint()
          ..blendMode = BlendMode.dstOut
          ..filterQuality = FilterQuality.low,
      );
    } else {
      // Ohne Bild: stufig je Kachel ausblenden.
      final p = Paint()..blendMode = BlendMode.dstOut;
      for (final t in tiles) {
        final a = 1 - deckkraft(abstand[t]!);
        if (a <= 0) continue;
        p.color = Color.fromRGBO(0, 0, 0, a);
        c.drawRect(Rect.fromLTWH(t.x.toDouble(), t.y.toDouble(), 1, 1), p);
      }
    }
    c.restore();
  }

  // --- Boden ---------------------------------------------------------------

  (Color, Color) _farben(String stil) {
    final f = pal.fog;
    return switch (stil) {
      'rasen' => (mix(const Color(0xFF34502A), f, 0.18), mix(const Color(0xFF203619), f, 0.18)),
      'kies' => (mix(const Color(0xFF706A61), f, 0.2), mix(const Color(0xFF4E4943), f, 0.2)),
      'schotter' => (mix(const Color(0xFF59534D), f, 0.15), mix(const Color(0xFF3A3632), f, 0.15)),
      'schnee' => (mix(const Color(0xFFDCE4EE), f, 0.08), mix(const Color(0xFFA9B8CC), f, 0.08)),
      'asphalt' => (mix(const Color(0xFF303237), f, 0.08), mix(const Color(0xFF222428), f, 0.08)),
      'fels' => (mix(const Color(0xFF4B4641), f, 0.3), mix(const Color(0xFF2B2825), f, 0.3)),
      'beton' => (mix(const Color(0xFF85827A), f, 0.15), mix(const Color(0xFF65625C), f, 0.15)),
      'sand' => (mix(const Color(0xFFB59C70), f, 0.22), mix(const Color(0xFF8C7752), f, 0.22)),
      _ => (pal.floor, pal.floorAlt),
    };
  }

  /// Weiches Wertrauschen (0..1), zwei Oktaven.
  double _rauschen(double x, double y) {
    double gitter(int i, int j) {
      var n = (i * 374761393 + j * 668265263) & 0x7fffffff;
      n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff;
      return (n & 0xffff) / 0xffff;
    }

    double oktave(double x, double y) {
      final i = x.floor(), j = y.floor();
      final fx = x - i, fy = y - j;
      final sx = fx * fx * (3 - 2 * fx), sy = fy * fy * (3 - 2 * fy);
      final a = gitter(i, j), b = gitter(i + 1, j), c = gitter(i, j + 1), d = gitter(i + 1, j + 1);
      return (a + (b - a) * sx) + ((c + (d - c) * sx) - (a + (b - a) * sx)) * sy;
    }

    return oktave(x / 5, y / 5) * 0.7 + oktave(x / 1.7 + 11, y / 1.7 + 7) * 0.3;
  }

  /// Grundfarben als Netz mit Eckfarben: weicher Verlauf ohne Kachelraster.
  void _grund(Canvas c, List<Pt> tiles) {
    final pos = Float32List(tiles.length * 12);
    final farben = Int32List(tiles.length * 6);
    var k = 0, f = 0;
    for (final t in tiles) {
      final (a, b) = _farben(boden[t]!);
      int ecke(double x, double y) => mix(a, b, 0.1 + 0.6 * _rauschen(x, y)).toARGB32();
      final x0 = t.x - 0.02, y0 = t.y - 0.02, x1 = t.x + 1.02, y1 = t.y + 1.02;
      final c00 = ecke(t.x.toDouble(), t.y.toDouble()), c10 = ecke(t.x + 1.0, t.y.toDouble());
      final c01 = ecke(t.x.toDouble(), t.y + 1.0), c11 = ecke(t.x + 1.0, t.y + 1.0);
      for (final (x, y, col) in [(x0, y0, c00), (x1, y0, c10), (x1, y1, c11), (x0, y0, c00), (x1, y1, c11), (x0, y1, c01)]) {
        pos[k++] = x;
        pos[k++] = y;
        farben[f++] = col;
      }
    }
    final v = Vertices.raw(VertexMode.triangles, pos, colors: farben);
    c.drawVertices(v, BlendMode.dst, Paint());
    v.dispose();
  }

  static const _weiss = Color(0xFFFFFFFF);
  static const _schwarz = Color(0xFF000000);

  void _muster(Canvas c, Pt t) {
    final stil = boden[t]!;
    final rng = Rng((t.x * 73856093) ^ (t.y * 19349663) ^ stil.length * 83492791);
    final (a, b) = _farben(stil);
    final p = Paint();
    double rx() => t.x + rng.nextDouble();
    double ry() => t.y + rng.nextDouble();
    switch (stil) {
      case 'rasen':
        if (rng.chance(0.5)) {
          p.color = withAlpha(rng.chance(0.5) ? shade(a, 0.14) : b, 0.32);
          c.drawOval(Rect.fromCenter(center: Offset(rx(), ry()), width: 0.6 + rng.nextDouble(), height: 0.5 + rng.nextDouble() * 0.7), p);
        }
        final halm = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.02
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 16; i++) {
          final x = rx(), y = ry(), l = 0.05 + rng.nextDouble() * 0.07;
          halm.color = withAlpha(rng.chance(0.5) ? shade(a, 0.28) : shade(b, -0.2), 0.6);
          c.drawLine(Offset(x, y), Offset(x - l + rng.nextDouble() * 0.03, y - l), halm);
        }
        if (rng.chance(0.06)) {
          p.color = rng.chance(0.5) ? const Color(0xCCE8E0C8) : const Color(0xCCD9B44A);
          c.drawCircle(Offset(rx(), ry()), 0.03, p);
        }
      case 'kies' || 'schotter':
        final n = stil == 'kies' ? 16 : 22;
        for (var i = 0; i < n; i++) {
          final r = 0.02 + rng.nextDouble() * 0.035;
          p.color = withAlpha(rng.chance(0.5) ? shade(a, 0.25) : shade(b, -0.25), 0.75);
          c.drawOval(Rect.fromCenter(center: Offset(rx(), ry()), width: r * 2, height: r * 1.5), p);
        }
        if (schnee && rng.chance(0.5)) {
          p.color = withAlpha(_weiss, 0.35);
          c.drawOval(Rect.fromCenter(center: Offset(rx(), ry()), width: 0.5 + rng.nextDouble() * 0.5, height: 0.3 + rng.nextDouble() * 0.3), p);
        }
      case 'schnee':
        if (rng.chance(0.55)) {
          p.color = withAlpha(rng.chance(0.6) ? _weiss : b, 0.28);
          c.drawOval(Rect.fromCenter(center: Offset(rx(), ry()), width: 0.8 + rng.nextDouble(), height: 0.5 + rng.nextDouble() * 0.6), p);
        }
        p.color = const Color(0xCCFFFFFF);
        for (var i = 0; i < 3; i++) {
          c.drawCircle(Offset(rx(), ry()), 0.013, p);
        }
      case 'asphalt':
        for (var i = 0; i < 10; i++) {
          p.color = withAlpha(rng.chance(0.5) ? _weiss : _schwarz, 0.08 + rng.nextDouble() * 0.08);
          c.drawCircle(Offset(rx(), ry()), 0.012 + rng.nextDouble() * 0.012, p);
        }
        if (rng.chance(0.06)) _riss(c, t, rng, 0.3);
      case 'fels':
        for (var i = 0; i < 2; i++) {
          p.color = withAlpha(rng.chance(0.5) ? shade(a, 0.12) : shade(b, -0.3), 0.3);
          c.drawOval(Rect.fromCenter(center: Offset(rx(), ry()), width: 0.4 + rng.nextDouble() * 0.6, height: 0.3 + rng.nextDouble() * 0.5), p);
        }
        for (var i = 0; i < 5; i++) {
          p.color = withAlpha(shade(a, 0.3), 0.5);
          c.drawCircle(Offset(rx(), ry()), 0.015 + rng.nextDouble() * 0.02, p);
        }
        if (rng.chance(0.22)) _riss(c, t, rng, 0.4);
      case 'beton':
        c.drawRect(
          Rect.fromLTWH(t.x + 0.02, t.y + 0.02, 0.96, 0.96),
          Paint()
            ..color = withAlpha(_schwarz, 0.22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.02,
        );
        for (var i = 0; i < 6; i++) {
          p.color = withAlpha(rng.chance(0.5) ? _weiss : _schwarz, 0.1);
          c.drawCircle(Offset(rx(), ry()), 0.012, p);
        }
        if (schnee && rng.chance(0.4)) {
          p.color = withAlpha(_weiss, 0.3);
          c.drawOval(Rect.fromCenter(center: Offset(rx(), ry()), width: 0.6, height: 0.35), p);
        }
      case 'sand':
        for (var i = 0; i < 14; i++) {
          p.color = withAlpha(rng.chance(0.5) ? shade(a, 0.2) : shade(b, -0.2), 0.22);
          c.drawCircle(Offset(rx(), ry()), 0.012 + rng.nextDouble() * 0.015, p);
        }
        if (rng.chance(0.3)) {
          final welle = Paint()
            ..color = withAlpha(shade(b, -0.15), 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.018;
          final y = ry();
          c.drawPath(Path()
            ..moveTo(t.x.toDouble(), y)
            ..quadraticBezierTo(t.x + 0.5, y - 0.12, t.x + 1.0, y), welle);
        }
    }
  }

  void _riss(Canvas c, Pt t, Rng rng, double a) {
    final p = Paint()
      ..color = withAlpha(_schwarz, a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.016;
    final path = Path()..moveTo(t.x + rng.nextDouble(), t.y.toDouble());
    for (var k = 1; k <= 3; k++) {
      path.lineTo(t.x + rng.nextDouble(), t.y + k / 3);
    }
    c.drawPath(path, p);
  }

  /// Weicher Schatten am Fuß der Außenmauern.
  void _kontaktschatten(Canvas c, List<Pt> tiles) {
    final p = Paint();
    for (final t in tiles) {
      if (abstand[t] != 1) continue;
      final x = t.x.toDouble(), y = t.y.toDouble();
      for (final (dx, dy, a) in [(0, -1, 0.42), (-1, 0, 0.42), (0, 1, 0.28), (1, 0, 0.28)]) {
        if (!wand(t.x + dx, t.y + dy)) continue;
        final (von, bis) = switch ((dx, dy)) {
          (0, -1) => (Offset(x, y), Offset(x, y + 0.55)),
          (-1, 0) => (Offset(x, y), Offset(x + 0.55, y)),
          (0, 1) => (Offset(x, y + 1), Offset(x, y + 0.45)),
          _ => (Offset(x + 1, y), Offset(x + 0.45, y)),
        };
        p.shader = Gradient.linear(von, bis, [withAlpha(_schwarz, a), withAlpha(_schwarz, 0)]);
        c.drawRect(Rect.fromLTWH(x, y, 1, 1), p);
      }
    }
  }

  // --- Zeichen auf dem Boden -------------------------------------------------

  void _schienen(Canvas c, double yc, double x0, double x1) {
    final schwelle = Paint()..color = mix(const Color(0xFF3D3026), pal.fog, 0.2);
    final kante = Paint()..color = withAlpha(_schwarz, 0.35);
    final reif = Paint()..color = withAlpha(_weiss, 0.55);
    final rng = Rng((yc * 1000).round() & 0x7fffffff);
    for (var x = x0; x < x1; x += 0.72) {
      c.drawRect(Rect.fromLTWH(x + 0.03, yc - 1.32, 0.26, 2.64), kante);
      c.drawRect(Rect.fromLTWH(x, yc - 1.35, 0.26, 2.64), schwelle);
      if (schnee && rng.chance(0.6)) {
        c.drawOval(Rect.fromLTWH(x + 0.02, yc - 1.2 + rng.nextDouble() * 1.6, 0.22, 0.5 + rng.nextDouble() * 0.5), reif);
      }
    }
    final stahl = Paint()
      ..color = const Color(0xFF7D8288)
      ..strokeWidth = 0.1;
    final glanz = Paint()
      ..color = const Color(0xFFD9DDE2)
      ..strokeWidth = 0.035;
    final schatten = Paint()
      ..color = withAlpha(_schwarz, 0.4)
      ..strokeWidth = 0.08;
    for (final dy in [-0.95, 0.95]) {
      c.drawLine(Offset(x0, yc + dy + 0.07), Offset(x1, yc + dy + 0.07), schatten);
      c.drawLine(Offset(x0, yc + dy), Offset(x1, yc + dy), stahl);
      c.drawLine(Offset(x0, yc + dy - 0.03), Offset(x1, yc + dy - 0.03), glanz);
    }
  }

  void _bahnsteigKante(Canvas c, double y, double x0, double x1) {
    c.drawRect(Rect.fromLTRB(x0, y, x1, y + 0.18), Paint()..color = mix(const Color(0xFFB8B4AA), pal.fog, 0.1));
    final gelb = Paint()..color = mix(const Color(0xFFE2C04A), pal.fog, 0.15);
    for (var x = x0; x < x1; x += 0.5) {
      c.drawRect(Rect.fromLTWH(x, y - 0.32, 0.32, 0.08), gelb);
    }
  }

  void _strasse(Canvas c, double y0, double y1, double x0, double x1) {
    final rand = Paint()
      ..color = withAlpha(const Color(0xFFE8E4D6), 0.55)
      ..strokeWidth = 0.07;
    c.drawLine(Offset(x0, y0 + 0.18), Offset(x1, y0 + 0.18), rand);
    c.drawLine(Offset(x0, y1 - 0.18), Offset(x1, y1 - 0.18), rand);
    final mitte = Paint()..color = withAlpha(const Color(0xFFE6C55A), 0.85);
    final ym = (y0 + y1) / 2;
    c.drawRect(Rect.fromLTRB(x0, ym - 0.1, x1, ym - 0.04), mitte);
    c.drawRect(Rect.fromLTRB(x0, ym + 0.04, x1, ym + 0.1), mitte);
    final strich = Paint()..color = withAlpha(const Color(0xFFE8E4D6), 0.5);
    for (var x = x0; x < x1; x += 2.2) {
      c.drawRect(Rect.fromLTWH(x, y0 + 0.97, 1.0, 0.07), strich);
      c.drawRect(Rect.fromLTWH(x + 1.1, y1 - 1.04, 1.0, 0.07), strich);
    }
  }

  // --- Dinge -----------------------------------------------------------------

  void _ding(Canvas c, _Ding d) {
    final f = d.fuss;
    final rng = Rng(d.samen & 0x7fffffff);
    c.save();
    if (d.groesse != 1) {
      c.translate(f.dx, f.dy);
      c.scale(d.groesse);
      c.translate(-f.dx, -f.dy);
    }
    final pen = IsoPen(c, d.x.toDouble(), d.y.toDouble());
    switch (d.art) {
      case 'baum':
        _schattenOval(pen, 0.5, 0.55, 0.5);
        props.paint(c, PropDef(type: 'tree', x: d.x, y: d.y));
      case 'busch':
        _schattenOval(pen, 0.5, 0.55, 0.38);
        props.paint(c, PropDef(type: 'bush', x: d.x, y: d.y));
      case 'auto':
        _schattenOval(pen, 0.5, 0.55, 0.62);
        props.paint(c, PropDef(type: 'car', x: d.x, y: d.y, color: d.farbe));
      case 'tanne':
        _tanne(pen, rng);
      case 'palme':
        _palme(pen, rng);
      case 'fels':
        _fels(pen, rng);
      case 'laterne':
        _laterne(pen);
      case 'mauer':
        _mauerkrone(pen);
    }
    c.restore();
  }

  /// Mauerkrone hinter der Karte: Mauerstück mit Zinne (Kulisse schloss).
  void _mauerkrone(IsoPen pen) {
    final stein = mix(pal.wall, const Color(0xFF6B5E55), 0.5);
    pen.box(0.0, 0.0, 1.0, 1.0, 0, 0.55, stein, edge: withAlpha(_weiss, 0.08));
    pen.box(0.15, 0.15, 0.85, 0.85, 0.55, 0.9, shade(stein, 0.1), edge: withAlpha(_weiss, 0.08));
  }

  void _schattenOval(IsoPen pen, double u, double v, double r) => pen.oval(u, v, 0, r, pen.fill(withAlpha(_schwarz, 0.3)));

  void _tanne(IsoPen pen, Rng rng) {
    _schattenOval(pen, 0.5, 0.55, 0.48);
    pen.cylinder(0.5, 0.5, 0.07, 0, 0.5, const Color(0xFF3E2A1C), rTop: 0.05);
    final gruen = mix(const Color(0xFF1E3A2B), pal.fog, 0.2);
    const lagen = 4;
    for (var i = 0; i < lagen; i++) {
      final z0 = 0.38 + i * 0.44;
      final z1 = z0 + 0.95 - i * 0.08;
      final r = 0.52 - i * 0.1;
      _kegel(pen, z0, z1, r, shade(gruen, i * 0.035 + (rng.nextDouble() - 0.5) * 0.06), rng);
    }
  }

  void _kegel(IsoPen pen, double z0, double z1, double r, Color col, Rng rng) {
    final c = pen.c;
    final b = pen.p(0.5, 0.5, z0), t = pen.p(0.5, 0.5, z1);
    final bw = r * IsoPen.rx, bh = r * IsoPen.ry;
    // Unterkante leicht gezackt (Zweige).
    final path = Path()..moveTo(b.dx - bw, b.dy);
    const zacken = 7;
    for (var i = 1; i <= zacken; i++) {
      final a = math.pi - i / zacken * math.pi;
      final aMitte = math.pi - (i - 0.5) / zacken * math.pi;
      final tief = Offset(b.dx + math.cos(aMitte) * bw * 0.96, b.dy + math.sin(aMitte) * bh + 2.2);
      final ende = Offset(b.dx + math.cos(a) * bw, b.dy + math.sin(a) * bh);
      path.quadraticBezierTo(tief.dx, tief.dy, ende.dx, ende.dy);
    }
    path
      ..lineTo(t.dx, t.dy)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = Gradient.linear(Offset(b.dx - bw, 0), Offset(b.dx + bw, 0), [shade(col, 0.16), col, shade(col, -0.45)], const [0.0, 0.38, 1.0]),
    );
    if (schnee) {
      const k = 0.45;
      final m = Offset.lerp(t, b, k)!;
      final mw = bw * k, mh = bh * k;
      final kappe = Path()
        ..moveTo(t.dx, t.dy)
        ..lineTo(m.dx - mw, m.dy)
        ..quadraticBezierTo(m.dx - mw * 0.4, m.dy + mh * 1.4, m.dx, m.dy + mh * 0.6)
        ..quadraticBezierTo(m.dx + mw * 0.5, m.dy + mh * 1.5, m.dx + mw, m.dy)
        ..close();
      c.drawPath(kappe, Paint()..color = const Color(0xF0EEF3F8));
      final flocke = Paint()..color = const Color(0xD8F2F6FA);
      for (var i = 0; i < 3; i++) {
        final a = 0.4 + rng.nextDouble() * (math.pi - 0.8);
        c.drawCircle(Offset(b.dx + math.cos(a) * bw * 0.8, b.dy + math.sin(a) * bh * 0.5 - 1), 1.6, flocke);
      }
    }
  }

  void _palme(IsoPen pen, Rng rng) {
    final c = pen.c;
    _schattenOval(pen, 0.5, 0.55, 0.42);
    final neig = (rng.nextDouble() - 0.5) * 0.9;
    final basis = pen.p(0.5, 0.5, 0);
    final kopf = pen.p(0.5, 0.5, 2.7) + Offset(neig * 30, 0);
    final mitte = pen.p(0.5, 0.5, 1.35) + Offset(neig * 6, 0);
    Offset bez(double t) {
      final u = 1 - t;
      return basis * (u * u) + mitte * (2 * u * t) + kopf * (t * t);
    }

    final stamm = mix(const Color(0xFF7A6040), pal.fog, 0.15);
    for (var i = 0; i < 14; i++) {
      final t0 = i / 14, t1 = (i + 1) / 14;
      c.drawLine(
        bez(t0),
        bez(t1),
        Paint()
          ..color = shade(stamm, i.isEven ? 0.06 : -0.1)
          ..strokeWidth = 5.6 - 2.2 * t0
          ..strokeCap = StrokeCap.round,
      );
    }
    final blatt = mix(const Color(0xFF2F6A3A), pal.fog, 0.22);
    final wedel = <(double, void Function())>[];
    final n = 8 + rng.nextInt(2);
    for (var i = 0; i < n; i++) {
      final a = i / n * 2 * math.pi + rng.nextDouble() * 0.5;
      final len = 30 + rng.nextDouble() * 10;
      wedel.add((
        math.sin(a),
        () {
          final dir = Offset(math.cos(a), math.sin(a) * 0.5);
          final spitze = kopf + dir * len + Offset(0, 13 + 7 * dir.dy.abs());
          final m = kopf + dir * (len * 0.5) + const Offset(0, -7);
          final nrm = Offset(-dir.dy, dir.dx) * 5.5;
          final path = Path()
            ..moveTo(kopf.dx, kopf.dy)
            ..quadraticBezierTo(m.dx + nrm.dx, m.dy + nrm.dy, spitze.dx, spitze.dy)
            ..quadraticBezierTo(m.dx - nrm.dx, m.dy - nrm.dy, kopf.dx, kopf.dy)
            ..close();
          c.drawPath(path, Paint()..color = shade(blatt, math.sin(a) * 0.12 - 0.04));
          c.drawPath(
            Path()
              ..moveTo(kopf.dx, kopf.dy)
              ..quadraticBezierTo(m.dx, m.dy, spitze.dx, spitze.dy),
            Paint()
              ..color = withAlpha(shade(blatt, 0.3), 0.6)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8,
          );
        },
      ));
    }
    wedel.sort((x, y) => x.$1.compareTo(y.$1));
    for (final (tiefe, malen) in wedel) {
      if (tiefe < 0) malen();
    }
    final nuss = Paint()..color = const Color(0xFF4A3A22);
    for (var k = 0; k < 3; k++) {
      c.drawCircle(kopf + Offset(-3.0 + k * 3, 3), 2.3, nuss);
    }
    for (final (tiefe, malen) in wedel) {
      if (tiefe >= 0) malen();
    }
  }

  void _fels(IsoPen pen, Rng rng) {
    _schattenOval(pen, 0.5, 0.58, 0.4);
    final grau = mix(const Color(0xFF6B6862), pal.fog, 0.3);
    final teile = <(double, double, double, double)>[
      (0.5, 0.5, 0.16, 0.3),
      (0.3 + rng.nextDouble() * 0.1, 0.6, 0.1, 0.2),
      (0.68, 0.45 + rng.nextDouble() * 0.15, 0.12, 0.22),
    ]..sort((a, b) => (a.$1 + a.$2).compareTo(b.$1 + b.$2));
    for (final (u, v, z, r) in teile) {
      pen.sphere(u, v, z, r, shade(grau, (rng.nextDouble() - 0.5) * 0.2), squash: 0.72);
    }
    if (schnee) {
      final o = pen.p(0.5, 0.5, 0.3);
      pen.c.drawOval(Rect.fromCenter(center: o.translate(0, -2), width: 0.36 * IsoPen.rx, height: 0.14 * IsoPen.rx), Paint()..color = const Color(0xE8F2F6FA));
    }
  }

  void _laterne(IsoPen pen) {
    final c = pen.c;
    final eisen = mix(const Color(0xFF26282C), pal.fog, 0.15);
    _schattenOval(pen, 0.5, 0.55, 0.2);
    pen.cylinder(0.5, 0.5, 0.08, 0, 0.22, eisen, rTop: 0.06);
    c.drawLine(pen.p(0.5, 0.5, 0.2), pen.p(0.5, 0.5, 2.3), pen.stroke(eisen, 2.6));
    final glas = mix(pal.light, const Color(0xFFFFF0C8), 0.35);
    pen.box(0.4, 0.4, 0.6, 0.6, 2.28, 2.62, glas, top: eisen, south: glas, eastC: shade(glas, -0.15));
    final dach = [pen.p(0.36, 0.36, 2.62), pen.p(0.64, 0.36, 2.62), pen.p(0.64, 0.64, 2.62), pen.p(0.36, 0.64, 2.62)];
    final spitze = pen.p(0.5, 0.5, 2.8);
    pen.poly([dach[3], dach[2], spitze], pen.fill(eisen));
    pen.poly([dach[2], dach[1], spitze], pen.fill(shade(eisen, -0.3)));
    if (schnee) pen.poly([dach[3], spitze, dach[2]], pen.fill(const Color(0xCCEEF3F8)));
  }
}
