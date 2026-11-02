/// Teil 10 (Rollenhefte der besetzten Rollen 1–10) und Teil 12 (Zusatzhefte
/// der besetzten Rollen 11–18), dazu das Heft einer Rolle für die Einzeldatei
/// (MECH 10.1, 10.3, 10.4; RK 1, ZG 0.6, ZR 0.7).
///
/// Stand: einfache, aber echte Fassung aus dem Inhalt (Gerüst G2): jedes Heft
/// mit eigener Seitenzählung, alle Abschnitte in Bibel-Reihenfolge. Die feste
/// Gestalt (vier Seiten je Rollenheft, drei je Zusatzheft, gleiche Gestalt der
/// vier Verdächtigen, E9) baut der Teil-Agent 10/12.
library;

import 'package:pdf/widgets.dart' as pw;

import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Setzt Teil 10: die Rollenhefte der besetzten Plätze 1–10 in Platzreihenfolge.
void kammerRollenhefte(pw.Document doc, KammerKontext k) {
  for (final p in k.besetzung.hauptrollen) {
    kammerRollenheft(doc, k, p);
  }
}

/// Setzt Teil 12: die Zusatzhefte der besetzten Plätze 11–18; ohne Zusatzrollen
/// (6 bis 12 Personen) eine Hinweisseite (MECH 10.1, `ui/12.json` → `hinweisseite`).
void kammerZusatzhefte(pw.Document doc, KammerKontext k) {
  final rollen = k.besetzung.zusatzrollen;
  if (rollen.isEmpty) {
    kammerTeilSetzen(doc, k, '12', (s) => s.seite(wo: 'hinweisseite', [k.satz.ueberschrift(k.teilTitel('12')), k.satz.absatz(k.ui('12', 'hinweisseite'))]));
    return;
  }
  for (final p in rollen) {
    kammerZusatzheft(doc, k, p);
  }
}

/// Das Rollenheft von [p] (Platz 1–10) mit eigener Seitenzählung.
void kammerRollenheft(pw.Document doc, KammerKontext k, KammerPlatz p) {
  if (p.art == KammerArt.zusatz) throw ArgumentError.value(p.id, 'p', 'Zusatzrolle: kammerZusatzheft');
  kammerTeilSetzen(doc, k, '10', (s) => s.fliessend(_heft(k, p, '10'), wo: p.name), bereich: p.name);
}

/// Das Zusatzheft von [p] (Platz 11–18) mit eigener Seitenzählung.
void kammerZusatzheft(pw.Document doc, KammerKontext k, KammerPlatz p) {
  if (p.art != KammerArt.zusatz) throw ArgumentError.value(p.id, 'p', 'Hauptrolle: kammerRollenheft');
  kammerTeilSetzen(doc, k, '12', (s) => s.fliessend(_heft(k, p, '12'), wo: p.name), bereich: p.name);
}

List<pw.Widget> _heft(KammerKontext k, KammerPlatz p, String teil) {
  final x = k.satz;
  final r = k.rolle(p);
  final b = k.besetzung;
  String g(String schluessel, [Map<String, String> werte = const {}]) => k.uiGemeinsam(schluessel, werte);
  String feld(String id) => k.fall.feld(id).name;
  final impulse = {for (final i in k.inhalt.erzaehlerheft.impulse) i.id: i};
  final kopf = teil == '10'
      ? k.ui('10', 'kopf', {'name': p.name, 'platz': '${p.platz}'})
      : k.ui('12', 'kopf', {'name': p.name, 'platz': '${p.platz}', 'tandem': '${p.tandem}'});
  final st1 = r.stufe1;
  final st2 = r.stufe2;
  final gk = r.geheimniskarte;
  final ak = r.aktionskarte;
  return [
    x.titel(kopf, groesse: 18),
    pw.SizedBox(height: 4),
    x.absatz(g('besetzungshinweis', {'name': p.name}), groesse: 9, leise: true),

    // Seite 1: Auftritt, Wer du bist, Was alle wissen.
    x.ueberschrift(g('heft.deinAuftritt')),
    x.absatz(r.auftritt),
    x.ueberschrift(g('heft.werDuBist')),
    x.absatz(r.werDuBist),
    if (r.haltung case final h?) ...[pw.SizedBox(height: 4), x.absatz(h)],
    if (r.tandemKasten case final t?) ...[pw.SizedBox(height: 6), x.kasten([x.absatz(t, groesse: 10)], marke: k.ui('12', 'deinTandem'))],
    if (r.solo case final solo? when b.solo == p) ...[pw.SizedBox(height: 6), x.kasten([x.absatz(solo, groesse: 10)])],
    x.ueberschrift(g('ueberschrift.wasAlleWissen')),
    x.liste(k.inhalt.gemeinsam.wasAlleWissen, groesse: 9.5),
    x.ueberschrift(g('ueberschrift.soSpieltIhr'), stufe: 2),
    x.kasten([x.absatz(k.inhalt.gemeinsam.soSpieltIhr, groesse: 9.5)]),

    // Seite 2: Marker, Wissen, Stufe 1, Erzähler-Fragen, Stufe 2.
    x.ueberschrift(g('heft.deineMarker')),
    x.absatz(r.marker.zeile, groesse: 10),
    pw.SizedBox(height: 4),
    x.tabelle(zeilen: [
      [g('zeitpunkt.z2357'), feld(r.marker.behauptet2357)],
      [g('zeitpunkt.scheppern'), feld(r.marker.behauptetScheppern)],
    ], spalten: [1, 4], groesse: 10),
    if (r.wasDuWeisst case final w?) ...[
      x.ueberschrift(g('heft.wasDuWeisst')),
      x.tabelle(
        zeilen: [
          for (final z in w.zeilen)
            [
              z.zeit,
              z.text,
              z.zusatz ??
                  switch (z.frei) {
                    KammerFrei.offen => null,
                    KammerFrei.karte => g('heft.frei.karte'),
                    KammerFrei.runde3 => g('heft.frei.runde3'),
                  },
            ],
        ],
        spalten: [1.2, 6, 1.8],
      ),
    ],
    if (r.notiz case final n?) ...[pw.SizedBox(height: 6), x.kasten([x.liste(n.zeilen, nummer: KammerNummer.keine, groesse: 9, abstand: 1), pw.SizedBox(height: 4), x.absatz(n.hinweis, groesse: 9, leise: true)])],
    x.ueberschrift(g('heft.stufe1')),
    if (st1.kernsaetze.isNotEmpty) ...[x.ueberschrift(k.ui('10', 'kernsaetze'), stufe: 3), x.liste(st1.kernsaetze, groesse: 10)],
    if (st1.regie case final regie?) ...[x.ueberschrift(k.ui('10', 'regie'), stufe: 3), x.absatz(regie, groesse: 10)],
    if (st1.sagstDuJedem.isNotEmpty) ...[x.ueberschrift(g('heft.sagstDuJedem'), stufe: 3), x.liste(st1.sagstDuJedem, groesse: 10)],
    if (st1.ausweichsaetze.isNotEmpty) ...[
      pw.SizedBox(height: 4),
      x.tabelle(kopf: [g('heft.wennJemandFragt'), g('heft.sagstDu')], zeilen: [for (final a in st1.ausweichsaetze) [a.frage, a.antwort]], spalten: [2, 3]),
    ],
    if (st1.verboten.isNotEmpty) ...[x.ueberschrift(g('heft.verboten'), stufe: 3), x.liste(st1.verboten, groesse: 10)],
    if (st1.markersatz case final m?) ...[pw.SizedBox(height: 4), x.absatz(m, groesse: 10)],
    x.ueberschrift(g('heft.wennDerErzaehlerFragt'), stufe: 2),
    x.tabelle(
      zeilen: [
        for (final a in r.wennDerErzaehlerFragt)
          [impulse[a.impuls] == null ? a.impuls : g('impuls', {'id': a.impuls, 'titel': k.text(impulse[a.impuls]!.titel)}), a.antwort],
      ],
      spalten: [2, 4],
      groesse: 9,
    ),
    x.ueberschrift(g('heft.stufe2')),
    if (gk.sperre > 1) x.absatz(g('heft.rundensperre', {'runde': '${gk.sperre}'}), groesse: 10),
    if (st2.wasDuVerbirgst case final v?) ...[x.ueberschrift(k.ui('10', 'wasDuVerbirgst'), stufe: 3), x.absatz(v, groesse: 10)],
    if (p.art == KammerArt.verdaechtig) x.absatz(k.ui('10', 'ausloeser.kopf'), groesse: 10),
    x.liste(st2.ausloeser, nummer: p.art == KammerArt.verdaechtig ? KammerNummer.buchstabe : KammerNummer.zahl, groesse: 10),
    if (p.art == KammerArt.verdaechtig) x.absatz(k.ui('10', 'ausloeser.fuss'), groesse: 10),
    if (st2.wasDuDannSagst case final w?) ...[x.ueberschrift(k.ui('10', 'wasDuDannSagst'), stufe: 3), x.absatz(w, groesse: 10)],
    x.ueberschrift(g('heft.wasDuDannZugibst'), stufe: 3),
    x.absatz(gk.wasIchZugebe, groesse: 10),
    if (st2.marker case final m?) ...[x.ueberschrift(k.ui('10', 'marker'), stufe: 3), x.absatz(m, groesse: 10)],
    if (st2.abDann case final a?) ...[x.ueberschrift(k.ui('10', 'abDann'), stufe: 3), x.absatz(a, groesse: 10)],
    if (st2.nachDemUmdrehen.isNotEmpty || st2.nachDemUmdrehenEinleitung != null) ...[
      x.ueberschrift(g('heft.nachDemUmdrehen'), stufe: 3),
      if (st2.nachDemUmdrehenEinleitung case final e?) x.absatz(e, groesse: 10),
      x.liste(st2.nachDemUmdrehen, groesse: 10),
    ],
    if (r.freigabe case final f?) ...[
      x.ueberschrift(k.ui('10', 'freigabe'), stufe: 2),
      x.absatz(k.ui('10', 'freigabe.kopf'), groesse: 9.5),
      pw.SizedBox(height: 4),
      x.tabelle(
        kopf: [k.ui('10', 'freigabe.sofort'), k.ui('10', 'freigabe.marker'), k.ui('10', 'freigabe.karte')],
        zeilen: [
          [x.liste(f.sofort, groesse: 9), x.liste(f.nachDemMarker, groesse: 9), x.liste(f.nachDerKarte, groesse: 9)],
        ],
      ),
    ],

    // Seite 3: Gesprächsaufträge je Runde (Ausweichziel, wenn das Ziel fehlt).
    x.ueberschrift(teil == '10' ? g('heft.nachbohrZiele') : k.ui('12', 'gespraechsauftraege')),
    for (final runde in k.fall.runden) ...[
      x.ueberschrift(k.uiGemeinsam('runde.titel', {'runde': '${runde.nr}', 'name': k.text(runde.name)}), stufe: 3),
      for (final a in r.gespraechsauftraege.where((a) => a.runde == runde.nr))
        if (b.istBesetzt(a.ziel)) ...[
          x.absatz('**${g('heft.ziel', {'nr': '${a.nr}'})}: ${k.inhalt.platzVon(a.ziel).name}**', groesse: 10),
          x.absatz(a.frage, groesse: 10),
          if (a.nachschlag case final n?) x.absatz('*${g('heft.nachschlag')}:* $n', groesse: 9.5),
          pw.SizedBox(height: 4),
        ] else ...[
          x.absatz('**${g('heft.ziel', {'nr': '${a.nr}'})}**', groesse: 10),
          x.absatz(a.ausweich ?? k.ui('12', 'ausweichRegel'), groesse: 10),
          pw.SizedBox(height: 4),
        ],
    ],

    // Seite 4: Was du bei dir trägst, Aktionskarte, Bonus-Ziel, Fassung, Notizen.
    x.ueberschrift(g('heft.wasDuBeiDirTraegst')),
    x.absatz(r.wasDuBeiDirTraegst.text, groesse: 10),
    if (r.wasDuBeiDirTraegst.hinweis case final h?) x.absatz(h, groesse: 9, leise: true),
    x.ueberschrift(g('heft.deineAktionskarte')),
    x.kasten(marke: k.klartext(ak.name), [
      x.absatz(ak.wirkung, groesse: 10),
      pw.SizedBox(height: 3),
      x.absatz(ak.grenzen, groesse: 9.5, leise: true),
      pw.SizedBox(height: 3),
      x.absatz('**${g('heft.tipp')}:** ${ak.tipp}', groesse: 9.5),
    ]),
    x.ueberschrift(g('heft.deinBonusZiel')),
    x.absatz(r.bonusZiel.text, groesse: 10),
    if (r.bonusZiel.hinweis case final h?) x.absatz(h, groesse: 9, leise: true),
    if (r.fassung case final f?) ...[
      x.ueberschrift(k.ui('10', 'fassung')),
      x.absatz(k.ui('10', 'fassung.text', {'code': f.code}), groesse: 10),
    ] else ...[
      pw.SizedBox(height: 8),
      x.absatz(g('heft.angeklagt'), groesse: 10),
    ],
    pw.SizedBox(height: 10),
    x.marke(g('notizen')),
    x.notizlinien(6),
  ];
}
