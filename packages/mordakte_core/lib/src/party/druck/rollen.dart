import 'dart:math';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../befragung.dart';
import '../besetzung.dart';
import '../texte.dart';
import 'modell.dart';
import 'satz.dart';
import 'satz_stil.dart';

// Rollenhefte, versiegelte Fassungen der Kernrollen, Stimmkarten (F5-BAUMEISTER-02, Master 7.11, 7.14, G-1).
// Texte kommen aus Bausteinen `ui.druck.*` oder aus den Daten des Satzes. Außen stehen nur Codes.

/// Stimmkarte: 90 × 60 mm, acht je Blatt. Unten ein Streifen zum Abreißen, der nur den Wertcode trägt (E-035).
const _kartenBreite = PdfPageFormat.mm * 90;
const _kartenHoehe = PdfPageFormat.mm * 60;
const _streifenHoehe = PdfPageFormat.mm * 17;
const _vorneHoehe = _kartenHoehe - _streifenHoehe;

void rollenhefte(pw.Document doc, DruckKontext k) {
  for (final rolle in k.satz.besetzt) {
    rollenheft(doc, k, rolle);
  }
}

/// Das Heft einer Rolle: Deckblatt und Inhalt.
void rollenheft(pw.Document doc, DruckKontext k, String rolle) {
  doc.addPage(_deckblatt(k, rolle));
  doc.addPage(pw.MultiPage(
    pageFormat: DruckStil.format,
    margin: DruckStil.rand,
    footer: (c) => k.stil.fuss(c, k.fallTitel),
    build: (c) => _heft(k, rolle),
  ));
}

/// Je besetzter Rolle ein eigenes Rollenheft (A-059), in Besetzungsreihenfolge, damit
/// jede Person nur ihr Heft bekommt. Der Dateiname trägt den Figurennamen
/// (`10-rollenheft-<figur>.pdf`); jede Rolle hat in jedem Pfad genau ein Heft.
Future<List<DruckDatei>> rollenheftDateien(DruckKontext k) async => [
      for (final rolle in k.satz.besetzt) await rollenheftDatei(k, rolle),
    ];

/// Das Rollenheft von [rolle] als eigene Datei.
Future<DruckDatei> rollenheftDatei(DruckKontext k, String rolle) => setzeDatei(
      k,
      '10-rollenheft-${dateiWort(k.figurName(rolle))}.pdf',
      '${k.ui('ui.druck.rollen.heft')} · ${k.figurName(rolle)}',
      (doc, k) => rollenheft(doc, k, rolle),
      figur: rolle,
    );

/// Jede Fassung hat genau vier Seiten mit denselben Überschriften (E-036):
/// Außenseite, Inhalt, Rundenwahl mit den Streifen A und B (E-039), Notizen. Eine Schriftgröße
/// für alle vier bringt die längste Fassung auf ihre Seite; so verrät weder
/// Seitenzahl noch Aufbau, welche Fassung die Täterfassung ist.
void fassungen(pw.Document doc, DruckKontext k) {
  final fs = k.satz.fassungen;
  final hoehe = DruckStil.format.height - DruckStil.rand.top - DruckStil.rand.bottom - _fussRaum;
  double gemeinsam(pw.Widget Function(Fassung f, double g) bauen, double platz, String wo) => [
        for (final f in fs) k.stil.passendeGroesse((g) => bauen(f, g), DruckStil.breite, platz, wo: '$wo ${f.code}'),
      ].reduce(min);
  final gInhalt = gemeinsam((f, g) => _fassungInhalt(k, f, g), hoehe, 'fassung');
  final gWahl = gemeinsam((f, g) => _fassungWahl(k, f, g), hoehe - 2 * _streifenReiheHoehe - 6, 'rundenwahl');
  for (final f in fs) {
    doc.addPage(pw.Page(pageFormat: DruckStil.format, margin: DruckStil.rand, build: (c) => _fassungAussen(k, f)));
    doc.addPage(pw.Page(
      pageFormat: DruckStil.format,
      margin: DruckStil.rand,
      build: (c) => pw.Column(children: [_fassungInhalt(k, f, gInhalt), pw.Spacer(), k.stil.fuss(c, k.fallTitel)]),
    ));
    doc.addPage(pw.Page(
      pageFormat: DruckStil.format,
      margin: DruckStil.rand,
      build: (c) => pw.Column(children: [
        _fassungWahl(k, f, gWahl),
        pw.Spacer(),
        _streifenReihe(k, 'A', f.streifenA),
        pw.SizedBox(height: 6),
        _streifenReihe(k, 'B', f.streifen),
        pw.SizedBox(height: 8),
        k.stil.fuss(c, k.fallTitel),
      ]),
    ));
    doc.addPage(_notizen(k));
  }
}

void stimmkarten(pw.Document doc, DruckKontext k) {
  // Reihenfolge: nach Runde, dann Besetzungsreihenfolge, A vor B. Nur Gäste haben
  // Karten; die Kernrollen stimmen mit ihrer Fassung (E-039).
  final karten = [
    for (var r = 1; r <= 3; r++)
      for (final rolle in k.satz.besetzt)
        for (final a in [true, false]) ...k.satz.stimmkarten.where((s) => s.rolle == rolle && s.runde == r && s.a == a),
  ];
  if (karten.isEmpty) {
    doc.addPage(pw.Page(
      pageFormat: DruckStil.format,
      margin: DruckStil.rand,
      build: (c) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        k.stil.kopf(k.ui('ui.druck.stimme.titel'), ''),
        pw.Text(k.ui('ui.druck.stimme.keine'), style: k.stil.text()),
        pw.Spacer(),
        k.stil.fuss(c, k.fallTitel),
      ]),
    ));
    return;
  }
  final schrift = _kartenSchrift(k, karten);
  for (var i = 0; i < karten.length; i += 8) {
    final blatt = karten.sublist(i, min(i + 8, karten.length));
    doc.addPage(pw.Page(
      pageFormat: DruckStil.format,
      margin: pw.EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      build: (c) => pw.Column(
        children: [
          for (var z = 0; z < 4; z++)
            pw.Row(
              children: [
                for (var s = 0; s < 2; s++)
                  if (z * 2 + s < blatt.length)
                    _karte(k, blatt[z * 2 + s], schrift)
                  else
                    pw.SizedBox(width: _kartenBreite, height: _kartenHoehe),
              ],
            ),
        ],
      ),
    ));
  }
}

// ---------------------------------------------------------------- Rollenheft

pw.Page _deckblatt(DruckKontext k, String rolle) {
  final farbe = PdfColor.fromHex(k.kanon.figur(rolle)!['colorCode'] as String);
  return pw.Page(
    pageFormat: DruckStil.format,
    margin: DruckStil.rand,
    build: (c) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(k.fallTitel, style: k.stil.marke()),
        pw.Spacer(flex: 2),
        pw.Container(
          width: DruckStil.breite,
          height: 18,
          decoration: pw.BoxDecoration(color: farbe, border: pw.Border.all(color: DruckStil.linie, width: 0.6)),
        ),
        pw.SizedBox(height: 26),
        pw.Text(k.ui('ui.druck.rollen.heft'), style: k.stil.marke(10)),
        pw.SizedBox(height: 8),
        pw.Text(k.figurName(rolle), style: k.stil.titel(44)),
        pw.SizedBox(height: 6),
        pw.Text(k.figurTitel(rolle), style: k.stil.ueberschrift(16)),
        pw.Spacer(flex: 3),
        pw.Container(
          width: DruckStil.breite,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 1.2)),
          child: pw.Text(k.ui('ui.druck.rollen.nurfuerdich'), style: k.stil.text(14)),
        ),
        pw.Spacer(flex: 4),
        k.stil.fuss(c, k.fallTitel),
      ],
    ),
  );
}

/// Hält einen Block zusammen: Passt er nicht mehr auf die Seite, beginnt er auf der nächsten.
List<pw.Widget> _zusammen(DruckKontext k, pw.Widget Function() bauen) => [
      pw.NewPage(freeSpace: k.stil.hoehe(bauen(), DruckStil.breite)),
      bauen(),
    ];

List<pw.Widget> _heft(DruckKontext k, String rolle) {
  final d = k.satz.rollenhefte[rolle]!;
  final w = <pw.Widget>[k.stil.kopf(k.ui('ui.druck.rollen.heft'), k.figurName(rolle))];
  final fassung = _fassungVon(k, rolle);
  w.addAll(_zusammen(k, () => k.stil.abschnitt(k.ui('ui.druck.rollen.wer'), [d.wer])));
  // Kernrollen: Das Ziel hängt am Pfad (Täterziel) und steht deshalb im
  // versiegelten Umschlag; die vier Kernhefte sehen gleich aus (E-033).
  if (fassung == null) w.addAll(_zusammen(k, () => k.stil.abschnitt(k.ui('ui.druck.rollen.ziel'), [d.ziel])));
  final befragung = k.texte.besetzung.befragungsmodell;
  for (var r = 1; r <= 3; r++) {
    w.addAll(_zusammen(k, () => befragung ? _tischRunde(k, d, r, kopf: r == 1) : _gespraechRunde(k, d, r, kopf: r == 1)));
  }
  w.addAll(_zusammen(k, () => k.stil.abschnitt(k.ui('ui.druck.rollen.besetzung'), [d.besetzung])));
  if (fassung != null) {
    // Kernrollen: Was ich weiß, verberge und wähle steht im versiegelten Umschlag.
    w.addAll(_zusammen(k, () => _umschlag(k, fassung.code)));
  } else {
    w
      ..addAll(_weissUndVerberge(k, d))
      ..addAll(_rundenwahl(k, d));
  }
  return w;
}

/// Pflichtgespräche einer Runde; die erste Runde trägt die Überschrift des Abschnitts.
pw.Widget _gespraechRunde(DruckKontext k, Dossier d, int r, {bool kopf = false}) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (kopf) ...[
            pw.Text(k.ui('ui.druck.rollen.gespraeche'), style: k.stil.ueberschrift(12.5)),
            pw.SizedBox(height: 4),
          ],
          pw.Text(k.ui('ui.druck.rollen.runde', {'nr': '$r'}), style: k.stil.ueberschrift(11)),
          pw.SizedBox(height: 3),
          for (final (g, partner) in d.gespraeche[r] ?? const <(Gespraech, String)>[]) ...[
            _feld(k, k.ui('ui.druck.rollen.partner'), _partner(k, partner)),
            _feld(k, k.ui('ui.druck.rollen.thema'), g.thema),
            _feld(k, k.ui('ui.druck.rollen.gespraechsziel'), g.ziel),
            _feld(k, k.ui('ui.druck.rollen.anfang'), '„${g.text}“'),
            pw.SizedBox(height: 5),
          ],
        ],
      ),
    );

/// Modell befragung (A-051): je Runde das Tischgespräch mit Stichpunkten, wer dich
/// anspricht und was du sagst, wenn der Detektiv dich befragt. Alles hängt nur an
/// Rolle und Personenzahl, nie am Pfad.
pw.Widget _tischRunde(DruckKontext k, Dossier d, int r, {bool kopf = false}) {
  final b = d.befragungen[r];
  final angesprochen = d.alsPartner[r] ?? const <(Gespraech, String)>[];
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (kopf) ...[
          pw.Text(k.ui('ui.druck.rollen.tisch'), style: k.stil.ueberschrift(12.5)),
          pw.SizedBox(height: 4),
        ],
        pw.Text(k.ui('ui.druck.rollen.runde', {'nr': '$r'}), style: k.stil.ueberschrift(11)),
        pw.SizedBox(height: 3),
        for (final (g, partner) in d.gespraeche[r] ?? const <(Gespraech, String)>[]) ...[
          _feld(k, k.ui('ui.druck.rollen.partner'), _partner(k, partner)),
          _feld(k, k.ui('ui.druck.rollen.thema'), g.thema),
          _feld(k, k.ui('ui.druck.rollen.gespraechsziel'), g.ziel),
          _feld(k, k.ui('ui.druck.rollen.stichpunkte'), _punkte(g.stichpunkte)),
          pw.SizedBox(height: 3),
        ],
        if (angesprochen.isNotEmpty)
          _feld(k, k.ui('ui.druck.rollen.angesprochen'), _punkte([
            for (final (g, sprecher) in angesprochen) k.ui('ui.druck.befragung.zeile', {'name': k.figurName(sprecher), 'thema': g.thema}),
          ])),
        if (b != null) ...[
          pw.SizedBox(height: 3),
          pw.Text(k.ui('ui.druck.rollen.befragt'), style: k.stil.klein()),
          pw.SizedBox(height: 2),
          _feld(k, k.ui('ui.druck.rollen.thema'), b.thema),
          _feld(k, k.ui('ui.druck.rollen.fragen'), _punkte(b.fragen)),
          _feld(k, k.ui('ui.druck.rollen.sagen'), _antwort(k, b)),
        ],
      ],
    ),
  );
}

/// Was die Rolle in ihrer Befragung sagt: Beobachtungen, Behauptungen, eigene Würze.
/// Je Karte ein Block (R17, E-044), getrennt durch eine Leerzeile wie in der App.
String _antwort(DruckKontext k, BefragungText b) {
  final karten = befragungsZettel(k.texte, b).kartenZeilen((x) => k.ui('ui.druck.rollen.behaupte', {'text': x}));
  return karten.isEmpty ? k.ui('ui.druck.rollen.nichts') : [for (final z in karten) _punkte(z)].join('\n\n');
}

/// Stichpunkte untereinander, je mit Gedankenstrich.
String _punkte(List<String> zeilen) => [for (final z in zeilen) '– $z'].join('\n');

List<pw.Widget> _weissUndVerberge(DruckKontext k, Dossier d) => [
      ..._zusammen(k, () => k.stil.abschnitt(k.ui('ui.druck.rollen.weiss'), [for (final z in d.weiss) z.text])),
      ..._zusammen(
        k,
        () => k.stil.abschnitt(k.ui('ui.druck.rollen.verberge'), [
          for (final z in d.verbirgt)
            if (z.behauptung != null) ...[
              k.ui('ui.druck.rollen.behauptet', {'behauptung': z.behauptung!}),
              k.ui('ui.druck.rollen.wahrheit', {'wahrheit': z.text}),
            ] else
              z.text,
        ]),
      ),
    ];

List<pw.Widget> _rundenwahl(DruckKontext k, Dossier d) => [
      for (var r = 1; r <= 3; r++)
        if (d.wahlen[r] != null) ..._zusammen(k, () => _wahlBlock(k, r, d.wahlen[r]!, kopf: r == 1)),
    ];

/// Die beiden Wahlen einer Runde; die erste Runde trägt die Überschrift des Abschnitts.
pw.Widget _wahlBlock(DruckKontext k, int r, WahlText w, {bool kopf = false}) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (kopf) ...[
            pw.Text(k.ui('ui.druck.rollen.wahl'), style: k.stil.ueberschrift(12.5)),
            pw.SizedBox(height: 4),
          ],
          pw.Text(k.ui('ui.druck.rollen.runde', {'nr': '$r'}), style: k.stil.ueberschrift(11)),
          pw.SizedBox(height: 3),
          _wahlZeile(k, 'A', w.a),
          // Im Rollenheft nie die Sabotage: Die steht nur in der Fassung der Täterrolle (E-036).
          _wahlZeile(k, 'B', w.b),
        ],
      ),
    );

pw.Widget _wahlZeile(DruckKontext k, String kennzeichen, String text, {double groesse = 11}) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(kennzeichen, style: k.stil.klein()),
          pw.Text(text, style: k.stil.text(groesse)),
        ],
      ),
    );

pw.Widget _feld(DruckKontext k, String bezeichnung, String wert) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 118, child: pw.Text(bezeichnung, style: k.stil.klein())),
          pw.Expanded(child: pw.Text(wert, style: k.stil.text())),
        ],
      ),
    );

String _partner(DruckKontext k, String id) => id == Besetzung.detektiv ? k.ui('ui.druck.rollen.detektiv') : k.figurName(id);

pw.Widget _umschlag(DruckKontext k, String code) => pw.Container(
      width: DruckStil.breite,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 1)),
      child: pw.Text(k.ui('ui.druck.rollen.umschlag', {'code': code}), style: k.stil.text()),
    );

Fassung? _fassungVon(DruckKontext k, String rolle) {
  for (final f in k.satz.fassungen) {
    if (f.rolle == rolle) return f;
  }
  return null;
}

// ---------------------------------------------------------------- Fassungen

/// Platz für die Fußzeile einer Seite und Höhe der Streifenreihe (pt).
const _fussRaum = 22.0;
const _wahlSpalte = 24.0;
const _streifenReiheHoehe = PdfPageFormat.mm * 24;

/// Außenseite: Code und neutraler Hinweis im oberen Viertel. Beim Knick in der
/// Mitte nach hinten bleibt der Code vorn (Vorbereitung im Spielleitungsheft).
pw.Widget _fassungAussen(DruckKontext k, Fassung f) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Spacer(),
        pw.Center(child: k.stil.aussenseite(f.code, k.ui('ui.druck.fassung.aussen'))),
        pw.Spacer(flex: 3),
      ],
    );

/// Inhalt einer Fassung: Ziel, Wissen, Verborgenes. Die Täterrolle bekommt keine
/// eigene Überschrift; ihre Tat und Tarnung stehen unter „Was ich verberge“ (E-036).
/// Jede Fassung beginnt und endet dort mit einem Satz an der gleichen Stelle; die
/// Unschuldigen haben ihre Nacht als Chronik, damit die Seiten ähnlich dicht sind (E-039).
pw.Widget _fassungInhalt(DruckKontext k, Fassung f, double g) {
  final d = f.dossier;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      k.stil.kopf(k.ui('ui.druck.fassung.marke'), k.figurName(f.rolle)),
      k.stil.abschnitt(k.ui('ui.druck.rollen.ziel'), [d.ziel], groesse: g),
      k.stil.abschnitt(k.ui('ui.druck.rollen.weiss'), [for (final z in d.weiss) z.text], groesse: g),
      k.stil.abschnitt(
        k.ui('ui.druck.rollen.verberge'),
        [
          k.ui(d.taeter ? 'ui.druck.fassung.taeter' : 'ui.druck.fassung.unschuldig'),
          for (final z in d.tatwissen) z.text,
          if (d.tarnung != null) d.tarnung!,
          for (final z in d.verbirgt)
            if (z.behauptung != null) ...[
              k.ui('ui.druck.rollen.behauptet', {'behauptung': z.behauptung!}),
              k.ui('ui.druck.rollen.wahrheit', {'wahrheit': z.text}),
            ] else
              z.text,
          k.ui(d.taeter ? 'ui.druck.fassung.sabotage' : 'ui.druck.fassung.tipp'),
        ],
        groesse: g,
      ),
    ],
  );
}

/// Rundenwahl einer Fassung: dieselbe Anleitung für alle vier, je Runde A und B.
/// Bei der Täterrolle ist B die heimliche Wahl (Sabotage-Text), ohne eigene Marke.
pw.Widget _fassungWahl(DruckKontext k, Fassung f, double g) {
  final d = f.dossier;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      k.stil.kopf(k.ui('ui.druck.fassung.marke'), k.ui('ui.druck.rollen.wahl')),
      pw.Text(k.ui('ui.druck.fassung.streifen'), style: k.stil.text(g)),
      pw.SizedBox(height: 10),
      for (var r = 1; r <= 3; r++)
        if (d.wahlen[r] case final w?) ...[
          pw.Text(k.ui('ui.druck.rollen.runde', {'nr': '$r'}), style: k.stil.ueberschrift(11)),
          pw.SizedBox(height: 3),
          _wahlZeile(k, 'A', w.a, groesse: g),
          _wahlZeile(k, 'B', w.sabotage ?? w.b, groesse: g),
          pw.SizedBox(height: 6),
        ],
    ],
  );
}

/// Drei Streifen zum Abreißen, je Runde einer: nur Runde und Wertcode. Die
/// Wahl A oder B steht links daneben und bleibt auf der Seite.
pw.Widget _streifenReihe(DruckKontext k, String wahl, Map<int, String> streifen) => pw.Row(
      children: [
        pw.SizedBox(width: _wahlSpalte, child: pw.Center(child: pw.Text(wahl, style: k.stil.ueberschrift(16)))),
        for (var r = 1; r <= 3; r++)
          pw.Container(
            width: (DruckStil.breite - _wahlSpalte) / 3,
            height: _streifenReiheHoehe,
            padding: const pw.EdgeInsets.all(6),
            decoration: k.stil.schnitt(),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(k.ui('ui.druck.rollen.runde', {'nr': '$r'}), style: k.stil.klein()),
                pw.SizedBox(height: 2),
                pw.Text(k.ui('ui.druck.stimme.wert', {'code': streifen[r]!}), style: k.stil.ueberschrift(14)),
                pw.SizedBox(height: 2),
                pw.Text(k.ui('ui.druck.stimme.falz_fassung'), style: k.stil.klein(), textAlign: pw.TextAlign.center),
              ],
            ),
          ),
      ],
    );

pw.Page _notizen(DruckKontext k) => pw.Page(
      pageFormat: DruckStil.format,
      margin: DruckStil.rand,
      build: (c) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          k.stil.kopf(k.ui('ui.druck.fassung.marke'), k.ui('ui.druck.fassung.notizen')),
          for (var i = 0; i < 26; i++)
            pw.Container(
              width: DruckStil.breite,
              height: 24,
              decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: DruckStil.linie, width: 0.5))),
            ),
          pw.Spacer(),
          k.stil.fuss(c, k.fallTitel),
        ],
      ),
    );

// ---------------------------------------------------------------- Stimmkarten

/// Eine Schriftgröße für alle Karten: die kleinste, die jede Vorderseite passend fasst.
/// Gemessen wird die ganze Vorderseite (Kopfzeile und Kartentext), nicht nur der Text.
double _kartenSchrift(DruckKontext k, List<Stimmkarte> karten) {
  var schrift = 11.0;
  for (final s in karten) {
    final g = k.stil.passendeGroesse(
      (groesse) => _vorderseite(k, s, groesse),
      _kartenBreite,
      _vorneHoehe,
      wo: 'Stimmkarte ${s.rolle} Runde ${s.runde}',
    );
    schrift = min(schrift, g);
  }
  return schrift;
}

/// Karte (oberer Teil): Figur, Runde, A oder B und der Text der Karte. Kein Wert, kein Namensfeld.
/// Ohne feste Höhe, damit die Messung die echte Höhe liefert.
pw.Widget _vorderseite(DruckKontext k, Stimmkarte s, double schrift) => pw.Container(
      width: _kartenBreite,
      padding: const pw.EdgeInsets.fromLTRB(9, 7, 9, 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(k.figurName(s.rolle), style: k.stil.ueberschrift(10)),
              pw.Text('  ·  ', style: k.stil.klein()),
              pw.Text(k.ui('ui.druck.stimme.runde', {'nr': '${s.runde}'}), style: k.stil.klein()),
              pw.Spacer(),
              pw.Text(s.a ? 'A' : 'B', style: k.stil.ueberschrift(12)),
            ],
          ),
          pw.SizedBox(height: 5),
          // Kartentext eng gesetzt (kein Zeilenabstand über der Schrift), damit vier Zeilen bei 9 pt passen.
          pw.Text(s.text, style: pw.TextStyle(font: k.stil.normal, fontSize: schrift, color: DruckStil.tinte, lineSpacing: 0.5)),
        ],
      ),
    );

pw.Widget _karte(DruckKontext k, Stimmkarte s, double schrift) => pw.Container(
      width: _kartenBreite,
      height: _kartenHoehe,
      decoration: k.stil.schnitt(),
      child: pw.Column(
        children: [
          pw.SizedBox(width: _kartenBreite, height: _vorneHoehe, child: _vorderseite(k, s, schrift)),
          // Streifen zum Abreißen: nur der neutrale Wertcode, kein Name, kein Wert.
          pw.Container(
            width: _kartenBreite,
            height: _streifenHoehe,
            padding: const pw.EdgeInsets.fromLTRB(9, 4, 9, 4),
            decoration: pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: DruckStil.linie, width: 0.8, style: pw.BorderStyle.dashed)),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(k.ui('ui.druck.stimme.wert', {'code': s.wertCode}), style: k.stil.ueberschrift(14)),
                pw.SizedBox(height: 2),
                pw.Text(k.ui('ui.druck.stimme.falz'), style: k.stil.klein(), textAlign: pw.TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
