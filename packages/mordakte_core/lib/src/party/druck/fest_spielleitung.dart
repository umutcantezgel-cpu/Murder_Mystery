import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../besetzung.dart';
import 'fest_steckbrief.dart';
import 'modell.dart';
import 'paket.dart';
import 'satz.dart';
import 'satz_fest.dart';

// Detektivbogen und Erzählerheft im festlichen Stil (Druckpaket, Abend am Bildschirm).
// Inhalte wie im Druckspiel (spielleitung.dart), ohne das, was nur der Abend auf
// Papier braucht: keine Kartencodes, keine Auszählung, kein Fall-Code.
//   Detektivbogen: Auftrag, Regeln, je Runde die Befragungen (nur Fragen) und die
//   Entscheidungen zum Ankreuzen, Ermittlungsbogen, Anklage. Nie eine Antwort.
//   Erzählerheft: Vorlesetexte mit Dia-Nummer, je Runde Rundenstart, Befragungen mit
//   Antworten und alle Tischgespräche (Erzählerpaket). Nie die Lösung.

// ---------------------------------------------------------------- Detektivbogen

/// Der Detektivbogen für die Detektivin (`w`) oder den Detektiv (`m`).
Future<DruckDatei> festDetektivbogenDatei(PaketKontext k, String g) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.fest.bogen.titel')}');
  festDetektivbogen(doc, k, g);
  return DruckDatei('detektivbogen-${g == 'w' ? 'detektivin' : 'detektiv'}.pdf', await k.stil.speichern(doc), figur: Besetzung.detektiv);
}

void festDetektivbogen(pw.Document doc, PaketKontext k, String g) {
  final s = k.stil;
  final f = festFigur(k, Besetzung.detektiv, detektiv: g);
  final farbe = PdfColor.fromHex(f.farbe);
  final nur = k.ui('ui.druck.fest.bogen.nur.$g');
  final theme = s.seite(falltitel: k.fallTitel, marke: k.ui('ui.druck.fest.bogen.titel'), fuss: nur, seitenzahl: k.seite, lasche: farbe, laschenText: f.name);
  doc.addPage(
    pw.Page(
      pageTheme: theme,
      build: (c) => s.mitNotizen(
        [
          // Kopf: Porträt, Name, Stempel.
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 4, top: 6),
                child: s.fotoabzug(k.bild(Besetzung.detektiv, detektiv: g), 170, neigung: -0.035),
              ),
              pw.SizedBox(width: 26),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 6),
                    pw.Text(k.ui('ui.druck.fest.bogen.titel').toUpperCase(), style: s.marke(10.5, FestStil.stempelrot)),
                    pw.SizedBox(height: 4),
                    pw.Text(f.name, style: s.titel(38)),
                    pw.Text(f.titel, style: s.kursiv(13, FestStil.tinteLeise)),
                    pw.SizedBox(height: 16),
                    s.stempel(nur, g: 11, neigung: -0.05),
                    pw.SizedBox(height: 16),
                    pw.Text(k.ui('ui.druck.fest.bogen.hinweis'), style: s.kursiv(11.5)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 22),
          s.kopfzeile(k.ui('ui.druck.fest.bogen.auftrag'), farbe: farbe),
          s.feld(pw.Text(k.text('detektiv.$g.auftrag'), style: s.text(12)), farbe: farbe),
          pw.SizedBox(height: 16),
          s.kopfzeile(k.ui('ui.druck.bogen.regeln'), farbe: farbe),
          s.punkte(
            [k.text('detektiv.regeln.entscheidungen'), k.text('detektiv.regeln.hinweise'), k.text('detektiv.regeln.punkte'), k.ui('ui.druck.fest.bogen.app')],
            g: 12,
            abstand: 6,
          ),
        ],
        marke: k.ui('ui.druck.fest.notizen'),
        wo: 'Detektivbogen Seite 1',
      ),
    ),
  );
  // Je Runde zwei feste Seiten: die Befragungen, dann die Entscheidungen; freier Platz wird zu Notizen.
  for (var r = 1; r <= 3; r++) {
    final runde = k.ui('ui.druck.bogen.runde', {'nr': '$r'});
    if (k.druck.satz.befragungen.isNotEmpty) {
      doc.addPage(pw.Page(
        pageTheme: theme,
        build: (c) => s.mitNotizen(
          [
            _rundenKopf(k, runde),
            s.kopfzeile(k.ui('ui.druck.bogen.befragungen'), farbe: farbe, g: 15),
            ..._befragungen(k, r, 'ui.druck.bogen.befragungen_frei'),
          ],
          marke: k.ui('ui.druck.fest.notizen'),
          wo: 'Detektivbogen Befragungen $r',
        ),
      ));
    }
    doc.addPage(pw.Page(
      pageTheme: theme,
      build: (c) => s.mitNotizen(
        [
          _rundenKopf(k, runde),
          for (final b in k.druck.satz.detektivbogen.where((b) => b.runde == r))
            pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: _entscheidung(k, b)),
        ],
        marke: k.ui('ui.druck.fest.notizen'),
        wo: 'Detektivbogen Entscheidungen $r',
      ),
    ));
  }
  doc.addPage(pw.Page(
    pageTheme: theme,
    build: (c) => s.spalte(wo: 'Ermittlungsbogen', quer: pw.CrossAxisAlignment.start, [
      ..._ermittlungsbogen(k, farbe),
      pw.Spacer(),
      ..._anklage(k, farbe),
    ]),
  ));
}

pw.Widget _rundenKopf(PaketKontext k, String titel) {
  final s = k.stil;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 12),
    child: pw.Row(
      children: [
        pw.Text(titel, style: s.titel(30)),
        pw.SizedBox(width: 16),
        pw.Expanded(child: pw.Container(height: 0.5, color: FestStil.linie)),
        pw.SizedBox(width: 8),
        s.raute(7, FestStil.kerze),
      ],
    ),
  );
}

/// Eine Entscheidung: Frage, Möglichkeiten zum Ankreuzen (Reihenfolge wie in der App)
/// und eine Notizzeile. Nie ein Kartencode, nie eine Antwort.
pw.Widget _entscheidung(PaketKontext k, BogenEntscheidung b) {
  final s = k.stil;
  return s.karteikarte(
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        s.feldmarke(k.ui('ui.druck.bogen.entscheidung', {'nr': '${b.nr}'}), farbe: FestStil.stempelrot),
        pw.Text(b.frage, style: s.titel(13)),
        pw.SizedBox(height: 6),
        for (final o in b.optionen)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(padding: const pw.EdgeInsets.only(top: 2), child: s.kaestchen(10)),
                pw.SizedBox(width: 8),
                pw.Expanded(child: pw.Text(o.text, style: s.text(10.5))),
              ],
            ),
          ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Text(k.ui('ui.druck.fest.bogen.notiz'), style: s.hand(14)),
            pw.SizedBox(width: 8),
            pw.Expanded(child: pw.Container(height: 0.6, color: FestStil.linieZart)),
          ],
        ),
      ],
    ),
    innen: const pw.EdgeInsets.fromLTRB(12, 9, 12, 9),
  );
}

List<pw.Widget> _ermittlungsbogen(PaketKontext k, PdfColor farbe) {
  final s = k.stil;
  final eb = k.druck.satz.ermittlungsbogen;
  pw.Widget zelle(pw.Widget w, {bool mitte = false}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3.2),
    alignment: mitte ? pw.Alignment.center : pw.Alignment.centerLeft,
    child: w,
  );
  return [
    _rundenKopf(k, k.ui('ui.druck.bogen.ermittlung')),
    pw.Text(k.text('ermittlungsbogen.einleitung'), style: s.text(11)),
    pw.SizedBox(height: 6),
    pw.Text(k.text('ermittlungsbogen.restverdaechtige'), style: s.text(11)),
    pw.SizedBox(height: 6),
    pw.Row(
      children: [
        for (final (i, p) in eb.personen.indexed)
          pw.Expanded(
            child: pw.Column(
              children: [
                s.fotoabzug(k.bild(p, klein: true), 52, neigung: i.isEven ? -0.03 : 0.03, klebeband: false),
                pw.SizedBox(height: 4),
                pw.Text(k.figurName(p), style: s.titel(15)),
              ],
            ),
          ),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: FestStil.linieZart, width: 0.6),
        top: pw.BorderSide(color: FestStil.linie, width: 0.8),
        bottom: pw.BorderSide(color: FestStil.linie, width: 0.8),
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(120),
        1: const pw.FixedColumnWidth(56),
        for (var i = 0; i < eb.personen.length; i++) i + 2: const pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: FestStil.papierTief),
          children: [
            zelle(pw.Text(k.ui('ui.druck.bogen.tabelle.art').toUpperCase(), style: s.marke(8))),
            zelle(pw.Text(k.ui('ui.druck.bogen.tabelle.lage').toUpperCase(), style: s.marke(8))),
            for (final p in eb.personen) zelle(pw.Text(k.figurName(p), style: s.titel(11)), mitte: true),
          ],
        ),
        for (final typ in eb.typen)
          pw.TableRow(
            children: [
              zelle(pw.Text(k.ui('ui.druck.bogen.typ.$typ'), style: s.text(10.5))),
              zelle(pw.Text(_lage(k, eb, typ), style: s.marke(8.5, FestStil.stempelrot))),
              for (final _ in eb.personen) zelle(s.kaestchen(11), mitte: true),
            ],
          ),
      ],
    ),
    pw.SizedBox(height: 8),
    s.kopfzeile(k.ui('ui.druck.bogen.ausscheiden'), farbe: farbe, g: 14),
    s.punkte([for (final r in eb.regeln) eb.regelText[r.id]!], g: 10.5, abstand: 4),
    pw.SizedBox(height: 6),
    s.feld(pw.Text(k.ui('ui.druck.bogen.lage'), style: s.kursiv(10.5)), farbe: FestStil.messing),
  ];
}

String _lage(PaketKontext k, Ermittlungsbogen eb, String typ) {
  if (typ == 'schluesselbeweis') return k.ui('ui.druck.bogen.lage.klar');
  return eb.belastend.contains(typ) ? k.ui('ui.druck.bogen.lage.spur') : '';
}

List<pw.Widget> _anklage(PaketKontext k, PdfColor farbe) {
  final s = k.stil;
  return [
    pw.Inseparable(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          s.kopfzeile(k.ui('ui.druck.bogen.anklage'), farbe: FestStil.stempelrot, g: 18),
          pw.Text(k.text('detektiv.regeln.anklage'), style: s.text(11.5)),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              pw.Text(k.ui('ui.druck.bogen.angeklagt'), style: s.titel(14)),
              pw.SizedBox(width: 10),
              pw.Expanded(child: pw.Container(height: 0.8, color: FestStil.tinte)),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Row(
            children: [
              pw.Text(k.ui('ui.druck.bogen.punkte'), style: s.titel(14)),
              pw.SizedBox(width: 10),
              pw.Container(width: 60, height: 0.8, color: FestStil.tinte),
              pw.SizedBox(width: 8),
              pw.Text(k.ui('ui.druck.bogen.von', {'anzahl': '${k.druck.satz.detektivbogen.length}'}), style: s.text(12)),
            ],
          ),
        ],
      ),
    ),
  ];
}

/// Die Befragungen einer Runde: feste mit Thema und Fragen, dann wie viele freie Wahlen
/// es gibt und unter wem ([frei] ist der Bausteinstamm). Mit [antworten] (Erzählerheft)
/// folgt jeder Befragung ihre Antwort aus dem Erzählerpaket; der Detektivbogen nie.
List<pw.Widget> _befragungen(PaketKontext k, int r, String frei, {bool antworten = false, pw.Widget? kopf}) {
  final s = k.stil;
  final br = k.druck.satz.befragungen[r]!;
  final antwort = {
    if (antworten)
      for (final b in k.druck.satz.erzaehler[r]?.befragungen ?? const []) b.rolle: b.antwort,
  };
  pw.Widget eintrag(String rolle) => pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      s.medaillon(k.bild(rolle, klein: true), 26, ring: k.farbe(rolle)),
      pw.SizedBox(width: 10),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(k.ui('ui.druck.befragung.zeile', {'name': k.figurName(rolle), 'thema': br.text(rolle).thema}), style: s.titel(11.5)),
            pw.SizedBox(height: 2),
            s.punkte(br.text(rolle).fragen, g: 10, farbe: FestStil.messing, abstand: 1, stil: _eng(s)),
            if (antwort[rolle] case final zeilen?) ...[
              pw.SizedBox(height: 3),
              s.feld(
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    s.feldmarke(k.ui('ui.druck.erzaehler.antwort'), farbe: FestStil.stempelrot, g: 8),
                    if (zeilen.isEmpty)
                      pw.Text(k.ui('ui.druck.erzaehler.nichts'), style: s.text(10))
                    else
                      s.punkte(zeilen, g: 10, farbe: FestStil.stempelrot, abstand: 1, stil: _eng(s)),
                  ],
                ),
                farbe: FestStil.stempelrot,
                grund: FestStil.karte,
                innen: const pw.EdgeInsets.fromLTRB(10, 5, 8, 4),
              ),
            ],
          ],
        ),
      ),
    ],
  );
  return [
    ...s.zweispaltig([for (final rolle in br.pflicht) eintrag(rolle)], kopf: kopf),
    if (br.freiWahlen > 0) ...[
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 2, bottom: 6),
        child: pw.Text(k.ui('${frei}_${br.freiWahlen}'), style: s.kursiv(11, FestStil.tinteLeise)),
      ),
      ...s.zweispaltig([for (final rolle in br.frei) eintrag(rolle)]),
    ],
  ];
}

// ---------------------------------------------------------------- Erzählerheft

/// Das Erzählerheft für den Abend am Bildschirm (wie `erzaehlerheftDatei(druckspiel: false)`).
Future<DruckDatei> festErzaehlerheftDatei(PaketKontext k) async {
  final doc = k.stil.neuesDokument('${k.fallTitel} · ${k.ui('ui.druck.fest.erzaehler.titel')}');
  festErzaehlerheft(doc, k);
  return DruckDatei('erzaehlerheft.pdf', await k.stil.speichern(doc));
}

void festErzaehlerheft(pw.Document doc, PaketKontext k) {
  final s = k.stil;
  final heft = k.druck.satz.spielleitung;
  final nur = k.ui('ui.druck.fest.erzaehler.nur');
  final theme = s.seite(falltitel: k.fallTitel, marke: k.ui('ui.druck.fest.erzaehler.titel'), fuss: nur, seitenzahl: k.seite, markeFarbe: FestStil.stempelrot);
  doc.addPage(pw.Page(pageTheme: theme, build: (c) => _erzaehlerDeckblatt(k)));
  doc.addPage(
    pw.MultiPage(
      pageTheme: theme,
      build: (c) => [
        _rundenKopf(k, k.ui('ui.druck.spielleitung.intro')),
        for (var i = 0; i < heft.intro.length; i++) _introStueck(k, heft.intro[i], i),
        // Die Runden laufen ohne erzwungenen Seitenwechsel weiter (keine halb leeren Seiten);
        // Rundenkopf und erster Vorlesetext bleiben zusammen.
        for (var r = 1; r <= 3; r++) ...[
          pw.Inseparable(
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
              pw.SizedBox(height: r == 1 ? 0 : 14),
              _rundenKopf(k, k.ui('ui.druck.spielleitung.runde', {'nr': '$r'})),
              s.kopfzeile(k.ui('ui.druck.spielleitung.schritt.start'), g: 14),
              _vorlesen(k, k.text(heft.rundenStart[r]!.first)),
            ]),
          ),
          for (final b in heft.rundenStart[r]!.skip(1)) _vorlesen(k, k.text(b)),
          if (k.druck.satz.befragungen.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            ..._befragungen(k, r, 'ui.druck.spielleitung.befragungen_frei', antworten: true, kopf: s.kopfzeile(k.ui('ui.druck.spielleitung.schritt.befragungen'), g: 14)),
            pw.SizedBox(height: 8),
            ..._tisch(k, r, kopf: s.kopfzeile(k.ui('ui.druck.erzaehler.tisch'), g: 14)),
          ],
        ],
      ],
    ),
  );
}

pw.Widget _erzaehlerDeckblatt(PaketKontext k) {
  final s = k.stil;
  return s.spalte(wo: 'Erzählerheft Deckblatt', quer: pw.CrossAxisAlignment.center, [
    pw.SizedBox(height: 40),
    s.siegel(96, wachs: true),
    pw.SizedBox(height: 22),
    pw.Text(k.ui('ui.druck.fest.erzaehler.titel'), style: s.titel(48)),
    pw.SizedBox(height: 2),
    pw.Text(k.fallTitel, style: s.kursiv(16, FestStil.tinteLeise)),
    pw.SizedBox(height: 12),
    s.zierlinie(240),
    pw.SizedBox(height: 12),
    pw.Text(k.ui('ui.druck.spielleitung.personen', {'anzahl': '${k.rollen}'}).toUpperCase(), style: s.marke(10.5)),
    pw.SizedBox(height: 22),
    s.stempel(k.ui('ui.druck.fest.erzaehler.nur'), g: 12.5, neigung: -0.04),
    pw.Spacer(),
    pw.SizedBox(
      width: FestStil.breite - 50,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(k.ui('ui.druck.spielleitung.willkommen'), style: s.text(12)),
          pw.SizedBox(height: 6),
          pw.Text(k.ui('ui.druck.erzaehler.app'), style: s.text(12)),
          pw.SizedBox(height: 6),
          pw.Text(k.ui('ui.druck.spielleitung.ablauf.einleitung'), style: s.text(12)),
          pw.SizedBox(height: 6),
          pw.Text(k.ui('ui.druck.erzaehler.app_rest'), style: s.kursiv(12, FestStil.tinteLeise)),
          pw.SizedBox(height: 14),
          s.feld(pw.Text(k.ui('ui.druck.erzaehler.nur_du'), style: s.kursiv(12)), farbe: FestStil.stempelrot),
        ],
      ),
    ),
    pw.SizedBox(height: 20),
  ]);
}

/// Ein Stück der Einleitung mit seiner Dia-Nummer. Der Auftrag am Ende hängt davon ab,
/// ob eine Detektivin oder ein Detektiv ermittelt: Das Heft zeigt beide Fassungen nebeneinander.
pw.Widget _introStueck(PaketKontext k, String kennung, int i) {
  final dia = _dia(k, kennung, i);
  if (!RegExp(r'^intro\.auftrag\.[mw]$').hasMatch(kennung)) return _vorlesen(k, k.text(kennung), dia: dia);
  final basis = kennung.substring(0, kennung.length - 1);
  final s = k.stil;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: s.feld(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _vorlesenMarke(k, dia),
          for (final (j, g) in ['w', 'm'].indexed) ...[
            if (j > 0) pw.SizedBox(width: 14),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(k.ui('ui.druck.fest.erzaehler.fuer.$g'), style: s.hand(14)),
                  pw.Text(k.text('$basis$g'), style: s.text(10.5)),
                ],
              ),
            ),
          ],
        ],
      ),
      innen: const pw.EdgeInsets.fromLTRB(12, 7, 12, 7),
    ),
  );
}

int? _dia(PaketKontext k, String kennung, int i) {
  final d = k.druck.diashow;
  if (d == null) return i + 1;
  final nr = d.nrFuer(kennung);
  return nr == null ? null : nr + 1;
}

/// Vorlesetext: links Marke „Vorlesen“ und das Dia, rechts der Baustein wortgleich.
pw.Widget _vorlesen(PaketKontext k, String text, {int? dia}) {
  final s = k.stil;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 7),
    child: s.feld(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _vorlesenMarke(k, dia),
          pw.Expanded(child: pw.Text(text, style: s.text(11))),
        ],
      ),
      innen: const pw.EdgeInsets.fromLTRB(12, 7, 12, 7),
    ),
  );
}

pw.Widget _vorlesenMarke(PaketKontext k, int? dia) {
  final s = k.stil;
  return pw.SizedBox(
    width: 60,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(k.ui('ui.druck.spielleitung.vorlesen').toUpperCase(), style: s.marke(7.5, FestStil.stempelrot)),
        if (dia != null) ...[
          pw.SizedBox(height: 2),
          pw.Text(k.ui('ui.druck.erzaehler.dia', {'nr': '$dia'}), style: s.titel(14, FestStil.messing)),
        ],
      ],
    ),
  );
}

/// Die Tischgespräche der Runde aus dem Erzählerpaket: wer mit wem worüber, darunter die Stichpunkte.
List<pw.Widget> _tisch(PaketKontext k, int r, {pw.Widget? kopf}) {
  final s = k.stil;
  String name(String id) => id == Besetzung.detektiv ? k.ui('ui.druck.rollen.detektiv') : k.figurName(id);
  return s.zweispaltig(zeilenAbstand: 6, kopf: kopf, [
    for (final t in k.druck.satz.erzaehler[r]?.tisch ?? const [])
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          s.medaillon(k.bild(t.sprecher, klein: true), 24, ring: k.farbe(t.sprecher)),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  k.ui('ui.druck.erzaehler.tisch_zeile', {'sprecher': k.figurName(t.sprecher), 'partner': name(t.partner), 'thema': t.thema}),
                  style: s.titel(11),
                ),
                pw.SizedBox(height: 1),
                s.punkte(t.stichpunkte, g: 10, abstand: 1, stil: _eng(s)),
              ],
            ),
          ),
        ],
      ),
  ]);
}

/// Enger Listensatz für Fragen, Antworten und Stichpunkte.
pw.TextStyle _eng(FestStil s) => s.text(9.8).copyWith(lineSpacing: 1.4);
