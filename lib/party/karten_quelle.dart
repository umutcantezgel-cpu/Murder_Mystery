import 'dart:collection';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'sitzung.dart';

/// Was die Karte vom Abend wissen muss (M1.5): Phase, Runde, laufende
/// Entscheidung, die Wahl bisher, der laufende Zug und die offenen Abstecher.
/// Mehr liest eine Szene (`WeltSzene`) nicht; so kann sie auch auf einem Gerät
/// laufen, das den Abend nur aus einer Ansicht kennt. Nicht zu verwechseln mit
/// der Herkunft einer Sammelkarte (`KartenQuelle` aus `runden.dart`); wer beide
/// Bibliotheken einbindet, blendet jene mit `hide` aus.
abstract interface class KartenQuelle {
  PartyPhase get phase;

  int get runde;

  /// Entscheidung, auf die die Karte gerade zeigt; `null` ohne offene Frage.
  Entscheidung? get laufendeEntscheidung;

  /// Gewählte Option je Entscheidung.
  Map<String, String> get gewaehlt;

  /// Laufender Zug (Lauf, Wurf, Tischruf, Fund), sonst `null`.
  RundenZug? get zug;

  /// Erkundungsorte, die gerade gewählt werden können.
  List<AbstecherOrt> get abstecherOffen;
}

/// Die Karte am Tisch: alles aus der laufenden [PartySitzung].
class SitzungsKartenQuelle implements KartenQuelle {
  SitzungsKartenQuelle(this.sitzung);

  final PartySitzung sitzung;

  @override
  PartyPhase get phase => sitzung.phase;

  @override
  int get runde => sitzung.runde;

  @override
  Entscheidung? get laufendeEntscheidung => sitzung.laufendeEntscheidung;

  @override
  Map<String, String> get gewaehlt => UnmodifiableMapView(sitzung.spiel.gewaehlt);

  @override
  RundenZug? get zug => sitzung.zug;

  @override
  List<AbstecherOrt> get abstecherOffen => sitzung.abstecherOffen;
}
