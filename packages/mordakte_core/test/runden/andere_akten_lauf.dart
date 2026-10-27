// T-N · Schnappschuss aller fünf Akten vor der Einfluss-Schicht (Finale §0.1, §4).
//
// Je Akte SHA-256-Summen über kanonisches JSON (Schlüssel sortiert):
// (a) vollständige RundenPartie-Abende für feste Fall-Codes × Rollenzahlen {min, 8 bzw. max ≤ 8, max} ×
//     drei Wahlfolgen (bestes Spiel, erste Option, gezogen): Bausteine mit Wortlaut, alle Züge mit Würfen,
//     Vorschau und Modifikatoren, Abstecher, Minuten, Fakten, Restmengen, Bot-Stimmen und Qualitäten,
//     Bonus, Punkte, Ende; dazu Druckspiel-Abende über das reine Spiel;
// (b) geskriptete Online-Abende im Raum (SchlosskellerRaum, den alle Akten nutzen, aufgebaut wie die
//     Server-Fabrik): nach jeder Nachricht zustandFuer(...) für jedes Gerät.
// Der Schlosskeller läuft ohne neue Schichten. Vergleichsstand: andere_akten_soll.g.dart, geschrieben von
// tool/bollwerk/andere_akten_soll.dart, nie neu schreiben. Nur VM (liest die Akten mit dart:io).
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../party/kanon_hilfe.dart';
import 'befragung_treiber.dart';

/// Die fünf Akten des Spiels (feste Reihenfolge, unabhängig von `akten.json`).
const schnappAkten = ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm'];

/// Eine Akte so geladen, wie die Server-Fabrik sie aufbaut (`server/lib/party.dart`).
class SchnappAkte {
  final String id;
  final Kanon kanon;
  final Texte texte;
  final Ermittlung ermittlung;
  final List<AbstecherOrt> abstecher;
  final int dias;
  final Erkundung? erkundung;
  final VorspielMorgen? rundgang;
  SchnappAkte._(this.id, this.kanon, this.texte, this.abstecher, this.dias, this.erkundung, this.rundgang)
      : ermittlung = Ermittlung(kanon);

  factory SchnappAkte.lade(String id) {
    final root = '$repoWurzel/content/party';
    final kanon = ladeKanon(id);
    final sammlung = Textsammlung.lade((p) => leseJson('$root/$id/$p'));
    // Fehlende ui-Texte der übrigen Akten kommen aus der eingefrorenen Basis (A-061), wie auf dem Server.
    if (id != 'schlosskeller') sammlung.ergaenzeUi(Textsammlung.lade((p) => leseJson('$root/basis-ui/$p')));
    final ab = File('$root/zusatz/$id/abstecher.json');
    final welt = '$repoWurzel/content/welt/$id';
    final dia = File('$welt/diashow.json');
    final weltJson = File('$welt/welt.json').existsSync() ? leseJson('$welt/welt.json') : const <String, Object?>{};
    final erk = weltJson['erkundung'], vm = weltJson['vorspielMorgen'];
    return SchnappAkte._(
      id,
      kanon,
      Texte(kanon, sammlung),
      ab.existsSync() ? AbstecherOrt.liste(leseJson(ab.path)) : const [],
      dia.existsSync() ? Diashow.ausJson(leseJson(dia.path)).dias.length : 0,
      erk is String ? Erkundung.ausJson(leseJson('$welt/$erk')) : null,
      vm is String && File('$welt/$vm').existsSync() ? VorspielMorgen.ausJson(leseJson('$welt/$vm')) : null,
    );
  }

  int get minRollen => texte.besetzung.minRollen;
  int get maxRollen => texte.besetzung.maxRollen;

  /// Rollenzahlen der Partie-Abende: kleinste, 8 (bzw. größte ≤ 8), größte.
  List<int> get rollenzahlen => {minRollen, maxRollen < 8 ? maxRollen : 8, maxRollen}.toList();

  /// Zwölf feste Fall-Codes: zuerst je Pfad der Code der Spielleitung, dann gezogene.
  List<FallCode> get codes => [
        for (final p in kanon.pfade) FallCode.fuerPfad(p, kanon.pfade),
        for (var i = 0; i < 12 - kanon.pfade.length; i++) FallCode.zufall(Rng(Rng.hashString('tn-code:$id:$i'))),
      ];
}

/// Kanonische Form: Schlüssel sortiert, Listen in Reihenfolge, Werte unverändert.
Object? kanonisch(Object? w) => switch (w) {
      Map m => {for (final e in (m.entries.toList()..sort((x, y) => '${x.key}'.compareTo('${y.key}')))) '${e.key}': kanonisch(e.value)},
      Iterable l => [for (final x in l) kanonisch(x)],
      _ => w,
    };

/// Summenbildung über Zeilen (je Zeile kanonisches JSON und Zeilenende).
class _Summe implements Sink<Digest> {
  Digest? _d;
  late final ByteConversionSink _ein = sha256.startChunkedConversion(this);
  void zeile(Object? wert) => _ein.add(utf8.encode('${jsonEncode(kanonisch(wert))}\n'));
  @override
  void add(Digest d) => _d = d;
  @override
  void close() {}
  String fertig() {
    _ein.close();
    return _d.toString();
  }
}

/// Alle Summen einer Akte, Schlüssel `<akte>/<teil>`.
Map<String, String> andereAktenSummenFuer(String akte) {
  final a = SchnappAkte.lade(akte);
  final aus = <String, String>{};
  for (final n in a.rollenzahlen) {
    final s = _Summe();
    for (final (i, code) in a.codes.indexed) {
      for (final wahl in const ['best', 'erste', 'zufall']) {
        _partieAbend(a, code, n, wahl, i, s.zeile);
      }
    }
    aus['$akte/partie/$n'] = s.fertig();
  }
  final druck = _Summe();
  for (final n in a.rollenzahlen) {
    for (final (i, code) in a.codes.indexed) {
      _druckAbend(a, code, n, i, druck.zeile);
    }
  }
  aus['$akte/druck'] = druck.fertig();
  for (final abend in _raumAbende(a)) {
    final s = _Summe();
    abend.spielen(s.zeile);
    aus['$akte/raum/${abend.name}'] = s.fertig();
  }
  return aus;
}

/// Alle Summen aller fünf Akten.
Map<String, String> andereAktenSummen() => {for (final a in schnappAkten) ...andereAktenSummenFuer(a)};

// ---------------------------------------------------------------- (a) Partie

Map<String, Object?> _wurf(Wurf? w) => w == null ? const {} : {...w.toJson(), 'zeile': w.zeile, 'summe': w.summe};

Map<String, Object?>? _zug(RundenZug? z) => z == null
    ? null
    : {
        'id': z.id, 'option': z.option, 'suche': z.suche, 'phase': z.phase.name, 'aktion': z.aktion,
        'ruf': z.ruf?.name, 'wurf': _wurf(z.wurf), 'auftakt': z.istAuftakt,
        'funde': [for (final f in z.funde) {'fakt': f.fakt, 'entstanden': f.entstanden, 'text': f.text}],
        'abstecher': z.abstecher, 'nebenfund': z.nebenfund,
      };

List<String> _sortiert(Iterable<String> x) => [...x]..sort();

/// Bot-Stimmen der Runde für alle besetzten Rollen (eigener 70-Prozent-Strom, K-20) und die Qualität.
Map<String, Object?> _abstimmen(Spiel spiel, String salz, Qualitaet Function({required int kooperativ, required bool taeterSabotiert}) abstimmen) {
  final stimmen = {for (final r in spiel.besetzt) r: botKooperativ(salz: salz, rolle: r, runde: spiel.runde)};
  final kooperativ = stimmen.entries.where((e) => e.key != spiel.pfad && e.value).length;
  final sabotage = stimmen[spiel.pfad] == false;
  final q = abstimmen(kooperativ: kooperativ, taeterSabotiert: sabotage);
  return {'stimmen': stimmen, 'kooperativ': kooperativ, 'sabotage': sabotage, 'qualitaet': q.name};
}

Map<String, String> _wahlfolge(SchnappAkte a, String art, String pfad, Rng r) => switch (art) {
      'best' => {for (final e in a.ermittlung.entscheidungen) e.id: e.richtig[pfad]!},
      'erste' => {for (final e in a.ermittlung.entscheidungen) e.id: e.optionen.first.id},
      _ => {for (final e in a.ermittlung.entscheidungen) e.id: e.optionen[r.nextInt(e.optionen.length)].id},
    };

void _partieAbend(SchnappAkte a, FallCode code, int rollen, String wahlArt, int nr, void Function(Object?) aus) {
  final salz = 'tn:${a.id}:$nr:$rollen:$wahlArt';
  final r = Rng(Rng.hashString('tn-strategie:$salz'));
  final p = RundenPartie(a.kanon, quelle: SalzWuerfel(salz), ermittlung: a.ermittlung, abstecher: a.abstecher);
  p.einrichten(Einstellungen(rollen: rollen, detektiv: nr.isEven ? 'm' : 'w', code: code));
  final pfad = p.spiel.pfad;
  final wahl = _wahlfolge(a, wahlArt, pfad, r);
  aus({'abend': salz, 'code': code.code, 'pfad': pfad, 'besetzt': p.spiel.besetzt, 'wahl': wahl});
  var gesehen = 0;
  void stand(Map<String, Object?> schritt) {
    final neu = p.spiel.bausteine.skip(gesehen).toList();
    gesehen = p.spiel.bausteine.length;
    aus({
      ...schritt,
      'phase': p.phase.name, 'runde': p.runde, 'kannWeiter': p.kannWeiter,
      'rest': p.restMinuten, 'reserve': p.reserveMinuten, 'marken': p.marken, 'bilanz': p.seifenblasenBilanz,
      'fakten': _sortiert(p.fakten), 'restmenge': _sortiert(p.spiel.restmenge()),
      'zug': _zug(p.zug), 'naechste': p.naechsteEntscheidung?.id,
      'optionen': [if (p.naechsteEntscheidung case final e?) for (final o in p.spiel.optionen(e.id)) o.id],
      'abstecherOffen': [for (final o in p.abstecherOffen) o.id],
      'bausteine': [for (final b in neu) {'id': b, 'text': a.texte.baustein(b)}],
    });
  }

  for (var schritte = 0; p.phase != PartyPhase.ende; schritte++) {
    if (schritte > 400) throw StateError('Sackgasse: $salz');
    final z = p.zug;
    if (z != null) {
      switch (z.phase) {
        case RundenZugPhase.aktion:
          stand({'aktionFertig': p.aktionFertig(z.aktion)});
        case RundenZugPhase.wurf:
          final werkzeug = r.chance(0.3), marke = r.chance(0.3);
          final v = p.vorschau(werkzeug: werkzeug, marke: marke);
          final vorschau = {'mod': v.mod, 'garantie': v.garantie, 'markeWirkt': v.markeWirkt, 'prozent': {for (final e in v.prozent.entries) e.key.name: e.value}};
          final w = p.wuerfeln(werkzeug: werkzeug, marke: marke);
          stand({'wurf': _wurf(w), 'werkzeug': werkzeug, 'marke': marke, 'vorschau': vorschau});
        case RundenZugPhase.tischruf:
          final ruf = r.chance(0.5) ? Tischruf.nochmal : Tischruf.umweg;
          p.tischruf(ruf);
          stand({'tischruf': ruf.name});
        case RundenZugPhase.fund:
          p.fundGelesen();
          stand({'fundGelesen': true});
      }
    } else if (p.naechsteEntscheidung case final e?) {
      final offen = p.abstecherOffen;
      if (offen.isNotEmpty && r.chance(0.35)) {
        final ort = offen[r.nextInt(offen.length)].id;
        final gruendlich = r.chance(0.3);
        String? fehler;
        try {
          p.starteAbstecher(ort, gruendlich: gruendlich);
        } on StateError {
          fehler = 'gesperrt';
          p.starteAbstecher(ort);
        }
        stand({'abstecher': ort, 'gruendlich': gruendlich, 'fehler': fehler});
      } else {
        final gruendlich = istSuche(e) && r.chance(0.25);
        p.waehle(wahl[e.id]!, gruendlich: gruendlich);
        stand({'waehle': e.id, 'option': wahl[e.id], 'gruendlich': gruendlich});
      }
    } else {
      final schritt = <String, Object?>{'weiter': p.phase.name};
      if (p.phase == PartyPhase.gruppenwahl) schritt['gruppenwahl'] = _abstimmen(p.spiel, salz, p.abstimmen);
      if (p.phase == PartyPhase.anklage) {
        final person = wahlArt == 'best' ? pfad : a.kanon.kernverdaechtige[r.nextInt(a.kanon.kernverdaechtige.length)];
        p.anklagen(person);
        schritt['anklage'] = person;
      }
      p.weiter();
      stand(schritt);
    }
  }
  aus({
    'ende': p.spiel.ende.id, 'punkte': p.spiel.punkte, 'angeklagt': p.spiel.angeklagt,
    'gewaehlt': p.spiel.gewaehlt, 'qualitaeten': {for (final e in p.spiel.qualitaeten.entries) '${e.key}': e.value.name},
    'restJeRunde': p.restJeRunde, 'wuerfe': [for (final w in p.wuerfe) w.zeile],
    'abstecherErgebnis': {for (final e in p.abstecherErgebnis.entries) e.key: e.value.kurz},
    'abstecherFunde': _sortiert(p.abstecherFunde), 'restmenge': _sortiert(p.spiel.restmenge()),
    'bekannt': [for (var r = 1; r <= 3; r++) _sortiert(p.spiel.bekannteFakten(r))],
  });
}

/// Druckspiel: das reine Spiel ohne Würfel (Papierstreifen A/B, BE-12).
void _druckAbend(SchnappAkte a, FallCode code, int rollen, int nr, void Function(Object?) aus) {
  final salz = 'tn-druck:${a.id}:$nr:$rollen';
  final r = Rng(Rng.hashString(salz));
  final s = Spiel(a.kanon, ermittlung: a.ermittlung)
    ..einrichten(Einstellungen(rollen: rollen, detektiv: nr.isOdd ? 'm' : 'w', code: code, druck: true));
  final wahl = _wahlfolge(a, nr.isEven ? 'zufall' : 'best', s.pfad, r);
  aus({'abend': salz, 'code': code.code, 'pfad': s.pfad, 'besetzt': s.besetzt});
  var gesehen = 0;
  while (s.phase != PartyPhase.ende) {
    final schritt = <String, Object?>{'phase': s.phase.name, 'runde': s.runde};
    if (s.phase == PartyPhase.entscheidungen) {
      schritt['funde'] = [
        for (final e in s.ermittlung.runde(s.runde)) ...[
          e.id,
          [for (final o in s.optionen(e.id)) o.id],
          for (final f in s.waehle(e.id, wahl[e.id]!)) {'fakt': f.fakt, 'entstanden': f.entstanden, 'text': f.text},
        ],
      ];
    }
    if (s.phase == PartyPhase.gruppenwahl) schritt['gruppenwahl'] = _abstimmen(s, salz, s.abstimmen);
    if (s.phase == PartyPhase.anklage) s.anklagen(nr.isEven ? s.pfad : a.kanon.kernverdaechtige.first);
    s.weiter();
    final neu = s.bausteine.skip(gesehen).toList();
    gesehen = s.bausteine.length;
    aus({
      ...schritt,
      'restmenge': _sortiert(s.restmenge()),
      'bausteine': [for (final b in neu) {'id': b, 'text': a.texte.baustein(b)}],
    });
  }
  aus({'ende': s.ende.id, 'punkte': s.punkte, 'angeklagt': s.angeklagt, 'qualitaeten': {for (final e in s.qualitaeten.entries) '${e.key}': e.value.name}});
}

// ---------------------------------------------------------------- (b) Raum

/// Ein geskripteter Online-Abend: Geräte p0 … p(n−1), p0 ist Gastgeber.
class _RaumAbend {
  final String name;
  final SchnappAkte akte;
  final int geraete, rollen;
  final String detektiv;
  final String? erzaehler;
  final String pfad;
  final Abendfassung fassung;
  _RaumAbend(this.name, this.akte, {required this.geraete, required this.rollen, required this.detektiv, this.erzaehler, required this.pfad, this.fassung = Abendfassung.kurz});

  String get leiter => erzaehler ?? detektiv;

  void spielen(void Function(Object?) aus) {
    final a = akte;
    final lang = fassung.istLang;
    final r = SchlosskellerRaum(
      raumCode: 'TNAB', kanon: a.kanon, texte: a.texte, akte: a.id, abstecher: a.abstecher, diaAnzahl: a.dias,
      fassung: fassung, erkundung: lang ? a.erkundung : null, rundgang: lang ? a.rundgang : null,
      gastgeberSitz: Sitz.detektiv,
      fallCode: FallCode.fuerPfad(pfad, a.kanon.pfade), salz: 'tn-raum:${a.id}:$name',
    );
    final strategie = Rng(Rng.hashString('tn-raum-strategie:${a.id}:$name'));
    var zeit = 1000;
    void ansichten() {
      for (final id in r.spielerIds) {
        try {
          aus({'an': id, 'v': r.zustandFuer(id)});
        } on PartyRaumFehler catch (e) {
          aus({'an': id, 'fehler': e.code});
        }
      }
    }

    void senden(String id, String typ, [Map<String, Object?> d = const {}]) {
      zeit += 7000;
      String? fehler;
      try {
        r.nachricht(id, mitAbendzeit({'typ': typ, ...d}, zeit));
      } on PartyRaumFehler catch (e) {
        fehler = e.code;
      }
      aus({'von': id, 'typ': typ, 'daten': d, 'fehler': fehler, 'beendet': r.beendet});
      ansichten();
    }

    // Lobby: beitreten, Sitze, Rollenzahl, Wunsch, bereit, Start.
    for (var i = 0; i < geraete; i++) {
      aus({'beitreten': 'p$i', 'ok': r.beitreten('p$i', 'Person $i')});
    }
    ansichten();
    if (erzaehler != null) senden('p0', 'sitz', {'spieler': erzaehler, 'sitz': 'erzaehler'});
    senden('p0', 'sitz', {'spieler': detektiv, 'sitz': 'detektiv'});
    senden('p0', 'besetzung', {'rollen': rollen});
    final ohneSitz = [for (var i = 0; i < geraete; i++) 'p$i']..removeWhere((id) => id == detektiv || id == erzaehler);
    if (ohneSitz.isNotEmpty) senden(ohneSitz.first, 'wunsch', {'rolle': a.texte.besetzung.reihenfolge[1]});
    senden(ohneSitz.isEmpty ? 'p0' : ohneSitz.last, 'start', {'rollen': rollen}); // vor „bereit“: not_ready
    for (var i = 0; i < geraete; i++) {
      senden('p$i', 'bereit', {'wert': true});
    }
    senden('p0', 'start', {'rollen': rollen});

    final gestoert = <String>{};
    var wahlen = 0;
    for (var i = 0; i < 1500; i++) {
      final s = r.zustandFuer(detektiv);
      if (s['phase'] == 'ende' && s['rundgang'] == null) return;
      final phase = s['phase'] as String;
      final runde = s['runde'] as int;
      // Einmalige Störungen je Abschnitt: falsche Rechte, Verbindungsabbruch, Aufgeben und Rückkehr.
      final marke = '$phase/$runde';
      if (gestoert.add(marke) && ohneSitz.isNotEmpty) {
        final gast = ohneSitz.last;
        switch (marke) {
          case 'gespraeche/1':
            senden(gast, 'weiter');
            senden(gast, 'stimme', {'kooperativ': true});
          case 'entscheidungen/1':
            senden(gast, 'wahl', {'option': 'x'});
          case 'gespraeche/2':
            r.verbunden(gast, false);
            aus({'verbunden': gast, 'ja': false});
            ansichten();
            r.verbunden(gast, true);
            aus({'verbunden': gast, 'ja': true});
            ansichten();
          case 'entscheidungen/2' when ohneSitz.length > 1:
            r.verlassen(ohneSitz.first);
            aus({'verlassen': ohneSitz.first});
            ansichten();
          case 'gespraeche/3' when ohneSitz.length > 1:
            aus({'beitreten': ohneSitz.first, 'ok': r.beitreten(ohneSitz.first, 'Zurück')});
            ansichten();
        }
      }
      if (s['rundgang'] case final Map g) {
        senden(leiter, 'rundgang', {'station': g['station']});
        continue;
      }
      switch (phase) {
        case 'rollen':
          for (final t in (s['spieler'] as List).cast<Map>()) {
            if (t['rolle'] != null && t['online'] == true && !(_privat(r, t['id'] as String)['gelesen'] as bool? ?? true)) {
              senden(t['id'] as String, 'rollenGelesen');
            }
          }
          senden(leiter, 'weiter');
        case 'intro':
          final dia = s['dia'];
          if (dia is int && dia + 1 < a.dias) {
            senden(leiter, 'dia', {'nr': dia + 1});
          } else {
            senden(leiter, 'weiter');
          }
        case 'gespraeche':
          if (s['uhr'] case final Map uhr when uhr['start'] == null) {
            senden(leiter, 'uhr', {'aktion': 'start'});
            senden(leiter, 'uhr', {'aktion': 'plus', 'minuten': 5});
            senden(leiter, 'uhr', {'aktion': 'pause'});
          }
          if (s['streifzug'] is Map && lang) {
            final orte = a.erkundung!.orte;
            senden(detektiv, 'erkunde', {'ort': orte[(runde - 1) % orte.length].id});
            final treff = (_privat(r, detektiv)['streifzug'] as Map?)?['treffpunkte'] as Map?;
            if (treff != null && treff.isNotEmpty) senden(detektiv, 'treffen', {'befragung': (treff.keys.toList()..sort()).first});
          }
          befragungenErledigen(s, (typ, d) => senden(detektiv, typ, d));
          senden(leiter, 'weiter');
        case 'entscheidungen':
          if (s['zug'] case final Map zug) {
            switch (zug['phase']) {
              case 'aktion':
                senden(detektiv, 'aktionFertig', {'aktion': zug['aktion']});
              case 'wurf':
                final pate = s['wuerfelPate'] as String;
                if (strategie.chance(0.4)) senden(pate, 'wuerfelHilfe', {'marke': true});
                senden(pate, 'wurf');
              case 'tischruf':
                senden(detektiv, 'tischruf', {'ruf': strategie.chance(0.5) ? 'nochmal' : 'umweg'});
              case 'fund':
                senden(detektiv, 'fundGelesen');
            }
          } else if (s['entscheidung'] case final Map e) {
            final offen = (s['abstecher'] as List).cast<Map>();
            if (offen.isNotEmpty && strategie.chance(0.3)) {
              senden(detektiv, 'abstecher', {'ort': offen.first['id'], 'gruendlich': strategie.chance(0.3)});
            } else {
              final eid = e['id'] as String;
              final optionen = [for (final o in (e['optionen'] as List).cast<Map>()) o['id'] as String];
              final option = wahlen++ % 3 == 2 ? optionen.last : a.ermittlung.entscheidung(eid).richtig[pfad]!;
              senden(detektiv, 'wahl', {'option': option, 'gruendlich': e['suche'] == true && strategie.chance(0.3)});
            }
          } else {
            senden(leiter, 'weiter');
          }
        case 'gruppenwahl':
          for (final (n, t) in (s['spieler'] as List).cast<Map>().indexed) {
            if (t['online'] != true) continue;
            final id = t['id'] as String;
            final privat = _privat(r, id);
            if (privat['rolle'] != null && privat['hatGestimmt'] == false) senden(id, 'stimme', {'kooperativ': (n + runde).isEven});
          }
          senden(leiter, 'weiter');
        case 'anklage' when s['kannWeiter'] != true:
          senden(detektiv, 'anklage', {'person': name.endsWith('falsch') ? a.kanon.kernverdaechtige.firstWhere((k) => k != pfad) : pfad});
        default:
          senden(leiter, 'weiter');
      }
    }
    throw StateError('Raumabend ${a.id}/$name erreicht das Ende nicht');
  }
}

Map<String, Object?> _privat(SchlosskellerRaum r, String id) => (r.zustandFuer(id)['privat'] as Map).cast<String, Object?>();

/// Die Raumabende einer Akte: Gastgeber als Detektiv mit Gast-Erzähler; Gastgeber als Erzähler mit
/// Gast-Detektiv bei voller Besetzung und falscher Anklage; im Schlosskeller dazu der lange Abend.
List<_RaumAbend> _raumAbende(SchnappAkte a) {
  final pfade = a.kanon.pfade;
  return [
    _RaumAbend('detektiv-gastgeber', a, geraete: 5, rollen: a.minRollen < 6 && a.maxRollen >= 6 ? 6 : a.minRollen, detektiv: 'p0', erzaehler: 'p1', pfad: pfade.first),
    _RaumAbend('erzaehler-gastgeber-falsch', a, geraete: 4, rollen: a.maxRollen, detektiv: 'p1', erzaehler: 'p0', pfad: pfade.last),
    if (a.erkundung != null && a.rundgang != null)
      _RaumAbend('lang', a, geraete: 4, rollen: a.minRollen, detektiv: 'p0', erzaehler: 'p1', pfad: pfade[pfade.length > 1 ? 1 : 0], fassung: Abendfassung.lang),
  ];
}
