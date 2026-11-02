/// Teil 00: Erzählerheft (MECH 9, Kap. 14 der Fall-Bibel). Der Erzähler kennt
/// die Lösung nicht (E10): Das Heft enthält keine Lösung, keine Stufe-2-Inhalte
/// und keine Zuordnung der Fassungen.
///
/// Stand: einfache, aber echte Fassung aus dem Inhalt (Gerüst G2). Gliederung,
/// Seitenzahlen (MECH 10.1: 15 / 16 / 17) und Feinheiten baut der Teil-Agent 00.
library;

import 'package:pdf/widgets.dart' as pw;

import 'besetzung.dart';
import 'kontext.dart';
import 'satz.dart';

/// Setzt Teil 00 (Erzählerheft) in [doc].
void kammerErzaehlerheft(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '00', (s) {
      final e = k.inhalt.erzaehlerheft;
      final x = k.satz;
      final b = k.besetzung;
      String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui('00', schluessel, werte);

      // Seite 1: Deckblatt.
      s.seite(wo: 'deckblatt', [
        pw.SizedBox(height: 70),
        x.titel(u('deckblatt.titel'), groesse: 32),
        pw.SizedBox(height: 10),
        x.absatz(u('deckblatt.untertitel'), groesse: 15),
        pw.SizedBox(height: 28),
        x.absatz(k.uiGemeinsam('personen', {'personen': '${k.personen}', 'rollen': '${b.rollen}'}), groesse: 12),
      ]);

      final minuten = [for (final a in e.ablauf) a.minutenBei(k.personen)];
      s.fliessend(wo: 'heft', [
        // Vorbereitung (MECH 10.5).
        x.ueberschrift(u('vorbereitung')),
        x.absatz(e.vorbereitungHinweis),
        pw.SizedBox(height: 6),
        x.tabelle(
          kopf: [u('vorbereitung.spalten.teil'), u('vorbereitung.spalten.taetigkeit'), u('vorbereitung.spalten.dauer')],
          zeilen: [
            for (final t in e.vorbereitungTaetigkeiten)
              [t.teil, t.text, t.minuten == null ? null : u('vorbereitung.minuten', {'minuten': '${t.minuten}'})],
          ],
          spalten: [1, 6, 1.3],
        ),
        x.ueberschrift(u('vorbereitung.anWen'), stufe: 2),
        x.absatz(e.vorbereitungAnWen),

        // Ablauf, Tischregeln, Rundenaufbau (MECH 1.1, 1.3, 1.4).
        pw.NewPage(),
        x.ueberschrift(u('ablauf')),
        x.tabelle(
          kopf: [u('ablauf.spalten.schritt'), u('ablauf.spalten.minuten'), u('ablauf.spalten.uhr')],
          zeilen: [
            for (var i = 0; i < e.ablauf.length; i++) [e.ablauf[i].name, '${minuten[i]}', e.ablauf[i].uhr],
          ],
          spalten: [6, 1.4, 1.8],
        ),
        pw.SizedBox(height: 4),
        x.absatz(u('ablauf.summe', {'minuten': '${minuten.fold(0, (a, m) => a + m)}'}), groesse: 10),
        x.ueberschrift(u('rundenaufbau')),
        x.tabelle(zeilen: [for (final r in e.rundenaufbau) [r.abschnitt, r.name, '${r.minuten}', r.text]], spalten: [0.5, 2.2, 0.6, 7]),
        x.ueberschrift(u('rundenaufbau.runde3'), stufe: 2),
        x.absatz(e.runde3Reihenfolge),
        if (b.gegenueberstellung) ...[x.ueberschrift(u('gegenueberstellung'), stufe: 2), x.absatz(e.gegenueberstellungRegel)],
        if (b.abschnittBKurz) ...[x.ueberschrift(u('kleineRunden'), stufe: 2), x.absatz(e.kleineRunden)],
        x.ueberschrift(k.uiGemeinsam('ueberschrift.tischregeln')),
        x.tabelle(zeilen: [for (final r in k.inhalt.gemeinsam.tischregeln) [r.nr, r.name, r.text]], spalten: [0.8, 1.8, 7], groesse: 9),

        // So läuft der Abend, Vorgeschichte (MECH 9.2, 9.3).
        pw.NewPage(),
        x.ueberschrift(u('soLaeuftDerAbend')),
        x.vorlesen(e.soLaeuftDerAbend),
        x.ueberschrift(u('vorgeschichte')),
        x.vorlesen(e.vorgeschichte),

        // Vorstellungsrunde (MECH 9.4): je besetzter Rolle die Frage.
        pw.NewPage(),
        x.ueberschrift(u('vorstellung')),
        x.anleitung(e.vorstellung.anleitung),
        pw.SizedBox(height: 6),
        x.vorlesen(e.vorstellung.start),
        for (final p in b.besetzt) ...[x.ueberschrift(p.name, stufe: 3), x.vorlesen(k.rolle(p).frage)],
        x.ueberschrift(u('vorstellung.detektiv'), stufe: 3),
        x.vorlesen(e.vorstellung.frageDetektiv),
        for (final l in e.vorstellung.lacherFehlend)
          if (!b.istBesetzt(l.schluessel)) ...[x.ueberschrift(u('vorstellung.fehlend'), stufe: 3), x.vorlesen(l.text)],
        pw.SizedBox(height: 6),
        x.vorlesen(e.vorstellung.abschluss),

        // Tat-Moment, Auftrag, Fassungen, Was alle wissen (MECH 9.5, 9.6, 1.5).
        pw.NewPage(),
        x.ueberschrift(u('tatMoment')),
        x.vorlesen(e.tatMoment),
        x.ueberschrift(u('auftrag')),
        x.vorlesen(e.auftrag),
        x.ueberschrift(u('fassungenOeffnen')),
        x.anleitung(e.fassungenOeffnen),
        x.ueberschrift(k.uiGemeinsam('ueberschrift.wasAlleWissen')),
        x.liste(k.inhalt.gemeinsam.wasAlleWissen, groesse: 10),

        // Lageplan-Führung (MECH 9.7).
        pw.NewPage(),
        x.ueberschrift(u('lageplanFuehrung')),
        for (final f in e.lageplanFuehrung)
          if (!f.nurMitStreifen || b.abwesenheitsblatt) ...[
            f.vorlesen ? x.vorlesen(f.text) : x.anleitung(f.text),
            pw.SizedBox(height: 6),
          ],

        // Runden mit Start, Impulsen und Schluss (MECH 9.8, 9.9).
        for (final r in e.runden) ...[
          pw.NewPage(),
          x.ueberschrift(k.uiGemeinsam('runde.titel', {'runde': '${r.nr}', 'name': k.text(k.fall.runden[r.nr - 1].name)})),
          x.ueberschrift(u('runde.start'), stufe: 2),
          x.vorlesen(r.start),
          x.ueberschrift(u('impulse'), stufe: 2),
          for (final i in r.impulse) ...[
            x.ueberschrift(k.uiGemeinsam('impuls', {'id': i.id, 'titel': k.text(i.titel)}), stufe: 3),
            x.absatz(i.text, groesse: 10.5),
            if (i.hinweis != null) x.absatz(i.hinweis!, groesse: 9.5, leise: true),
          ],
          if (r.schluss != null) ...[x.ueberschrift(u('runde.schluss'), stufe: 2), x.vorlesen(r.schluss!)],
          if (r.nr == 1) ...[
            x.ueberschrift(u('impulse.regeln'), stufe: 2),
            x.absatz(e.impulsRegeln, groesse: 10),
            x.ueberschrift(u('ausweichsatz'), stufe: 3),
            x.absatz(e.ausweichsatz, groesse: 10),
            x.ueberschrift(u('dominoFrage'), stufe: 3),
            x.liste([e.dominoWann, e.dominoNenntPerson, e.dominoSonst, e.dominoFehlt], groesse: 10),
          ],
          if (r.nr == 2 && b.gegenueberstellung) ...[
            x.ueberschrift(u('gegenueberstellung'), stufe: 2),
            x.absatz(e.gegenueberstellungWann, groesse: 10),
            x.vorlesen(e.gegenueberstellung),
          ],
        ],

        // Bonus-Ziel, Tipp-Runde, Anklage (MECH 9.12).
        x.ueberschrift(u('bonusZiel')),
        x.absatz(e.bonusZiel),
        x.ueberschrift(u('tippRunde')),
        x.vorlesen(e.tippRunde.vorlesen),
        pw.SizedBox(height: 4),
        x.anleitung(e.tippRunde.anleitung),
        x.ueberschrift(u('anklage')),
        x.vorlesen(e.anklage.vorlesen),
        pw.SizedBox(height: 4),
        x.anleitung(e.anklage.anleitung),

        // Herr Schneider, Maße, Licht, Taschenkontrolle (MECH 9.10, 9.11).
        pw.NewPage(),
        x.ueberschrift(u('herrSchneider')),
        x.tabelle(
          kopf: [u('herrSchneider.spalten.frage'), u('herrSchneider.spalten.antwort')],
          zeilen: [for (final f in e.herrSchneiderAntwortet) [f.frage, f.antwort]],
          spalten: [2, 5],
        ),
        x.ueberschrift(u('masstabelle')),
        x.tabelle(
          kopf: [u('masstabelle.spalten.von'), u('masstabelle.spalten.nach'), u('masstabelle.spalten.abstand'), u('masstabelle.spalten.dunkel')],
          zeilen: [for (final m in e.masstabelle) [m.von, m.nach, m.abstand, m.dunkel]],
          spalten: [2, 2, 1, 3],
        ),
        x.ueberschrift(k.uiGemeinsam('ueberschrift.licht'), stufe: 2),
        x.absatz(k.inhalt.gemeinsam.licht, groesse: 10),
        x.ueberschrift(u('taschenkontrolle'), stufe: 2),
        x.absatz(e.taschenkontrolle),

        // Skalierung (MECH 9.13) und Karten unter den Streifen (MECH 9.14).
        pw.NewPage(),
        x.ueberschrift(u('skalierung')),
        x.ueberschrift(u('skalierung.heute', {'personen': '${k.personen}'}), stufe: 2),
        if (e.skalierungsHinweis(k.personen) case final h?) x.absatz(h),
        pw.SizedBox(height: 6),
        _skalierung(k),
        if (b.abwesenheitsblatt) ...[
          x.ueberschrift(u('kartenUnterStreifen')),
          x.anleitung(e.kartenUnterStreifenAnleitung),
          pw.SizedBox(height: 6),
          for (final p in b.fehlendeZeugen)
            x.absatz(e.kartenUnterStreifenMuster, werte: {
              'name': p.name,
              'codes': k.rolle(p).geheimniskarte.pflichtCodes.join(', '),
              'runde': '${k.rolle(p).geheimniskarte.sperre}',
            }),
          pw.SizedBox(height: 6),
          for (final w in e.umschreibungen)
            if (!b.istBesetzt(w.schluessel)) x.absatz(w.text, groesse: 10),
          x.absatz(e.kartenUnterStreifenHinweis, groesse: 10, leise: true),
        ],
      ]);
    });

/// Kurztabelle der Skalierung 6 bis 20 Personen (MECH 9.13), aus [KammerBesetzung] gerechnet.
pw.Widget _skalierung(KammerKontext k) {
  String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui('00', schluessel, werte);
  final f = k.fall;
  return k.satz.tabelle(
    kopf: [
      u('skalierung.spalten.personen'),
      u('skalierung.spalten.rollen'),
      u('skalierung.spalten.neu'),
      u('skalierung.spalten.abwesenheit'),
      u('skalierung.spalten.aktionskarten'),
      u('skalierung.spalten.zusatzhefte'),
    ],
    zeilen: [
      for (var p = f.personenMin; p <= f.personenMax; p++)
        () {
          final b = KammerBesetzung.fuer(k.inhalt, personen: p);
          final neu = b.neuBesetzt;
          return [
            '$p',
            '${b.rollen}',
            neu == null ? null : (b.solo == neu ? u('skalierung.allein', {'name': neu.name}) : neu.name),
            '${b.streifen.length}',
            '${b.aktionskartenBeimDetektiv.length}',
            '${b.zusatzrollen.length}',
          ];
        }(),
    ],
    spalten: [1, 1, 3, 1.4, 1.4, 1.2],
    groesse: 9,
  );
}
