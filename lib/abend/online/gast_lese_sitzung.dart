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

  @override
  List<BefragungKarte> get befragungen => befragungsKartenAus(_privat);

  @override
  int get befragungenFrei => jZahl(_privat['befragungenFrei']);

  @override
  void befragen(String id, int frage) => _befehl?.call({'typ': 'befragen', 'id': id, 'frage': frage});

  @override
  void befragungErledigt(String id) => _befehl?.call({'typ': 'erledigt', 'id': id});
}
