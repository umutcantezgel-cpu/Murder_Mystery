/// Teil 20: Indizkarten (19), Geheimniskarten und Aktionskarten (MECH 3, 4,
/// 10.1). Indiz- und Geheimniskarten als A5-Feld hoch im Z-Falz, zwei je A4
/// quer (Text innen, Außenseite neutral); Aktionskarten A7, acht je A4 quer.
/// Dazu die Abbildung der eigenen Aktionskarte für die Einzeldatei (MECH 10.3).
///
/// Stand: einfache, aber echte Fassung aus dem Inhalt (Gerüst G2). Seitenzahlen
/// (MECH 10.1: 17 / 17 / 22) und Feinheiten baut der Teil-Agent 20.
library;

import 'package:pdf/widgets.dart' as pw;

import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Setzt Teil 20 (Karten) in [doc]: Indizkarten nach Code, Geheimniskarten und
/// Aktionskarten in Platzreihenfolge (besetzte Rollen und fehlende Zeugen 5–10).
void kammerKarten(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '20', (s) {
      final x = k.satz;
      String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui('20', schluessel, werte);
      final b = k.besetzung;
      final ik = k.inhalt.indizkarten;

      // Gerüst: knapper Innenabstand und Schrift ab 7,5 pt, damit alle Karten in
      // ihr Feld passen; die endgültigen Maße legt der Teil-Agent 20 fest.
      const innen = pw.EdgeInsets.all(10);
      // An der Papierkante wächst der Innenabstand auf den Druckrand (KammerSatz.zFalzInnenFuer).
      final ib = KammerSatz.zFalzTextBreite(innen);
      final ih = KammerSatz.zFalzFeldHoehe - innen.vertical;
      const min = 7.5;

      // Indizkarten, nach Code sortiert (MECH 3.1 Nr. 6).
      final karten = [...ik.karten]..sort((a, c) => a.code.compareTo(c.code));
      s.zFalz(innen: innen, wo: 'indizkarten', [
        for (final c in karten)
          () {
            final g = s.passendeGroesse(
              (g) => _indizInnen(k, c, g),
              breite: ib,
              hoehe: ih,
              start: 10.5,
              min: min,
              wo: c.code,
            );
            return KammerZFalz(
              aussen: x.absatz(u('indiz.aussen', {'code': c.code, 'runde': '${c.abRunde}'}), groesse: 11, ausrichtung: pw.TextAlign.center),
              innen: _indizInnen(k, c, g),
              wo: c.code,
            );
          }(),
      ]);

      // Geheimniskarten (MECH 4.1): Vorderseite neutral, die Bedingung steht nur im Heft (E8).
      s.zFalz(innen: innen, wo: 'geheimniskarten', [
        for (final p in b.geheimniskarten)
          () {
            final werte = {'name': p.name, 'platz': '${p.platz}'};
            final fehlt = !b.istBesetzt(p.id);
            final g = s.passendeGroesse(
              (g) => _geheimnisInnen(k, p, g),
              breite: ib,
              hoehe: ih,
              start: 10.5,
              min: min,
              wo: p.name,
            );
            return KammerZFalz(
              aussen: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
                x.absatz(fehlt ? u('geheimnis.vorne.fehlt', werte) : '**${u('geheimnis.vorne', werte)}**', groesse: 12, ausrichtung: pw.TextAlign.center),
                if (!fehlt) ...[pw.SizedBox(height: 6), x.absatz(u('geheimnis.vorne.hinweis'), groesse: 9.5, ausrichtung: pw.TextAlign.center, leise: true)],
              ]),
              innen: _geheimnisInnen(k, p, g),
              wo: p.name,
            );
          }(),
      ]);

      // Aktionskarten (MECH 4.3), eine Schriftgröße für alle.
      final aktion = b.aktionskarten;
      final g = _aktionGroesse(s, k, aktion);
      s.a7(wo: 'aktionskarten', [for (final p in aktion) _aktionZelle(k, p, g)]);
    });

/// Die Abbildung der Aktionskarte von [p] auf einer A4-Seite (Einzeldatei, MECH 10.3).
void kammerAktionskarteSeite(pw.Document doc, KammerKontext k, KammerPlatz p) => kammerTeilSetzen(doc, k, '20', (s) {
      final x = k.satz;
      final z = _aktionZelle(k, p, _aktionGroesse(s, k, [p]));
      s.seite(wo: 'aktionskarte', [
        x.ueberschrift(k.uiGemeinsam('heft.deineAktionskarte')),
        pw.SizedBox(height: 16),
        pw.Center(
          child: pw.Container(
            width: KammerSatz.a7Breite,
            height: KammerSatz.a7Hoehe,
            padding: KammerSatz.a7Innen,
            decoration: x.schnitt(),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [z.oben, pw.Spacer(), z.unten!]),
          ),
        ),
      ]);
    }, bereich: p.name);

/// Schriftgröße der Aktionskarten [plaetze]: die größte, bei der alle in ihr A7-Feld passen.
double _aktionGroesse(KammerSeiten s, KammerKontext k, List<KammerPlatz> plaetze) => s.gemeinsameGroesse(
      [
        for (final p in plaetze)
          (g) {
            final z = _aktionZelle(k, p, g);
            return pw.Column(children: [z.oben, pw.SizedBox(height: 4), z.unten!]);
          },
      ],
      breite: KammerSatz.a7InnenBreite,
      hoehe: KammerSatz.a7InnenHoehe,
      start: 10,
      wo: 'aktionskarten',
    );

pw.Widget _etikett(KammerKontext k, String text, double g) =>
    pw.Padding(padding: const pw.EdgeInsets.only(top: 4, bottom: 2), child: k.satz.marke(text, groesse: g * 0.85));

pw.Widget _indizInnen(KammerKontext k, KammerIndizkarte c, double g) {
  final x = k.satz;
  final ik = k.inhalt.indizkarten;
  final vermerke = c.art == KammerKartenArt.ortstermin && c.vermerke.isEmpty ? [ik.ortsterminVermerk] : c.vermerke;
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    x.absatz('**${k.klartext(c.titel)}**', groesse: g + 1.5),
    _etikett(k, k.ui('20', 'indiz.wasDuFindest'), g),
    x.absatz(c.wasDuFindest, groesse: g),
    if (c.ortstermin case final o?) ...[
      _etikett(k, k.ui('20', 'indiz.ortstermin'), g),
      x.absatz(o, groesse: g),
      pw.SizedBox(height: 2),
      x.absatz(c.zeugen.length > 1 ? ik.ortsterminSchlussMehrzahl : ik.ortsterminSchlussEinzahl, groesse: g),
    ],
    _etikett(k, k.uiGemeinsam('karte.fuerDenBogen'), g),
    x.liste(vermerke, groesse: g, abstand: 1),
  ]);
}

pw.Widget _geheimnisInnen(KammerKontext k, KammerPlatz p, double g) {
  final x = k.satz;
  final gk = k.rolle(p).geheimniskarte;
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    _etikett(k, k.uiGemeinsam('karte.wasIchZugebe'), g),
    x.absatz(gk.wasIchZugebe, groesse: g),
    _etikett(k, k.uiGemeinsam('karte.fuerDenBogen'), g),
    x.liste(gk.vermerke, groesse: g, abstand: 1),
    _etikett(k, k.uiGemeinsam('karte.undNochEtwas'), g),
    x.absatz(gk.undNochEtwas, groesse: g),
  ]);
}

/// Inhalt einer Aktionskarte (MECH 4.3): Kopf, Name, Wirkung, Grenzen; unten der Fuß.
KammerZelle _aktionZelle(KammerKontext k, KammerPlatz p, double g) {
  final x = k.satz;
  final a = k.rolle(p).aktionskarte;
  final kopf = k.besetzung.istBesetzt(p.id) ? k.ui('20', 'aktion.kopf', {'name': p.name}) : k.ui('20', 'aktion.kopf.detektiv');
  return KammerZelle(
    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      x.marke(kopf, groesse: 7.5),
      pw.SizedBox(height: 4),
      x.absatz('**${k.klartext(a.name)}**', groesse: g + 3),
      _etikett(k, k.ui('20', 'aktion.wirkung'), g),
      x.absatz(a.wirkung, groesse: g),
      _etikett(k, k.ui('20', 'aktion.grenzen'), g),
      x.absatz(a.grenzen, groesse: g),
    ]),
    unten: x.absatz(k.ui('20', 'aktion.fuss'), groesse: 7.5, leise: true),
    wo: p.name,
  );
}
