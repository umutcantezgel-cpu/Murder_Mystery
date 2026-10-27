// „Dein Moment“ im Online-Abend (Finale §3.1, §3.2, §3.12, §3.14): Nachrichten `zug`, `letzterAufruf` und
// `nachfrage`, ihre festen Fehlercodes, Ändern bis zu den Folgen, die Frist nach dem letzten Aufruf (Abendzeit
// vom Transport, keine Wanduhr), Bot-Ersatz für getrennte Plätze, Privatsphäre der Ansichten (Lauschergebnis
// nur beim Lauscher, Zug-Tafel nur beim Erzähler, nie Pfad, Tipps oder Zählwerte vor dem Finale) und das
// Wiedereinspielen aus dem Nachrichtenprotokoll. Der Treiber nutzt nur Ansichten und Nachrichten.
@TestOn('vm')
library;

import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'befragung_treiber.dart';
import 'einfluss_hilfe.dart';

final _texte = einflussTexte();
const _salz = 'moment-raumsalz-unabhaengig-vom-pfad';

final _erkundung = Erkundung.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/erkundung.json'));
final _rundgang = VorspielMorgen.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/vorspiel_morgen.json'));

/// Raum mit Schicht; im langen Abend wie beim Gastgeber mit Diashow, Streifzug sowie Vorspiel und Morgen.
SchlosskellerRaum _raum({String pfad = 'ahmet', bool schicht = true, Abendfassung fassung = Abendfassung.kurz}) => SchlosskellerRaum(
      raumCode: 'MOMT', kanon: kanon, texte: _texte, fallCode: FallCode.fuerPfad(pfad, kanon.pfade), salz: _salz,
      fassung: fassung, einfluss: schicht ? einflussRegeln : null,
      diaAnzahl: fassung.istLang ? 6 : 0, erkundung: fassung.istLang ? _erkundung : null, rundgang: fassung.istLang ? _rundgang : null,
    );

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? v) => [for (final x in v as List) _map(x)];
Map<String, Object?> _privat(AbendRaum r, String id) => _map(r.zustandFuer(id)['privat']);
Map<String, Object?> _oeffentlich(Map<String, Object?> s) => Map.of(s)..remove('privat');

void _befehl(AbendRaum r, String id, String typ, [Map<String, Object?> daten = const {}]) => r.nachricht(id, {'typ': typ, ...daten});

Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

Iterable<String> _schluessel(Object? v) sync* {
  if (v is Map) {
    for (final e in v.entries) {
      yield e.key.toString();
      yield* _schluessel(e.value);
    }
  } else if (v is List) {
    for (final x in v) {
      yield* _schluessel(x);
    }
  }
}

/// [geraete] Geräte: p0 Gastgeber und Erzähler, p1 Detektiv, die übrigen spielen Figuren; [rollen] Rollen.
void _start(AbendRaum r, {int geraete = 6, int rollen = 4}) {
  for (var i = 0; i < geraete; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
  }
  _befehl(r, 'p0', 'sitz', {'spieler': 'p0', 'sitz': 'erzaehler'});
  _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'detektiv'});
  for (var i = 0; i < geraete; i++) {
    _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
  _befehl(r, 'p0', 'start', {'rollen': rollen});
}

/// Geräte mit Figur (aus der Ansicht des Gastgebers, verbunden).
List<String> _figurGeraete(AbendRaum r) => [
      for (final t in _liste(r.zustandFuer('p0')['spieler']))
        if (t['rolle'] != null && t['online'] == true) t['id'] as String,
    ];

/// Zug einer Rolle aus ihrer eigenen Ansicht `moment`: Art und Ziel reihum über das Erlaubte; in der
/// Tipp-Runde dazu ein Tipp. Runde 1 fest: das erste Gerät lauscht beim zweiten.
typedef _Zugwahl = Map<String, Object?>? Function(String geraet, int index, Map<String, Object?> moment);

Map<String, Object?>? _reihum(String geraet, int i, Map<String, Object?> m) {
  final runde = m['runde'] as int;
  final arten = (m['arten'] as List).cast<String>();
  final ziele = _map(m['ziele']);
  final art = arten[(i + runde) % arten.length];
  final moegliche = (ziele[art] as List?)?.cast<String>();
  return {
    'art': art,
    if (moegliche != null) 'ziel': moegliche[(i * 3 + runde) % moegliche.length],
    if (m['tipps'] case final List t) 'tipp': t[i % t.length],
  };
}

/// Ein Schritt nur über Ansichten und Nachrichten. Leiter p0 (Erzähler), Detektiv p1; Wahl: die erste
/// angebotene Option (die Reihenfolge hängt nur am Salz). [zuege] wählt die Züge der Figuren-Geräte.
void _schritt(AbendRaum r, {_Zugwahl zuege = _reihum, String anklage = 'ahmet'}) {
  final s = r.zustandFuer('p1');
  // Vorspiel und Morgen (langer Abend): Der Erzähler geht die Stationen ab.
  if (s['rundgang'] case final Map g) {
    _befehl(r, 'p0', 'rundgang', {'station': g['station']});
    return;
  }
  switch (s['phase']) {
    case 'rollen':
      for (final id in _figurGeraete(r)) {
        _befehl(r, id, 'rollenGelesen');
      }
      _befehl(r, 'p0', 'weiter');
    case 'gespraeche':
      for (final (i, id) in _figurGeraete(r).indexed) {
        final m = _map(_privat(r, id)['moment']);
        if (m['offen'] != true || m['zug'] != null) continue;
        if (zuege(id, i, m) case final z?) _befehl(r, id, 'zug', z);
      }
      befragungenErledigen(s, (typ, daten) => _befehl(r, 'p1', typ, daten));
      _befehl(r, 'p0', 'weiter');
    case 'entscheidungen':
      if (s['zug'] case final Map zug) {
        switch (zug['phase']) {
          case 'aktion':
            _befehl(r, 'p1', 'aktionFertig', {'aktion': zug['aktion']});
          case 'wurf':
            _befehl(r, s['wuerfelPate'] as String, 'wurf');
          case 'tischruf':
            _befehl(r, 'p1', 'tischruf', {'ruf': (zug['aktion'] as int).isEven ? 'nochmal' : 'umweg'});
          case 'fund':
            _befehl(r, 'p1', 'fundGelesen');
        }
      } else if (s['entscheidung'] case final Map e) {
        _befehl(r, 'p1', 'wahl', {'option': _liste(e['optionen']).first['id']});
      } else {
        _befehl(r, 'p0', 'weiter');
      }
    case 'anklage':
      final n = _map(_map(s['einfluss'])['nachfragen']);
      if ((n['offen'] as int) > 0 && (n['optionen'] as List).isNotEmpty) {
        _befehl(r, 'p1', 'nachfrage', {'option': (n['optionen'] as List).first});
      } else {
        _befehl(r, 'p1', 'anklage', {'person': anklage});
        _befehl(r, 'p0', 'weiter');
      }
    default:
      _befehl(r, 'p0', 'weiter');
  }
}

void _bis(AbendRaum r, bool Function(Map<String, Object?> s) erreicht, {_Zugwahl zuege = _reihum, void Function()? jeSchritt}) {
  for (var i = 0; i < 500; i++) {
    if (erreicht(r.zustandFuer('p0'))) return;
    _schritt(r, zuege: zuege);
    jeSchritt?.call();
  }
  fail('Zielzustand nicht erreicht');
}

bool _gespraeche(Map<String, Object?> s, int runde) => s['phase'] == 'gespraeche' && s['runde'] == runde;

void main() {
  group('Ohne Schicht', () {
    test('zug, letzterAufruf und nachfrage sind unbekannt (invalid), kein Schlüssel einfluss', () {
      final r = _raum(schicht: false);
      _start(r);
      _bis(r, (s) => _gespraeche(s, 1));
      final rolle = _figurGeraete(r).first;
      expect(() => _befehl(r, rolle, 'zug', {'art': 'helfen'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'letzterAufruf', {'zeit': 5}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p1', 'nachfrage', {'option': 'e1_1_joanna'}), throwsA(_fehler('invalid')));
      for (var i = 0; i < 6; i++) {
        final v = r.zustandFuer('p$i');
        expect(v.containsKey('einfluss'), isFalse);
        expect(_map(v['privat']).keys, isNot(anyOf(contains('moment'), contains('einflussTafel'))));
      }
    });
  });

  group('Nachrichten und Fehlercodes', () {
    test('zug nur in den Gesprächen und nur von Geräten mit Figur; unzulässige Züge sind invalid', () {
      final r = _raum();
      // 21 Gäste bei 20 Rollen: einer sitzt ohne Figur am Tisch (Assistenz).
      _start(r, geraete: 23, rollen: 20);
      final figuren = _figurGeraete(r);
      final assistenz = [for (final t in _liste(r.zustandFuer('p0')['spieler'])) if (t['sitz'] == 'assistenz') t['id'] as String];
      expect(figuren, hasLength(20));
      expect(assistenz, hasLength(1));
      final a = figuren[0], b = figuren[1];
      final rolleA = r.rolleVon(a)!, rolleB = r.rolleVon(b)!;
      // Vor den Gesprächen: invalid_phase (Rollen lesen).
      expect(() => _befehl(r, a, 'zug', {'art': 'helfen'}), throwsA(_fehler('invalid_phase')));
      _bis(r, (s) => _gespraeche(s, 1));
      for (final ohne in ['p0', 'p1', ...assistenz]) {
        expect(() => _befehl(r, ohne, 'zug', {'art': 'helfen'}), throwsA(_fehler('invalid')), reason: ohne);
      }
      for (final falsch in <Map<String, Object?>>[
        {'art': 'zaubern'},
        {'art': 'zeigen'},
        {'art': 'zeigen', 'ziel': rolleA},
        {'art': 'decken', 'ziel': 'niemand'},
        {'art': 'helfen', 'ziel': rolleB},
        {'art': 'helfen', 'tipp': 'ahmet'},
        {'art': 'helfen', 'ziel': 7},
        {'art': 'helfen', 'fremd': 1},
        {'art': 'lauschen', 'ziel': rolleA},
      ]) {
        expect(() => _befehl(r, a, 'zug', falsch), throwsA(_fehler('invalid')), reason: '$falsch');
      }
      final vorher = r.zustandFuer(a);
      expect(_map(_map(vorher['privat'])['moment']).containsKey('zug'), isFalse, reason: 'Abgelehnte Züge ändern nichts');
      // Letzter Aufruf: nur wer leitet, nur mit Abendzeit; Nachfrage: nur der Detektiv, erst nach Runde 3.
      expect(() => _befehl(r, 'p1', 'letzterAufruf', {'zeit': 1}), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, a, 'letzterAufruf', {'zeit': 1}), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, 'p0', 'letzterAufruf'), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, a, 'nachfrage', {'option': 'e1_1_joanna'}), throwsA(_fehler('not_detective')));
      expect(() => _befehl(r, 'p1', 'nachfrage', {'option': 'e1_1_joanna'}), throwsA(_fehler('invalid_phase')));
      // Weiter erst, wenn alle Menschen gezogen haben.
      befragungenErledigen(r.zustandFuer('p1'), (typ, daten) => _befehl(r, 'p1', typ, daten));
      expect(r.zustandFuer('p0')['kannWeiter'], isFalse);
      expect(() => _befehl(r, 'p0', 'weiter'), throwsA(_fehler('not_ready')));
      for (final id in figuren) {
        _befehl(r, id, 'zug', {'art': 'helfen'});
      }
      expect(r.zustandFuer('p0')['kannWeiter'], isTrue);
      _befehl(r, 'p0', 'weiter');
      expect(r.zustandFuer('p0')['phase'], 'entscheidungen');
      expect(() => _befehl(r, a, 'zug', {'art': 'ablenken'}), throwsA(_fehler('invalid_phase')), reason: 'nach den Folgen fest');
      expect(() => _befehl(r, 'p0', 'letzterAufruf', {'zeit': 1}), throwsA(_fehler('invalid_phase')));
    });

    test('änderbar bis zu den Folgen; öffentlich nur, wer gezogen hat, nie was', () {
      final r = _raum();
      _start(r);
      _bis(r, (s) => _gespraeche(s, 1));
      final figuren = _figurGeraete(r);
      final a = figuren[0], b = figuren[1];
      final rolleA = r.rolleVon(a)!, rolleB = r.rolleVon(b)!;
      expect(_map(r.zustandFuer('p0')['einfluss'])['gezogen'], isEmpty);
      _befehl(r, a, 'zug', {'art': 'zeigen', 'ziel': rolleB});
      _befehl(r, a, 'zug', {'art': 'decken', 'ziel': rolleB});
      final moment = _map(_privat(r, a)['moment']);
      expect(moment['zug'], {'art': 'decken', 'ziel': rolleB});
      expect(moment['offen'], isTrue);
      expect(moment['arten'], containsAll(['zeigen', 'decken', 'helfen', 'ablenken', 'lauschen']));
      expect(_map(moment['ziele'])['decken'], contains(rolleA), reason: 'decken auch sich selbst');
      expect(_map(moment['ziele'])['zeigen'], isNot(contains(rolleA)));
      expect(moment.containsKey('tipps'), isFalse, reason: 'Tipp erst in Runde 3');
      for (var i = 0; i < 6; i++) {
        final v = r.zustandFuer('p$i');
        final e = _map(v['einfluss']);
        expect(e['gezogen'], [rolleA]);
        expect(jsonEncode(_oeffentlich(v)), isNot(contains('decken')), reason: 'nie die Art');
        if (_map(v['privat'])['moment'] case final Map m when 'p$i' != a) expect(m['zug'], isNull, reason: 'p$i');
      }
      // Der Erzähler sieht die Tafel der laufenden Runde; sonst niemand.
      final tafel = _map(_privat(r, 'p0')['einflussTafel']);
      expect(tafel, {'runde': 1, 'ausgewertet': false, 'zuege': [{'rolle': rolleA, 'art': 'decken', 'ziel': rolleB}]});
      for (var i = 1; i < 6; i++) {
        expect(_privat(r, 'p$i').containsKey('einflussTafel'), isFalse);
      }
    });

    test('letzter Aufruf: Weiter erst nach 60 s Abendzeit, wer fehlt, hat abgewartet', () {
      final r = _raum();
      _start(r);
      _bis(r, (s) => _gespraeche(s, 1));
      final figuren = _figurGeraete(r);
      _befehl(r, figuren[0], 'zug', {'art': 'helfen'});
      befragungenErledigen(r.zustandFuer('p1'), (typ, daten) => _befehl(r, 'p1', typ, daten));
      expect(r.zustandFuer('p0')['kannWeiter'], isFalse);
      _befehl(r, 'p0', 'letzterAufruf', {'zeit': 10000});
      _befehl(r, 'p0', 'letzterAufruf', {'zeit': 30000});
      final e = _map(r.zustandFuer('p2')['einfluss']);
      expect(e['aufruf'], 10000, reason: 'der erste Aufruf zählt');
      expect(r.zustandFuer('p0')['kannWeiter'], isTrue, reason: 'die Frist rechnet das Gerät');
      expect(() => _befehl(r, 'p0', 'weiter'), throwsA(_fehler('not_ready')), reason: 'ohne Abendzeit');
      expect(() => _befehl(r, 'p0', 'weiter', {'zeit': 10000 + momentAufrufFrist - 1}), throwsA(_fehler('not_ready')));
      _befehl(r, 'p0', 'weiter', {'zeit': 10000 + momentAufrufFrist});
      final tafel = _liste(_map(_privat(r, 'p0')['einflussTafel'])['zuege']);
      for (final id in figuren.skip(1)) {
        expect(tafel.firstWhere((z) => z['rolle'] == r.rolleVon(id)), {'rolle': r.rolleVon(id), 'art': 'abgewartet'}, reason: 'Mensch ohne Zug');
      }
      expect(tafel.firstWhere((z) => z['rolle'] == r.rolleVon(figuren[0]))['art'], 'helfen');
      expect(_map(r.zustandFuer('p2')['einfluss']).containsKey('aufruf'), isFalse);
      // In der nächsten Runde gilt der alte Aufruf nicht mehr.
      _bis(r, (s) => _gespraeche(s, 2), zuege: (_, _, _) => null);
      expect(_map(r.zustandFuer('p0')['einfluss']).containsKey('aufruf'), isFalse);
      befragungenErledigen(r.zustandFuer('p1'), (typ, daten) => _befehl(r, 'p1', typ, daten));
      expect(() => _befehl(r, 'p0', 'weiter', {'zeit': 999999}), throwsA(_fehler('not_ready')));
    });

    test('Bot-Ersatz: ein getrennter Platz bremst, bis der Transport ihn nach seiner Frist herausnimmt; dann zieht der Bot', () {
      final r = _raum();
      _start(r, geraete: 5, rollen: 5);
      _bis(r, (s) => _gespraeche(s, 1));
      final figuren = _figurGeraete(r);
      expect(figuren, hasLength(3));
      final weg = figuren.last;
      final rolleWeg = r.rolleVon(weg)!;
      for (final id in figuren.take(2)) {
        _befehl(r, id, 'zug', {'art': 'helfen'});
      }
      befragungenErledigen(r.zustandFuer('p1'), (typ, daten) => _befehl(r, 'p1', typ, daten));
      expect(r.zustandFuer('p0')['kannWeiter'], isFalse);
      r.verbunden(weg, false);
      expect(r.zustandFuer('p0')['kannWeiter'], isFalse, reason: 'innerhalb der Frist bleibt der Platz menschlich');
      r.verlassen(weg); // nach zwei Minuten (Server und Relais)
      expect(r.zustandFuer('p0')['kannWeiter'], isTrue);
      _befehl(r, 'p0', 'weiter');
      final tafel = _liste(_map(_privat(r, 'p0')['einflussTafel'])['zuege']);
      final bots = {for (final z in tafel) if (z['bot'] == true) z['rolle']};
      final unbesetzt = [for (final b in Besetzung(kanon).besetzt(5)) if (!figuren.map(r.rolleVon).contains(b)) b];
      expect(bots, {...unbesetzt, rolleWeg}, reason: 'die Rolle ohne Gerät und der getrennte Platz ziehen als Bot');
      expect(tafel.firstWhere((z) => z['rolle'] == rolleWeg)['art'], isNot('abgewartet'));
      // Ein Zug, den der Mensch noch selbst gesetzt hatte, bliebe: Runde 2 zieht er vor dem Gehen.
    });

    test('Bot-Ersatz behält einen schon gesetzten Zug', () {
      final r = _raum();
      _start(r, geraete: 5, rollen: 5);
      _bis(r, (s) => _gespraeche(s, 1));
      final figuren = _figurGeraete(r);
      final weg = figuren.last;
      for (final id in figuren) {
        _befehl(r, id, 'zug', {'art': id == weg ? 'ablenken' : 'helfen'});
      }
      r.verbunden(weg, false);
      r.verlassen(weg);
      befragungenErledigen(r.zustandFuer('p1'), (typ, daten) => _befehl(r, 'p1', typ, daten));
      _befehl(r, 'p0', 'weiter');
      final z = _liste(_map(_privat(r, 'p0')['einflussTafel'])['zuege']).firstWhere((z) => z['rolle'] == r.rolleVon(weg));
      expect(z, {'rolle': r.rolleVon(weg), 'art': 'ablenken'});
      expect(_liste(_map(r.zustandFuer('p0')['einfluss'])['folgen']).single['ablenker'], contains(r.rolleVon(weg)));
    });
  });

  group('Privatsphäre', () {
    test('Lauschergebnis nur beim Lauscher, Tafel nur beim Erzähler, nie Pfad, Tipps oder Zählwerte vor dem Finale', () {
      final r = _raum(pfad: 'fatma');
      _start(r, geraete: 6, rollen: 6);
      final figuren = _figurGeraete(r);
      final lauscher = figuren[0], belauscht = figuren[1];
      final rolleB = r.rolleVon(belauscht)!;
      final ansichten = <String, List<Map<String, Object?>>>{for (var i = 0; i < 6; i++) 'p$i': []};
      void merke() {
        for (final id in ansichten.keys) {
          ansichten[id]!.add(r.zustandFuer(id));
        }
      }

      // Nur das erste Gerät lauscht (Runde 1); sonst reihum, Lauschen wird zu Helfen.
      Map<String, Object?>? zuege(String g, int i, Map<String, Object?> m) => switch ((m['runde'], g)) {
            (1, final x) when x == lauscher => {'art': 'lauschen', 'ziel': rolleB},
            (1, final x) when x == belauscht => {'art': 'zeigen', 'ziel': r.rolleVon(lauscher)},
            _ => switch (_reihum(g, i, m)!) {
                final z when z['art'] == 'lauschen' => {'art': 'helfen', 'tipp': ?z['tipp']},
                final z => z,
              },
          };
      _bis(r, (s) => s['phase'] == 'ende', zuege: zuege, jeSchritt: merke);

      // Lauschen: nur der Lauscher erfährt Art und Ziel.
      final gelauscht = _liste(_map(_privat(r, lauscher)['moment'])['gelauscht']);
      expect(gelauscht.first, {
        'runde': 1, 'schluessel': 'einfluss.privat.gelauscht', 'art': 'gelauscht', 'figur': rolleB, 'zug': 'zeigen', 'ziel': r.rolleVon(lauscher),
      });
      final geheim = {'pfad', 'fallCode', 'salz', 'seed', 'richtig', 'qualitaeten', 'tipp', 'tipps', 'summeZusammenhalt', 'summeSpuk', 'wertung'};
      var vorFinale = 0;
      for (final e in ansichten.entries) {
        final id = e.key;
        for (final v in e.value) {
          final nachFinale = ['finale', 'aufloesung', 'ende'].contains(v['phase']);
          final privat = _map(v['privat']);
          final moment = privat['moment'] is Map ? _map(privat['moment']) : null;
          if (id != lauscher) expect(moment?.containsKey('gelauscht') ?? false, isFalse, reason: '$id hört nicht mit');
          expect(privat.containsKey('einflussTafel'), id == 'p0' && !nachFinale && v['runde'] != 0, reason: 'Tafel: $id ${v['phase']}');
          expect(privat.containsKey('moment'), r.rolleVon(id) != null, reason: 'moment nur mit Figur: $id');
          if (nachFinale) continue;
          vorFinale++;
          expect(_schluessel(_oeffentlich(v)).toSet().intersection(geheim), isEmpty, reason: 'öffentlich vor dem Finale');
          expect(_schluessel(privat['einflussTafel']).toSet().intersection(geheim), isEmpty, reason: 'Tafel ohne Tipps');
          expect(v.keys.every(raumOeffentlicheSchluessel.contains), isTrue);
          final eigene = moment == null ? const <String>{} : {'tipps', 'tipp'};
          expect(_schluessel(moment).toSet().intersection(geheim.difference(eigene)), isEmpty, reason: 'moment: $id');
          expect(jsonEncode(_oeffentlich(v)), isNot(contains('"aufloesung"')));
        }
      }
      expect(vorFinale, greaterThan(200));
      // Öffentlicher Teil ist bei gleicher Version für alle gleich.
      for (var i = 0; i < ansichten['p0']!.length; i++) {
        final soll = jsonEncode(_oeffentlich(ansichten['p0']![i]));
        for (final id in ansichten.keys) {
          expect(jsonEncode(_oeffentlich(ansichten[id]![i])), soll, reason: '$id Schritt $i');
        }
      }
      // Nach dem Finale: Auflösung mit Protokoll der Nacht, Sternen, Tipps, Auszeichnungen und Endwert.
      final a = _map(_map(r.zustandFuer('p3')['aufloesung'])['einfluss']);
      expect(a.keys, containsAll(['protokoll', 'sterne', 'ziele', 'tipps', 'auszeichnungen', 'tischbonus', 'endwert', 'morgen']));
      expect(_liste(a['protokoll']), hasLength(3));
      expect(_map(a['tipps']).keys.toSet(), Besetzung(kanon).besetzt(6).toSet(), reason: 'alle Rollen tippen in Runde 3');
    });

    test('Pfadblind: gleiche Züge und Würfel, gleiche Moment-Ansichten in allen vier Pfaden', () {
      String spur(String pfad) {
        final r = _raum(pfad: pfad);
        _start(r, geraete: 6, rollen: 4);
        final zeilen = <String>[];
        _bis(r, (s) => s['phase'] == 'anklage', jeSchritt: () {
          for (var i = 0; i < 6; i++) {
            final v = r.zustandFuer('p$i');
            final privat = _map(v['privat']);
            final moment = privat['moment'] is Map ? (Map.of(_map(privat['moment']))..remove('sterne')) : null;
            zeilen.add(jsonEncode([v['phase'], v['einfluss'], moment, privat['einflussTafel'], v['restMinuten'], v['wuerfe']]));
          }
        });
        return zeilen.join('\n');
      }

      final erste = spur(kanon.pfade.first);
      for (final pfad in kanon.pfade.skip(1)) {
        expect(spur(pfad), erste, reason: pfad);
      }
    });
  });

  group('Abend', () {
    for (final fassung in Abendfassung.values) {
      test('ganzer Abend (${fassung.name}): Folgen beim Wechsel, keine Gruppenwahl, Flüstern, Nachfragen, Notizbuch, Auflösung', () {
        final r = _raum(fassung: fassung);
        _start(r, geraete: 6, rollen: 7);
        final phasen = <String>{};
        var folgen = 0, mitFunden = 0, nachfragen = 0;
        _bis(r, (s) => s['phase'] == 'ende' && s['rundgang'] == null, jeSchritt: () {
          final s = r.zustandFuer('p1');
          phasen.add(s['phase'] as String);
          final e = _map(s['einfluss']);
          folgen = (e['folgen'] as List).length;
          if (s['phase'] == 'anklage' && s['angeklagt'] == null) {
            nachfragen = nachfragen > (_map(e['nachfragen'])['offen'] as int) ? nachfragen : _map(e['nachfragen'])['offen'] as int;
          }
          if (s['zug'] case final Map z when z['phase'] == 'fund' && z['option'] != null) {
            expect(z.keys, containsAll(['tisch', 'verwischt', 'einfluss']));
            mitFunden++;
          }
          if (s['zug'] case final Map z when z['phase'] == 'wurf' && z['option'] != null) expect(z['tischVorschau'], isA<Map>());
        });
        expect(phasen, isNot(contains('gruppenwahl')));
        expect(r.beendet, isTrue, reason: 'lang erst nach dem Morgen');
        expect(phasen, containsAll(['gespraeche', 'entscheidungen', 'bonus', 'resuemee', 'anklage', 'finale', 'aufloesung']));
        expect(folgen, 3);
        expect(mitFunden, 9);
        final ende = r.zustandFuer('p1');
        final notizbuch = _map(ende['notizbuch']);
        expect(notizbuch, hasLength(9));
        expect(notizbuch.values.every((f) => (f as List).isNotEmpty), isTrue, reason: 'verzögerte Funde sind nachgereicht');
        final aufloesung = _map(ende['aufloesung']);
        expect(_map(aufloesung['einfluss'])['endwert'], isA<int>());
        final gestellt = (_map(ende['einfluss'])['nachgefragt'] as List?) ?? const [];
        expect(gestellt.length, nachfragen, reason: 'jede offene Nachfrage gestellt');
        expect(nachfragen, greaterThan(0), reason: 'dieser Abend hat Nachfragen');
        for (final n in gestellt.cast<Map>()) {
          expect(einflussRegeln.randnotizen[n['option']], contains(n['notiz']));
        }
        // Blasen der Bots stehen in den Folgen, je höchstens drei.
        for (final f in _liste(_map(ende['einfluss'])['folgen'])) {
          expect((f['blasen'] as List).length, lessThanOrEqualTo(botBlasenHoechstens));
        }
      });
    }

    test('Replay aus dem Nachrichtenprotokoll gleich (Züge, Aufruf, Bot-Ersatz, Nachfragen)', () {
      SchlosskellerRaum fabrik() => _raum(pfad: 'olli');
      final r = ProtokollRaum(fabrik());
      _start(r, geraete: 6, rollen: 5);
      _bis(r, (s) => _gespraeche(s, 2));
      final figuren = _figurGeraete(r);
      _befehl(r, figuren.first, 'zug', {'art': 'helfen'});
      r.verbunden(figuren.last, false);
      r.verlassen(figuren.last);
      befragungenErledigen(r.zustandFuer('p1'), (typ, daten) => _befehl(r, 'p1', typ, daten));
      _befehl(r, 'p0', 'letzterAufruf', {'zeit': 5000});
      _befehl(r, 'p0', 'weiter', {'zeit': 70000});
      _bis(r, (s) => s['phase'] == 'ende');
      final soll = {for (var i = 0; i < 6; i++) if ('p$i' != figuren.last) 'p$i': r.zustandFuer('p$i')};
      expect(r.protokoll.where((e) => e[0] == 'nachricht' && _map(e[2])['typ'] == 'zug'), isNotEmpty);
      final wieder = ProtokollRaum.wiederherstellen(r.protokoll, fabrik);
      for (final e in soll.entries) {
        expect(jsonEncode(wieder.zustandFuer(e.key)), jsonEncode(e.value), reason: e.key);
      }
    });
  });
}
