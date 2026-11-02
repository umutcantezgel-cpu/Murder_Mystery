/// Teil 20: Karten (MECH 3, 4, 10.1). Alle Seiten A4 quer, ohne Kopf und Fuß,
/// in dieser Reihenfolge:
///
/// 1. **Indizkarten** (MECH 3.1, 3.3), 19 Stück nach Code sortiert, zwei je
///    Blatt: zehn Blätter, auf dem letzten bleibt die rechte Hälfte leer.
/// 2. **Geheimniskarten** (MECH 4.1, 4.2) der besetzten Rollen und der heute
///    fehlenden Zeugen 5–10, in Platzreihenfolge, zwei je Blatt (bei 6 bis 12
///    Personen immer zehn, sonst so viele wie Rollen).
/// 3. **Aktionskarten** (MECH 4.3, 4.4, 4.6), dieselben Plätze, acht je Blatt;
///    die Karten der fehlenden Zeugen tragen den Kopf „heute beim Detektiv“.
///
/// Seiten: 10 + ⌈Geheimniskarten / 2⌉ + ⌈Aktionskarten / 8⌉, also 17 bei 6 bis
/// 12 Personen, 18 bei 13 und 14, 19 bei 15 und 16, 20 bei 17 und 18, 22 bei
/// 19 und 20 (MECH 10.1: 17 / 17 / 22).
///
/// Indiz- und Geheimniskarten sind je ein A5-Feld hoch im Z-Falz
/// ([KammerSeiten.zFalz]): Feld 1 oben ist die Außenseite (Indizkarte: Code
/// groß und der Satz aus `indiz.aussen` mit der Runde, E12; Geheimniskarte: die
/// neutrale Vorderseite, E8), Feld 2 die Innenseite mit dem Text, Feld 3 das
/// Deckfeld mit dem grauen Raster. Gefaltet wird Feld 1 nach hinten und Feld 3
/// nach vorn über den Text; das sagt der Falzhinweis ganz oben in Feld 2, direkt
/// unter dem Falz zu Feld 1. Der Text darunter beginnt mindestens [_textAbFalz]
/// unter diesem Falz: Ein um 2 mm verrutschter Falz trägt nichts davon nach
/// außen (höchstens den Hinweis), und das Raster deckt ihn auch dort, wo der
/// Drucker den unteren Rand des Deckfelds nicht druckt (das Deckfeld liegt
/// gefaltet mit seiner Papierkante am oberen Falz).
///
/// Aktionskarten sind A7 hoch ([KammerSeiten.a7]): Kopf, Name mit „ab Runde“,
/// Wirkung, Grenzen, unten der Fuß; die Rückseite bleibt leer.
///
/// Schrift: nie unter [_min] (9 pt, FALL-BIBEL 19.2 Nr. 4; die Ausnahme 8 pt
/// gilt nur für Joannas Notiz in Teil 02). Jede Indizkarte bekommt die größte
/// Größe bis [_start], die passt; die Geheimniskarten aller 18 Rollen teilen
/// eine Größe, ebenso die Aktionskarten (gleiche Gestalt, E9). Passt etwas
/// auch in 9 pt nicht, ist das ein [KammerUeberlauf] mit Code bzw. Rolle.
library;

import 'dart:math' as math;

import 'package:pdf/widgets.dart' as pw;

import '../satz_stil.dart';
import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

const _mm = KammerSatz.mm;

/// Kleinste Schriftgröße auf jeder Karte, innen wie außen (9 pt).
const double _min = 9;

/// Größte Schriftgröße für den Text der Innenseiten und Aktionskarten.
const double _start = 11;

/// Innenabstand der drei Felder im Z-Falz: oben und unten 1,5 mm zum Falz (in
/// Feld 2 steht oben der Falzhinweis, der Text erst ab [_textAbFalz]), links und
/// rechts 10 pt an der Schnittlinie in der Mitte; an der Papierkante wächst er
/// auf den Druckrand ([KammerSatz.zFalzInnenFuer]).
const _zInnen = pw.EdgeInsets.fromLTRB(10, 1.5 * _mm, 10, 1.5 * _mm);

/// So weit unter dem Falz zwischen Feld 1 und Feld 2 beginnt der Text der Innenseite mindestens.
const _textAbFalz = 5 * _mm;

/// Abstand zwischen Falzhinweis und Text mindestens.
const double _nachHinweis = 3;

/// Zugabe an der Papierkante: Das letzte Zeichen einer vollen Zeile ragt bis
/// zu 0,1 em über die gemessene Breite hinaus (bei 11 pt gut 1 pt). Damit auch
/// die Glyphen selbst den Druckrand halten, rücken Text im Z-Falz und auf den
/// Aktionskarten an der Papierkante um so viel weiter nach innen.
const double _ueberhang = 2;

/// Innenabstand der Aktionskarten: 5 mm rundum. Der Text ist um [_ueberhang]
/// schmaler als das Feld ([_a7Text]); so hält er überall den Druckrand.
const _a7Innen = pw.EdgeInsets.all(5 * _mm);

/// Textbreite einer Aktionskarte.
const _a7Text = KammerSatz.a7Breite - 10 * _mm - _ueberhang;

/// Setzt Teil 20 (Karten) in [doc]: Indizkarten nach Code, Geheimniskarten und
/// Aktionskarten in Platzreihenfolge (besetzte Rollen und fehlende Zeugen 5–10).
void kammerKarten(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '20', (s) {
      final x = k.satz;
      String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui('20', schluessel, werte);
      final b = k.besetzung;
      final platz = _ZFalzPlatz(s);

      // 1. Indizkarten, nach Code sortiert (MECH 3.1 Nr. 6); je Karte die größte passende Schrift.
      final karten = [...k.inhalt.indizkarten.karten]..sort((a, c) => a.code.compareTo(c.code));
      s.zFalz(innen: _zInnen, wo: 'indizkarten', [
        for (final (i, c) in karten.indexed)
          KammerZFalz(
            aussen:
                platz.aussenseite(x.aussenseite(c.code, u('indiz.aussen', {'code': c.code, 'runde': '${c.abRunde}'}), codeGroesse: 36, hinweisGroesse: 11), i),
            innen: platz.innenseite(_indizInnen(k, c, platz.groesse((g) => _indizInnen(k, c, g), wo: c.code)), i),
            wo: c.code,
          ),
      ]);

      // 2. Geheimniskarten (MECH 4.1): Vorderseite neutral, die Bedingung steht nur im Heft (E8).
      final gg = _geheimnisGroesse(k, platz);
      s.zFalz(innen: _zInnen, wo: 'geheimniskarten', [
        for (final (i, p) in b.geheimniskarten.indexed)
          KammerZFalz(aussen: platz.aussenseite(_geheimnisAussen(k, p), i), innen: platz.innenseite(_geheimnisInnen(k, p, gg), i), wo: p.name),
      ]);

      // 3. Aktionskarten (MECH 4.3), eine Schriftgröße für alle.
      final ag = _aktionGroesse(s, k, b.aktionskarten);
      s.a7(innen: _a7Innen, wo: 'aktionskarten', [for (final p in b.aktionskarten) _aktionZelle(k, p, ag)]);
    });

/// Die Abbildung der Aktionskarte von [p] auf einer A4-Seite (Einzeldatei,
/// MECH 10.3): in Originalgröße und derselben Schrift wie im Kartensatz.
void kammerAktionskarteSeite(pw.Document doc, KammerKontext k, KammerPlatz p) => kammerTeilSetzen(doc, k, '20', (s) {
      final x = k.satz;
      final g = _aktionGroesse(s, k, {...k.besetzung.aktionskarten, p});
      final z = _aktionZelle(k, p, g);
      s.seite(wo: 'aktionskarte', [
        x.ueberschrift(k.uiGemeinsam('heft.deineAktionskarte')),
        pw.SizedBox(height: 16),
        pw.Center(
          child: pw.Container(
            width: KammerSatz.a7Breite,
            height: KammerSatz.a7Hoehe,
            padding: _a7Innen,
            decoration: x.schnitt(),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [z.oben, pw.Spacer(), z.unten!]),
          ),
        ),
      ]);
    }, bereich: p.name);

// ---------------------------------------------------------------- Z-Falz

/// Platz in den Feldern des Z-Falzes: Textbreite (ohne die Zugabe
/// [_ueberhang] an der Papierkante); in Feld 2 oben der Falzhinweis
/// (`ui/20.json` → `falz.hinweis`), darunter ab [_textAbFalz] der Text bis zum
/// unteren Innenabstand. Karte `i` steht in Spalte `i % 2` (zwei je Blatt).
class _ZFalzPlatz {
  _ZFalzPlatz(this.s) : breite = KammerSatz.zFalzTextBreite(_zInnen) - _ueberhang {
    hinweis = s.satz.absatz(s.k.ui('20', 'falz.hinweis'), groesse: _min, leise: true, ausrichtung: pw.TextAlign.center);
    final h = s.satz.hoehe(hinweis, breite);
    luecke = math.max(_nachHinweis, _textAbFalz - _zInnen.top - h);
    text = KammerSatz.zFalzFeldHoehe - _zInnen.vertical - h - luecke;
  }

  final KammerSeiten s;
  final double breite;
  late final pw.Widget hinweis;

  /// Abstand zwischen Falzhinweis und Text.
  late final double luecke;

  /// Höhe für den Text unter dem Falzhinweis.
  late final double text;

  /// Größte Schrift von [_start] abwärts, bei der [bauen] unter dem Falzhinweis Platz hat; unter 9 pt ein Überlauf.
  double groesse(pw.Widget Function(double g) bauen, {required String wo}) =>
      s.passendeGroesse(bauen, breite: breite, hoehe: text, start: _start, min: _min, wo: wo);

  /// [inhalt] in der Breite [breite], an der Papierkante der Karte [i] um [_ueberhang] eingerückt.
  pw.Widget _spalte(pw.Widget inhalt, int i) => pw.Padding(
        padding: i.isEven ? const pw.EdgeInsets.only(left: _ueberhang) : const pw.EdgeInsets.only(right: _ueberhang),
        child: pw.SizedBox(width: breite, child: inhalt),
      );

  /// Feld 1 der Karte [i]: [inhalt] mittig.
  pw.Widget aussenseite(pw.Widget inhalt, int i) => _spalte(pw.Center(child: inhalt), i);

  /// Feld 2 der Karte [i]: oben der Falzhinweis, darunter [inhalt] (mit
  /// [groesse] gemessen; [KammerSeiten.zFalz] prüft das Ganze noch einmal
  /// gegen das Feld).
  pw.Widget innenseite(pw.Widget inhalt, int i) => _spalte(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(width: breite, child: hinweis),
            pw.SizedBox(height: luecke),
            inhalt,
          ],
        ),
        i,
      );
}

/// Absatz mit fettem Etikett vorn („**Was du findest:** …“), wie in den Heften.
pw.Widget _mitEtikett(KammerKontext k, String etikett, String text, double g) => k.satz.absatz('**${k.klartext(etikett)}:** ${k.text(text)}', groesse: g);

/// „Für den Ermittlungsbogen“: Etikett und die Vermerke als Liste, mit einem
/// Strich links, damit der Detektiv sie auf einen Blick findet.
pw.Widget _fuerDenBogen(KammerKontext k, List<String> vermerke, double g) => pw.Container(
      padding: pw.EdgeInsets.only(left: g * 0.7),
      decoration: const pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: DruckStil.tinte, width: 1.5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          k.satz.absatz('**${k.klartext(k.uiGemeinsam('karte.fuerDenBogen'))}:**', groesse: g),
          pw.SizedBox(height: g * 0.15),
          k.satz.liste(vermerke, groesse: g, abstand: g * 0.15),
        ],
      ),
    );

/// Kopfzeile einer Innenseite: [titel] links, [rechts] (Code) rechts.
pw.Widget _kopf(KammerKontext k, String titel, double g, {String? rechts}) => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(child: k.satz.absatz('**${k.klartext(titel)}**', groesse: g + 1.5)),
        if (rechts != null) ...[pw.SizedBox(width: g), k.satz.absatz('**$rechts**', groesse: g + 1.5)],
      ],
    );

// ---------------------------------------------------------------- Indizkarten

/// Innenseite einer Indizkarte (MECH 3.3): Titel und Code, „Was du findest“, bei
/// Ortsterminen „Ortstermin“ mit dem Schlusssatz (Mehrzahl, wenn der Ort mehr als
/// einen Zeugenstreifen öffnet), dann „Für den Ermittlungsbogen“.
pw.Widget _indizInnen(KammerKontext k, KammerIndizkarte c, double g) {
  final ik = k.inhalt.indizkarten;
  final vermerke = c.art == KammerKartenArt.ortstermin && c.vermerke.isEmpty ? [ik.ortsterminVermerk] : c.vermerke;
  final abstand = pw.SizedBox(height: g * 0.45);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _kopf(k, c.titel, g, rechts: c.code),
      abstand,
      _mitEtikett(k, k.ui('20', 'indiz.wasDuFindest'), c.wasDuFindest, g),
      if (c.ortstermin case final o?) ...[
        abstand,
        _mitEtikett(k, k.ui('20', 'indiz.ortstermin'), o, g),
        pw.SizedBox(height: g * 0.2),
        k.satz.absatz(c.zeugen.length > 1 ? ik.ortsterminSchlussMehrzahl : ik.ortsterminSchlussEinzahl, groesse: g),
      ],
      abstand,
      _fuerDenBogen(k, vermerke, g),
    ],
  );
}

// ---------------------------------------------------------------- Geheimniskarten

/// Vorderseite (Feld 1, E8, MECH 4.1 wörtlich): „Geheimnis · Name · Platz“ und
/// der Hinweis; bei einem fehlenden Zeugen der eine Satz für den Erzähler.
pw.Widget _geheimnisAussen(KammerKontext k, KammerPlatz p) {
  final x = k.satz;
  final werte = {'name': p.name, 'platz': '${p.platz}'};
  if (!k.besetzung.istBesetzt(p.id)) {
    return x.absatz(k.ui('20', 'geheimnis.vorne.fehlt', werte), groesse: 15, ausrichtung: pw.TextAlign.center);
  }
  return pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      x.absatz('**${k.ui('20', 'geheimnis.vorne', werte)}**', groesse: 18, ausrichtung: pw.TextAlign.center),
      pw.SizedBox(height: 8),
      x.absatz(k.ui('20', 'geheimnis.vorne.hinweis'), groesse: 11, ausrichtung: pw.TextAlign.center, leise: true),
    ],
  );
}

/// Innenseite einer Geheimniskarte (MECH 4.1, für alle 18 gleich gebaut): Kopf
/// mit dem Namen (die Vorderseite liegt nach dem Aufklappen unten), „Was ich
/// zugebe“, „Für den Ermittlungsbogen“, „Und noch etwas“.
pw.Widget _geheimnisInnen(KammerKontext k, KammerPlatz p, double g) {
  final gk = k.rolle(p).geheimniskarte;
  final abstand = pw.SizedBox(height: g * 0.45);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _kopf(k, k.ui('20', 'geheimnis.innen', {'name': p.name}), g),
      abstand,
      _mitEtikett(k, k.uiGemeinsam('karte.wasIchZugebe'), gk.wasIchZugebe, g),
      abstand,
      _fuerDenBogen(k, gk.vermerke, g),
      abstand,
      _mitEtikett(k, k.uiGemeinsam('karte.undNochEtwas'), gk.undNochEtwas, g),
    ],
  );
}

/// Eine Schrift für die Geheimniskarten aller 18 Rollen (gleiche Gestalt, E9):
/// So sehen die Karten bei jeder Besetzung gleich aus. Gemessen wird jede Karte
/// in der heutigen Besetzung (Platzhalter aufgelöst).
double _geheimnisGroesse(KammerKontext k, _ZFalzPlatz platz) {
  var g = _start;
  for (final p in k.inhalt.fall.plaetze) {
    final eigen = platz.groesse((g) => _geheimnisInnen(k, p, g), wo: p.name);
    if (eigen < g) g = eigen;
  }
  return g;
}

// ---------------------------------------------------------------- Aktionskarten

/// Schriftgröße der Aktionskarten [plaetze]: die größte bis [_start], bei der
/// alle in ihr A7-Feld passen; nie unter 9 pt.
double _aktionGroesse(KammerSeiten s, KammerKontext k, Iterable<KammerPlatz> plaetze) => s.gemeinsameGroesse(
      [
        for (final p in plaetze)
          (g) {
            final z = _aktionZelle(k, p, g);
            return pw.Column(children: [z.oben, pw.SizedBox(height: 4), z.unten!]);
          },
      ],
      breite: KammerSatz.a7Breite - _a7Innen.horizontal,
      hoehe: KammerSatz.a7Hoehe - _a7Innen.vertical,
      start: _start,
      min: _min,
      wo: 'aktionskarten',
    );

/// Inhalt einer Aktionskarte (MECH 4.3): Kopf „Aktionskarte · Name“ bzw. „heute
/// beim Detektiv“ (MECH 4.6), Name mit „ab Runde“, Wirkung, Grenzen; unten der Fuß.
KammerZelle _aktionZelle(KammerKontext k, KammerPlatz p, double g) {
  final x = k.satz;
  final a = k.rolle(p).aktionskarte;
  final kopf = k.besetzung.istBesetzt(p.id) ? k.ui('20', 'aktion.kopf', {'name': p.name}) : k.ui('20', 'aktion.kopf.detektiv');
  return KammerZelle(
    pw.SizedBox(
      width: _a7Text,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          x.absatz('**${k.klartext(kopf)}**', groesse: _min, leise: true),
          pw.SizedBox(height: g * 0.5),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(child: x.absatz('**${k.klartext(a.name)}**', groesse: g + 3)),
              pw.SizedBox(width: g * 0.6),
              x.absatz(k.uiGemeinsam('ab.runde', {'runde': '${a.abRunde}'}), groesse: _min, leise: true),
            ],
          ),
          pw.SizedBox(height: g * 0.6),
          _mitEtikett(k, k.ui('20', 'aktion.wirkung'), a.wirkung, g),
          pw.SizedBox(height: g * 0.5),
          _mitEtikett(k, k.ui('20', 'aktion.grenzen'), a.grenzen, g),
        ],
      ),
    ),
    unten: pw.Container(
      width: _a7Text,
      padding: const pw.EdgeInsets.only(top: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: DruckStil.linie, width: 0.5)),
      ),
      child: x.absatz(k.ui('20', 'aktion.fuss'), groesse: _min, leise: true),
    ),
    wo: p.name,
  );
}
