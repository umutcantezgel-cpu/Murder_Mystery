/// Verbindung zu einem Raum im selben Prozess, ohne Netz: der Gastgeberplatz
/// im Relais-Spiel und die Grundlage für Tests.
library;

import 'dart:async';
import 'dart:convert';

import 'package:mordakte_core/runden.dart' show AbendRaum, PartyRaumFehler;

import 'verbindung.dart';

class LokaleVerbindung implements AbendVerbindung {
  /// Tritt dem [raum] als [id] mit [name] bei ([beitreten] `false`: der Platz
  /// besteht schon, z. B. nach Wiederherstellung). [beiAenderung] wird nach
  /// jedem erfolgreichen Befehl gerufen, damit andere Plätze (Relais-Gäste)
  /// ihre Ansichten neu bekommen.
  LokaleVerbindung(this.raum, {required String id, String name = '', this.beiAenderung, bool beitreten = true}) : _id = id {
    if (beitreten && !raum.beitreten(id, name)) throw const AbendFehler('voll');
    _status.add(VerbindungsStatus.verbunden);
    aktualisiere();
  }

  final AbendRaum raum;
  final void Function()? beiAenderung;
  final String _id;
  final LetzterWert<Map<String, Object?>> _ansichten = LetzterWert<Map<String, Object?>>();
  final LetzterWert<VerbindungsStatus> _status = LetzterWert<VerbindungsStatus>();
  String? _letzte;
  bool _zu = false;

  @override
  String get raumCode => raum.raumCode;

  @override
  String? get spielerId => _id;

  @override
  Stream<Map<String, Object?>> get ansichten => _ansichten.strom;

  @override
  Stream<VerbindungsStatus> get status => _status.strom;

  /// Die letzte veröffentlichte Ansicht (nach dem Start immer vorhanden).
  Map<String, Object?>? get letzteAnsicht => _ansichten.wert;

  /// Holt die Ansicht neu und veröffentlicht sie, wenn sie sich geändert hat.
  /// Fremde Änderungen am Raum (andere Plätze) müssen dies auslösen.
  void aktualisiere() {
    if (_zu) return;
    final Map<String, Object?> ansicht;
    try {
      ansicht = raum.zustandFuer(_id);
    } on PartyRaumFehler {
      // Nicht (mehr) im Raum: Der Platz ist vorbei.
      unawaited(_schliesse());
      return;
    }
    final text = jsonEncode(ansicht);
    if (text == _letzte) return;
    _letzte = text;
    _ansichten.add(ansicht);
  }

  @override
  Future<void> befehl(Map<String, Object?> c) async {
    if (_zu) throw const AbendFehler('geschlossen');
    try {
      raum.nachricht(_id, c);
    } on PartyRaumFehler catch (e) {
      throw AbendFehler(e.code);
    } on AbendFehler {
      rethrow;
    } catch (_) {
      throw const AbendFehler('invalid');
    }
    aktualisiere();
    beiAenderung?.call();
  }

  @override
  Future<void> verlassen() async {
    if (_zu) return;
    raum.verlassen(_id);
    await _schliesse();
    beiAenderung?.call();
  }

  Future<void> _schliesse() async {
    if (_zu) return;
    _zu = true;
    _status.add(VerbindungsStatus.geschlossen);
    await _ansichten.schliessen();
    await _status.schliessen();
  }

  /// Schließt nur diese Verbindung, ohne den Raum zu verlassen (Gastgeber-Ende).
  Future<void> schliessen() => _schliesse();
}
