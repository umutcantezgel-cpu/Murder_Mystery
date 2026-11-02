/// Teil 90: das versiegelte Auflösungsheft (MECH 8.4, Kap. 13 der Fall-Bibel):
/// Was wirklich war, die neun Meilensteine, die vier Enden, Rückblende,
/// Zeitleiste, die Rollen am Tisch, Tipp-Wertung, zum Nachlesen. Wird nie
/// einzeln gesendet (MECH 10.3).
///
/// Stand: einfache, aber echte Fassung aus dem Inhalt (Gerüst G2). Gliederung,
/// Seitenzahlen (MECH 10.1: 9 / 10 / 12) und Feinheiten baut der Teil-Agent 90.
library;

import 'package:pdf/widgets.dart' as pw;

import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Setzt Teil 90 (Auflösungsheft, versiegelt) in [doc].
void kammerAufloesung(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '90', (s) {
      final a = k.inhalt.aufloesung;
      final f = k.fall;
      final x = k.satz;
      final b = k.besetzung;
      String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui('90', schluessel, werte);
      final namen = {for (final e in a.enden) e.nr: e.name};

      // Bund-Satz je Ende: beide Fassungen, ob PP9 noch zu oder schon offen ist (SCHEMA aufloesung.json).
      String bund(KammerEnde e) {
        final taeter = e.anklage == 'taeter';
        final ohne = taeter ? a.bundSaetze.taeterOhnePp9 : a.bundSaetze.andereOhnePp9;
        final mit = taeter ? a.bundSaetze.taeterMitPp9 : a.bundSaetze.andereMitPp9;
        return '**${u('bund.ohnePp9')}** ${k.text(ohne)}\n**${u('bund.mitPp9')}** ${k.text(mit)}';
      }

      s.versiegelt(code: k.fallCode, titel: k.fallTitel, hinweis: u('deckblatt.titel'));

      s.fliessend(wo: 'heft', [
        x.ueberschrift(u('wasWirklichWar')),
        x.absatz(a.wasWirklichWar),

        pw.NewPage(),
        x.ueberschrift(u('meilensteine')),
        x.tabelle(
          kopf: [u('meilensteine.nr'), u('meilensteine.feld'), u('meilensteine.kernfakt'), u('meilensteine.stichwort'), u('meilensteine.haken')],
          zeilen: [for (final m in a.meilensteine) [m.nr, m.feld, m.kernfakt, m.stichwort, pw.Center(child: x.kaestchen(10))]],
          spalten: [0.6, 1.6, 3, 3, 0.6],
          groesse: 9,
        ),
        pw.SizedBox(height: 6),
        x.absatz(u('meilensteine.summe', {'max': '${f.punkte.detektivMax}'}), groesse: 11),
        pw.SizedBox(height: 6),
        x.absatz(a.meilensteinRegel, groesse: 10),
        pw.SizedBox(height: 4),
        x.absatz(a.pruefung, groesse: 10),

        pw.NewPage(),
        x.ueberschrift(u('enden')),
        x.tabelle(
          kopf: [u('enden.ende'), u('enden.anklage'), u('enden.punkte'), u('enden.name')],
          zeilen: [
            for (final e in f.enden)
              [
                '${e.nr}',
                e.anklage == 'taeter' ? u('enden.anklage.taeter') : u('enden.anklage.andere'),
                u('enden.bereich', {'von': '${e.von}', 'bis': '${e.bis}'}),
                namen[e.nr] ?? '',
              ],
          ],
          spalten: [0.7, 2, 1.5, 4],
        ),
        for (final e in f.enden)
          if (a.enden.where((t) => t.nr == e.nr).firstOrNull case final t?) ...[
            x.ueberschrift(u('ende', {'nr': '${e.nr}', 'name': k.text(t.name)}), stufe: 2),
            x.absatz(t.text, werte: {'bund': bund(e)}),
          ],

        pw.NewPage(),
        x.ueberschrift(u('rueckblende')),
        for (final r in a.rueckblende) ...[x.absatz(r), pw.SizedBox(height: 6)],
        x.ueberschrift(u('zeitleiste')),
        x.tabelle(zeilen: [for (final z in a.zeitleiste) [z.zeit, z.text]], spalten: [1.2, 6], groesse: 9),

        pw.NewPage(),
        x.ueberschrift(u('rollenAmTisch')),
        for (final p in b.besetzt) ...[x.ueberschrift(p.name, stufe: 3), x.absatz(k.rolle(p).teil90, groesse: 10.5)],

        pw.NewPage(),
        x.ueberschrift(u('tippWertung')),
        x.tabelle(zeilen: [for (final t in a.tippFragen) ['${t.nr}', '${t.punkte}', t.loesung]], spalten: [0.5, 0.7, 7]),
        pw.SizedBox(height: 6),
        x.absatz(a.sonderregel, groesse: 10),
        pw.SizedBox(height: 4),
        x.absatz(a.spuernase, groesse: 10),
        x.ueberschrift(u('tippWertung.bonusZiele'), stufe: 2),
        x.tabelle(zeilen: [for (final p in b.besetzt) [p.name, k.rolle(p).bonusZiel.text]], spalten: [1.2, 6], groesse: 9),
        x.ueberschrift(u('tippWertung.erzaehler'), stufe: 2),
        x.absatz(a.erzaehlerBonus, groesse: 10),

        pw.NewPage(),
        x.ueberschrift(u('zumNachlesen')),
        x.ueberschrift(u('zumNachlesen.ausloeser'), stufe: 2),
        for (final p in b.besetzt) ...[
          x.ueberschrift(p.name, stufe: 3),
          x.liste(k.rolle(p).stufe2.ausloeser, nummer: p.art == KammerArt.verdaechtig ? KammerNummer.buchstabe : KammerNummer.zahl, groesse: 9),
        ],
        if (b.streifen.isNotEmpty) ...[
          x.ueberschrift(u('zumNachlesen.streifen'), stufe: 2),
          for (final st in b.streifen) ...[
            x.absatz(st.etikett, groesse: 9),
            x.absatz(st.protokoll, groesse: 9),
            x.absatz(st.vermerk, groesse: 9, leise: true),
            pw.SizedBox(height: 6),
          ],
        ],
        x.ueberschrift(u('zumNachlesen.indizkarten'), stufe: 2),
        x.tabelle(
          zeilen: [for (final c in ([...k.inhalt.indizkarten.karten]..sort((p, q) => p.code.compareTo(q.code)))) [c.code, c.titel, '${c.abRunde}']],
          spalten: [0.8, 5, 0.7],
          groesse: 9,
        ),
      ]);
    });
