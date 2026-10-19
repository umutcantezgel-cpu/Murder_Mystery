import 'package:flutter/widgets.dart' show BuildContext;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:provider/provider.dart';

import '../game/szenen_erweiterung.dart';
import '../meta/meta_store.dart';
import 'daten.dart';
import 'karten_quelle.dart';
import 'sitzung.dart';

/// Wirkung der Detektivklasse auf der Karte (A-055, Langer Abend M6): die
/// festen Werte aus [KlassenParameter] als [SzenenKlasse] für den Renderer.
///
/// Spurenblick, Menschenkenner, Ortskundig, Gerüchte und Laufschritt wirken
/// nur auf die Darstellung und das Tempo der eigenen Figur. Die Wirkung liest
/// den Abend nur (Runde, Wahl bisher, wer am Tisch eine Rolle spielt, ob ein
/// Randgespräch möglich ist) und ändert nie Optionen, Fakten, Punkte, Ende,
/// Würfelchancen oder Nachtminuten. Alles, was sie liest, ist in allen Pfaden
/// gleich (Beleg: `klasse_pfadgleich_test`, `klasse_invarianz_test`).
class KlasseWirkung implements SzenenKlasse {
  KlasseWirkung({
    required this.faehigkeit,
    required this.daten,
    required this.quelle,
    bool Function(String figur)? randgespraech,
    bool Function(String figur)? appSprichtFuer,
  })  : parameter = KlassenParameter.von(faehigkeit),
        _randgespraech = randgespraech ?? _nie,
        _appSprichtFuer = appSprichtFuer ?? _nie;

  /// Am Tisch: alles aus der laufenden [PartySitzung], nur lesend. Eine Rolle,
  /// die ein Mensch spielt, sagt nichts durch die App (R14); im Solo spielen
  /// Bots alle Rollen.
  factory KlasseWirkung.amTisch(PartySitzung s, KlassenFaehigkeit f) => KlasseWirkung(
        faehigkeit: f,
        daten: s.daten,
        quelle: SitzungsKartenQuelle(s),
        randgespraech: s.randgespraechMoeglich,
        appSprichtFuer: (figur) => s.solo || !s.besetzt.contains(figur),
      );

  /// Die Wirkung der Klasse [klasse] dieses Geräts am Tisch, wenn die Akte
  /// Klassen hat (`AkteInfo.hat('klassen')`); sonst `null`, und die Karte
  /// bleibt wie bisher.
  static KlasseWirkung? fuer(PartySitzung s, String? klasse) {
    final f = KlassenFaehigkeit.vonKlasse(klasse);
    if (f == null || !s.daten.hat('klassen')) return null;
    return KlasseWirkung.amTisch(s, f);
  }

  /// Wie [fuer] mit der gewählten Klasse dieses Geräts (Ausrüstung im
  /// [MetaStore]); ohne MetaStore (Tests) keine Klasse.
  static KlasseWirkung? diesesGeraets(BuildContext context, PartySitzung s) => fuer(s, context.read<MetaStore?>()?.loadout.cls);

  final KlassenFaehigkeit faehigkeit;
  final KlassenParameter parameter;
  final PartyDaten daten;
  final KartenQuelle quelle;
  final bool Function(String figur) _randgespraech;
  final bool Function(String figur) _appSprichtFuer;

  static bool _nie(String _) => false;

  @override
  double get glanzRadius => parameter.glanzRadius;

  @override
  double get tempoFaktor => parameter.tempoFaktor;

  @override
  bool get tuerenZeigen => parameter.tuerenZeigen;

  @override
  bool get stimmungZeigen => parameter.stimmungZeigen;

  @override
  bool gespraechsMarker(String npcId) {
    if (!parameter.gespraechsMarker) return false;
    final figur = daten.kanonKennung[npcId];
    return figur != null && _randgespraech(figur);
  }

  /// Eine Zeile aus `geruechte.json` für Figur und Runde. Mit jeder getroffenen
  /// Entscheidung kommt die nächste Zeile dran (die Zahl der Entscheidungen
  /// ist in allen Pfaden gleich).
  @override
  String? geruechtFuer(String npcId) {
    final g = daten.geruechte;
    final figur = daten.kanonKennung[npcId];
    if (!parameter.geruechte || g == null || figur == null || !_appSprichtFuer(figur)) return null;
    final zeilen = g.zeilen(figur, quelle.runde.clamp(1, 3));
    return zeilen.isEmpty ? null : zeilen[quelle.gewaehlt.length % zeilen.length];
  }
}
