import 'karte.dart';

/// Fehler beim Ausspielen einer Karte mit festem Schlüssel.
class KartenFehler implements Exception {
  final String code;
  const KartenFehler(this.code);
  @override
  String toString() => 'KartenFehler: $code';
}

/// Tischvorrat eines Abends: höchstens [maxKarten] Karten, je Art höchstens eine,
/// zusammen höchstens [maxLadungen] Ladungen. Die Stärke hängt damit nie an der
/// Besetzung (K-06): acht Spieler bringen nicht mehr Hilfe als einer.
class TischVorrat {
  static const maxKarten = 3;
  static const maxLadungen = 4;

  final List<KartenDef> karten;
  final Map<String, int> _rest;

  /// Zeit-Karten wirken höchstens einmal je Runde.
  final Map<String, int> _zeitRunde = {};

  TischVorrat._(this.karten, this._rest);

  /// Leerer Vorrat (Bots, Druckspiel, ohne Deck).
  factory TischVorrat.leer() => TischVorrat._(const [], {});

  /// Baut den Vorrat aus den gewünschten Kartenkennungen in Reihenfolge. Nicht
  /// spielbare, doppelte Arten und Überzähliges werden still weggelassen.
  factory TischVorrat.aus(Iterable<String> wunsch, KartenKatalog katalog) {
    final karten = <KartenDef>[];
    final arten = <KartenArt>{};
    var ladungen = 0;
    for (final id in wunsch) {
      final k = katalog[id];
      if (k == null || !k.art.spielbar || arten.contains(k.art)) continue;
      if (karten.length >= maxKarten || ladungen + k.ladungen > maxLadungen) continue;
      karten.add(k);
      arten.add(k.art);
      ladungen += k.ladungen;
    }
    return TischVorrat._(List.unmodifiable(karten), {for (final k in karten) k.id: k.ladungen});
  }

  int rest(String id) => _rest[id] ?? 0;
  bool verfuegbar(String id) => rest(id) > 0;

  KartenDef? karte(String id) {
    for (final k in karten) {
      if (k.id == id) return k;
    }
    return null;
  }

  /// Prüft Art und Ladung, ohne zu verbrauchen.
  KartenDef pruefe(String id, Set<KartenArt> erlaubt, {int? runde}) {
    final k = karte(id) ?? (throw const KartenFehler('card_unknown'));
    if (!erlaubt.contains(k.art)) throw const KartenFehler('card_wrong_moment');
    if (!verfuegbar(id)) throw const KartenFehler('card_used');
    if (k.art == KartenArt.zeit && runde != null && _zeitRunde[id] == runde) throw const KartenFehler('card_once_per_round');
    return k;
  }

  void verbrauche(String id, {int? runde}) {
    _rest[id] = rest(id) - 1;
    if (runde != null && karte(id)?.art == KartenArt.zeit) _zeitRunde[id] = runde;
  }

  List<Map<String, Object?>> toJson() => [
        for (final k in karten) {'id': k.id, 'art': k.art.name, 'rest': rest(k.id)},
      ];
}
