/// Teil 02: Lageplan (Blatt A und B, A4 quer), Positions-Marker, Tipp-Zettel,
/// Abwesenheitsblatt bei 6 bis 11 Personen (MECH 10.1, 10.2, 5, 7.1, 9.7;
/// WELT 2.1–2.8, 4.2, 5.4).
///
/// Seitenplan (MECH 10.1: 6 / 6 / 8 Seiten bei 6 / 12 / 20 Personen):
/// 1. Blatt A, Lageplan (A4 quer): maßstäblicher Plan links (1 m = 8,5 mm,
///    25 × 22 m), Legende rechts. Zonen mit Nummer im Kreis und Namen,
///    Teilfelder, Türen mit Zustand, jeder Gegenstand als Punkt mit Namen.
/// 2. Blatt B, Markerfelder (A4 quer): 5 × 3 Zellen zu 54 × 58 mm, Feld 1 über
///    drei Zellen; je Feld Nummer, Name und Mini-Skizze der Lage.
/// 3. Positions-Marker (A4 hoch, ein Blatt): Plättchen 26 × 18 mm, je Person
///    zwei nebeneinander (23:57 und Scheppern), Grauton-Streifen nach Zeitpunkt.
/// 4. Tipp-Zettel (A4 hoch): P − 1 Stück, vier A6 quer je Blatt (gedreht).
/// 5. Abwesenheitsblatt (A4 hoch, nur bei 6 bis 11 Personen): je fehlendem
///    Zeugen ein Streifen 100 × 95 mm, Etikett oben, Falz 30 mm unter der
///    Oberkante, Protokoll um 180° gedreht darunter.
///
/// Schrift: nirgends unter 9 pt; nur Joannas Notiz steht in 8 pt (MECH 5.2,
/// FALL-BIBEL 19.2 Nr. 4). Die Beschriftungen des Lageplans setzt eine
/// feste Suche (gleiche Eingaben ⇒ gleiche Lage): erst neben den Punkt, sonst
/// mit Führungslinie in freien Platz. Kollisionen und Überlauf sind ein
/// [KammerUeberlauf] mit Stelle, nie still.
library;

import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../satz_stil.dart';
import 'besetzung.dart';
import 'inhalt.dart';
import 'kontext.dart';
import 'platzhalter.dart';
import 'satz.dart';

const _mm = KammerSatz.mm;

/// Schriftgröße aller Texte dieses Teils außer Joannas Notiz (MECH 5.2).
const double _pt = KammerSatz.kleinsteGroesse;

/// Setzt Teil 02 (Tisch) in [doc].
void kammerTisch(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '02', (s) {
  _blattA(s, k);
  _blattB(s, k);
  _marker(s, k);
  _tippZettel(s, k);
  if (k.besetzung.abwesenheitsblatt) _abwesenheit(s, k);
});

String _u(KammerKontext k, String schluessel, [Map<String, String> werte = const {}]) => k.ui('02', schluessel, werte);

/// Überlauf mit Teil, Seite und Stelle (wie die Helfer in satz.dart).
Never _ueberlauf(KammerSeiten s, String wo, String grund) {
  final ort = '${s.k.teilTitel('02')} / $wo';
  throw KammerUeberlauf('02', s.naechste, ort, 'Überlauf in Teil 02, Seite ${s.naechste} ($ort): $grund');
}

pw.TextStyle _stil(KammerKontext k, {double g = _pt, bool fett = false, PdfColor farbe = DruckStil.tinte}) =>
    pw.TextStyle(font: fett ? k.stil.stark : k.stil.normal, fontSize: g, color: farbe);

/// Text mit Auszeichnung (`**fett**`, Zeilen, Absätze) in einfachem
/// Zeilenabstand (Legende, Streifen) oder mit [zeilenabstand] (Anteil der
/// Schriftgröße); Kursives steht grau wie in satz.dart. Umbrochen wird nur an
/// normalen Leerzeichen: Ein geschütztes Leerzeichen hält zusammen („(2 Punkte)“).
pw.Widget _text(KammerKontext k, String roh, {double g = _pt, bool fett = false, PdfColor farbe = DruckStil.tinte, double zeilenabstand = 0}) {
  pw.TextStyle stil(KammerLauf l) => _stil(k, g: g, fett: fett || l.fett, farbe: l.kursiv ? DruckStil.leise : farbe).copyWith(lineSpacing: g * zeilenabstand);
  return pw.RichText(
    // Umbruch nur an normalen Leerzeichen; ein geschütztes wird im Wort zu einem normalen.
    lineSplitter: (zeile) => [for (final w in zeile.split(' ')) w.replaceAll(_fest, ' ')],
    text: pw.TextSpan(
      children: [
        for (final (i, absatz) in k.absaetze(roh).indexed)
          for (final (j, z) in absatz.zeilen.indexed) ...[
            if (i > 0 || j > 0) pw.TextSpan(text: '\n', style: stil(const KammerLauf(''))),
            for (final l in z) pw.TextSpan(text: KammerSatz.glyphen(l.text), style: stil(l)),
          ],
      ],
    ),
  );
}

/// Geschütztes Leerzeichen: [_text] bricht dort nicht um.
const _fest = '\u00a0';

// ================================================================ Geometrie

/// Rechteck in Metern (Lageplan: x nach Osten, y nach Süden).
class _R {
  const _R(this.x0, this.y0, this.x1, this.y1);
  final double x0, y0, x1, y1;

  /// Kachelbereich: Kachel k reicht von k bis k + 1 (WELT 2.3).
  static _R aus(KammerBereich b) => _R(b.x0.toDouble(), b.y0.toDouble(), b.x1 + 1.0, b.y1 + 1.0);

  double get breite => x1 - x0;
  double get hoehe => y1 - y0;
  _R um(double d) => _R(x0 - d, y0 - d, x1 + d, y1 + d);
  bool schneidet(_R o) => x0 < o.x1 && o.x0 < x1 && y0 < o.y1 && o.y0 < y1;
  bool umfasst(_R o) => o.x0 >= x0 - 1e-9 && o.x1 <= x1 + 1e-9 && o.y0 >= y0 - 1e-9 && o.y1 <= y1 + 1e-9;
  bool hat(double x, double y) => x > x0 && x < x1 && y > y0 && y < y1;

  double abstand(double x, double y) {
    final dx = math.max(math.max(x0 - x, 0.0), x - x1);
    final dy = math.max(math.max(y0 - y, 0.0), y - y1);
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Nächster Punkt des Rechtecks zu (x, y).
  (double, double) naechster(double x, double y) => (x.clamp(x0, x1), y.clamp(y0, y1));
}

/// Ob die Strecke a–b das Rechteck [r] trifft (Liang–Barsky).
bool _streckeTrifft(double ax, double ay, double bx, double by, _R r) {
  var t0 = 0.0, t1 = 1.0;
  final dx = bx - ax, dy = by - ay;
  for (final (p, q) in [(-dx, ax - r.x0), (dx, r.x1 - ax), (-dy, ay - r.y0), (dy, r.y1 - ay)]) {
    if (p.abs() < 1e-12) {
      if (q < 0) return false;
      continue;
    }
    final t = q / p;
    if (p < 0) {
      if (t > t1) return false;
      if (t > t0) t0 = t;
    } else {
      if (t < t0) return false;
      if (t < t1) t1 = t;
    }
  }
  return t0 <= t1;
}

/// Abstand des Punkts p von der Strecke a–b.
double _abstandStrecke(double px, double py, double ax, double ay, double bx, double by) {
  final dx = bx - ax, dy = by - ay;
  final l2 = dx * dx + dy * dy;
  final t = l2 == 0 ? 0.0 : (((px - ax) * dx + (py - ay) * dy) / l2).clamp(0.0, 1.0);
  final qx = ax + t * dx - px, qy = ay + t * dy - py;
  return math.sqrt(qx * qx + qy * qy);
}

/// Ob sich die Strecken a–b und c–d schneiden (auch berührend).
bool _streckenKreuzen((double, double, double, double) s, (double, double, double, double) t) {
  double o(double ax, double ay, double bx, double by, double cx, double cy) => (bx - ax) * (cy - ay) - (by - ay) * (cx - ax);
  final (ax, ay, bx, by) = s;
  final (cx, cy, dx, dy) = t;
  final o1 = o(ax, ay, bx, by, cx, cy), o2 = o(ax, ay, bx, by, dx, dy);
  final o3 = o(cx, cy, dx, dy, ax, ay), o4 = o(cx, cy, dx, dy, bx, by);
  const e = 1e-9;
  if (o1.abs() < e && o2.abs() < e) {
    // Auf einer Geraden: nur wenn sich die Stücke überdecken.
    bool ueber(double a, double b, double c, double d) => math.max(math.min(a, b), math.min(c, d)) <= math.min(math.max(a, b), math.max(c, d)) + e;
    return ueber(ax, bx, cx, dx) && ueber(ay, by, cy, dy);
  }
  return o1 * o2 <= 0 && o3 * o4 <= 0;
}

/// Eine Tür (WELT 2.2): Lücke in einer oder zwei Wänden, bei zwei Räumen ein
/// Durchgang (die Wandkachel dazwischen).
class _Tuer {
  _Tuer(this.p, this.luecken, this.durchgang, this.waagrecht);
  final KammerPunkt p;

  /// Je Raum die Lücke in seiner Wand (Strecke in Metern).
  final List<(double, double, double, double)> luecken;

  /// Wandkachel zwischen zwei Räumen bzw. vor dem Außentor; null bei einer Tür in der Wand.
  final _R? durchgang;

  /// Ob die Wand waagrecht läuft (Tür in einer Nord- oder Südwand).
  final bool waagrecht;

  /// Die Breite der Öffnung: Lücke mit ganzer Koordinate = zwei Kacheln (Außentor).
  double get von => waagrecht ? luecken.first.$1 : luecken.first.$2;
  double get bis => waagrecht ? luecken.first.$3 : luecken.first.$4;
}

/// Lageplan in Metern, aus `tisch.json` (WELT 2.3).
class _Plan {
  _Plan(this.k) : p = k.inhalt.tisch.lageplan {
    raeume = [
      for (final r in p.raeume) (r, [for (final b in r.kacheln) _R.aus(b)]),
    ];
    felder = {
      for (final f in p.felder) f.id: [for (final b in f.kacheln) _R.aus(b)],
    };
    moebel = [
      for (final f in p.moebel) (f, [for (final b in f.kacheln) _R.aus(b)]),
    ];
    tueren = [for (final t in p.tueren) _tuer(t)];
  }

  final KammerKontext k;
  final KammerLageplan p;
  late final List<(KammerFlaeche, List<_R>)> raeume;
  late final Map<String, List<_R>> felder;
  late final List<(KammerFlaeche, List<_R>)> moebel;
  late final List<_Tuer> tueren;

  _R get rahmen => _R(p.x0.toDouble(), p.y0.toDouble(), (p.x0 + p.breite).toDouble(), (p.y0 + p.hoehe).toDouble());

  Iterable<_R> get raumKaesten => [for (final (_, rs) in raeume) ...rs];

  /// Index des Raums, in dem (x, y) liegt, sonst null.
  int? raumVon(double x, double y) {
    for (var i = 0; i < raeume.length; i++) {
      if (raeume[i].$2.any((r) => r.hat(x, y))) return i;
    }
    return null;
  }

  /// Feld, in dem (x, y) liegt, sonst null.
  String? feldVon(double x, double y) {
    for (final MapEntry(key: id, value: rs) in felder.entries) {
      if (rs.any((r) => r.hat(x, y))) return id;
    }
    return null;
  }

  _Tuer _tuer(KammerPunkt t) {
    final luecken = <(double, double, double, double)>[];
    _R? durchgang;
    var waagrecht = false;
    // Halbe Breite der Öffnung: Mitte auf einer Kachelgrenze = zwei Kacheln (Außentor).
    double halb(double v) => (v - v.floorToDouble()).abs() < 1e-9 ? 1.0 : 0.5;
    final nahe = <(_R, String)>[];
    for (final (_, rs) in raeume) {
      for (final r in rs) {
        if ((t.y - r.y0).abs() <= 0.5 + 1e-9 && t.x >= r.x0 && t.x <= r.x1) nahe.add((r, 'n'));
        if ((t.y - r.y1).abs() <= 0.5 + 1e-9 && t.x >= r.x0 && t.x <= r.x1) nahe.add((r, 's'));
        if ((t.x - r.x0).abs() <= 0.5 + 1e-9 && t.y >= r.y0 && t.y <= r.y1) nahe.add((r, 'w'));
        if ((t.x - r.x1).abs() <= 0.5 + 1e-9 && t.y >= r.y0 && t.y <= r.y1) nahe.add((r, 'o'));
      }
    }
    if (nahe.isEmpty) throw StateError('Tür ${t.id} liegt an keiner Wand');
    for (final (r, seite) in nahe) {
      switch (seite) {
        case 'n' || 's':
          waagrecht = true;
          final y = seite == 'n' ? r.y0 : r.y1;
          final h = halb(t.x);
          luecken.add((t.x - h, y, t.x + h, y));
        default:
          final x = seite == 'w' ? r.x0 : r.x1;
          final h = halb(t.y);
          luecken.add((x, t.y - h, x, t.y + h));
      }
    }
    final (ax, ay, bx, by) = luecken.first;
    if (luecken.length == 2) {
      final (cx, cy, dx, dy) = luecken.last;
      durchgang = _R(math.min(ax, cx), math.min(ay, cy), math.max(bx, dx), math.max(by, dy));
    } else if (waagrecht && (t.y - ay).abs() > 1e-9) {
      durchgang = _R(ax, math.min(ay, ay + 2 * (t.y - ay)), bx, math.max(ay, ay + 2 * (t.y - ay)));
    } else if (!waagrecht && (t.x - ax).abs() > 1e-9) {
      durchgang = _R(math.min(ax, ax + 2 * (t.x - ax)), ay, math.max(ax, ax + 2 * (t.x - ax)), by);
    }
    return _Tuer(t, luecken, durchgang, waagrecht);
  }
}

// ================================================================ Beschriftung des Lageplans

enum _Art { zone, teilfeld, moebel, gegenstand, tuer, frei }

/// Ein gesetztes Schild: Kasten in Metern (mit Polster), Zeilen, Führungslinie.
class _Schild {
  _Schild({required this.wo, required this.kasten, required this.zeilen, required this.art, this.ausrichtung = pw.TextAlign.left, this.linie, this.nr});

  final String wo;
  final _R kasten;
  final List<String> zeilen;
  final _Art art;
  final pw.TextAlign ausrichtung;
  final (double, double, double, double)? linie;

  /// Zone: Nummer im Kreis; Teilfeld: Kennung im Rahmen.
  final String? nr;
}

/// Lage eines Zonen-, Teilfeld- oder Möbelschilds (Hand gesetzt, geprüft):
/// Punkt in Metern, welcher Punkt des Kastens dort liegt, Zeilen.
class _Lage {
  const _Lage(this.x, this.y, this.anker, [this.zeilen = 1, this.zielX]);
  final double x, y;

  /// `tl`, `tr`, `bl`, `br`, `l`, `r`, `t`, `c`.
  final String anker;
  final int zeilen;

  /// Wo die Führungslinie am Kasten ankommt (x in Metern, an der Kante zum
  /// Punkt hin); sonst am nächsten Punkt des Kastens.
  final double? zielX;
}

/// Zonenschilder: Nummer im Kreis und Name (MECH 10.2). Kleine Räume tragen
/// ihr Schild gleich außen an der Wand, Zone 4 auf der Theke.
const _zonenLage = {
  '1': _Lage(20.15, 7.15, 'tl'),
  '2': _Lage(11.12, 18.9, 'bl', 2),
  '3': _Lage(15.12, 18.9, 'bl', 2),
  '4': _Lage(15.0, 9.5, 'c'),
  '5': _Lage(13.0, 1.9, 'bl'),
  '6': _Lage(7.12, 10.76, 'tl', 2),
  '7': _Lage(1.12, 8.12, 'tl'),
  '8': _Lage(4.15, 1.1, 'tl'),
  'W': _Lage(16.15, 21.0, 'l'),
};

/// Teilfelder 4a–4d, 8a, 8b: Kennung im Rahmen.
const _teilfeldLage = {
  '4a': _Lage(14.9, 10.5, 'r'),
  '4b': _Lage(15.1, 10.5, 'l'),
  '4c': _Lage(11.12, 8.9, 'bl'),
  '4d': _Lage(18.88, 8.9, 'br'),
  '8a': _Lage(1.12, 3.12, 'tl'),
  '8b': _Lage(1.12, 1.12, 'tl'),
};

/// Vorgegebene Lage der Schilder, wo es eng ist (Kennung des Gegenstands bzw.
/// der Tür). Ausgearbeitet für den Plan aus `tisch.json`, so dass sich keine
/// Führungslinien kreuzen: Turmgang und Vorratsraum links und rechts außen,
/// hinter der Theke (4c, 4d) treppenförmig nach Nordosten, der Durchgang
/// darüber und darunter, der Ost-Saal um die lange Tafel. Jede Lage wird wie
/// jede gesuchte geprüft; passt sie nicht (anderer Inhalt), sucht der Satz.
const _schildLage = {
  'wendeltreppe': _Lage(4.15, 1.82, 'tl'),
  'ruestung': _Lage(4.15, 3.47, 'tl'),
  'vitrine': _Lage(4.15, 4.22, 'tl'),
  'schluesselkasten': _Lage(4.15, 5.02, 'tl'),
  'beschlag': _Lage(4.15, 5.7, 'tl', 3),
  't8': _Lage(1.12, 5.86, 'tl'),
  't5': _Lage(3.12, 7.5, 'l'),
  'getraenkekisten': _Lage(8.65, 7.9, 'br'),
  'sicherungskasten': _Lage(10.1, 7.26, 'br'),
  't3': _Lage(10.94, 10.12, 'tr'),
  't4': _Lage(6.88, 9.86, 'r'),
  'lichtschaechte': _Lage(5.5, 8.69, 't'),
  'spuele': _Lage(11.69, 7.4, 'l'),
  'kerzenstaender': _Lage(13.92, 6.62, 'br'),
  'teekocher': _Lage(16.6, 4.8, 'l'),
  'kaffeemaschine': _Lage(16.7, 5.42, 'l'),
  'werkzeugkasten': _Lage(17.0, 6.04, 'l'),
  'anrichteOst': _Lage(17.35, 6.94, 'bl'),
  'torte': _Lage(12.94, 2.75, 'r'),
  'ersteHilfe': _Lage(16.1, 3.5, 'l'),
  'notlaterne': _Lage(12.94, 5.5, 'r'),
  'fundort': _Lage(12.94, 4.6, 'r'),
  't2': _Lage(13.12, 3.85, 'tl', 1, 15.3),
  'jackenstaender': _Lage(20.67, 8.5, 'l'),
  'wandtafel': _Lage(25.9, 7.15, 'tr', 2),
  't1': _Lage(20.12, 9.5, 'l'),
  'kopfDerTafel': _Lage(22.33, 10.44, 'r', 2),
  'handykorb': _Lage(25.9, 10.5, 'r'),
  'musikbox': _Lage(25.9, 15.3, 'br'),
  'ehrenplatz': _Lage(25.9, 17.15, 'tr'),
  'warmhaltebehaelter': _Lage(15.12, 15.12, 'tl'),
};

/// Gesetzte Beschriftung des Lageplans (hängt nur am Inhalt, nicht an der Besetzung).
class _Beschriftung {
  _Beschriftung(this.schilder, this.zeile, this.kreis);
  final List<_Schild> schilder;

  /// Zeilenhöhe in Metern.
  final double zeile;

  /// Durchmesser des Zonenkreises in Metern.
  final double kreis;
}

final _beschriftungen = Expando<Map<DruckStil, _Beschriftung>>('lageplan');

/// Polster um den Text eines Schilds (Meter).
const _polster = 0.03;

/// Abstand zwischen Schildern, zu Wänden, Punkten (Meter).
const _luft = 0.06;

/// Radius eines Gegenstandspunkts (Meter).
const _punktRadius = 0.11;

_Beschriftung _beschriften(KammerSeiten s, KammerKontext k, _Plan plan) {
  final cache = _beschriftungen[k.inhalt] ??= {};
  return cache[k.stil] ??= _Beschrifter(s, k, plan).setzen();
}

class _Beschrifter {
  _Beschrifter(this.s, this.k, this.plan) : m = plan.p.mmJeMeter * _mm;

  final KammerSeiten s;
  final KammerKontext k;
  final _Plan plan;

  /// pt je Meter.
  final double m;
  final schilder = <_Schild>[];
  final _breiten = <(String, bool), double>{};

  late final double zeile = s.satz.hoehe(pw.Text('X', style: _stil(k)), 1000) / m;
  late final double kreis = 0.5;

  /// Breite von [t] in Metern.
  double breite(String t, {bool fett = false}) => _breiten[(t, fett)] ??= () {
    final w = pw.Text(t, style: _stil(k, fett: fett));
    s.satz.hoehe(w, 100000);
    return w.box!.width / m;
  }();

  Never fehler(String wo, String grund) => _ueberlauf(s, 'lageplan / $wo', grund);

  /// [text] in [n] Zeilen, möglichst gleich lang; Umbruch nur an Leerzeichen,
  /// gern vor „(“ und nach „–“, „:“ oder „,“. Null, wenn es weniger Wörter sind.
  (List<String>, double)? umbruch(String text, int n, {bool fett = false}) {
    final w = text.split(' ');
    if (w.length < n) return null;
    if (n == 1) return ([text], breite(text, fett: fett));
    (List<String>, double)? beste;
    (List<String>, double)? schoen;
    void probiere(List<int> schnitte) {
      final zeilen = <String>[];
      var a = 0;
      for (final b in [...schnitte, w.length]) {
        zeilen.add(w.sublist(a, b).join(' '));
        a = b;
      }
      final br = zeilen.map((z) => breite(z, fett: fett)).reduce(math.max);
      final gut = schnitte.every((i) => w[i].startsWith('(') || RegExp(r'[–:,]$').hasMatch(w[i - 1]));
      if (beste == null || br < beste!.$2 - 1e-9) beste = (zeilen, br);
      if (gut && (schoen == null || br < schoen!.$2 - 1e-9)) schoen = (zeilen, br);
    }

    if (n == 2) {
      for (var i = 1; i < w.length; i++) {
        probiere([i]);
      }
    } else {
      for (var i = 1; i < w.length; i++) {
        for (var j = i + 1; j < w.length; j++) {
          probiere([i, j]);
        }
      }
    }
    if (schoen != null && schoen!.$2 <= beste!.$2 + 0.8) return schoen;
    return beste;
  }

  /// Kasten an [x], [y] mit Anker.
  static _R kastenAn(double x, double y, String anker, double b, double h) => switch (anker) {
    'tl' => _R(x, y, x + b, y + h),
    'tr' => _R(x - b, y, x, y + h),
    'bl' => _R(x, y - h, x + b, y),
    'br' => _R(x - b, y - h, x, y),
    'l' => _R(x, y - h / 2, x + b, y + h / 2),
    'r' => _R(x - b, y - h / 2, x, y + h / 2),
    't' => _R(x - b / 2, y, x + b / 2, y + h),
    _ => _R(x - b / 2, y - h / 2, x + b / 2, y + h / 2),
  };

  // ---------------------------------------------------------------- Prüfen

  /// Grund, warum [kasten] nicht geht, sonst null. [raeumeErlaubt]: Räume, in
  /// denen das Schild stehen darf (außerhalb aller Räume geht immer).
  String? kastenFrei(_R kasten, {Set<int> raeumeErlaubt = const {}, bool aufMoebel = false, Object? selbst}) {
    if (!plan.rahmen.um(-_luft).umfasst(kasten)) return 'ragt aus dem Plan';
    int? raum;
    for (var i = 0; i < plan.raeume.length; i++) {
      final rs = plan.raeume[i].$2;
      if (rs.any((r) => r.um(-_luft - 0.02).umfasst(kasten))) {
        raum = i;
      } else if (rs.any((r) => r.um(_luft).schneidet(kasten))) {
        return 'schneidet die Wand von ${plan.raeume[i].$1.name}';
      }
    }
    if (raum != null && !raeumeErlaubt.contains(raum)) return 'steht im falschen Raum (${plan.raeume[raum].$1.name})';
    if (raum != null && !aufMoebel) {
      // Ein Schild steht ganz in einem Feld (oder in keinem) und kreuzt keine Feldgrenze.
      final getroffen = [
        for (final MapEntry(key: id, value: rs) in plan.felder.entries)
          if (rs.any((r) => r.schneidet(kasten))) id,
      ];
      if (getroffen.length > 1) return 'kreuzt eine Feldgrenze (${getroffen.join(', ')})';
      if (getroffen.length == 1) {
        final rs = plan.felder[getroffen.single]!;
        if (!rs.any((r) => r.umfasst(kasten))) {
          for (var x = kasten.x0; x <= kasten.x1 + 1e-9; x += 0.1) {
            for (var y = kasten.y0; y <= kasten.y1 + 1e-9; y += 0.1) {
              final px = math.min(x, kasten.x1 - 1e-6), py = math.min(y, kasten.y1 - 1e-6);
              if (!rs.any((r) => px >= r.x0 && px < r.x1 && py >= r.y0 && py < r.y1)) return 'kreuzt die Grenze von Feld ${getroffen.single}';
            }
          }
        }
      }
    }
    if (raum == null) {
      for (final t in plan.tueren) {
        if (t.durchgang case final d? when d.um(_luft).schneidet(kasten)) return 'liegt auf der Tür ${t.p.name}';
      }
    }
    if (!aufMoebel) {
      for (final (f, rs) in plan.moebel) {
        if (rs.any((r) => r.um(0.03).schneidet(kasten))) return 'liegt auf ${f.name}';
      }
    }
    for (final o in plan.p.gegenstaende) {
      if (kasten.abstand(o.x, o.y) < _punktRadius + _luft) return 'deckt den Punkt ${o.name}';
    }
    for (final a in schilder) {
      if (identical(a, selbst)) continue;
      if (a.kasten.um(_luft).schneidet(kasten)) return 'stößt an ${a.wo}';
      if (a.linie case (final ax, final ay, final bx, final by)? when _streckeTrifft(ax, ay, bx, by, kasten.um(0.03))) {
        return 'liegt auf der Führungslinie von ${a.wo}';
      }
    }
    return null;
  }

  /// Grund, warum die Führungslinie a–b nicht geht, sonst null.
  String? linieFrei((double, double, double, double) l, {required Set<int> raeumeErlaubt, required double vonX, required double vonY}) {
    final (ax, ay, bx, by) = l;
    for (final a in schilder) {
      if (_streckeTrifft(ax, ay, bx, by, a.kasten.um(0.03))) return 'Linie kreuzt ${a.wo}';
      if (a.linie case final b? when _streckenKreuzen(l, b)) return 'Linie kreuzt die Linie von ${a.wo}';
    }
    for (final o in plan.p.gegenstaende) {
      if ((o.x - vonX).abs() < 1e-9 && (o.y - vonY).abs() < 1e-9) continue;
      if (_abstandStrecke(o.x, o.y, ax, ay, bx, by) < 0.2) return 'Linie streift den Punkt ${o.name}';
    }
    for (final t in plan.tueren) {
      if ((t.p.x - vonX).abs() < 1e-9 && (t.p.y - vonY).abs() < 1e-9) continue;
      if (t.durchgang case final d? when _streckeTrifft(ax, ay, bx, by, d)) return 'Linie läuft durch die Tür ${t.p.name}';
    }
    final laenge = math.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay));
    final schritte = math.max(1, (laenge / 0.05).ceil());
    for (var i = 0; i <= schritte; i++) {
      final x = ax + (bx - ax) * i / schritte, y = ay + (by - ay) * i / schritte;
      final r = plan.raumVon(x, y);
      if (r != null && !raeumeErlaubt.contains(r)) return 'Linie läuft durch ${plan.raeume[r].$1.name}';
    }
    return null;
  }

  // ---------------------------------------------------------------- Setzen

  _Beschriftung setzen() {
    final p = plan.p;
    // 1. Hand gesetzt: Zonen, Teilfelder, Möbel (lange Tafeln), Nordpfeil und Maßstab.
    for (final z in k.fall.zonen) {
      final lage = _zonenLage[z.nr] ?? fehler('Zone ${z.nr}', 'keine Lage für das Zonenschild');
      final (zeilen, b) = umbruch(k.klartext(z.name), lage.zeilen, fett: true) ?? fehler('Zone ${z.nr}', 'Name passt nicht in ${lage.zeilen} Zeilen');
      final h = math.max(kreis, zeilen.length * zeile) + 2 * _polster;
      final kasten = kastenAn(lage.x, lage.y, lage.anker, kreis + 0.12 + b + 2 * _polster, h);
      final felder = z.felder.toSet();
      final raeume = {
        for (var i = 0; i < plan.raeume.length; i++)
          if (felder.any((f) => plan.felder[f]!.any((fr) => plan.raeume[i].$2.any((r) => r.schneidet(fr))))) i,
      };
      final aufMoebel = plan.moebel.any((m) => m.$2.any((r) => r.umfasst(kasten)));
      final grund = kastenFrei(kasten, raeumeErlaubt: raeume, aufMoebel: aufMoebel);
      if (grund != null) fehler('Zone ${z.nr}', grund);
      schilder.add(_Schild(wo: 'Zone ${z.nr}', kasten: kasten, zeilen: zeilen, art: _Art.zone, nr: z.nr));
    }
    for (final f in k.fall.felder) {
      final zone = k.fall.zonen.firstWhere((z) => z.felder.contains(f.id));
      if (zone.felder.length < 2) continue;
      final lage = _teilfeldLage[f.id] ?? fehler('Feld ${f.id}', 'keine Lage für das Feldschild');
      final kasten = kastenAn(lage.x, lage.y, lage.anker, breite(f.id, fett: true) + 0.3, kreis + 2 * _polster - 0.04);
      final raum = plan.raumVon((kasten.x0 + kasten.x1) / 2, (kasten.y0 + kasten.y1) / 2);
      final grund = kastenFrei(kasten, raeumeErlaubt: {?raum});
      if (grund != null) fehler('Feld ${f.id}', grund);
      if (plan.feldVon((kasten.x0 + kasten.x1) / 2, (kasten.y0 + kasten.y1) / 2) != f.id) fehler('Feld ${f.id}', 'Schild liegt nicht im Feld');
      schilder.add(_Schild(wo: 'Feld ${f.id}', kasten: kasten, zeilen: [f.id], art: _Art.teilfeld, nr: f.id));
    }
    for (final (f, rs) in plan.moebel) {
      // Die Theke trägt das Schild der Zone 4; die Buffettische tragen die Zonen 2 und 3 im Namen.
      if (schilder.any((a) => a.art == _Art.zone && rs.any((r) => r.umfasst(a.kasten)))) continue;
      final r = rs.first;
      for (final n in [1, 2]) {
        final u = umbruch(k.klartext(f.name!), n);
        if (u == null) continue;
        final (zeilen, b) = u;
        final kasten = kastenAn((r.x0 + r.x1) / 2, (r.y0 + r.y1) / 2, 'c', b + 2 * _polster, zeilen.length * zeile + 2 * _polster);
        if (!r.um(-0.05).umfasst(kasten)) continue;
        if (kastenFrei(kasten, raeumeErlaubt: {?plan.raumVon(r.x0 + 0.5, r.y0 + 0.5)}, aufMoebel: true) != null) continue;
        schilder.add(_Schild(wo: f.name!, kasten: kasten, zeilen: zeilen, art: _Art.moebel, ausrichtung: pw.TextAlign.center));
        break;
      }
    }
    // Nordpfeil und Maßstab unten links im freien Platz.
    final nord = k.klartext(_u(k, 'lageplan.norden'));
    final massstab = k.klartext(_u(k, 'lageplan.massstab'));
    final unten = p.y0 + p.hoehe - 0.15;
    final nordKasten = _R(p.x0 + 0.2, unten - 2.0, p.x0 + 0.2 + math.max(0.8, breite(nord, fett: true) + 0.1), unten);
    final massKasten = _R(nordKasten.x1 + 0.4, unten - 1.0, nordKasten.x1 + 0.4 + 1.3 + breite(massstab) + 2 * _polster, unten);
    for (final (wo, kasten) in [('norden', nordKasten), ('massstab', massKasten)]) {
      final grund = kastenFrei(kasten);
      if (grund != null) fehler(wo, grund);
    }
    schilder
      ..add(_Schild(wo: 'norden', kasten: nordKasten, zeilen: [nord], art: _Art.frei, ausrichtung: pw.TextAlign.center))
      ..add(_Schild(wo: 'massstab', kasten: massKasten, zeilen: [massstab], art: _Art.frei, ausrichtung: pw.TextAlign.right));

    // 2. Gesucht: Gegenstände und Türen, enge Felder zuerst.
    final auftraege = <(String, String, double, double, Set<int>, double, String)>[];
    double flaeche(String? feld) => feld == null ? 0 : plan.felder[feld]!.fold(0.0, (a, r) => a + r.breite * r.hoehe);
    for (final t in plan.tueren) {
      final raeume = {
        for (var i = 0; i < plan.raeume.length; i++)
          if (plan.raeume[i].$2.any(
            (r) => t.luecken.any((l) => r.um(1e-6).hat(l.$1 + 1e-7, l.$2 + 1e-7) || _streckeTrifft(l.$1, l.$2, l.$3, l.$4, r.um(1e-6))),
          ))
            i,
      };
      final groesse = [for (final i in raeume) plan.raeume[i].$2.fold(0.0, (a, r) => a + r.breite * r.hoehe)].fold(1e9, math.min);
      auftraege.add(('Tür ${t.p.name}', _tuerText(t), t.p.x, t.p.y, raeume, groesse, t.p.id));
    }
    for (final o in p.gegenstaende) {
      final raum = plan.raumVon(o.x, o.y);
      auftraege.add((o.name, k.klartext(o.name), o.x, o.y, {?raum}, flaeche(o.zusatz), o.id));
    }
    // Erst die vorgegebenen Lagen (in der Reihenfolge der Tabelle), dann die
    // übrigen, enge Felder zuerst.
    final vorgabe = _schildLage.keys.toList();
    int rang(int i) => vorgabe.contains(auftraege[i].$7) ? vorgabe.indexOf(auftraege[i].$7) : vorgabe.length;
    final reihenfolge = [for (var i = 0; i < auftraege.length; i++) i]
      ..sort((a, b) {
        var c = rang(a).compareTo(rang(b));
        if (c == 0) c = auftraege[a].$6.compareTo(auftraege[b].$6);
        return c != 0 ? c : a.compareTo(b);
      });
    for (final i in reihenfolge) {
      final (wo, text, x, y, raeume, _, id) = auftraege[i];
      schilder.add(suche(wo, text, x, y, raeume, tuer: auftraege[i].$1.startsWith('Tür '), lage: _schildLage[id]));
    }
    return _Beschriftung(schilder, zeile, kreis);
  }

  String _tuerText(_Tuer t) {
    final name = k.klartext(t.p.name);
    final zustand = t.p.zusatz;
    return k.hatUi('02', 'tuer.$zustand') ? k.klartext(_u(k, 'tuer.$zustand', {'name': name})) : name;
  }

  /// Sucht die Lage für ein Schild zum Punkt (x, y): erst daneben, dann mit
  /// Führungslinie, immer der billigste freie Platz (fest, ohne Zufall).
  _Schild suche(String wo, String text, double x, double y, Set<int> raeume, {bool tuer = false, _Lage? lage}) {
    // Abstand, ab dem eine Führungslinie gezogen wird (Türen: neben der Öffnung).
    final linieAb = tuer ? 0.7 : 0.3;
    // Bei einer Tür beginnt die Linie an der Kante der Öffnung, nicht auf dem Türblatt.
    final durchgang = tuer ? plan.tueren.firstWhere((t) => t.p.x == x && t.p.y == y).durchgang : null;
    (double, double, double, double) linieZu(_R kasten, {double? zielX}) {
      var (bx, by) = kasten.naechster(x, y);
      if (zielX != null) (bx, by) = (zielX, y > kasten.y1 ? kasten.y1 : kasten.y0);
      final dx = bx - x, dy = by - y;
      final d = math.sqrt(dx * dx + dy * dy);
      var t = tuer ? 0.0 : (_punktRadius + 0.03) / d;
      if (durchgang case final g?) {
        final tx = dx.abs() < 1e-9 ? 1.0 : (dx > 0 ? g.x1 - x : g.x0 - x) / dx;
        final ty = dy.abs() < 1e-9 ? 1.0 : (dy > 0 ? g.y1 - y : g.y0 - y) / dy;
        t = math.min(tx, ty).clamp(0.0, 1.0);
      }
      return (x + dx * t, y + dy * t, bx, by);
    }

    if (lage != null) {
      if (umbruch(text, lage.zeilen) case (final zeilen, final b)?) {
        final kasten = kastenAn(lage.x, lage.y, lage.anker, b + 2 * _polster, zeilen.length * zeile + 2 * _polster);
        final ausrichtung = switch (lage.anker) {
          'tr' || 'br' || 'r' => pw.TextAlign.right,
          't' || 'c' => pw.TextAlign.center,
          _ => pw.TextAlign.left,
        };
        if (kastenFrei(kasten, raeumeErlaubt: raeume) == null) {
          final linie = kasten.abstand(x, y) > linieAb ? linieZu(kasten, zielX: lage.zielX) : null;
          if (linie == null || linieFrei(linie, raeumeErlaubt: raeume, vonX: x, vonY: y) == null) {
            return _Schild(wo: wo, kasten: kasten, zeilen: zeilen, art: tuer ? _Art.tuer : _Art.gegenstand, ausrichtung: ausrichtung, linie: linie);
          }
        }
      }
    }
    final kandidaten = <(double, _R, List<String>, pw.TextAlign, bool)>[];
    final feld = plan.feldVon(x, y);
    double lagekosten(_R kasten) {
      final mx = (kasten.x0 + kasten.x1) / 2, my = (kasten.y0 + kasten.y1) / 2;
      final r = plan.raumVon(mx, my);
      if (r == null) return 0.3;
      final f = plan.feldVon(mx, my);
      return f == feld ? 0 : 0.8;
    }

    for (var n = 1; n <= 3; n++) {
      final u = umbruch(text, n);
      if (u == null) continue;
      final (zeilen, b) = u;
      final w = b + 2 * _polster, h = zeilen.length * zeile + 2 * _polster;
      final zusatz = 0.35 * (n - 1);
      // Gleich neben dem Punkt (Türen: neben der Öffnung).
      final g = tuer ? 0.62 : 0.17;
      final neben = [
        (_R(x + g, y - h / 2, x + g + w, y + h / 2), pw.TextAlign.left),
        (_R(x - g - w, y - h / 2, x - g, y + h / 2), pw.TextAlign.right),
        (_R(x - w / 2, y + g, x + w / 2, y + g + h), pw.TextAlign.center),
        (_R(x - w / 2, y - g - h, x + w / 2, y - g), pw.TextAlign.center),
        (_R(x + g * 0.6, y + g * 0.6, x + g * 0.6 + w, y + g * 0.6 + h), pw.TextAlign.left),
        (_R(x + g * 0.6, y - g * 0.6 - h, x + g * 0.6 + w, y - g * 0.6), pw.TextAlign.left),
        (_R(x - g * 0.6 - w, y + g * 0.6, x - g * 0.6, y + g * 0.6 + h), pw.TextAlign.right),
        (_R(x - g * 0.6 - w, y - g * 0.6 - h, x - g * 0.6, y - g * 0.6), pw.TextAlign.right),
      ];
      for (var i = 0; i < neben.length; i++) {
        final (kasten, a) = neben[i];
        kandidaten.add((0.04 * i + zusatz + lagekosten(kasten), kasten, zeilen, a, false));
      }
      // Mit Führungslinie: Raster in 0,25 m, höchstens 6 m vom Punkt.
      final r = plan.rahmen;
      for (var x0 = r.x0 + 0.1; x0 + w <= r.x1 - 0.05; x0 += 0.25) {
        for (var y0 = r.y0 + 0.1; y0 + h <= r.y1 - 0.05; y0 += 0.25) {
          final kasten = _R(x0, y0, x0 + w, y0 + h);
          final d = kasten.abstand(x, y);
          if (d < 0.3 || d > 6) continue;
          final a = (x0 + w / 2) < x ? pw.TextAlign.right : pw.TextAlign.left;
          kandidaten.add((1.0 + d + zusatz + lagekosten(kasten), kasten, zeilen, a, true));
        }
      }
    }
    // Fest sortiert: Kosten, dann Reihenfolge der Erzeugung.
    final idx = [for (var i = 0; i < kandidaten.length; i++) i]
      ..sort((a, b) {
        final c = kandidaten[a].$1.compareTo(kandidaten[b].$1);
        return c != 0 ? c : a.compareTo(b);
      });
    String? letzterGrund;
    for (final i in idx) {
      final (_, kasten, zeilen, ausrichtung, mitLinie) = kandidaten[i];
      final grund = kastenFrei(kasten, raeumeErlaubt: raeume);
      if (grund != null) {
        letzterGrund ??= grund;
        continue;
      }
      (double, double, double, double)? linie;
      if (mitLinie) {
        linie = linieZu(kasten);
        if (linieFrei(linie, raeumeErlaubt: raeume, vonX: x, vonY: y) != null) continue;
      }
      return _Schild(wo: wo, kasten: kasten, zeilen: zeilen, art: tuer ? _Art.tuer : _Art.gegenstand, ausrichtung: ausrichtung, linie: linie);
    }
    fehler(wo, 'kein freier Platz für die Beschriftung (${letzterGrund ?? 'keine Lage'})');
  }
}

// ================================================================ Blatt A: Lageplan

/// Seitenrand der Lageplan-Blätter (Text hält 5 mm Druckrand).
const _randQuer = pw.EdgeInsets.fromLTRB(5.5 * _mm, 6 * _mm, 5.5 * _mm, 6 * _mm);

/// Blatt A: maßstäblicher Plan links (1 m = 8,5 mm), Legende rechts (MECH 10.2).
void _blattA(KammerSeiten s, KammerKontext k) {
  final plan = _Plan(k);
  final p = plan.p;
  final m = p.mmJeMeter * _mm;
  final w = p.breite * m;
  final h = p.hoehe * m;
  final format = KammerSatz.a4Quer;
  // Kopf über dem Plan: Titel wörtlich links (MECH 10.2), rechts Blatt und Anschluss an Blatt B.
  final titel = pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Expanded(child: pw.Text(KammerSatz.glyphen(k.klartext(_u(k, 'lageplan.titel'))), style: k.stil.titel(15))),
      pw.SizedBox(width: 4 * _mm),
      _text(k, '**${k.klartext(_u(k, 'lageplan.blattA'))}** · ${k.klartext(_u(k, 'lageplan.blattA.anschluss'))}'),
    ],
  );
  final kopfHoehe = s.satz.hoehe(titel, w) + 2 * _mm;
  s.pruefeHoehe(kopfHoehe + h, format.height - _randQuer.vertical, wo: 'lageplan');
  const luecke = 3 * _mm;
  final legendeBreite = format.width - _randQuer.horizontal - w - luecke;
  if (legendeBreite < 60 * _mm) _ueberlauf(s, 'legende', 'nur ${(legendeBreite / _mm).toStringAsFixed(0)} mm breit');
  final legende = _legende(k, plan, legendeBreite);
  s.pruefe(legende, breite: legendeBreite, platz: format.height - _randQuer.vertical, wo: 'legende');
  final beschriftung = _beschriften(s, k, plan);
  s.vollSeite(
    quer: true,
    rand: _randQuer,
    (c) => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(width: w, child: titel),
            pw.SizedBox(height: kopfHoehe - s.satz.hoehe(titel, w)),
            _planBild(k, plan, beschriftung),
          ],
        ),
        pw.SizedBox(width: luecke),
        pw.SizedBox(width: legendeBreite, child: legende),
      ],
    ),
  );
}

/// Der Plan: Räume mit Gitter, Möbel, Felder, Wände, Türen, Punkte, Schilder.
pw.Widget _planBild(KammerKontext k, _Plan plan, _Beschriftung b) {
  final p = plan.p;
  final m = p.mmJeMeter * _mm;
  final w = p.breite * m;
  final h = p.hoehe * m;
  double px(double x) => (x - p.x0) * m;
  double py(double y) => (y - p.y0) * m;
  return pw.SizedBox(
    width: w,
    height: h,
    child: pw.Stack(
      children: [
        pw.CustomPaint(size: PdfPoint(w, h), painter: (g, groesse) => _planMalen(g, plan, b, m, h)),
        for (final a in b.schilder) _schildBild(k, a, b, m, px(a.kasten.x0), py(a.kasten.y0)),
      ],
    ),
  );
}

void _planMalen(PdfGraphics g, _Plan plan, _Beschriftung b, double m, double h) {
  final p = plan.p;
  double gx(double x) => (x - p.x0) * m;
  double gy(double y) => h - (y - p.y0) * m;
  void rechteck(_R r) => g.drawRect(gx(r.x0), gy(r.y1), r.breite * m, r.hoehe * m);
  void linie(double ax, double ay, double bx, double by) => g
    ..moveTo(gx(ax), gy(ay))
    ..lineTo(gx(bx), gy(by));

  // Hellgraues 1-m-Gitter in den Räumen.
  g
    ..setStrokeColor(PdfColors.grey300)
    ..setLineWidth(0.35);
  for (final r in plan.raumKaesten) {
    for (var x = r.x0 + 1; x < r.x1 - 1e-9; x++) {
      linie(x, r.y0, x, r.y1);
    }
    for (var y = r.y0 + 1; y < r.y1 - 1e-9; y++) {
      linie(r.x0, y, r.x1, y);
    }
  }
  g.strokePath();
  // Möbel grau mit dünnem Rand.
  g.setFillColor(PdfColors.grey200);
  for (final (_, rs) in plan.moebel) {
    rs.forEach(rechteck);
  }
  g.fillPath();
  g
    ..setStrokeColor(PdfColors.grey600)
    ..setLineWidth(0.5);
  for (final (_, rs) in plan.moebel) {
    rs.forEach(rechteck);
  }
  g.strokePath();
  // Feldgrenzen gestrichelt: Außenkanten der Kacheln jedes Felds.
  g
    ..setStrokeColor(PdfColors.grey700)
    ..setLineWidth(0.8)
    ..setLineDashPattern([3, 2]);
  for (final rs in plan.felder.values) {
    for (final (ax, ay, bx, by) in _feldKanten(rs)) {
      linie(ax, ay, bx, by);
    }
  }
  g
    ..strokePath()
    ..setLineDashPattern();
  // Wände: Raumränder mit Lücken an den Türen, Durchgänge mit Laibung.
  const wand = 1.7;
  final halb = wand / 2 / m;
  g
    ..setStrokeColor(DruckStil.tinte)
    ..setLineWidth(wand);
  for (final r in plan.raumKaesten) {
    for (final (ax, ay, bx, by) in [(r.x0, r.y0, r.x1, r.y0), (r.x0, r.y1, r.x1, r.y1), (r.x0, r.y0, r.x0, r.y1), (r.x1, r.y0, r.x1, r.y1)]) {
      final waagrecht = ay == by;
      final luecken = [
        for (final t in plan.tueren)
          for (final (lx, ly, mx, my) in t.luecken)
            if (waagrecht && (ly - ay).abs() < 1e-9 && ly == my && lx < bx && mx > ax)
              (lx, mx)
            else if (!waagrecht && (lx - ax).abs() < 1e-9 && lx == mx && ly < by && my > ay)
              (ly, my),
      ]..sort((a, b) => a.$1.compareTo(b.$1));
      var von = waagrecht ? ax : ay;
      final ende = waagrecht ? bx : by;
      for (final (l0, l1) in [...luecken, (ende, ende)]) {
        if (l0 > von + 1e-9) {
          // An den Ecken um eine halbe Wandstärke verlängern, damit die Ecken voll sind.
          final a0 = (von - (waagrecht ? ax : ay)).abs() < 1e-9 ? von - halb : von;
          final a1 = (l0 - ende).abs() < 1e-9 ? l0 + halb : l0;
          if (waagrecht) {
            linie(a0, ay, a1, ay);
          } else {
            linie(ax, a0, ax, a1);
          }
        }
        von = math.max(von, l1);
      }
    }
  }
  for (final t in plan.tueren) {
    if (t.durchgang case final d?) {
      if (t.waagrecht) {
        linie(d.x0, d.y0 - halb, d.x0, d.y1 + halb);
        linie(d.x1, d.y0 - halb, d.x1, d.y1 + halb);
      } else {
        linie(d.x0 - halb, d.y0, d.x1 + halb, d.y0);
        linie(d.x0 - halb, d.y1, d.x1 + halb, d.y1);
      }
    }
  }
  g.strokePath();
  // Türblätter nach Zustand (Legende): offen ohne Blatt, angelehnt schräg, zu quer, verschlossen quer mit Schloss.
  for (final t in plan.tueren) {
    _tuerMalen(g, t, gx, gy, m);
  }
  // Führungslinien, dann die Punkte.
  g
    ..setStrokeColor(DruckStil.leise)
    ..setLineWidth(0.5);
  for (final a in b.schilder) {
    if (a.linie case (final ax, final ay, final bx, final by)?) linie(ax, ay, bx, by);
  }
  g.strokePath();
  g.setFillColor(DruckStil.tinte);
  for (final o in p.gegenstaende) {
    g.drawEllipse(gx(o.x), gy(o.y), _punktRadius * m, _punktRadius * m);
  }
  g.fillPath();
  // Nordpfeil.
  if (b.schilder.where((a) => a.wo == 'norden').firstOrNull case final n?) {
    final x = (n.kasten.x0 + n.kasten.x1) / 2;
    final oben = n.kasten.y0 + b.zeile + 2 * _polster;
    g
      ..setFillColor(DruckStil.tinte)
      ..moveTo(gx(x), gy(oben))
      ..lineTo(gx(x - 0.25), gy(n.kasten.y1 - 0.1))
      ..lineTo(gx(x), gy(n.kasten.y1 - 0.35))
      ..lineTo(gx(x + 0.25), gy(n.kasten.y1 - 0.1))
      ..closePath()
      ..fillPath();
  }
  // Maßstab: ein Kästchen mit Gitterrand.
  if (b.schilder.where((a) => a.wo == 'massstab').firstOrNull case final ms?) {
    final y0 = (ms.kasten.y0 + ms.kasten.y1) / 2 - 0.5;
    g
      ..setStrokeColor(DruckStil.tinte)
      ..setLineWidth(0.7)
      ..drawRect(gx(ms.kasten.x0), gy(y0 + 1), m, m)
      ..strokePath();
  }
}

/// Außenkanten der Kacheln eines Felds, zu Strecken zusammengefasst.
List<(double, double, double, double)> _feldKanten(List<_R> rs) {
  final kacheln = <(int, int)>{
    for (final r in rs)
      for (var x = r.x0.round(); x < r.x1.round(); x++)
        for (var y = r.y0.round(); y < r.y1.round(); y++) (x, y),
  };
  final kanten = <(double, double, double, double)>[];
  // Waagrechte Kanten je Zeile, senkrechte je Spalte, zusammenhängend.
  final xs = [for (final (x, _) in kacheln) x], ys = [for (final (_, y) in kacheln) y];
  final x0 = xs.reduce(math.min), x1 = xs.reduce(math.max), y0 = ys.reduce(math.min), y1 = ys.reduce(math.max);
  for (var y = y0; y <= y1 + 1; y++) {
    int? start;
    for (var x = x0; x <= x1 + 1; x++) {
      final kante = kacheln.contains((x, y)) != kacheln.contains((x, y - 1));
      if (kante && start == null) start = x;
      if (!kante && start != null) {
        kanten.add((start.toDouble(), y.toDouble(), x.toDouble(), y.toDouble()));
        start = null;
      }
    }
  }
  for (var x = x0; x <= x1 + 1; x++) {
    int? start;
    for (var y = y0; y <= y1 + 1; y++) {
      final kante = kacheln.contains((x, y)) != kacheln.contains((x - 1, y));
      if (kante && start == null) start = y;
      if (!kante && start != null) {
        kanten.add((x.toDouble(), start.toDouble(), x.toDouble(), y.toDouble()));
        start = null;
      }
    }
  }
  return kanten;
}

/// Türblatt nach Zustand in der Mitte der Öffnung.
void _tuerMalen(PdfGraphics g, _Tuer t, double Function(double) gx, double Function(double) gy, double m) {
  final mitte = t.waagrecht ? t.p.y : t.p.x;
  // Lage der Türblatt-Linie: in der Mitte des Durchgangs oder auf der Wand.
  final (a, b) = (t.von, t.bis);
  _tuerSymbol(g, t.p.zusatz, t.waagrecht, a, b, mitte, gx, gy, m);
}

/// Zeichnet das Symbol eines Türzustands über die Öffnung a..b auf der Linie
/// [mitte] (waagrecht: y = mitte, x von a bis b; sonst x = mitte, y von a bis b).
void _tuerSymbol(
  PdfGraphics g,
  String zustand,
  bool waagrecht,
  double a,
  double b,
  double mitte,
  double Function(double) gx,
  double Function(double) gy,
  double m,
) {
  (double, double) pt(double laengs, double quer) => waagrecht ? (gx(laengs), gy(quer)) : (gx(quer), gy(laengs));
  g
    ..setStrokeColor(DruckStil.tinte)
    ..setLineWidth(1.1);
  switch (zustand) {
    case 'angelehnt':
      // Blatt um 30° aufgeschwenkt, Angel am Anfang der Öffnung.
      final l = b - a;
      final (x0, y0) = pt(a, mitte);
      final (x1, y1) = pt(a + l * math.cos(math.pi / 6), mitte - l * math.sin(math.pi / 6));
      g
        ..moveTo(x0, y0)
        ..lineTo(x1, y1)
        ..strokePath();
    case 'zu' || 'verschlossen':
      final (x0, y0) = pt(a, mitte);
      final (x1, y1) = pt(b, mitte);
      g
        ..moveTo(x0, y0)
        ..lineTo(x1, y1)
        ..strokePath();
      if (zustand == 'verschlossen') {
        final (cx, cy) = pt((a + b) / 2, mitte);
        const s = 0.32;
        g
          ..setFillColor(DruckStil.tinte)
          ..drawRect(cx - s * m / 2, cy - s * m / 2, s * m, s * m)
          ..fillPath();
      }
    default:
      break;
  }
}

pw.Widget _schildBild(KammerKontext k, _Schild a, _Beschriftung b, double m, double left, double top) {
  final kasten = a.kasten;
  final textStil = _stil(k, fett: a.art == _Art.zone || a.art == _Art.teilfeld);
  // Alle Zeilen in einem Text: Eine Spalte fester Höhe ließe eine Zeile still weg.
  pw.Widget zeilen(pw.TextAlign ausrichtung) => pw.Text(KammerSatz.glyphen(a.zeilen.join('\n')), style: textStil, textAlign: ausrichtung);
  final inhalt = switch (a.art) {
    _Art.zone => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _zonenKreis(k, a.nr!, b.kreis * m),
        pw.SizedBox(width: 0.12 * m),
        zeilen(pw.TextAlign.left),
      ],
    ),
    _Art.teilfeld => pw.Container(
      width: kasten.breite * m,
      height: kasten.hoehe * m,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: DruckStil.tinte, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(a.nr!, style: textStil),
    ),
    _ => pw.SizedBox(width: (kasten.breite - 2 * _polster) * m, child: zeilen(a.ausrichtung)),
  };
  return pw.Positioned(
    left: left,
    top: top,
    child: a.art == _Art.teilfeld
        ? inhalt
        : a.art == _Art.frei
        // Nordpfeil (Buchstabe oben, Pfeil darunter) und Maßstab (Kästchen links, Text rechts daneben).
        ? pw.Container(
            width: kasten.breite * m,
            height: kasten.hoehe * m,
            alignment: a.ausrichtung == pw.TextAlign.right ? pw.Alignment.centerRight : pw.Alignment.topCenter,
            child: pw.Text(KammerSatz.glyphen(a.zeilen.join('\n')), style: textStil),
          )
        : pw.Container(padding: pw.EdgeInsets.all(_polster * m), color: a.art == _Art.moebel || a.art == _Art.frei ? null : PdfColors.white, child: inhalt),
  );
}

pw.Widget _zonenKreis(KammerKontext k, String nr, double d) => pw.Container(
  width: d,
  height: d,
  alignment: pw.Alignment.center,
  decoration: pw.BoxDecoration(
    shape: pw.BoxShape.circle,
    color: PdfColors.white,
    border: pw.Border.all(color: DruckStil.tinte, width: 0.9),
  ),
  child: pw.Text(nr, style: _stil(k, fett: true)),
);

/// Legende (rechts, etwa 70 mm, MECH 10.2): je Zone Kreis, Name und Text aus
/// `tisch.json`, bei Zone 4 und 8 die Teilfelder mit Feldname (WELT 2.1) und
/// Text; darunter die Zeichen (zweispaltig) und die Hinweise.
pw.Widget _legende(KammerKontext k, _Plan plan, double breite) {
  final texte = {for (final l in plan.p.legende) l.schluessel: l.text};
  const einzug = 7.5 * _mm;
  final m = plan.p.mmJeMeter * _mm;
  final kreis = 0.5 * m;
  pw.Widget zeile(pw.Widget zeichen, pw.Widget text, {double oben = 1.8, double einzugZeichen = einzug}) => pw.Padding(
    padding: pw.EdgeInsets.only(top: oben),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: einzugZeichen,
          child: pw.Align(alignment: pw.Alignment.topLeft, child: zeichen),
        ),
        pw.Expanded(child: text),
      ],
    ),
  );
  pw.Widget zeichen(void Function(PdfGraphics g, PdfPoint s) malen) => pw.SizedBox(
    width: 6 * _mm,
    height: 3.4 * _mm,
    child: pw.CustomPaint(size: const PdfPoint(6 * _mm, 3.4 * _mm), painter: malen),
  );
  pw.Widget tuer(String zustand) => zeichen((g, s) {
    g
      ..setStrokeColor(DruckStil.tinte)
      ..setLineWidth(1.7)
      ..moveTo(0, s.y / 2)
      ..lineTo(s.x * 0.15, s.y / 2)
      ..moveTo(s.x * 0.85, s.y / 2)
      ..lineTo(s.x, s.y / 2)
      ..strokePath();
    _tuerSymbol(g, zustand, true, s.x * 0.15 / m, s.x * 0.85 / m, 0, (v) => v * m, (v) => s.y / 2 - v * m, m);
  });
  final zeichenListe = <(pw.Widget, String)>[
    (
      zeichen(
        (g, s) => g
          ..setStrokeColor(PdfColors.grey700)
          ..setLineWidth(0.8)
          ..setLineDashPattern([3, 2])
          ..moveTo(0, s.y / 2)
          ..lineTo(s.x, s.y / 2)
          ..strokePath()
          ..setLineDashPattern(),
      ),
      'legende.feldgrenze',
    ),
    (
      zeichen(
        (g, s) => g
          ..setFillColor(DruckStil.tinte)
          ..drawEllipse(s.x * 0.3, s.y / 2, _punktRadius * m, _punktRadius * m)
          ..fillPath(),
      ),
      'legende.gegenstand',
    ),
    (
      zeichen(
        (g, s) => g
          ..setFillColor(PdfColors.grey200)
          ..drawRect(0, s.y * 0.15, s.x, s.y * 0.7)
          ..fillPath()
          ..setStrokeColor(PdfColors.grey600)
          ..setLineWidth(0.5)
          ..drawRect(0, s.y * 0.15, s.x, s.y * 0.7)
          ..strokePath(),
      ),
      'legende.moebel',
    ),
    for (final z in ['offen', 'angelehnt', 'zu', 'verschlossen']) (tuer(z), 'legende.tuer.$z'),
  ];
  final halbe = (zeichenListe.length / 2).ceil();
  pw.Widget zeichenSpalte(Iterable<(pw.Widget, String)> liste) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [for (final (z, schluessel) in liste) zeile(z, _text(k, _u(k, schluessel)), einzugZeichen: 8 * _mm)],
  );
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(KammerSatz.glyphen(k.klartext(_u(k, 'lageplan.legende'))), style: k.stil.ueberschrift(12.5)),
      pw.SizedBox(height: 1),
      for (final z in k.fall.zonen) ...[
        zeile(_zonenKreis(k, z.nr, kreis), _text(k, ['**${k.klartext(z.name)}**', if (z.felder.length == 1) ?texte[z.felder.single]].join('\n')), oben: 3.2),
        if (z.felder.length > 1)
          for (final f in z.felder) zeile(_feldRahmen(k, f), _text(k, ['**${k.klartext(k.fall.feld(f).name)}**', ?texte[f]].join(': '))),
      ],
      pw.SizedBox(height: 5),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: zeichenSpalte(zeichenListe.take(halbe))),
          pw.Expanded(child: zeichenSpalte(zeichenListe.skip(halbe))),
        ],
      ),
      pw.SizedBox(height: 5),
      for (final h in k.texte(plan.p.hinweise)) zeile(_text(k, '–'), _text(k, h), einzugZeichen: 3 * _mm),
    ],
  );
}

/// Teilfeld-Kennung im abgerundeten Rahmen (Legende).
pw.Widget _feldRahmen(KammerKontext k, String id) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.3),
  decoration: pw.BoxDecoration(
    border: pw.Border.all(color: DruckStil.tinte, width: 0.8),
    borderRadius: pw.BorderRadius.circular(4),
  ),
  child: pw.Text(id, style: _stil(k, fett: true)),
);

// ================================================================ Blatt B: Markerfelder

/// Blatt B: 5 × 3 Zellen zu 54 × 58 mm; Feld 1 über drei Zellen (MECH 10.2).
/// Je Feld Nummer, Name (wörtlich nach WELT 2.1) und eine Mini-Skizze der Lage.
void _blattB(KammerSeiten s, KammerKontext k) {
  final plan = _Plan(k);
  final mf = k.inhalt.tisch.markerfelder;
  final zb = mf.zelleBreiteMm * _mm;
  final zh = mf.zelleHoeheMm * _mm;
  final format = KammerSatz.a4Quer;
  final kopf = pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Expanded(child: pw.Text(KammerSatz.glyphen(k.klartext(_u(k, 'lageplan.blattB'))), style: k.stil.titel(15))),
      pw.Text(KammerSatz.glyphen(k.klartext(_u(k, 'lageplan.blattB.anschluss'))), style: _stil(k, farbe: DruckStil.leise)),
    ],
  );
  final gitterB = mf.spalten * zb;
  final kopfHoehe = s.satz.hoehe(kopf, gitterB) + 4 * _mm;
  if (gitterB > format.width - _randQuer.horizontal) _ueberlauf(s, 'markerfelder', 'Raster breiter als das Blatt');
  s.pruefeHoehe(kopfHoehe + mf.reihen * zh, format.height - _randQuer.vertical, wo: 'markerfelder');
  // Mini-Skizze: der ganze Keller klein, das Feld schwarz.
  const skizzeB = 32 * _mm;
  final skizzeH = skizzeB * plan.p.hoehe / plan.p.breite;
  const innen = pw.EdgeInsets.all(3 * _mm);
  final felder = [
    for (final b in mf.belegung)
      () {
        final spalten = [for (final z in b.zellen) z.$1];
        final reihen = [for (final z in b.zellen) z.$2];
        final s0 = spalten.reduce(math.min), s1 = spalten.reduce(math.max);
        final r0 = reihen.reduce(math.min), r1 = reihen.reduce(math.max);
        final feld = k.fall.feld(b.feld);
        final breite = (s1 - s0 + 1) * zb;
        final hoehe = (r1 - r0 + 1) * zh;
        // Wie auf Blatt A: Zone mit einem Feld im Kreis, Teilfeld im Rahmen.
        final zone = k.fall.zonen.firstWhere((z) => z.felder.contains(feld.id));
        const d = 7.5 * _mm;
        final kennung = pw.Container(
          width: zone.felder.length == 1 ? d : null,
          height: d,
          padding: zone.felder.length == 1 ? null : const pw.EdgeInsets.symmetric(horizontal: 4),
          alignment: pw.Alignment.center,
          decoration: zone.felder.length == 1
              ? pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: DruckStil.tinte, width: 1.1),
                )
              : pw.BoxDecoration(
                  border: pw.Border.all(color: DruckStil.tinte, width: 1.1),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
          child: pw.Text(feld.id, style: _stil(k, g: 13, fett: true)),
        );
        final kopfzeile = pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            kennung,
            pw.SizedBox(width: 2 * _mm),
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(top: 3.5),
                child: pw.Text(KammerSatz.glyphen(k.klartext(feld.name)), style: _stil(k, g: 10.5, fett: true)),
              ),
            ),
          ],
        );
        // Kopfzeile und Skizze dürfen sich nicht überlappen: Kopf über der Skizze.
        final kopfH = s.satz.hoehe(kopfzeile, breite - innen.horizontal);
        if (kopfH + skizzeH + 2 * _mm > hoehe - innen.vertical) {
          _ueberlauf(
            s,
            'markerfelder / ${feld.id}',
            'Name und Skizze ${((kopfH + skizzeH) / _mm).toStringAsFixed(1)} mm hoch, Platz ${((hoehe - innen.vertical) / _mm).toStringAsFixed(1)} mm',
          );
        }
        return pw.Positioned(
          left: s0 * zb,
          top: r0 * zh,
          child: pw.Container(
            width: breite,
            height: hoehe,
            padding: innen,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 1)),
            child: pw.Stack(
              children: [
                pw.Positioned(left: 0, top: 0, right: 0, child: kopfzeile),
                pw.Positioned(right: 0, bottom: 0, child: _skizze(plan, b.feld, skizzeB, skizzeH)),
              ],
            ),
          ),
        );
      }(),
  ];
  s.vollSeite(
    quer: true,
    rand: _randQuer,
    (c) => pw.Center(
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: gitterB, child: kopf),
          pw.SizedBox(height: kopfHoehe - s.satz.hoehe(kopf, gitterB)),
          pw.SizedBox(
            width: gitterB,
            height: mf.reihen * zh,
            child: pw.Stack(children: felder),
          ),
        ],
      ),
    ),
  );
}

/// Mini-Skizze der Lage eines Felds: Räume als dünne Umrisse, das Feld gefüllt.
pw.Widget _skizze(_Plan plan, String feld, double b, double h) => pw.SizedBox(
  width: b,
  height: h,
  child: pw.CustomPaint(
    size: PdfPoint(b, h),
    painter: (g, s) {
      final p = plan.p;
      final m = b / p.breite;
      void rechteck(_R r) => g.drawRect((r.x0 - p.x0) * m, h - (r.y1 - p.y0) * m, r.breite * m, r.hoehe * m);
      g.setFillColor(PdfColors.grey200);
      plan.raumKaesten.forEach(rechteck);
      g.fillPath();
      g.setFillColor(DruckStil.tinte);
      plan.felder[feld]!.forEach(rechteck);
      g.fillPath();
      g
        ..setStrokeColor(PdfColors.grey700)
        ..setLineWidth(0.5);
      plan.raumKaesten.forEach(rechteck);
      g.strokePath();
    },
  ),
);

// ================================================================ Marker

/// Positions-Marker: zwei je besetzter Rolle, Detektiv, Herr Schneider (MECH
/// 10.2): flache Plättchen 26 × 18 mm, alle auf einem Blatt A4 hoch. Je Person
/// stehen die beiden nebeneinander (sechs Spalten). Name, Platz-Nummer und
/// Zeitpunkt; der Grauton-Streifen unten unterscheidet 23:57 (hell) und
/// Scheppern (dunkler), der Name entscheidet (LÜ L-18).
void _marker(KammerSeiten s, KammerKontext k) {
  final x = k.satz;
  final mv = k.inhalt.tisch.marker;
  final b = mv.breiteMm * _mm;
  final h = mv.hoeheMm * _mm;
  final marker = k.besetzung.marker;
  if (marker.length > mv.max) _ueberlauf(s, 'marker', '${marker.length} Marker, höchstens ${mv.max}');
  String wer(KammerMarker m) => switch (m.wer) {
    kammerDetektiv => _u(k, 'marker.detektiv'),
    kammerSchneider => _u(k, 'marker.schneider'),
    _ => k.inhalt.platzVon(m.wer).name,
  };
  final zeiten = k.fall.zeitpunkte;
  const innen = pw.EdgeInsets.fromLTRB(2 * _mm, 1.2 * _mm, 2 * _mm, 1.2 * _mm);
  final iw = b - innen.horizontal;
  const rand = pw.EdgeInsets.all(12 * _mm);
  const spalten = 6;
  final ueber = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      x.ueberschrift(_u(k, 'marker.titel')),
      x.absatz(_u(k, 'marker.hinweis', {for (final z in zeiten) z: k.uiGemeinsam('zeitpunkt.$z')}), groesse: _pt + 1),
    ],
  );
  s.raster(
    wo: 'marker',
    [
      for (final m in marker)
        KammerZelle(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(KammerSatz.glyphen(k.klartext(wer(m))), style: _stil(k, g: 10.5, fett: true)),
              if (m.platz case final p?) pw.Text(k.klartext(_u(k, 'marker.platz', {'platz': '$p'})), style: _stil(k, farbe: DruckStil.leise)),
            ],
          ),
          unten: pw.Container(
            width: iw,
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            alignment: pw.Alignment.center,
            color: zeiten.indexOf(m.zeitpunkt) == 0 ? PdfColors.grey200 : PdfColors.grey500,
            child: pw.Text(k.klartext(k.uiGemeinsam('zeitpunkt.${m.zeitpunkt}')), style: _stil(k, fett: true)),
          ),
          wo: '${m.wer} ${m.zeitpunkt}',
        ),
    ],
    breite: b,
    hoehe: h,
    spalten: spalten,
    // So viele Reihen, wie auf die Seite passen: Das Raster steht mittig, die Plättchen beginnen so oben.
    reihen: math.max(
      (marker.length / spalten).ceil(),
      ((KammerSatz.a4Hoch.height - rand.vertical - s.satz.hoehe(ueber, KammerSatz.a4Hoch.width - rand.horizontal) - 6) / h).floor(),
    ),
    innen: innen,
    rand: rand,
    ueber: ueber,
    maxSeiten: 1,
  );
}

// ================================================================ Tipp-Zettel

/// Tipp-Zettel (MECH 7.1, wörtlich aus `tisch.json`): einer je Rolle und einer
/// für den Erzähler, A6 quer, vier je A4 hoch (2 × 2 Felder zu 105 × 148,5 mm,
/// der Zettel um 90° gedreht).
void _tippZettel(KammerSeiten s, KammerKontext k) {
  final t = k.inhalt.tisch.tippZettel;
  const spalten = 2;
  final reihen = t.jeBlatt ~/ spalten;
  final zb = KammerSatz.a4Hoch.width / spalten;
  final zh = KammerSatz.a4Hoch.height / reihen;
  const innen = pw.EdgeInsets.all(9 * _mm);
  // Lesefläche des gedrehten Zettels (A6 quer): Breite = Höhe des Felds.
  final lb = zh - innen.vertical;
  final lh = zb - innen.horizontal;
  const g = 11.0;
  final kopf = pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Text(KammerSatz.glyphen(k.klartext(t.titel)), style: k.stil.ueberschrift(16)),
      pw.SizedBox(width: 8 * _mm),
      pw.Expanded(child: _text(k, t.name, g: g)),
    ],
  );
  // Punkte geschützt anhängen, damit „(2 Punkte)“ nicht auseinanderbricht.
  String punkte(KammerTippFrage f) =>
      (f.punkte == 1 ? _u(k, 'tippZettel.punkt') : _u(k, 'tippZettel.punkte', {'punkte': '${f.punkte}'})).replaceAll(' ', _fest);
  final fragen = [
    for (final f in t.fragen)
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 3 * _mm),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 6 * _mm,
              child: pw.Text('${f.nr}.', style: _stil(k, g: g, fett: true)),
            ),
            pw.Expanded(child: _text(k, '${k.text(f.text)} ${punkte(f)}', g: g, zeilenabstand: 0.35)),
          ],
        ),
      ),
  ];
  final fuss = _text(k, t.fuss, g: _pt + 0.5, farbe: DruckStil.leise);
  final oben = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      kopf,
      pw.SizedBox(height: 1 * _mm),
      ...fragen,
    ],
  );
  final hoehe = s.satz.hoehe(oben, lb) + 4 * _mm + s.satz.hoehe(fuss, lb);
  if (hoehe > lh) _ueberlauf(s, 'tippzettel', '${(hoehe / _mm).toStringAsFixed(1)} mm hoch, Platz ${(lh / _mm).toStringAsFixed(1)} mm');
  // Um 90° gedreht; das Kind bekommt seine eigene Größe (sonst gälte die schmale Feldbreite).
  final zettel = pw.Transform.rotateBox(
    angle: math.pi / 2,
    unconstrained: true,
    child: pw.SizedBox(
      width: lb,
      height: lh,
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [oben, pw.Spacer(), fuss]),
    ),
  );
  s.raster(
    wo: 'tippzettel',
    [for (var i = 0; i < k.besetzung.tippZettel; i++) KammerZelle(zettel, wo: 'tippzettel ${i + 1}')],
    breite: zb,
    hoehe: zh,
    spalten: spalten,
    reihen: reihen,
    innen: innen,
  );
}

// ================================================================ Abwesenheitsblatt

/// Abwesenheitsblatt (MECH 5.2): ein A4-Blatt hoch mit 5 mm Rand, je fehlendem
/// Zeugen ein Streifen 100 × 95 mm in Platzreihenfolge. Oben das Etikett (bis
/// zum Falz 30 mm unter der Oberkante), darunter das Protokoll um 180° gedreht:
/// gefaltet liegt das Etikett oben, das Protokoll mit der Schrift nach unten.
/// Protokoll und Vermerk in 9 pt, Joannas Notiz zweispaltig in 8 pt unter dem
/// Protokoll (die Spalten so geteilt, dass die Notiz am wenigsten Zeilen braucht).
void _abwesenheit(KammerSeiten s, KammerKontext k) {
  final a = k.inhalt.tisch.abwesenheitsblatt;
  final pt = a.schriftPt.toDouble();
  final notizPt = a.notizPt.toDouble();
  // Mindestgrößen fest (MECH 5.2, 19.2 Nr. 4): 9 pt, nur die Notiz 8 pt.
  if (pt < _pt || notizPt < _pt - 1) _ueberlauf(s, 'abwesenheitsblatt', 'Schrift ${a.schriftPt}/${a.notizPt} pt, mindestens 9/8 pt');
  final sb = a.streifenBreiteMm * _mm;
  final sh = a.streifenHoeheMm * _mm;
  final falz = a.etikettHoeheMm * _mm;
  // Abstände im Streifen: seitlich 2,5 mm, oben 2,5 mm, am Falz je 1,6 mm (Platz für „Hier falten“), unten 2 mm.
  const seitlich = 2.5 * _mm, oben = 2.5 * _mm, amFalz = 1.6 * _mm, unten = 2 * _mm, luft = 1.3 * _mm;
  final tb = sb - 2 * seitlich;
  pw.Widget text(String roh, double g, {bool fett = false}) => _text(k, roh, g: g, fett: fett);
  // Joannas Notiz zweispaltig: Teilung und Spaltenbreite so, dass sie am wenigsten Höhe braucht.
  pw.Widget notiz(KammerNotiz n, String wo) {
    final zeilen = k.texte(n.zeilen).map(k.klartext).toList();
    const zwischen = 3 * _mm;
    pw.Widget spalte(Iterable<String> z, double b) => pw.SizedBox(
      width: b,
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [for (final t in z) text(t, notizPt)]),
    );
    (double, int, double)? beste;
    for (var teil = 1; teil < zeilen.length; teil++) {
      for (var b1 = 0.3 * tb; b1 <= 0.7 * tb; b1 += 1 * _mm) {
        final b2 = tb - zwischen - b1;
        final hoehe = math.max(s.satz.hoehe(spalte(zeilen.take(teil), b1), b1), s.satz.hoehe(spalte(zeilen.skip(teil), b2), b2));
        if (beste == null || hoehe < beste.$1 - 0.01) beste = (hoehe, teil, b1);
      }
    }
    if (beste == null) _ueberlauf(s, '$wo / notiz', 'keine Zeilen');
    final (_, teil, b1) = beste;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        spalte(zeilen.take(teil), b1),
        pw.SizedBox(width: zwischen),
        spalte(zeilen.skip(teil), tb - zwischen - b1),
      ],
    );
  }

  final zellen = <KammerZelle>[];
  for (final st in k.besetzung.streifen) {
    final wo = 'abwesenheitsblatt / ${st.zeuge}';
    // Das Etikett hat feste Höhe bis zum Falz: messen statt still kürzen.
    final etikett = s.fest(text(st.etikett, pt), breite: tb, hoehe: falz - oben - amFalz, wo: '$wo / etikett');
    final innen = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        text(st.protokoll, pt),
        if (st.mitNotiz) ...[pw.SizedBox(height: luft), notiz(k.inhalt.rolle(st.zeuge).notiz ?? _ueberlauf(s, wo, 'Notiz fehlt'), wo)],
        pw.SizedBox(height: luft),
        text(st.vermerk, pt, fett: true),
      ],
    );
    final protokoll = s.fest(innen, breite: tb, hoehe: sh - falz - amFalz - unten, wo: '$wo / protokoll');
    zellen.add(
      KammerZelle(
        pw.SizedBox(
          width: sb,
          height: sh,
          child: pw.Stack(
            children: [
              pw.Positioned(left: seitlich, top: oben, child: etikett),
              pw.Positioned(
                left: 1.5 * _mm,
                right: 1.5 * _mm,
                top: falz - 4,
                child: pw.SizedBox(height: 8, child: k.satz.falzlinie()),
              ),
              // Um 180° gedreht: der Anfang des Protokolls liegt an der Unterkante, gelesen oben.
              pw.Positioned(
                left: seitlich,
                top: falz + amFalz,
                child: pw.Transform.rotate(angle: math.pi, child: protokoll),
              ),
            ],
          ),
        ),
        wo: wo,
      ),
    );
  }
  s.raster(
    wo: 'abwesenheitsblatt',
    zellen,
    breite: sb,
    hoehe: sh,
    spalten: a.spalten,
    reihen: a.reihen,
    innen: pw.EdgeInsets.zero,
    rand: pw.EdgeInsets.all(a.randMm * _mm),
    maxSeiten: 1,
  );
}
