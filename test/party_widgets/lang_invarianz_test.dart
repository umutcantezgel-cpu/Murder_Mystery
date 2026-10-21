// M7b (Leitregel 2): Der lange Abend ändert nie den Fall. Je Kombination aus
// vier Täterpfaden, drei Besetzungen (7 und 4 Personen reihum, Solo) und vier
// Spielweisen spielt der Test denselben Abend (gleicher Fall-Code, gleiches
// Salz, gesalzene Würfel) einmal kurz und einmal lang, 48 Kombinationen.
//
// Lang geht er alles ab, was Streifzug und Rundgänge anbieten: das Vorspiel
// Station für Station, jede Befragung an ihrem Treffpunkt, alle fünfzehn
// Erkundungsorte über die Runden verteilt (je Runde der Reihum-Deckel), vor
// jeder Entscheidung den Rückweg in den Keller und den Morgen. Jeder Weg läuft
// Bild für Bild über die Karte des langen Abends (StreifzugKarte,
// RundgangKarte), wie der Streifzug-Bildschirm sie führt; jede Kartenaktion
// der Entscheidungen läuft über die Karte des Kellers (PartyKartenSession).
// Kurz und lang müssen danach gleich sein: Punkte, Ende, richtig, Wahlen,
// Fakten und Funde, Würfe, Nachtminuten, Marken, Abstecher, Qualitäten,
// Erzählerbausteine und die Befragungen (gestellte Fragen, erledigt).
//
// Dazu ein Abend über die echten Bildschirme (Rundgang, Diashow, Streifzug,
// Kartentisch) mit dem Entwickler-Skript, kurz und lang: Auch die Oberfläche
// des langen Abends ändert nichts am Fall.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations.dart';
import 'package:mordakte/party/abend_karte.dart';
import 'package:mordakte/party/bildschirme/rundgang.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte/party/karten_quelle.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte/party/rundgang_karte.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte/party/stand/befragung_stand.dart';
import 'package:mordakte/party/streifzug_karte.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' hide KartenQuelle;

import 'klasse_hilfe.dart' show abstecherVon, akteAusKatalog, bildDauer;

Map<String, Object?> _json(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as Map<String, Object?>;

const _weltOrdner = 'content/welt/schlosskeller';
final Map<String, Object?> _weltJson = _json('$_weltOrdner/welt.json');

/// Vorlage des Renderers aus der Darstellung der Akte (setting.json).
final Map<String, Object?> _vorlage = () {
  final setting = _json('content/party/schlosskeller/setting.json');
  return _json(((setting['darstellung'] as Map?)?['vorlage'] as String?) ?? 'content/scenarios/ravensmoor.json');
}();

/// Der Schlosskeller wie in der App ([PartyDaten.laden]): Zusätze aus
/// akten.json (mit `langfassung` und `diashow`), welt.json, Gespräche mit
/// Wahl, Gerüchte, Diashow sowie Vorspiel und Morgen. Kurz und lang spielen
/// mit denselben Daten; nur die Fassung der Einrichtung unterscheidet sie.
final PartyDaten _daten = PartyDaten.aus(
  (p) => _json('content/party/schlosskeller/$p'),
  _vorlage,
  welt: _weltJson,
  erzaehlung: _json('content/erzaehlung/schlosskeller/gespraeche.json'),
  akte: akteAusKatalog('schlosskeller'),
  geruechte: _json('$_weltOrdner/${_weltJson['geruechte']}'),
  diashow: _json('$_weltOrdner/diashow.json'),
  vorspielMorgen: _json('$_weltOrdner/${_weltJson['vorspielMorgen']}'),
);

/// Welt-Ebenen und Szenarien je Ebene wie [AbendKarte.ladeWelt], die
/// Erkundung wie `StreifzugWelt.laden`.
final _welt = () {
  final ebenen = WeltEbenen.ausJson(_json('$_weltOrdner/${_weltJson['langfassung']}'), _daten.kanon);
  return (
    ebenen: ebenen,
    szenarien: partyEbenenSzenarien(_daten.kanon, _vorlage, ebenen, id: _daten.szenario.id, welt: _weltJson),
    erkundung: Erkundung.ausJson(_json('$_weltOrdner/${_weltJson['erkundung']}')),
  );
}();

/// Erkundungsorte des Abends (Abstecher der Akte), nur in der gemischten Spielweise.
final List<AbstecherOrt> _abstecher = abstecherVon('schlosskeller');

// ---------------------------------------------------------------------------
// Kombinationen

/// Besetzungen: zwei Tische reihum und Solo mit sieben Bot-Rollen.
const _besetzungen = <({String name, int n, bool solo})>[
  (name: '7 Personen reihum', n: 7, solo: false),
  (name: '4 Personen reihum', n: 4, solo: false),
  (name: 'Solo', n: 7, solo: true),
];

/// Spielweisen des Detektivs und des Tisches.
enum _Spielweise {
  /// Beste Wahlen, alle in der Gruppe kooperativ, richtige Anklage.
  besteRichtig('beste Wahlen, richtige Anklage'),

  /// Beste Wahlen, alle kooperativ, falsche Anklage.
  besteFalsch('beste Wahlen, falsche Anklage'),

  /// Schwache Wahlen, alle in der Gruppe eigennützig, richtige Anklage.
  schwachRichtig('schwache Wahlen, richtige Anklage'),

  /// Gemischt: Optionen, gründlich und Fragen aus festem Zufall, Gruppe
  /// gemischt, Marken wo möglich, freie Befragungen von hinten, je Runde ein
  /// Abstecher, Erkundung schon vor der ersten Befragung, längste Rundenuhr.
  gemischt('gemischt mit Abstechern');

  const _Spielweise(this.name);
  final String name;
}

/// Eine der 48 Kombinationen.
class _Kombi {
  const _Kombi(this.pfad, this.besetzung, this.weise);

  final String pfad;
  final ({String name, int n, bool solo}) besetzung;
  final _Spielweise weise;

  bool get gemischt => weise == _Spielweise.gemischt;

  /// Salz des Abends: kurz und lang gleich, je Kombination ein anderes.
  String get salz => 'lang_invarianz:$pfad:${besetzung.name}:${weise.name}';

  int _zufall(String was, int n) => Rng(Rng.hashString('$salz:$was')).nextInt(n);

  /// Rundenuhr: die Vorgabe der Fassung, gemischt die längste Wahl.
  int minuten(Abendfassung f) => gemischt ? f.minutenOptionen.last : f.standardMinuten;

  /// Option der Entscheidung [e] im Pfad [taeter].
  String option(Entscheidung e, String taeter) {
    final richtig = e.richtig[taeter]!;
    return switch (weise) {
      _Spielweise.besteRichtig || _Spielweise.besteFalsch => richtig,
      _Spielweise.schwachRichtig => e.optionen.firstWhere((o) => o.id != richtig).id,
      _Spielweise.gemischt => e.optionen[_zufall('option:${e.id}', e.optionen.length)].id,
    };
  }

  /// Gründlich suchen (nur gemischt, nur bei Suchen).
  bool gruendlich(Entscheidung e) => gemischt && istSuche(e) && _zufall('gruendlich:${e.id}', 2) == 0;

  bool kooperativ(String rolle, int runde) => switch (weise) {
        _Spielweise.besteRichtig || _Spielweise.besteFalsch => true,
        _Spielweise.schwachRichtig => false,
        _Spielweise.gemischt => (rolle.length + runde).isEven,
      };

  String anklage(PartySitzung s) {
    final kern = s.kernverdaechtige;
    final taeter = s.spiel.pfad;
    return weise == _Spielweise.besteFalsch ? kern[(kern.indexOf(taeter) + 1) % kern.length] : taeter;
  }

  /// Frage der Befragung [k] (Index in ihren Fragen).
  int frage(BefragungKarte k) => gemischt ? _zufall('frage:${k.id}', k.fragen.length) : 0;

  @override
  String toString() => 'Pfad $pfad · ${besetzung.name} · ${weise.name}';
}

// ---------------------------------------------------------------------------
// Ein Abend

/// Je Runde ihre fünf Erkundungsorte in Dateireihenfolge: drei in den
/// Gesprächen, zwei zwischen den Entscheidungen (reihum genau der Deckel).
const _erkundungJeRunde = 5, _erkundungInGespraechen = 3;

/// So nah (Kacheln) steht der Detektiv am Ziel eines Wegs: am Ort selbst oder,
/// liegt der an einem Möbelstück, auf der nächsten freien Kachel daneben.
const _nah = 1.5;

/// Spielt einen Abend der Kombination [c] in der Fassung [fassung] und hält
/// fest, was der Vergleich und die Prüfungen des langen Abends brauchen.
class _Abend {
  _Abend(this.c, this.fassung) {
    s = PartySitzung(_daten, salz: c.salz);
    if (c.gemischt) s.kartenAnlegen(abstecher: _abstecher);
    s.einrichten(
      rollen: c.besetzung.n,
      detektiv: 'w',
      solo: c.besetzung.solo,
      code: FallCode.fuerPfad(c.pfad, _daten.kanon.pfade).code,
      rundendauerMinuten: c.minuten(fassung),
      fassung: fassung,
    );
  }

  final _Kombi c;
  final Abendfassung fassung;
  late final PartySitzung s;

  bool get lang => fassung.istLang;

  /// Befragungen je Runde am Ende der Gespräche: Kennung, fest, gestellte Frage, erledigt.
  final befragungen = <int, List<(String, bool, int?, bool)>>{};

  // Nur lang: was der Abend abgegangen ist.
  final rundgaenge = <RundgangTeil, List<String>>{};
  final treffen = <int, List<String>>{};
  final erkundungen = <int, List<String>>{};
  var rueckwege = 0;
  var wahlenNachRueckweg = 0;
  var _zurueck = false;

  /// Zahl der Bilder, die die Wege des langen Abends brauchten.
  var wegBilder = 0;

  var _ruf = 0;
  final _abgestecht = <int>{};

  /// Letzte Stelle des Detektivs in der laufenden Runde (Ebene, x, y), wie
  /// `StreifzugSteuerung.position`: Die Entscheidungen beginnen dort, wo die
  /// Gespräche aufhörten; eine neue Runde im Keller.
  ({int runde, String ebene, double x, double y})? _stelle;

  Future<void> spielen() async {
    for (var i = 0; i < 400; i++) {
      switch (s.phase) {
        case PartyPhase.ende:
          if (s.rundgang != null) {
            await _rundgang();
            continue;
          }
          return;
        case PartyPhase.rollen:
          // Reihum schaut jede Person verdeckt in ihr Dossier.
          if (!s.solo) {
            for (final r in s.besetzt) {
              s.zeigeVerdeckt(r);
              s.verdecken();
            }
          }
          s.weiter();
        case PartyPhase.intro:
          if (s.rundgang != null) {
            await _rundgang();
            continue;
          }
          final d = s.diashow;
          for (var n = 1; n < (d?.dias.length ?? 0); n++) {
            s.diaSetzen(n);
          }
          s.weiter();
        case PartyPhase.gespraeche:
          expect(s.uhrAktion(UhrAktion.start), isTrue);
          if (lang) {
            await _streifzugGespraeche();
          } else {
            for (final k in _befragungsPlan()) {
              _befragungFuehren(k);
            }
          }
          befragungen[s.runde] = [for (final k in s.befragungen) (k.id, k.pflicht, k.frage, k.erledigt)];
          s.weiter();
        case PartyPhase.entscheidungen:
          // Lang läuft die Rundenuhr im ganzen Streifzug weiter, kurz nur in den Gesprächen.
          expect((s.uhrInPhase, s.uhr.laeuft), (lang, true));
          if (lang) {
            await _streifzugEntscheidungen();
          } else {
            // Kurz: eine Karte für die ganzen Entscheidungen der Runde.
            final k = PartyKartenSession(s);
            for (var i = 0; _entscheidungOffen; i++) {
              if (i > 400) throw StateError('$c: Entscheidungen enden nicht');
              _entscheidungsSchritt(k);
            }
            await k.dispose();
          }
          s.weiter();
        case PartyPhase.gruppenwahl:
          while (s.offeneWaehler.isNotEmpty) {
            final w = s.offeneWaehler.first;
            s.zeigeVerdeckt(w);
            s.stimme(w, kooperativ: c.kooperativ(w, s.runde));
          }
          s.weiter();
        case PartyPhase.anklage:
          s.anklagen(c.anklage(s));
          s.weiter();
        default:
          s.weiter();
      }
    }
    throw StateError('Abend endet nicht (Phase ${s.phase})');
  }

  // -------------------------------------------------------------- Befragungen

  /// Befragungen der Runde in der Reihenfolge, in der der Detektiv sie führt:
  /// erst die festen, dann so viele freie, wie die Runde erlaubt (gemischt
  /// von hinten). Kurz und lang derselbe Plan.
  List<BefragungKarte> _befragungsPlan() {
    final karten = s.befragungen;
    final frei = [for (final k in karten) if (!k.pflicht && k.waehlbar) k];
    return [
      for (final k in karten) if (k.pflicht) k,
      ...(c.gemischt ? frei.reversed : frei).take(s.befragungenFrei),
    ];
  }

  /// Eine Befragung wie am Tisch: die Frage; reihum geht das Gerät verdeckt
  /// zur Person (Spickzettel), danach ist sie beantwortet. Im Solo antwortet die App.
  void _befragungFuehren(BefragungKarte k) {
    s.befragen(k.id, c.frage(k));
    if (k.mensch) {
      s.zeigeVerdeckt(k.rolle);
      s.verdecken();
      s.befragungErledigt(k.id);
    }
  }

  // ------------------------------------------------------------ Entscheidungen

  /// Steht noch eine Entscheidung an (oder läuft ein Zug wie der Auftakt)?
  bool get _entscheidungOffen => s.laufendeEntscheidung != null || s.zug != null || s.letzterFund != null;

  /// Ein Schritt am Kartentisch: Zug über die Karte [k], sonst je Runde ein
  /// Abstecher (gemischt), sonst die laufende Entscheidung.
  void _entscheidungsSchritt(PartyKartenSession k) {
    if (s.zug != null) return _zug(k);
    if (s.letzterFund != null) return s.fundGelesen();
    if (c.gemischt && s.abstecherOffen.isNotEmpty && _abgestecht.add(s.runde)) return s.starteAbstecher(s.abstecherOffen.first.id);
    final e = s.laufendeEntscheidung!;
    s.schlageVor(c.option(e, s.spiel.pfad));
    if (lang) {
      expect(_zurueck, isTrue, reason: '$c: Wahl ${e.id} ohne Rückweg in den Keller');
      wahlenNachRueckweg++;
      _zurueck = false;
    }
    s.bestaetigen(gruendlich: c.gruendlich(e));
  }

  /// Der laufende Zug: jeder Lauf Bild für Bild über die Karte, dann Wurf
  /// (gemischt mit Marke), Tischruf abwechselnd und Fund.
  void _zug(PartyKartenSession k) {
    for (var i = 0; i < 40; i++) {
      final z = s.zug;
      if (z == null) {
        if (s.letzterFund != null) s.fundGelesen();
        return;
      }
      switch (z.phase) {
        case RundenZugPhase.aktion:
          final a = z.aktion;
          var bilder = 0;
          while (s.zug?.phase == RundenZugPhase.aktion && s.zug?.aktion == a) {
            if (++bilder > 30 * 60) throw StateError('Lauf endet nicht: ${z.id}');
            k.szenenSchritt(bildDauer);
          }
        case RundenZugPhase.wurf:
          s.wuerfeln(marke: c.gemischt);
        case RundenZugPhase.tischruf:
          s.tischruf((_ruf++).isEven ? Tischruf.nochmal : Tischruf.umweg);
        case RundenZugPhase.fund:
          s.fundGelesen();
          return;
      }
    }
    throw StateError('Zug nicht beendet');
  }

  // ------------------------------------------------------- Langer Abend: Wege

  /// Treibt die Karte [k] Bild für Bild, bis der Weg [weg] endet. `true`, wenn
  /// der Detektiv ankam.
  Future<bool> _geh(AbendKarte k, Future<bool> weg) async {
    var fertig = false;
    var ok = false;
    unawaited(weg.then((x) {
      ok = x;
      fertig = true;
    }));
    for (var i = 0; !fertig; i++) {
      if (i > 30 * 600) throw StateError('$c: Weg endet nicht');
      if (k.laeuft) {
        k.szenenSchritt(bildDauer);
        wegBilder++;
      } else {
        // Ankunft und Lage folgen dem Weg erst nach seinem Ende (Future).
        await Future<void>.delayed(Duration.zero);
      }
    }
    return ok;
  }

  /// Vorspiel oder Morgen: zu jeder Station gehen ([RundgangKarte.geheZu],
  /// wie der Rundgang-Bildschirm), dort ankommen, dann zur nächsten Station.
  Future<void> _rundgang() async {
    final teil = s.rundgang!;
    final r = s.vorspielMorgen!.rundgang(teil);
    final k = RundgangKarte(_daten, _welt.ebenen, _welt.szenarien, r, station: s.rundgangStation, detektivName: s.personAmTisch(Besetzung.detektiv));
    final besucht = rundgaenge[teil] = [];
    try {
      while (s.rundgang == teil) {
        final nr = s.rundgangStation;
        final st = r.stationen[nr];
        expect(await _geh(k, k.geheZu(nr)), isTrue, reason: '$c: ${teil.name} Station ${st.id}');
        // Am Ort der Station oder auf dem freien Boden daneben (ein Ort an einem Möbelstück).
        final o = _welt.ebenen.ebenen[st.ebene]!.graph.orte[st.ort]!;
        final d = k.world.value!.detectives.single;
        expect((k.aktuelleEbene, dist(d.x, d.y, o.x, o.y) <= _nah), (st.ebene, true),
            reason: '$c: ${teil.name} Station ${st.id} nicht erreicht');
        besucht.add(st.id);
        s.rundgangWeiter();
      }
    } finally {
      await k.dispose();
    }
  }

  /// Streifzug-Karte der laufenden Runde: Lage zur Uhrzeit der Runde, Start
  /// im Keller oder dort, wo der Detektiv in dieser Runde zuletzt stand.
  StreifzugKarte _streifzugKarte() {
    final hier = _stelle?.runde == s.runde ? _stelle : null;
    final k = StreifzugKarte(
      _daten,
      _welt.ebenen,
      _welt.szenarien,
      lage: WeltLage(lang: true, uhr: Uhrzeit.parse(s.rundenUhrzeit)),
      quelle: SitzungsKartenQuelle(s),
      ebene: hier?.ebene ?? kellerEbene,
      start: hier == null ? null : (hier.x, hier.y),
      detektivName: s.personAmTisch(Besetzung.detektiv),
    );
    k.onMarke = (m) => _marke(k, m);
    return k;
  }

  void _stelleMerken(StreifzugKarte k) => _stelle = (runde: s.runde, ebene: k.aktuelleEbene, x: k.position.$1, y: k.position.$2);

  /// Die Marken wie der Streifzug-Bildschirm: Treffpunkte der offenen
  /// Befragungen (in den Gesprächen) und die offenen Erkundungsorte.
  void _markenSetzen(StreifzugKarte k) {
    final treff = s.streifzugTreffpunkte(_welt.erkundung);
    final offen = s.phase != PartyPhase.gespraeche
        ? const <BefragungKarte>[]
        : [for (final b in s.befragungen) if (!b.erledigt && (b.pflicht || b.gefragt || (s.befragungenFrei > 0 && b.waehlbar))) b];
    k.marken = [
      for (final b in offen)
        if (_welt.erkundung.treffpunkt(treff[b.id] ?? '') case final t?)
          if (treffpunktStelle(_welt.ebenen, t) case final p?)
            () {
              final (fx, fy) = k.nebenOrt(t.ebene, p.$1, p.$2);
              return StreifzugMarke(id: '${StreifzugMarke.treffPraefix}${b.id}', ebene: t.ebene, x: p.$1, y: p.$2, ort: t.ort, figur: b.rolle, figurX: fx, figurY: fy);
            }(),
      if (s.erkundungFrei)
        for (final o in _welt.erkundung.orte)
          if (!s.erkundet.contains(o.id))
            if (erkundungsStelle(_welt.ebenen, o, raster: k.rasterVon(o.ebene)) case final p?)
              StreifzugMarke(id: '${StreifzugMarke.erkundePraefix}${o.id}', ebene: o.ebene, x: p.$1, y: p.$2, ort: o.ziel.ort),
    ];
  }

  /// Marke, an der der Detektiv zuletzt ankam.
  String? _angekommen;

  /// Ankunft an einer Marke wie im Streifzug-Bildschirm: am Treffpunkt die
  /// Befragung (Treffen melden), am Erkundungsort die Erkundung.
  void _marke(StreifzugKarte k, StreifzugMarke m) {
    _angekommen = m.id;
    if (m.treffen) {
      if (!s.befragungen.any((b) => b.id == m.kennung)) return;
      s.streifzugTreffen(m.kennung);
      (treffen[s.runde] ??= []).add(m.kennung);
    } else if (!s.erkundet.contains(m.kennung) && s.erkundungFrei) {
      s.erkunden(m.kennung);
      (erkundungen[s.runde] ??= []).add(m.kennung);
    }
  }

  /// Geht geführt zur Marke [id] (oder steht schon dort) und kommt an.
  Future<void> _gehZu(StreifzugKarte k, String id) async {
    _markenSetzen(k);
    final m = k.marke(id) ?? (throw StateError('$c: Marke $id fehlt in Runde ${s.runde}'));
    _angekommen = null;
    if (k.steht(m)) {
      _marke(k, m);
    } else {
      expect(await _geh(k, k.geheZu(m)), isTrue, reason: '$c: kein Weg zu $id in Runde ${s.runde}');
    }
    expect(_angekommen, id, reason: '$c: nicht bei $id angekommen');
    expect((k.aktuelleEbene, dist(k.position.$1, k.position.$2, m.x, m.y) <= _nah), (m.ebene, true), reason: '$c: nicht bei $id');
    if (!m.treffen) expect(s.erkundet, contains(m.kennung), reason: '$c: $id nicht erkundet');
  }

  /// Die Erkundungsorte der laufenden Runde: in den Gesprächen die ersten
  /// drei, in den Entscheidungen die übrigen zwei.
  List<String> _erkundungsPlan({required bool gespraeche}) {
    final orte = [for (final o in _welt.erkundung.orte) o.id];
    final runde = orte.skip((s.runde - 1) * _erkundungJeRunde).take(_erkundungJeRunde);
    return (gespraeche ? runde.take(_erkundungInGespraechen) : runde.skip(_erkundungInGespraechen)).toList();
  }

  /// Gespräche im langen Abend: jede Befragung des Plans an ihrem Treffpunkt
  /// (erst ankommen, dann fragen), dazu drei Erkundungsorte (gemischt einer
  /// schon vor der ersten Befragung).
  Future<void> _streifzugGespraeche() async {
    final k = _streifzugKarte();
    try {
      expect(k.aktuelleEbene, kellerEbene, reason: 'Eine Runde beginnt im Keller');
      final erkunden = _erkundungsPlan(gespraeche: true);
      if (c.gemischt) await _gehZu(k, '${StreifzugMarke.erkundePraefix}${erkunden.removeAt(0)}');
      for (final b in _befragungsPlan()) {
        await _gehZu(k, '${StreifzugMarke.treffPraefix}${b.id}');
        expect(treffen[s.runde], contains(b.id), reason: '$c: Befragung ${b.id} ohne Treffpunkt');
        _befragungFuehren(b);
      }
      for (final id in erkunden) {
        await _gehZu(k, '${StreifzugMarke.erkundePraefix}$id');
      }
      _stelleMerken(k);
    } finally {
      await k.dispose();
    }
  }

  /// Entscheidungen im langen Abend: vor den ersten beiden Entscheidungen je
  /// ein Erkundungsort, dann der Rückweg in den Keller; im Keller läuft die
  /// Entscheidung am Kartentisch unverändert (der Auftakt der ersten Runde
  /// gehört zur ersten). Danach geht es zurück auf den Streifzug.
  Future<void> _streifzugEntscheidungen() async {
    final k = _streifzugKarte();
    final erkunden = _erkundungsPlan(gespraeche: false);
    try {
      while (_entscheidungOffen) {
        if (erkunden.isNotEmpty) await _gehZu(k, '${StreifzugMarke.erkundePraefix}${erkunden.removeAt(0)}');
        await _geh(k, k.zurueckInDenKeller().then((_) => true));
        final start = k.kellerStart;
        expect((k.aktuelleEbene, dist(k.position.$1, k.position.$2, start.$1, start.$2) <= AbendKarte.ankunftsRadius), (kellerEbene, true),
            reason: '$c: Rückweg endet nicht am Ermittlungsort');
        rueckwege++;
        _zurueck = true;
        // Der Kartentisch der Entscheidung, bis sie entschieden und alles still ist.
        final tisch = PartyKartenSession(s);
        final vorher = s.spiel.gewaehlt.length;
        for (var i = 0; _entscheidungOffen && !(s.spiel.gewaehlt.length > vorher && s.zug == null && s.letzterFund == null); i++) {
          if (i > 200) throw StateError('$c: Entscheidung endet nicht');
          _entscheidungsSchritt(tisch);
        }
        await tisch.dispose();
      }
      expect(erkunden, isEmpty, reason: '$c: Erkundung der Runde ${s.runde} nicht abgegangen');
      _stelleMerken(k);
    } finally {
      await k.dispose();
    }
  }
}

/// Alles, was die Fassung nie ändern darf, am Ende des Abends.
Map<String, Object?> _ergebnis(PartySitzung s) => {
      'punkte': s.spiel.punkte,
      'ende': s.ende.id,
      'richtig': s.ende.richtig,
      'angeklagt': s.angeklagt,
      'gewaehlt': {...s.spiel.gewaehlt},
      'fakten': [...s.spiel.bekannteFakten()]..sort(),
      'funde': {for (final e in s.funde.entries) e.key: [for (final a in e.value) (a.fakt, a.entstanden)]},
      'wuerfe': [for (final w in s.wuerfe) w.zeile],
      'nachtminuten': (s.restMinuten, s.reserveMinuten),
      'marken': s.marken,
      'abstecher': {for (final e in s.abstecherErgebnis.entries) e.key: e.value.name},
      'abstecherFunde': [...s.abstecherFunde]..sort(),
      'qualitaeten': {for (final e in s.spiel.qualitaeten.entries) e.key: e.value.name},
      'bausteine': [...s.spiel.bausteine],
      'notizen': [for (final k in s.befragungsNotizen) (k.id, k.frage)],
      'erzaehlerNotizen': s.erzaehlerNotizen,
    };

Future<_Abend> _spiele(_Kombi c, Abendfassung f) async {
  final a = _Abend(c, f);
  addTearDown(a.s.dispose);
  await a.spielen();
  return a;
}

/// Befehle des Journals mit dem Namen [b].
Iterable<Map> _befehle(PartySitzung s, String b) => (s.abendstand['befehle'] as List).cast<Map>().where((x) => x['b'] == b);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final pfade = _daten.kanon.pfade;
  final orte = {for (final o in _welt.erkundung.orte) o.id};

  test('Grundlagen: vier Pfade, fünfzehn Erkundungsorte, drei Entscheidungen je Runde, Vorspiel und Morgen', () {
    expect(pfade, hasLength(4));
    expect(orte, hasLength(erkundungAnzahl));
    expect(erkundungAnzahl, 3 * _erkundungJeRunde);
    expect(_erkundungJeRunde, streifzugDeckelReihum);
    for (var r = 1; r <= 3; r++) {
      expect(_daten.karte.ermittlung.entscheidungen.where((e) => e.runde == r), hasLength(3), reason: 'Runde $r');
    }
    expect(_daten.hat('langfassung'), isTrue);
    expect(_daten.vorspielMorgen, isNotNull);
    expect(_abstecher, isNotEmpty);
  });

  final kombis = [
    for (final pfad in pfade)
      for (final b in _besetzungen)
        for (final w in _Spielweise.values) _Kombi(pfad, b, w),
  ];
  assert(kombis.length == 48);

  group('Kurz gegen lang (${kombis.length} Kombinationen)', () {
    for (final c in kombis) {
      test('$c: lang endet wie kurz', () async {
        final kurz = await _spiele(c, Abendfassung.kurz);
        final lang = await _spiele(c, Abendfassung.lang);
        final soll = _ergebnis(kurz.s);
        expect(soll['wuerfe'], isNotEmpty, reason: 'es wurde gewürfelt');
        if (c.gemischt) expect(soll['abstecher'], isNotEmpty, reason: 'ein Abstecher gehört dazu');
        expect([kurz.s.phase, kurz.s.lang, lang.s.phase, lang.s.lang], [PartyPhase.ende, false, PartyPhase.ende, true]);

        // Der Vergleich: alles gleich, auch die Befragungen jeder Runde.
        expect(_ergebnis(lang.s), equals(soll));
        expect(lang.befragungen, equals(kurz.befragungen));
        for (var r = 1; r <= 3; r++) {
          final b = kurz.befragungen[r]!;
          expect(b.where((x) => x.$2).every((x) => x.$4), isTrue, reason: 'Runde $r: jede feste Befragung erledigt');
          expect(b.where((x) => x.$4).length, inInclusiveRange(3, 5), reason: 'Runde $r: drei bis fünf Befragungen');
        }

        // Kurz bleibt kurz: kein Rundgang, keine Erkundung, keine Fassung im Journal.
        expect(_befehle(kurz.s, 'rundgang'), isEmpty);
        expect(_befehle(kurz.s, 'erkundet'), isEmpty);
        expect(_befehle(kurz.s, 'einrichten').single.containsKey('fassung'), isFalse);
        expect(kurz.rueckwege, 0);

        // Lang ist alles abgegangen.
        final vm = _daten.vorspielMorgen!;
        expect(lang.rundgaenge[RundgangTeil.vorspiel], [for (final st in vm.vorspiel.stationen) st.id], reason: 'Vorspiel komplett');
        expect(lang.rundgaenge[RundgangTeil.morgen], [for (final st in vm.morgen.stationen) st.id], reason: 'Morgen komplett');
        expect(_befehle(lang.s, 'rundgang').where((b) => b['ueberspringen'] == true), isEmpty);
        for (var r = 1; r <= 3; r++) {
          final gefuehrt = [for (final b in lang.befragungen[r]!) if (b.$4) b.$1];
          expect(gefuehrt, isNotEmpty, reason: 'Runde $r');
          expect(lang.treffen[r], containsAll(gefuehrt), reason: 'Runde $r: jede Befragung am Treffpunkt angetroffen');
          expect(lang.erkundungen[r], hasLength(_erkundungJeRunde), reason: 'Runde $r');
          expect(lang.s.erkundetInRunde(r), _erkundungJeRunde, reason: 'Runde $r');
        }
        expect(lang.s.erkundet, orte, reason: 'alle fünfzehn Erkundungsorte');
        expect(_befehle(lang.s, 'erkundet'), hasLength(erkundungAnzahl));
        expect(lang.wahlenNachRueckweg, lang.s.spiel.gewaehlt.length, reason: 'jede Wahl nach dem Rückweg');
        expect(lang.rueckwege, 9, reason: 'vor jeder der neun Entscheidungen zurück in den Keller');
        expect(lang.wegBilder, greaterThan(0), reason: 'die Wege liefen über die Karte');

        // Das Journal des langen Abends spielt denselben Abend nach.
        final weiter = PartySitzung.fortsetzen(_daten, lang.s.abendstand, abstecher: _abstecher);
        addTearDown(weiter.dispose);
        expect([weiter.lang, weiter.phase, weiter.rundgang, weiter.erkundet], [true, PartyPhase.ende, null, orte]);
        expect(_ergebnis(weiter), equals(soll));
      });
    }
  });

  group('Über die Bildschirme', () {
    final weltLaden = RundgangBildschirm.weltLaden;
    setUp(() {
      RundgangBildschirm.weltLaden = (_) async => (_welt.ebenen, _welt.szenarien);
      StreifzugWelt.vorgabe = StreifzugWelt(_welt.ebenen, _welt.szenarien, _welt.erkundung);
    });
    tearDown(() {
      RundgangBildschirm.weltLaden = weltLaden;
      StreifzugWelt.vorgabe = null;
    });

    /// Spielt den Abend mit dem Entwickler-Skript über die echten Bildschirme
    /// (PartyAblauf: Rundgang, Diashow, Streifzug, Kartentisch) bis `PARTY fertig`.
    Future<PartySitzung> skript(WidgetTester t, Abendfassung f) async {
      final s = PartySitzung(_daten, salz: 'lang_invarianz:skript');
      s.abendzeit = () => t.binding.clock.now().millisecondsSinceEpoch;
      final zeilen = <String>[];
      final vorher = debugPrint;
      debugPrint = (String? m, {int? wrapWidth}) {
        if (m != null) zeilen.add(m);
      };
      PartySitzung.protokoll = true;
      try {
        await t.pumpWidget(MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(body: PartyAblauf(sitzung: s)),
        ));
        await t.pump();
        final dev = PartyDev(rollen: 4, pfad: 'fatma', skript: const ['erste', 'gemischt', 'richtig'], takt: 60, fotos: false, fotopause: 60, zeitraffer: 600, fassung: f);
        unawaited(PartySkript(s, dev).starten());
        for (var i = 0; i < 30000 && !zeilen.any((z) => z.startsWith('PARTY fertig') || z.startsWith('PARTY fehler')); i++) {
          await t.pump(const Duration(milliseconds: 100));
        }
      } finally {
        debugPrint = vorher;
        PartySitzung.protokoll = false;
      }
      expect(zeilen.where((z) => z.startsWith('PARTY fehler')), isEmpty, reason: '${f.name}: ${zeilen.reversed.take(8).join(' | ')}');
      expect(zeilen.where((z) => z.startsWith('PARTY fertig pfad=fatma')), hasLength(1), reason: '${f.name}: Der Abend läuft durch');
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 2));
      return s;
    }

    testWidgets('Skript kurz und lang (4 Personen reihum, erste Optionen, Gruppe gemischt): derselbe Abend', (t) async {
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final kurz = await skript(t, Abendfassung.kurz);
      final lang = await skript(t, Abendfassung.lang);
      addTearDown(kurz.dispose);
      addTearDown(lang.dispose);
      expect([kurz.lang, lang.lang], [false, true]);
      expect(_befehle(lang, 'erkundet'), hasLength(erkundungAnzahl), reason: 'Der lange Abend ging über den Streifzug');
      expect(_befehle(lang, 'rundgang'), isNotEmpty, reason: 'und über Vorspiel und Morgen');
      expect(_ergebnis(lang), equals(_ergebnis(kurz)));
    });
  });

  test('Gegenprobe: der Vergleich sieht eine andere Spielweise', () async {
    final p = pfade.first;
    final a = await _spiele(_Kombi(p, _besetzungen.first, _Spielweise.besteRichtig), Abendfassung.lang);
    final b = await _spiele(_Kombi(p, _besetzungen.first, _Spielweise.schwachRichtig), Abendfassung.lang);
    expect(_ergebnis(b.s), isNot(equals(_ergebnis(a.s))));
  });
}
