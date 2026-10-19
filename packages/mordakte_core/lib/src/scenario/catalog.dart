/// Feste Kataloge, die Szenario-JSON, Engine und Renderer gemeinsam benutzen.
library;

/// Kachel-Zeichen in `map.rows`.
abstract final class TileChar {
  static const wall = '#';
  static const window = 'W';
  static const floor = '.';
  static const door = '+';
  static const lockedDoor = 'L';
  static const void_ = ' ';
}

/// Bodenstile für Räume (Renderer zeichnet sie prozedural).
const floorStyles = <String>{
  'parquet', 'planks', 'carpet', 'checker', 'tiles', 'stone', 'metal',
  'linoleum', 'grass', 'gravel', 'asphalt', 'snow',
};

/// Prop-Typ: blockiert Bewegung? Höhe in Kachel-Einheiten (für Renderer).
class PropSpec {
  final bool blocks;
  final double height;

  /// Hohe Props werden transparent, wenn sie den eigenen Spieler verdecken.
  bool get tall => height >= 1.2;

  /// Lichtquelle (Renderer: warmer Schein, auch nachts).
  final bool light;

  const PropSpec(this.blocks, this.height, {this.light = false});
}

const propCatalog = <String, PropSpec>{
  'table': PropSpec(true, 0.45),
  'chair': PropSpec(true, 0.5),
  'armchair': PropSpec(true, 0.55),
  'sofa': PropSpec(true, 0.5),
  'bed': PropSpec(true, 0.45),
  'desk': PropSpec(true, 0.5),
  'bookshelf': PropSpec(true, 1.6),
  'cabinet': PropSpec(true, 1.3),
  'wardrobe': PropSpec(true, 1.7),
  'piano': PropSpec(true, 0.8),
  'fireplace': PropSpec(true, 1.2, light: true),
  'plant': PropSpec(true, 0.9),
  'lamp': PropSpec(true, 1.4, light: true),
  'clock': PropSpec(true, 1.8),
  'crate': PropSpec(true, 0.6),
  'barrel': PropSpec(true, 0.7),
  'bathtub': PropSpec(true, 0.45),
  'sink': PropSpec(true, 0.6),
  'toilet': PropSpec(true, 0.5),
  'counter': PropSpec(true, 0.6),
  'stove': PropSpec(true, 0.6),
  'fridge': PropSpec(true, 1.5),
  'seat': PropSpec(true, 0.6),
  'luggage': PropSpec(true, 0.4),
  'statue': PropSpec(true, 1.6),
  'vending': PropSpec(true, 1.5, light: true),
  'neon_sign': PropSpec(true, 1.2, light: true),
  'pool_table': PropSpec(true, 0.5),
  'bar_stool': PropSpec(true, 0.5),
  'tv': PropSpec(true, 0.6, light: true),
  'bush': PropSpec(true, 0.7),
  'tree': PropSpec(true, 2.0),
  'car': PropSpec(true, 0.9),
  'candles': PropSpec(true, 0.5, light: true),
  // Partymodus (F4-ORCH-06): Möbel des Schlosskellers ohne Flaschen.
  'party_tafel': PropSpec(true, 0.45),
  'party_buffet': PropSpec(true, 0.45),
  'party_theke': PropSpec(true, 0.6),
  'party_anrichte': PropSpec(true, 0.6),
  'party_teekocher': PropSpec(true, 1.05),
  'party_kaffee': PropSpec(true, 0.97),
  'party_kamin': PropSpec(true, 1.2),
  'party_wendeltreppe': PropSpec(true, 1.8),
  'party_ruestung': PropSpec(true, 1.7),
  'party_jackenstaender': PropSpec(true, 1.6),
  // Langer Abend (M7a): Hof, Garten, Turm und Außenwelt, Halle und Küche.
  'party_hecke': PropSpec(true, 0.9),
  'party_brunnen': PropSpec(true, 0.8),
  'party_bank': PropSpec(true, 0.5),
  'party_tor': PropSpec(true, 1.8),
  'party_zinne': PropSpec(true, 0.9),
  'party_laterne': PropSpec(true, 2.1, light: true),
  'party_beet': PropSpec(true, 0.35),
  'party_herd': PropSpec(true, 0.9),
  'party_truhe': PropSpec(true, 0.5),
  // Dekor, begehbar:
  'party_ascheneimer': PropSpec(false, 0.35),
  'party_kerzenstaender': PropSpec(false, 0.1),
  'party_stufen': PropSpec(false, 0.05),
  'rug': PropSpec(false, 0.0),
  'bloodstain': PropSpec(false, 0.0),
  'papers': PropSpec(false, 0.0),
  'puddle': PropSpec(false, 0.0),
};

/// Hotspot-Arten.
abstract final class HotspotKind {
  /// Durchsuchen → findet Hinweise.
  static const search = 'search';

  /// Labor: analysiert alle eigenen Hinweise mit `evolve: lab`.
  static const lab = 'lab';

  /// Versteck: unsichtbar für den Schatten, solange man drin ist.
  static const hide = 'hide';

  /// Nur mit Effekt `sight` sichtbar (Forensikerin-Fähigkeit).
  static const blood = 'blood';

  /// Leiche des Opfers.
  static const body = 'body';

  static const all = {search, lab, hide, blood, body};
}

/// Item-Typen auf der Map.
abstract final class ItemType {
  static const coffee = 'coffee';
  static const battery = 'battery';
  static const salts = 'salts';
  static const antidote = 'antidote';
  static const medkit = 'medkit';
  static const flare = 'flare';

  /// Nur von der Engine erzeugt: Spur, die der Schatten nachts hinterlässt.
  /// Aufheben → Sichtungs-Hinweis (ein Merkmal des Täters).
  static const trace = 'trace';

  static const all = {coffee, battery, salts, antidote, medkit, flare};
}

/// Hinweis-Arten.
abstract final class ClueKind {
  /// Verrät einen Merkmalswert des Täters (`trait`).
  static const trait = 'trait';

  /// Verrät das echte Motiv.
  static const motive = 'motive';

  /// Verrät die echte Tatwaffe.
  static const weapon = 'weapon';

  /// Bestätigt oder widerlegt das Alibi von `subject`.
  static const alibi = 'alibi';

  /// Reiner Story-Hinweis (fester Text).
  static const story = 'story';

  /// Von der Engine erzeugt (Sichtung, Widerspruch, Notizen eines Toten).
  static const generated = 'generated';

  static const authored = {trait, motive, weapon, alibi, story};
}

/// Wie sich ein Hinweis weiterentwickelt (Stufe 0 „gefunden“ → Stufe 1 „aufgedeckt“).
abstract final class Evolve {
  /// Sofort aufgedeckt.
  static const none = 'none';

  /// Muss im Labor analysiert werden.
  static const lab = 'lab';

  /// Deckt sich nach `chapters` Kapitelwechseln selbst auf.
  static const time = 'time';

  static const all = {none, lab, time};
}

/// Gesprächsthemen bei Verhören.
abstract final class Topic {
  static const alibi = 'alibi';
  static const victim = 'victim';
  static const observation = 'observation';

  /// Nur für die Journalistin.
  static const rumor = 'rumor';

  static const all = [alibi, victim, observation, rumor];
}
