/// Teil 01: Detektivbogen und Ermittlungsbogen (MECH 2, RK 6, Kap. 8 und 16 der
/// Fall-Bibel): Auftritt, eigenes Wissen, Fragen-Leitfaden, Untersuchungsliste,
/// Ermittlungsbogen, Vermerke, Anklage, Aktionskarten fehlender Zeugen.
///
/// Stand: einfache, aber echte Fassung aus dem Inhalt (Gerüst G2). Gliederung,
/// Seitenzahlen (MECH 10.1: 6 Seiten) und Feinheiten baut der Teil-Agent 01.
library;

import 'package:pdf/widgets.dart' as pw;

import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Setzt Teil 01 (Detektivbogen) in [doc].
void kammerDetektivbogen(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '01', (s) {
      final d = k.inhalt.detektiv;
      final g = k.inhalt.gemeinsam;
      final x = k.satz;
      final b = k.besetzung;
      String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui('01', schluessel, werte);
      // Untersuchungsliste in der Reihenfolge der Runden, darin nach Code (MECH 3.2).
      final karten = [...k.inhalt.indizkarten.karten]..sort((a, c) => a.abRunde != c.abRunde ? a.abRunde - c.abRunde : a.code.compareTo(c.code));
      final bogen = d.bogen;
      final tipps = {for (final t in d.aktionskartenTipps) t.schluessel: t.text};

      s.fliessend(wo: 'bogen', [
        x.titel(k.teilTitel('01')),
        pw.SizedBox(height: 6),
        x.ueberschrift(u('deinAuftritt')),
        x.absatz(d.auftritt),
        x.ueberschrift(u('wasDuSelbstWeisst')),
        x.liste(d.wasDuSelbstWeisst, groesse: 10.5),
        x.ueberschrift(k.uiGemeinsam('ueberschrift.wasAlleWissen')),
        x.liste(g.wasAlleWissen, groesse: 10),
        x.ueberschrift(k.uiGemeinsam('ueberschrift.soSpieltIhr')),
        x.kasten([x.absatz(g.soSpieltIhr, groesse: 10)]),

        pw.NewPage(),
        x.ueberschrift(u('fragenLeitfaden')),
        for (final gruppe in d.fragenLeitfaden) ...[
          x.ueberschrift(gruppe.titel, stufe: 3),
          x.liste([for (final f in gruppe.fragen) f.nr == null ? f.text : '**${f.nr}** ${f.text}'], groesse: 10),
        ],
        x.ueberschrift(u('untersuchungen')),
        x.liste(d.untersuchungen, groesse: 10),
        x.ueberschrift(u('aufgabenJeRunde')),
        for (final a in d.aufgabenJeRunde) ...[
          x.ueberschrift(k.uiGemeinsam('runde', {'runde': '${a.runde}'}), stufe: 3),
          x.liste(a.zeilen, nummer: KammerNummer.zahl, groesse: 10),
        ],

        pw.NewPage(),
        x.ueberschrift(u('untersuchungsliste')),
        x.tabelle(
          kopf: [u('untersuchungsliste.titel'), u('untersuchungsliste.code'), u('untersuchungsliste.abRunde'), u('untersuchungsliste.gewaehlt')],
          zeilen: [for (final c in karten) [c.titel, c.code, '${c.abRunde}', null]],
          spalten: [5, 1, 1, 2],
        ),

        pw.NewPage(),
        x.ueberschrift(u('ermittlungsbogen')),
        x.absatz(bogen.hinweis, groesse: 10),
        pw.SizedBox(height: 6),
        x.tabelle(
          kopf: ['', for (final id in bogen.spalten) k.inhalt.platzVon(id).name],
          zeilen: [
            for (final z in bogen.zeilen)
              [
                z.zusatz == null ? '**${z.titel}**' : '**${z.titel}**\n${z.zusatz}',
                for (final _ in bogen.spalten) pw.Center(child: x.kaestchen(11)),
              ],
          ],
          spalten: [3, 1, 1, 1, 1],
          groesse: 10,
        ),
        pw.SizedBox(height: 6),
        x.liste(bogen.unterRaster, groesse: 9.5),
        pw.SizedBox(height: 6),
        x.absatz(bogen.entlastungsregel, groesse: 10),
        pw.SizedBox(height: 4),
        x.absatz(bogen.ueberfuehrungsregel, groesse: 10),
        pw.SizedBox(height: 4),
        x.absatz(bogen.fuehren, groesse: 10),

        pw.NewPage(),
        x.ueberschrift(u('vermerke')),
        x.tabelle(
          kopf: [u('vermerke.nr'), u('vermerke.runde'), u('vermerke.quelle'), u('vermerke.vermerk')],
          zeilen: [for (var i = 1; i <= d.vermerkeZeilen; i++) ['$i', null, null, null]],
          spalten: [0.6, 0.9, 1.6, 7],
          groesse: 8.5,
        ),

        pw.NewPage(),
        x.ueberschrift(u('anklage')),
        x.liste(d.anklageFeld, nummer: KammerNummer.keine, abstand: 10),
        pw.SizedBox(height: 6),
        x.absatz(d.anklageHilfe, groesse: 10),
        if (b.aktionskartenBeimDetektiv.isNotEmpty) ...[
          x.ueberschrift(u('aktionskartenFehlend')),
          for (final p in b.aktionskartenBeimDetektiv)
            if (tipps[p.id] case final t?) ...[x.ueberschrift(_kartenName(k, p), stufe: 3), x.absatz(t, groesse: 10)],
        ],
        x.ueberschrift(u('gegenKarten')),
        x.absatz(d.gegenKarten, groesse: 10),
        x.ueberschrift(k.uiGemeinsam('ueberschrift.tischregeln')),
        x.tabelle(zeilen: [for (final r in g.tischregeln) [r.nr, r.name, r.text]], spalten: [0.8, 1.8, 7], groesse: 9),
      ]);
    });

/// „Name: Aktion“ einer Aktionskarte (Name der Rolle und der Karte).
String _kartenName(KammerKontext k, KammerPlatz p) => '${p.name}: ${k.klartext(k.rolle(p).aktionskarte.name)}';
