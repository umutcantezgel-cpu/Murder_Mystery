import 'package:mordakte_core/mordakte_core.dart';

import '../game/szenen_erweiterung.dart';
import 'abend_karte.dart';
import 'daten.dart';

/// Die Karte eines Rundgangs (Vorspiel und Morgen, Langer Abend M7b): die
/// Abend-Karte ([AbendKarte]) mit dem Weg von Station zu Station.
///
/// - [geheZu] führt den Detektiv geführt an den Ort der Station, in der Lage
///   des Wegs ([Rundgang.wegLage]: die Tore der Station davor). Erst wenn er
///   dort steht (oder ein späterer Schritt ihn ablöst), stellt die Uhrzeit der
///   Station die Tore: So schließt Herr Schneider erst ab, wenn der Detektiv
///   im Keller ist, und am Morgen steht der Hof erst offen, wenn die Kollegin
///   aufgeschlossen hat.
/// - Figuren: Auf den Ebenen stehen die Figuren der Station an ihren Orten.
///   Im Keller stehen alle an ihren Ermittlungsorten, wie im ganzen Abend,
///   außer denen, die die Station draußen hinstellt.
/// - Licht: am Morgen draußen Tageslicht ([AbendKarte.tageslicht]); der
///   Keller bleibt beim Licht der Nacht.
///
/// Der Rundgang ändert nichts am Abend: Die Karte kennt weder Partie noch
/// Würfel, Nachtminuten oder Wertung (siehe [AbendKarte]).
class RundgangKarte extends AbendKarte {
  RundgangKarte._(super.daten, super.welt, super.szenarien, this.rundgang, int station, {required super.lage, required super.ebene, required super.start, super.klasse, super.detektivName})
      : _station = station;

  /// Karte für [rundgang], vor der Station [station]: Der Detektiv steht am
  /// Ort der Station davor (vor der ersten am Start), in der Lage dieses
  /// Wegs. [geheZu] bringt ihn dann zur Station.
  factory RundgangKarte(PartyDaten daten, WeltEbenen welt, Map<String, ScenarioDef> szenarien, Rundgang rundgang,
      {int station = 0, SzenenKlasse? klasse, String detektivName = ''}) {
    final i = station.clamp(0, rundgang.stationen.length - 1);
    final (ebene, ort) = i == 0 ? (rundgang.startEbene, rundgang.startOrt) : (rundgang.stationen[i - 1].ebene, rundgang.stationen[i - 1].ort);
    final o = welt.ebenen[ebene]!.graph.orte[ort]!;
    return RundgangKarte._(daten, welt, szenarien, rundgang, i,
        lage: rundgang.wegLage(i), ebene: ebene, start: (o.x, o.y), klasse: klasse, detektivName: detektivName);
  }

  /// Der Rundgang dieser Karte.
  final Rundgang rundgang;

  int _station;

  /// Zahl der Aufrufe von [geheZu]; ein älterer Weg stellt keine Tore mehr.
  int _schritt = 0;

  /// Station, deren Figuren gerade stehen und zu der der Detektiv geht.
  int get station => _station;

  RundgangStation get _aktuell => rundgang.stationen[_station];

  /// Geht zur Station [i]: Figuren der Station, Weg in der Lage davor, dann
  /// die Lage der Station. `true`, wenn der Detektiv dort angekommen ist;
  /// `false`, wenn ein neuerer Schritt diesen abgelöst hat. Führt kein Weg
  /// dorthin, steht er nach einer Kurzblende dort (die Lage gilt trotzdem).
  Future<bool> geheZu(int i) async {
    if (entsorgt || i < 0 || i >= rundgang.stationen.length) return false;
    final schritt = ++_schritt;
    _station = i;
    final st = rundgang.stationen[i];
    // Der Weg läuft in der Lage der Station davor; erst dort angekommen, gilt die Lage der Station.
    if (laeuft) abkuerzen();
    wechsleLage(rundgang.wegLage(i));
    zeigeFall();
    var angekommen = await laufeZu(st.ebene, st.ort);
    if (entsorgt || schritt != _schritt) return false;
    if (!angekommen) {
      // Kein offener Weg (darf laut Prüfer nicht sein): Kurzblende an den Ort der Station.
      final o = welt.ebenen[st.ebene]!.graph.orte[st.ort]!;
      springe(st.ebene, (o.x, o.y), ort: st.ort);
      angekommen = true;
    }
    wechsleLage(st.lage);
    return angekommen;
  }

  /// Figuren der laufenden Station auf [ebene] (nur die neuen Ebenen).
  @override
  List<NpcView> figurenAufEbene(String ebene) {
    final st = _aktuell;
    if (st.ebene != ebene) return const [];
    final g = welt.ebenen[ebene]!.graph;
    return [
      for (final f in st.figuren)
        if ((g.orte[f.ort], daten.npcKennung[f.figur]) case (final o?, final id?)) NpcView(id: id, x: o.x, y: o.y, alive: true),
    ];
  }

  /// Im Keller alle an ihren Ermittlungsorten, außer denen, die die Station
  /// draußen hinstellt; auf den Ebenen die Figuren der Station.
  @override
  ({List<NpcView> npcs, Set<String> gehend}) figurenAnsicht() {
    final ansicht = super.figurenAnsicht();
    if (aktuelleEbene != kellerEbene) return ansicht;
    final draussen = {for (final f in _aktuell.figuren) ?daten.npcKennung[f.figur]};
    return (npcs: [for (final n in ansicht.npcs) if (!draussen.contains(n.id)) n], gehend: ansicht.gehend);
  }
}
