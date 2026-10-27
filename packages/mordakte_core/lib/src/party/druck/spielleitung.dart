import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../besetzung.dart';
import '../einstimmung.dart';
import 'modell.dart';
import 'satz.dart';
import 'satz_stil.dart';

// Erzählerheft ohne Lösung (früher Spielleitungsheft, A-052, M5) und Detektivbogen mit
// Ermittlungsbogen (F5-BAUMEISTER-01, Master 7.14). Jeder Text ist ein Baustein
// (ui.druck.spielleitung.*, ui.druck.erzaehler.*, ui.druck.bogen.*), ein Erzähler- oder
// Detektivtext über k.text oder ein Datum des Satzes. Keine Schrift unter 9 pt.

/// Dateinummern des Satzes mit ihrem Baustein (Vorbereitung).
const _dateien = [
  ('00', 'ui.druck.spielleitung.datei.00'),
  ('01', 'ui.druck.spielleitung.datei.01'),
  ('10', 'ui.druck.spielleitung.datei.10'),
  ('11', 'ui.druck.spielleitung.datei.11'),
  ('12', 'ui.druck.spielleitung.datei.12'),
  ('20', 'ui.druck.spielleitung.datei.20'),
  ('21', 'ui.druck.spielleitung.datei.21'),
  ('90', 'ui.druck.spielleitung.datei.90'),
];

/// Lagen im Zwischenresümee: Schlüssel der Erzählerbausteine und ihre Beschriftung.
const _lagen = [
  ('offen', 'ui.druck.spielleitung.lage.offen'),
  ('spur', 'ui.druck.spielleitung.lage.spur'),
  ('klar', 'ui.druck.spielleitung.lage.klar'),
];

/// Erzählerheft (A-052): was der Erzähler am Tisch liest und weiß, nie die Lösung.
/// Vorlesetexte mit der Dia-Nummer als Stichwort im Intro, je Runde die Befragungen
/// des Detektivs mit ihren Antworten und alle Tischgespräche als Stichpunkte (aus
/// dem Erzählerpaket, M2.1). Mit [druckspiel] kommen Vorbereitung, Fassungen,
/// Entscheidungen, Auszählung, Umschläge, Resümee, Anklage und Anhang dazu (Abend
/// auf Papier); ohne bleibt es beim Vorlesen und dem Tisch, den Rest zeigt die App
/// (Abend am Bildschirm, Fallback ohne eigenes Erzählerhandy). Hat die Akte eine
/// Einstimmung (A-063), stehen Vorgeschichte und Vorstellung vor dem Intro, und das
/// Druckspiel sagt in der Vorbereitung, dass es ohne „Dein Moment“ läuft.
void erzaehlerheft(pw.Document doc, DruckKontext k, {bool druckspiel = true}) {
  final heft = k.satz.spielleitung;
  final links = '${k.fallTitel} · ${k.ui('ui.druck.spielleitung.marke')}';
  doc.addPage(
    pw.MultiPage(
      pageFormat: DruckStil.format,
      margin: DruckStil.rand,
      footer: (c) => _fuss(k, links, c),
      build: (_) => [
        ..._deckblatt(k, druckspiel: druckspiel),
        pw.NewPage(),
        if (druckspiel) ..._vorbereitung(k),
        ..._ablauf(k, heft, druckspiel: druckspiel),
        if (druckspiel) ...[pw.NewPage(), ..._anhang(k, heft)],
      ],
    ),
  );
}

void detektivbogen(pw.Document doc, DruckKontext k) {
  final links = '${k.fallTitel} · ${k.ui('ui.druck.bogen.marke')}';
  doc.addPage(
    pw.MultiPage(
      pageFormat: DruckStil.format,
      margin: DruckStil.rand,
      footer: (c) => _fuss(k, links, c),
      build: (_) => [
        ..._kopf(k, k.ui('ui.druck.bogen.marke'), k.fallTitel),
        ..._block(k, k.ui('ui.druck.bogen.regeln'), [
          _absatz(k, k.text('detektiv.regeln.entscheidungen')),
          _absatz(k, k.text('detektiv.regeln.hinweise')),
          _absatz(k, k.text('detektiv.regeln.punkte')),
        ]),
        for (var r = 1; r <= 3; r++) ...[
          if (r > 1) pw.NewPage(),
          _titel(k, k.ui('ui.druck.bogen.runde', {'nr': '$r'})),
          // Modell befragung: Wen du befragst und was du fragen kannst, nie eine Antwort.
          if (k.satz.befragungen.isNotEmpty) ..._block(k, k.ui('ui.druck.bogen.befragungen'), _befragungen(k, r, 'ui.druck.bogen.befragungen_frei')),
          for (final b in k.satz.detektivbogen.where((b) => b.runde == r))
            ..._entscheidung(k, b),
        ],
        pw.NewPage(),
        ..._ermittlungsbogen(k),
        ..._anklageBogen(k),
      ],
    ),
  );
}

// Erzählerheft

/// Deckblatt; den Fall-Code und das Auflösungsheft gibt es nur im Druckspiel.
/// Stehen Antworten im Heft (Modell befragung), sagt ein Kasten, dass der Detektiv es nicht liest.
List<pw.Widget> _deckblatt(DruckKontext k, {required bool druckspiel}) => [
  pw.SizedBox(height: 150),
  pw.Text(k.fallTitel, style: k.stil.titel(30)),
  pw.SizedBox(height: 10),
  pw.Text(k.ui('ui.druck.spielleitung.titel'), style: k.stil.ueberschrift(16)),
  pw.SizedBox(height: 14),
  _linie(DruckStil.breite),
  pw.SizedBox(height: 18),
  if (druckspiel) ...[
    pw.Text(
      k.ui('ui.druck.spielleitung.fallcode', {'code': k.satz.code.code}),
      style: k.stil.text(13),
    ),
    pw.SizedBox(height: 4),
  ],
  pw.Text(
    k.ui('ui.druck.spielleitung.personen', {'anzahl': '${k.satz.rollen}'}),
    style: k.stil.text(13),
  ),
  pw.SizedBox(height: 22),
  pw.Text(k.ui('ui.druck.spielleitung.willkommen'), style: k.stil.text(12)),
  pw.SizedBox(height: 6),
  pw.Text(k.ui(druckspiel ? 'ui.druck.spielleitung.aufloesung' : 'ui.druck.erzaehler.app'), style: k.stil.text(12)),
  if (k.satz.erzaehler.isNotEmpty) ...[
    pw.SizedBox(height: 22),
    pw.Container(
      width: DruckStil.breite,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 1.2)),
      child: pw.Text(k.ui('ui.druck.erzaehler.nur_du'), style: k.stil.text(12)),
    ),
  ],
];

List<pw.Widget> _vorbereitung(DruckKontext k) => [
  _titel(k, k.ui('ui.druck.spielleitung.vorbereitung')),
  _absatz(k, k.ui('ui.druck.spielleitung.vorbereitung.einleitung')),
  // Akten mit Einstimmung spielen in der App mit „Dein Moment“; die Druckfassung bleibt bei den Streifen A und B.
  if (Einstimmung.aus(k.kanon) != null) _absatz(k, k.ui('ui.druck.spielleitung.ohne_moment')),
  pw.Table(
    border: pw.TableBorder(
      horizontalInside: pw.BorderSide(color: DruckStil.linie, width: 0.5),
    ),
    columnWidths: {
      0: const pw.FixedColumnWidth(40),
      1: const pw.FlexColumnWidth(),
    },
    children: [
      for (final (nr, baustein) in _dateien)
        pw.TableRow(
          children: [
            _zelle(pw.Text(nr, style: k.stil.ueberschrift(11))),
            _zelle(pw.Text(k.ui(baustein), style: k.stil.text(11))),
          ],
        ),
    ],
  ),
  pw.SizedBox(height: 10),
  _unterlabel(k, k.ui('ui.druck.spielleitung.teile')),
  // Ohne Gäste gibt es keine Stimmkarten (E-039): Das Heft sagt es dann so.
  for (final t in ['indiz', 'umschlag', 'fassung', if (k.satz.stimmkarten.isEmpty) 'stimme_keine' else 'stimme', 'aufloesung'])
    _absatz(k, k.ui('ui.druck.spielleitung.teile.$t')),
];

/// Jede Runde und die Anklage beginnen auf einer neuen Seite, damit keine Überschrift am Seitenende hängt.
/// Die Intro-Bausteine tragen ihre Dia-Nummer als Stichwort: die Nummer ihres Bildes
/// in der Diashow der Akte (M4; ein Baustein ohne Bild ohne Stichwort), ohne Diashow
/// ein Dia je Baustein (A-054).
List<pw.Widget> _ablauf(DruckKontext k, Spielleitungsheft heft, {required bool druckspiel}) => [
  _titel(k, k.ui('ui.druck.spielleitung.ablauf')),
  _absatz(k, k.ui('ui.druck.spielleitung.ablauf.einleitung')),
  if (druckspiel)
    // Die Kernrollen öffnen ihre Fassung, wenn der Erzähler die Codes nennt (alphabetisch, ohne Namen).
    ..._block(k, k.ui('ui.druck.spielleitung.fassungen.titel'), [
      _absatz(k, k.ui('ui.druck.spielleitung.fassungen', {'codes': ([for (final f in k.satz.fassungen) f.code]..sort()).join(', ')})),
    ])
  else
    _absatz(k, k.ui('ui.druck.erzaehler.app_rest')),
  if (Einstimmung.aus(k.kanon) case final e?) ..._einstimmung(k, e),
  ..._block(k, k.ui('ui.druck.spielleitung.intro'), [
    for (var i = 0; i < heft.intro.length; i++) _vorlesen(k, k.text(heft.intro[i]), dia: _dia(k, heft.intro[i], i)),
  ]),
  for (var r = 1; r <= 3; r++) ...[pw.NewPage(), ..._runde(k, heft, r, druckspiel: druckspiel)],
  if (druckspiel) ...[pw.NewPage(), ..._anklage(k, heft)],
];

/// Einstimmung (A-063) vor dem Intro: die Teile der Vorgeschichte mit Kapiteltitel
/// (nicht vorgelesen) und Vorlesetext, dann die Vorstellung – Auftakt, je besetzte
/// Figur in Besetzungsreihenfolge Name, Rolle, „gespielt von“ und Text, der
/// Sammelblock für Gäste ohne Spieler und der Detektiv dieses Abends.
List<pw.Widget> _einstimmung(DruckKontext k, Einstimmung e) {
  final schritte = e.schritte(rollen: k.satz.rollen, detektiv: k.satz.detektiv);
  pw.Widget schritt(EinstimmungSchritt x) => switch (x.figur) {
        null when x.teil == EinstimmungTeil.vorgeschichte => _fach([_unterlabel(k, k.text(x.titel!)), _vorlesen(k, k.text(x.kennung))]),
        null when x.kennung == Einstimmung.npc => _fach([_unterlabel(k, k.ui('ui.druck.spielleitung.vorstellung.npc')), _vorlesen(k, k.text(x.kennung))]),
        null => _vorlesen(k, k.text(x.kennung)),
        Besetzung.detektiv => _fach([_unterlabel(k, k.ui('ui.druck.spielleitung.vorstellung.detektiv')), _vorlesen(k, k.text(x.kennung))]),
        final f => _fach([
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(k.figurName(f), style: k.stil.ueberschrift(11)),
                pw.SizedBox(width: 6),
                pw.Expanded(child: pw.Text(k.figurTitel(f), style: k.stil.text(10))),
                pw.Text(k.ui('ui.druck.spielleitung.gespielt'), style: k.stil.klein(10)),
                pw.SizedBox(width: 6),
                _linie(150),
              ],
            ),
            pw.SizedBox(height: 4),
            _vorlesen(k, k.text(x.kennung)),
          ]),
      };
  // Marke, Hinweis und erster Schritt eines Teils bleiben zusammen.
  List<pw.Widget> teil(String marke, String hinweis, List<EinstimmungSchritt> l) => _block(k, k.ui(marke), [
        _fach([_absatz(k, k.ui(hinweis)), if (l.isNotEmpty) schritt(l.first)]),
        for (final x in l.skip(1)) schritt(x),
      ]);
  final vorstellung = [for (final x in schritte) if (x.teil == EinstimmungTeil.vorstellung) x];
  return [
    ...teil('ui.druck.spielleitung.vorgeschichte', 'ui.druck.spielleitung.vorgeschichte.hinweis', [
      for (final x in schritte) if (x.teil == EinstimmungTeil.vorgeschichte) x,
    ]),
    if (vorstellung.isNotEmpty) ...teil('ui.druck.spielleitung.vorstellung', 'ui.druck.spielleitung.vorstellung.hinweis', vorstellung),
  ];
}

/// Dia-Nummer (ab 1) des Intro-Bausteins [kennung] an Stelle [i].
int? _dia(DruckKontext k, String kennung, int i) {
  final d = k.diashow;
  if (d == null) return i + 1;
  final nr = d.nrFuer(kennung);
  return nr == null ? null : nr + 1;
}

List<pw.Widget> _runde(DruckKontext k, Spielleitungsheft heft, int r, {required bool druckspiel}) => [
  _titel(k, k.ui('ui.druck.spielleitung.runde', {'nr': '$r'})),
  ..._block(k, k.ui('ui.druck.spielleitung.schritt.start'), [
    for (final b in heft.rundenStart[r]!) _vorlesen(k, k.text(b)),
  ]),
  if (k.satz.befragungen.isEmpty) ...[
    if (druckspiel)
      ..._block(k, k.ui('ui.druck.spielleitung.schritt.gespraeche'), [
        _absatz(
          k,
          k.ui('ui.druck.spielleitung.gespraeche', {
            'minuten': '${k.satz.rundendauerMinuten}',
          }),
        ),
      ]),
  ] else ...[
    // Modell befragung (A-051): die Befragungen des Detektivs mit Fragen und Antworten,
    // dann jedes Tischgespräch mit seinen Stichpunkten (Erzählerpaket, A-052).
    ..._block(k, k.ui('ui.druck.spielleitung.schritt.befragungen'), [
      if (druckspiel) _absatz(k, k.ui('ui.druck.spielleitung.befragungen', {'minuten': '${k.satz.rundendauerMinuten}'})),
      ..._befragungen(k, r, 'ui.druck.spielleitung.befragungen_frei', antworten: true),
    ]),
    ..._block(k, k.ui('ui.druck.erzaehler.tisch'), _tisch(k, r)),
  ],
  if (druckspiel) ..._ablaufDruck(k, heft, r),
];

/// Was nur der Abend auf Papier braucht: Entscheidungen, Gruppenwahl mit Auszählung, Umschlag, Resümee.
List<pw.Widget> _ablaufDruck(DruckKontext k, Spielleitungsheft heft, int r) => [
  ..._block(k, k.ui('ui.druck.spielleitung.schritt.entscheidung'), [
    _absatz(k, k.ui('ui.druck.spielleitung.entscheidung')),
  ]),
  ..._block(k, k.ui('ui.druck.spielleitung.schritt.gruppenwahl'), [
    _absatz(k, k.ui(k.satz.stimmkarten.isEmpty ? 'ui.druck.spielleitung.gruppenwahl_kern' : 'ui.druck.spielleitung.gruppenwahl')),
    _absatz(k, k.ui('ui.druck.spielleitung.wertseite')),
    _codetabelle(k, heft.auszaehlung.firstWhere((a) => a.runde == r)),
    _auszaehlung(k, heft.auszaehlung.firstWhere((a) => a.runde == r)),
    _absatz(k, k.ui('ui.druck.spielleitung.auszaehlung.unter0')),
  ]),
  ..._block(k, k.ui('ui.druck.spielleitung.schritt.umschlag'), [
    _absatz(k, k.ui('ui.druck.spielleitung.umschlag')),
  ]),
  // Jedes Fach des Resümees bleibt mit seiner Überschrift auf einer Seite.
  ..._block(k, k.ui('ui.druck.spielleitung.schritt.resuemee'), [
    _fach([
      _unterlabel(k, k.ui('ui.druck.spielleitung.resuemee.gruppe')),
      _vorlesen(k, k.text(heft.resuemeeGruppe[r]!)),
    ]),
    _fach([
      _unterlabel(k, k.ui('ui.druck.spielleitung.resuemee.rest')),
      _absatz(k, k.ui('ui.druck.spielleitung.rest.anleitung')),
      _absatz(k, k.ui('ui.druck.spielleitung.rest.suche')),
    ]),
    _fach([
      _unterlabel(k, k.ui('ui.druck.spielleitung.resuemee.lage')),
      _absatz(k, k.ui('ui.druck.spielleitung.lage.anleitung')),
      _marke(k, k.ui('ui.druck.spielleitung.vorlesen')),
      _lage(k, heft.resuemeeLage[r]!),
    ]),
  ]),
];

List<pw.Widget> _anklage(DruckKontext k, Spielleitungsheft heft) => [
  _titel(k, k.ui('ui.druck.spielleitung.schritt.anklage')),
  _absatz(k, k.ui('ui.druck.spielleitung.anklage.klagt')),
  _vorlesen(k, k.text(heft.anklage)),
  _absatz(k, k.ui('ui.druck.spielleitung.anklage.aufloesung')),
  _absatz(k, k.ui('ui.druck.spielleitung.anklage.punkte')),
  _absatz(k, k.ui('ui.druck.spielleitung.anklage.ende')),
  _absatz(k, k.ui('ui.druck.spielleitung.anklage.aufloesung_alle', {'alle': k.ui('ui.druck.aufloesung.alle'), 'rollen': k.ui('ui.druck.aufloesung.rollen')})),
];

List<pw.Widget> _anhang(DruckKontext k, Spielleitungsheft heft) => [
  _titel(k, k.ui('ui.druck.spielleitung.anhang')),
  _absatz(k, k.ui('ui.druck.spielleitung.anhang.einleitung')),
  _marke(k, k.ui('ui.druck.spielleitung.vorlesen')),
  pw.Table(
    border: _gitter(),
    columnWidths: {
      0: const pw.FixedColumnWidth(170),
      1: const pw.FlexColumnWidth(),
    },
    children: [
      pw.TableRow(
        decoration: _kopfFarbe(),
        children: [
          _zelle(
            pw.Text(
              k.ui('ui.druck.spielleitung.anhang.namen'),
              style: k.stil.ueberschrift(10),
            ),
          ),
          _zelle(
            pw.Text(
              k.ui('ui.druck.spielleitung.anhang.text'),
              style: k.stil.ueberschrift(10),
            ),
          ),
        ],
      ),
      for (final e in heft.resuemeeRest.entries)
        pw.TableRow(
          children: [
            _zelle(
              pw.Text(
                [
                  for (final id in e.key.split('_')) k.figurName(id),
                ].join(' · '),
                style: k.stil.text(10),
              ),
            ),
            _zelle(pw.Text(k.text(e.value), style: k.stil.text(10))),
          ],
        ),
    ],
  ),
];

/// Codetabelle der Runde: jeder Wertcode mit seinem Wert, nach Code sortiert, vier Paare je Zeile.
pw.Widget _codetabelle(DruckKontext k, Auszaehlung a) {
  const proZeile = 4;
  final codes = [...a.werte.keys]..sort();
  String wert(int w) => w > 0 ? '+$w' : (w < 0 ? '−${-w}' : '0');
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Table(
      border: _gitter(),
      children: [
        pw.TableRow(
          decoration: _kopfFarbe(),
          children: [
            for (var i = 0; i < proZeile; i++) ...[
              _zelle(pw.Text(k.ui('ui.druck.spielleitung.auszaehlung.code'), style: k.stil.ueberschrift(10))),
              _zelle(pw.Text(k.ui('ui.druck.spielleitung.auszaehlung.wert'), style: k.stil.ueberschrift(10))),
            ],
          ],
        ),
        for (var z = 0; z < codes.length; z += proZeile)
          pw.TableRow(
            children: [
              for (var i = z; i < z + proZeile; i++) ...[
                _zelle(pw.Text(i < codes.length ? codes[i] : '', style: k.stil.ueberschrift(10))),
                _zelle(pw.Text(i < codes.length ? wert(a.werte[codes[i]]!) : '', style: k.stil.text(10))),
              ],
            ],
          ),
      ],
    ),
  );
}

pw.Widget _auszaehlung(DruckKontext k, Auszaehlung a) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 6),
  child: pw.Table(
    border: _gitter(),
    columnWidths: {
      0: const pw.FixedColumnWidth(200),
      1: const pw.FixedColumnWidth(140),
    },
    children: [
      pw.TableRow(
        decoration: _kopfFarbe(),
        children: [
          _zelle(
            pw.Text(
              k.ui('ui.druck.spielleitung.auszaehlung.summe'),
              style: k.stil.ueberschrift(10),
            ),
          ),
          _zelle(
            pw.Text(
              k.ui('ui.druck.spielleitung.auszaehlung.umschlag'),
              style: k.stil.ueberschrift(10),
            ),
          ),
        ],
      ),
      for (final st in a.stufen)
        pw.TableRow(
          children: [
            _zelle(
              pw.Text(
                k.ui('ui.druck.spielleitung.auszaehlung.ab', {
                  'summe': '${st.abSumme}',
                }),
                style: k.stil.text(11),
              ),
            ),
            _zelle(pw.Text(st.umschlag, style: k.stil.ueberschrift(11))),
          ],
        ),
    ],
  ),
);

pw.Widget _lage(DruckKontext k, Map<String, String> lage) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 6),
  child: pw.Table(
    border: _gitter(),
    columnWidths: {
      0: const pw.FixedColumnWidth(100),
      1: const pw.FlexColumnWidth(),
    },
    children: [
      for (final (stufe, baustein) in _lagen)
        pw.TableRow(
          children: [
            _zelle(pw.Text(k.ui(baustein), style: k.stil.ueberschrift(10))),
            _zelle(pw.Text(k.text(lage[stufe]!), style: k.stil.text(10))),
          ],
        ),
    ],
  ),
);

/// Die Befragungen der Runde [r]: feste mit Thema und Fragen, dann wie viele
/// freie Wahlen es gibt und unter wem ([frei] ist der Bausteinstamm der Zeile).
/// Mit [antworten] (Erzählerheft) folgt jeder Befragung ihre Antwort aus dem
/// Erzählerpaket, ohne Zeile ein eigener Satz über die Befragte (nicht die
/// Du-Form des Rollenhefts); der Detektivbogen zeigt nie eine Antwort.
List<pw.Widget> _befragungen(DruckKontext k, int r, String frei, {bool antworten = false}) {
  final br = k.satz.befragungen[r]!;
  final antwort = {
    if (antworten)
      for (final b in k.satz.erzaehler[r]?.befragungen ?? const []) b.rolle: b.antwort,
  };
  pw.Widget eintrag(String rolle) => _fach([
        pw.Text(k.ui('ui.druck.befragung.zeile', {'name': k.figurName(rolle), 'thema': br.text(rolle).thema}), style: k.stil.ueberschrift(10.5)),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10, top: 1, bottom: 5),
          child: pw.Text([for (final f in br.text(rolle).fragen) '– $f'].join('\n'), style: k.stil.text(10)),
        ),
        if (antwort[rolle] case final zeilen?) ...[
          pw.Padding(padding: const pw.EdgeInsets.only(left: 10), child: _marke(k, k.ui('ui.druck.erzaehler.antwort'))),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10, top: 2, bottom: 6),
            child: pw.Text(zeilen.isEmpty ? k.ui('ui.druck.erzaehler.nichts') : [for (final z in zeilen) '– $z'].join('\n'), style: k.stil.text(10)),
          ),
        ],
      ]);
  return [
    for (final rolle in br.pflicht) eintrag(rolle),
    if (br.freiWahlen > 0) ...[
      _absatz(k, k.ui('${frei}_${br.freiWahlen}')),
      for (final rolle in br.frei) eintrag(rolle),
    ],
  ];
}

// Detektivbogen

List<pw.Widget> _entscheidung(DruckKontext k, BogenEntscheidung b) => [
  _marke(k, k.ui('ui.druck.bogen.entscheidung', {'nr': '${b.nr}'})),
  pw.SizedBox(height: 3),
  pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(b.frage, style: k.stil.ueberschrift(12)),
  ),
  for (final o in b.optionen)
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _kaestchen(),
          pw.SizedBox(width: 9),
          pw.Expanded(child: pw.Text(o.text, style: k.stil.text(11))),
          pw.SizedBox(width: 10),
          pw.Text(
            k.ui('ui.druck.bogen.karte', {'code': o.karte}),
            style: k.stil.ueberschrift(10),
          ),
        ],
      ),
    ),
  pw.SizedBox(height: 3),
  pw.Row(
    children: [
      pw.Text(k.ui('ui.druck.bogen.gewaehlt'), style: k.stil.klein()),
      pw.SizedBox(width: 6),
      _linie(120),
    ],
  ),
  pw.SizedBox(height: 14),
];

List<pw.Widget> _ermittlungsbogen(DruckKontext k) {
  final eb = k.satz.ermittlungsbogen;
  return [
    _titel(k, k.ui('ui.druck.bogen.ermittlung')),
    _absatz(k, k.text('ermittlungsbogen.einleitung')),
    // Restverdächtige: Namen zum Durchstreichen (wortgleich aus dem Kanon).
    _absatz(k, k.text('ermittlungsbogen.restverdaechtige')),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        children: [
          for (final p in eb.personen)
            pw.Container(
              margin: const pw.EdgeInsets.only(right: 22),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.linie, width: 0.8)),
              child: pw.Text(k.figurName(p), style: k.stil.ueberschrift(14)),
            ),
        ],
      ),
    ),
    pw.Table(
      border: _gitter(),
      columnWidths: {
        0: const pw.FixedColumnWidth(122),
        1: const pw.FixedColumnWidth(66),
        for (var i = 0; i < eb.personen.length; i++)
          i + 2: const pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(
          decoration: _kopfFarbe(),
          children: [
            _zelle(
              pw.Text(
                k.ui('ui.druck.bogen.tabelle.art'),
                style: k.stil.ueberschrift(10),
              ),
            ),
            _zelle(
              pw.Text(
                k.ui('ui.druck.bogen.tabelle.lage'),
                style: k.stil.ueberschrift(10),
              ),
            ),
            for (final p in eb.personen)
              _zelle(pw.Text(k.figurName(p), style: k.stil.ueberschrift(10))),
          ],
        ),
        for (final typ in eb.typen)
          pw.TableRow(
            children: [
              _zelle(
                pw.Text(
                  k.ui('ui.druck.bogen.typ.$typ'),
                  style: k.stil.text(10),
                ),
              ),
              _zelle(
                pw.Text(_lageZu(k, eb, typ), style: k.stil.ueberschrift(10)),
              ),
              for (final _ in eb.personen)
                pw.Container(
                  height: 24,
                  alignment: pw.Alignment.center,
                  child: _kaestchen(),
                ),
            ],
          ),
      ],
    ),
    pw.SizedBox(height: 8),
    _absatz(k, k.ui('ui.druck.bogen.karten.hinweis')),
    ..._block(k, k.ui('ui.druck.bogen.ausscheiden'), [
      for (final r in eb.regeln) _absatz(k, eb.regelText[r.id]!),
    ]),
    ..._block(k, k.ui('ui.druck.bogen.tabelle.lage'), [
      _absatz(k, k.ui('ui.druck.bogen.lage')),
    ]),
  ];
}

List<pw.Widget> _anklageBogen(DruckKontext k) => [
  pw.SizedBox(height: 16),
  _titel(k, k.ui('ui.druck.bogen.anklage')),
  _absatz(k, k.text('detektiv.regeln.anklage')),
  pw.SizedBox(height: 10),
  pw.Row(
    children: [
      pw.Text(k.ui('ui.druck.bogen.angeklagt'), style: k.stil.klein(10)),
      pw.SizedBox(width: 8),
      _linie(300),
    ],
  ),
  pw.SizedBox(height: 16),
  pw.Row(
    children: [
      pw.Text(k.ui('ui.druck.bogen.punkte'), style: k.stil.klein(10)),
      pw.SizedBox(width: 8),
      _linie(60),
      pw.SizedBox(width: 8),
      pw.Text(
        k.ui('ui.druck.bogen.von', {
          'anzahl': '${k.satz.detektivbogen.length}',
        }),
        style: k.stil.klein(10),
      ),
    ],
  ),
];

/// Lage einer Art im Ermittlungsbogen: wie der Erzähler sie wertet (Schlüsselbeweis klar, belastende Art Spur).
String _lageZu(DruckKontext k, Ermittlungsbogen eb, String typ) {
  if (typ == 'schluesselbeweis') return k.ui('ui.druck.bogen.lage.klar');
  return eb.belastend.contains(typ) ? k.ui('ui.druck.bogen.lage.spur') : '';
}

// Gemeinsame Bausteine der beiden Teile

List<pw.Widget> _kopf(DruckKontext k, String marke, String titel) => [
  _marke(k, marke),
  pw.SizedBox(height: 3),
  pw.Text(titel, style: k.stil.titel()),
  pw.SizedBox(height: 6),
  _linie(DruckStil.breite),
  pw.SizedBox(height: 12),
];

/// Fuß: Falltitel und Seitenzahl, nie ein Pfad (9 pt statt 8 pt aus stil.fuss).
pw.Widget _fuss(DruckKontext k, String links, pw.Context c) => pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    pw.Text(links, style: k.stil.klein()),
    pw.Text('${c.pageNumber} / ${c.pagesCount}', style: k.stil.klein()),
  ],
);

/// Abschnitt mit kleiner Marke als Überschrift (wie `stil.kopf`, aber 9 pt).
/// Ein Fach, das nicht über eine Seitengrenze bricht.
pw.Widget _fach(List<pw.Widget> inhalt) =>
    pw.Inseparable(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: inhalt));

/// Die Marke bleibt mit dem ersten Inhalt zusammen: keine Überschrift allein am Seitenende.
List<pw.Widget> _block(DruckKontext k, String label, List<pw.Widget> inhalt) =>
    [
      pw.SizedBox(height: 4),
      pw.Inseparable(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _marke(k, label),
            pw.SizedBox(height: 3),
            if (inhalt.isNotEmpty) inhalt.first,
          ],
        ),
      ),
      ...inhalt.skip(1),
      pw.SizedBox(height: 8),
    ];

/// Vorlesetext: links die Marke „Vorlesen“ (im Intro mit der Dia-Nummer als
/// Stichwort darunter), rechts der Baustein wortgleich.
pw.Widget _vorlesen(DruckKontext k, String text, {int? dia}) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 6),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: 72,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _marke(k, k.ui('ui.druck.spielleitung.vorlesen')),
            if (dia != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(k.ui('ui.druck.erzaehler.dia', {'nr': '$dia'}), style: k.stil.ueberschrift(11)),
            ],
          ],
        ),
      ),
      pw.Expanded(child: pw.Text(text, style: k.stil.text(11))),
    ],
  ),
);

/// Die Tischgespräche der Runde [r] aus dem Erzählerpaket: wer mit wem worüber, darunter die Stichpunkte.
List<pw.Widget> _tisch(DruckKontext k, int r) => [
  for (final t in k.satz.erzaehler[r]?.tisch ?? const [])
    _fach([
      pw.Text(
        k.ui('ui.druck.erzaehler.tisch_zeile', {'sprecher': k.figurName(t.sprecher), 'partner': _name(k, t.partner), 'thema': t.thema}),
        style: k.stil.ueberschrift(10.5),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 10, top: 1, bottom: 5),
        child: pw.Text([for (final z in t.stichpunkte) '– $z'].join('\n'), style: k.stil.text(10)),
      ),
    ]),
];

String _name(DruckKontext k, String id) => id == Besetzung.detektiv ? k.ui('ui.druck.rollen.detektiv') : k.figurName(id);

pw.Widget _titel(DruckKontext k, String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 6, bottom: 6),
  child: pw.Text(text, style: k.stil.ueberschrift(14)),
);

pw.Widget _unterlabel(DruckKontext k, String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 2, bottom: 3),
  child: pw.Text(text, style: k.stil.ueberschrift(10.5)),
);

pw.Widget _absatz(DruckKontext k, String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 5),
  child: pw.Text(text, style: k.stil.text(11)),
);

pw.Widget _marke(DruckKontext k, String text) =>
    pw.Text(text.toUpperCase(), style: k.stil.marke(9));

pw.Widget _zelle(pw.Widget inhalt) =>
    pw.Padding(padding: const pw.EdgeInsets.all(5), child: inhalt);

pw.TableBorder _gitter() =>
    pw.TableBorder.all(color: DruckStil.linie, width: 0.6);

pw.BoxDecoration _kopfFarbe() => pw.BoxDecoration(color: PdfColors.grey200);

pw.Widget _linie(double breite) =>
    pw.Container(width: breite, height: 0.6, color: DruckStil.linie);

pw.Widget _kaestchen() => pw.Container(
  width: 10,
  height: 10,
  decoration: pw.BoxDecoration(
    border: pw.Border.all(color: DruckStil.tinte, width: 0.8),
  ),
);
