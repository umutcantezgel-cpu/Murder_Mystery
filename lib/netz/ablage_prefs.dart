import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ablage_tab.dart';

/// Dauerhafter Speicher des Online-Spiels ([Ablage] des Netzpakets) auf
/// `shared_preferences`: der Gastgeberzustand (Schlüssel, Protokoll des Abends)
/// und die Wiederverbindungs-Schlüssel der Gäste. Alle Schlüssel tragen das
/// Präfix [praefix].
///
/// Mit [proTab] liegen die Werte im Web nur im aktuellen Tab (`sessionStorage`),
/// damit zwei Gäste in zwei Tabs desselben Browsers nicht denselben Platz
/// bekommen; auf Handys ist der Schalter ohne Wirkung.
class AblagePrefs implements Ablage {
  const AblagePrefs({this.proTab = false});

  /// Gemeinsames Präfix aller Schlüssel dieser Ablage.
  static const praefix = 'mordakte.netz.';

  /// Wo Gäste merken, in welchem Raum sie sitzen: `{"code": …, "name": …}`.
  static const gastSitzung = 'gast.sitzung';

  /// Im Web: nur dieser Tab.
  final bool proTab;

  bool get _tab => proTab && tabSpeicherDa;

  @override
  Future<String?> lesen(String schluessel) async {
    final k = '$praefix$schluessel';
    if (_tab) return tabLesen(k);
    return (await SharedPreferences.getInstance()).getString(k);
  }

  @override
  Future<void> schreiben(String schluessel, String wert) async {
    final k = '$praefix$schluessel';
    if (_tab) {
      tabSchreiben(k, wert);
      return;
    }
    await (await SharedPreferences.getInstance()).setString(k, wert);
  }

  @override
  Future<void> loeschen(String schluessel) async {
    final k = '$praefix$schluessel';
    if (_tab) {
      tabLoeschen(k);
      return;
    }
    await (await SharedPreferences.getInstance()).remove(k);
  }
}
