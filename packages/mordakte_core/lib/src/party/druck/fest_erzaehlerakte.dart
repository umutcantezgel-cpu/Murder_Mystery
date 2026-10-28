import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../besetzung.dart';
import '../erzaehlerakte.dart';
import '../kanon/kanon.dart';
import '../texte.dart';
import 'paket.dart';
import 'satz.dart';
import 'satz_fest.dart';

// Erzählerakte im festlichen Stil (Druckpaket, Ordner 4; A-063, SPEZIFIKATION §2):
// Deckblatt „Nur für dich als Erzähler“, Herr Schneider und der Detektiv, das
// Beziehungsnetz als Ring mit nummerierter Legende, dann je Figur eine Seite – erst
// die besetzten, dann die ohne Spieler. Alles kommt aus der zusammengesetzten
// [Erzaehlerakte] (Datei und Kanon, Ziele über ihre ZielQuelle) und den Bausteinen
// `ui.druck.akte.*`. Kein Druck-Satz, kein Fall-Code: In allen Pfaden entsteht
// dieselbe Datei.

/// Was die Erzählerakte zum Setzen braucht: Kanon, Texte, die zusammengesetzte
/// [akte], der festliche Stil, die Personenzahl [rollen] und die Porträts.
class ErzaehlerakteKontext {
  ErzaehlerakteKontext(this.kanon, this.texte, this.akte, {required this.stil, required this.rollen, FestPortraets? portraets})
      : portraets = portraets ?? FestPortraets(const {}),
        besetzung = Besetzung(kanon) {
    besetzung.besetzt(rollen); // prüft die Personenzahl
  }

  final Kanon kanon;
  final Texte texte;
  final Erzaehlerakte akte;
  final FestStil stil;
  final int rollen;
  final FestPortraets portraets;
  final Besetzung besetzung;

  late final Map<String, Object?> _opfer = (kanon.figurenJson['opfer'] as Map).cast<String, Object?>();

  /// Kennung des Opfers, der Mitte des Netzes (`schneider`).
  String get opfer => _opfer['id'] as String;

  String get fallTitel => kanon.fall['titel'] as String;

  String ui(String kennung, [Map<String, String> werte = const {}]) {
    var t = texte.baustein(kennung);
    for (final e in werte.entries) {
      t = t.replaceAll('{${e.key}}', e.value);
    }
    return t;
  }

  /// Anzeigename eines Knotens im Netz: Figur oder Opfer.
  String name(String knoten) => knoten == opfer ? _opfer['name'] as String : kanon.figur(knoten)!['name'] as String;

  /// Farbe eines Knotens aus `colorCode`.
  PdfColor farbe(String knoten) => PdfColor.fromHex((knoten == opfer ? _opfer['colorCode'] : kanon.figur(knoten)!['colorCode']) as String);

  /// Porträt einer Figur (Detektiv: `detektiv-w`/`detektiv-m`); null, wenn keins vorliegt.
  pw.ImageProvider? bild(String id, {bool klein = false}) => portraets.bild(id, klein: klein);

  /// Platz in der Besetzungsreihenfolge (ab 1): die Nummer im Netz.
  int platz(String figur) => besetzung.reihenfolge.indexOf(figur) + 1;

  bool istBesetzt(String figur) => _besetzt.contains(figur);
  late final Set<String> _besetzt = besetzung.besetzt(rollen).toSet();

  /// Die Figuren der Akte: erst die besetzten, dann die ohne Spieler, je in
  /// Besetzungsreihenfolge.
  late final List<ErzaehlerakteFigur> figuren = [
    for (final id in [...besetzung.besetzt(rollen), ...besetzung.npc(rollen)]) ?akte.figur(id),
  ];

  String seite(int nr, int von) => ui('ui.druck.fest.seite', {'nr': '$nr', 'von': '$von'});
}

/// Die Erzählerakte als Datei (`erzaehlerakte.pdf`).
Future<DruckDatei> festErzaehlerakteDatei(ErzaehlerakteKontext k) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.akte.titel')}');
  festErzaehlerakte(doc, k);
  return DruckDatei('erzaehlerakte.pdf', await k.stil.speichern(doc));
}

void festErzaehlerakte(pw.Document doc, ErzaehlerakteKontext k) {
  pw.PageTheme theme({PdfColor? lasche, String? laschenText}) => k.stil.seite(
        falltitel: k.fallTitel,
        marke: k.ui('ui.druck.akte.titel'),
        fuss: k.ui('ui.druck.akte.fuss'),
        seitenzahl: k.seite,
        lasche: lasche,
        laschenText: laschenText,
      );
  doc
    ..addPage(pw.Page(pageTheme: theme(), build: (c) => _deckblatt(k)))
    ..addPage(pw.MultiPage(pageTheme: theme(), build: (c) => _personen(k)))
    ..addPage(pw.MultiPage(pageTheme: theme(), build: (c) => _netz(k)));
  for (final f in k.figuren) {
    _figurSeite(doc, k, f, theme(lasche: k.farbe(f.figur), laschenText: f.name));
  }
}

// ---------------------------------------------------------------- Deckblatt

pw.Widget _deckblatt(ErzaehlerakteKontext k) {
  final s = k.stil;
  return s.spalte(wo: 'Erzählerakte Deckblatt', quer: pw.CrossAxisAlignment.center, [
    pw.SizedBox(height: 40),
    s.siegel(96, wachs: true),
    pw.SizedBox(height: 22),
    pw.Text(k.ui('ui.druck.akte.titel'), style: s.titel(48)),
    pw.SizedBox(height: 2),
    pw.Text(k.fallTitel, style: s.kursiv(16, FestStil.tinteLeise)),
    pw.SizedBox(height: 12),
    s.zierlinie(240),
    pw.SizedBox(height: 12),
    pw.Text(k.ui('ui.druck.akte.personen', {'anzahl': '${k.rollen}'}).toUpperCase(), style: s.marke(10.5)),
    pw.SizedBox(height: 22),
    s.stempel(k.ui('ui.druck.akte.nur'), g: 12.5, neigung: -0.04),
    pw.Spacer(),
    pw.SizedBox(
      width: FestStil.breite - 50,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(k.akte.einleitung, style: s.text(12)),
          pw.SizedBox(height: 8),
          pw.Text(k.ui('ui.druck.akte.inhalt', {'opfer': k.name(k.opfer)}), style: s.kursiv(12, FestStil.tinteLeise)),
          pw.SizedBox(height: 14),
          s.feld(pw.Text(k.ui('ui.druck.akte.hinweis'), style: s.kursiv(12)), farbe: FestStil.stempelrot),
        ],
      ),
    ),
    pw.SizedBox(height: 20),
  ]);
}

// ---------------------------------------------------------------- Herr Schneider und der Detektiv

List<pw.Widget> _personen(ErzaehlerakteKontext k) {
  final a = k.akte;
  final opfer = a.schneider;
  return [
    ..._blatt(
      k,
      opfer,
      titel: opfer.name ?? k.name(k.opfer),
      unter: [?opfer.rolle, if (opfer.alter case final n?) k.ui('ui.druck.fest.jahre', {'alter': '$n'})].join('  ·  '),
      bilder: [k.bild(k.opfer)],
      farbe: k.farbe(k.opfer),
    ),
    pw.SizedBox(height: 26),
    ..._blatt(
      k,
      a.detektiv,
      titel: k.ui('ui.druck.akte.detektiv'),
      unter: '',
      bilder: [k.bild('detektiv-w'), k.bild('detektiv-m')],
      farbe: FestStil.messing,
    ),
  ];
}

/// Ein Blatt für Herrn Schneider oder den Detektiv: Porträts (wenn vorhanden),
/// Name und Rolle, Hintergrund und Stimme.
List<pw.Widget> _blatt(ErzaehlerakteKontext k, ErzaehlerakteBlatt b, {required String titel, required String unter, required List<pw.ImageProvider?> bilder, required PdfColor farbe}) {
  final s = k.stil;
  final da = [for (final x in bilder) ?x];
  // Der Name bleibt einzeilig neben den Porträts.
  final groesse = s.einzeilig(titel, (g) => s.titel(g), FestStil.breite - da.length * 98 - 12, start: 30, min: 18);
  return [
    pw.Inseparable(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          for (final (i, bild) in da.indexed) ...[
            pw.Padding(padding: const pw.EdgeInsets.only(left: 4, top: 6, bottom: 4), child: s.fotoabzug(bild, 86, neigung: i.isEven ? -0.035 : 0.03)),
            pw.SizedBox(width: 12),
          ],
          if (da.isNotEmpty) pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(titel, style: s.titel(groesse)),
                if (unter.isNotEmpty) pw.Text(unter, style: s.kursiv(12.5, FestStil.tinteLeise)),
              ],
            ),
          ),
        ],
      ),
    ),
    pw.SizedBox(height: 10),
    _abschnitt(k, k.ui('ui.druck.akte.hintergrund'), farbe, pw.Text(b.hintergrund, style: s.text(11))),
    if (b.stimme.isNotEmpty) _abschnitt(k, k.ui('ui.druck.akte.stimme'), farbe, s.punkte(b.stimme, g: 10.5, abstand: 2)),
  ];
}

/// Abschnitt mit Überschrift, der nicht über eine Seitengrenze bricht.
pw.Widget _abschnitt(ErzaehlerakteKontext k, String titel, PdfColor farbe, pw.Widget inhalt) => pw.Inseparable(
      child: pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 9),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [k.stil.kopfzeile(titel, g: 13.5, farbe: farbe, abstand: 3), inhalt],
        ),
      ),
    );

// ---------------------------------------------------------------- Netz

/// Maße des Rings: Fläche, Radius der Figuren, Durchmesser der Knoten.
const _ringHoehe = 392.0, _ringRadius = 156.0, _knoten = 30.0, _mitte = 46.0, _etikett = 72.0;

/// Heimliche Kante zu einer Figur ohne Spieler: blasses Stempelrot.
const _rotBlass = PdfColor.fromInt(0xFFDDB0B4);

List<pw.Widget> _netz(ErzaehlerakteKontext k) {
  final s = k.stil;
  return [
    pw.Text(k.ui('ui.druck.akte.netz.titel'), style: s.titel(28)),
    pw.SizedBox(height: 3),
    pw.Container(height: 0.5, color: FestStil.linie),
    pw.SizedBox(height: 6),
    pw.Text(k.ui('ui.druck.akte.netz.hinweis', {'opfer': k.name(k.opfer)}), style: s.kursiv(10.5, FestStil.tinteLeise)),
    pw.SizedBox(height: 6),
    _ring(k),
    pw.SizedBox(height: 8),
    _linienLegende(k),
    pw.SizedBox(height: 14),
    s.kopfzeile(k.ui('ui.druck.akte.legende.titel'), g: 15),
    ..._legende(k),
  ];
}

/// Der Ring: Herr Schneider in der Mitte, die Figuren in Besetzungsreihenfolge
/// im Uhrzeigersinn ab oben, jede mit ihrer Nummer. Öffentliche Kanten
/// durchgezogen, heimliche gestrichelt; Figuren ohne Spieler blass.
pw.Widget _ring(ErzaehlerakteKontext k) {
  final s = k.stil;
  final breite = FestStil.breite;
  final cx = breite / 2, cy = _ringHoehe / 2;
  final reihe = k.besetzung.reihenfolge;
  // Lage der Knoten (von oben links gemessen) und ihr Winkel ab oben im Uhrzeigersinn.
  final winkel = {for (final (i, id) in reihe.indexed) id: 2 * math.pi * i / reihe.length};
  final lage = <String, (double, double)>{
    k.opfer: (cx, cy),
    for (final e in winkel.entries) e.key: (cx + _ringRadius * math.sin(e.value), cy - _ringRadius * math.cos(e.value)),
  };
  bool blass(String id) => id != k.opfer && !k.istBesetzt(id);
  final kanten = [
    for (final kante in k.akte.netz)
      if (lage.containsKey(kante.a) && lage.containsKey(kante.b)) kante,
  ];
  // Blasse Kanten zuerst, dann öffentliche, zuletzt heimliche: Die gestrichelten bleiben sichtbar.
  int rang(NetzKante x) => (blass(x.a) || blass(x.b) ? 0 : 2) + (x.oeffentlich ? 0 : 1);
  final reihenfolge = [for (var r = 0; r < 4; r++) ...kanten.where((x) => rang(x) == r)];

  void maler(PdfGraphics g, PdfPoint groesse) {
    for (final kante in reihenfolge) {
      final (x1, y1) = lage[kante.a]!;
      final (x2, y2) = lage[kante.b]!;
      final leise = blass(kante.a) || blass(kante.b);
      g
        ..saveContext()
        ..setStrokeColor(kante.oeffentlich ? (leise ? FestStil.linieZart : FestStil.tinteLeise) : (leise ? _rotBlass : FestStil.stempelrot))
        ..setLineWidth(kante.oeffentlich ? 0.7 : 0.9);
      if (!kante.oeffentlich) g.setLineDashPattern([3.2, 2.2]);
      g
        ..drawLine(x1, groesse.y - y1, x2, groesse.y - y2)
        ..strokePath()
        ..restoreContext();
    }
  }

  pw.Widget knoten(String id, double d) {
    final m = s.medaillon(k.bild(id, klein: true), d, ring: k.farbe(id));
    return blass(id) ? pw.Opacity(opacity: 0.45, child: m) : m;
  }

  pw.Widget etikett(String id, pw.TextAlign ausrichtung) => pw.RichText(
        textAlign: ausrichtung,
        maxLines: 1,
        text: pw.TextSpan(children: [
          if (id != k.opfer) pw.TextSpan(text: '${k.platz(id)}  ', style: s.titel(9.5, FestStil.kerze)),
          pw.TextSpan(text: k.name(id), style: blass(id) ? s.kursiv(9.5, FestStil.tinteLeise) : s.titel(10)),
        ]),
      );

  final kinder = <pw.Widget>[
    pw.Positioned.fill(child: pw.CustomPaint(size: PdfPoint(breite, _ringHoehe), painter: maler)),
  ];
  for (final id in reihe) {
    final (x, y) = lage[id]!;
    final w = winkel[id]!;
    kinder.add(pw.Positioned(left: x - _knoten / 2, top: y - _knoten / 2, child: knoten(id, _knoten)));
    // Das Etikett sitzt außen neben dem Knoten: rechts und links auf seiner Höhe,
    // ganz oben darüber, ganz unten darunter.
    final sinus = math.sin(w);
    const abstand = _knoten / 2 + 4;
    if (sinus > 0.2) {
      kinder.add(pw.Positioned(left: x + abstand, top: y - 6.5, child: pw.SizedBox(width: _etikett, child: etikett(id, pw.TextAlign.left))));
    } else if (sinus < -0.2) {
      kinder.add(pw.Positioned(left: x - abstand - _etikett, top: y - 6.5, child: pw.SizedBox(width: _etikett, child: etikett(id, pw.TextAlign.right))));
    } else {
      final oben = math.cos(w) > 0;
      kinder.add(pw.Positioned(left: x - _etikett / 2, top: oben ? y - abstand - 11 : y + abstand - 2, child: pw.SizedBox(width: _etikett, child: etikett(id, pw.TextAlign.center))));
    }
  }
  kinder
    ..add(pw.Positioned(left: cx - _mitte / 2, top: cy - _mitte / 2, child: knoten(k.opfer, _mitte)))
    ..add(pw.Positioned(left: cx - _etikett / 2, top: cy + _mitte / 2 + 2, child: pw.SizedBox(width: _etikett, child: etikett(k.opfer, pw.TextAlign.center))));
  return pw.SizedBox(width: breite, height: _ringHoehe, child: pw.Stack(overflow: pw.Overflow.visible, children: kinder));
}

/// Was die Linien bedeuten: durchgezogen, gestrichelt, blass.
pw.Widget _linienLegende(ErzaehlerakteKontext k) {
  final s = k.stil;
  pw.Widget linie(PdfColor farbe, {bool gestrichelt = false}) => pw.CustomPaint(
        size: const PdfPoint(28, 8),
        painter: (g, p) {
          g
            ..setStrokeColor(farbe)
            ..setLineWidth(gestrichelt ? 0.9 : 0.7);
          if (gestrichelt) g.setLineDashPattern([3.2, 2.2]);
          g
            ..drawLine(0, p.y / 2, p.x, p.y / 2)
            ..strokePath();
        },
      );
  pw.Widget eintrag(pw.Widget zeichen, String text) => pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
        zeichen,
        pw.SizedBox(width: 5),
        pw.Text(text, style: s.text(9.5)),
      ]);
  return pw.Wrap(spacing: 18, runSpacing: 4, children: [
    eintrag(linie(FestStil.tinteLeise), k.ui('ui.druck.akte.netz.oeffentlich')),
    eintrag(linie(FestStil.stempelrot, gestrichelt: true), k.ui('ui.druck.akte.netz.heimlich')),
    eintrag(pw.Opacity(opacity: 0.45, child: s.medaillon(null, 10, ring: FestStil.linie)), k.ui('ui.druck.akte.ohne')),
  ]);
}

/// Nummerierte Legende: je Knoten Nummer, Name und Rolle und mit wem er
/// verbunden ist (heimliche Bindungen in Rot). Zugleich die Nachbarschaftstabelle,
/// falls der Ring auf dem Papier zu eng wird.
List<pw.Widget> _legende(ErzaehlerakteKontext k) {
  final s = k.stil;
  pw.Widget zelle(pw.Widget w) => pw.Padding(padding: const pw.EdgeInsets.fromLTRB(5, 3.5, 5, 3), child: w);
  pw.TableRow zeile(String knoten) {
    final mitte = knoten == k.opfer;
    final rolle = mitte ? k.akte.schneider.rolle : k.akte.figur(knoten)?.rolle;
    final kanten = k.akte.kantenVon(knoten);
    return pw.TableRow(verticalAlignment: pw.TableCellVerticalAlignment.top, children: [
      zelle(pw.Text(mitte ? '' : '${k.platz(knoten)}', style: s.titel(11, FestStil.kerze), textAlign: pw.TextAlign.right)),
      zelle(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(k.name(knoten), style: s.titel(11)),
        if (rolle != null && rolle.isNotEmpty) pw.Text(rolle, style: s.klein(7.5), maxLines: 2),
        if (!mitte && !k.istBesetzt(knoten)) pw.Text(k.ui('ui.druck.akte.ohne'), style: s.kursiv(8, FestStil.stempelrot)),
      ])),
      zelle(pw.RichText(
        text: pw.TextSpan(children: [
          for (final (i, x) in kanten.indexed)
            pw.TextSpan(
              text: '${i == 0 ? '' : ',  '}${k.ui(x.anderer(knoten) == k.opfer ? 'ui.druck.akte.legende.mitte' : 'ui.druck.akte.legende.eintrag', {'nr': '${k.platz(x.anderer(knoten))}', 'name': k.name(x.anderer(knoten)), 'art': k.ui('ui.druck.akte.art.${x.art}')})}',
              style: x.oeffentlich ? s.text(9.5) : s.kursiv(9.5, FestStil.stempelrot),
            ),
        ]),
      )),
    ]);
  }

  return [
    pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: FestStil.linieZart, width: 0.6),
        top: pw.BorderSide(color: FestStil.linie, width: 0.8),
        bottom: pw.BorderSide(color: FestStil.linie, width: 0.8),
      ),
      columnWidths: const {0: pw.FixedColumnWidth(24), 1: pw.FixedColumnWidth(118), 2: pw.FlexColumnWidth()},
      children: [
        pw.TableRow(decoration: const pw.BoxDecoration(color: FestStil.papierTief), children: [
          for (final t in [k.ui('ui.druck.akte.legende.nr'), k.ui('ui.druck.akte.legende.figur'), k.ui('ui.druck.akte.legende.bindungen')])
            zelle(pw.Text(t.toUpperCase(), style: s.marke(7.5))),
        ]),
        zeile(k.opfer),
        for (final id in k.besetzung.reihenfolge) zeile(id),
      ],
    ),
  ];
}

// ---------------------------------------------------------------- Figur

/// Größte und kleinste Textgröße der Figurenseiten (Lesetext nie unter [FestStil.minGroesse]).
const _figurGroesse = 10.5;

/// Eine Figur auf genau einer Seite: Die Textgröße sinkt von [_figurGroesse] in
/// Viertelpunkten bis [FestStil.minGroesse], bis alles passt. Passt es auch dann
/// nicht, läuft die Figur auf einer zweiten Seite weiter (nie ein Abschnitt halb).
void _figurSeite(pw.Document doc, ErzaehlerakteKontext k, ErzaehlerakteFigur f, pw.PageTheme theme) {
  final s = k.stil;
  final messung = s.neuesDokument('Messung');
  final ctx = pw.Context(document: messung.document).inheritFromAll([messung.theme!]);
  double hoehe(pw.Widget w, double breite) {
    w.layout(ctx, pw.BoxConstraints(maxWidth: breite), parentUsesSize: true);
    return w.box!.height;
  }

  for (var g = _figurGroesse; g >= FestStil.minGroesse - 1e-9; g -= 0.25) {
    final t = _figurTeile(k, f, g);
    final spalten = _verteilt([for (final w in t.kurz) hoehe(w, _spaltenBreite)]);
    final oben = hoehe(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: t.oben), FestStil.breite);
    if (oben + spalten.hoehe <= FestStil.hoehe) {
      final teile = [...t.oben, _zweiSpalten([for (final i in spalten.links) t.kurz[i]], [for (final i in spalten.rechts) t.kurz[i]])];
      doc.addPage(pw.Page(pageTheme: theme, build: (c) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: teile)));
      return;
    }
  }
  final t = _figurTeile(k, f, FestStil.minGroesse);
  doc.addPage(pw.MultiPage(pageTheme: theme, build: (c) => [...t.oben, ...s.zweispaltig(t.kurz, zeilenAbstand: 0)]));
}

const _spaltenAbstand = 16.0;
double get _spaltenBreite => (FestStil.breite - _spaltenAbstand) / 2;

/// Verteilt Abschnitte der Höhen [h] auf zwei Spalten, sodass die höhere Spalte
/// so niedrig wie möglich wird; in jeder Spalte bleibt die Reihenfolge, der
/// erste Abschnitt steht links. Bei Gleichstand gewinnt die erste Verteilung.
({List<int> links, List<int> rechts, double hoehe}) _verteilt(List<double> h) {
  var beste = 0;
  var besteHoehe = double.infinity;
  for (var maske = 0; maske < 1 << h.length; maske += 2) {
    var (l, r) = (0.0, 0.0);
    for (var i = 0; i < h.length; i++) {
      if (maske & (1 << i) == 0) {
        l += h[i];
      } else {
        r += h[i];
      }
    }
    final m = math.max(l, r);
    if (m < besteHoehe - 1e-6) {
      beste = maske;
      besteHoehe = m;
    }
  }
  return (
    links: [for (var i = 0; i < h.length; i++) if (beste & (1 << i) == 0) i],
    rechts: [for (var i = 0; i < h.length; i++) if (beste & (1 << i) != 0) i],
    hoehe: h.isEmpty ? 0 : besteHoehe,
  );
}

pw.Widget _zweiSpalten(List<pw.Widget> links, List<pw.Widget> rechts) {
  pw.Widget spalte(List<pw.Widget> l) => pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: l));
  return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [spalte(links), pw.SizedBox(width: _spaltenAbstand), spalte(rechts)]);
}

/// Die Teile einer Figurenseite in Textgröße [g]: oben Porträt (wenn vorhanden),
/// Name, Nummer, Rolle und Alter, Hintergrund und Bindungen; dazu die kurzen
/// Abschnitte für zwei Spalten (Zu Herrn Schneider, Motiv, Geheimnis,
/// Nebendelikt, Loyalität, Ziele, Stimme).
({List<pw.Widget> oben, List<pw.Widget> kurz}) _figurTeile(ErzaehlerakteKontext k, ErzaehlerakteFigur f, double g) {
  final s = k.stil;
  final farbe = k.farbe(f.figur);
  final bild = k.bild(f.figur);
  final besetzt = k.istBesetzt(f.figur);
  final unter = [f.rolle, if (f.alter case final n?) k.ui('ui.druck.fest.jahre', {'alter': '$n'})].join('  ·  ');
  final kopf = pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      if (bild != null) ...[
        pw.Padding(padding: const pw.EdgeInsets.only(left: 4, top: 4, bottom: 2), child: s.fotoabzug(bild, 80, neigung: -0.03, klebeband: false)),
        pw.SizedBox(width: 20),
      ],
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(k.ui(besetzt ? 'ui.druck.akte.besetzt' : 'ui.druck.akte.ohne').toUpperCase(), style: s.marke(9, besetzt ? FestStil.messing : FestStil.stempelrot)),
            pw.SizedBox(height: 1),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text(f.name, style: s.titel(30)),
              pw.SizedBox(width: 10),
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 6), child: pw.Text('${k.platz(f.figur)}', style: s.titel(14, FestStil.kerze))),
            ]),
            pw.Text(unter, style: s.kursiv(12, FestStil.tinteLeise)),
            if (f.vollerName case final v? when v != f.name) pw.Text(v, style: s.klein(8.5)),
          ],
        ),
      ),
    ],
  );

  final kanten = k.akte.kantenVon(f.figur);
  // Kurze Abschnitte und Bindungen einen halben Punkt kleiner als der Hintergrund.
  final klein = math.max(FestStil.minGroesse, g - 0.5);
  pw.Widget text(String t) => pw.Text(t, style: s.text(klein));
  return (
    oben: [
      kopf,
      pw.SizedBox(height: 10),
      _klein(k, k.ui('ui.druck.akte.hintergrund'), farbe, pw.Text(f.hintergrund, style: s.text(g)), unten: 8),
      if (kanten.isNotEmpty) ...[
        ...s.zweispaltig(
          [for (final x in kanten) _bindung(k, f.figur, x, klein)],
          zeilenAbstand: 4,
          kopf: _kopfzeile(k, k.ui('ui.druck.akte.bindungen'), farbe),
        ),
        pw.SizedBox(height: 4),
      ],
    ],
    kurz: [
      if (f.zuSchneider.isNotEmpty) _klein(k, k.ui('ui.druck.akte.zu_schneider'), farbe, text(f.zuSchneider)),
      if (f.motiv case final t? when t.isNotEmpty) _klein(k, k.ui('ui.druck.akte.motiv'), farbe, text(t)),
      if (f.geheimnis case final t? when t.isNotEmpty) _klein(k, k.ui('ui.druck.akte.geheimnis'), farbe, text(t)),
      if (f.nebendelikt case final t? when t.isNotEmpty) _klein(k, k.ui('ui.druck.akte.nebendelikt'), farbe, text(t)),
      if (f.loyalitaet case final l?)
        _klein(
          k,
          k.ui('ui.druck.akte.loyalitaet'),
          farbe,
          pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(text: k.ui('ui.druck.akte.loyalitaet.zu', {'name': k.name(l.zu)}), style: s.titel(klein + 0.5)),
              pw.TextSpan(text: '   ${l.grund}', style: s.text(klein)),
            ]),
          ),
        ),
      if (f.ziele.isNotEmpty) _klein(k, k.ui('ui.druck.akte.ziele'), farbe, s.punkte([for (final z in f.ziele) z.text], g: klein, abstand: 1.5)),
      if (f.stimme.isNotEmpty) _klein(k, k.ui('ui.druck.akte.stimme'), farbe, s.punkte(f.stimme, g: klein, abstand: 1.5)),
    ],
  );
}

/// Kleine Abschnittsüberschrift der Figurenseite.
pw.Widget _kopfzeile(ErzaehlerakteKontext k, String titel, PdfColor farbe) => k.stil.kopfzeile(titel, g: 12, farbe: farbe, abstand: 2);

/// Kurzer Abschnitt: kleine Überschrift, darunter der Inhalt.
pw.Widget _klein(ErzaehlerakteKontext k, String titel, PdfColor farbe, pw.Widget inhalt, {double unten = 6}) => pw.Padding(
      padding: pw.EdgeInsets.only(bottom: unten),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [_kopfzeile(k, titel, farbe), inhalt],
      ),
    );

/// Eine Bindung in Textgröße [g]: Medaillon des anderen, Name, Art und – bei
/// heimlichen – der Hinweis, dass nur der Erzähler sie kennt; dahinter der Text der Kante.
pw.Widget _bindung(ErzaehlerakteKontext k, String figur, NetzKante x, double g) {
  final s = k.stil;
  final anderer = x.anderer(figur);
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Padding(padding: const pw.EdgeInsets.only(top: 1), child: s.medaillon(k.bild(anderer, klein: true), 18, ring: k.farbe(anderer))),
      pw.SizedBox(width: 6),
      pw.Expanded(
        child: pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(text: k.name(anderer), style: s.titel(g + 0.5)),
            pw.TextSpan(text: '  ${k.ui('ui.druck.akte.art.${x.art}').toUpperCase()}', style: s.marke(7)),
            if (!x.oeffentlich) pw.TextSpan(text: '  ${k.ui('ui.druck.akte.netz.heimlich').toUpperCase()}', style: s.marke(7, FestStil.stempelrot)),
            pw.TextSpan(text: '  ${x.text}', style: s.text(g)),
          ]),
        ),
      ),
    ],
  );
}
