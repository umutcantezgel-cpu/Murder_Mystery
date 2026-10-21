// Rückkehr des Online-Gastgebers: Die Randgespräche führt nur der Gastgeber, der
// Raum kennt sie nicht. Flags und geführte Gespräche liegen deshalb neben dem
// Raum in der Ablage und gelten nach der Rückkehr zum Abend weiter, aber nur
// für denselben Abend (gleiches Salz).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/ansicht.dart';
import 'package:mordakte/abend/online/gastgeber_dienst.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show Ablage, LokaleVerbindung, SpeicherAblage;

import '../party_widgets/hilfe.dart' show akteDaten;
import 'online_hilfe.dart' show befragungenImRaum;

/// Schlosskeller mit Randgesprächen.
PartyDaten get _daten => akteDaten('schlosskeller');

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? wert) => [for (final v in wert as List) _map(v)];

class _Verbindung implements LokaleVerbindung {
  _Verbindung(this.raum);

  @override
  final SchlosskellerRaum raum;

  @override
  String? get spielerId => 'gastgeber';

  @override
  Stream<Map<String, Object?>> get ansichten => Stream<Map<String, Object?>>.empty();

  @override
  Future<void> befehl(Map<String, Object?> c) async => raum.nachricht('gastgeber', c);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Gastgebergerät mit einem gestarteten Raum und einer Ablage.
class _Dienst implements GastgeberDienst {
  _Dienst(this.raum, this.ablage, {this.salz = 'salz-test'}) : verb = _Verbindung(raum);

  @override
  final SchlosskellerRaum raum;

  @override
  final Ablage ablage;

  @override
  final String salz;

  @override
  final LokaleVerbindung verb;

  @override
  PartyDaten get daten => _daten;

  @override
  String get detektivName => '';

  @override
  Sitz get sitz => Sitz.detektiv;

  @override
  int get minuten => 30;

  @override
  Abendfassung get fassung => raum.fassung;

  @override
  bool get stimme => false;

  @override
  Map<String, Object?> get ansicht => const {};

  @override
  List<SpielerInfo> get spieler => const [];

  @override
  List<SpielerInfo> get gaeste => const [];

  @override
  String nameVon(String? id) => '';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Ein Raum mit dem Gastgeber am Tisch, bis die erste Entscheidung offen ist.
SchlosskellerRaum _raum() {
  final raum = SchlosskellerRaum(
    raumCode: 'ABCDEF',
    kanon: _daten.kanon,
    texte: _daten.texte,
    fallCode: FallCode.fuerPfad('ahmet', _daten.kanon.pfade),
    salz: 'salz-test',
    festerGastgeber: true,
  );
  raum.beitreten('gastgeber', 'Anna');
  raum.nachricht('gastgeber', {'typ': 'bereit', 'wert': true});
  raum.nachricht('gastgeber', {'typ': 'start', 'rollen': 4, 'detektiv': 'w', 'vorrat': const <String>[]});
  for (var i = 0; i < 50; i++) {
    final s = raum.zustandFuer('gastgeber');
    if (s['phase'] == 'entscheidungen' && s['entscheidung'] is Map && s['zug'] == null) return raum;
    if (s['phase'] == 'rollen') {
      for (final t in _liste(s['spieler'])) {
        if (t['rolle'] != null && t['online'] == true) raum.nachricht(t['id'] as String, {'typ': 'rollenGelesen'});
      }
    }
    if (s['phase'] == 'gespraeche') befragungenImRaum(raum);
    // Der Auftakt der ersten Runde ist ein Zug: Würfeln, Aktion, Fund.
    final zug = s['zug'] is Map ? _map(s['zug']) : null;
    switch (zug?['phase']) {
      case null:
        raum.nachricht('gastgeber', {'typ': 'weiter'});
      case 'aktion':
        raum.nachricht('gastgeber', {'typ': 'aktionFertig', 'aktion': zug!['aktion']});
      case 'wurf':
        raum.nachricht(s['wuerfelPate'] as String, {'typ': 'wurf'});
      case 'tischruf':
        raum.nachricht('gastgeber', {'typ': 'tischruf', 'ruf': 'umweg'});
      case 'fund':
        raum.nachricht('gastgeber', {'typ': 'fundGelesen'});
      default:
        fail('Unerwarteter Zugabschnitt ${zug!['phase']}');
    }
  }
  fail('Erste Entscheidung nicht erreicht');
}

/// Führt mit dem ersten ansprechbaren Zeugen ein ganzes Gespräch; liefert dessen Kennung.
String _gespraechFuehren(PartySitzung s) {
  final figur = s.daten.erzaehlung!.gespraeche.map((g) => g.figur).firstWhere(s.randgespraechMoeglich);
  expect(s.randgespraechBeginnen(figur), isTrue);
  final id = s.gespraech!.gespraech.id;
  while (!s.gespraech!.fertig) {
    s.randgespraechWaehlen(s.gespraech!.wahlen.first);
  }
  s.randgespraechBeenden();
  return id;
}

Future<void> _warten() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('Rückkehr zum Abend: Flags und geführte Gespräche bleiben', () async {
    final raum = _raum();
    final ablage = SpeicherAblage();
    final erste = GastgeberSitzung(_Dienst(raum, ablage));
    await _warten();
    expect(erste.phase, PartyPhase.entscheidungen);
    final id = _gespraechFuehren(erste);
    final flags = erste.erzaehlFlags;
    expect(flags, isNotEmpty, reason: 'Das Gespräch setzt Flags');
    await _warten();
    final abgelegt = jsonDecode(ablage.daten[GastgeberDienst.erzaehlSchluessel]!) as Map;
    expect(abgelegt['salz'], 'salz-test');

    // Die App wird beendet; der Gastgeber kehrt in denselben Raum zurück.
    final zweite = GastgeberSitzung(_Dienst(raum, ablage));
    await _warten();
    expect(zweite.erzaehlFlags, flags);
    final figur = erste.daten.erzaehlung!.gespraeche.firstWhere((g) => g.id == id).figur;
    if (zweite.randgespraechBeginnen(figur)) {
      expect(zweite.gespraech!.gespraech.id, isNot(id), reason: 'Ein geführtes Gespräch kommt nicht wieder');
    }
  });

  test('Ein anderer Abend übernimmt nichts; Verwerfen räumt ab', () async {
    final raum = _raum();
    final ablage = SpeicherAblage();
    final erste = GastgeberSitzung(_Dienst(raum, ablage));
    await _warten();
    _gespraechFuehren(erste);
    await _warten();

    final fremd = GastgeberSitzung(_Dienst(raum, ablage, salz: 'anderer-abend'));
    await _warten();
    expect(fremd.erzaehlFlags, isEmpty);

    await GastgeberDienst.verwerfeGespeicherten(ablage);
    expect(ablage.daten.containsKey(GastgeberDienst.erzaehlSchluessel), isFalse);
  });
}
