/// Teil 00: Erzählerheft (MECH 9, Kap. 14 der Fall-Bibel). Der Erzähler kennt
/// die Lösung nicht (E10): Das Heft enthält keine Lösung, keine Stufe-2-Inhalte
/// und keine Zuordnung der Fassungen; aus den Rollendateien liest es nur die
/// Vorstellungsfrage und bei fehlenden Zeugen Codes und Rundensperre ihrer
/// Geheimniskarte (MECH 9.14).
///
/// Seitenplan (MECH 9.1, A4 hoch, 16 Seiten bei jeder Besetzung): Jeder
/// Abschnitt steht auf seiner Seite, „Was alle wissen“ immer auf Seite 7
/// ([kammerErzaehlerheftSeiteWasAlleWissen], `fassungenOeffnen` nennt sie).
///
///  1 Deckblatt mit Inhaltsverzeichnis
///  2 Vorbereitung: Teileliste für heute, drucken und schneiden (MECH 10.5), was an wen geht
///  3 Ablauf mit Minuten (1.1), Aufbau jeder Runde (1.3), Runde 3, kleine Runden (bis 8 Personen)
///  4 So läuft der Abend (9.2), Vorgeschichte (9.3)
///  5–6 Vorstellungsrunde (9.4), Tat-Moment und Auftrag (9.5) ab Seite 6
///  7 Fassungen öffnen (9.6), Was alle wissen (1.5)
///  8 Lageplan-Führung (9.7)
///  9 Runde 1; 10 Impulsregeln, Ausweichsatz, Domino-Frage (9.8, 9.9)
/// 11 Runde 2, 12 Runde 3 (ab 14 Personen mit Gegenüberstellung, 1.3)
/// 13 Bonus-Ziel, Tipp-Runde, Anklage und Auflösung (9.12)
/// 14 Tischregeln ganz (1.4). MECH 9.1 nennt Seite 3; dort ist neben Ablauf
///    und Rundenaufbau kein Platz, und vor Seite 7 keine Seite frei.
/// 15 Herr Schneider, Maßtabelle, Licht, Taschenkontrolle (9.10, 9.11)
/// 16 Skalierung (9.13), bei 6 bis 11 Personen Karten unter den Streifen (9.14)
///
/// Was nicht auf seine Seiten passt, ist ein Überlauf ([KammerUeberlauf]).
/// Vorlesetexte stehen mit Balken und der Marke „Vorlesen“, Anleitungen im
/// Kasten mit der Marke „Anleitung“ (`ui/gemeinsam.json`).
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../satz_stil.dart';
import 'besetzung.dart';
import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Seite des Erzählerhefts mit „Was alle wissen“ (MECH 9.1, 9.6, 1.5).
const kammerErzaehlerheftSeiteWasAlleWissen = 7;

/// Setzt Teil 00 (Erzählerheft) in [doc].
void kammerErzaehlerheft(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '00', (s) => _Heft(k, s).setzen());

/// Ein unteilbarer Baustein einer Seite. [neueSeite]: beginnt eine neue Seite.
/// [inhalt]: Eintrag im Inhaltsverzeichnis auf dem Deckblatt. [kopf]: steht
/// davor, wenn der Baustein eine Folgeseite seiner Gruppe beginnt (wozu er
/// gehört).
class _Block {
  _Block(this.widget, {this.neueSeite = false, this.inhalt, this.kopf});
  final pw.Widget widget;
  final bool neueSeite;
  final String? inhalt;
  final pw.Widget? kopf;
}

/// Eine Seitengruppe des Seitenplans: [bloecke] auf mindestens [min] und
/// höchstens [max] Seiten; freier Platz wird mit [notizen] zu Notizlinien.
class _Gruppe {
  _Gruppe(this.wo, this.bloecke, {this.min = 1, int? max, this.notizen = false}) : max = max ?? min;
  final String wo;
  final List<_Block> bloecke;
  final int min;
  final int max;
  final bool notizen;
}

class _Heft {
  _Heft(this.k, this.s);

  final KammerKontext k;
  final KammerSeiten s;

  KammerSatz get x => k.satz;
  KammerBesetzung get b => k.besetzung;
  KammerErzaehlerheft get e => k.inhalt.erzaehlerheft;

  static const _teil = '00';
  static final _breite = KammerSatz.satzBreite();

  /// Größen: Vorlesetext, Anleitung, Fließtext, Tabelle (MECH 9, E15; nie unter 9 pt).
  static const _gVorlesen = 11.0;
  static const _gAnleitung = 10.0;
  static const _gText = 10.0;
  static const _gTabelle = 9.0;

  String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui(_teil, schluessel, werte);

  // ---------------------------------------------------------------- Bausteine

  pw.Widget _h1(String text) => x.ueberschrift(text);
  pw.Widget _h2(String text) => x.ueberschrift(text, stufe: 2);

  pw.Widget _abstand([double h = 6]) => pw.SizedBox(height: h);

  /// Vorlesetext mit Balken und Marke „Vorlesen“.
  pw.Widget _vorlesen(String text, {double groesse = _gVorlesen, Map<String, String> werte = const {}}) =>
      x.vorlesen(text, groesse: groesse, werte: werte);

  /// Anleitung im Kasten mit Marke „Anleitung“.
  pw.Widget _anleitung(String text, {double groesse = _gAnleitung, Map<String, String> werte = const {}}) =>
      x.anleitung(text, groesse: groesse, werte: werte);

  /// Anleitung im Kasten mit mehreren Teilen (Text und Vorlesetext gemischt).
  pw.Widget _anleitungKasten(List<pw.Widget> teile) => x.kasten(teile, marke: k.uiGemeinsam('anleitung'), rahmen: 0.5);

  pw.Widget _fett(String text, {double groesse = _gText}) => x.fett(text, groesse: groesse);

  /// Aufzählung „a, b oder c“ bzw. „a, b und c“ (`ui/00.json` → `liste.oder`, `liste.und`).
  String _aufzaehlen(List<String> teile, String art) => x.aufzaehlen(teile, _teil, 'liste.$art');

  // ---------------------------------------------------------------- Setzen

  void setzen() {
    final gruppen = [
      _vorbereitung(),
      _ablauf(),
      _beginn(),
      _vorstellung(),
      _wasAlleWissen(),
      _lageplan(),
      for (final r in e.runden) ..._runde(r),
      _tischregeln(),
      _nachschlagen(),
      _skalierung(),
    ];
    final platz = s.platz();
    final seiten = <(List<pw.Widget>, String, bool)>[];
    final inhalt = <(String, int)>[];
    for (final g in gruppen) {
      final verteilt = _verteilen(g, platz, seiten.length + 2);
      for (final (i, seite) in verteilt.indexed) {
        for (final bl in seite) {
          if (bl.inhalt != null) inhalt.add((bl.inhalt!, seiten.length + 2));
        }
        seiten.add(([for (final bl in seite) bl.widget], i == 0 ? g.wo : '${g.wo} ${i + 1}', g.notizen));
      }
    }
    final wasAlleWissen = inhalt.where((i) => i.$1 == k.uiGemeinsam('ueberschrift.wasAlleWissen')).single.$2;
    if (wasAlleWissen != kammerErzaehlerheftSeiteWasAlleWissen) {
      throw KammerUeberlauf.werfen(_teil, wasAlleWissen, 'was-alle-wissen', '„Was alle wissen“ stünde auf Seite $wasAlleWissen statt $kammerErzaehlerheftSeiteWasAlleWissen');
    }
    s.seite(_deckblatt(inhalt), wo: 'deckblatt');
    for (final (w, wo, notizen) in seiten) {
      s.seite(w, wo: wo, notizen: notizen, ausrichtung: pw.CrossAxisAlignment.stretch);
    }
  }

  /// Verteilt die Bausteine von [g] der Reihe nach auf höchstens [_Gruppe.max]
  /// Seiten zu [platz] pt, ab Seite [erste]. Passt ein Baustein nicht mehr auf
  /// die letzte erlaubte Seite (oder auf eine ganze Seite): [KammerUeberlauf]
  /// mit dieser Seite.
  List<List<_Block>> _verteilen(_Gruppe g, double platz, int erste) {
    final seiten = <List<_Block>>[[]];
    var hoehe = 0.0;
    for (final bl in g.bloecke) {
      final h = x.hoehe(bl.widget, _breite);
      if (seiten.last.isNotEmpty && (bl.neueSeite || hoehe + h > platz)) {
        final seite = erste + seiten.length - 1;
        if (seiten.length == g.max) KammerUeberlauf.zuHoch(_teil, seite, g.wo, hoehe + h, platz);
        seiten.add([]);
        hoehe = 0;
      }
      // Beginnt der Baustein eine Folgeseite der Gruppe, steht sein Kopf davor.
      final kopf = seiten.length > 1 && seiten.last.isEmpty ? bl.kopf : null;
      final mitKopf = h + (kopf == null ? 0 : x.hoehe(kopf, _breite));
      if (mitKopf > platz) KammerUeberlauf.zuHoch(_teil, erste + seiten.length - 1, g.wo, mitKopf, platz);
      if (kopf != null) seiten.last.add(_Block(kopf));
      seiten.last.add(bl);
      hoehe += mitKopf;
    }
    while (seiten.length < g.min) {
      seiten.add([]);
    }
    return seiten;
  }

  // ---------------------------------------------------------------- Seite 1

  List<pw.Widget> _deckblatt(List<(String, int)> inhalt) {
    // Ein Eintrag je Abschnitt; mehrere Seiten eines Abschnitts stehen als erste Seite.
    final eintraege = <(String, int)>[];
    for (final i in inhalt) {
      if (!eintraege.any((e) => e.$1 == i.$1)) eintraege.add(i);
    }
    return [
      _abstand(60),
      x.titel(u('deckblatt.titel'), groesse: 34),
      _abstand(10),
      x.absatz(u('deckblatt.untertitel'), groesse: 15),
      _abstand(24),
      x.absatz(k.uiGemeinsam('personen', {'personen': '${k.personen}', 'rollen': '${b.rollen}'}), groesse: 12),
      _abstand(2),
      x.absatz(u('deckblatt.detektiv'), groesse: 12),
      _abstand(40),
      x.marke(u('deckblatt.inhalt'), groesse: 10),
      _abstand(6),
      pw.Table(
        columnWidths: const {0: pw.FlexColumnWidth(6), 1: pw.FlexColumnWidth(1.4)},
        border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: DruckStil.linie, width: 0.4)),
        children: [
          for (final (titel, seite) in eintraege)
            pw.TableRow(children: [
              pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 3), child: x.absatz(titel, groesse: 11)),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                child: x.absatz(u('inhalt.seite', {'seite': '$seite'}), groesse: 11, ausrichtung: pw.TextAlign.right),
              ),
            ]),
        ],
      ),
    ];
  }

  // ---------------------------------------------------------------- Seite 2

  _Gruppe _vorbereitung() {
    final teile = <String, String>{
      '00': u('teileliste.00'),
      '01': u('teileliste.01'),
      '02': [
        u('teileliste.02', {'marker': '${b.marker.length}', 'zettel': '${b.tippZettel}'}),
        if (b.abwesenheitsblatt) u('teileliste.02.streifen', {'streifen': '${b.streifen.length}'}),
      ].join('\n'),
      '10': u('teileliste.10', {'anzahl': '${b.hauptrollen.length}', 'namen': [for (final p in b.hauptrollen) p.name].join(', ')}),
      '11': u('teileliste.11', {'anzahl': '${b.verdaechtige.length}', 'namen': _aufzaehlen([for (final p in b.verdaechtige) p.name], 'und')}),
      '12': b.zusatzrollen.isEmpty
          ? u('teileliste.12.keine')
          : u('teileliste.12', {'anzahl': '${b.zusatzrollen.length}', 'namen': [for (final p in b.zusatzrollen) p.name].join(', ')}),
      '20': [
        u('teileliste.20', {
          'indiz': '${k.inhalt.indizkarten.karten.length}',
          'geheim': '${b.geheimniskarten.length}',
          'aktion': '${b.aktionskarten.length}',
        }),
        if (b.aktionskartenBeimDetektiv.isNotEmpty) u('teileliste.20.detektiv', {'anzahl': '${b.aktionskartenBeimDetektiv.length}'}),
      ].join('\n'),
      '90': u('teileliste.90'),
    };
    String teilName(String t) => t == 'alle' ? u('vorbereitung.alle') : t;
    return _Gruppe('vorbereitung', [
      _Block(x.spalte([
        _h1(u('vorbereitung')),
        _anleitung(e.vorbereitungHinweis),
      ]), inhalt: u('vorbereitung')),
      _Block(x.spalte([
        _h2(u('vorbereitung.teileliste')),
        x.tabelle(
          kopf: [u('vorbereitung.spalten.teil'), u('vorbereitung.spalten.datei'), u('vorbereitung.spalten.stueck')],
          zeilen: [
            for (final t in kammerTeile) ['$t ${k.teilTitel(t)}', k.ui(t, 'datei'), teile[t]],
          ],
          spalten: [2.2, 2.9, 4.8],
          groesse: _gTabelle,
        ),
      ])),
      _Block(x.spalte([
        _h2(u('vorbereitung.schneiden')),
        x.tabelle(
          kopf: [u('vorbereitung.spalten.teil'), u('vorbereitung.spalten.taetigkeit'), u('vorbereitung.spalten.dauer')],
          zeilen: [
            for (final t in e.vorbereitungTaetigkeiten)
              [teilName(t.teil), t.text, t.minuten == null ? null : u('vorbereitung.minuten', {'minuten': '${t.minuten}'})],
          ],
          spalten: [0.9, 7, 1.1],
          groesse: _gTabelle,
        ),
      ])),
      _Block(x.spalte([
        _h2(u('vorbereitung.anWen')),
        x.absatz(e.vorbereitungAnWen, groesse: _gText),
      ])),
    ]);
  }

  // ---------------------------------------------------------------- Seite 3

  _Gruppe _ablauf() {
    final minuten = [for (final a in e.ablauf) a.minutenBei(k.personen)];
    final summe = minuten.fold(0, (a, m) => a + m);
    pw.Widget rechts(String t) => x.absatz(t, groesse: _gTabelle, ausrichtung: pw.TextAlign.right);
    return _Gruppe('ablauf', [
      _Block(x.spalte([
        _h1(u('ablauf')),
        x.tabelle(
          kopf: [u('ablauf.spalten.nr'), u('ablauf.spalten.schritt'), u('ablauf.spalten.minuten'), u('ablauf.spalten.uhr')],
          zeilen: [
            for (var i = 0; i < e.ablauf.length; i++)
              [rechts('${e.ablauf[i].schritt}'), e.ablauf[i].name, rechts('${minuten[i]}'), e.ablauf[i].uhr],
            [null, _fett(u('ablauf.summe'), groesse: _gTabelle), x.absatz('**$summe**', groesse: _gTabelle, ausrichtung: pw.TextAlign.right), null],
          ],
          spalten: [0.5, 6.2, 1.1, 1.8],
          groesse: _gTabelle,
          innen: const pw.EdgeInsets.fromLTRB(4, 2, 4, 2),
        ),
      ]), inhalt: u('ablauf')),
      _Block(x.spalte([
        _h1(u('rundenaufbau')),
        x.tabelle(
          zeilen: [
            for (final r in e.rundenaufbau)
              [_fett('${r.abschnitt}  ${k.klartext(r.name)}', groesse: _gTabelle), rechts(u('rundenaufbau.minuten', {'minuten': '${r.minuten}'})), r.text],
          ],
          spalten: [2.1, 0.8, 7.4],
          groesse: _gTabelle,
          innen: const pw.EdgeInsets.fromLTRB(4, 2.5, 4, 2.5),
        ),
      ])),
      _Block(x.spalte([
        _h2(u('rundenaufbau.runde3')),
        x.absatz(e.runde3Reihenfolge, groesse: _gText),
      ])),
      if (b.abschnittBKurz)
        _Block(x.spalte([
          _h2(u('kleineRunden')),
          x.absatz(e.kleineRunden, groesse: _gText),
        ])),
    ]);
  }

  // ---------------------------------------------------------------- Seite 4

  _Gruppe _beginn() => _Gruppe('beginn', [
        _Block(x.spalte([
          _h1(u('soLaeuftDerAbend')),
          _vorlesen(e.soLaeuftDerAbend),
        ]), inhalt: u('soLaeuftDerAbend')),
        _Block(x.spalte([
          _h1(u('vorgeschichte')),
          _vorlesen(e.vorgeschichte),
        ]), inhalt: u('vorgeschichte')),
      ]);

  // ---------------------------------------------------------------- Seiten 5 und 6

  /// Breite der Spalte „wer“ in der Vorstellungsrunde.
  static const _wer = 120.0;

  /// Eine Zeile der Vorstellungsrunde: links wer, rechts der Vorlesetext mit Balken.
  pw.Widget _frage(String wer, String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 4),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.SizedBox(width: _wer, child: pw.Padding(padding: const pw.EdgeInsets.only(top: 1.5, right: 8), child: _fett(wer, groesse: 9.5))),
          pw.Expanded(child: x.balken(x.absatz(text, groesse: 10.5))),
        ]),
      );

  _Gruppe _vorstellung() {
    final v = e.vorstellung;
    final fehlend = [for (final l in v.lacherFehlend) if (!b.istBesetzt(l.schluessel)) l];
    final kopf = x.spalte([
      _h1(u('vorstellung')),
      _anleitung(v.anleitung),
      _abstand(8),
      _vorlesen(v.start),
      _abstand(4),
    ]);
    final rollen = [
      for (final p in b.besetzt) _frage(u('vorstellung.rolle', {'name': p.name, 'titel': k.text(p.bezeichnung)}), k.rolle(p).frage),
      _frage(u('vorstellung.detektiv'), v.frageDetektiv),
    ];
    // Eine Marke bleibt mit dem ersten Text darunter zusammen (nie allein am Seitenende).
    pw.Widget mitMarke(String marke, pw.Widget erstes) => x.spalte([
          pw.Padding(padding: const pw.EdgeInsets.only(top: 10, bottom: 1), child: x.marke(marke)),
          erstes,
        ]);
    final danach = [
      if (fehlend.isNotEmpty) ...[
        mitMarke(u('vorstellung.fehlend'), _frage('', fehlend.first.text)),
        for (final l in fehlend.skip(1)) _frage('', l.text),
      ],
      if (b.rollen < k.fall.plaetze.length) mitMarke(u('vorstellung.abschluss'), _frage('', v.abschluss)),
    ];
    // Auf Seite 6 steht über der Fortsetzung, wozu sie gehört (wie in Teil 90).
    final weiter = pw.Padding(padding: const pw.EdgeInsets.only(bottom: 2), child: x.marke(u('vorstellung.weiter')));
    final tat = x.spalte([
      _h1(u('tatMoment')),
      _vorlesen(e.tatMoment, groesse: 10.5),
      _h1(u('auftrag')),
      _vorlesen(e.auftrag),
    ]);
    // Die Vorstellungsrunde beginnt auf Seite 5; passt sie ganz darauf, beginnt der Tat-Moment Seite 6.
    final vorstellung = [
      _Block(kopf, inhalt: u('vorstellung')),
      for (final (i, r) in rollen.indexed)
        i > 0
            ? _Block(r, kopf: weiter)
            : _Block(x.spalte([
                pw.Padding(padding: const pw.EdgeInsets.only(left: _wer), child: x.marke(k.uiGemeinsam('vorlesen'))),
                r,
              ])),
      for (final d in danach) _Block(d, kopf: weiter),
    ];
    final hoehe = vorstellung.fold(0.0, (h, bl) => h + x.hoehe(bl.widget, _breite));
    return _Gruppe('vorstellung', [
      ...vorstellung,
      _Block(tat, neueSeite: hoehe <= s.platz(), inhalt: u('tatMoment')),
    ], min: 2);
  }

  // ---------------------------------------------------------------- Seite 7

  _Gruppe _wasAlleWissen() => _Gruppe('was-alle-wissen', [
        _Block(x.spalte([
          _h1(u('fassungenOeffnen')),
          _anleitung(e.fassungenOeffnen, werte: {'seite': '$kammerErzaehlerheftSeiteWasAlleWissen'}),
        ]), inhalt: u('fassungenOeffnen')),
        _Block(x.spalte([
          _h1(k.uiGemeinsam('ueberschrift.wasAlleWissen')),
          x.liste(k.inhalt.gemeinsam.wasAlleWissen, groesse: 10.5, abstand: 4),
        ]), inhalt: k.uiGemeinsam('ueberschrift.wasAlleWissen')),
      ], notizen: true);

  // ---------------------------------------------------------------- Seite 8

  _Gruppe _lageplan() => _Gruppe('lageplan', [
        _Block(_h1(u('lageplanFuehrung')), inhalt: u('lageplanFuehrung')),
        for (final f in e.lageplanFuehrung)
          if (!f.nurMitStreifen || b.abwesenheitsblatt)
            _Block(pw.Padding(padding: const pw.EdgeInsets.only(bottom: 7), child: f.vorlesen ? _vorlesen(f.text) : _anleitung(f.text))),
      ], notizen: true);

  // ---------------------------------------------------------------- Seiten 9 bis 14

  pw.Widget _impuls(KammerImpuls i) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: x.spalte([
          x.ueberschrift(k.uiGemeinsam('impuls', {'id': i.id, 'titel': k.text(i.titel)}), stufe: 3),
          x.balken(x.absatz(i.text, groesse: 10.5)),
          if (i.hinweis != null && !k.leer(i.hinweis!))
            pw.Padding(padding: const pw.EdgeInsets.only(top: 3, left: 10.5), child: x.absatz(i.hinweis!, groesse: 9.5, leise: true)),
        ]),
      );

  /// Gegenüberstellung (MECH 1.3, 9.9): in Runde 2 mit der Regel, in Runde 3 nur wann.
  pw.Widget _gegenueberstellung(int runde) => x.spalte([
        _h2(u('gegenueberstellung')),
        _anleitungKasten([
          // In Runde 2 die ganze Regel (MECH 1.3, nennt auch wann), in Runde 3 nur wann (MECH 9.9).
          x.absatz(runde == 2 ? e.gegenueberstellungRegel : e.gegenueberstellungWann, groesse: _gAnleitung),
        ]),
        _abstand(4),
        _vorlesen(e.gegenueberstellung, groesse: 10.5),
      ]);

  List<_Gruppe> _runde(KammerRundeTexte r) {
    final runde = k.fall.runden.firstWhere((f) => f.nr == r.nr);
    final titel = k.uiGemeinsam('runde.titel', {'runde': '${r.nr}', 'name': k.text(runde.name)});
    final bloecke = [
      _Block(x.spalte([
        _h1(titel),
        x.absatz(u('runde.uhr', {'uhr': runde.uhr}), groesse: 9.5, leise: true),
        _h2(u('runde.start')),
        _vorlesen(r.start),
      ]), inhalt: titel),
      if (r.nr > 1 && b.gegenueberstellung) _Block(_gegenueberstellung(r.nr)),
      _Block(x.spalte([
        _h2(u('impulse')),
        x.marke(k.uiGemeinsam('vorlesen')),
        _abstand(1),
      ])),
      for (final i in r.impulse) _Block(_impuls(i)),
      if (r.schluss != null)
        _Block(x.spalte([
          _h2(u('runde.schluss')),
          _vorlesen(r.schluss!),
        ]))
      else
        _Block(pw.Padding(padding: const pw.EdgeInsets.only(top: 6), child: _anleitung(u('runde.keinSchluss')))),
    ];
    return [
      if (r.nr == 1) ...[
        _Gruppe('runde-1', bloecke, notizen: true, max: 2),
        _Gruppe('impulse', _moderation(), notizen: true),
      ] else if (r.nr == 3) ...[
        _Gruppe('runde-3', bloecke, notizen: true, max: 2),
        _Gruppe('tipp-runde', _schluss(), notizen: true),
      ] else
        _Gruppe('runde-${r.nr}', bloecke, notizen: true, max: 2),
    ];
  }

  /// Regeln für die Impulse, Ausweichsatz, Domino-Frage (MECH 9.9): gelten in allen Runden.
  List<_Block> _moderation() => [
        _Block(x.spalte([
          _h1(u('impulse.regeln')),
          _anleitung(e.impulsRegeln),
        ]), inhalt: u('impulse.regeln')),
        _Block(x.spalte([
          _h2(u('ausweichsatz')),
          _vorlesen(e.ausweichsatz),
        ])),
        _Block(x.spalte([
          _h2(u('dominoFrage')),
          _anleitungKasten([
            x.absatz(e.dominoWann, groesse: _gAnleitung),
            _abstand(5),
            x.absatz(u('dominoFrage.nenntPerson'), groesse: _gAnleitung),
            _abstand(3),
            x.vorlesen(e.dominoNenntPerson, groesse: 10.5),
            _abstand(5),
            x.absatz(e.dominoSonst, groesse: _gAnleitung),
            _abstand(4),
            x.absatz(e.dominoFehlt, groesse: _gAnleitung),
          ]),
        ])),
      ];

  /// Bonus-Ziel, Tipp-Runde, Anklage (MECH 9.12).
  List<_Block> _schluss() {
    final karten = (b.rollen * 3 / 4).ceil();
    // Zwei Listen nebeneinander, damit auch 18 Rollen kurz bleiben.
    final jeSpalte = (b.rollen / 2).ceil();
    pw.Widget liste(List<KammerPlatz> plaetze) => x.tabelle(
          kopf: [u('bonusZiel.rolle'), u('bonusZiel.vorTipp'), u('bonusZiel.anklage')],
          zeilen: [for (final p in plaetze) [p.name, pw.Align(alignment: pw.Alignment.centerLeft, child: x.kaestchen()), pw.Align(alignment: pw.Alignment.centerLeft, child: x.kaestchen())]],
          spalten: [2, 1.6, 1.6],
          groesse: _gTabelle,
          innen: const pw.EdgeInsets.fromLTRB(4, 2.5, 4, 2.5),
        );
    return [
      _Block(x.spalte([
        _h1(u('bonusZiel')),
        x.kasten([x.absatz(e.bonusZiel, groesse: _gText)], grau: true, rahmen: 0.5),
        _abstand(6),
        x.absatz(u('bonusZiel.heute', {'rollen': '${b.rollen}', 'karten': '$karten'}), groesse: _gText),
        _abstand(4),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) pw.SizedBox(width: 12),
            pw.Expanded(child: liste(b.besetzt.skip(i * jeSpalte).take(jeSpalte).toList())),
          ],
        ]),
      ]), inhalt: u('bonusZiel')),
      _Block(x.spalte([
        _h1(u('tippRunde')),
        _vorlesen(e.tippRunde.vorlesen),
        _abstand(5),
        _anleitung(e.tippRunde.anleitung),
      ]), inhalt: u('tippRunde')),
      _Block(x.spalte([
        _h1(u('anklage')),
        _vorlesen(e.anklage.vorlesen),
        _abstand(5),
        _anleitung(e.anklage.anleitung),
      ]), inhalt: u('anklage')),
    ];
  }

  // ---------------------------------------------------------------- Tischregeln

  /// Tischregeln ganz (MECH 1.4) auf einer Seite: so groß wie möglich, nie unter 9 pt.
  _Gruppe _tischregeln() {
    final titel = k.uiGemeinsam('ueberschrift.tischregeln');
    final regeln = k.inhalt.gemeinsam.tischregeln;
    pw.Widget regel(KammerRegel r, double g) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.SizedBox(width: 30, child: x.absatz(r.nr, groesse: _gTabelle, leise: true)),
            pw.Expanded(child: x.absatz('**${k.klartext(r.name)}.** ${k.text(r.text)}', groesse: g)),
          ]),
        );
    final g = s.passendeGroesse(
      (g) => pw.Column(children: [_h1(titel), for (final r in regeln) regel(r, g)]),
      breite: _breite,
      hoehe: s.platz(),
      start: 9.5,
      min: KammerSatz.kleinsteGroesse,
      wo: 'tischregeln',
    );
    return _Gruppe('tischregeln', [
      _Block(_h1(titel), inhalt: titel),
      for (final r in regeln) _Block(regel(r, g)),
    ]);
  }

  // ---------------------------------------------------------------- Seite 15

  /// Herr Schneider, Maßtabelle, Licht, Taschenkontrolle (MECH 9.10, 9.11, 9.1 Seite 15).
  _Gruppe _nachschlagen() {
    final hs = u('herrSchneider');
    final mass = u('masstabelle');
    const innen = pw.EdgeInsets.fromLTRB(4, 2, 4, 2);
    return _Gruppe('nachschlagen', [
      _Block(x.spalte([
        _h2(hs),
        x.tabelle(
          kopf: [u('herrSchneider.spalten.frage'), u('herrSchneider.spalten.antwort')],
          zeilen: [for (final f in e.herrSchneiderAntwortet) [f.frage, f.antwort]],
          spalten: [2.15, 5],
          groesse: _gTabelle,
          innen: innen,
        ),
      ]), inhalt: hs),
      _Block(x.spalte([
        _h2(mass),
        x.tabelle(
          kopf: [u('masstabelle.spalten.vonNach'), u('masstabelle.spalten.abstand'), u('masstabelle.spalten.dunkel')],
          zeilen: [
            for (final m in e.masstabelle) [u('masstabelle.vonNach', {'von': k.text(m.von), 'nach': k.text(m.nach)}), m.abstand, m.dunkel],
          ],
          spalten: [3.7, 2.3, 4.1],
          groesse: _gTabelle,
          innen: innen,
        ),
      ]), inhalt: mass),
      _Block(x.spalte([
        _h2(k.uiGemeinsam('ueberschrift.licht')),
        x.absatz(k.inhalt.gemeinsam.licht, groesse: _gTabelle),
      ])),
      // Der Text beginnt selbst mit „Taschenkontrolle:“ (MECH 9.1 wörtlich).
      _Block(pw.Padding(padding: const pw.EdgeInsets.only(top: 8), child: x.absatz(e.taschenkontrolle, groesse: _gTabelle)), inhalt: u('taschenkontrolle')),
    ]);
  }

  // ---------------------------------------------------------------- Seite 16

  /// Skalierung (MECH 9.13) und bei 6 bis 11 Personen „Karten unter den Streifen“ (MECH 9.14).
  _Gruppe _skalierung() {
    final hinweis = e.skalierungsHinweis(k.personen);
    final titel = u('skalierung');
    final karten = u('kartenUnterStreifen');
    return _Gruppe('skalierung', [
      _Block(x.spalte([
        _h1(titel),
        _h2(u('skalierung.heute', {'personen': '${k.personen}'})),
        _anleitung(hinweis == null || k.leer(hinweis) ? u('skalierung.keinHinweis') : hinweis, groesse: 9.5),
        _abstand(7),
        x.marke(u('skalierung.ueberblick')),
        _abstand(3),
        _ueberblick(),
      ]), inhalt: titel),
      if (b.abwesenheitsblatt)
        _Block(x.spalte([
          _h1(karten),
          _anleitung(e.kartenUnterStreifenAnleitung, groesse: 9.5),
          _abstand(5),
          x.tabelle(
            kopf: [u('kartenUnterStreifen.spalten.karte'), u('kartenUnterStreifen.spalten.umschreibung')],
            zeilen: [
              for (final p in b.fehlendeZeugen)
                [
                  x.absatz(e.kartenUnterStreifenMuster, groesse: _gTabelle, werte: {
                    'name': p.name,
                    'codes': _aufzaehlen(k.rolle(p).geheimniskarte.pflichtCodes, 'oder'),
                    'runde': '${k.rolle(p).geheimniskarte.sperre}',
                  }),
                  [for (final w in e.umschreibungen) if (w.schluessel == p.id) w.text].join('\n'),
                ],
            ],
            spalten: [5.6, 3.6],
            groesse: _gTabelle,
            innen: const pw.EdgeInsets.fromLTRB(4, 2.5, 4, 2.5),
          ),
          _abstand(4),
          x.absatz(e.kartenUnterStreifenHinweis, groesse: _gTabelle, leise: true),
        ]), inhalt: karten),
    ], notizen: true);
  }

  /// Zeile der Kurztabelle (MECH 9.13) für [b]: Personen, Rollen, neu besetzt,
  /// Streifen, Aktionskarten beim Detektiv, Zusatzhefte.
  List<String> _skalierungsZeile(KammerBesetzung b) {
    final neu = b.neuBesetzt;
    final keine = u('skalierung.keine');
    return [
      '${b.personen}',
      '${b.rollen}',
      if (neu == null)
        [for (final p in b.verdaechtige) p.name].join(', ')
      else
        b.solo == neu ? u('skalierung.allein', {'name': neu.name}) : u('skalierung.plus', {'name': neu.name}),
      b.streifen.isEmpty ? keine : '${b.streifen.length}',
      b.aktionskartenBeimDetektiv.isEmpty ? keine : '${b.aktionskartenBeimDetektiv.length}',
      b.zusatzrollen.isEmpty ? keine : '${b.zusatzrollen.length}',
    ];
  }

  /// Kurztabelle 6 bis 20 Personen; die Zeile von heute ist grau und fett.
  pw.Widget _ueberblick() {
    final f = k.fall;
    pw.Widget zelle(String t, {bool fett = false}) =>
        pw.Padding(padding: const pw.EdgeInsets.fromLTRB(4, 1.2, 4, 1.2), child: fett ? _fett(t, groesse: _gTabelle) : x.absatz(t, groesse: _gTabelle));
    return pw.Table(
      border: pw.TableBorder.all(color: DruckStil.linie, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.1),
        1: pw.FlexColumnWidth(0.9),
        2: pw.FlexColumnWidth(3.6),
        3: pw.FlexColumnWidth(1.1),
        4: pw.FlexColumnWidth(1.3),
        5: pw.FlexColumnWidth(1.3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            for (final sp in ['personen', 'rollen', 'neu', 'abwesenheit', 'aktionskarten', 'zusatzhefte']) zelle(u('skalierung.spalten.$sp'), fett: true),
          ],
        ),
        for (var p = f.personenMin; p <= f.personenMax; p++)
          pw.TableRow(
            decoration: p == k.personen ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
            children: [for (final w in _skalierungsZeile(KammerBesetzung.fuer(k.inhalt, personen: p))) zelle(w, fett: p == k.personen)],
          ),
      ],
    );
  }
}
