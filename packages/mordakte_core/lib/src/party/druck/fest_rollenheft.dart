import 'dart:math';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../befragung.dart';
import '../besetzung.dart';
import '../texte.dart';
import 'fest_steckbrief.dart';
import 'modell.dart';
import 'paket.dart';
import 'satz.dart';
import 'satz_fest.dart';

// Rollenheft je Figur im festlichen Stil (Druckpaket, Ordner 3, geheim). Jedes Heft
// hat denselben Aufbau und gleich viele Seiten, jede Seite ist eine feste Seite:
//   1 Deckblatt · 2 Wer du bist, Dein Ziel, Was du weißt, Deine Rundenwahl ·
//   3 Was du verbirgst · 4 Wen du kennst · 5–7 Runde 1–3 · 8 Notizen.
// Die Kernrollen tragen ihre zum Fall-Code passende Fassung direkt im Heft (Ziel,
// Wissen, Verborgenes, heimliche Wahl), wortgleich wie die versiegelte Fassung des
// Druckspiels; je Seitenart gilt eine Schriftgröße für alle vier Kernhefte, so
// verrät weder Seitenzahl noch Satz von außen, wer es war. Freier Platz unten auf
// einer Seite wird zu Notizlinien. Inhalte anderer Rollen stehen nur als
// spoilerfreie Kurzkarten unter „Wen du kennst“.

/// Seiten eines Rollenhefts.
const rollenheftSeiten = 8;

/// Das Rollenheft von [rolle] als Datei (`rollenheft-<figur>.pdf`).
Future<DruckDatei> festRollenheftDatei(PaketKontext k, String rolle) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.fest.heft.titel')} · ${k.figurName(rolle)}');
  festRollenheft(doc, k, rolle);
  return DruckDatei('rollenheft-${paketName(k, rolle)}.pdf', await k.stil.speichern(doc), figur: rolle);
}

/// Setzt das Heft von [rolle] in [doc].
void festRollenheft(pw.Document doc, PaketKontext k, String rolle) {
  final g = _groessen(k, rolle);
  final theme = _seite(k, rolle);
  doc
    ..addPage(pw.Page(pageTheme: theme, build: (c) => _deckblatt(k, rolle)))
    ..addPage(pw.Page(pageTheme: theme, build: (c) => _mitNotizen(k, _vorab1(k, rolle, g.vorab1))))
    ..addPage(pw.Page(pageTheme: theme, build: (c) => _mitNotizen(k, _vorab2(k, rolle, g.vorab2))))
    ..addPage(pw.Page(pageTheme: theme, build: (c) => _kennst(k, rolle, _kartenGroesse(k))));
  for (var r = 1; r <= 3; r++) {
    doc.addPage(pw.Page(
      pageTheme: theme,
      build: (c) => _mitNotizen(k, _runde(k, rolle, r, g.runde[r]!), marke: k.ui('ui.druck.fest.runde.notizen', {'nr': '$r'})),
    ));
  }
  doc.addPage(pw.Page(pageTheme: theme, build: (c) => _notizen(k)));
}

pw.PageTheme _seite(PaketKontext k, String rolle) => k.stil.seite(
      falltitel: k.fallTitel,
      marke: '${k.ui('ui.druck.fest.heft.titel')} · ${k.figurName(rolle)}',
      fuss: k.ui('ui.druck.fest.geheim'),
      seitenzahl: k.seite,
      lasche: k.farbe(rolle),
      laschenText: k.figurName(rolle),
    );

Dossier _dossier(PaketKontext k, String rolle) => k.druck.satz.rollenhefte[rolle]!;

Fassung? _fassung(PaketKontext k, String rolle) {
  for (final f in k.druck.satz.fassungen) {
    if (f.rolle == rolle) return f;
  }
  return null;
}

// ---------------------------------------------------------------- Größen

typedef _Groessen = ({double vorab1, double vorab2, Map<int, double> runde});

final _cache = Expando<Map<String, _Groessen>>();
final _kartenCache = Expando<double>();

/// Je Seitenart die größte Schriftgröße (bis 12 pt), bei der die Seite nicht überläuft
/// (sonst ein Fehler). Die vier Kernrollen teilen sich je Seitenart eine Größe.
_Groessen _groessen(PaketKontext k, String rolle) => (_cache[k] ??= {})[rolle] ??= () {
      final kern = k.kanon.kernverdaechtige;
      final gruppe = kern.contains(rolle) ? [for (final r in k.druck.satz.besetzt) if (kern.contains(r)) r] : [rolle];
      double je(pw.Widget Function(String rolle, double g) bauen, {required String wo}) => [
            for (final r in gruppe) k.stil.passendeGroesse((g) => bauen(r, g), FestStil.breite, FestStil.hoehe, start: 12, wo: '$wo $r'),
          ].reduce(min);
      final g = (
        vorab1: je((r, g) => pw.Column(children: _vorab1(k, r, g)), wo: 'Rollenheft Seite 2'),
        vorab2: je((r, g) => pw.Column(children: _vorab2(k, r, g)), wo: 'Rollenheft Seite 3'),
        runde: {for (var r = 1; r <= 3; r++) r: je((rolle, g) => pw.Column(children: _runde(k, rolle, r, g)), wo: 'Rollenheft Runde $r')},
      );
      if (kern.contains(rolle)) {
        for (final r in gruppe) {
          _cache[k]![r] = g;
        }
      }
      return g;
    }();

double _kartenGroesse(PaketKontext k) => _kartenCache[k] ??= kurzkartenGroesse(k, _kennstBreite, _kennstHoehe, satz: false, foto: _kennstFoto, name: 15);

// ---------------------------------------------------------------- Deckblatt

pw.Widget _deckblatt(PaketKontext k, String rolle) {
  final s = k.stil;
  final name = k.figurName(rolle);
  final titel = k.druck.figurTitel(rolle);
  final inhalt = [
    ('${k.ui('ui.druck.fest.wer')} · ${k.ui('ui.druck.fest.ziel')} · ${k.ui('ui.druck.fest.weiss')} · ${k.ui('ui.druck.fest.rundenwahl')}', 2),
    (k.ui('ui.druck.fest.verbirgst'), 3),
    (k.ui('ui.druck.fest.kennst'), 4),
    for (var r = 1; r <= 3; r++) ('${k.ui('ui.druck.fest.runde', {'nr': '$r'})} – ${k.ui('ui.druck.fest.runde.erst', {'nr': '$r'})}', 4 + r),
    (k.ui('ui.druck.fest.notizen'), 8),
  ];
  return s.spalte(
    wo: 'Deckblatt $rolle',
    quer: pw.CrossAxisAlignment.center,
    [
      pw.SizedBox(height: 2),
      pw.Text(k.ui('ui.druck.fest.heft.titel').toUpperCase(), style: s.marke(12, FestStil.stempelrot)),
      pw.SizedBox(height: 16),
      s.fotoabzug(k.bild(rolle), 238, neigung: -0.03),
      pw.SizedBox(height: 20),
      pw.Text(name, style: s.titel(s.einzeilig(name, (x) => s.titel(x), FestStil.breite, start: 52, min: 30))),
      pw.SizedBox(height: 2),
      pw.Text(titel.toUpperCase(), style: s.marke(11.5, FestStil.tinteLeise)),
      pw.SizedBox(height: 12),
      s.zierlinie(240),
      pw.SizedBox(height: 16),
      s.stempel(k.ui('ui.druck.fest.geheim'), g: 12.5, neigung: -0.04),
      pw.Spacer(),
      pw.SizedBox(
        width: FestStil.breite - 40,
        child: s.feld(pw.Text(k.ui('ui.druck.fest.heft.lesen'), style: s.kursiv(11)), farbe: k.farbe(rolle)),
      ),
      pw.SizedBox(height: 12),
      pw.Stack(
        overflow: pw.Overflow.visible,
        children: [
          s.karteikarte(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                s.feldmarke(k.ui('ui.druck.fest.heft.inhalt'), farbe: FestStil.stempelrot),
                pw.SizedBox(height: 3),
                for (final (t, seite) in inhalt)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2.5),
                    child: pw.Row(children: [
                      pw.Expanded(child: pw.Text(t, style: s.text(9.5))),
                      pw.SizedBox(width: 8),
                      pw.Text('$seite', style: s.titel(10.5, FestStil.messing)),
                    ]),
                  ),
              ],
            ),
            farbe: k.farbe(rolle),
            breite: FestStil.breite - 40,
          ),
          pw.Positioned(right: -20, top: -24, child: s.siegel(56, wachs: true)),
        ],
      ),
      pw.SizedBox(height: 2),
    ],
  );
}

// ---------------------------------------------------------------- Vorab

/// Seite 2: Wer du bist, Dein Ziel, Was du weißt, Hinweis zur Besetzung und Deine
/// Rundenwahl (bei der Täterrolle ist B die heimliche Wahl, wie in ihrer Fassung).
List<pw.Widget> _vorab1(PaketKontext k, String rolle, double g) {
  final s = k.stil;
  final d = _dossier(k, rolle);
  return [
    _seitenTitel(k, k.ui('ui.druck.fest.wer'), rolle),
    pw.Text(d.wer, style: s.text(g)),
    pw.SizedBox(height: 14),
    s.kopfzeile(k.ui('ui.druck.fest.ziel'), farbe: k.farbe(rolle)),
    s.feld(pw.Text(d.ziel, style: s.kursiv(g + 0.5)), farbe: k.farbe(rolle)),
    pw.SizedBox(height: 14),
    s.kopfzeile(k.ui('ui.druck.fest.weiss'), farbe: k.farbe(rolle)),
    s.punkte([for (final z in d.weiss) z.text], g: g, farbe: FestStil.kerze, abstand: 4),
    pw.SizedBox(height: 4),
    pw.Text(d.besetzung, style: s.kursiv(g - 1.5, FestStil.tinteLeise)),
    pw.SizedBox(height: 14),
    s.kopfzeile(k.ui('ui.druck.fest.rundenwahl'), farbe: k.farbe(rolle)),
    pw.Text(k.ui('ui.druck.fest.rundenwahl.hinweis'), style: s.kursiv(g - 1, FestStil.tinteLeise)),
    pw.SizedBox(height: 6),
    for (var r = 1; r <= 3; r++)
      if (d.wahlen[r] case final w?) _wahl(k, r, w, g),
  ];
}

/// Seite 3: Was du verbirgst. Kernrollen lesen hier ihre Fassung (wie
/// `_fassungInhalt` im Druckspiel), ohne Codes und Streifen.
List<pw.Widget> _vorab2(PaketKontext k, String rolle, double g) {
  final s = k.stil;
  final d = _dossier(k, rolle);
  final fassung = _fassung(k, rolle);
  final verborgen = <pw.Widget>[];
  void zeile(DossierZeile z) {
    if (z.behauptung != null) {
      verborgen.add(_behauptung(k, z, g));
    } else {
      verborgen.add(s.punkte([z.text], g: g, farbe: FestStil.stempelrot, abstand: 4));
    }
  }

  if (fassung != null) {
    verborgen.add(pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: s.feld(pw.Text(k.ui(d.taeter ? 'ui.druck.fassung.taeter' : 'ui.druck.fassung.unschuldig'), style: s.titel(g + 2)), farbe: FestStil.stempelrot),
    ));
    for (final z in d.tatwissen) {
      zeile(z);
    }
    if (d.tarnung != null) verborgen.add(s.punkte([d.tarnung!], g: g, farbe: FestStil.stempelrot, abstand: 4));
  }
  for (final z in d.verbirgt) {
    zeile(z);
  }
  if (fassung != null) {
    verborgen.add(pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Text(k.ui(d.taeter ? 'ui.druck.fassung.sabotage' : 'ui.druck.fassung.tipp'), style: s.kursiv(g)),
    ));
  }
  return [
    _seitenTitel(k, k.ui('ui.druck.fest.verbirgst'), rolle),
    ...verborgen,
  ];
}

/// Eine Lüge: was du behauptest und wie es wirklich war.
pw.Widget _behauptung(PaketKontext k, DossierZeile z, double g) {
  final s = k.stil;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: s.feld(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(k.ui('ui.druck.rollen.behauptet', {'behauptung': z.behauptung!}), style: s.kursiv(g)),
          pw.SizedBox(height: 2),
          pw.Text(k.ui('ui.druck.rollen.wahrheit', {'wahrheit': z.text}), style: s.text(g)),
        ],
      ),
      farbe: FestStil.stempelrot,
      grund: FestStil.karte,
      innen: const pw.EdgeInsets.fromLTRB(10, 5, 8, 5),
    ),
  );
}

/// Die Wahl einer Runde: A und B nebeneinander (B ist bei der Täterrolle die heimliche Wahl).
pw.Widget _wahl(PaketKontext k, int r, WahlText w, double g) {
  final s = k.stil;
  pw.Widget seite(String buchstabe, String text) => pw.Expanded(
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
            width: g * 1.7,
            height: g * 1.7,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(color: FestStil.messing, width: 0.8)),
            child: pw.Text(buchstabe, style: s.titel(g, FestStil.messing)),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(child: pw.Text(text, style: s.text(g - 0.5))),
        ]),
      );
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 7),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 2),
        s.feldmarke(k.ui('ui.druck.fest.runde', {'nr': '$r'}), farbe: FestStil.stempelrot),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          seite('A', w.a),
          pw.SizedBox(width: 14),
          seite('B', w.sabotage ?? w.b),
        ]),
      ],
    ),
  );
}

/// Titel einer Heftseite: groß in Playfair, darunter eine Linie mit Akzent in der Figurenfarbe.
pw.Widget _seitenTitel(PaketKontext k, String titel, String rolle) {
  final s = k.stil;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(titel, style: s.titel(26)),
        pw.SizedBox(height: 3),
        pw.Row(children: [
          pw.Container(width: 46, height: 2.2, color: k.farbe(rolle)),
          pw.Expanded(child: pw.Container(height: 0.5, color: FestStil.linie)),
        ]),
      ],
    ),
  );
}

// ---------------------------------------------------------------- Wen du kennst

const _kennstAbstand = 10.0;
double get _kennstBreite => (FestStil.breite - 2 * _kennstAbstand) / 3;
const _kennstHoehe = 146.0;
const _kennstFoto = 50.0;

pw.Widget _kennst(PaketKontext k, String rolle, double g) {
  final s = k.stil;
  final andere = [for (final id in k.figurenAlphabetisch) if (id != rolle) id];
  final karten = <pw.Widget>[
    for (final (i, id) in andere.indexed) kurzkarte(k, id, _kennstBreite, _kennstHoehe, g, neigung: i.isEven ? -0.03 : 0.03, satz: false, foto: _kennstFoto, name: 15),
    _detektivKachel(k),
  ];
  return s.spalte(
    wo: 'Wen du kennst $rolle',
    quer: pw.CrossAxisAlignment.start,
    [
      _seitenTitel(k, k.ui('ui.druck.fest.kennst'), rolle),
      pw.Text(k.ui('ui.druck.fest.kennst.hinweis'), style: s.kursiv(11, FestStil.tinteLeise)),
      pw.SizedBox(height: 8),
      for (var i = 0; i < karten.length; i += 3)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: _kennstAbstand),
          child: pw.Row(children: [
            for (var j = i; j < i + 3; j++) ...[
              if (j > i) pw.SizedBox(width: _kennstAbstand),
              if (j < karten.length) karten[j] else pw.SizedBox(width: _kennstBreite),
            ],
          ]),
        ),
    ],
  );
}

/// Die letzte Kachel: Detektivin oder Detektiv mit beiden Porträts.
pw.Widget _detektivKachel(PaketKontext k) {
  final s = k.stil;
  final f = festFigur(k, Besetzung.detektiv, uebersicht: true);
  return s.karteikarte(
    s.kasten(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(children: [
            s.fotoabzug(k.bild(Besetzung.detektiv, detektiv: 'w', klein: true), 44, neigung: -0.04, klebeband: false),
            pw.SizedBox(width: 6),
            s.fotoabzug(k.bild(Besetzung.detektiv, detektiv: 'm', klein: true), 44, neigung: 0.04, klebeband: false),
          ]),
          pw.SizedBox(height: 5),
          pw.Text(f.name, style: s.titel(13)),
          pw.SizedBox(height: 2),
          pw.Text(f.alltag, style: s.text(8.5).copyWith(lineSpacing: 1.5)),
        ],
      ),
      _kennstBreite - 23.4,
      _kennstHoehe - 23.4,
      wo: 'Kachel Detektiv',
    ),
    farbe: PdfColor.fromHex(f.farbe),
    breite: _kennstBreite,
    hoehe: _kennstHoehe,
    innen: const pw.EdgeInsets.fromLTRB(11, 9, 11, 9),
  );
}

// ---------------------------------------------------------------- Runden

/// Eine Runde: Kopf mit Stempel „Erst lesen, wenn Runde X beginnt“, dein
/// Tischgespräch, wer dich anspricht und was du sagst, wenn der Detektiv dich befragt
/// (Inhalt wie `_tischRunde` des Druckspiels; im Modell legacy die Pflichtgespräche).
List<pw.Widget> _runde(PaketKontext k, String rolle, int r, double g) {
  final s = k.stil;
  final d = _dossier(k, rolle);
  final befragung = k.texte.besetzung.befragungsmodell;
  final b = d.befragungen[r];
  final angesprochen = d.alsPartner[r] ?? const <(Gespraech, String)>[];
  return [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(k.ui('ui.druck.fest.runde', {'nr': '$r'}), style: s.titel(34)),
        pw.SizedBox(width: 18),
        pw.Expanded(child: pw.Container(height: 0.5, color: FestStil.linie)),
        pw.SizedBox(width: 14),
        s.stempel(k.ui('ui.druck.fest.runde.erst', {'nr': '$r'}), g: 9.5, neigung: -0.05),
      ],
    ),
    pw.SizedBox(height: 10),
    for (final (gs, partner) in d.gespraeche[r] ?? const <(Gespraech, String)>[])
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: s.karteikarte(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                _person(k, partner, 34),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    s.feldmarke(k.ui(befragung ? 'ui.druck.fest.tisch' : 'ui.druck.rollen.gespraeche'), farbe: FestStil.stempelrot),
                    pw.Text(k.ui('ui.druck.fest.mit', {'name': _name(k, partner)}), style: s.titel(g + 4)),
                  ]),
                ),
              ]),
              pw.SizedBox(height: 6),
              _feld(k, k.ui('ui.druck.rollen.thema'), pw.Text(gs.thema, style: s.text(g)), g),
              _feld(k, k.ui('ui.druck.rollen.gespraechsziel'), pw.Text(gs.ziel, style: s.text(g)), g),
              if (befragung)
                _feld(k, k.ui('ui.druck.rollen.stichpunkte'), s.punkte(gs.stichpunkte, g: g, abstand: 2), g)
              else
                _feld(k, k.ui('ui.druck.rollen.anfang'), pw.Text('„${gs.text}“', style: s.kursiv(g)), g),
            ],
          ),
          farbe: k.farbe(rolle),
        ),
      ),
    if (angesprochen.isNotEmpty) ...[
      s.kopfzeile(k.ui('ui.druck.rollen.angesprochen'), g: g + 3, farbe: k.farbe(rolle), abstand: 4),
      for (final (gs, sprecher) in angesprochen)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4, left: 2),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            _person(k, sprecher, 24),
            pw.SizedBox(width: 8),
            pw.Expanded(child: pw.Text(k.ui('ui.druck.befragung.zeile', {'name': k.figurName(sprecher), 'thema': gs.thema}), style: s.text(g))),
          ]),
        ),
      pw.SizedBox(height: 8),
    ],
    if (b != null) ...[
      s.kopfzeile(k.ui('ui.druck.rollen.befragt'), g: g + 3, farbe: k.farbe(rolle), abstand: 4),
      _feld(k, k.ui('ui.druck.rollen.thema'), pw.Text(b.thema, style: s.text(g)), g),
      _feld(k, k.ui('ui.druck.rollen.fragen'), s.punkte(b.fragen, g: g, farbe: FestStil.messing, abstand: 2), g),
      _feld(k, k.ui('ui.druck.rollen.sagen'), _antwort(k, b, g), g),
    ],
  ];
}

/// Was die Rolle in ihrer Befragung sagt: je Karte ein Block (R17), wie im Druckspiel.
pw.Widget _antwort(PaketKontext k, BefragungText b, double g) {
  final s = k.stil;
  final karten = befragungsZettel(k.texte, b).kartenZeilen((x) => k.ui('ui.druck.rollen.behaupte', {'text': x}));
  if (karten.isEmpty) return pw.Text(k.ui('ui.druck.rollen.nichts'), style: s.text(g));
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (final (i, z) in karten.indexed) ...[
        if (i > 0) pw.SizedBox(height: 4),
        s.feld(s.punkte(z, g: g, farbe: FestStil.stempelrot, abstand: 2), farbe: FestStil.linie, grund: FestStil.karte, innen: const pw.EdgeInsets.fromLTRB(8, 4, 6, 2)),
      ],
    ],
  );
}

/// Feld mit Marke links und Inhalt rechts.
pw.Widget _feld(PaketKontext k, String marke, pw.Widget inhalt, double g) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 112, child: pw.Padding(padding: pw.EdgeInsets.only(top: g * 0.18), child: pw.Text(marke.toUpperCase(), style: k.stil.marke(8)))),
          pw.Expanded(child: inhalt),
        ],
      ),
    );

/// Kleines rundes Porträt einer Person; der Detektiv als Schattenriss.
pw.Widget _person(PaketKontext k, String id, double d) =>
    k.stil.medaillon(id == Besetzung.detektiv ? null : k.bild(id, klein: true), d, ring: id == Besetzung.detektiv ? FestStil.linie : k.farbe(id));

String _name(PaketKontext k, String id) => id == Besetzung.detektiv ? k.ui('ui.druck.rollen.detektiv') : k.figurName(id);

// ---------------------------------------------------------------- Notizen

/// Füllt den Platz unter [inhalt] mit Notizlinien, wenn genug frei ist.
pw.Widget _mitNotizen(PaketKontext k, List<pw.Widget> inhalt, {String? marke}) =>
    k.stil.mitNotizen(inhalt, marke: marke ?? k.ui('ui.druck.fest.notizen'), wo: 'Rollenheft');

pw.Widget _notizen(PaketKontext k) {
  final s = k.stil;
  return s.spalte(
    wo: 'Notizen',
    quer: pw.CrossAxisAlignment.start,
    [
      pw.Text(k.ui('ui.druck.fest.notizen'), style: s.titel(26)),
      pw.SizedBox(height: 3),
      pw.Container(height: 0.5, color: FestStil.linie),
      pw.SizedBox(height: 6),
      pw.Text(k.ui('ui.druck.fest.notizen.hinweis'), style: s.hand(17)),
      s.linien(25, abstand: 24.5),
    ],
  );
}
