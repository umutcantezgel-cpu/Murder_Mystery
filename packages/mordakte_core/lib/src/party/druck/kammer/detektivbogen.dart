/// Teil 01: Detektivbogen und Ermittlungsbogen (MECH 2, 10.1; RK 6; Kap. 8
/// und 16 der Fall-Bibel). A4 hoch, bei jeder Personenzahl genau
/// [kammerDetektivbogenSeiten] feste Seiten nach dem Seitenplan MECH 2.6 und
/// den Seitenangaben in RK 6:
///
/// 1. Titel, Dein Auftritt (RK 6.3, Vorlesen), Was du selbst weißt (MECH 1.6),
///    Was alle wissen (MECH 1.5).
/// 2. So ermittelst du: die Tischregeln in Kurzform („So spielt ihr“, MECH
///    1.4), Fragen-Leitfaden (RK 6.6), So gehst du mit Untersuchungen um (RK
///    6.7), Licht im Keller nach dem Knall (MECH 9.11 B).
/// 3. Kasten „Deine Aufgaben je Runde“ (RK 6.5), Untersuchungsliste: alle
///    Indizkarten nach Runde, darin nach Code, je Zeile Code, Titel, ab Runde,
///    Kästchen „gewählt in Runde“ und „Kein Bund“ (MECH 3.2, RK 6.7 Nr. 6).
/// 4. Ermittlungsbogen: Hinweis, Raster (MECH 2.1) mit Schreibraum, Felder
///    unter dem Raster, Hinweise zum Führen (RK 6.9), darunter die Regeln 2.3
///    und 2.4.
/// 5. Vermerke 1 bis 48, zweispaltig (Nr · Runde · Quelle · Vermerk, MECH 2.2).
/// 6. Anklagefeld mit Schreiblinien (MECH 2.5) und Hilfe (RK 6.10); „Wenn
///    Rollen fehlen“ für die heutige Personenzahl (RK 6.12 nennt keine Seite;
///    auf Seite 6 leitet der Hinweis für 6 bis 11 Personen die Aktionskarten
///    ein); bei 6 bis 11 Personen die Tipps zu den Aktionskarten der fehlenden
///    Zeugen (RK 6.8, MECH 4.6); Wenn Karten gegen dich gespielt werden (RK
///    6.8); freier Platz wird zu Notizlinien.
///
/// Die ganzen Tischregeln R-01 bis R-14 stehen nur im Erzählerheft (MECH 1.4,
/// 2.6: Teil 01 hat die Kurzform).
///
/// Lesetext steht je Seite in der größten Schrift von 11 pt abwärts, die die
/// Seite füllt, nie unter 9 pt. Passt eine Seite auch in 9 pt nicht, wird sie
/// mit halben Abständen noch einmal versucht (dichter Satz, Reserve für
/// längere Texte); passt sie auch so nicht, ist das ein [KammerUeberlauf] mit
/// Seite und Stelle. Raster und Vermerke füllen
/// ihre Seite mit Schreibraum (mindestens [_rasterMin] bzw. [_vermerkMin] je
/// Zeile). Jeder sichtbare Text kommt aus dem Inhalt (`detektiv.json`,
/// `gemeinsam.json`, `indizkarten.json`, `fall.json`, die Aktionskarten der
/// Rollen) und aus `ui/01.json` bzw. `ui/gemeinsam.json`.
library;

import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../satz_stil.dart';
import 'besetzung.dart';
import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Seiten von Teil 01 bei jeder Personenzahl (MECH 10.1: 6 / 6 / 6).
const kammerDetektivbogenSeiten = 6;

/// Setzt Teil 01 (Detektivbogen) in [doc].
void kammerDetektivbogen(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '01', (s) => _Bogen(k, s).setzen());

/// Schreibraum je Zeile des Rasters (Ort, Alibi, Heimlichtuerei): mindestens.
const double _rasterMin = 20 * KammerSatz.mm;

/// Schreibraum je Zeile des Rasters: höchstens (der Rest bleibt frei).
const double _rasterMax = 42 * KammerSatz.mm;

/// Höhe einer Vermerk-Zeile: mindestens (zwei kleine Schreibzeilen).
const double _vermerkMin = 8 * KammerSatz.mm;

class _Bogen {
  _Bogen(this.k, this.s);

  final KammerKontext k;
  final KammerSeiten s;

  static const _teil = '01';
  static final _breite = KammerSatz.satzBreite();

  /// Schriftgrößen: Lesetext von [_gStart] bis [_gMin] (Fließtext 9 pt), Tabellen.
  static const _gStart = 11.0;
  static const _gMin = KammerSatz.kleinsteGroesse;
  static const _gTabelle = 9.5;
  static const _gKlein = 9.0;

  KammerSatz get x => k.satz;
  KammerDetektiv get d => k.inhalt.detektiv;
  KammerGemeinsam get gemeinsam => k.inhalt.gemeinsam;
  KammerBesetzung get b => k.besetzung;
  DruckStil get stil => k.stil;

  String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui(_teil, schluessel, werte);
  String gm(String schluessel, [Map<String, String> werte = const {}]) => k.uiGemeinsam(schluessel, werte);

  // ---------------------------------------------------------------- Setzen

  void setzen() {
    _leseSeite('auftritt', _seite1);
    _leseSeite('so-ermittelst-du', _seite2);
    _leseSeite('untersuchungsliste', _seite3);
    _ermittlungsbogen();
    _vermerke();
    _leseSeite('anklage', _seite6, notizen: true);
    if (s.gesetzt != kammerDetektivbogenSeiten) {
      throw KammerUeberlauf.werfen(_teil, s.gesetzt, 'seitenplan', '${s.gesetzt} Seiten statt $kammerDetektivbogenSeiten');
    }
  }


  /// Dichter Satz: halbe Abstände (Überschriften, Listen, Kästen). Nur, wenn
  /// eine Seite mit den üblichen Abständen auch in [_gMin] nicht passt.
  bool _dicht = false;

  /// Eine feste Seite mit Lesetext in der größten Schrift von [_gStart]
  /// abwärts, bei der [bauen] auf die Seite passt; passt sie auch in [_gMin]
  /// nicht, noch einmal mit dichtem Satz ([_dicht]), danach [KammerUeberlauf].
  void _leseSeite(String wo, List<pw.Widget> Function(double g) bauen, {bool notizen = false}) {
    double groesse() => s.passendeGroesse((g) => x.spalte(bauen(g)), breite: _breite, hoehe: s.platz(), start: _gStart, min: _gMin, wo: wo);
    double g;
    try {
      g = groesse();
    } on KammerUeberlauf {
      _dicht = true;
      g = groesse();
    }
    s.seite(bauen(g), wo: wo, notizen: notizen, ausrichtung: pw.CrossAxisAlignment.stretch);
    _dicht = false;
  }

  // ---------------------------------------------------------------- Bausteine

  /// Abstand [h], im dichten Satz die Hälfte.
  double _a(double h) => _dicht ? h / 2 : h;

  /// Überschriften wie [KammerSatz.ueberschrift] (15 pt bzw. 12,5 pt), die
  /// Abstände im dichten Satz halb.
  pw.Widget _h1(String text) => _ueberschrift(text, 15, oben: 8, unten: 5);
  pw.Widget _h2(String text) => _ueberschrift(text, 12.5, oben: 5, unten: 3);

  pw.Widget _ueberschrift(String text, double g, {required double oben, required double unten}) => pw.Padding(
        padding: pw.EdgeInsets.only(top: _a(oben), bottom: _a(unten)),
        child: x.fett(text, groesse: g),
      );

  pw.EdgeInsets get _kastenInnen => _dicht ? const pw.EdgeInsets.fromLTRB(9, 5, 9, 5) : const pw.EdgeInsets.fromLTRB(9, 7, 9, 8);

  /// Fette Zeile in Lesegröße (Gruppentitel, Rundentitel, Kartenname).
  pw.Widget _fett(String text, double g) => x.fett(text, groesse: g);

  pw.Widget _abstand([double h = 6]) => pw.SizedBox(height: _a(h));

  /// Etikett vor dem ersten Doppelpunkt fett („Ziel:“, „Tipp-Runde:“), wenn
  /// der Text noch keine Auszeichnung hat und das Etikett kurz ist.
  String _etikett(String text) {
    final t = k.text(text);
    final i = t.indexOf(': ');
    if (t.contains('*') || i <= 0 || i > 40 || t.substring(0, i).contains('„')) return t;
    return '**${t.substring(0, i + 1)}**${t.substring(i + 1)}';
  }

  /// Namen der Aktionskarten vor einem Doppelpunkt fett („Einspruch:“), wenn
  /// der Text noch keine Auszeichnung hat (RK 6.8, Karten gegen den Detektiv).
  String _kartenNamenFett(String text) {
    var t = k.text(text);
    if (t.contains('*')) return t;
    for (final p in k.fall.plaetze) {
      final name = k.klartext(k.rolle(p).aktionskarte.name);
      t = t.replaceAll('$name: ', '**$name:** ');
    }
    return t;
  }

  /// Zelle einer eigenen Tabelle: Text in [g], fett für Köpfe.
  pw.Widget _zellText(String text, double g, {bool fett = false, bool leise = false, pw.TextAlign ausrichtung = pw.TextAlign.left}) => pw.Text(
        KammerSatz.glyphen(k.klartext(text)),
        style: (fett ? stil.ueberschrift(g) : stil.text(g)).copyWith(color: leise ? DruckStil.leise : null),
        textAlign: ausrichtung,
      );

  // ---------------------------------------------------------------- Seite 1

  List<pw.Widget> _seite1(double g) => [
        x.marke(u('fuer'), groesse: 9),
        _abstand(3),
        x.titel(k.teilTitel(_teil), groesse: 26),
        _abstand(3),
        pw.Text(
          KammerSatz.glyphen(k.klartext(gm('personen', {'personen': '${b.personen}', 'rollen': '${b.rollen}'}))),
          style: stil.klein(_gKlein),
        ),
        _abstand(6),
        _h2(u('deinAuftritt')),
        x.vorlesen(d.auftritt, groesse: g),
        _h2(u('wasDuSelbstWeisst')),
        x.liste(d.wasDuSelbstWeisst, groesse: g, abstand: _a(2)),
        _h2(gm('ueberschrift.wasAlleWissen')),
        x.liste(gemeinsam.wasAlleWissen, groesse: g, abstand: _a(2)),
      ];

  // ---------------------------------------------------------------- Seite 2

  List<pw.Widget> _seite2(double g) => [
        _h1(u('soErmittelstDu')),
        x.kasten([x.absatz(gemeinsam.soSpieltIhr, groesse: g)], marke: gm('ueberschrift.soSpieltIhr'), rahmen: 0.6, innen: _kastenInnen),
        _h2(u('fragenLeitfaden')),
        ..._leitfaden(g),
        _h2(u('untersuchungen')),
        x.liste(d.untersuchungen, nummer: KammerNummer.zahl, groesse: g, abstand: _a(1.5)),
        _h2(gm('ueberschrift.licht')),
        x.absatz(gemeinsam.licht, groesse: g),
      ];

  /// Fragen-Leitfaden (RK 6.6): Die Gruppen mit nummerierten Fragen (A, B, C)
  /// stehen in zwei Spalten, so geteilt, dass die höhere Spalte möglichst
  /// niedrig ist (kurze Fragen füllen die Breite sonst nicht); Gruppen ohne
  /// Nummern („Gut zu wissen“) darunter über die ganze Breite.
  List<pw.Widget> _leitfaden(double g) {
    final gruppen = [
      for (final gr in d.fragenLeitfaden)
        if (gr.fragen.any((f) => !k.leer(f.text))) gr,
    ];
    final nummeriert = [for (final gr in gruppen) if (gr.fragen.every((f) => f.nr != null)) gr];
    final rest = [for (final gr in gruppen) if (!nummeriert.contains(gr)) gr];
    const luecke = 14.0;
    final spaltenBreite = (_breite - luecke) / 2;
    double hoehe(Iterable<KammerLeitfadenGruppe> gs) => gs.isEmpty ? 0 : x.hoehe(x.spalte([for (final gr in gs) ..._leitfadenGruppe(gr, g)]), spaltenBreite);
    var teilung = nummeriert.length;
    var beste = double.infinity;
    for (var i = 1; i < nummeriert.length; i++) {
      final h = math.max(hoehe(nummeriert.take(i)), hoehe(nummeriert.skip(i)));
      if (h < beste) {
        beste = h;
        teilung = i;
      }
    }
    return [
      if (nummeriert.length < 2)
        for (final gr in nummeriert) ..._leitfadenGruppe(gr, g)
      else
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: x.spalte([for (final gr in nummeriert.take(teilung)) ..._leitfadenGruppe(gr, g)])),
          pw.SizedBox(width: luecke),
          pw.Expanded(child: x.spalte([for (final gr in nummeriert.skip(teilung)) ..._leitfadenGruppe(gr, g)])),
        ]),
      for (final gr in rest) ..._leitfadenGruppe(gr, g),
    ];
  }

  /// Eine Gruppe des Fragen-Leitfadens: Titel fett, Fragen mit Nummer (A1 …)
  /// in einer Spalte, Einträge ohne Nummer mit Strich. Leer aufgelöste fallen weg.
  List<pw.Widget> _leitfadenGruppe(KammerLeitfadenGruppe gruppe, double g) {
    final fragen = [for (final f in gruppe.fragen) if (!k.leer(f.text)) f];
    if (fragen.isEmpty) return const [];
    final nrBreite = g * 2.2;
    return [
      pw.Padding(padding: pw.EdgeInsets.only(top: _a(3), bottom: _a(1.5)), child: _fett(gruppe.titel, g)),
      for (final (i, f) in fragen.indexed)
        pw.Padding(
          padding: pw.EdgeInsets.only(top: i == 0 ? 0 : _a(1)),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.SizedBox(
              width: f.nr == null ? g * 1.1 : nrBreite,
              child: pw.Text(f.nr ?? '–', style: f.nr == null ? stil.text(g) : stil.ueberschrift(g)),
            ),
            pw.Expanded(child: x.absatz(f.text, groesse: g)),
          ]),
        ),
    ];
  }

  // ---------------------------------------------------------------- Seite 3

  List<pw.Widget> _seite3(double g) => [
        _h1(u('aufgabenJeRunde')),
        x.kasten([
          for (final (i, a) in d.aufgabenJeRunde.indexed) ...[
            if (i > 0) _abstand(4),
            _fett(_rundenTitel(a.runde), g + 0.5),
            _abstand(1.5),
            x.liste([for (final z in a.zeilen) _etikett(z)], groesse: g, abstand: _a(1)),
          ],
        ], rahmen: 0.8, innen: _kastenInnen),
        _h1(u('untersuchungsliste')),
        _untersuchungsliste(math.min(g, _gTabelle)),
      ];

  /// „Runde 1 – Das Alibi-Geflecht“ (`ui/gemeinsam.json` → `runde.titel`, Name aus `fall.json`).
  String _rundenTitel(int nr) {
    final r = k.fall.runden.firstWhere((r) => r.nr == nr);
    return gm('runde.titel', {'runde': '${r.nr}', 'name': k.text(r.name)});
  }

  /// Alle Indizkarten nach Runde, darin nach Code (MECH 3.1 Nr. 6, 3.2).
  List<KammerIndizkarte> get _karten =>
      [...k.inhalt.indizkarten.karten]..sort((a, c) => a.abRunde != c.abRunde ? a.abRunde - c.abRunde : a.code.compareTo(c.code));

  /// Untersuchungsliste (MECH 2.6 Seite 3, RK 6.7 Nr. 6): Code, Titel, ab
  /// Runde, Kästchen und Schreiblinie „gewählt in Runde“, Kästchen „Kein
  /// Bund“. Über der ersten Karte einer neuen Runde steht eine kräftige
  /// Linie, damit die Runden auch schwarzweiß auseinanderfallen.
  pw.Widget _untersuchungsliste(double g) {
    final innen = pw.EdgeInsets.fromLTRB(5, _dicht ? 1.5 : 2.5, 5, _dicht ? 1.5 : 2.5);
    pw.Widget zelle(pw.Widget w, {bool mitte = false}) =>
        pw.Padding(padding: innen, child: mitte ? pw.Center(child: w) : w);
    pw.Widget kopf(String schluessel, {bool mitte = false}) => zelle(_zellText(u(schluessel), _gKlein, fett: true), mitte: mitte);
    final karten = _karten;
    return pw.Table(
      border: pw.TableBorder.all(color: DruckStil.linie, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(40),
        1: pw.FlexColumnWidth(),
        2: pw.FixedColumnWidth(52),
        3: pw.FixedColumnWidth(92),
        4: pw.FixedColumnWidth(54),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            kopf('untersuchungsliste.code'),
            kopf('untersuchungsliste.titel'),
            kopf('untersuchungsliste.abRunde', mitte: true),
            kopf('untersuchungsliste.gewaehlt', mitte: true),
            kopf('untersuchungsliste.keinBund', mitte: true),
          ],
        ),
        for (final (i, c) in karten.indexed)
          pw.TableRow(
            decoration: i > 0 && karten[i - 1].abRunde != c.abRunde
                ? const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: DruckStil.tinte, width: 1.6)))
                : null,
            children: [
              zelle(pw.Text(c.code, style: stil.ueberschrift(g))),
              zelle(_zellText(c.titel, g)),
              zelle(_zellText('${c.abRunde}', g), mitte: true),
              zelle(
                pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                  x.kaestchen(10),
                  pw.SizedBox(width: 6),
                  pw.Container(
                    width: 28,
                    height: 10,
                    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: DruckStil.tinte, width: 0.6))),
                  ),
                ]),
                mitte: true,
              ),
              zelle(x.kaestchen(10), mitte: true),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------- Seite 4

  /// Ermittlungsbogen (MECH 2.1–2.4, RK 6.9): Die Textgröße ist die größte,
  /// bei der das Raster mit [_rasterMin] je Schreibzeile auf die Seite passt;
  /// der Rest der Seite geht als Schreibraum an die drei Zeilen (bis [_rasterMax]).
  void _ermittlungsbogen() {
    const wo = 'ermittlungsbogen';
    final platz = s.platz();
    final g = s.passendeGroesse((g) => x.spalte(_seite4(g, _rasterMin)), breite: _breite, hoehe: platz, start: 10.5, min: _gMin, wo: wo);
    final schreibzeilen = d.bogen.zeilen.where((z) => z.id != 'ausgeschieden').length;
    final rest = platz - x.hoehe(x.spalte(_seite4(g, _rasterMin)), _breite);
    final zeile = math.min(_rasterMax, _rasterMin + (schreibzeilen == 0 ? 0 : (rest - 1) / schreibzeilen));
    s.seite(_seite4(g, zeile), wo: wo, ausrichtung: pw.CrossAxisAlignment.stretch);
  }

  List<pw.Widget> _seite4(double g, double zeile) {
    final bogen = d.bogen;
    return [
      _h1(u('ermittlungsbogen')),
      x.absatz(bogen.hinweis, groesse: g),
      _abstand(6),
      _raster(zeile),
      _abstand(8),
      for (final (i, z) in k.texte(bogen.unterRaster).indexed) ...[
        if (i > 0) _abstand(7),
        x.absatz(z, groesse: math.max(g, 10)),
      ],
      _h2(u('bogenFuehren')),
      x.absatz(bogen.fuehren, groesse: g),
      _abstand(6),
      x.kasten([
        x.absatz(bogen.entlastungsregel, groesse: g),
        _abstand(5),
        x.absatz(bogen.ueberfuehrungsregel, groesse: g),
      ], rahmen: 0.8),
    ];
  }

  /// Raster MECH 2.1: vier Spalten (die Verdächtigen), Zeilen aus
  /// `detektiv.json`; die Schreibzeilen [zeile] hoch, „Ausgeschieden“ mit
  /// Kästchen.
  pw.Widget _raster(double zeile) {
    final bogen = d.bogen;
    const innen = pw.EdgeInsets.fromLTRB(5, 4, 5, 4);
    pw.Widget etikett(KammerBogenZeile z) => pw.Padding(
          padding: innen,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            _zellText(z.titel, 10, fett: true),
            if (z.zusatz case final zusatz? when !k.leer(zusatz)) ...[
              pw.SizedBox(height: 2),
              _zellText(zusatz, _gKlein, leise: true),
            ],
          ]),
        );
    return pw.Table(
      border: pw.TableBorder.all(color: DruckStil.tinte, width: 0.7),
      columnWidths: {
        0: const pw.FixedColumnWidth(96),
        for (var i = 1; i <= bogen.spalten.length; i++) i: const pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.SizedBox(),
            for (final id in bogen.spalten)
              pw.Padding(padding: innen, child: _zellText(k.inhalt.platzVon(id).name, 11, fett: true, ausrichtung: pw.TextAlign.center)),
          ],
        ),
        for (final z in bogen.zeilen)
          pw.TableRow(
            verticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              etikett(z),
              for (final _ in bogen.spalten)
                z.id == 'ausgeschieden'
                    ? pw.Padding(padding: innen, child: pw.Center(child: x.kaestchen(13)))
                    : pw.SizedBox(height: zeile),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------- Seite 5

  /// Vermerke 1 bis [KammerDetektiv.vermerkeZeilen], zweispaltig (MECH 2.6
  /// Seite 5); die Zeilen füllen die Seite, mindestens [_vermerkMin] hoch.
  void _vermerke() {
    const wo = 'vermerke';
    final platz = s.platz();
    final n = d.vermerkeZeilen;
    final links = (n + 1) ~/ 2;
    final ohneZeilen = x.hoehe(x.spalte(_seite5(0)), _breite);
    final zeile = (platz - ohneZeilen - 1) / links;
    if (zeile < _vermerkMin) {
      throw KammerUeberlauf.werfen(_teil, s.naechste, wo, '$n Vermerke, Zeile ${(zeile / KammerSatz.mm).toStringAsFixed(1)} mm hoch, mindestens ${(_vermerkMin / KammerSatz.mm).toStringAsFixed(0)} mm');
    }
    s.seite(_seite5(zeile), wo: wo, ausrichtung: pw.CrossAxisAlignment.stretch);
  }

  List<pw.Widget> _seite5(double zeile) {
    final n = d.vermerkeZeilen;
    final links = (n + 1) ~/ 2;
    return [
      _h1(u('vermerke')),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(child: _vermerkTabelle(1, links, zeile)),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _vermerkTabelle(links + 1, n, zeile)),
      ]),
    ];
  }

  pw.Widget _vermerkTabelle(int von, int bis, double zeile) {
    const innen = pw.EdgeInsets.fromLTRB(3, 3, 3, 3);
    pw.Widget kopf(String schluessel) => pw.Padding(padding: innen, child: _zellText(u(schluessel), _gKlein, fett: true));
    return pw.Table(
      border: pw.TableBorder.all(color: DruckStil.linie, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(20),
        1: pw.FixedColumnWidth(34),
        2: pw.FixedColumnWidth(48),
        3: pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [kopf('vermerke.nr'), kopf('vermerke.runde'), kopf('vermerke.quelle'), kopf('vermerke.vermerk')],
        ),
        for (var i = von; i <= bis; i++)
          pw.TableRow(children: [
            pw.Container(
              height: zeile,
              padding: innen,
              alignment: pw.Alignment.topRight,
              child: pw.Text('$i', style: stil.klein(_gKlein)),
            ),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
          ]),
      ],
    );
  }

  // ---------------------------------------------------------------- Seite 6

  List<pw.Widget> _seite6(double g) {
    final feld = k.texte(d.anklageFeld);
    final heute = d.wennRollenFehlenBei(b.personen).where((t) => !k.leer(t)).toList();
    final tipps = {for (final t in d.aktionskartenTipps) t.schluessel: t.text};
    final karten = [
      for (final p in b.aktionskartenBeimDetektiv)
        if (tipps[p.id] case final t? when !k.leer(t)) (k.rolle(p).aktionskarte.name, t),
    ];
    return [
      _h1(u('anklage')),
      x.kasten([
        if (feld.isNotEmpty) x.absatz(feld.first, groesse: g + 0.5),
        x.notizlinien(3, abstand: 24),
        for (final f in feld.skip(1)) ...[_abstand(10), x.absatz(f, groesse: g + 0.5)],
      ], rahmen: 1.2, innen: const pw.EdgeInsets.fromLTRB(12, 10, 12, 11)),
      _abstand(6),
      x.absatz(d.anklageHilfe, groesse: g),
      if (heute.isNotEmpty) ...[
        _h2(u('wennRollenFehlen', {'personen': '${b.personen}'})),
        x.liste(heute, groesse: g),
      ],
      if (karten.isNotEmpty) ...[
        _h2(u('aktionskartenFehlend')),
        for (final (i, (name, tipp)) in karten.indexed)
          pw.Padding(
            padding: pw.EdgeInsets.only(top: i == 0 ? 0 : 4),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _fett(name, g),
              x.absatz(tipp, groesse: g),
            ]),
          ),
      ],
      _h2(u('gegenKarten')),
      x.absatz(_kartenNamenFett(d.gegenKarten), groesse: g),
    ];
  }
}
