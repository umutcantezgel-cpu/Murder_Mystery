import '../../party/ablauf.dart';
import '../../party/befragung.dart';
import '../../welt/ebenen.dart' show kellerEbene;
import '../../welt/erkundung.dart';
import '../schlosskeller_raum.dart' show PartyRaumFehler;
import 'raum_modul.dart';

/// Streifzug im Online-Abend (Langer Abend M7b, nur bei [Abendfassung.lang]).
///
/// Nachrichten, nur vom Gerät, das ermittelt ([RaumKontext.nurDetektiv]),
/// nur in Gesprächen und Entscheidungen:
/// - `erkunde {ort}`: Der Detektiv hat einen Erkundungsort besucht.
/// - `treffen {befragung}`: Der Detektiv geht zum Treffpunkt einer Befragung
///   der laufenden Runde (nur in den Gesprächen).
///
/// Öffentlich ist `streifzug {ebene, ort?, erkundet, treffpunkt?}`: wo der
/// Detektiv zuletzt war, welche Orte er erkundet hat und, solange er jemanden
/// trifft, wen und wo (`{figur, ort, anzeige}`). Alles ist Stimmung: in allen
/// Pfaden gleich, ohne Pfad, Salz, Täter oder Wertung; Partie, Würfel und
/// Nachtminuten bleiben unberührt. Privat bekommt das ermittelnde Gerät die
/// Treffpunkte der Befragungen der Runde und die Fassungen der Erkundungsorte
/// (`streifzug {treffpunkte, varianten}`): Beide zieht der Raum aus dem Samen
/// der Welt, der nie ein Gerät verlässt.
class StreifzugModul extends RaumModul {
  StreifzugModul({required this.erkundung, required int weltSamen}) : _samen = weltSamen;

  /// Erkundungsorte und Treffpunkte der Akte.
  final Erkundung erkundung;

  /// Samen der Welt (aus dem Salz des Raums), Quelle aller Treffpunkte und Fassungen.
  final int _samen;

  BefragungsVerlauf? _plan;
  final List<String> _erkundet = [];
  String _ebene = kellerEbene;
  String? _ort;

  /// Laufendes Treffen: Befragung und Treffpunkt.
  ({String befragung, Treffpunkt treffpunkt})? _treffen;

  /// Erkundete Orte (zum Lesen, etwa für Tests).
  List<String> get erkundet => List.unmodifiable(_erkundet);

  @override
  Map<String, Set<String>> get nachrichten => const {
        'erkunde': {'ort'},
        'treffen': {'befragung'},
      };

  bool _streifzug(RaumKontext k) => _plan != null && (k.phase == PartyPhase.gespraeche || k.phase == PartyPhase.entscheidungen);

  /// Befragungen der laufenden Runde in der Reihenfolge der Karten (feste, dann freie).
  List<String> _befragungen(RaumKontext k) => [..._plan!.pflicht(k.runde), ..._plan!.frei(k.runde)];

  Map<String, Treffpunkt> _treffpunkte(RaumKontext k) => erkundung.treffpunkteFuer(_samen, _befragungen(k));

  @override
  void beimStart(RaumKontext k) {
    _plan = BefragungsVerlauf(Befragungsplan(k.texte), k.partie!.spiel.einstellungen.rollen);
    _erkundet.clear();
    _ebene = kellerEbene;
    _ort = null;
    _treffen = null;
  }

  @override
  void nachricht(RaumKontext k, String id, String typ, Map<String, Object?> inhalt) {
    k.nurDetektiv(id);
    if (!_streifzug(k)) throw const PartyRaumFehler('invalid_phase');
    switch (typ) {
      case 'erkunde':
        final ort = inhalt['ort'];
        final o = ort is String ? erkundung.ort(ort) : null;
        if (o == null) throw const PartyRaumFehler('invalid');
        if (!_erkundet.contains(o.id)) _erkundet.add(o.id);
        _ebene = o.ebene;
        _ort = o.id;
        _treffen = null;
      case 'treffen':
        if (k.phase != PartyPhase.gespraeche) throw const PartyRaumFehler('invalid_phase');
        final b = inhalt['befragung'];
        final t = b is String ? _treffpunkte(k)[b] : null;
        if (b is! String || t == null) throw const PartyRaumFehler('invalid');
        _treffen = (befragung: b, treffpunkt: t);
        _ebene = t.ebene;
        _ort = t.id;
    }
  }

  @override
  void phaseGewechselt(RaumKontext k) {
    _treffen = null;
    // Jede Runde beginnt im Keller; in die Entscheidungen geht es von dort, wo er war.
    if (k.phase == PartyPhase.gespraeche) {
      _ebene = kellerEbene;
      _ort = null;
    }
  }

  @override
  Map<String, Object?> oeffentlich(RaumKontext k, String id) {
    if (!_streifzug(k)) return const {};
    final t = _treffen;
    return {
      'streifzug': {
        'ebene': _ebene,
        'ort': ?_ort,
        'erkundet': [..._erkundet],
        if (t != null)
          'treffpunkt': {
            'figur': _plan!.text(t.befragung).rolle,
            'ort': t.treffpunkt.id,
            'anzeige': t.treffpunkt.anzeige,
          },
      },
    };
  }

  @override
  Map<String, Object?> privat(RaumKontext k, String id) {
    if (!_streifzug(k) || id != k.detektiv) return const {};
    return {
      'streifzug': {
        'treffpunkte': k.phase == PartyPhase.gespraeche ? {for (final e in _treffpunkte(k).entries) e.key: e.value.id} : const <String, String>{},
        'varianten': {
          for (final o in erkundung.orte)
            if (o.varianten.isNotEmpty) o.id: o.fassungFuer(_samen),
        },
      },
    };
  }
}
