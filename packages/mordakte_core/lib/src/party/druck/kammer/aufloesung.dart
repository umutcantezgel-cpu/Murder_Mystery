/// Teil 90: das versiegelte Auflösungsheft (MECH 8.4, Kap. 13 der Fall-Bibel).
/// Der einzige Teil mit der Lösung, den Sekunden der Tatnacht und allen vier
/// Fassungscodes. Wird nie einzeln gesendet (MECH 10.3); gefaltet und
/// versiegelt, geöffnet erst nach der Anklage.
///
/// Seitenplan (A4 hoch, einseitig; MECH 8.4 in seiner Reihenfolge, Umfang
/// nach MECH 10.1: 9 / 10 / 12 Seiten bei 6 / 12 / 20 Personen):
///
///  1 Außenseite: „Auflösungsheft“, Fall-Code, „Versiegelt – erst nach der
///    Anklage öffnen“, im oberen Drittel ([KammerSeiten.versiegelt])
///  2 Was wirklich war (Vorlesen), die neun Meilensteine mit Kästchen und
///    Summe (MECH 6.1, 6.4)
///  3 Endentabelle (MECH 8.2), Ende 1 und 2; 4 Ende 3 und 4. In jedem Ende
///    stehen beide Bund-Sätze (PP9 zu oder offen) zur Wahl.
///  5 Rückblende (Vorlesen, MECH 8.3) allein auf der Seite, in der größten
///    Schrift von 11 bis 10 pt, die passt
///  6 bis Ende, fortlaufend und gleichmäßig auf 4 / 5 / 6 / 7 Seiten verteilt
///    (bis 8 / 9 bis 12 / 13 bis 17 / 18 bis 20 Personen, [_restSeiten]):
///    - Zeitleiste zum Nachlesen mit Sekunden (MECH 8.3)
///    - Die Rollen am Tisch: ein Absatz je gespielter Rolle (RK x.12, ZG x.12,
///      ZR x.13), Verdächtige mit ihrem Fassungscode; ab 14 Personen liest
///      jede Person ihren Absatz selbst
///    - Tipp-Wertung (MECH 7.2): Lösungen, Sonderregel Olli, Bonus-Ziele der
///      gespielten Rollen und des Erzählers mit Kästchen (gleicher Wortlaut
///      in einer Zeile), Spürnase
///    - Zum Nachlesen: Pflicht-Auslöser der gespielten Rollen, bei 6 bis 11
///      Personen die Streifen neben dem Lageplan (wann Streifen und Karte
///      darunter umgedreht werden, MECH 5.4, 9.14), die 19 Indizkarten mit
///      Code, Titel und Runde
///
/// MECH 8.4 sieht für Rückblende und Zeitleiste zwei Seiten vor; mit den
/// endgültigen Texten braucht die Zeitleiste allein mehr als eine Seite in
/// 9 pt. Darum laufen die Abschnitte ab Seite 6 ineinander; Überschriften
/// bleiben bei ihrem ersten Eintrag, Tabellenköpfe wiederholen sich auf jeder
/// neuen Seite. Was nicht auf die geplanten Seiten passt, ist ein Überlauf
/// ([KammerUeberlauf]); nichts steht unter 9 pt.
library;

import 'dart:math' as math;

import 'package:pdf/widgets.dart' as pw;

import 'besetzung.dart';
import 'inhalt.dart';
import 'kontext.dart';
import 'satz.dart';

/// Setzt Teil 90 (Auflösungsheft, versiegelt) in [doc].
void kammerAufloesung(pw.Document doc, KammerKontext k) => kammerTeilSetzen(doc, k, '90', (s) => _Heft(k, s).setzen());

/// Seiten ab Seite 6 (Zeitleiste bis Zum Nachlesen): bis zu `rollen` Rollen
/// so viele Seiten. Gemessen mit den endgültigen Texten füllen sie die Seiten
/// zu höchstens 90 Prozent.
const _restSeiten = [(rollen: 6, seiten: 4), (rollen: 10, seiten: 5), (rollen: 15, seiten: 6), (rollen: 18, seiten: 7)];

/// Ein unteilbarer Baustein. [kopf]: Tabellenkopf, der vor dem Baustein
/// wiederholt wird, wenn er eine Seite beginnt.
class _Block {
  _Block(this.widget, {this.kopf});
  final pw.Widget widget;
  final pw.Widget? kopf;
}

/// Ein Abschnitt des Seitenplans: [bloecke] auf genau [seiten] Seiten.
class _Abschnitt {
  _Abschnitt(this.wo, this.seiten, this.bloecke);
  final String wo;
  final int seiten;
  final List<_Block> bloecke;
}

class _Heft {
  _Heft(this.k, this.s);

  final KammerKontext k;
  final KammerSeiten s;

  KammerSatz get x => k.satz;
  KammerBesetzung get b => k.besetzung;
  KammerAufloesung get a => k.inhalt.aufloesung;
  KammerFall get f => k.fall;

  static const _teil = '90';
  static final _breite = KammerSatz.satzBreite();

  /// Größen (E15; nie unter 9 pt): Vorlesetext, Fließtext, Hinweis, Tabelle.
  static const _gVorlesen = 11.0;
  static const _gRueckblendeMin = 10.0;
  static const _gText = 10.0;
  static const _gHinweis = 9.5;
  static const _gTabelle = 9.0;

  /// Stelle des Bund-Satzes im aufgelösten Ende (ersetzt `{bund}`).
  static const _bundStelle = 'BUNDSATZ';

  /// Seiten: Außenseite, Meilensteine, Enden (zwei), Rückblende.
  static const _seiteEnden = 3;
  static const _seiteRueckblende = 5;

  String u(String schluessel, [Map<String, String> werte = const {}]) => k.ui(_teil, schluessel, werte);

  int get _rest => _restSeiten.firstWhere((r) => b.rollen <= r.rollen).seiten;

  // ---------------------------------------------------------------- Setzen

  void setzen() {
    s.versiegelt(code: k.fallCode, titel: u('deckblatt.titel'), hinweis: u('deckblatt.hinweis'));
    final abschnitte = [
      _meilensteine(),
      ..._enden(),
      _rueckblende(),
      _Abschnitt('ab-seite-6', _rest, [..._zeitleiste(), ..._rollenAmTisch(), ..._tippWertung(), ..._nachlesen()]),
    ];
    final platz = s.platz();
    var seite = 2;
    for (final ab in abschnitte) {
      for (final (i, bloecke) in _verteilen(ab, platz, seite).indexed) {
        s.seite(
          [
            for (final (j, bl) in bloecke.indexed) ...[if (j == 0 && bl.kopf != null) bl.kopf!, bl.widget],
          ],
          wo: ab.seiten == 1 ? ab.wo : '${ab.wo} ${i + 1}',
          ausrichtung: pw.CrossAxisAlignment.stretch,
        );
      }
      seite += ab.seiten;
    }
  }

  /// Verteilt die Bausteine von [ab] der Reihe nach auf genau
  /// [_Abschnitt.seiten] Seiten zu [platz] pt, ab Seite [erste], so
  /// gleichmäßig wie möglich (die vollste Seite so niedrig wie möglich).
  /// Passt es nicht: [KammerUeberlauf] mit der Seite.
  List<List<_Block>> _verteilen(_Abschnitt ab, double platz, int erste) {
    final ohneKopf = [for (final bl in ab.bloecke) x.hoehe(bl.widget, _breite)];
    final mitKopf = [
      for (final (i, bl) in ab.bloecke.indexed) ohneKopf[i] + (bl.kopf == null ? 0 : x.hoehe(bl.kopf!, _breite)),
    ];
    // Der Reihe nach mit höchstens [grenze] pt je Seite; null, wenn ein Baustein allein höher ist.
    List<List<_Block>>? packen(double grenze) {
      final seiten = <List<_Block>>[[]];
      var hoehe = 0.0;
      for (final (i, bl) in ab.bloecke.indexed) {
        if (seiten.last.isNotEmpty && hoehe + ohneKopf[i] > grenze) {
          seiten.add([]);
          hoehe = 0;
        }
        hoehe += seiten.last.isEmpty ? mitKopf[i] : ohneKopf[i];
        if (hoehe > grenze) return null;
        seiten.last.add(bl);
      }
      return seiten;
    }

    final voll = packen(platz);
    if (voll == null) {
      KammerUeberlauf.zuHoch(_teil, erste, ab.wo, mitKopf.reduce(math.max), platz);
    }
    if (voll.length > ab.seiten) {
      final letzte = erste + ab.seiten - 1;
      final summe = ohneKopf.fold(0.0, (p, q) => p + q).toStringAsFixed(1);
      throw KammerUeberlauf.werfen(_teil, letzte, ab.wo, '${voll.length} Seiten nötig, geplant sind ${ab.seiten} ($summe pt, Platz ${(ab.seiten * platz).toStringAsFixed(1)} pt)');
    }
    if (ab.seiten == 1) return voll;
    // Kleinste Seitenhöhe, mit der es auf die geplanten Seiten geht (halbierend gesucht).
    var unten = mitKopf.reduce(math.max);
    var oben = platz;
    while (oben - unten > 0.25) {
      final mitte = (unten + oben) / 2;
      final p = packen(mitte);
      if (p != null && p.length <= ab.seiten) {
        oben = mitte;
      } else {
        unten = mitte;
      }
    }
    final seiten = packen(oben)!;
    // Gleichmäßig verteilt bleibt keine Seite leer, solange es mehr Bausteine als Seiten gibt.
    if (seiten.length < ab.seiten) throw StateError('Teil $_teil (${ab.wo}): ${ab.bloecke.length} Bausteine für ${ab.seiten} Seiten');
    return seiten;
  }

  // ---------------------------------------------------------------- Bausteine

  pw.Widget _h1(String text) => x.ueberschrift(text);
  pw.Widget _h2(String text) => x.ueberschrift(text, stufe: 2);

  /// Wer liest (MECH 8.4), leise unter der Überschrift.
  pw.Widget _wer(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: x.absatz(text, groesse: _gHinweis, leise: true),
      );

  pw.Widget _abstand([double h = 8]) => pw.SizedBox(height: h);

  pw.Widget _spalte(List<pw.Widget> kinder) =>
      pw.Column(mainAxisSize: pw.MainAxisSize.min, crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: kinder);

  /// Abstand vor einem Abschnitt, der mitten auf einer Seite beginnen kann.
  static const _vorAbschnitt = 14.0;

  /// Vorlesetext aus mehreren Teilen: Balken links, Marke „Vorlesen“ in 9 pt.
  pw.Widget _vorlesen(List<pw.Widget> teile, {double luecke = 5}) => x.vorlesenKasten(teile, marke: _gTabelle, luecke: luecke);

  /// Eine Tabellenzeile als eigener Baustein ([KammerSatz.tabellenzeile]); der
  /// Kopf ([kopf]) fett, mit Linie oben und grau hinterlegt.
  pw.Widget _zeile(
    List<Object?> zellen,
    List<double> spalten, {
    bool kopf = false,
    pw.EdgeInsets innen = const pw.EdgeInsets.fromLTRB(4, 3, 4, 3),
  }) =>
      x.tabellenzeile([for (final z in zellen) x.zelle(z, groesse: _gTabelle, innen: innen, kopf: kopf)], spalten, oben: kopf, grau: kopf);

  /// Bausteine einer Tabelle, die über Seiten gehen darf: [vorweg] (etwa die
  /// Überschrift), Kopf und erste Zeile bleiben zusammen; jede weitere Zeile
  /// ist ein Baustein, vor dem sich der Kopf auf einer neuen Seite wiederholt.
  List<_Block> _tabelle(
    List<pw.Widget> vorweg,
    List<String> kopf,
    List<List<Object?>> zeilen,
    List<double> spalten, {
    pw.EdgeInsets innen = const pw.EdgeInsets.fromLTRB(4, 3, 4, 3),
  }) {
    pw.Widget k0() => _zeile(kopf, spalten, kopf: true);
    final z = [for (final r in zeilen) _zeile(r, spalten, innen: innen)];
    if (z.isEmpty) return [_Block(_spalte([...vorweg, k0()]))];
    return [
      _Block(_spalte([...vorweg, k0(), z.first])),
      for (final r in z.skip(1)) _Block(r, kopf: k0()),
    ];
  }

  /// Ganze Tabelle als ein Widget.
  pw.Widget _tabelleGanz(List<String> kopf, List<List<Object?>> zeilen, List<double> spalten) =>
      _spalte([_zeile(kopf, spalten, kopf: true), for (final r in zeilen) _zeile(r, spalten)]);

  pw.Widget _fett(String text, [double groesse = _gTabelle]) => x.fett(text, groesse: groesse);

  /// „a, b oder c“ (`liste.oder`).
  String _oder(List<String> teile) => x.aufzaehlen(teile, _teil, 'liste.oder');

  KammerPlatz _platz(String id) => f.plaetze.firstWhere((p) => p.id == id);

  // ---------------------------------------------------------------- Seite 2

  _Abschnitt _meilensteine() {
    const spalten = [0.5, 1.5, 3.45, 3.2, 0.45];
    return _Abschnitt('meilensteine', 1, [
      _Block(_spalte([
        _h1(u('wasWirklichWar')),
        _wer(u('wasWirklichWar.wer')),
        _vorlesen([x.absatz(a.wasWirklichWar, groesse: _gVorlesen)]),
        _abstand(4),
      ])),
      _Block(_spalte([
        _h1(u('meilensteine')),
        x.absatz(a.pruefung, groesse: _gHinweis),
        _abstand(6),
        _tabelleGanz(
          [u('meilensteine.nr'), u('meilensteine.feld'), u('meilensteine.kernfakt'), u('meilensteine.stichwort'), u('meilensteine.haken')],
          [for (final m in a.meilensteine) [_fett(m.nr), m.feld, m.kernfakt, m.stichwort, pw.Center(child: x.kaestchen(10))]],
          spalten,
        ),
        _abstand(4),
        x.absatz(a.meilensteinRegel, groesse: _gHinweis),
        _abstand(8),
        x.kasten([
          x.absatz('**${u('meilensteine.summe', {'max': '${f.punkte.detektivMax}'})}**', groesse: 11),
          _abstand(3),
          x.absatz(u('meilensteine.weiter', {'seite': '$_seiteEnden'}), groesse: _gHinweis, leise: true),
        ]),
      ])),
    ]);
  }

  // ---------------------------------------------------------------- Seiten 3 und 4

  List<_Abschnitt> _enden() {
    final taeter = _platz(f.taeter).name;
    final texte = {for (final e in a.enden) e.nr: e};
    final tabelle = _tabelleGanz(
      [u('enden.ende'), u('enden.anklage'), u('enden.punkte'), u('enden.name')],
      [
        for (final e in f.enden)
          [
            _fett('${e.nr}', _gText),
            e.anklage == 'taeter' ? taeter : u('enden.anklage.andere'),
            u('enden.bereich', {'von': '${e.von}', 'bis': '${e.bis}'}),
            '**${k.text(texte[e.nr]!.name)}**',
          ],
      ],
      [0.6, 1.6, 1.4, 2.6],
    );
    _Block ende(KammerEnde e) {
      final t = texte[e.nr]!;
      final teile = k.text(t.text, werte: const {'bund': _bundStelle}).split(RegExp(r'\n\s*\n'));
      return _Block(_spalte([
        _h2(u('ende', {'nr': '${e.nr}', 'name': k.klartext(t.name)})),
        _vorlesen([
          for (final teil in teile)
            if (teil.trim() == _bundStelle) _bund(e) else if (!k.leer(teil)) x.absatz(teil, groesse: _gVorlesen),
        ]),
        _abstand(10),
      ]));
    }

    return [
      _Abschnitt('enden', 1, [
        _Block(_spalte([
          _h1(u('enden')),
          _wer(u('enden.wer', {'seite': '$_seiteRueckblende'})),
          _abstand(2),
          tabelle,
          _abstand(6),
        ])),
        for (final e in f.enden.where((e) => e.anklage == 'taeter')) ende(e),
      ]),
      _Abschnitt('enden-3-4', 1, [for (final e in f.enden.where((e) => e.anklage != 'taeter')) ende(e)]),
    ];
  }

  /// Beide Bund-Sätze zur Wahl (MECH 8.2 M-24, SCHEMA aufloesung.json).
  pw.Widget _bund(KammerEnde e) {
    final taeter = e.anklage == 'taeter';
    final ohne = taeter ? a.bundSaetze.taeterOhnePp9 : a.bundSaetze.andereOhnePp9;
    final mit = taeter ? a.bundSaetze.taeterMitPp9 : a.bundSaetze.andereMitPp9;
    return x.kasten(
      [
        x.absatz(u('bund.wahl'), groesse: _gHinweis, leise: true),
        _abstand(3),
        x.absatz('**${u('bund.ohnePp9')}**\n${k.text(ohne)}', groesse: _gVorlesen),
        _abstand(4),
        x.absatz('**${u('bund.mitPp9')}**\n${k.text(mit)}', groesse: _gVorlesen),
      ],
      rahmen: 0.5,
      innen: const pw.EdgeInsets.fromLTRB(8, 5, 8, 6),
    );
  }

  // ---------------------------------------------------------------- Seite 5

  _Abschnitt _rueckblende() {
    pw.Widget bauen(double g) => _spalte([
          _h1(u('rueckblende')),
          _wer(u('rueckblende.wer')),
          _vorlesen([for (final r in a.rueckblende) x.absatz(r, groesse: g)], luecke: g * 0.5),
        ]);
    // Größte Schrift von 11 bis 10 pt in Viertelpunkten, die auf Seite 5 passt (sonst Überlauf dort).
    final platz = s.platz();
    for (var g = _gVorlesen; g >= _gRueckblendeMin - 1e-9; g -= 0.25) {
      final w = bauen(g);
      if (x.hoehe(w, _breite) <= platz) return _Abschnitt('rueckblende', 1, [_Block(w)]);
    }
    KammerUeberlauf.keineGroesse(_teil, _seiteRueckblende, 'rueckblende', _gRueckblendeMin, x.hoehe(bauen(_gRueckblendeMin), _breite), platz);
  }

  // ---------------------------------------------------------------- ab Seite 6

  List<_Block> _zeitleiste() => _tabelle(
        [_h1(u('zeitleiste')), _wer(u('zeitleiste.wer'))],
        [u('zeitleiste.zeit'), u('zeitleiste.text')],
        [for (final z in a.zeitleiste) [z.zeit, z.text]],
        const [1.6, 6.0],
        innen: const pw.EdgeInsets.fromLTRB(4, 2, 4, 2.5),
      );

  List<_Block> _rollenAmTisch() {
    pw.Widget rolle(KammerPlatz p) {
      final r = k.rolle(p);
      final name = r.fassung == null ? p.name : u('rollenAmTisch.fassung', {'name': p.name, 'code': r.fassung!.code});
      return x.balken(x.absatz('**$name** ${r.teil90}', groesse: _gVorlesen), aussen: const pw.EdgeInsets.only(bottom: 7));
    }

    final rollen = b.besetzt;
    // Auf einer Folgeseite steht über dem ersten Absatz, wozu er gehört.
    pw.Widget weiter() => _spalte([x.marke(u('rollenAmTisch.weiter'), groesse: _gTabelle), _abstand(4)]);
    return [
      _Block(_spalte([
        _abstand(_vorAbschnitt),
        _h1(u('rollenAmTisch')),
        _wer(u(b.rollenAmTischSelbst ? 'rollenAmTisch.selbst' : 'rollenAmTisch.erzaehler')),
        x.marke(k.uiGemeinsam('vorlesen'), groesse: _gTabelle),
        _abstand(4),
        rolle(rollen.first),
      ])),
      for (final p in rollen.skip(1)) _Block(rolle(p), kopf: weiter()),
    ];
  }

  List<_Block> _tippWertung() {
    // Bonus-Ziele mit gleichem Wortlaut (etwa die vier Verdächtigen, E9) stehen in einer Zeile.
    final etikett = '**${k.uiGemeinsam('heft.deinBonusZiel')}:**';
    String ziel(String roh) {
      final t = k.text(roh).trim();
      return t.startsWith(etikett) ? t.substring(etikett.length).trim() : t;
    }

    final gruppen = <String, List<String>>{};
    for (final p in b.besetzt) {
      (gruppen[ziel(k.rolle(p).bonusZiel.text)] ??= []).add(p.name);
    }
    (gruppen[ziel(a.erzaehlerBonus)] ??= []).add(k.uiGemeinsam('erzaehler'));
    pw.Widget wer(List<String> namen) => _spalte([
          for (final (i, n) in namen.indexed)
            pw.Padding(
              padding: pw.EdgeInsets.only(top: i == 0 ? 0 : 3),
              child: pw.Row(children: [x.kaestchen(9), pw.SizedBox(width: 5), _fett(n)]),
            ),
        ]);

    return [
      _Block(_spalte([
        _abstand(_vorAbschnitt),
        _h1(u('tippWertung')),
        _wer(u('tippWertung.wer')),
        _tabelleGanz(
          [u('tippWertung.frage'), u('tippWertung.loesung'), u('tippWertung.punkte')],
          [
            for (final t in a.tippFragen) [_fett('${t.nr}', _gText), x.absatz(t.loesung, groesse: _gText), _fett('${t.punkte}', _gText)],
          ],
          const [0.7, 7, 0.9],
        ),
        _abstand(6),
        // Die Sonderregel gehört zur Tabelle darüber: nie allein auf die nächste Seite.
        x.kasten([x.absatz(a.sonderregel, groesse: _gText)]),
        _abstand(4),
      ])),
      ..._tabelle(
        [_h2(u('tippWertung.bonusZiele')), _wer(u('tippWertung.bonusZiele.wer'))],
        [u('tippWertung.bonus.wer'), u('tippWertung.bonus.ziel')],
        [for (final g in gruppen.entries) [wer(g.value), g.key]],
        const [1.35, 6],
      ),
      _Block(_spalte([_abstand(8), x.absatz(a.spuernase, groesse: _gText)])),
    ];
  }

  List<_Block> _nachlesen() {
    final ausloeser = [
      for (final p in b.besetzt)
        () {
          final r = k.rolle(p);
          return [
            _fett(p.name),
            _spalte([
              x.liste(r.stufe2.ausloeser, nummer: p.art == KammerArt.verdaechtig ? KammerNummer.buchstabe : KammerNummer.zahl, groesse: _gTabelle, abstand: 1.5),
              if (r.geheimniskarte.sperre > 1)
                x.absatz(k.uiGemeinsam('heft.rundensperre', {'runde': '${r.geheimniskarte.sperre}'}), groesse: _gTabelle, leise: true),
            ]),
          ];
        }(),
    ];
    final streifen = [
      for (final st in b.streifen)
        () {
          final p = _platz(st.zeuge);
          final karte = k.rolle(p).geheimniskarte;
          final codes = _oder(karte.pflichtCodes);
          return [
            _fett(p.name),
            _oder([...st.oeffnen, u('zumNachlesen.streifen.zeitstempel', {'name': p.name})]),
            karte.sperre > 1 ? u('zumNachlesen.streifen.runde', {'codes': codes, 'runde': '${karte.sperre}'}) : codes,
          ];
        }(),
    ];
    final karten = k.inhalt.indizkarten.karten;
    final haelfte = (karten.length / 2).ceil();
    pw.Widget indiz(Iterable<KammerIndizkarte> teil) => _tabelleGanz(
          [u('zumNachlesen.indiz.code'), u('zumNachlesen.indiz.titel'), u('zumNachlesen.indiz.runde')],
          [for (final c in teil) [_fett(c.code), c.titel, '${c.abRunde}']],
          const [0.9, 3.9, 1.25],
        );

    return [
      ..._tabelle(
        [_abstand(_vorAbschnitt), _h1(u('zumNachlesen')), _wer(u('zumNachlesen.wer')), _h2(u('zumNachlesen.ausloeser'))],
        [u('zumNachlesen.ausloeser.rolle'), u('zumNachlesen.ausloeser.text')],
        ausloeser,
        const [1.1, 7],
      ),
      if (streifen.isNotEmpty)
        _Block(_spalte([
          _abstand(4),
          _h2(u('zumNachlesen.streifen')),
          _tabelleGanz(
            [u('zumNachlesen.streifen.zeuge'), u('zumNachlesen.streifen.oeffnen'), u('zumNachlesen.streifen.karte')],
            streifen,
            const [1.1, 3.4, 3.4],
          ),
        ])),
      _Block(_spalte([
        _abstand(4),
        _h2(u('zumNachlesen.indizkarten')),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: indiz(karten.take(haelfte))),
          pw.SizedBox(width: 10),
          pw.Expanded(child: indiz(karten.skip(haelfte))),
        ]),
      ])),
    ];
  }
}
