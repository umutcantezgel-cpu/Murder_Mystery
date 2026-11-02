/// Teil 02: Lageplan (Blatt A und B, A4 quer), Positions-Marker, Tipp-Zettel,
/// Abwesenheitsblatt bei 6 bis 11 Personen (MECH 10.1, 10.2, 5, 7.1).
///
/// Stand: einfache, aber echte Fassung aus dem Inhalt (Gerüst G2): Plan aus der
/// Geometrie von `tisch.json`, Markerfelder, Plättchen, Tipp-Zettel, Streifen.
/// Symbole, Mini-Skizzen, Seitenzahlen (MECH 10.1: 6 / 6 / 8) und Feinheiten
/// baut der Teil-Agent 02.
library;

import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../satz_stil.dart';
import 'besetzung.dart';
import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

const _mm = KammerSatz.mm;

/// Setzt Teil 02 (Tisch) in [doc].
void kammerTisch(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '02', (s) {
      _blattA(s, k);
      _blattB(s, k);
      _marker(s, k);
      _tippZettel(s, k);
      if (k.besetzung.abwesenheitsblatt) _abwesenheit(s, k);
    });

String _u(KammerKontext k, String schluessel, [Map<String, String> werte = const {}]) => k.ui('02', schluessel, werte);

// ---------------------------------------------------------------- Blatt A: Lageplan

/// Blatt A: maßstäblicher Plan links (1 m = 8,5 mm), Legende rechts (MECH 10.2).
void _blattA(KammerSeiten s, KammerKontext k) {
  final x = k.satz;
  final plan = k.inhalt.tisch.lageplan;
  final m = plan.mmJeMeter * _mm;
  final w = plan.breite * m;
  final h = plan.hoehe * m;
  const rand = pw.EdgeInsets.all(6 * _mm);
  final titel = x.titel(_u(k, 'lageplan.titel'), groesse: 15);
  final format = KammerSatz.a4Quer;
  s.pruefeHoehe(x.hoehe(titel, w) + 2 * _mm + h, format.height - rand.vertical, wo: 'lageplan');
  final legendeBreite = format.width - rand.horizontal - w - 6 * _mm;
  final legende = _legende(k, legendeBreite);
  s.pruefe(legende, breite: legendeBreite, platz: format.height - rand.vertical, wo: 'legende');
  s.vollSeite(
    quer: true,
    rand: rand,
    (c) => pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [titel, pw.SizedBox(height: 2 * _mm), _plan(k, m)]),
      pw.SizedBox(width: 6 * _mm),
      pw.SizedBox(width: legendeBreite, child: legende),
    ]),
  );
}

/// Linke obere Ecke eines Bereichs in pt (y von oben).
(double, double) _ecke(KammerLageplan p, KammerBereich b, double m) => ((b.x0 - p.x0) * m, (b.y0 - p.y0) * m);

pw.Widget _plan(KammerKontext k, double m) {
  final x = k.satz;
  final p = k.inhalt.tisch.lageplan;
  final w = p.breite * m;
  final h = p.hoehe * m;
  void rechteck(PdfGraphics g, KammerBereich b) =>
      g.drawRect((b.x0 - p.x0) * m, h - (b.y1 + 1 - p.y0) * m, (b.x1 - b.x0 + 1) * m, (b.y1 - b.y0 + 1) * m);
  return pw.SizedBox(
    width: w,
    height: h,
    child: pw.Stack(children: [
      pw.CustomPaint(
        size: PdfPoint(w, h),
        painter: (g, groesse) {
          // Hellgraues 1-m-Gitter.
          g
            ..setStrokeColor(PdfColors.grey300)
            ..setLineWidth(0.3);
          for (var i = 0; i <= p.breite; i++) {
            g
              ..moveTo(i * m, 0)
              ..lineTo(i * m, h);
          }
          for (var j = 0; j <= p.hoehe; j++) {
            g
              ..moveTo(0, j * m)
              ..lineTo(w, j * m);
          }
          g.strokePath();
          // Möbel grau gefüllt.
          g.setFillColor(PdfColors.grey300);
          for (final f in p.moebel) {
            for (final b in f.kacheln) {
              rechteck(g, b);
            }
          }
          g.fillPath();
          // Markerfelder gestrichelt.
          g
            ..setStrokeColor(PdfColors.grey600)
            ..setLineWidth(0.7)
            ..setLineDashPattern([3, 2]);
          for (final f in p.felder) {
            for (final b in f.kacheln) {
              rechteck(g, b);
            }
          }
          g
            ..strokePath()
            ..setLineDashPattern();
          // Räume mit kräftiger Wand.
          g
            ..setStrokeColor(DruckStil.tinte)
            ..setLineWidth(1.4);
          for (final r in p.raeume) {
            for (final b in r.kacheln) {
              rechteck(g, b);
            }
          }
          g.strokePath();
          // Türen als Balken, Gegenstände als Punkte.
          g.setFillColor(DruckStil.tinte);
          for (final t in p.tueren) {
            g.drawRect((t.x - p.x0) * m - m * 0.3, h - (t.y - p.y0) * m - m * 0.3, m * 0.6, m * 0.6);
          }
          for (final o in p.gegenstaende) {
            g.drawEllipse((o.x - p.x0) * m, h - (o.y - p.y0) * m, m * 0.15, m * 0.15);
          }
          g.fillPath();
        },
      ),
      for (final r in p.raeume)
        if (r.name case final name?)
          pw.Positioned(
            left: _ecke(p, r.kacheln.first, m).$1 + 3,
            top: _ecke(p, r.kacheln.first, m).$2 + 3,
            child: pw.Text(k.klartext(name), style: k.stil.ueberschrift(7.5)),
          ),
      for (final f in p.felder)
        pw.Positioned(
          left: _ecke(p, f.kacheln.first, m).$1 + 3,
          top: _ecke(p, f.kacheln.first, m).$2 + 13,
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 0.8), borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Text(f.id, style: k.stil.ueberschrift(7.5)),
          ),
        ),
      for (final o in p.gegenstaende)
        pw.Positioned(
          left: (o.x - p.x0) * m + 3,
          top: (o.y - p.y0) * m - 3,
          child: pw.Text(KammerSatz.glyphen(k.klartext(o.name)), style: k.stil.klein(5)),
        ),
      // Kein Rollenname auf dem Plan (SCHEMA tisch.json); nur Räume, Felder, Gegenstände.
      pw.Positioned(left: 0, top: h - 10, child: x.marke(_u(k, 'lageplan.massstab'), groesse: 6.5)),
    ]),
  );
}

pw.Widget _legende(KammerKontext k, double breite) {
  final x = k.satz;
  final plan = k.inhalt.tisch.lageplan;
  final texte = {for (final l in plan.legende) l.schluessel: l.text};
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    x.ueberschrift(_u(k, 'lageplan.legende'), stufe: 2),
    for (final z in k.fall.zonen) ...[
      x.absatz('**${z.nr}** ${z.name}', groesse: 8),
      for (final f in z.felder)
        if (texte[f] case final t?) pw.Padding(padding: const pw.EdgeInsets.only(left: 8, bottom: 2), child: x.absatz('${k.fall.feld(f).id}: $t', groesse: 7)),
    ],
    pw.SizedBox(height: 6),
    x.liste(plan.hinweise, groesse: 7.5),
  ]);
}

// ---------------------------------------------------------------- Blatt B: Markerfelder

/// Blatt B: 5 × 3 Zellen zu 54 × 58 mm; Feld 1 über drei Zellen (MECH 10.2).
void _blattB(KammerSeiten s, KammerKontext k) {
  final x = k.satz;
  final mf = k.inhalt.tisch.markerfelder;
  final zb = mf.zelleBreiteMm * _mm;
  final zh = mf.zelleHoeheMm * _mm;
  final titel = x.titel(_u(k, 'lageplan.blattB'), groesse: 14);
  final format = KammerSatz.a4Quer;
  s.pruefeHoehe(x.hoehe(titel, mf.spalten * zb) + 4 * _mm + mf.reihen * zh, format.height - 12 * _mm, wo: 'markerfelder');
  // Die Felder vor der Seite bauen und messen ([KammerSeiten.fest]); der Seitenbau läuft erst beim Speichern.
  final felder = [
    for (final b in mf.belegung)
      () {
        final spalten = [for (final z in b.zellen) z.$1];
        final reihen = [for (final z in b.zellen) z.$2];
        final s0 = spalten.reduce(math.min), s1 = spalten.reduce(math.max);
        final r0 = reihen.reduce(math.min), r1 = reihen.reduce(math.max);
        final feld = k.fall.feld(b.feld);
        return pw.Positioned(
          left: s0 * zb,
          top: r0 * zh,
          child: s.fest(
            x.absatz('**${feld.id}** ${feld.name}', groesse: 8.5),
            breite: (s1 - s0 + 1) * zb,
            hoehe: (r1 - r0 + 1) * zh,
            innen: const pw.EdgeInsets.all(5),
            rahmen: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 0.8)),
            wo: 'markerfelder / ${feld.id}',
          ),
        );
      }(),
  ];
  s.vollSeite(
    quer: true,
    rand: const pw.EdgeInsets.all(6 * _mm),
    (c) => pw.Center(
      child: pw.Column(mainAxisSize: pw.MainAxisSize.min, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        titel,
        pw.SizedBox(height: 4 * _mm),
        pw.SizedBox(width: mf.spalten * zb, height: mf.reihen * zh, child: pw.Stack(children: felder)),
      ]),
    ),
  );
}

// ---------------------------------------------------------------- Marker

/// Positions-Marker: zwei je besetzter Rolle, Detektiv, Herr Schneider (MECH 10.2).
void _marker(KammerSeiten s, KammerKontext k) {
  final x = k.satz;
  String wer(KammerMarker m) => switch (m.wer) {
        kammerDetektiv => _u(k, 'marker.detektiv'),
        kammerSchneider => _u(k, 'marker.schneider'),
        _ => k.inhalt.platzVon(m.wer).name,
      };
  s.plaettchen(
    wo: 'marker',
    ueber: x.ueberschrift(_u(k, 'marker.titel')),
    [
      for (final m in k.besetzung.marker)
        KammerZelle(
          x.absatz('**${wer(m)}**', groesse: 8),
          unten: x.absatz(
            [if (m.platz case final p?) _u(k, 'marker.platz', {'platz': '$p'}), k.uiGemeinsam('zeitpunkt.${m.zeitpunkt}')].join(' · '),
            groesse: 6.5,
          ),
          wo: '${m.wer} ${m.zeitpunkt}',
        ),
    ],
  );
}

// ---------------------------------------------------------------- Tipp-Zettel

/// Tipp-Zettel: einer je Rolle und einer für den Erzähler, vier je Blatt (MECH 7.1).
void _tippZettel(KammerSeiten s, KammerKontext k) {
  final x = k.satz;
  final t = k.inhalt.tisch.tippZettel;
  pw.Widget zettel() => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        x.ueberschrift(t.titel, stufe: 2),
        x.absatz(t.name, groesse: 10),
        pw.SizedBox(height: 8),
        for (final f in t.fragen) ...[
          x.absatz('**${f.nr}.** ${f.text}', groesse: 10),
          x.absatz(f.punkte == 1 ? _u(k, 'tippZettel.punkt') : _u(k, 'tippZettel.punkte', {'punkte': '${f.punkte}'}), groesse: 8.5, leise: true),
          pw.SizedBox(height: 10),
        ],
      ]);
  final spalten = 2;
  final reihen = t.jeBlatt ~/ spalten;
  s.raster(
    wo: 'tippzettel',
    [for (var i = 0; i < k.besetzung.tippZettel; i++) KammerZelle(zettel(), unten: x.absatz(t.fuss, groesse: 8, leise: true))],
    breite: KammerSatz.a4Hoch.width / spalten,
    hoehe: KammerSatz.a4Hoch.height / reihen,
    spalten: spalten,
    reihen: reihen,
    innen: const pw.EdgeInsets.all(12 * _mm),
  );
}

// ---------------------------------------------------------------- Abwesenheitsblatt

/// Abwesenheitsblatt: je fehlendem Zeugen ein Streifen 100 × 95 mm, Etikett oben,
/// Protokoll um 180° gedreht darunter, gefaltet 30 mm unter der Oberkante (MECH 5.2).
/// Gerüst: Protokoll und Notiz je 1 pt kleiner als `schriftPt`/`notizPt`, weil
/// Joannas Streifen sonst nicht in 95 mm passt; das löst der Teil-Agent 02.
void _abwesenheit(KammerSeiten s, KammerKontext k) {
  final x = k.satz;
  final a = k.inhalt.tisch.abwesenheitsblatt;
  const innen = pw.EdgeInsets.fromLTRB(3 * _mm, 2 * _mm, 3 * _mm, 2 * _mm);
  // Joannas Notiz zweispaltig in notizPt (MECH 5.2), Zeilen je Spalte als ein Absatz.
  pw.Widget notiz(KammerNotiz n) {
    final zeilen = k.texte(n.zeilen);
    final haelfte = (zeilen.length / 2).ceil();
    final g = a.notizPt - 1.0;
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(child: x.absatz(zeilen.take(haelfte).join('\n'), groesse: g)),
      pw.SizedBox(width: 4),
      pw.Expanded(child: x.absatz(zeilen.skip(haelfte).join('\n'), groesse: g)),
    ]);
  }

  final iw = a.streifenBreiteMm * _mm - innen.horizontal;
  s.raster(
    wo: 'abwesenheitsblatt',
    [
      for (final st in k.besetzung.streifen)
        KammerZelle(
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
            // Das Etikett hat feste Höhe bis zum Falz: messen statt still kürzen.
            s.fest(x.absatz(st.etikett, groesse: 7.5, abstand: 1), breite: iw, hoehe: a.etikettHoeheMm * _mm - innen.top - 2, wo: '${st.zeuge} / etikett'),
            x.falzlinie(),
            pw.SizedBox(height: 1 * _mm),
            pw.Transform.rotate(
              angle: math.pi,
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                x.absatz(st.protokoll, groesse: a.schriftPt - 1.0),
                pw.SizedBox(height: 3),
                x.absatz('**${k.klartext(st.vermerk)}**', groesse: a.schriftPt - 1.0),
                if (st.mitNotiz)
                  if (k.inhalt.rolle(st.zeuge).notiz case final n?) ...[pw.SizedBox(height: 2), notiz(n)],
              ]),
            ),
          ]),
          wo: st.zeuge,
        ),
    ],
    breite: a.streifenBreiteMm * _mm,
    hoehe: a.streifenHoeheMm * _mm,
    spalten: a.spalten,
    reihen: a.reihen,
    innen: innen,
    rand: pw.EdgeInsets.all(a.randMm * _mm),
    maxSeiten: 1,
  );
}
