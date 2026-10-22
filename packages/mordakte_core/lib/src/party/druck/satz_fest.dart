import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Festlicher Satzstil des Druckpakets (Abend am Bildschirm): eine Ermittlungsmappe
/// auf hellem Aktenpapier. Playfair Display für Titel und Namen, Lora für den Lesetext,
/// Lora kursiv für Zitate, Special Elite für Formularköpfe und Stempel, Caveat für
/// Randnotizen, Inter nur für kleine Funktionstexte (DESIGN-ERMITTLUNGSMAPPE).
///
/// Neben [DruckStil] (Druckspiel, unverändert): Papierton, feiner Doppelrahmen mit
/// Eckzeichen, Kopf mit Siegel und Falltitel, Fuß mit Seitenzahl, Registerlasche in
/// der Figurenfarbe, Fotoabzüge mit Schatten und Klebestreifen. Alle Farben bleiben
/// im Schwarzweißdruck unterscheidbar; Text steht immer in dunkler Tinte.
/// Schriften kommen als Bytes herein, damit der Kern ohne `dart:io` bleibt.
class FestStil {
  FestStil({
    required Uint8List titel,
    required Uint8List text,
    required Uint8List kursiv,
    required Uint8List hand,
    required Uint8List maschine,
    required Uint8List funktion,
    required Uint8List funktionStark,
  })  : titelSchrift = _font(titel),
        textSchrift = _font(text),
        kursivSchrift = _font(kursiv),
        handSchrift = _font(hand),
        maschinenSchrift = _font(maschine),
        funktionSchrift = _font(funktion),
        funktionStarkSchrift = _font(funktionStark);

  static pw.Font _font(Uint8List b) => pw.Font.ttf(ByteData.sublistView(b));

  final pw.Font titelSchrift, textSchrift, kursivSchrift, handSchrift, maschinenSchrift, funktionSchrift, funktionStarkSchrift;

  // ------------------------------------------------------------------ Maße

  static const format = PdfPageFormat.a4;

  /// Abstand des Doppelrahmens vom Seitenrand (pt). Liegt innerhalb des Bereichs,
  /// den Bürodrucker sicher drucken.
  static const rahmen = 22.0;

  /// Satzspiegel: innerhalb von Kopf und Fuß.
  static const rand = pw.EdgeInsets.fromLTRB(56, 78, 56, 66);

  static double get breite => format.width - rand.left - rand.right;
  static double get hoehe => format.height - rand.top - rand.bottom;

  /// Kleinste Schriftgröße für Lesetext (gut lesbar, auch am Handy gezoomt).
  static const minGroesse = 9.5;

  // ------------------------------------------------------------------ Farben

  /// Helles Aktenpapier (druckfreundlich, kaum Tinte).
  static const papier = PdfColor.fromInt(0xFFFBF8F0);

  /// Etwas tieferes Papier für Kästen und Karten.
  static const papierTief = PdfColor.fromInt(0xFFF3ECDD);

  /// Karteikarte und Fotopapier.
  static const karte = PdfColor.fromInt(0xFFFFFDF8);
  static const tinte = PdfColor.fromInt(0xFF2A211B);
  static const tinteLeise = PdfColor.fromInt(0xFF65564A);
  static const linie = PdfColor.fromInt(0xFFB3A184);
  static const linieZart = PdfColor.fromInt(0xFFDCD0B8);
  static const stempelrot = PdfColor.fromInt(0xFFA3242F);
  static const messing = PdfColor.fromInt(0xFF9C7A3C);
  static const manila = PdfColor.fromInt(0xFFD9B979);

  /// Kerzenorange des Schlosskellers, für den Druck etwas abgedunkelt.
  static const kerze = PdfColor.fromInt(0xFFD9761A);

  /// Füllertinte für Randnotizen.
  static const fueller = PdfColor.fromInt(0xFF22385A);

  /// Lesbare Schriftfarbe auf [farbe] (Registerlasche, Farbstreifen).
  static PdfColor schriftAuf(PdfColor farbe) => farbe.luminance > 0.42 ? tinte : karte;

  // ------------------------------------------------------------------ Schriften

  pw.ThemeData get theme => pw.ThemeData.withFont(base: textSchrift, bold: textSchrift, italic: kursivSchrift, boldItalic: kursivSchrift);

  pw.TextStyle titel([double g = 30, PdfColor farbe = tinte]) => pw.TextStyle(font: titelSchrift, fontSize: g, color: farbe, lineSpacing: g * 0.05);
  pw.TextStyle text([double g = 11, PdfColor farbe = tinte]) => pw.TextStyle(font: textSchrift, fontSize: g, color: farbe, lineSpacing: g * 0.32);
  pw.TextStyle kursiv([double g = 11, PdfColor farbe = tinte]) => pw.TextStyle(font: kursivSchrift, fontSize: g, color: farbe, lineSpacing: g * 0.32);
  pw.TextStyle hand([double g = 16, PdfColor farbe = fueller]) => pw.TextStyle(font: handSchrift, fontSize: g, color: farbe, lineSpacing: g * 0.05);
  pw.TextStyle marke([double g = 9, PdfColor farbe = tinteLeise]) => pw.TextStyle(font: maschinenSchrift, fontSize: g, color: farbe, letterSpacing: g * 0.14);
  pw.TextStyle klein([double g = 8.5, PdfColor farbe = tinteLeise]) => pw.TextStyle(font: funktionSchrift, fontSize: g, color: farbe, lineSpacing: g * 0.25);
  pw.TextStyle kleinStark([double g = 8.5, PdfColor farbe = tinte]) => pw.TextStyle(font: funktionStarkSchrift, fontSize: g, color: farbe, letterSpacing: g * 0.04);

  // ------------------------------------------------------------------ Dokument

  pw.Document neuesDokument(String titel) => pw.Document(theme: theme, title: titel, author: 'Mordakte Partymodus', creator: 'Mordakte');

  /// Speichert [doc] reproduzierbar: Das pdf-Paket setzt Erstellungszeit und eine
  /// zufällige Dokumentkennung; beide werden durch feste Werte gleicher Länge ersetzt
  /// (Querverweise bleiben gültig). Gleicher Inhalt ⇒ gleiche Bytes.
  Future<Uint8List> speichern(pw.Document doc) async => festeBytes(await doc.save());

  // ------------------------------------------------------------------ Messen

  double hoeheVon(pw.Widget w, double breite) {
    final doc = neuesDokument('Messung');
    final ctx = pw.Context(document: doc.document).inheritFromAll([doc.theme!]);
    w.layout(ctx, pw.BoxConstraints(maxWidth: breite), parentUsesSize: true);
    return w.box!.height;
  }

  /// Natürliche Breite von [w] ohne Umbruch.
  double breiteVon(pw.Widget w) {
    final doc = neuesDokument('Messung');
    final ctx = pw.Context(document: doc.document).inheritFromAll([doc.theme!]);
    w.layout(ctx, const pw.BoxConstraints(), parentUsesSize: true);
    return w.box!.width;
  }

  /// Größte Größe ab [start] (in halben Punkten abwärts), bei der [text] in [stil]
  /// einzeilig in [breite] passt; nie unter [min].
  double einzeilig(String text, pw.TextStyle Function(double g) stil, double breite, {required double start, double min = 10}) {
    for (var g = start; g > min; g -= 0.5) {
      if (breiteVon(pw.Text(text, style: stil(g))) <= breite) return g;
    }
    return min;
  }

  /// Größte Größe bis [start], bei der jedes Wort von [text] in [breite] passt: Das
  /// pdf-Paket bricht zu lange Wörter sonst mitten im Wort um.
  double wortGroesse(String text, pw.TextStyle Function(double g) stil, double breite, {required double start}) {
    var breitestes = 0.0;
    for (final w in text.split(RegExp(r'\s+'))) {
      if (w.isNotEmpty) breitestes = math.max(breitestes, breiteVon(pw.Text(w, style: stil(start))));
    }
    if (breitestes <= breite) return start;
    return ((start * breite / breitestes) * 4).floorToDouble() / 4;
  }

  /// [kind] in einem Kasten fester Größe; passt es nicht hinein, ist das ein Fehler.
  pw.Widget kasten(pw.Widget kind, double breite, double hoehe, {required String wo}) {
    final h = hoeheVon(kind, breite);
    if (h > hoehe + 0.5) throw StateError('Überlauf: $wo ist ${h.toStringAsFixed(0)} pt hoch, Platz ist ${hoehe.toStringAsFixed(0)} pt');
    return pw.SizedBox(width: breite, height: hoehe, child: kind);
  }

  /// Größte Schriftgröße von [start] abwärts bis [minGroesse], bei der [bauen] in
  /// [breite] × [hoeheMax] passt; sonst ein [StateError] (Überlauf ist ein Fehler).
  double passendeGroesse(pw.Widget Function(double g) bauen, double breite, double hoeheMax, {double start = 12, String wo = ''}) {
    for (var g = start; g >= minGroesse - 1e-9; g -= 0.25) {
      if (hoeheVon(bauen(g), breite) <= hoeheMax) return g;
    }
    throw StateError('Überlauf: $wo (${hoeheVon(bauen(minGroesse), breite).toStringAsFixed(1)} pt hoch) passt auch in ${minGroesse}pt nicht in ${breite.toStringAsFixed(0)} × ${hoeheMax.toStringAsFixed(0)} pt');
  }

  /// Inhalt einer festen Seite als Spalte. Wird die Seite zu voll (ohne die
  /// [pw.Spacer]), ist das ein Fehler: Eine Seite schneidet sonst still ab.
  pw.Widget spalte(List<pw.Widget> kinder, {required String wo, pw.CrossAxisAlignment quer = pw.CrossAxisAlignment.stretch}) {
    final fest = [for (final w in kinder) if (w is! pw.Spacer) w];
    final h = hoeheVon(pw.Column(crossAxisAlignment: quer, children: fest), breite);
    if (h > hoehe + 0.5) throw StateError('Überlauf: $wo ist ${h.toStringAsFixed(0)} pt hoch, Platz ist ${hoehe.toStringAsFixed(0)} pt');
    return pw.Column(crossAxisAlignment: quer, children: kinder);
  }

  /// Inhalt einer festen Seite; der freie Platz darunter wird zu Notizlinien mit
  /// [marke], wenn mindestens zwei Linien passen.
  pw.Widget mitNotizen(List<pw.Widget> inhalt, {required String marke, required String wo}) {
    final belegt = hoeheVon(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: inhalt), breite);
    final frei = hoehe - belegt - 24;
    final zeilen = ((frei - 16) / 23).floor();
    return spalte(
      wo: wo,
      quer: pw.CrossAxisAlignment.start,
      [
        ...inhalt,
        if (zeilen >= 2) ...[
          pw.Spacer(),
          feldmarke(marke, farbe: tinteLeise),
          linien(zeilen, abstand: 23),
        ],
      ],
    );
  }

  /// Zwei Spalten: [eintraege] paarweise nebeneinander, jede Zeile untrennbar.
  /// Mit [kopf] bleibt die Überschrift mit der ersten Zeile zusammen.
  List<pw.Widget> zweispaltig(List<pw.Widget> eintraege, {double abstand = 16, double zeilenAbstand = 8, pw.Widget? kopf}) => [
        if (eintraege.isEmpty && kopf != null) kopf,
        for (var i = 0; i < eintraege.length; i += 2)
          pw.Inseparable(
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
              if (i == 0 && kopf != null) kopf,
              pw.Padding(
                padding: pw.EdgeInsets.only(bottom: zeilenAbstand),
                child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Expanded(child: eintraege[i]),
                  pw.SizedBox(width: abstand),
                  pw.Expanded(child: i + 1 < eintraege.length ? eintraege[i + 1] : pw.SizedBox()),
                ]),
              ),
            ]),
          ),
      ];

  // ------------------------------------------------------------------ Seite

  /// Seitenrahmen einer Datei: Papier, Doppelrahmen mit Eckzeichen, Kopf (Siegel,
  /// [falltitel], rechts [marke]), Fuß ([fuss] links, Seitenzahl rechts) und, mit
  /// [lasche], die Registerlasche in der Figurenfarbe mit [laschenText].
  pw.PageTheme seite({
    required String falltitel,
    required String marke,
    required String fuss,
    String Function(int nr, int von)? seitenzahl,
    PdfColor? lasche,
    String? laschenText,
    PdfColor markeFarbe = stempelrot,
    pw.EdgeInsets? innen,
  }) =>
      pw.PageTheme(
        pageFormat: format,
        margin: innen ?? rand,
        theme: theme,
        buildBackground: (c) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(children: [
            pw.Positioned.fill(child: pw.Container(color: papier)),
            pw.Positioned.fill(child: pw.CustomPaint(painter: _rahmenMaler)),
            if (lasche != null) _lasche(lasche, laschenText ?? ''),
            pw.Positioned(
              left: rand.left,
              right: rand.right,
              top: rahmen + 14,
              child: _kopf(falltitel, marke, markeFarbe),
            ),
            pw.Positioned(
              left: rand.left,
              right: rand.right,
              bottom: rahmen + 12,
              child: _fuss(fuss, seitenzahl == null ? null : seitenzahl(c.pageNumber, c.pagesCount)),
            ),
          ]),
        ),
      );

  static void _rahmenMaler(PdfGraphics g, PdfPoint s) {
    const a = rahmen;
    g
      ..setStrokeColor(linie)
      ..setLineWidth(0.9)
      ..drawRect(a, a, s.x - 2 * a, s.y - 2 * a)
      ..strokePath()
      ..setLineWidth(0.35)
      ..drawRect(a + 3.5, a + 3.5, s.x - 2 * a - 7, s.y - 2 * a - 7)
      ..strokePath();
    // Eckzeichen: kleine Raute mit zwei Strichen an jeder Ecke.
    for (final (x, y, sx, sy) in [(a, a, 1.0, 1.0), (s.x - a, a, -1.0, 1.0), (a, s.y - a, 1.0, -1.0), (s.x - a, s.y - a, -1.0, -1.0)]) {
      g
        ..setFillColor(messing)
        ..moveTo(x + sx * 9, y + sy * 3.5)
        ..lineTo(x + sx * 12.5, y + sy * 7)
        ..lineTo(x + sx * 9, y + sy * 10.5)
        ..lineTo(x + sx * 5.5, y + sy * 7)
        ..closePath()
        ..fillPath()
        ..setStrokeColor(messing)
        ..setLineWidth(0.6)
        ..moveTo(x + sx * 15, y + sy * 7)
        ..lineTo(x + sx * 34, y + sy * 7)
        ..moveTo(x + sx * 9, y + sy * 13)
        ..lineTo(x + sx * 9, y + sy * 32)
        ..strokePath();
    }
  }

  pw.Widget _kopf(String falltitel, String marke, PdfColor markeFarbe) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              siegel(22),
              pw.SizedBox(width: 8),
              pw.Text(falltitel.toUpperCase(), style: this.marke(8.5, tinte)),
              pw.Spacer(),
              pw.Text(marke.toUpperCase(), style: this.marke(8.5, markeFarbe)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Container(height: 0.5, color: linie),
        ],
      );

  pw.Widget _fuss(String links, String? rechts) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(height: 0.5, color: linie),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Expanded(child: pw.Text(links, style: klein(8))),
              raute(4, messing),
              pw.Expanded(child: pw.Text(rechts ?? '', style: klein(8), textAlign: pw.TextAlign.right)),
            ],
          ),
        ],
      );

  /// Registerlasche am rechten Rand: ein Reiter in der Figurenfarbe, der über den
  /// Rahmen hinausragt, mit dem Namen quer.
  pw.Widget _lasche(PdfColor farbe, String text) => pw.Positioned(
        right: rahmen - 9,
        top: 118,
        child: pw.Container(
          width: 24,
          height: 132,
          decoration: pw.BoxDecoration(
            color: farbe,
            border: pw.Border.all(color: tinte, width: 0.5),
            borderRadius: const pw.BorderRadius.horizontal(right: pw.Radius.circular(5)),
          ),
          child: pw.Center(
            child: pw.Transform.rotateBox(
              angle: -math.pi / 2,
              unconstrained: true,
              child: pw.Text(text.toUpperCase(), style: marke(9.5, schriftAuf(farbe)), maxLines: 1),
            ),
          ),
        ),
      );

  // ------------------------------------------------------------------ Zeichen

  /// Siegel „SK“ (Kürzel der Akte, wie im Spiel): mit [wachs] ein gewelltes rotes
  /// Lacksiegel, sonst ein feiner Stempelring.
  pw.Widget siegel(double d, {bool wachs = false, String kuerzel = 'SK'}) => pw.SizedBox(
        width: d,
        height: d,
        child: pw.Stack(
          alignment: pw.Alignment.center,
          children: [
            pw.CustomPaint(size: PdfPoint(d, d), painter: (g, s) => wachs ? _wachs(g, s) : _ring(g, s)),
            pw.Padding(
              padding: pw.EdgeInsets.only(top: d * 0.05),
              child: pw.Text(kuerzel, style: titel(d * (wachs ? 0.34 : 0.4), wachs ? karte : stempelrot)),
            ),
          ],
        ),
      );

  static void _ring(PdfGraphics g, PdfPoint s) {
    final r = s.x / 2;
    g
      ..setStrokeColor(stempelrot)
      ..setLineWidth(math.max(0.6, r * 0.09))
      ..drawEllipse(r, r, r * 0.94, r * 0.94)
      ..strokePath()
      ..setLineWidth(math.max(0.3, r * 0.035))
      ..drawEllipse(r, r, r * 0.76, r * 0.76)
      ..strokePath();
  }

  static void _wachs(PdfGraphics g, PdfPoint s) {
    final r = s.x / 2;
    const zacken = 22;
    g.setFillColor(stempelrot);
    for (var i = 0; i <= zacken * 4; i++) {
      final w = i / (zacken * 4) * 2 * math.pi;
      final rr = r * (0.93 + 0.07 * math.cos(w * zacken));
      final x = r + rr * math.cos(w), y = r + rr * math.sin(w);
      i == 0 ? g.moveTo(x, y) : g.lineTo(x, y);
    }
    g
      ..closePath()
      ..fillPath()
      ..setStrokeColor(const PdfColor.fromInt(0xFF7A1820))
      ..setLineWidth(r * 0.05)
      ..drawEllipse(r, r, r * 0.7, r * 0.7)
      ..strokePath()
      ..setStrokeColor(const PdfColor.fromInt(0xFFC4505A))
      ..setLineWidth(r * 0.025)
      ..drawEllipse(r - r * 0.02, r + r * 0.02, r * 0.66, r * 0.66)
      ..strokePath();
  }

  /// Kleine Raute als Aufzählungs- oder Trennzeichen.
  pw.Widget raute(double d, PdfColor farbe) => pw.CustomPaint(
        size: PdfPoint(d * 1.6, d * 1.6),
        painter: (g, s) => g
          ..setFillColor(farbe)
          ..moveTo(s.x / 2, s.y / 2 - d / 2)
          ..lineTo(s.x / 2 + d / 2, s.y / 2)
          ..lineTo(s.x / 2, s.y / 2 + d / 2)
          ..lineTo(s.x / 2 - d / 2, s.y / 2)
          ..closePath()
          ..fillPath(),
      );

  /// Zierlinie: Strich, Raute, Strich.
  pw.Widget zierlinie(double breite, {PdfColor farbe = linie}) => pw.SizedBox(
        width: breite,
        child: pw.Row(children: [
          pw.Expanded(child: pw.Container(height: 0.5, color: farbe)),
          pw.SizedBox(width: 6),
          raute(5, messing),
          pw.SizedBox(width: 6),
          pw.Expanded(child: pw.Container(height: 0.5, color: farbe)),
        ]),
      );

  /// Stempel: doppelt gerahmter Text in Stempelrot, leicht schräg.
  pw.Widget stempel(String text, {double g = 12, double neigung = -0.06, PdfColor farbe = stempelrot}) => pw.Transform.rotate(
        angle: neigung,
        child: pw.Opacity(
          opacity: 0.9,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(2.2),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: farbe, width: 1.6), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
            child: pw.Container(
              padding: pw.EdgeInsets.symmetric(horizontal: g * 0.8, vertical: g * 0.45),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: farbe, width: 0.6), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2))),
              child: pw.Text(text.toUpperCase(), style: marke(g, farbe), textAlign: pw.TextAlign.center),
            ),
          ),
        ),
      );

  /// Überschrift eines Abschnitts: Raute in [farbe], Titel in Playfair, feine Linie bis zum Rand.
  pw.Widget kopfzeile(String titel, {double g = 16, PdfColor farbe = kerze, double abstand = 6}) => pw.Padding(
        padding: pw.EdgeInsets.only(bottom: abstand),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            raute(g * 0.36, farbe),
            pw.SizedBox(width: 5),
            pw.Text(titel, style: this.titel(g)),
            pw.SizedBox(width: 8),
            pw.Expanded(child: pw.Container(height: 0.5, color: linie)),
          ],
        ),
      );

  /// Kleine Marke über einem Feld (Formularkopf).
  pw.Widget feldmarke(String text, {PdfColor farbe = tinteLeise, double g = 8.5}) =>
      pw.Padding(padding: const pw.EdgeInsets.only(bottom: 2.5), child: pw.Text(text.toUpperCase(), style: marke(g, farbe)));

  /// Stichpunkte mit Rauten in [farbe].
  pw.Widget punkte(List<String> zeilen, {double g = 11, PdfColor farbe = kerze, pw.TextStyle? stil, double abstand = 3}) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final z in zeilen)
            pw.Padding(
              padding: pw.EdgeInsets.only(bottom: abstand),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.28, right: g * 0.45), child: raute(g * 0.36, farbe)),
                  pw.Expanded(child: pw.Text(z, style: stil ?? text(g))),
                ],
              ),
            ),
        ],
      );

  /// Karteikarte: helles Papier, feiner Rand, oben ein Streifen in [farbe].
  pw.Widget karteikarte(pw.Widget kind, {PdfColor? farbe, double? breite, double? hoehe, pw.EdgeInsets innen = const pw.EdgeInsets.fromLTRB(12, 10, 12, 10)}) =>
      pw.Container(
        width: breite,
        height: hoehe,
        decoration: pw.BoxDecoration(
          color: karte,
          border: pw.Border.all(color: linieZart, width: 0.7),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2.5)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (farbe != null) pw.Container(height: 4, decoration: pw.BoxDecoration(color: farbe, border: pw.Border(bottom: pw.BorderSide(color: tinte, width: 0.3)))),
            pw.Padding(padding: innen, child: kind),
          ],
        ),
      );

  /// Getöntes Feld (für Vorlesetexte und Hinweise) mit Strich links in [farbe].
  pw.Widget feld(pw.Widget kind, {PdfColor farbe = kerze, PdfColor grund = papierTief, pw.EdgeInsets innen = const pw.EdgeInsets.fromLTRB(12, 8, 12, 8)}) => pw.Container(
        decoration: pw.BoxDecoration(color: grund, border: pw.Border(left: pw.BorderSide(color: farbe, width: 2.2))),
        padding: innen,
        child: kind,
      );

  /// Zitat: zentriert in Lora kursiv mit deutschen Anführungszeichen, darunter eine Zierlinie.
  pw.Widget zitat(String satz, {double g = 16, double breite = 300}) => pw.Column(
        children: [
          pw.Text('„$satz“', style: kursiv(g), textAlign: pw.TextAlign.center),
          pw.SizedBox(height: g * 0.5),
          zierlinie(breite * 0.4),
        ],
      );

  /// Kästchen zum Ankreuzen.
  pw.Widget kaestchen([double d = 10]) => pw.Container(
        width: d,
        height: d,
        decoration: pw.BoxDecoration(color: karte, border: pw.Border.all(color: tinte, width: 0.8)),
      );

  /// Schreiblinien für Notizen, [anzahl] im Abstand [abstand].
  pw.Widget linien(int anzahl, {double abstand = 24}) => pw.Column(
        children: [
          for (var i = 0; i < anzahl; i++)
            pw.Container(
              height: abstand,
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: linieZart, width: 0.6))),
            ),
        ],
      );

  // ------------------------------------------------------------------ Fotoabzug

  /// Fotoabzug eines Porträts: weißer Rand, weicher Schatten, leicht schräg
  /// ([neigung] im Bogenmaß), oben zwei Klebestreifen; mit [beschriftung] eine
  /// Zeile in Handschrift. Ohne [bild] ein ruhiger Schattenriss als Platzhalter.
  pw.Widget fotoabzug(pw.ImageProvider? bild, double breite, {double neigung = 0, String? beschriftung, bool klebeband = true, double? handGroesse}) {
    final rahmenBreite = breite * 0.045;
    final innen = breite - 2 * rahmenBreite;
    final unten = beschriftung == null ? rahmenBreite : rahmenBreite + (handGroesse ?? breite * 0.1) * 1.25;
    final abzug = pw.Container(
      width: breite,
      padding: pw.EdgeInsets.fromLTRB(rahmenBreite, rahmenBreite, rahmenBreite, unten),
      decoration: pw.BoxDecoration(
        color: karte,
        border: pw.Border.all(color: linieZart, width: 0.5),
        boxShadow: [pw.BoxShadow(color: const PdfColor(0.16, 0.12, 0.08, 0.32), blurRadius: breite * 0.035, offset: PdfPoint(breite * 0.012, breite * 0.02))],
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            width: innen,
            height: innen,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: const PdfColor(0.1, 0.08, 0.06, 0.35), width: 0.4)),
            child: bild == null ? platzhalter(innen) : pw.Image(bild, width: innen, height: innen, fit: pw.BoxFit.cover),
          ),
          if (beschriftung != null)
            pw.Padding(
              padding: pw.EdgeInsets.only(top: rahmenBreite * 0.4),
              child: pw.Text(beschriftung, style: hand(handGroesse ?? breite * 0.1), maxLines: 1),
            ),
        ],
      ),
    );
    final band = breite * 0.3;
    final mitBand = !klebeband
        ? abzug
        : pw.Stack(
            overflow: pw.Overflow.visible,
            children: [
              abzug,
              pw.Positioned(left: -band * 0.22, top: -band * 0.05, child: _klebestreifen(band, 0.65)),
              pw.Positioned(right: -band * 0.22, top: -band * 0.05, child: _klebestreifen(band, -0.65)),
            ],
          );
    return neigung == 0 ? mitBand : pw.Transform.rotate(angle: neigung, child: mitBand);
  }

  pw.Widget _klebestreifen(double laenge, double winkel) => pw.Transform.rotate(
        angle: winkel,
        child: pw.Opacity(
          opacity: 0.72,
          child: pw.Container(
            width: laenge,
            height: laenge * 0.3,
            decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0xFFE8DCC0), border: pw.Border.all(color: const PdfColor.fromInt(0xFFCDBB94), width: 0.3)),
          ),
        ),
      );

  /// Schattenriss (Kopf und Schultern) auf hellem Grund, wenn kein Porträt vorliegt.
  pw.Widget platzhalter(double d) => pw.CustomPaint(
        size: PdfPoint(d, d),
        painter: (g, s) {
          g
            ..setFillColor(papierTief)
            ..drawRect(0, 0, s.x, s.y)
            ..fillPath()
            ..setFillColor(linie)
            ..drawEllipse(s.x / 2, s.y * 0.58, s.x * 0.17, s.y * 0.2)
            ..fillPath()
            ..moveTo(s.x * 0.14, 0)
            ..curveTo(s.x * 0.16, s.y * 0.26, s.x * 0.3, s.y * 0.33, s.x / 2, s.y * 0.34)
            ..curveTo(s.x * 0.7, s.y * 0.33, s.x * 0.84, s.y * 0.26, s.x * 0.86, 0)
            ..closePath()
            ..fillPath();
        },
      );

  /// Kleines rundes Porträt (Medaillon) für Listen und Karten.
  pw.Widget medaillon(pw.ImageProvider? bild, double d, {PdfColor? ring}) => pw.Container(
        width: d,
        height: d,
        decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(color: ring ?? linie, width: 1.2), color: karte),
        child: pw.ClipOval(child: bild == null ? platzhalter(d) : pw.Image(bild, width: d, height: d, fit: pw.BoxFit.cover)),
      );
}

/// Ersetzt in einer vom pdf-Paket gespeicherten Datei Erstellungszeit und
/// Dokumentkennung durch feste Werte gleicher Länge. Die Kennung wird aus dem Inhalt
/// abgeleitet (SHA-256), damit verschiedene Dateien verschiedene Kennungen tragen.
Uint8List festeBytes(Uint8List bytes) {
  final s = latin1.decode(bytes);
  var t = s.replaceAllMapped(RegExp(r'/CreationDate\s*\((D:[^)]*)\)'), (m) {
    final alt = m.group(1)!;
    const fest = "D:20261031180000Z00'00'";
    final neu = fest.length >= alt.length ? fest.substring(0, alt.length) : fest.padRight(alt.length, '0');
    return m.group(0)!.replaceFirst(alt, neu);
  });
  final id = RegExp(r'/ID\s*\[<([0-9a-fA-F]+)><([0-9a-fA-F]+)>\]');
  String mitId(String text, String Function(int laenge) wert) =>
      text.replaceAllMapped(id, (m) => '/ID[<${wert(m.group(1)!.length)}><${wert(m.group(2)!.length)}>]'.padRight(m.group(0)!.length));
  final kennung = sha256.convert(latin1.encode(mitId(t, (n) => '0' * n))).toString();
  t = mitId(t, (n) => (kennung * (n ~/ kennung.length + 1)).substring(0, n));
  final out = Uint8List.fromList(latin1.encode(t));
  assert(out.length == bytes.length);
  return out;
}
