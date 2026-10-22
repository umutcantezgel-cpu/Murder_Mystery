import 'dart:math';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../besetzung.dart';
import 'paket.dart';
import 'satz.dart';
import 'satz_fest.dart';
import 'steckbrief.dart';

// Steckbriefe und Charakterübersicht im festlichen Stil (Druckpaket, Ordner 1).
// Spoilerfrei wie die schlichten Steckbriefe (K3, A-059): Alle Angaben kommen aus
// [steckbriefFigur] (Name, Aussprache, Rolle, Alter, Alltag, Wer du bist, Besetzung,
// Kostüm, Auftritt, Satz), nie aus Dossiers, Fassungen oder dem Fall-Code.

/// Angaben für Steckbrief und Karten: Figur oder Detektiv ([detektiv] `w`/`m`).
SteckbriefFigur festFigur(PaketKontext k, String id, {String detektiv = 'w', bool uebersicht = false}) =>
    steckbriefFigur(k.steckbrief(detektiv), id, uebersicht: uebersicht);

/// „Sprich: …“ und „27 Jahre“ (leer beim Detektiv).
List<String> festZeilenTeile(PaketKontext k, SteckbriefFigur f) => [
      if (f.aussprache.isNotEmpty) k.ui('ui.druck.steckbrief.aussprache', {'aussprache': f.aussprache}),
      if (f.alter != null) k.ui('ui.druck.steckbrief.alter', {'alter': '${f.alter}'}),
    ];

/// „Sprich: … · 27 Jahre“ (leer beim Detektiv).
String festZeile(PaketKontext k, SteckbriefFigur f) => festZeilenTeile(k, f).join('  ·  ');

// ---------------------------------------------------------------- Steckbrief

const _fotoBreite = 206.0;
const _spalte = 24.0;
double get _nameBreite => FestStil.breite - _fotoBreite - _spalte;

/// Eine Steckbriefseite: großes Porträt als Fotoabzug, Name, Aussprache, Rolle und
/// Alter, Im Alltag, Wer du bist, So trittst du auf, Kostümtipp, Dein Satz am Abend,
/// Hinweis zur Besetzung. Eine Schriftgröße für alle Steckbriefe des Pakets.
void festSteckbrief(pw.Document doc, PaketKontext k, String id, {String detektiv = 'w'}) {
  final f = festFigur(k, id, detektiv: detektiv);
  final g = _steckbriefGroesse(k);
  final s = k.stil;
  doc.addPage(pw.Page(
    pageTheme: s.seite(
      falltitel: k.fallTitel,
      marke: k.ui('ui.druck.steckbrief.marke'),
      fuss: k.ui('ui.druck.fest.spoilerfrei'),
      seitenzahl: (_, _) => k.untertitel,
      lasche: PdfColor.fromHex(f.farbe),
      laschenText: f.name,
      markeFarbe: FestStil.stempelrot,
    ),
    build: (c) => pw.SizedBox(
      height: FestStil.hoehe,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: _steckbriefTeile(k, f, id, g, detektiv),
      ),
    ),
  ));
}

List<pw.Widget> _steckbriefTeile(PaketKontext k, SteckbriefFigur f, String id, double g, String detektiv) {
  final s = k.stil;
  final zeile = festZeile(k, f);
  final nameGroesse = s.einzeilig(f.name, (x) => s.titel(x), _nameBreite, start: 50, min: 30);
  return [
    // Kopf: Fotoabzug und Name.
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6, left: 4),
          child: s.fotoabzug(k.bild(id, detektiv: detektiv), _fotoBreite - 8, neigung: -0.035),
        ),
        pw.SizedBox(width: _spalte),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 4),
              pw.Text(f.titel.toUpperCase(), style: s.marke(10.5, FestStil.stempelrot)),
              pw.SizedBox(height: 4),
              pw.Text(f.name, style: s.titel(nameGroesse), maxLines: 1),
              if (zeile.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(zeile, style: s.kursiv(12.5, FestStil.tinteLeise)),
              ],
              pw.SizedBox(height: 12),
              s.zierlinie(_nameBreite),
              pw.SizedBox(height: 12),
              s.feldmarke(k.ui('ui.druck.steckbrief.alltag'), farbe: FestStil.tinteLeise),
              pw.Text(f.alltag, style: s.text(g + 0.5)),
            ],
          ),
        ),
      ],
    ),
    // Wer du bist.
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        s.kopfzeile(k.ui('ui.druck.steckbrief.wer'), farbe: PdfColor.fromHex(f.farbe)),
        pw.Text(f.wer, style: s.text(g)),
      ],
    ),
    // Auftritt und Kostüm.
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 11,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              s.kopfzeile(k.ui('ui.druck.steckbrief.auftritt'), farbe: PdfColor.fromHex(f.farbe)),
              s.punkte(f.eintrag.auftritt, g: g, farbe: FestStil.kerze, abstand: 5),
            ],
          ),
        ),
        pw.SizedBox(width: 22),
        pw.Expanded(
          flex: 9,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: _notizzettel(k, k.ui('ui.druck.steckbrief.kostuem'), f.eintrag.kostuem),
          ),
        ),
      ],
    ),
    // Dein Satz.
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        s.kopfzeile(k.ui('ui.druck.steckbrief.satz'), farbe: PdfColor.fromHex(f.farbe)),
        pw.SizedBox(height: 4),
        pw.Center(child: s.zitat(f.eintrag.satz, g: g + 7, breite: FestStil.breite)),
      ],
    ),
    // Besetzung und der Hinweis, dass nichts verraten wird.
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(
          child: s.feld(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                s.feldmarke(k.ui('ui.druck.steckbrief.besetzung')),
                pw.Text(f.besetzung, style: s.text(g - 1.5)),
                pw.SizedBox(height: 5),
                pw.Text(k.ui('ui.druck.steckbrief.ohne_geheimnis'), style: s.kursiv(g - 1.5, FestStil.tinteLeise)),
              ],
            ),
            farbe: FestStil.messing,
          ),
        ),
        pw.SizedBox(width: 18),
        s.stempel(k.ui('ui.druck.fest.spoilerfrei').split('–').first.trim(), g: 11, neigung: -0.08),
        pw.SizedBox(width: 6),
      ],
    ),
  ];
}

/// Notizzettel mit Klebestreifen: Marke und Text in Handschrift (Kostümtipp).
pw.Widget _notizzettel(PaketKontext k, String marke, String text) {
  final s = k.stil;
  return pw.Stack(
    overflow: pw.Overflow.visible,
    children: [
      pw.Transform.rotate(
        angle: 0.02,
        child: pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFF6EBCB),
            border: pw.Border.all(color: const PdfColor.fromInt(0xFFDCC795), width: 0.5),
            boxShadow: const [pw.BoxShadow(color: PdfColor(0.2, 0.15, 0.05, 0.22), blurRadius: 4, offset: PdfPoint(1.5, 2))],
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              s.feldmarke(marke, farbe: FestStil.stempelrot),
              pw.SizedBox(height: 2),
              pw.Text(text, style: s.hand(19)),
            ],
          ),
        ),
      ),
    ],
  );
}

final _groessen = Expando<double>();

/// Größte Lesegröße (bis 12,5 pt), bei der jeder Steckbrief des Pakets mit
/// Mindestabständen auf seine Seite passt.
double _steckbriefGroesse(PaketKontext k) => _groessen[k] ??= [
      for (final (id, d) in [for (final id in k.druck.satz.besetzt) (id, 'w'), (Besetzung.detektiv, 'w'), (Besetzung.detektiv, 'm')])
        k.stil.passendeGroesse(
          (g) => pw.Column(children: [
            for (final t in _steckbriefTeile(k, festFigur(k, id, detektiv: d), id, g, d)) ...[t, pw.SizedBox(height: 16)],
          ]),
          FestStil.breite,
          FestStil.hoehe,
          start: 12.5,
          wo: 'Steckbrief $id',
        ),
    ].reduce(min);

/// Der Steckbrief einer Figur oder des Detektivs als eigene Datei.
Future<DruckDatei> festSteckbriefDatei(PaketKontext k, String id, {String detektiv = 'w'}) async {
  final f = festFigur(k, id, detektiv: detektiv);
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.steckbrief.marke')} · ${f.name}');
  festSteckbrief(doc, k, id, detektiv: detektiv);
  final wort = id == Besetzung.detektiv ? (detektiv == 'w' ? 'detektivin' : 'detektiv') : paketName(k, id);
  return DruckDatei('steckbrief-$wort.pdf', await k.stil.speichern(doc), figur: id);
}

// ---------------------------------------------------------------- Charakterübersicht

const _kartenAbstand = 14.0;
double get _kartenBreite => (FestStil.breite - _kartenAbstand) / 2;
const _kartenHoehe = 150.0;
const _kartenFoto = 72.0;

/// Charakterübersicht bei der Personenzahl des Pakets: Titel „Wer ist dabei?“, der
/// Detektiv als breite Karte, dann die Figuren alphabetisch als Karten mit Porträt,
/// Name, Rolle, Alltag und Satz; am Ende, wie es weitergeht. Zwei Seiten.
void festUebersicht(pw.Document doc, PaketKontext k) {
  final s = k.stil;
  final ids = k.figurenAlphabetisch;
  final g = _kartenGroesse(k);
  final karten = [for (var i = 0; i < ids.length; i++) kurzkarte(k, ids[i], _kartenBreite, _kartenHoehe, g, neigung: i.isEven ? -0.03 : 0.025)];
  pw.Widget reihen(List<pw.Widget> ks) => pw.Column(children: [
        for (var i = 0; i < ks.length; i += 2)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: _kartenAbstand),
            child: pw.Row(children: [
              ks[i],
              pw.SizedBox(width: _kartenAbstand),
              if (i + 1 < ks.length) ks[i + 1] else pw.SizedBox(width: _kartenBreite),
            ]),
          ),
      ]);
  final theme = s.seite(
    falltitel: k.fallTitel,
    marke: k.ui('ui.druck.uebersicht.marke'),
    fuss: k.ui('ui.druck.fest.spoilerfrei'),
    seitenzahl: k.seite,
  );
  final erste = min(4, karten.length);
  doc.addPage(pw.Page(
    pageTheme: theme,
    build: (c) => s.spalte(
      wo: 'Charakterübersicht Seite 1',
      [
        pw.Center(child: pw.Text(k.ui('ui.druck.fest.uebersicht.titel'), style: s.titel(40))),
        pw.SizedBox(height: 2),
        pw.Center(child: pw.Text(k.fallTitel, style: s.kursiv(14, FestStil.tinteLeise))),
        pw.SizedBox(height: 8),
        pw.Center(child: s.zierlinie(200)),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.SizedBox(
            width: FestStil.breite - 60,
            child: pw.Text(k.ui('ui.druck.uebersicht.mit_zahl', {'anzahl': '${k.rollen}'}), style: s.text(11.5), textAlign: pw.TextAlign.center),
          ),
        ),
        pw.SizedBox(height: 14),
        _detektivKarte(k),
        pw.SizedBox(height: _kartenAbstand + 2),
        reihen(karten.sublist(0, erste)),
        pw.Spacer(),
        _weiter(k),
      ],
    ),
  ));
  doc.addPage(pw.Page(
    pageTheme: theme,
    build: (c) => s.spalte(
      wo: 'Charakterübersicht Seite 2',
      [
        reihen(karten.sublist(erste)),
        pw.Spacer(),
        pw.Center(child: s.zierlinie(220)),
        pw.SizedBox(height: 8),
        pw.Center(child: pw.Text(k.ui('ui.druck.uebersicht.waehlen'), style: s.kursiv(11, FestStil.tinteLeise), textAlign: pw.TextAlign.center)),
        pw.SizedBox(height: 4),
      ],
    ),
  ));
}

/// Der Detektiv als breite Karte: beide Porträts (Detektivin und Detektiv).
pw.Widget _detektivKarte(PaketKontext k) {
  final s = k.stil;
  final f = festFigur(k, Besetzung.detektiv, uebersicht: true);
  return s.karteikarte(
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        s.fotoabzug(k.bild(Besetzung.detektiv, detektiv: 'w', klein: true), 74, neigung: -0.04, klebeband: false),
        pw.SizedBox(width: 8),
        s.fotoabzug(k.bild(Besetzung.detektiv, detektiv: 'm', klein: true), 74, neigung: 0.035, klebeband: false),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(f.titel.toUpperCase(), style: s.marke(8.5, FestStil.stempelrot)),
              pw.SizedBox(height: 2),
              pw.Text(f.name, style: s.titel(19)),
              pw.SizedBox(height: 4),
              pw.Text(k.ui('ui.druck.fest.uebersicht.detektiv'), style: s.text(10.5)),
              pw.SizedBox(height: 4),
              pw.Text(k.ui('ui.druck.steckbrief.zitat', {'satz': f.eintrag.satz}), style: s.kursiv(10.5, FestStil.tinteLeise)),
            ],
          ),
        ),
      ],
    ),
    farbe: PdfColor.fromHex(f.farbe),
    innen: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
  );
}

/// Wie es weitergeht: drei Schritte nebeneinander.
pw.Widget _weiter(PaketKontext k) {
  final s = k.stil;
  final schritte = [
    k.ui('ui.druck.fest.uebersicht.schritt1'),
    k.ui('ui.druck.fest.uebersicht.schritt2'),
    k.ui('ui.druck.fest.uebersicht.schritt3'),
  ];
  return s.karteikarte(
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(k.ui('ui.druck.fest.uebersicht.weiter'), style: s.titel(15)),
        pw.SizedBox(height: 6),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final (i, t) in schritte.indexed) ...[
              if (i > 0) pw.SizedBox(width: 14),
              pw.Expanded(
                child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.SizedBox(width: 18, child: pw.Text('${i + 1}', style: s.titel(17, FestStil.kerze))),
                  pw.Expanded(child: pw.Padding(padding: const pw.EdgeInsets.only(top: 2), child: pw.Text(t, style: s.text(9.5)))),
                ]),
              ),
            ],
          ],
        ),
      ],
    ),
    farbe: FestStil.kerze,
    innen: const pw.EdgeInsets.fromLTRB(14, 10, 14, 10),
  );
}

/// Kurzkarte einer Figur (Übersicht, „Wen du kennst“): kleines Porträt, Name,
/// Aussprache und Alter, Rolle, darunter Alltag und Satz. Nur spoilerfreie Angaben.
pw.Widget kurzkarte(PaketKontext k, String id, double breite, double hoehe, double g, {double neigung = 0, bool satz = true, double? foto, double name = 19}) {
  final f = festFigur(k, id, uebersicht: true);
  return k.stil.karteikarte(
    pw.SizedBox(height: hoehe - _kartenRahmen, child: _kurzInhalt(k, f, g, foto: foto ?? _fotoFuer(hoehe), neigung: neigung, satz: satz, name: name)),
    farbe: PdfColor.fromHex(f.farbe),
    breite: breite,
    hoehe: hoehe,
    innen: const pw.EdgeInsets.fromLTRB(11, 9, 11, 9),
  );
}

/// Höhe von Farbstreifen und Innenrand einer Karteikarte.
const _kartenRahmen = 4.0 + 18 + 1.4;

double _fotoFuer(double hoehe) => min(_kartenFoto, hoehe * 0.5);

pw.Widget _kurzInhalt(PaketKontext k, SteckbriefFigur f, double g, {required double foto, double neigung = 0, bool satz = true, double name = 19}) {
  final s = k.stil;
  // Kleine Karten (schmales Porträt): Rolle unter dem Bild über die ganze Breite,
  // Aussprache und Alter je in einer eigenen Zeile (sonst bräche „Jahre“ allein um).
  final kompakt = foto < 60;
  final zeilen = kompakt ? festZeilenTeile(k, f) : [festZeile(k, f)].where((z) => z.isNotEmpty);
  final rolle = pw.Text(f.titel.toUpperCase(), style: s.marke(7.5, FestStil.stempelrot));
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          s.fotoabzug(k.bild(f.id, klein: true), foto, neigung: neigung, klebeband: false),
          pw.SizedBox(width: kompakt ? 8 : 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (!kompakt) ...[rolle, pw.SizedBox(height: 1)],
                pw.Text(f.name, style: s.titel(name)),
                for (final z in zeilen) pw.Text(z, style: s.klein(kompakt ? 7 : 7.5)),
              ],
            ),
          ),
        ],
      ),
      if (kompakt) ...[pw.SizedBox(height: 5), rolle],
      pw.SizedBox(height: kompakt ? 3 : 6),
      pw.Text(f.alltag, style: kompakt ? s.text(g).copyWith(lineSpacing: g * 0.18) : s.text(g)),
      if (satz) ...[
        pw.SizedBox(height: 3),
        pw.Text(k.ui('ui.druck.steckbrief.zitat', {'satz': f.eintrag.satz}), style: s.kursiv(g, FestStil.tinteLeise)),
      ],
    ],
  );
}

final _kartenGroessen = Expando<double>();

/// Eine Schriftgröße für alle Karten des Pakets.
double _kartenGroesse(PaketKontext k) => _kartenGroessen[k] ??= kurzkartenGroesse(k, _kartenBreite, _kartenHoehe);

/// Größte Schriftgröße (bis 10 pt), bei der jede Kurzkarte der besetzten Figuren in
/// [breite] × [hoehe] passt.
double kurzkartenGroesse(PaketKontext k, double breite, double hoehe, {bool satz = true, double? foto, double name = 19}) => [
      for (final id in k.druck.satz.besetzt) ...[
        k.stil.passendeGroesse(
          (g) => _kurzInhalt(k, festFigur(k, id, uebersicht: true), g, foto: foto ?? _fotoFuer(hoehe), satz: satz, name: name),
          breite - 22 - 1.4,
          hoehe - _kartenRahmen,
          start: 10,
          wo: 'Kurzkarte $id',
        ),
        // Kein Wort darf breiter sein als die Karte (sonst bricht es mitten im Wort).
        k.stil.wortGroesse(festFigur(k, id, uebersicht: true).alltag, (g) => k.stil.text(g), breite - 22 - 1.4, start: 10),
      ],
    ].reduce(min);

/// Die Charakterübersicht als Datei.
Future<DruckDatei> festUebersichtDatei(PaketKontext k) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.datei.uebersicht')}');
  festUebersicht(doc, k);
  return DruckDatei('charakteruebersicht.pdf', await k.stil.speichern(doc));
}

/// Übersicht, die Steckbriefe der besetzten Figuren (alphabetisch), Detektivin und Detektiv.
Future<DruckDatei> festSteckbriefeAlleDatei(PaketKontext k) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.datei.steckbriefe')}');
  festUebersicht(doc, k);
  for (final id in k.figurenAlphabetisch) {
    festSteckbrief(doc, k, id);
  }
  festSteckbrief(doc, k, Besetzung.detektiv, detektiv: 'w');
  festSteckbrief(doc, k, Besetzung.detektiv, detektiv: 'm');
  return DruckDatei('steckbriefe-alle.pdf', await k.stil.speichern(doc));
}
