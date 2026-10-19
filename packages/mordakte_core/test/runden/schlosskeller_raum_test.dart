import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'befragung_treiber.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _erm = Ermittlung(kanon);

SchlosskellerRaum _raum({String pfad = 'ahmet', KartenKatalog? katalog}) => SchlosskellerRaum(
  raumCode: 'ABCD', kanon: kanon, texte: _texte,
  fallCode: FallCode.fuerPfad(pfad, kanon.pfade), salz: 'pruefung-raumsalz-unabhaengig-vom-pfad',
  katalog: katalog,
);

Map<String, Object?> _map(Object? value) => (value as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? value) => [for (final v in value as List) _map(v)];
Map<String, Object?> _oeffentlich(Map<String, Object?> s) => Map.of(s)..remove('privat');

void _befehl(SchlosskellerRaum r, String id, String typ, [Map<String, Object?> daten = const {}]) =>
    r.nachricht(id, {'typ': typ, ...daten});

Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

void _start(SchlosskellerRaum r, int clients, int rollen, {List<String>? vorrat}) {
  for (var i = 0; i < clients; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
    _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
  _befehl(r, 'p0', 'start', {'rollen': rollen, 'vorrat': ?vorrat});
}

/// Sitze eines Testabends: wer „Weiter“ drückt (Erzähler, sonst Detektiv) und wer ermittelt.
typedef _Sitze = ({String leiter, String detektiv, String? erzaehler});
const _sitzeStandard = (leiter: 'p0', detektiv: 'p0', erzaehler: null);

/// Die drei Konstellationen des Online-Abends (M3): Gastgeber p0, Gast p1.
const _konstellationen = <String, ({String detektiv, String? erzaehler})>{
  'Host = Erzähler + Gast = Detektiv': (detektiv: 'p1', erzaehler: 'p0'),
  'Host = Detektiv ohne Erzähler': (detektiv: 'p0', erzaehler: null),
  'Host = Detektiv + Gast = Erzähler': (detektiv: 'p0', erzaehler: 'p1'),
};

/// Startet mit [clients] Geräten (p0 Gastgeber) und den Sitzen [detektiv]/[erzaehler];
/// [klasse] reist mit dem Detektiv-Sitz. Die Sitze werden in der Lobby vergeben.
_Sitze _startMitSitzen(SchlosskellerRaum r, int clients, int rollen, {String detektiv = 'p0', String? erzaehler, String? klasse}) {
  for (var i = 0; i < clients; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
  }
  if (erzaehler != null) _befehl(r, 'p0', 'sitz', {'spieler': erzaehler, 'sitz': 'erzaehler'});
  _befehl(r, 'p0', 'sitz', {'spieler': detektiv, 'sitz': 'detektiv', 'klasse': ?klasse});
  for (var i = 0; i < clients; i++) {
    _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
  _befehl(r, 'p0', 'start', {'rollen': rollen});
  return (leiter: erzaehler ?? detektiv, detektiv: detektiv, erzaehler: erzaehler);
}

/// Treiber benutzt nur Ansichten und Nachrichten, niemals den internen Zustand.
/// Der Detektiv-Sitz ermittelt, der Leiter (Erzähler, sonst Detektiv) geht weiter.
void _schritt(SchlosskellerRaum r, {String pfad = 'ahmet', bool bestesSpiel = true, _Sitze sitze = _sitzeStandard}) {
  final d = sitze.detektiv, l = sitze.leiter;
  final s = r.zustandFuer(d);
  switch (s['phase']) {
    case 'rollen':
      for (final t in _liste(s['spieler'])) {
        if (t['rolle'] != null && t['online'] == true) _befehl(r, t['id'] as String, 'rollenGelesen');
      }
      _befehl(r, l, 'weiter');
    case 'entscheidungen':
      if (s['zug'] case final Map zug) {
        switch (zug['phase']) {
          case 'aktion':
            _befehl(r, d, 'aktionFertig', {'aktion': zug['aktion']});
          case 'wurf':
            _befehl(r, s['wuerfelPate'] as String, 'wurf');
          case 'tischruf':
            _befehl(r, d, 'tischruf', {'ruf': (zug['aktion'] as int).isEven ? 'nochmal' : 'umweg'});
          case 'fund':
            _befehl(r, d, 'fundGelesen');
          default:
            fail('Unbekannter Zugabschnitt');
        }
      } else if (s['entscheidung'] case final Map e) {
        final option = bestesSpiel ? _erm.entscheidung(e['id'] as String).richtig[pfad]! : _liste(e['optionen']).first['id'];
        _befehl(r, d, 'wahl', {'option': option});
      } else {
        _befehl(r, l, 'weiter');
      }
    case 'gespraeche':
      befragungenErledigen(s, (typ, daten) => _befehl(r, d, typ, daten));
      _befehl(r, l, 'weiter');
    case 'gruppenwahl':
      for (final t in _liste(s['spieler'])) {
        final id = t['id'] as String;
        final privat = _map(r.zustandFuer(id)['privat']);
        if (privat['rolle'] != null && privat['hatGestimmt'] == false) _befehl(r, id, 'stimme', {'kooperativ': true});
      }
      _befehl(r, l, 'weiter');
    case 'anklage':
      _befehl(r, d, 'anklage', {'person': pfad});
      _befehl(r, l, 'weiter');
    default:
      _befehl(r, l, 'weiter');
  }
}

void _bis(SchlosskellerRaum r, bool Function(Map<String, Object?>) erreicht) {
  for (var i = 0; i < 400; i++) {
    if (erreicht(r.zustandFuer('p0'))) return;
    _schritt(r);
  }
  fail('Zielzustand nicht erreicht');
}

Iterable<String> _schluessel(Object? wert) sync* {
  if (wert is Map) {
    for (final e in wert.entries) {
      yield e.key.toString();
      yield* _schluessel(e.value);
    }
  } else if (wert is List) {
    for (final e in wert) { yield* _schluessel(e); }
  }
}

void main() {
  test('Identität, Kapazität, Startrechte und unbekannte Felder werden geprüft', () {
    final r = _raum();
    expect(() => r.zustandFuer('fremd'), throwsA(_fehler('not_in_room')));
    expect(r.beitreten('p0', 'Leitung'), isTrue);
    expect(r.beitreten('p1', 'Gast'), isTrue);
    final vorher = r.zustandFuer('p0');
    expect(() => _befehl(r, 'p1', 'start', {'rollen': 4}), throwsA(_fehler('not_host')));
    expect(() => _befehl(r, 'p0', 'start', {'rollen': 4}), throwsA(_fehler('not_ready')));
    expect(() => _befehl(r, 'p1', 'bereit', {'wert': true, 'spieler': 'p0'}), throwsA(_fehler('invalid')));
    expect(r.zustandFuer('p0'), vorher);
    // Kapazität: maxRollen (20) + Detektiv- und Erzähler-Sitz + vier Assistenz-Plätze = 26 Geräte.
    for (var i = 2; i <= 25; i++) { expect(r.beitreten('p$i', 'Person $i'), isTrue); }
    expect(r.beitreten('zu-viel', 'Niemand'), isFalse);
    expect(r.spielerIds, hasLength(26));
  });

  test('4–20 Rollen: jedes Gerät erhält ausschließlich sein eigenes Dossier', () {
    for (final pfad in kanon.pfade) {
      for (var rollen = 4; rollen <= 20; rollen++) {
        final r = _raum(pfad: pfad);
        _start(r, rollen + 1, rollen);
        final publicHost = _oeffentlich(r.zustandFuer('p0'));
        expect(_map(r.zustandFuer('p0')['privat']).containsKey('dossier'), isFalse);
        final gesehen = <String>{};
        for (var i = 1; i <= rollen; i++) {
          final s = r.zustandFuer('p$i');
          expect(_oeffentlich(s), publicHost);
          final privat = _map(s['privat']);
          final rolle = privat['rolle'] as String;
          expect(gesehen.add(rolle), isTrue);
          final dossier = _map(privat['dossier']);
          final soll = _texte.dossier(rolle, pfad, rollen);
          expect(dossier['wer'], soll.wer);
          expect(dossier['verbirgt'], [for (final z in soll.verbirgt) z.text]);
          expect(dossier['tarnung'], soll.tarnung);
          expect(_schluessel(s).where((k) => k == 'dossier'), hasLength(1));
          expect(_schluessel(s).toSet().intersection({'pfad', 'fallCode', 'salz', 'seed', 'richtig', 'qualitaeten', 'taeter'}), isEmpty);
          if (rolle != pfad) expect(jsonEncode(s), isNot(contains(_texte.sammlung.taeter[pfad]!.tarnung)));
        }
        expect(gesehen, _texte.besetzung.besetzt(rollen).toSet());
        expect(r.beitreten('nach-start', 'Neuer Gast'), isFalse);
      }
    }
  });

  test('Altakte (Modell legacy): Bot-Gespräche enthalten nur öffentliche Preisgaben und ersetzen keine getrennten Gäste', () {
    final gk = ladeKanon('gewoelbe');
    final gt = Texte(gk, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/gewoelbe/$p')));
    final r = SchlosskellerRaum(raumCode: 'ABCD', kanon: gk, texte: gt, akte: 'gewoelbe',
        fallCode: FallCode.fuerPfad(gk.pfade.first, gk.pfade), salz: 'pruefung-raumsalz-unabhaengig-vom-pfad');
    _start(r, 2, 4);
    final gastRolle = _map(r.zustandFuer('p1')['privat'])['rolle'];
    for (var i = 0; i < 40 && r.zustandFuer('p0')['phase'] != 'gespraeche'; i++) {
      if (r.zustandFuer('p0')['phase'] == 'rollen') _befehl(r, 'p1', 'rollenGelesen');
      _befehl(r, 'p0', 'weiter');
    }
    expect(r.zustandFuer('p0')['phase'], 'gespraeche');
    expect(r.zustandFuer('p0').containsKey('befragungen'), isFalse, reason: 'Altakten haben kein Befragungsmodul');
    final vorher = _liste(r.zustandFuer('p0')['botGespraeche']);
    final alle = botGespraeche(gt, rollen: 4, runde: 1, mitNpc: true);
    expect(vorher.map((g) => g['id']), alle.where((g) => g.rolle != gastRolle).map((g) => g.id));
    expect(vorher.every((g) => g['rolle'] != gastRolle), isTrue);
    for (final g in vorher) {
      expect(g.keys.toSet(), {'id', 'rolle', 'partner', 'thema', 'text', 'preisgaben'});
      final soll = alle.singleWhere((x) => x.id == g['id']);
      expect(g['preisgaben'], [for (final z in soll.preisgaben) {'quelle': z.quelle, 'text': z.text}]);
    }
    r.verbunden('p1', false);
    expect(r.zustandFuer('p0')['botGespraeche'], vorher);
    r.verlassen('p1');
    expect(_liste(r.zustandFuer('p0')['botGespraeche']).map((g) => g['id']), alle.map((g) => g.id));
  });

  test('Server-Bots benutzen denselben getrennten 70-Prozent-Strom', () {
    final r = _raum();
    _start(r, 1, 4);
    _bis(r, (s) => s['phase'] == 'gruppenwahl');
    final stimmen = {
      for (final rolle in _texte.besetzung.besetzt(4))
        rolle: botKooperativ(salz: 'pruefung-raumsalz-unabhaengig-vom-pfad', rolle: rolle, runde: 1),
    };
    final gruppe = Gruppenwahl(kanon);
    final qualitaet = gruppe.auswerten(rollen: 4,
      kooperativ: stimmen.entries.where((s) => s.key != 'ahmet' && s.value).length,
      taeterSabotiert: stimmen['ahmet'] == false);
    _befehl(r, 'p0', 'weiter');
    final hinweis = gruppe.hinweis('ahmet', 1, qualitaet)['text'];
    // Vorleser-Sitz: Ohne Erzähler liest der Detektiv (p0) den Bonus-Hinweis vor, privat.
    expect(_map(r.zustandFuer('p0')['privat'])['erzaehler'], contains(hinweis));
    expect(r.zustandFuer('p0').containsKey('erzaehler'), isFalse);
  });

  test('Öffentliche Auswahlreihenfolge und Würfe verraten keinen Fall-Code/Pfad', () {
    List<Object?>? soll;
    for (final pfad in kanon.pfade) {
      final r = _raum(pfad: pfad);
      _start(r, 4, 4);
      final verlauf = <Object?>[];
      for (var i = 0; i < 300 && !r.beendet; i++) {
        final s = r.zustandFuer('p0');
        if (s['entscheidung'] case final Map e) verlauf.add({'id': e['id'], 'optionen': e['optionen']});
        if (s['phase'] == 'anklage') {
          verlauf.add(s['wuerfe']);
          break;
        }
        _schritt(r, pfad: pfad, bestesSpiel: false);
      }
      expect(verlauf, hasLength(10)); // neun Entscheidungen und Würfelprotokoll
      if (soll == null) { soll = verlauf; } else { expect(verlauf, soll); }
    }
  });

  test('Reconnect hält Rollenkarte und Salz fest; Gnadenfrist ersetzt keine Stimme', () {
    final r = _raum();
    _start(r, 5, 4);
    final privat = r.zustandFuer('p1')['privat'];
    final zusage = r.wuerfelZusage;
    r.verbunden('p1', false);
    expect(() => r.zustandFuer('p1'), throwsA(_fehler('not_in_room')));
    expect(r.zustandFuer('p0')['kannWeiter'], isFalse);
    r.verbunden('p1', true);
    expect(r.zustandFuer('p1')['privat'], privat);
    expect(r.wuerfelZusage, zusage);
    _bis(r, (s) => s['phase'] == 'gruppenwahl');
    r.verbunden('p1', false);
    for (var i = 2; i <= 4; i++) { _befehl(r, 'p$i', 'stimme', {'kooperativ': true}); }
    expect(r.zustandFuer('p0')['kannWeiter'], isFalse);
    r.verlassen('p1'); // erst nach Ablauf der äußeren Gnadenfrist
    expect(r.zustandFuer('p0')['kannWeiter'], isTrue);
    expect(r.beitreten('p1', 'Zurück'), isTrue);
    expect(_map(r.zustandFuer('p1')['privat'])['rolle'], _map(privat)['rolle']);
    expect(_map(r.zustandFuer('p1')['privat'])['hatGestimmt'], isTrue);
  });

  test('Gast kann weder fremde Stimmen noch Würfelaugen vorgeben', () {
    final r = _raum();
    _start(r, 5, 4);
    _bis(r, (s) => s['phase'] == 'gruppenwahl');
    final vorher = r.zustandFuer('p0');
    expect(() => _befehl(r, 'p1', 'stimme', {'rolle': 'p2', 'kooperativ': true}), throwsA(_fehler('invalid')));
    expect(() => _befehl(r, 'p1', 'weiter'), throwsA(_fehler('not_host')));
    expect(r.zustandFuer('p0'), vorher);
    _befehl(r, 'p1', 'stimme', {'kooperativ': false});
    expect(() => _befehl(r, 'p1', 'stimme', {'kooperativ': true}), throwsA(_fehler('already_voted')));
    for (var i = 2; i <= 4; i++) {
      final s = r.zustandFuer('p$i');
      expect(_map(s['privat'])['hatGestimmt'], isFalse);
      expect(_schluessel(s), isNot(contains('kooperativ')));
      expect(_schluessel(s), isNot(contains('qualitaet')));
    }
  });

  test('Würfelhilfe wird vor dem Wurf in der gemeinsamen Chance sichtbar', () {
    const karte = 'schlosskeller:detektiv:lupe';
    final katalog = KartenKatalog([
      KartenDef(
        id: karte, akte: 'schlosskeller', figur: 'detektiv', seltenheit: Seltenheit.gewoehnlich,
        art: KartenArt.werkzeug, titel: 'Lupe', text: 'Ein Werkzeug aus der Welt.', quellen: [KartenQuelle('start')],
      ),
    ]);
    final r = _raum(katalog: katalog);
    _start(r, 4, 4, vorrat: [karte]);
    _bis(r, (s) => s['runde'] == 2 && s['zug'] is Map && _map(s['zug'])['phase'] == 'wurf');
    var s = r.zustandFuer('p0');
    final pate = s['wuerfelPate'] as String;
    final anderer = pate == 'p0' ? 'p1' : 'p0';
    expect(_liste(s['vorrat']), [{'id': karte, 'art': 'werkzeug', 'rest': 1}]);
    expect(() => _befehl(r, anderer, 'wurf'), throwsA(_fehler('not_dice_player')));
    expect(() => _befehl(r, pate, 'wurf', {'a': 6, 'b': 6}), throwsA(_fehler('invalid')));
    // Der freie Werkzeug-Schalter ist entfernt: Werkzeug kommt nur aus einer Karte des Tisches.
    expect(() => _befehl(r, pate, 'wuerfelHilfe', {'werkzeug': true}), throwsA(_fehler('invalid')));
    expect(() => _befehl(r, pate, 'wuerfelHilfe', {'karte': 'schlosskeller:detektiv:fremd', 'marke': true}),
        throwsA(_fehler('card_unknown')));
    expect(_liste(r.zustandFuer('p0')['vorrat']).single['rest'], 1);
    _befehl(r, pate, 'wuerfelHilfe', {'karte': karte, 'marke': true});
    s = r.zustandFuer('p0');
    final mod = _map(s['zug'])['mod'];
    expect(mod, inInclusiveRange(1, 2));
    for (var i = 1; i < 4; i++) {
      final sicht = _map(r.zustandFuer('p$i')['zug']);
      expect(sicht['chancen'], _map(s['zug'])['chancen']);
      expect(sicht['mod'], mod);
    }
    expect(_liste(s['vorrat']).single['rest'], 1, reason: 'Die Karte wird erst mit dem Wurf verbraucht');
    _befehl(r, pate, 'wurf');
    expect(_map(_map(r.zustandFuer('p0')['zug'])['wurf'])['mod'], mod);
    expect(_liste(r.zustandFuer('p0')['vorrat']).single['rest'], 0);
  });

  test('Veraltete Revision und Animationsrückrufe verändern keinen Zug', () {
    final r = _raum();
    _start(r, 1, 4);
    _bis(r, (s) => s['zug'] is Map);
    var s = r.zustandFuer('p0');
    expect(() => _befehl(r, 'p0', 'aktionFertig', {'aktion': 1, 'revision': (s['version'] as int) - 1}), throwsA(_fehler('stale')));
    expect(r.zustandFuer('p0'), s);
    _befehl(r, 'p0', 'aktionFertig', {'aktion': _map(s['zug'])['aktion']});
    s = r.zustandFuer('p0');
    expect(() => _befehl(r, 'p0', 'aktionFertig', {'aktion': _map(s['zug'])['aktion']}), throwsA(_fehler('stale')));
    expect(r.zustandFuer('p0'), s);
  });

  test('Host-Wechsel überträgt Leitung, niemals die private Rolle des alten Hosts', () {
    final r = _raum();
    _start(r, 5, 4);
    final rolle = _map(r.zustandFuer('p1')['privat'])['rolle'];
    r.verlassen('p0');
    final s = r.zustandFuer('p1');
    expect(s['host'], 'p1');
    expect(_map(s['privat'])['rolle'], rolle);
    expect(_map(s['privat'])['detektiv'], isFalse);
    // M3: Der Detektiv-Sitz wandert nicht mit der Leitung; vorlesen muss aber jemand:
    // Hat der Detektiv aufgegeben, bekommt der neue Gastgeber den Erzähltext.
    expect(() => _befehl(r, 'p1', 'wahl', {'option': 'x'}), throwsA(_fehler('not_detective')));
    expect(r.vorleser, 'p1');
    expect(_map(s['privat'])['vorleser'], isTrue);
    expect(r.beitreten('p0', 'Leitung zurück'), isTrue);
    expect(_map(r.zustandFuer('p0')['privat']).containsKey('dossier'), isFalse);
    expect(r.zustandFuer('p0')['host'], 'p1');
    expect(r.vorleser, 'p0', reason: 'Der Detektiv ist zurück und liest wieder');
  });

  test('Solo/Bots und 4/12/20/21 Geräte: vier Pfade vollständig, eigene Karten, prüfbare Würfe', () {
    for (final pfad in kanon.pfade) {
      for (final clients in [1, 4, 12, 20, 21]) {
        final rollen = (clients - 1).clamp(4, 20);
        final r = _raum(pfad: pfad);
        _start(r, clients, rollen);
        for (var i = 0; i < 400 && !r.beendet; i++) {
          final s = r.zustandFuer('p0');
          if (!['finale', 'aufloesung', 'ende'].contains(s['phase'])) {
            expect(_schluessel(s).toSet().intersection({'pfad', 'fallCode', 'salz', 'seed', 'richtig', 'qualitaeten'}), isEmpty);
          }
          _schritt(r, pfad: pfad);
        }
        expect(r.beendet, isTrue, reason: '$pfad / $clients Geräte');
        final s = r.zustandFuer('p0');
        final aufloesung = _map(s['aufloesung']);
        expect(aufloesung['pfad'], pfad);
        expect(aufloesung['punkte'], 9);
        expect(aufloesung['ende'], 'ende_meister');
        final salz = aufloesung['salz'] as String;
        expect(sha256.convert(utf8.encode(salz)).toString(), s['wuerfelZusage']);
        final quelle = SalzWuerfel(salz);
        for (final w in _liste(s['wuerfe'])) {
          expect(Wurf.werfen(quelle, w['id'] as String, w['anlauf'] as int, w['mod'] as int, garantie: w['garantie'] as bool).toJson(), w);
        }
      }
    }
  });

  group('Sitze und Vorleser-Sitz (M3)', () {
    final npcTexte = {for (final e in _texte.sammlung.bausteine.entries) if (e.key.startsWith('npc.')) e.value};
    for (final MapEntry(key: name, value: k) in _konstellationen.entries) {
      test('$name: ganzer Abend; Erzähltext nur beim Vorleser, Erzählerpaket nur beim Erzähler, Notizen beim Detektiv', () {
        final sitzZahl = k.erzaehler == null ? 1 : 2;
        var notizen = 0;
        for (final pfad in kanon.pfade) {
          for (final clients in [3, 8]) {
            final rollen = (clients - sitzZahl).clamp(4, 20);
            final r = _raum(pfad: pfad);
            final sitze = _startMitSitzen(r, clients, rollen, detektiv: k.detektiv, erzaehler: k.erzaehler);
            final ids = [for (var i = 0; i < clients; i++) 'p$i'];
            final vorleser = k.erzaehler ?? k.detektiv;
            final geheim = <String>{
              for (final rolle in _texte.besetzung.besetzt(rollen)) ...[
                for (final z in _texte.dossier(rolle, pfad, rollen).verbirgt) z.text,
                for (final z in _texte.dossier(rolle, pfad, rollen).tatwissen) z.text,
                ?_texte.dossier(rolle, pfad, rollen).tarnung,
              ],
            };
            final vorgelesen = <String>{};
            final vorFinale = <String, List<Map<String, Object?>>>{for (final id in ids) id: []};
            var pakete = 0;
            for (var i = 0; i < 400 && !r.beendet; i++) {
              final alle = {for (final id in ids) id: r.zustandFuer(id)};
              final oeffentlich = jsonEncode(_oeffentlich(alle['p0']!));
              for (final MapEntry(key: id, value: v) in alle.entries) {
                final privat = _map(v['privat']);
                final grund = '$name/$pfad/$clients/$id/${v['phase']}';
                expect(jsonEncode(_oeffentlich(v)), oeffentlich, reason: '$grund: öffentlicher Teil für alle gleich');
                expect(privat['detektiv'], id == k.detektiv, reason: grund);
                expect(privat.containsKey('erzaehlerPaket'), id == k.erzaehler, reason: grund);
                expect(privat.containsKey('erzaehlerNotizen'), id == k.detektiv, reason: grund);
                if (id == k.detektiv || id == k.erzaehler) expect(privat.keys.toSet().intersection({'rolle', 'dossier'}), isEmpty, reason: grund);
                if (privat['erzaehlerNotizen'] case final List n) {
                  expect(npcTexte.containsAll(n), isTrue, reason: '$grund: Notizen sind nur npc-Wissen');
                  notizen += n.length;
                }
                if (privat['erzaehlerPaket'] case final Map paket) {
                  final soll = erzaehlerPaket(_texte, Befragungsplan(_texte), n: rollen, runde: (v['runde'] as int).clamp(1, 3)).toJson();
                  expect(jsonEncode(paket), jsonEncode(soll), reason: grund);
                  pakete++;
                }
                if (id == k.erzaehler) {
                  expect(_schluessel(v).toSet().intersection({'dossier', 'verbirgt', 'tatwissen', 'tarnung'}), isEmpty, reason: grund);
                }
                expect(v['wuerfelPate'], isNot(k.erzaehler ?? '-'), reason: '$grund: Der Erzähler würfelt nie');
                if (['finale', 'aufloesung', 'ende'].contains(v['phase'])) {
                  // Nach dem Finale dürfen alle die Auflösungstexte sehen.
                  expect(v['erzaehler'], _map(alle[vorleser]!['privat'])['erzaehler'], reason: grund);
                  continue;
                }
                vorFinale[id]!.add(v);
                expect(v.containsKey('erzaehler'), isFalse, reason: '$grund: kein öffentlicher Erzähltext');
                expect(v['erzaehlerLiest'], (v['bausteinZahl'] as int) > 0, reason: grund);
                if (id == vorleser) {
                  final texte = (privat['erzaehler'] as List).cast<String>();
                  expect([texte.length, privat['vorleser']], [v['bausteinZahl'], true], reason: grund);
                  vorgelesen.addAll(texte);
                } else {
                  expect(privat.keys.toSet().intersection({'erzaehler', 'vorleser'}), isEmpty, reason: grund);
                }
              }
              _schritt(r, pfad: pfad, sitze: sitze);
            }
            expect(r.beendet, isTrue, reason: '$name/$pfad/$clients');
            final aufloesung = _map(r.zustandFuer('p0')['aufloesung']);
            expect([aufloesung['pfad'], aufloesung['punkte'], aufloesung['ende']], [pfad, 9, 'ende_meister']);
            expect(vorgelesen, isNotEmpty);
            expect(pakete, k.erzaehler == null ? 0 : greaterThan(0));
            for (final id in ids) {
              for (final v in vorFinale[id]!) {
                final privat = Map.of(_map(v['privat']))..remove('erzaehlerNotizen');
                final text = jsonEncode({...v, 'privat': privat});
                if (id != vorleser) {
                  for (final t in vorgelesen) {
                    expect(text.contains(jsonEncode(t)), isFalse, reason: '$name/$pfad/$id sieht Erzähltext vor dem Finale: $t');
                  }
                }
                if (id == k.erzaehler) {
                  // Öffentlich ist für alle gleich (oben geprüft; Funde dürfen dort stehen). Was nur der
                  // Erzähler bekommt, enthält nie verbirgt, Tatwissen oder Tarnung.
                  final nurErzaehler = jsonEncode(privat);
                  for (final t in geheim) {
                    expect(nurErzaehler.contains(t), isFalse, reason: '$name/$pfad: Erzähler sieht verbirgt/Tatwissen/Tarnung: $t');
                  }
                }
              }
            }
          }
        }
        expect(notizen, greaterThan(0), reason: 'Der Detektiv hat npc-Wissen notiert');
      });
    }

    test('Ohne Erzähler bekommt nur der Detektiv den Erzähltext', () {
      final r = _raum();
      final sitze = _startMitSitzen(r, 4, 4);
      _bis(r, (s) => s['phase'] == 'gespraeche');
      expect(r.vorleser, 'p0');
      final texte = _map(r.zustandFuer('p0')['privat'])['erzaehler'] as List;
      expect(texte, isNotEmpty);
      for (final id in ['p1', 'p2', 'p3']) {
        final v = r.zustandFuer(id);
        expect([v['erzaehlerLiest'], v['bausteinZahl'], v.containsKey('erzaehler'), _map(v['privat']).containsKey('erzaehler')],
            [true, texte.length, false, false], reason: id);
      }
      expect(sitze.leiter, 'p0');
    });

    test('Gast-Detektiv darf wahl und ermitteln; andere Gäste und der Erzähler-Gastgeber nicht', () {
      final r = _raum();
      final sitze = _startMitSitzen(r, 4, 4, detektiv: 'p1', erzaehler: 'p0');
      for (var i = 0; i < 400; i++) {
        final s = r.zustandFuer('p1');
        if (s['phase'] == 'entscheidungen' && s['entscheidung'] is Map && s['zug'] == null) break;
        _schritt(r, sitze: sitze);
      }
      final e = _map(r.zustandFuer('p1')['entscheidung']);
      final option = _erm.entscheidung(e['id'] as String).richtig['ahmet']!;
      final vorher = r.zustandFuer('p0');
      for (final id in ['p0', 'p2', 'p3']) {
        expect(() => _befehl(r, id, 'wahl', {'option': option}), throwsA(_fehler('not_detective')), reason: id);
        expect(() => _befehl(r, id, 'anklage', {'person': 'ahmet'}), throwsA(_fehler('not_detective')), reason: id);
        expect(() => _befehl(r, id, 'karte', {'id': 'x'}), throwsA(_fehler('not_detective')), reason: id);
        expect(() => _befehl(r, id, 'abstecher', {'ort': 'x'}), throwsA(_fehler('not_detective')), reason: id);
        expect(() => _befehl(r, id, 'fundGelesen'), throwsA(_fehler('not_detective')), reason: id);
      }
      // Der Gast-Detektiv geht nicht weiter, solange ein Erzähler da ist; eine Rolle nie.
      expect(() => _befehl(r, 'p1', 'weiter'), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, 'p2', 'weiter'), throwsA(_fehler('not_host')));
      expect(r.zustandFuer('p0'), vorher);
      _befehl(r, 'p1', 'wahl', {'option': option});
      // Den Lauf meldet die Karte des Detektivs, ersatzweise der Gastgeber; die Nummer verhindert Doppelte.
      final zug = _map(r.zustandFuer('p1')['zug']);
      expect(zug['phase'], 'aktion');
      expect(() => _befehl(r, 'p2', 'aktionFertig', {'aktion': zug['aktion']}), throwsA(_fehler('not_detective')));
      _befehl(r, 'p0', 'aktionFertig', {'aktion': zug['aktion']});
      expect(() => _befehl(r, 'p1', 'aktionFertig', {'aktion': zug['aktion']}), throwsA(_fehler('stale')));
    });

    test('Befragungen nur vom Detektiv-Sitz, auch wenn er ein Gast ist', () {
      final r = _raum();
      final sitze = _startMitSitzen(r, 4, 4, detektiv: 'p1', erzaehler: 'p0');
      _bis(r, (s) => s['phase'] == 'gespraeche');
      final karten = _liste(_map(r.zustandFuer('p1')['privat'])['befragungen']);
      expect(karten, isNotEmpty);
      expect(_map(r.zustandFuer('p0')['privat']).containsKey('befragungen'), isFalse, reason: 'Der Erzähler-Gastgeber hat keine Detektivkarten');
      expect(() => _befehl(r, 'p0', 'befragen', {'id': karten.first['id'], 'frage': 0}), throwsA(_fehler('not_detective')));
      _befehl(r, 'p1', 'befragen', {'id': karten.first['id'], 'frage': 0});
      befragungenErledigen(r.zustandFuer('p1'), (typ, d) => _befehl(r, 'p1', typ, d));
      _befehl(r, sitze.leiter, 'weiter');
      expect(r.zustandFuer('p0')['phase'], 'entscheidungen');
    });

    test('Fällt der Erzähler aus, darf der Gastgeber leiten; gibt er auf, liest der Detektiv', () {
      final r = _raum();
      _startMitSitzen(r, 4, 4, erzaehler: 'p1');
      for (final id in ['p2', 'p3']) {
        if (r.rolleVon(id) != null) _befehl(r, id, 'rollenGelesen');
      }
      expect(() => _befehl(r, 'p0', 'weiter'), throwsA(_fehler('not_host')), reason: 'Der Erzähler ist da');
      r.verbunden('p1', false);
      _befehl(r, 'p0', 'weiter');
      expect(r.zustandFuer('p0')['phase'], isNot('rollen'));
      expect(r.vorleser, 'p1', reason: 'Offline heißt nicht aufgegeben');
      r.verbunden('p1', true);
      expect(() => _befehl(r, 'p0', 'weiter'), throwsA(_fehler('not_host')));
      _befehl(r, 'p1', 'weiter');
      r.verlassen('p1');
      expect(r.vorleser, 'p0');
      expect(_map(r.zustandFuer('p0')['privat'])['vorleser'], isTrue);
      befragungenErledigen(r.zustandFuer('p0'), (typ, d) => _befehl(r, 'p0', typ, d));
      _befehl(r, 'p0', 'weiter');
      expect(r.zustandFuer('p0')['phase'], 'entscheidungen');
    });

    test('Der Erzähler würfelt und stimmt nie; Würfelpaten sind die übrigen Geräte', () {
      final r = _raum();
      final sitze = _startMitSitzen(r, 4, 4, detektiv: 'p1', erzaehler: 'p0');
      final paten = <String>{};
      for (var i = 0; i < 400 && !r.beendet; i++) {
        final s = r.zustandFuer('p1');
        if (s['wuerfelPate'] case final String pate) paten.add(pate);
        if (s['phase'] == 'gruppenwahl') {
          expect(() => _befehl(r, 'p0', 'stimme', {'kooperativ': true}), throwsA(_fehler('invalid_phase')));
          expect(() => _befehl(r, 'p1', 'stimme', {'kooperativ': true}), throwsA(_fehler('invalid_phase')));
        }
        _schritt(r, sitze: sitze);
      }
      expect(r.beendet, isTrue);
      expect(paten, {'p1', 'p2', 'p3'});
    });

    test('E-044: Der Detektiv-Sitz behält das npc-Wissen als Notiz, auch wenn der Erzähler vorliest', () {
      final r = _raum();
      final sitze = _startMitSitzen(r, 3, 4, detektiv: 'p1', erzaehler: 'p0');
      _bis(r, (s) => s['phase'] == 'gespraeche');
      final erzaehlt = (_map(r.zustandFuer('p0')['privat'])['erzaehler'] as List).cast<String>();
      final soll = [for (final k in ['npc.emine.1', 'npc.dilara.1', 'npc.enes.1']) _texte.baustein(k)];
      expect(erzaehlt, containsAll(soll));
      final detektiv = _map(r.zustandFuer('p1')['privat']);
      expect(detektiv.containsKey('erzaehler'), isFalse);
      expect(detektiv['erzaehlerNotizen'], soll);
      // Die Notiz bleibt über die Runde hinaus; die Ansicht des Erzählers trägt sie nur im Fenster.
      befragungenErledigen(r.zustandFuer('p1'), (typ, d) => _befehl(r, 'p1', typ, d));
      _befehl(r, sitze.leiter, 'weiter');
      expect(_map(r.zustandFuer('p1')['privat'])['erzaehlerNotizen'], soll);
      expect(_map(r.zustandFuer('p0')['privat'])['erzaehler'], isNot(containsAll(soll)));
      // Altakte: keine Notizen, kein Paket (E-044 gilt nur im Modell befragung).
      final gk = ladeKanon('gewoelbe');
      final gt = Texte(gk, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/gewoelbe/$p')));
      final g = SchlosskellerRaum(raumCode: 'ABCD', kanon: gk, texte: gt, akte: 'gewoelbe',
          fallCode: FallCode.fuerPfad(gk.pfade.first, gk.pfade), salz: 'pruefung-raumsalz-unabhaengig-vom-pfad');
      _startMitSitzen(g, 3, 4, detektiv: 'p1', erzaehler: 'p0');
      expect(_map(g.zustandFuer('p1')['privat']).containsKey('erzaehlerNotizen'), isFalse);
      expect(_map(g.zustandFuer('p0')['privat']).containsKey('erzaehlerPaket'), isFalse);
    });

    test('Die Klasse des Detektiv-Sitzes ändert den Abend nicht (Invarianz)', () {
      // Alles außer der Klasse selbst: jede Ansicht jedes Geräts, Schritt für Schritt.
      List<String> abend(String? klasse, String detektiv, String? erzaehler) {
        final r = _raum(pfad: 'fatma');
        final sitze = _startMitSitzen(r, 4, 4, detektiv: detektiv, erzaehler: erzaehler, klasse: klasse);
        final verlauf = <String>[];
        for (var i = 0; i < 400 && !r.beendet; i++) {
          for (var g = 0; g < 4; g++) {
            final v = r.zustandFuer('p$g');
            final privat = Map.of(_map(v['privat']));
            expect(privat.remove('klasse'), g == 0 || 'p$g' == detektiv ? klasse : null, reason: 'p$g sieht die Klasse');
            verlauf.add(jsonEncode({...v, 'privat': privat}));
          }
          _schritt(r, pfad: 'fatma', bestesSpiel: false, sitze: sitze);
        }
        expect(r.beendet, isTrue);
        return verlauf;
      }

      for (final (detektiv, erzaehler) in [('p1', 'p0'), ('p0', null)]) {
        final ohne = abend(null, detektiv, erzaehler);
        for (final f in KlassenFaehigkeit.values) {
          expect(abend(f.klasse, detektiv, erzaehler), ohne, reason: '${f.klasse} / Detektiv $detektiv');
        }
      }
    });
  });
}
