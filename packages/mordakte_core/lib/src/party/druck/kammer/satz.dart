/// Gemeinsame Satz-Helfer des Kammerspiel-Drucks (ARCHITEKTUR A2, MECH 10.1–10.3).
///
/// Zwei Ebenen:
/// - [KammerSatz] (`k.satz`) baut Bausteine ohne Seitenbezug: Titel,
///   Überschrift, fette Zeile, Absatz mit Auszeichnung, Liste, Kasten,
///   Vorlesetext (mit Marke oder nur Balken), Anleitung, Tabelle (ganz oder
///   Zeile für Zeile), Notizlinien, Kästchen, Falzlinie, Außenseite mit Code,
///   Sichtschutz-Raster, Aufzählung „a, b oder c“, Messen.
/// - [KammerSeiten] setzt Seiten eines Teils und zählt sie: feste Seite A4 hoch
///   oder quer mit Kopf und Fuß, fließender Text über mehrere Seiten, volle Seite
///   ohne Rand, versiegelte Außenseite, Raster (A5-Feld mit Z-Falz zwei je A4,
///   A7 acht je A4, beliebige Zellen wie Marker, Zettel, Streifen), passende
///   Schriftgrößen. [kammerTeilSetzen] öffnet die Zählung eines Teils und
///   schließt sie wieder.
///
/// Stil: [DruckStil] (schlicht, schwarzweiß). Alle Text-Helfer lösen die
/// Platzhalter selbst auf (über [KammerKontext.text]) und setzen die
/// Auszeichnung; ein schon aufgelöster Text bleibt dabei gleich.
///
/// Überlauf ist nie still: Passt etwas nicht auf seine Seite, in seine Zelle
/// oder in die erlaubte Seitenzahl, wirft der Helfer [KammerUeberlauf] mit
/// Teil, Seite und Stelle (A2); die Teile werfen ihn in derselben Form
/// ([KammerUeberlauf.werfen], [KammerSeiten.ueberlauf]). Achtung beim
/// Selbstbauen: Eine `pw.Column` mit begrenzter Höhe lässt ein Kind, das nicht
/// mehr passt, still weg (pw.Flex teilt es auf eine nächste Seite, die es auf
/// einer festen Seite nicht gibt). Darum feste Seiten nur über
/// [KammerSeiten.seite], Raster über [KammerSeiten.raster], [KammerSeiten.a7],
/// [KammerSeiten.zFalz], Kästen fester Größe über [KammerSeiten.fest], und
/// eigene Seiten ([KammerSeiten.vollSeite]) nur mit [KammerSeiten.pruefe] bzw.
/// [KammerSeiten.pruefeHoehe].
///
/// Druckrand: Raster, A7 und Z-Falz reichen bis an die Papierkante; Text hält
/// dort mindestens [KammerSatz.druckRand] Abstand, sonst ist es ein Überlauf.
library;

import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../satz_stil.dart';
import 'kontext.dart';
import 'platzhalter.dart';

/// Etwas passt nicht: auf seine Seite, in seine Zelle oder in die erlaubte
/// Seitenzahl. [seite] zählt im Teil (bzw. im Bereich, etwa einem Rollenheft).
class KammerUeberlauf implements Exception {
  const KammerUeberlauf(this.teil, this.seite, this.wo, this.meldung);

  /// Teilnummer (`00` … `90`).
  final String teil;

  /// Seite im Teil bzw. Bereich, ab 1.
  final int seite;

  /// Stelle (Bereich und Angabe des Teils).
  final String wo;
  final String meldung;

  @override
  String toString() => meldung;

  // Alle Überläufe haben dieselbe Meldung: „Überlauf in Teil …, Seite … (Stelle): Grund“.
  // Die Aufrufer schreiben `throw KammerUeberlauf.werfen(…)`, damit ein Grund mit Wörtern in
  // einer Zeile mit `throw` steht (story_text_ausserhalb_test.dart).

  /// Wirft den Überlauf in Teil [teil], Seite [seite], an der Stelle [wo] mit [grund].
  static Never werfen(String teil, int seite, String wo, String grund) =>
      throw KammerUeberlauf(teil, seite, wo, 'Überlauf in Teil $teil, Seite $seite ($wo): $grund');

  /// [hoehe] passt nicht in [platz] (pt).
  static Never zuHoch(String teil, int seite, String wo, double hoehe, double platz) =>
      throw werfen(teil, seite, wo, '${hoehe.toStringAsFixed(1)} pt hoch, Platz ${platz.toStringAsFixed(1)} pt');

  /// Auch in der kleinsten erlaubten Schriftgröße [min] ist es [hoehe] hoch, Platz [platz].
  static Never keineGroesse(String teil, int seite, String wo, double min, double hoehe, double platz) =>
      throw werfen(teil, seite, wo, 'auch in ${min}pt ${hoehe.toStringAsFixed(1)} pt hoch, Platz ${platz.toStringAsFixed(1)} pt');
}

Never _zuVieleSeiten(String teil, int seite, String wo, int seiten, int max) =>
    throw KammerUeberlauf.werfen(teil, seite, wo, '$seiten Seiten, erlaubt sind $max');

Never _zuNahAmRand(String teil, int seite, String wo, String kante, double abstand) =>
    throw KammerUeberlauf.werfen(teil, seite, wo, 'Text $kante ${(abstand / KammerSatz.mm).toStringAsFixed(1)} mm von der Papierkante, mindestens ${(KammerSatz.druckRand / KammerSatz.mm).toStringAsFixed(0)} mm');

/// Nummerierung einer Liste ([KammerSatz.liste]).
enum KammerNummer {
  /// Gedankenstrich vor jedem Eintrag.
  strich,

  /// 1., 2., 3. …
  zahl,

  /// (a), (b), (c) … (Pflicht-Auslöser der Verdächtigen, SCHEMA §2).
  buchstabe,

  /// ohne Zeichen.
  keine;

  /// Zeichen vor Eintrag [i] (ab 0).
  String zeichen(int i) => switch (this) {
        strich => '–',
        zahl => '${i + 1}.',
        buchstabe => '(${String.fromCharCode(0x61 + i)})',
        keine => '',
      };

  /// Einzug des Texts hinter dem Zeichen bei Schriftgröße [g] (ohne Zeichen keiner).
  double einzug(double g) => this == keine ? 0.0 : g * (this == strich ? 1.1 : 1.8);
}

/// Inhalt einer Rasterzelle (Karte, Plättchen, Zettel, Streifen): [oben] steht
/// oben, [unten] am unteren Rand. Beide zusammen müssen in die Zelle passen.
class KammerZelle {
  const KammerZelle(this.oben, {this.unten, this.wo = ''});
  final pw.Widget oben;
  final pw.Widget? unten;

  /// Stelle für die Fehlermeldung (etwa der Code einer Karte).
  final String wo;
}

/// Eine Karte im Z-Falz (MECH 3.1 Nr. 9, 4.1): [aussen] auf Feld 1, [innen]
/// auf Feld 2; Feld 3 ist das leere Deckfeld mit grauem Raster.
class KammerZFalz {
  const KammerZFalz({required this.aussen, required this.innen, this.wo = ''});
  final pw.Widget aussen;
  final pw.Widget innen;
  final String wo;
}

/// Bausteine ohne Seitenbezug (`k.satz`).
class KammerSatz {
  KammerSatz(this.k);

  final KammerKontext k;
  DruckStil get stil => k.stil;

  // ---------------------------------------------------------------- Maße

  static const mm = PdfPageFormat.mm;
  static const a4Hoch = PdfPageFormat.a4;
  static final a4Quer = PdfPageFormat.a4.landscape;
  static const randHoch = DruckStil.rand;
  static const randQuer = pw.EdgeInsets.fromLTRB(40, 32, 40, 32);

  /// Kleinste Schriftgröße für Lesetext (Master 7.14).
  static const kleinsteGroesse = DruckStil.minGroesse;

  /// Abstand, den Text mindestens zur Papierkante hält: Viele Drucker lassen
  /// die äußersten 4 bis 5 mm leer. Raster, Z-Falz und A7 füllen das Blatt bis
  /// an die Kante; ihre Zellen halten den Text deshalb mindestens so weit
  /// davon weg ([KammerSeiten.raster], [KammerSeiten.zFalz]).
  static const druckRand = 5 * mm;

  /// A5-Feld hoch (148 × 210 mm), zwei je A4 quer; Z-Falz in drei Felder zu 148 × 70 mm (MECH 3.1, 4.1).
  static const a5Breite = 148 * mm;
  static const a5Hoehe = 210 * mm;
  static const zFalzFeldHoehe = 70 * mm;

  /// Innenabstand der Felder im Z-Falz.
  static const zFalzInnen = pw.EdgeInsets.all(14);

  /// Abstand der beiden A5-Felder zur Papierkante links und rechts (0,5 mm).
  static double get zFalzAussenRand => (a4Quer.width - 2 * a5Breite) / 2;

  /// Innenabstand einer Karte im Z-Falz in Spalte [spalte] (0 links, 1
  /// rechts): [innen], an der Papierkante so viel mehr, dass der Text
  /// [druckRand] Abstand hält (an der Schnittlinie in der Mitte bleibt [innen]).
  static pw.EdgeInsets zFalzInnenFuer(pw.EdgeInsets innen, int spalte) {
    final mindest = druckRand - zFalzAussenRand;
    return spalte == 0
        ? pw.EdgeInsets.fromLTRB(math.max(innen.left, mindest), innen.top, innen.right, innen.bottom)
        : pw.EdgeInsets.fromLTRB(innen.left, innen.top, math.max(innen.right, mindest), innen.bottom);
  }

  /// Breite für Text in einem Feld des Z-Falzes bei [innen] (die schmalere der
  /// beiden Spalten, [zFalzInnenFuer]); damit misst ein Teil, was [KammerSeiten.zFalz] setzt.
  static double zFalzTextBreite([pw.EdgeInsets innen = zFalzInnen]) =>
      math.min(a5Breite - zFalzInnenFuer(innen, 0).horizontal, a5Breite - zFalzInnenFuer(innen, 1).horizontal);

  /// A7 hoch (74 × 105 mm), acht je A4 quer (MECH 4.3).
  static const a7Breite = 74 * mm;
  static const a7Hoehe = 105 * mm;
  static const a7Innen = pw.EdgeInsets.all(16);

  /// Seitenformat, Rand und Satzspiegel.
  static PdfPageFormat format({bool quer = false}) => quer ? a4Quer : a4Hoch;
  static pw.EdgeInsets rand({bool quer = false}) => quer ? randQuer : randHoch;
  static double satzBreite({bool quer = false}) => format(quer: quer).width - rand(quer: quer).horizontal;
  static double satzHoehe({bool quer = false}) => format(quer: quer).height - rand(quer: quer).vertical;

  // ---------------------------------------------------------------- Messen

  pw.Context? _mess;
  pw.Document? _messDokument;

  /// Höhe von [w] bei [breite] (pt). Gemessen wird im Dokument, das gerade
  /// gesetzt wird ([messenIn], das ruft [kammerTeilSetzen]), sonst in einem
  /// eigenen. Grund: Eine Schrift baut ihr PDF-Objekt je Dokument neu; wer
  /// zwischen einem Messdokument und dem Ziel wechselt, legt dieselbe Schrift
  /// mehrfach in die Datei.
  double hoehe(pw.Widget w, double breite) {
    final ctx = _mess ??= _kontext(stil.neuesDokument('Messung'));
    w.layout(ctx, pw.BoxConstraints(maxWidth: breite), parentUsesSize: true);
    return w.box!.height;
  }

  /// Misst ab jetzt in [doc] (siehe [hoehe]).
  void messenIn(pw.Document doc) {
    if (identical(doc, _messDokument)) return;
    _messDokument = doc;
    _mess = _kontext(doc);
  }

  static pw.Context _kontext(pw.Document doc) => pw.Context(document: doc.document).inheritFromAll([doc.theme!]);

  // ---------------------------------------------------------------- Text

  /// Zeichen, die Inter nicht hat, durch gleichwertige ersetzen (☐ → □).
  static String glyphen(String t) => t.replaceAll('☐', '□');

  /// Stil eines Laufs in Größe [g]; [zeilenabstand] ist der zusätzliche
  /// Zeilenabstand in Teilen der Größe.
  pw.TextStyle _lauf(KammerLauf l, double g, PdfColor farbe, double zeilenabstand) => pw.TextStyle(
        font: l.fett ? stil.stark : stil.normal,
        fontSize: g,
        // Der Stil hat keine kursive Schrift: Kursives steht in Grau.
        color: l.kursiv ? DruckStil.leise : farbe,
        lineSpacing: g * zeilenabstand,
      );

  pw.TextSpan _spans(KammerAbsatz a, double g, PdfColor farbe, double zeilenabstand) => pw.TextSpan(children: [
        for (var z = 0; z < a.zeilen.length; z++) ...[
          if (z > 0) pw.TextSpan(text: '\n', style: _lauf(const KammerLauf(''), g, farbe, zeilenabstand)),
          for (final l in a.zeilen[z]) pw.TextSpan(text: glyphen(l.text), style: _lauf(l, g, farbe, zeilenabstand)),
        ],
      ]);

  /// Fette Zeile ohne Auszeichnung in [groesse] (Überschrift, Tabellenkopf,
  /// Etikett, Name).
  pw.Widget fett(String text, {double groesse = 11, Map<String, String> werte = const {}}) =>
      pw.Text(glyphen(k.klartext(text, werte: werte)), style: stil.ueberschrift(groesse));

  /// Spalte über die ganze Breite (die Kinder gestreckt).
  pw.Widget spalte(List<pw.Widget> kinder) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: kinder);

  /// Großer Titel (Deckblatt), ohne Auszeichnung.
  pw.Widget titel(String text, {double groesse = 26, Map<String, String> werte = const {}}) =>
      pw.Text(glyphen(k.klartext(text, werte: werte)), style: stil.titel(groesse));

  /// Überschrift der Stufe 1 (Abschnitt), 2 (Unterabschnitt) oder 3 (Etikett im Fließtext).
  pw.Widget ueberschrift(String text, {int stufe = 1, Map<String, String> werte = const {}}) {
    final g = switch (stufe) { 1 => 15.0, 2 => 12.5, _ => 10.5 };
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: stufe == 1 ? 8 : 5, bottom: stufe == 1 ? 5 : 3),
      child: fett(text, groesse: g, werte: werte),
    );
  }

  /// Kleine Marke in Großbuchstaben (Kastenkopf, Kartenkopf).
  pw.Widget marke(String text, {double groesse = 8.5, Map<String, String> werte = const {}}) =>
      pw.Text(glyphen(k.klartext(text, werte: werte)).toUpperCase(), style: stil.marke(groesse));

  /// Absatz mit Auszeichnung: `**fett**`, `*kursiv*` (grau), Zeilen, Absätze.
  /// [abstand] steht zwischen den Absätzen, [zeilenabstand] (in Teilen der
  /// Größe) zwischen den Zeilen. Leer aufgelöst: nichts.
  pw.Widget absatz(
    String text, {
    double groesse = 11,
    Map<String, String> werte = const {},
    bool leise = false,
    pw.TextAlign ausrichtung = pw.TextAlign.left,
    double abstand = 4,
    double zeilenabstand = 0.2,
  }) {
    final absaetze = k.absaetze(text, werte: werte);
    if (absaetze.isEmpty) return pw.SizedBox();
    final farbe = leise ? DruckStil.leise : DruckStil.tinte;
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: ausrichtung == pw.TextAlign.center ? pw.CrossAxisAlignment.center : pw.CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < absaetze.length; i++)
          pw.Padding(
            padding: pw.EdgeInsets.only(top: i == 0 ? 0 : abstand),
            child: pw.RichText(text: _spans(absaetze[i], groesse, farbe, zeilenabstand), textAlign: ausrichtung),
          ),
      ],
    );
  }

  /// Liste: Einträge, die leer aufgelöst werden, fallen weg; die Nummern rücken nach.
  pw.Widget liste(
    Iterable<String> eintraege, {
    KammerNummer nummer = KammerNummer.strich,
    double groesse = 11,
    Map<String, String> werte = const {},
    double abstand = 3,
  }) {
    final texte = k.texte(eintraege, werte: werte);
    final einzug = nummer.einzug(groesse);
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < texte.length; i++)
          pw.Padding(
            padding: pw.EdgeInsets.only(top: i == 0 ? 0 : abstand),
            child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              if (einzug > 0) pw.SizedBox(width: einzug, child: pw.Text(nummer.zeichen(i), style: stil.text(groesse))),
              pw.Expanded(child: absatz(texte[i], groesse: groesse)),
            ]),
          ),
      ],
    );
  }

  /// Kasten mit Rahmen und optionaler [marke] oben.
  pw.Widget kasten(
    List<pw.Widget> inhalt, {
    String? marke,
    bool grau = false,
    double rahmen = 0.8,
    pw.EdgeInsets innen = const pw.EdgeInsets.fromLTRB(10, 8, 10, 9),
  }) =>
      pw.Container(
        padding: innen,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: DruckStil.tinte, width: rahmen),
          color: grau ? PdfColors.grey100 : null,
        ),
        child: pw.Column(mainAxisSize: pw.MainAxisSize.min, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          if (marke != null) ...[this.marke(marke), pw.SizedBox(height: 4)],
          ...inhalt,
        ]),
      );

  /// Vorlesetext: Balken links, Marke „Vorlesen“ (`ui/gemeinsam.json`).
  pw.Widget vorlesen(String text, {double groesse = 11.5, Map<String, String> werte = const {}}) =>
      vorlesenKasten([absatz(text, groesse: groesse, werte: werte)]);

  /// Vorlesetext aus mehreren [teile]n (Abstand [luecke]) unter der Marke
  /// „Vorlesen“ in [marke] pt, Balken links; mit [hoehe] genau so hoch (der
  /// Aufrufer hat vorher gemessen, dass der Inhalt passt).
  pw.Widget vorlesenKasten(List<pw.Widget> teile, {double marke = 8.5, double luecke = 5, double? hoehe}) => pw.Container(
        height: hoehe,
        padding: const pw.EdgeInsets.fromLTRB(10, 6, 4, 6),
        decoration: const pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: DruckStil.tinte, width: 2.5))),
        child: pw.Column(mainAxisSize: pw.MainAxisSize.min, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          this.marke(k.uiGemeinsam('vorlesen'), groesse: marke),
          pw.SizedBox(height: 4),
          for (final (i, t) in teile.indexed) ...[if (i > 0) pw.SizedBox(height: luecke), t],
        ]),
      );

  /// Balken eines Vorlesetexts ohne Marke (Einträge unter einer gemeinsamen
  /// Marke); [aussen] ist der Abstand um den Balken.
  pw.Widget balken(pw.Widget kind, {pw.EdgeInsets? aussen}) => pw.Container(
        margin: aussen,
        padding: const pw.EdgeInsets.fromLTRB(8, 1, 2, 1),
        decoration: const pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: DruckStil.tinte, width: 2.5))),
        child: kind,
      );

  /// Anleitung für den Erzähler: dünner Kasten, Marke „Anleitung“.
  pw.Widget anleitung(String text, {double groesse = 10.5, Map<String, String> werte = const {}}) =>
      kasten([absatz(text, groesse: groesse, werte: werte)], marke: k.uiGemeinsam('anleitung'), rahmen: 0.5);

  /// Tabelle mit Gitter; [kopf] wiederholt sich nach einem Seitenwechsel.
  /// Zellen: Text (mit Auszeichnung), Widget oder null. [spalten] sind
  /// Breitenverhältnisse. Zeilen, deren erster Text leer aufgelöst wird, fallen weg.
  pw.Widget tabelle({
    List<String>? kopf,
    required List<List<Object?>> zeilen,
    List<double>? spalten,
    double groesse = 9.5,
    pw.EdgeInsets innen = const pw.EdgeInsets.fromLTRB(4, 3, 4, 3),
  }) {
    final n = kopf?.length ?? (zeilen.isEmpty ? 1 : zeilen.first.length);
    final sichtbar = [
      for (final z in zeilen)
        if (z.isEmpty || z.first is! String || !k.leer(z.first! as String)) z,
    ];
    return pw.Table(
      border: pw.TableBorder.all(color: DruckStil.linie, width: 0.5),
      columnWidths: {for (var i = 0; i < n; i++) i: pw.FlexColumnWidth(spalten == null ? 1 : spalten[i])},
      children: [
        if (kopf != null)
          pw.TableRow(
            repeat: true,
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: [for (final t in kopf) zelle(t, groesse: groesse, innen: innen, kopf: true)],
          ),
        for (final z in sichtbar) pw.TableRow(children: [for (var i = 0; i < n; i++) zelle(i < z.length ? z[i] : null, groesse: groesse, innen: innen)]),
      ],
    );
  }

  /// Zelle einer Tabelle mit Innenabstand [innen]: Text mit Auszeichnung in
  /// [groesse] (im [kopf] fett ohne Auszeichnung), Widget oder leer (null).
  pw.Widget zelle(Object? inhalt, {required double groesse, pw.EdgeInsets innen = const pw.EdgeInsets.fromLTRB(4, 3, 4, 3), bool kopf = false}) => pw.Padding(
        padding: innen,
        child: switch (inhalt) {
          null => pw.SizedBox(),
          final pw.Widget w => w,
          final String s when kopf => fett(s, groesse: groesse),
          final String s => absatz(s, groesse: groesse),
          _ => absatz('$inhalt', groesse: groesse),
        },
      );

  /// Eine Tabellenzeile als eigene Tabelle (so kann eine Tabelle zwischen zwei
  /// Zeilen umbrechen): Linien links, rechts, unten und zwischen den Spalten,
  /// mit [oben] auch oben, mit [grau] grau hinterlegt (Kopf). [spalten] sind
  /// Breitenverhältnisse.
  pw.Widget tabellenzeile(List<pw.Widget> zellen, List<double> spalten, {bool oben = false, bool grau = false}) {
    const linie = pw.BorderSide(color: DruckStil.linie, width: 0.5);
    return pw.Table(
      border: pw.TableBorder(left: linie, right: linie, bottom: linie, top: oben ? linie : pw.BorderSide.none, verticalInside: linie),
      columnWidths: {for (var i = 0; i < spalten.length; i++) i: pw.FlexColumnWidth(spalten[i])},
      children: [
        pw.TableRow(
          decoration: grau ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
          children: zellen,
        ),
      ],
    );
  }

  /// „a, b oder c“: zwei und mehr [teile] über `ui/<teil>.json` → [schluessel]
  /// mit den Werten `{liste}` (alle bis auf den letzten, mit Komma) und
  /// `{letzter}`; einer allein bleibt, keiner ist leer.
  String aufzaehlen(List<String> teile, String teil, String schluessel) => switch (teile.length) {
        0 => '',
        1 => teile.single,
        _ => k.ui(teil, schluessel, {'liste': teile.sublist(0, teile.length - 1).join(', '), 'letzter': teile.last}),
      };

  /// [anzahl] Schreiblinien im Abstand [abstand].
  pw.Widget notizlinien(int anzahl, {double abstand = 22}) => pw.Column(children: [
        for (var i = 0; i < anzahl; i++)
          pw.Container(
            height: abstand,
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: DruckStil.linie, width: 0.5))),
          ),
      ]);

  /// Leeres Kästchen zum Ankreuzen.
  pw.Widget kaestchen([double groesse = 9]) => pw.Container(
        width: groesse,
        height: groesse,
        decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 0.7)),
      );

  /// Gestrichelter Rahmen zum Ausschneiden.
  pw.BoxDecoration schnitt() => stil.schnitt();

  /// Falzlinie: gepunktet, mit kleiner Beschriftung „Hier falten“
  /// (`ui/gemeinsam.json` → `falten`). Waagrecht.
  pw.Widget falzlinie({double? laenge, bool beschriftung = true}) => pw.SizedBox(
        width: laenge,
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Expanded(
            child: pw.Container(
              height: 0,
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: DruckStil.linie, width: 0.8, style: pw.BorderStyle.dotted)),
              ),
            ),
          ),
          if (beschriftung) ...[pw.SizedBox(width: 4), pw.Text(k.klartext(k.uiGemeinsam('falten')), style: stil.klein(6.5))],
        ]),
      );

  /// Außenseite mit großem Code und kleinem Hinweis (Indizkarten, Teil 90).
  pw.Widget aussenseite(String code, String hinweis, {double codeGroesse = 40, double hinweisGroesse = 10, Map<String, String> werte = const {}}) {
    final codeStil = stil.code(codeGroesse);
    return pw.Column(mainAxisSize: pw.MainAxisSize.min, crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
      // Die Sperrung steht auch hinter dem letzten Zeichen; links ebenso viel, damit der Code mittig steht (wie Teil 11).
      pw.Padding(padding: pw.EdgeInsets.only(left: codeStil.letterSpacing ?? 0), child: pw.Text(code, style: codeStil)),
      pw.SizedBox(height: 8),
      absatz(hinweis, groesse: hinweisGroesse, werte: werte, ausrichtung: pw.TextAlign.center, leise: true),
    ]);
  }

  /// Dichtes graues Raster (Sichtschutz des Deckfelds im Z-Falz, MECH 4.1).
  pw.Widget sichtschutz(double breite, double hoehe) => pw.SizedBox(
        width: breite,
        height: hoehe,
        child: pw.CustomPaint(size: PdfPoint(breite, hoehe), painter: _rasterMalen),
      );

  static void _rasterMalen(PdfGraphics g, PdfPoint s) {
    const schritt = 2.2 * mm;
    g
      ..setStrokeColor(PdfColors.grey500)
      ..setLineWidth(0.6);
    // Diagonalen in beide Richtungen, auf das Feld beschnitten.
    for (var d = -s.y; d < s.x; d += schritt) {
      final x0 = math.max(d, 0.0), y0 = x0 - d;
      final x1 = math.min(d + s.y, s.x), y1 = x1 - d;
      g
        ..moveTo(x0, y0)
        ..lineTo(x1, y1);
      final u0 = math.max(d, 0.0), v0 = s.y - (u0 - d);
      final u1 = math.min(d + s.y, s.x), v1 = s.y - (u1 - d);
      g
        ..moveTo(u0, v0)
        ..lineTo(u1, v1);
    }
    g.strokePath();
  }
}

/// Setzt Teil [teil] in [doc]: [setzen] bekommt die Seitenzählung des Teils
/// (bzw. des Bereichs [bereich], etwa eines Rollenhefts). Danach steht die
/// Seitenzahl fest; ein Teil ohne Seite ist ein Fehler.
void kammerTeilSetzen(pw.Document doc, KammerKontext k, String teil, void Function(KammerSeiten s) setzen, {String? bereich}) {
  k.satz.messenIn(doc);
  final s = KammerSeiten._(k, doc, teil, bereich);
  setzen(s);
  s._schliessen();
  if (s.gesetzt == 0) throw StateError('Teil $teil ($bereich) hat keine Seite');
}

/// Setzt und zählt die Seiten eines Teils oder Bereichs. Kopf: Fall · Spiel ·
/// Teil (`ui/gemeinsam.json` → `kopf`), rechts der Bereich. Fuß: Fall-Code
/// (`fuss.code`) und „Seite x von y“ (`fuss.seite`), gezählt im Bereich.
class KammerSeiten {
  KammerSeiten._(this.k, this.doc, this.teil, this.bereich) : _start = _anzahl(doc);

  static int _anzahl(pw.Document d) => d.document.pdfPageList.pages.length;

  final KammerKontext k;
  final pw.Document doc;

  /// Teilnummer (`00` … `90`).
  final String teil;

  /// Bereich im Teil (Kopf rechts, Fehlermeldungen), etwa der Rollenname.
  final String? bereich;
  final int _start;
  int? _ende;

  KammerSatz get satz => k.satz;
  DruckStil get stil => k.stil;

  /// Bisher gesetzte Seiten; nach dem Schließen alle.
  int get gesetzt => (_ende ?? _anzahl(doc)) - _start;

  /// Nummer der nächsten Seite im Bereich (für Fehlermeldungen).
  int get naechste => gesetzt + 1;

  /// Seite im Bereich, ab 1.
  int seiteVon(pw.Context c) => c.pageNumber - _start;

  void _schliessen() => _ende = _anzahl(doc);

  /// Stelle für Überlauf-Meldungen: Teil / Bereich / [wo].
  String ort(String wo) => [k.teilTitel(teil), ?bereich, if (wo.isNotEmpty) wo].join(' / ');

  /// Wirft [KammerUeberlauf] für die nächste Seite an der Stelle [wo] ([ort]) mit [grund].
  Never ueberlauf(String wo, String grund) => KammerUeberlauf.werfen(teil, naechste, ort(wo), grund);

  /// Ein Bereich desselben Teils mit eigener Seitenzählung (etwa ein Heft in
  /// Teil 10): Kopf rechts [name], Fuß „Seite x von y“ des Bereichs.
  void bereichSetzen(String name, void Function(KammerSeiten s) setzen) => kammerTeilSetzen(doc, k, teil, setzen, bereich: name);

  // ---------------------------------------------------------------- Kopf, Fuß

  pw.Widget kopf() => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Expanded(child: pw.Text(KammerSatz.glyphen(k.kopfText(k.teilTitel(teil))), style: stil.klein(8.5))),
          if (bereich != null) pw.Text(KammerSatz.glyphen(bereich!), style: stil.marke(8.5)),
        ]),
        pw.SizedBox(height: 3),
        pw.Container(height: 0.6, color: DruckStil.linie),
        pw.SizedBox(height: 10),
      ]);

  /// Fuß; ohne [c] (beim Messen) mit Seite 1.
  pw.Widget fuss([pw.Context? c]) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        pw.SizedBox(height: 8),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(k.klartext(k.uiGemeinsam('fuss.code', {'code': k.fallCode})), style: stil.klein(8.5)),
          pw.Text(
            k.klartext(k.uiGemeinsam('fuss.seite', {'seite': '${c == null ? 1 : seiteVon(c)}', 'seiten': '${math.max(gesetzt, 1)}'})),
            style: stil.klein(8.5),
          ),
        ]),
      ]);

  /// Platz für den Inhalt einer festen Seite (Höhe ohne Kopf und Fuß).
  double platz({bool quer = false, bool mitKopf = true, bool mitFuss = true}) {
    final b = KammerSatz.satzBreite(quer: quer);
    return KammerSatz.satzHoehe(quer: quer) - (mitKopf ? satz.hoehe(kopf(), b) : 0) - (mitFuss ? satz.hoehe(fuss(), b) : 0);
  }

  /// Überlaufschutz für selbst gebaute Seiten ([vollSeite]): Ist [hoehe] größer
  /// als [platz], wirft es [KammerUeberlauf] für die nächste Seite.
  void pruefeHoehe(double hoehe, double platz, {String wo = ''}) {
    if (hoehe > platz) KammerUeberlauf.zuHoch(teil, naechste, ort(wo), hoehe, platz);
  }

  /// Wie [pruefeHoehe], aber misst [inhalt] bei [breite] selbst.
  void pruefe(pw.Widget inhalt, {required double breite, required double platz, String wo = ''}) =>
      pruefeHoehe(satz.hoehe(inhalt, breite), platz, wo: wo);

  /// Kasten fester Größe [breite] × [hoehe] (pt) mit Innenabstand [innen] und
  /// optionalem Rahmen, [inhalt] oben links (Etikett eines Streifens, Feld auf
  /// Blatt B, Kartenteil). Passt [inhalt] nicht hinein, ist das ein Überlauf
  /// für die nächste Seite. Statt `pw.SizedBox(height: …)` um Text: Eine
  /// Spalte fester Höhe ließe den Text, der nicht passt, still weg.
  pw.Widget fest(
    pw.Widget inhalt, {
    required double breite,
    required double hoehe,
    pw.EdgeInsets innen = pw.EdgeInsets.zero,
    pw.BoxDecoration? rahmen,
    String wo = '',
  }) {
    pruefe(inhalt, breite: breite - innen.horizontal, platz: hoehe - innen.vertical, wo: wo);
    return pw.Container(width: breite, height: hoehe, padding: innen, decoration: rahmen, alignment: pw.Alignment.topLeft, child: inhalt);
  }

  /// Text auf einer Seite ohne Rand muss [KammerSatz.druckRand] von der
  /// Papierkante halten: [abstand] je Seite (links, oben, rechts, unten) vom
  /// Papier bis zum Text.
  void _druckRand(pw.EdgeInsets abstand, String wo) {
    const d = KammerSatz.druckRand - 0.01;
    for (final (seite, a) in [('links', abstand.left), ('oben', abstand.top), ('rechts', abstand.right), ('unten', abstand.bottom)]) {
      if (a < d) _zuNahAmRand(teil, naechste, ort(wo), seite, a);
    }
  }

  // ---------------------------------------------------------------- Seiten

  /// Feste Seite A4 hoch (oder [quer]): [inhalt] steht oben im Satzspiegel
  /// ([pw.Spacer] schiebt nach unten). Ist er höher als der Platz, ist das ein
  /// Überlauf. Mit [notizen] wird der freie Platz darunter zu Notizlinien
  /// (Marke `notizen`), wenn mindestens zwei passen.
  void seite(
    List<pw.Widget> inhalt, {
    String wo = '',
    bool quer = false,
    bool mitKopf = true,
    bool mitFuss = true,
    bool notizen = false,
    pw.CrossAxisAlignment ausrichtung = pw.CrossAxisAlignment.start,
  }) {
    final breite = KammerSatz.satzBreite(quer: quer);
    final p = platz(quer: quer, mitKopf: mitKopf, mitFuss: mitFuss);
    final h = satz.hoehe(pw.Column(crossAxisAlignment: ausrichtung, children: [for (final w in inhalt) if (w is! pw.Spacer) w]), breite);
    if (h > p) KammerUeberlauf.zuHoch(teil, naechste, ort(wo), h, p);
    var kinder = inhalt;
    if (notizen) {
      final marke = satz.marke(k.uiGemeinsam('notizen'));
      final zeilen = ((p - h - satz.hoehe(marke, breite) - 16) / 22).floor();
      if (zeilen >= 2) kinder = [...inhalt, pw.Spacer(), marke, pw.SizedBox(height: 2), satz.notizlinien(zeilen)];
    }
    doc.addPage(pw.Page(
      pageFormat: KammerSatz.format(quer: quer),
      margin: KammerSatz.rand(quer: quer),
      build: (c) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        if (mitKopf) kopf(),
        pw.Expanded(child: pw.Column(crossAxisAlignment: ausrichtung, children: kinder)),
        if (mitFuss) fuss(c),
      ]),
    ));
  }

  /// Fließender Inhalt über so viele Seiten wie nötig, mit Kopf und Fuß. Ein
  /// Element, das nicht teilbar und höher als eine Seite ist (Kasten, Zeile),
  /// und mehr als [maxSeiten] neue Seiten sind ein Überlauf. [pw.NewPage]
  /// erzwingt einen Seitenwechsel.
  void fliessend(List<pw.Widget> inhalt, {String wo = '', bool quer = false, bool mitKopf = true, bool mitFuss = true, int? maxSeiten}) {
    final vorher = _anzahl(doc);
    try {
      doc.addPage(pw.MultiPage(
        pageFormat: KammerSatz.format(quer: quer),
        margin: KammerSatz.rand(quer: quer),
        maxPages: 400,
        header: mitKopf ? (c) => kopf() : null,
        footer: mitFuss ? fuss : null,
        build: (c) => inhalt,
      ));
    } on PdfException catch (e) {
      throw KammerUeberlauf.werfen(teil, _anzahl(doc) - _start + 1, ort(wo), '${e.message}');
    }
    final neu = _anzahl(doc) - vorher;
    if (maxSeiten != null && neu > maxSeiten) _zuVieleSeiten(teil, gesetzt, ort(wo), neu, maxSeiten);
  }

  /// Volle Seite ohne Kopf und Fuß (Raster, Plan): [bauen] bekommt den Kontext,
  /// [rand] ist der Seitenrand (Vorgabe: keiner; für Text mindestens
  /// [KammerSatz.druckRand]). Kein Überlaufschutz: Was hier steht, misst der
  /// Aufrufer selbst ([pruefe], [fest], [passendeGroesse]), und zwar vor dem
  /// Aufruf, nicht in [bauen] (das läuft erst beim Speichern).
  void vollSeite(pw.Widget Function(pw.Context c) bauen, {bool quer = false, pw.EdgeInsets rand = pw.EdgeInsets.zero}) =>
      doc.addPage(pw.Page(pageFormat: KammerSatz.format(quer: quer), margin: rand, build: bauen));

  /// Abstand des Inhalts einer versiegelten Außenseite zum ersten Falz.
  static const _falzAbstand = 8 * KammerSatz.mm;

  /// Versiegelte Außenseite (Teil 11, Teil 90): [code] groß, darunter
  /// [hinweis], über dem Code optional [titel]; alles im oberen Drittel des
  /// Blatts (bis [_falzAbstand] über dem ersten Falz bei 99 mm), damit es nach
  /// dem Falten in Dritteln vorn bleibt. Ohne Kopf und Fuß.
  void versiegelt({required String code, required String hinweis, String? titel, Map<String, String> werte = const {}}) {
    final inhalt = [
      if (titel != null) ...[satz.titel(titel, groesse: 20, werte: werte), pw.SizedBox(height: 18)],
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: DruckStil.tinte, width: 1.6)),
        child: satz.aussenseite(code, hinweis, codeGroesse: 44, hinweisGroesse: 11, werte: werte),
      ),
    ];
    final h = satz.hoehe(pw.Column(children: inhalt), KammerSatz.satzBreite());
    // Gefaltet wird in Dritteln des Blatts, nicht des Satzspiegels.
    final drittel = KammerSatz.a4Hoch.height / 3 - KammerSatz.randHoch.top - _falzAbstand;
    if (h > drittel) KammerUeberlauf.zuHoch(teil, naechste, ort(code), h, drittel);
    doc.addPage(pw.Page(
      pageFormat: KammerSatz.a4Hoch,
      margin: KammerSatz.randHoch,
      // Volle Breite, damit Titel und Code mittig stehen (eine Spalte ist sonst so schmal wie ihr Inhalt).
      build: (c) => pw.SizedBox(
        width: KammerSatz.satzBreite(),
        child: pw.Column(children: [
          pw.SizedBox(height: (drittel - h) / 2),
          ...inhalt,
          pw.Spacer(),
        ]),
      ),
    ));
  }

  // ---------------------------------------------------------------- Raster

  /// Raster gleich großer Zellen ([breite] × [hoehe] pt), [spalten] × [reihen]
  /// je Seite, mittig auf der Seite (mit [ueber] darüber, etwa einer
  /// Überschrift). Jede Zelle hat einen gestrichelten Schnittrahmen und den
  /// Innenabstand [innen]; ihr Inhalt muss hineinpassen. Mehr Zellen als eine
  /// Seite fasst ergeben weitere Seiten, höchstens [maxSeiten].
  void raster(
    List<KammerZelle> zellen, {
    required double breite,
    required double hoehe,
    required int spalten,
    required int reihen,
    bool quer = false,
    pw.EdgeInsets innen = const pw.EdgeInsets.all(8),
    pw.EdgeInsets rand = pw.EdgeInsets.zero,
    pw.Widget? ueber,
    int? maxSeiten,
    String wo = '',
  }) {
    if (zellen.isEmpty) return;
    final format = KammerSatz.format(quer: quer);
    final nutzBreite = format.width - rand.horizontal;
    final ueberHoehe = ueber == null ? 0.0 : satz.hoehe(ueber, nutzBreite) + 6;
    final nutzHoehe = format.height - rand.vertical - ueberHoehe;
    if (spalten * breite > nutzBreite + 0.01) throw KammerUeberlauf.werfen(teil, naechste, ort(wo), '$spalten × ${breite.toStringAsFixed(1)} pt > ${nutzBreite.toStringAsFixed(1)} pt');
    if (reihen * hoehe > nutzHoehe + 0.01) KammerUeberlauf.zuHoch(teil, naechste, ort(wo), reihen * hoehe, nutzHoehe);
    // Das Gitter liegt mittig; Text in den Randzellen und die Überschrift halten Abstand zur Papierkante.
    final seitlich = math.max(0.0, nutzBreite - spalten * breite) / 2;
    final senkrecht = math.max(0.0, nutzHoehe - reihen * hoehe) / 2;
    if (ueber != null) _druckRand(pw.EdgeInsets.fromLTRB(rand.left, rand.top, rand.right, KammerSatz.druckRand), wo);
    _druckRand(
      pw.EdgeInsets.fromLTRB(
        rand.left + seitlich + innen.left,
        rand.top + ueberHoehe + senkrecht + innen.top,
        rand.right + seitlich + innen.right,
        rand.bottom + senkrecht + innen.bottom,
      ),
      wo,
    );
    final jeSeite = spalten * reihen;
    final seiten = (zellen.length / jeSeite).ceil();
    if (maxSeiten != null && seiten > maxSeiten) _zuVieleSeiten(teil, naechste, ort(wo), seiten, maxSeiten);
    final iw = breite - innen.horizontal;
    final ih = hoehe - innen.vertical;
    for (var i = 0; i < zellen.length; i++) {
      final z = zellen[i];
      final h = satz.hoehe(z.oben, iw) + (z.unten == null ? 0 : satz.hoehe(z.unten!, iw) + 4);
      if (h > ih) KammerUeberlauf.zuHoch(teil, naechste + i ~/ jeSeite, ort(z.wo.isEmpty ? wo : z.wo), h, ih);
    }
    for (var s = 0; s < seiten; s++) {
      final blatt = zellen.skip(s * jeSeite).take(jeSeite).toList();
      vollSeite(
        quer: quer,
        rand: rand,
        // Das Gitter liegt in einem Stapel statt in Spalten: Füllen die Zellen das Blatt
        // genau (A7: 2 × 105 mm = 210 mm), ließe pw.Flex die letzte Reihe um eine
        // Rundung zu hoch still weg.
        (c) => pw.Column(children: [
          if (ueber != null) ...[ueber, pw.SizedBox(height: 6)],
          pw.Expanded(
            child: pw.Center(
              child: pw.SizedBox(
                width: spalten * breite,
                height: reihen * hoehe,
                child: pw.Stack(children: [
                  for (var i = 0; i < blatt.length; i++)
                    pw.Positioned(left: (i % spalten) * breite, top: (i ~/ spalten) * hoehe, child: _zelle(blatt[i], breite, hoehe, innen)),
                ]),
              ),
            ),
          ),
        ]),
      );
    }
  }

  pw.Widget _zelle(KammerZelle z, double breite, double hoehe, pw.EdgeInsets innen) => pw.Container(
        width: breite,
        height: hoehe,
        padding: innen,
        decoration: satz.schnitt(),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          z.oben,
          if (z.unten != null) ...[pw.Spacer(), z.unten!],
        ]),
      );

  /// Aktionskarten A7 hoch (74 × 105 mm), acht je A4 quer (MECH 4.3, 10.1).
  void a7(List<KammerZelle> karten, {pw.EdgeInsets innen = KammerSatz.a7Innen, String wo = ''}) => raster(
        karten,
        breite: KammerSatz.a7Breite,
        hoehe: KammerSatz.a7Hoehe,
        spalten: 4,
        reihen: 2,
        quer: true,
        innen: innen,
        wo: wo,
      );

  /// Karten im Z-Falz (Indiz- und Geheimniskarten, MECH 3.1 Nr. 9, 4.1): je Karte
  /// ein A5-Feld hoch (148 × 210 mm), zwei nebeneinander auf A4 quer. Feld 1
  /// (oben) [KammerZFalz.aussen], Feld 2 [KammerZFalz.innen], Feld 3 das
  /// Deckfeld mit grauem Raster; zwischen den Feldern Falzlinien, außen
  /// Schnittlinien. Beide Texte müssen in ihr Feld passen: Breite
  /// [KammerSatz.zFalzTextBreite] für [innen], Höhe Feldhöhe minus
  /// [innen] (Vorgabe [KammerSatz.zFalzInnen]). Die Felder reichen bis an die
  /// Papierkante; dort wächst der Innenabstand auf [KammerSatz.druckRand]
  /// ([KammerSatz.zFalzInnenFuer]).
  void zFalz(List<KammerZFalz> karten, {pw.EdgeInsets innen = KammerSatz.zFalzInnen, String wo = ''}) {
    const b = KammerSatz.a5Breite;
    const f = KammerSatz.zFalzFeldHoehe;
    final ih = f - innen.vertical;
    for (var i = 0; i < karten.length; i++) {
      final z = karten[i];
      final stelle = ort(z.wo.isEmpty ? wo : z.wo);
      final ib = b - KammerSatz.zFalzInnenFuer(innen, i % 2).horizontal;
      for (final w in [z.aussen, z.innen]) {
        final h = satz.hoehe(w, ib);
        if (h > ih) KammerUeberlauf.zuHoch(teil, naechste + i ~/ 2, stelle, h, ih);
        // Feld 1 liegt an der oberen Papierkante; sein Text steht mittig.
        final oben = innen.top + (ih - h) / 2;
        if (identical(w, z.aussen) && oben < KammerSatz.druckRand) _zuNahAmRand(teil, naechste + i ~/ 2, stelle, 'oben', oben);
      }
    }
    pw.Widget feld(pw.Widget kind, int spalte, {bool falz = true, bool mitte = false}) => pw.Container(
          width: b,
          height: f,
          padding: KammerSatz.zFalzInnenFuer(innen, spalte),
          decoration: falz
              ? const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: DruckStil.linie, width: 0.8, style: pw.BorderStyle.dotted)),
                )
              : null,
          child: mitte ? pw.Center(child: kind) : kind,
        );
    for (var i = 0; i < karten.length; i += 2) {
      final paar = karten.skip(i).take(2).toList();
      vollSeite(
        quer: true,
        (c) => pw.Center(
          child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
            for (final (spalte, z) in paar.indexed)
              pw.Container(
                width: b,
                height: KammerSatz.a5Hoehe,
                decoration: satz.schnitt(),
                child: pw.Column(children: [
                  feld(z.aussen, spalte, mitte: true),
                  feld(z.innen, spalte),
                  // Feld 3 füllt den Rest: Eine Spalte mit fester Höhe ließe ein Kind, das um
                  // eine Rundung zu hoch ist, still weg (pw.Flex teilt auf die nächste Seite).
                  pw.Expanded(child: pw.Padding(padding: const pw.EdgeInsets.all(3), child: satz.sichtschutz(b - 6, f - 7))),
                ]),
              ),
            if (paar.length == 1) pw.SizedBox(width: b, height: KammerSatz.a5Hoehe),
          ]),
        ),
      );
    }
  }

  // ---------------------------------------------------------------- Größen

  /// Größte Schriftgröße von [start] abwärts (in [schritt]), bei der [bauen] in
  /// [breite] × [hoehe] passt; unter [min] ist es ein Überlauf.
  double passendeGroesse(
    pw.Widget Function(double g) bauen, {
    required double breite,
    required double hoehe,
    double start = 11,
    double min = KammerSatz.kleinsteGroesse,
    double schritt = 0.25,
    String wo = '',
  }) {
    for (var g = start; g >= min - 1e-9; g -= schritt) {
      if (satz.hoehe(bauen(g), breite) <= hoehe) return g;
    }
    KammerUeberlauf.keineGroesse(teil, naechste, ort(wo), min, satz.hoehe(bauen(min), breite), hoehe);
  }

  /// Eine Schriftgröße für mehrere Inhalte (gleiche Gestalt, E9): die kleinste
  /// der passenden Größen.
  double gemeinsameGroesse(
    Iterable<pw.Widget Function(double g)> bauer, {
    required double breite,
    required double hoehe,
    double start = 11,
    double min = KammerSatz.kleinsteGroesse,
    double schritt = 0.25,
    String wo = '',
  }) =>
      [for (final b in bauer) passendeGroesse(b, breite: breite, hoehe: hoehe, start: start, min: min, schritt: schritt, wo: wo)].reduce(math.min);
}
