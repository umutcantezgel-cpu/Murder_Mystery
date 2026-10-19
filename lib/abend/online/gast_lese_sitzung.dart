import 'dart:async';

import 'package:mordakte_core/runden.dart' show Sitz;

import '../../party/sitzung.dart';
import '../../party/stand/befragung_stand.dart';
import 'ansicht.dart';
import 'gast_ansicht.dart' show GastKontext, GastBefehl;
import 'gast_dienst.dart';

final _sitzungen = Expando<GastLeseSitzung>();

/// Eine Partysitzung zum Lesen auf dem Gerät eines Gastes (Langer Abend M3):
/// Sie hat keine eigene Partie und kennt weder Salz noch Pfad. Aus der Ansicht
/// des Raums (der Positivliste dieses Geräts) liest sie nur Namen am Tisch, die
/// Befragungskarten des Detektivs (privat) und die Klasse des Detektiv-Sitzes;
/// jede Frage geht als Raumnachricht hinaus. So nutzt der Gast-Detektiv
/// dieselben Bausteine wie der Gastgeber: Befragungskarten (M2), Detektivkarte
/// (M6), Texte der Oberfläche (`ui`) und Figuren.
///
/// Nie ein Dossier, nie die Täterfassung: Die Ansicht des Detektivs trägt sie
/// nicht, und die Sitzung zeigt nichts außerhalb von ihr.
class GastLeseSitzung extends PartySitzung {
  GastLeseSitzung._(super.daten) : super(salz: 'gast-ansicht');

  /// Die Sitzung zu diesem Gastgerät (eine je Dienst und Akte), mit der
  /// jüngsten Ansicht und dem Befehlsweg von [c]. `null`, solange die Akte lädt.
  static GastLeseSitzung? fuer(GastKontext c) {
    final daten = c.daten;
    if (daten == null) return null;
    final s = _sitzungen[c.dienst];
    final sitzung = s != null && s.daten == daten ? s : (_sitzungen[c.dienst] = GastLeseSitzung._(daten));
    return sitzung..aktualisieren(c.dienst, c.befehl);
  }

  GastDienst? _dienst;
  GastBefehl? _befehl;

  Map<String, Object?> get _ansicht => _dienst?.ansicht ?? const {};
  Map<String, Object?> get _privat => jMap(_ansicht['privat']);

  /// Neue Ansicht: Namen am Tisch (Rolle → Gast, Detektiv → Gerät auf dem Sitz).
  void aktualisieren(GastDienst dienst, GastBefehl befehl) {
    _dienst = dienst;
    _befehl = befehl;
    final spieler = spielerAusAnsicht(_ansicht);
    namen
      ..clear()
      ..addAll({for (final s in spieler) if (s.rolle != null && s.name.trim().isNotEmpty) s.rolle!: s.name.trim()});
    detektivName = spieler.where((s) => s.sitz == Sitz.detektiv).firstOrNull?.name ?? '';
  }

  @override
  bool get online => true;

  @override
  bool get detektivAmGeraet => _privat['detektiv'] == true;

  @override
  String? get detektivKlasse => _privat['klasse'] is String ? _privat['klasse'] as String : null;

  /// Fragen und „Beantwortet“ auf dem Weg zum Raum. Bis eine neue Ansicht
  /// kommt, zeigt die Karte sie schon als gestellt: Ein zweiter Tipp schickt
  /// nichts doppelt, eine freie Wahl ist sofort verbraucht. Mit der nächsten
  /// Ansicht gilt wieder nur sie.
  final Map<String, ({int frage, Object? ansicht, bool fertig})> _gefragt = {};
  final Map<String, ({Object? ansicht, bool fertig})> _beantwortet = {};

  /// Gilt ein Eintrag noch? Solange der Befehl läuft, und danach, bis eine
  /// neue Ansicht da ist.
  bool _gilt(Object? ansicht, bool fertig) => !fertig || identical(ansicht, _dienst?.ansicht);

  int? _unterwegs(String id) {
    final e = _gefragt[id];
    return e != null && _gilt(e.ansicht, e.fertig) ? e.frage : null;
  }

  bool _erledigtUnterwegs(String id) {
    final e = _beantwortet[id];
    return e != null && _gilt(e.ansicht, e.fertig);
  }

  @override
  List<BefragungKarte> get befragungen => [
        for (final k in befragungsKartenAus(_privat))
          if ((k.frage == null && _unterwegs(k.id) != null) || (!k.erledigt && _erledigtUnterwegs(k.id)))
            BefragungKarte(
              id: k.id,
              rolle: k.rolle,
              thema: k.thema,
              fragen: k.fragen,
              pflicht: k.pflicht,
              mensch: k.mensch,
              frage: k.frage ?? _unterwegs(k.id),
              erledigt: k.erledigt || _erledigtUnterwegs(k.id),
              waehlbar: k.waehlbar,
              antwortKarten: k.antwortKarten,
            )
          else
            k,
      ];

  @override
  int get befragungenFrei {
    final frei = jZahl(_privat['befragungenFrei']);
    final unterwegs = [for (final k in befragungsKartenAus(_privat)) if (!k.pflicht && k.frage == null && _unterwegs(k.id) != null) k].length;
    return (frei - unterwegs).clamp(0, frei);
  }

  @override
  void befragen(String id, int frage) {
    if (_unterwegs(id) != null) return;
    final ansicht = _dienst?.ansicht;
    _gefragt[id] = (frage: frage, ansicht: ansicht, fertig: false);
    notifyListeners();
    unawaited((_befehl?.call({'typ': 'befragen', 'id': id, 'frage': frage}) ?? Future<void>.value()).whenComplete(() {
      if (_gefragt[id]?.ansicht case final a when identical(a, ansicht)) _gefragt[id] = (frage: frage, ansicht: ansicht, fertig: true);
      notifyListeners();
    }));
  }

  @override
  void befragungErledigt(String id) {
    if (_erledigtUnterwegs(id)) return;
    final ansicht = _dienst?.ansicht;
    _beantwortet[id] = (ansicht: ansicht, fertig: false);
    notifyListeners();
    unawaited((_befehl?.call({'typ': 'erledigt', 'id': id}) ?? Future<void>.value()).whenComplete(() {
      if (_beantwortet[id]?.ansicht case final a when identical(a, ansicht)) _beantwortet[id] = (ansicht: ansicht, fertig: true);
      notifyListeners();
    }));
  }
}
