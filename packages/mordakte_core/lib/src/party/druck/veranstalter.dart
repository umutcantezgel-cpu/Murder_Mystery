import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../besetzung.dart';
import '../einstimmung.dart';
import '../fassung.dart';
import 'fest_steckbrief.dart';
import 'paket.dart';
import 'satz.dart';
import 'satz_fest.dart';

// Veranstalter-Blatt (Druckpaket, Ordner 2): für die Person, die einlädt. Spoilerfrei:
// Begrüßung, Fall-Code mit Anleitung, Besetzung bei n Personen, Ablauf mit
// ca.-Minuten für den kurzen und den langen Abend (K-18, fassung.dart; mit Einstimmung
// A-063 auch Vorgeschichte und Vorstellung), Gästeliste zum Ausfüllen, Checkliste und
// welche Datei an wen geht (mit Erzählerakte auch sie). Texte: `ui.druck.paket.*`.

/// Das Veranstalter-Blatt als Datei (`veranstalter.pdf`), drei Seiten.
Future<DruckDatei> veranstalterDatei(PaketKontext k) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.paket.datei')}');
  veranstalterBlatt(doc, k);
  return DruckDatei('veranstalter.pdf', await k.stil.speichern(doc));
}

void veranstalterBlatt(pw.Document doc, PaketKontext k) {
  final theme = k.stil.seite(
    falltitel: k.fallTitel,
    marke: k.ui('ui.druck.paket.datei'),
    // Nicht „darf jeder lesen“: Das Blatt trägt den Fall-Code und bleibt bei denen, die einladen.
    fuss: k.ui('ui.druck.paket.fuss'),
    seitenzahl: k.seite,
  );
  doc
    ..addPage(pw.Page(pageTheme: theme, build: (c) => _seite1(k)))
    ..addPage(pw.Page(pageTheme: theme, build: (c) => _seite2(k)))
    ..addPage(pw.Page(pageTheme: theme, build: (c) => _seite3(k)));
}

// ---------------------------------------------------------------- Seite 1

pw.Widget _seite1(PaketKontext k) {
  final s = k.stil;
  return s.spalte(
    wo: 'Veranstalter-Blatt Seite 1',
    [
      pw.Text(k.ui('ui.druck.paket.marke').toUpperCase(), style: s.marke(10, FestStil.stempelrot)),
      pw.SizedBox(height: 4),
      pw.Text(k.ui('ui.druck.paket.titel'), style: s.titel(34)),
      pw.Text('${k.fallTitel} · ${k.untertitel}', style: s.kursiv(13, FestStil.tinteLeise)),
      pw.SizedBox(height: 10),
      pw.Text(k.ui('ui.druck.paket.willkommen'), style: s.text(12)),
      pw.SizedBox(height: 18),
      _codeKarte(k),
      pw.SizedBox(height: 20),
      s.kopfzeile(k.ui('ui.druck.paket.besetzung.titel', {'anzahl': '${k.rollen}'}), g: 17),
      pw.SizedBox(height: 2),
      _besetzung(k),
      pw.Spacer(),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          s.fotoabzug(k.bild(Besetzung.detektiv, detektiv: 'w', klein: true), 52, neigung: -0.05, klebeband: false),
          pw.SizedBox(width: 4),
          s.fotoabzug(k.bild(Besetzung.detektiv, detektiv: 'm', klein: true), 52, neigung: 0.04, klebeband: false),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(k.ui('ui.druck.paket.besetzung.hinweis'), style: s.kursiv(11)),
              pw.SizedBox(height: 3),
              pw.Text(k.ui('ui.druck.paket.dateien.detektiv'), style: s.text(10, FestStil.tinteLeise)),
            ]),
          ),
        ],
      ),
    ],
  );
}

/// Der Fall-Code groß, je Zeichen ein Kästchen, mit Anleitung und Lacksiegel.
pw.Widget _codeKarte(PaketKontext k) {
  final s = k.stil;
  return pw.Stack(
    overflow: pw.Overflow.visible,
    children: [
      s.karteikarte(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                s.feldmarke(k.ui('ui.druck.paket.code.titel'), farbe: FestStil.stempelrot, g: 10),
                pw.SizedBox(height: 4),
                pw.Row(children: [
                  for (final z in k.code.split(''))
                    pw.Container(
                      width: 40,
                      height: 50,
                      margin: const pw.EdgeInsets.only(right: 6),
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        color: FestStil.papier,
                        border: pw.Border.all(color: FestStil.tinte, width: 1),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                      ),
                      child: pw.Text(z, style: s.marke(30, FestStil.tinte).copyWith(letterSpacing: 0)),
                    ),
                ]),
              ],
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(k.ui('ui.druck.paket.code.anleitung'), style: s.text(11.5)),
                  pw.SizedBox(height: 4),
                  pw.Text(k.ui('ui.druck.paket.code.schritt'), style: s.text(11)),
                  pw.SizedBox(height: 4),
                  pw.Text(k.ui('ui.druck.paket.code.neutral'), style: s.kursiv(10, FestStil.tinteLeise)),
                ],
              ),
            ),
          ],
        ),
        farbe: FestStil.kerze,
        innen: const pw.EdgeInsets.fromLTRB(18, 14, 26, 16),
      ),
      pw.Positioned(right: -18, top: -22, child: s.siegel(54, wachs: true)),
    ],
  );
}

/// Besetzung: je Figur ein kleines Porträt mit Name und Rolle, vier je Reihe.
pw.Widget _besetzung(PaketKontext k) {
  final s = k.stil;
  final ids = k.figurenAlphabetisch;
  const spalten = 3;
  pw.Widget figur(String id) {
    final f = festFigur(k, id);
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
      s.medaillon(k.bild(id, klein: true), 44, ring: k.farbe(id)),
      pw.SizedBox(width: 6),
      pw.Expanded(
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(f.name, style: s.titel(14)),
          pw.Text(f.titel, style: s.klein(8)),
        ]),
      ),
    ]);
  }

  return pw.Column(children: [
    for (var i = 0; i < ids.length; i += spalten)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 14),
        child: pw.Row(children: [
          for (var j = i; j < i + spalten; j++) ...[
            if (j > i) pw.SizedBox(width: 8),
            pw.Expanded(child: j < ids.length ? figur(ids[j]) : pw.SizedBox()),
          ],
        ]),
      ),
  ]);
}

// ---------------------------------------------------------------- Seite 2

/// Seite 2: Ablauf und Checkliste. Passt sie nicht (mit Einstimmung zwei Schritte
/// mehr), steht in jeder Zeile des Ablaufs die Erklärung gleich hinter dem Schritt.
pw.Widget _seite2(PaketKontext k) {
  final s = k.stil;
  List<pw.Widget> teile({required bool eng}) {
    pw.Widget punkt(String c) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(children: [
            s.kaestchen(11),
            pw.SizedBox(width: 10),
            pw.Expanded(child: pw.Text(k.ui('ui.druck.paket.check.$c'), style: s.text(11))),
          ]),
        );
    final punkte = [for (final c in ['handys', 'drucke', 'umschlaege', if (k.erzaehlerakte == null) 'erzaehler' else 'erzaehler.akte', 'stifte', 'kostueme', 'ecke']) punkt(c)];
    return [
      pw.Text(k.ui('ui.druck.paket.ablauf.titel'), style: s.titel(28)),
      pw.SizedBox(height: 3),
      pw.Container(height: 0.5, color: FestStil.linie),
      pw.SizedBox(height: 10),
      _ablauf(k, eng: eng),
      pw.SizedBox(height: 6),
      pw.Text(k.ui('ui.druck.paket.ablauf.fussnote'), style: s.klein(8)),
      pw.SizedBox(height: 4),
      pw.Text(k.ui('ui.druck.paket.fassung.hinweis'), style: s.kursiv(10.5, FestStil.tinteLeise)),
      pw.Spacer(),
      s.kopfzeile(k.ui('ui.druck.paket.check.titel'), g: 17),
      ...punkte,
    ];
  }

  final weit = teile(eng: false);
  final passt = s.hoeheVon(pw.Column(children: [for (final w in weit) if (w is! pw.Spacer) w]), FestStil.breite) <= FestStil.hoehe + 0.5;
  return s.spalte(wo: 'Veranstalter-Blatt Seite 2', passt ? weit : teile(eng: true));
}

/// Ablauf als Tabelle: Schritt, was passiert, ca. Minuten kurz und lang (K-18).
/// Mit Einstimmung (A-063) folgen auf das Rollenlesen Vorgeschichte und
/// Vorstellung; die Summe zählt sie mit. Mit [eng] stehen die Zeilen dichter.
pw.Widget _ablauf(PaketKontext k, {bool eng = false}) {
  final s = k.stil;
  final mk = Abendfassung.kurz.standardMinuten, ml = Abendfassung.lang.standardMinuten;
  final einstimmung = Einstimmung.aus(k.kanon);
  final vorstellung = abendEinstimmungMinuten(k.rollen) - abendVorgeschichteMinuten;
  final rundeKurz = (mk + abendGeraetMinuten + abendWahlMinuten + abendResuemeeMinuten).round();
  final rundeLang = (ml + abendWahlMinuten + abendResuemeeMinuten).round();
  String min(num m) => '${m.round()}';
  final runden = (k.ui('ui.druck.paket.ablauf.runden_zeile', {'minuten': '$rundeKurz'}), k.ui('ui.druck.paket.ablauf.runden_zeile', {'minuten': '$rundeLang'}));
  final schritte = <(String, String?, String?)>[
    ('einrichtung', min(abendEinrichtungMinuten), min(abendEinrichtungMinuten)),
    ('figuren', null, null),
    ('rollen', null, null),
    if (einstimmung != null) ...[
      ('vorgeschichte', min(abendVorgeschichteMinuten), min(abendVorgeschichteMinuten)),
      if (einstimmung.vorstellung) ('vorstellung', min(vorstellung), min(vorstellung)),
    ],
    ('vorspiel', null, min(abendVorspielMinuten)),
    ('einleitung', min(abendIntroMinuten), min(abendIntroMinuten)),
    ('runden', runden.$1, runden.$2),
    ('aufloesung', min(abendFinaleMinuten), min(abendFinaleMinuten)),
    ('morgen', null, min(abendMorgenMinuten)),
  ];
  pw.Widget kopf(String t, {bool rechts = false}) => pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(6, 5, 6, 5),
        child: pw.Text(t.toUpperCase(), style: s.marke(8), textAlign: rechts ? pw.TextAlign.right : pw.TextAlign.left),
      );
  pw.Widget zahl(String? t, {bool stark = false}) => pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(6, 5, 6, 4),
        child: pw.Text(t ?? '–', style: stark ? s.titel(11.5) : s.text(11, t == null ? FestStil.linie : FestStil.tinte), textAlign: pw.TextAlign.right, maxLines: 1),
      );
  return pw.Table(
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: FestStil.linieZart, width: 0.6),
      top: pw.BorderSide(color: FestStil.linie, width: 0.8),
      bottom: pw.BorderSide(color: FestStil.linie, width: 0.8),
    ),
    columnWidths: const {0: pw.FixedColumnWidth(24), 1: pw.FlexColumnWidth(), 2: pw.FixedColumnWidth(82), 3: pw.FixedColumnWidth(82)},
    children: [
      pw.TableRow(decoration: const pw.BoxDecoration(color: FestStil.papierTief), children: [
        kopf(''),
        kopf(k.ui('ui.druck.paket.ablauf.schritt')),
        kopf(k.ui('ui.druck.paket.fassung.kurz'), rechts: true),
        kopf(k.ui('ui.druck.paket.fassung.lang'), rechts: true),
      ]),
      for (final (i, (id, kurz, lang)) in schritte.indexed)
        pw.TableRow(verticalAlignment: pw.TableCellVerticalAlignment.top, children: [
          pw.Padding(padding: const pw.EdgeInsets.fromLTRB(4, 4, 0, 3), child: pw.Text('${i + 1}', style: s.titel(14, FestStil.kerze))),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(6, 4, 6, 4),
            // Eng: Schritt und Erklärung in einem Absatz.
            child: eng
                ? pw.RichText(
                    text: pw.TextSpan(children: [
                      pw.TextSpan(text: k.ui('ui.druck.paket.ablauf.$id'), style: s.titel(12)),
                      pw.TextSpan(text: '   ${k.ui('ui.druck.paket.ablauf.$id.text')}', style: s.text(9.5).copyWith(lineSpacing: 1.5)),
                    ]),
                  )
                : pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(k.ui('ui.druck.paket.ablauf.$id'), style: s.titel(12.5)),
                    pw.Text(k.ui('ui.druck.paket.ablauf.$id.text'), style: s.text(9.5).copyWith(lineSpacing: 1.5)),
                  ]),
          ),
          zahl(kurz),
          zahl(lang),
        ]),
      pw.TableRow(decoration: const pw.BoxDecoration(color: FestStil.papierTief), children: [
        pw.SizedBox(),
        pw.Padding(padding: const pw.EdgeInsets.fromLTRB(6, 7, 6, 5), child: pw.Text(k.ui('ui.druck.paket.ablauf.gesamt'), style: s.titel(13))),
        zahl(k.ui('ui.druck.paket.ablauf.ca', {'minuten': '${abendMinutenCa(Abendfassung.kurz, mk, einstimmungRollen: einstimmung == null ? null : k.rollen)}'}), stark: true),
        zahl(k.ui('ui.druck.paket.ablauf.ca', {'minuten': '${abendMinutenCa(Abendfassung.lang, ml, einstimmungRollen: einstimmung == null ? null : k.rollen)}'}), stark: true),
      ]),
    ],
  );
}

// ---------------------------------------------------------------- Seite 3

pw.Widget _seite3(PaketKontext k) {
  final s = k.stil;
  return s.spalte(
    wo: 'Veranstalter-Blatt Seite 3',
    [
      pw.Text(k.ui('ui.druck.paket.gaeste.titel'), style: s.titel(28)),
      pw.SizedBox(height: 3),
      pw.Container(height: 0.5, color: FestStil.linie),
      pw.SizedBox(height: 6),
      pw.Text(k.ui('ui.druck.paket.gaeste.hinweis'), style: s.kursiv(11, FestStil.tinteLeise)),
      pw.SizedBox(height: 8),
      _gaesteliste(k),
      pw.Spacer(),
      s.kopfzeile(k.ui('ui.druck.paket.dateien.titel'), g: 17),
      for (final n in [1, 2, 3, 4]) _ordner(k, n),
      pw.SizedBox(height: 6),
      s.feld(pw.Text(k.ui('ui.druck.paket.dateien.warnung'), style: s.text(11, FestStil.stempelrot)), farbe: FestStil.stempelrot),
      pw.SizedBox(height: 4),
      pw.Center(child: pw.Text(k.ui('ui.druck.paket.viel_spass'), style: s.hand(20))),
    ],
  );
}

pw.Widget _gaesteliste(PaketKontext k) {
  final s = k.stil;
  pw.Widget zelle(pw.Widget w, {bool mitte = false}) =>
      pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.4), alignment: mitte ? pw.Alignment.center : pw.Alignment.centerLeft, child: w);
  pw.TableRow zeile(pw.Widget figur, {bool steckbrief = true}) => pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          zelle(figur),
          zelle(pw.SizedBox(height: 17)),
          zelle(steckbrief ? s.kaestchen(11) : pw.SizedBox(), mitte: true),
          zelle(s.kaestchen(11), mitte: true),
        ],
      );
  pw.Widget figur(String id) => pw.Row(children: [
        s.medaillon(k.bild(id, klein: true), 18, ring: k.farbe(id)),
        pw.SizedBox(width: 6),
        pw.Text(k.figurName(id), style: s.titel(11.5)),
        pw.SizedBox(width: 6),
        pw.Expanded(child: pw.Text(k.druck.figurTitel(id), style: s.klein(7.5), maxLines: 1)),
      ]);
  return pw.Table(
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: FestStil.linieZart, width: 0.6),
      verticalInside: pw.BorderSide(color: FestStil.linieZart, width: 0.6),
      top: pw.BorderSide(color: FestStil.linie, width: 0.8),
      bottom: pw.BorderSide(color: FestStil.linie, width: 0.8),
    ),
    columnWidths: const {0: pw.FixedColumnWidth(212), 1: pw.FlexColumnWidth(), 2: pw.FixedColumnWidth(70), 3: pw.FixedColumnWidth(62)},
    children: [
      pw.TableRow(decoration: const pw.BoxDecoration(color: FestStil.papierTief), children: [
        for (final (t, mitte) in [
          (k.ui('ui.druck.paket.gaeste.figur'), false),
          (k.ui('ui.druck.paket.gaeste.name'), false),
          (k.ui('ui.druck.paket.gaeste.steckbrief'), true),
          (k.ui('ui.druck.paket.gaeste.heft'), true),
        ])
          zelle(pw.Text(t.toUpperCase(), style: s.marke(7), textAlign: mitte ? pw.TextAlign.center : pw.TextAlign.left), mitte: mitte),
      ]),
      for (final id in k.figurenAlphabetisch) zeile(figur(id)),
      zeile(pw.Row(children: [
        s.medaillon(k.bild(Besetzung.detektiv, detektiv: 'w', klein: true), 18),
        pw.SizedBox(width: 6),
        pw.Text(k.ui('ui.druck.paket.gaeste.detektiv'), style: s.titel(11.5)),
      ])),
      zeile(
        pw.Row(children: [
          pw.SizedBox(width: 24),
          pw.Text(k.ui('ui.druck.paket.gaeste.erzaehler'), style: s.titel(11.5)),
          pw.SizedBox(width: 6),
          pw.Expanded(child: pw.Text(k.ui('ui.druck.paket.gaeste.optional'), style: s.klein(7.5), maxLines: 2)),
        ]),
        steckbrief: false,
      ),
    ],
  );
}

/// Ein Ordner des Pakets: Nummer, Name und wofür er da ist.
pw.Widget _ordner(PaketKontext k, int n) {
  final s = k.stil;
  final farbe = n >= 3 ? FestStil.stempelrot : FestStil.messing;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Container(
        width: 26,
        height: 20,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          color: n >= 3 ? const PdfColor.fromInt(0xFFF3DADB) : FestStil.papierTief,
          border: pw.Border.all(color: farbe, width: 0.8),
          borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
        ),
        child: pw.Text('$n', style: s.titel(12, farbe)),
      ),
      pw.SizedBox(width: 10),
      pw.Expanded(
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text(k.ui('ui.druck.paket.dateien.ordner$n'), style: s.titel(12.5)),
            pw.SizedBox(width: 8),
            pw.Text(paketOrdner[n - 1], style: s.klein(7.5)),
          ]),
          pw.Text(k.ui('ui.druck.paket.dateien.ordner$n.text${n == 4 && k.erzaehlerakte != null ? '.akte' : ''}'), style: s.text(10)),
        ]),
      ),
    ]),
  );
}
