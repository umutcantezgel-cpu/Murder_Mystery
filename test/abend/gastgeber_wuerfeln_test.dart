// Würfeln auf dem Gastgebergerät: Jeder Wurf schickt zuerst den eigenen Stand
// (Würfelhilfe mit Marke und Werkzeugkarte), dann den Wurf. So fließt nichts
// still aus einem früheren Würfelpaten in diesen Wurf ein.
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/ansicht.dart';
import 'package:mordakte/abend/online/gastgeber_dienst.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show LokaleVerbindung;

import '../party_widgets/hilfe.dart' show partyDaten;

/// Lokale Verbindung ohne Relais: merkt sich nur die gesendeten Befehle.
class _Verbindung implements LokaleVerbindung {
  final List<Map<String, Object?>> befehle = [];

  @override
  String? get spielerId => 'gastgeber';

  @override
  Stream<Map<String, Object?>> get ansichten => Stream<Map<String, Object?>>.empty();

  @override
  Map<String, Object?>? get letzteAnsicht => null;

  @override
  Future<void> befehl(Map<String, Object?> c) async {
    befehle.add(c);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Gastgebergerät mit einem gestarteten Raum, nur die Teile, die die Sitzung liest.
class _Dienst implements GastgeberDienst {
  _Dienst(this.raum, this.daten, this.verb);

  @override
  final SchlosskellerRaum raum;

  @override
  final PartyDaten daten;

  @override
  final LokaleVerbindung verb;

  @override
  String get salz => 'salz-test';

  @override
  String get geburtstagskind => '';

  @override
  int get minuten => 30;

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

void main() {
  test('Gastgeber-Würfeln schickt die Würfelhilfe vor jedem Wurf', () async {
    // Ein Platz am Tisch, der Gastgeber: Er ist der Würfelpate.
    final raum = SchlosskellerRaum(
      raumCode: 'ABCDEF',
      kanon: partyDaten.kanon,
      texte: partyDaten.texte,
      fallCode: FallCode.fuerPfad('ahmet', partyDaten.kanon.pfade),
      salz: 'salz-test',
      festerGastgeber: true,
    );
    raum.beitreten('gastgeber', 'Anna');
    raum.nachricht('gastgeber', {'typ': 'bereit', 'wert': true});
    raum.nachricht('gastgeber', {'typ': 'start', 'rollen': 4, 'detektiv': 'w'});
    expect(raum.partieFuerGastgeber, isNotNull, reason: 'Der Abend läuft');
    expect(raum.wuerfelPate, 'gastgeber');

    final verb = _Verbindung();
    final s = GastgeberSitzung(_Dienst(raum, partyDaten, verb));

    s.wuerfeln(marke: true, karte: 'schlosskeller:ahmet:lupe');
    await Future<void>.delayed(Duration.zero);
    expect(verb.befehle, [
      {'typ': 'wuerfelHilfe', 'marke': true, 'karte': 'schlosskeller:ahmet:lupe'},
      {'typ': 'wurf'},
    ], reason: 'Würfelhilfe mit Marke und Karte, dann der Wurf');

    verb.befehle.clear();
    s.wuerfeln();
    await Future<void>.delayed(Duration.zero);
    expect(verb.befehle, [
      {'typ': 'wuerfelHilfe', 'marke': false},
      {'typ': 'wurf'},
    ], reason: 'Ohne Marke und Karte wird der eigene Stand trotzdem mitgeschickt');
  });
}
