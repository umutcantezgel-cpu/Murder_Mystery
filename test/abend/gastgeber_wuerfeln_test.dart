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
import 'online_hilfe.dart' show befragungenImRaum;

const _karte = 'schlosskeller:ahmet:lupe';

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? wert) => [for (final v in wert as List) _map(v)];

/// Lokale Verbindung, die jeden Befehl in den Raum gibt und mitschreibt.
class _Verbindung implements LokaleVerbindung {
  _Verbindung(this.raum);

  @override
  final SchlosskellerRaum raum;
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
    raum.nachricht('gastgeber', c);
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
  String get detektivName => '';

  @override
  Sitz get sitz => Sitz.detektiv;

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

/// Ein Raum mit dem Gastgeber als einzigem Platz am Tisch und einer Werkzeugkarte im Vorrat.
SchlosskellerRaum _raum() {
  final raum = SchlosskellerRaum(
    raumCode: 'ABCDEF',
    kanon: partyDaten.kanon,
    texte: partyDaten.texte,
    fallCode: FallCode.fuerPfad('ahmet', partyDaten.kanon.pfade),
    salz: 'salz-test',
    festerGastgeber: true,
    katalog: KartenKatalog([
      KartenDef(
        id: _karte, akte: 'schlosskeller', figur: 'ahmet', seltenheit: Seltenheit.gewoehnlich,
        art: KartenArt.werkzeug, titel: 'Lupe', text: 'Ein Werkzeug aus der Welt.', quellen: const [KartenQuelle('start')],
      ),
    ]),
  );
  raum.beitreten('gastgeber', 'Anna');
  raum.nachricht('gastgeber', {'typ': 'bereit', 'wert': true});
  raum.nachricht('gastgeber', {'typ': 'start', 'rollen': 4, 'detektiv': 'w', 'vorrat': [_karte]});
  return raum;
}

/// Treiber wie in der Raumprüfung: nur Ansichten und Nachrichten, bis ein Wurf der zweiten Runde ansteht.
void _bisWurf(SchlosskellerRaum raum) {
  final erm = Ermittlung(partyDaten.kanon);
  for (var i = 0; i < 400; i++) {
    final s = raum.zustandFuer('gastgeber');
    if (s['runde'] == 2 && s['zug'] is Map && _map(s['zug'])['phase'] == 'wurf') return;
    switch (s['phase']) {
      case 'rollen':
        for (final t in _liste(s['spieler'])) {
          if (t['rolle'] != null && t['online'] == true) raum.nachricht(t['id'] as String, {'typ': 'rollenGelesen'});
        }
        raum.nachricht('gastgeber', {'typ': 'weiter'});
      case 'entscheidungen':
        if (s['zug'] case final Map zug) {
          switch (zug['phase']) {
            case 'aktion':
              raum.nachricht('gastgeber', {'typ': 'aktionFertig', 'aktion': zug['aktion']});
            case 'wurf':
              // Der Auftakt in Runde 1 wird vom Würfelpaten geworfen.
              raum.nachricht(s['wuerfelPate'] as String, {'typ': 'wurf'});
            case 'tischruf':
              raum.nachricht('gastgeber', {'typ': 'tischruf', 'ruf': 'umweg'});
            case 'fund':
              raum.nachricht('gastgeber', {'typ': 'fundGelesen'});
            default:
              fail('Unerwarteter Zugabschnitt ${zug['phase']}');
          }
        } else if (s['entscheidung'] case final Map e) {
          final option = erm.entscheidung(e['id'] as String).richtig['ahmet']!;
          raum.nachricht('gastgeber', {'typ': 'wahl', 'option': option});
        } else {
          raum.nachricht('gastgeber', {'typ': 'weiter'});
        }
      case 'gespraeche':
        befragungenImRaum(raum);
        raum.nachricht('gastgeber', {'typ': 'weiter'});
      case 'gruppenwahl':
        raum.nachricht('gastgeber', {'typ': 'weiter'});
      case 'anklage':
        raum.nachricht('gastgeber', {'typ': 'anklage', 'person': 'ahmet'});
        raum.nachricht('gastgeber', {'typ': 'weiter'});
      default:
        raum.nachricht('gastgeber', {'typ': 'weiter'});
    }
  }
  fail('Wurf der zweiten Runde nicht erreicht');
}

void main() {
  test('Gastgeber-Würfeln schickt die Würfelhilfe vor jedem Wurf', () async {
    // Ein Platz am Tisch, der Gastgeber: Er ist der Würfelpate. Der Abend steht im Wurf.
    final raum = _raum();
    expect(raum.partieFuerGastgeber, isNotNull, reason: 'Der Abend läuft');
    expect(raum.wuerfelPate, 'gastgeber');
    _bisWurf(raum);
    expect(_map(raum.zustandFuer('gastgeber')['zug'])['phase'], 'wurf');

    final verb = _Verbindung(raum);
    final s = GastgeberSitzung(_Dienst(raum, partyDaten, verb));
    final vorher = _liste(raum.zustandFuer('gastgeber')['wuerfe']).length;

    s.wuerfeln(marke: true, karte: _karte);
    await Future<void>.delayed(Duration.zero);
    expect(verb.befehle, [
      {'typ': 'wuerfelHilfe', 'marke': true, 'karte': _karte},
      {'typ': 'wurf'},
    ], reason: 'Würfelhilfe mit Marke und Karte, dann der Wurf');
    expect(s.letzterFehler, isNull, reason: 'Der Raum nimmt Würfelhilfe und Wurf an');
    expect(_liste(raum.zustandFuer('gastgeber')['wuerfe']), hasLength(vorher + 1));
    expect(_liste(raum.zustandFuer('gastgeber')['vorrat']).single['rest'], 0, reason: 'Die Karte wird mit dem Wurf verbraucht');

    _bisWurf(raum);
    verb.befehle.clear();
    s.wuerfeln();
    await Future<void>.delayed(Duration.zero);
    expect(verb.befehle, [
      {'typ': 'wuerfelHilfe', 'marke': false},
      {'typ': 'wurf'},
    ], reason: 'Ohne Marke und Karte wird der eigene Stand trotzdem mitgeschickt');
    expect(s.letzterFehler, isNull, reason: 'Auch der zweite Wurf wird vom Raum angenommen');
  });
}
