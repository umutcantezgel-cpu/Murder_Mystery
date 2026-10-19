import '../util/geom.dart';
import '../util/ltext.dart';
import 'catalog.dart';

/// Ein komplettes, vorgefertigtes Szenario (aus `content/scenarios/*.json`).
///
/// Das Format ist in `content/SCHEMA.md` beschrieben.
class ScenarioDef {
  final String id;
  final LText title;
  final LText tagline;
  final LText synopsis;
  final int difficulty;
  final int minutes;
  final ThemeDef theme;
  final MapDef map;
  final List<HotspotDef> hotspots;
  final List<ItemDef> items;
  final VictimDef victim;
  final Map<String, TraitDef> traits;
  final List<SuspectDef> suspects;
  final List<MotiveDef> motives;
  final List<WeaponDef> weapons;
  final CaseTruthDef story;
  final List<ClueDef> clues;
  final List<ComboDef> combos;
  final List<ChapterDef> chapters;
  final EndingsDef endings;

  ScenarioDef({
    required this.id,
    required this.title,
    required this.tagline,
    required this.synopsis,
    required this.difficulty,
    required this.minutes,
    required this.theme,
    required this.map,
    required this.hotspots,
    required this.items,
    required this.victim,
    required this.traits,
    required this.suspects,
    required this.motives,
    required this.weapons,
    required this.story,
    required this.clues,
    required this.combos,
    required this.chapters,
    required this.endings,
  });

  late final Map<String, HotspotDef> hotspotById = {for (final h in hotspots) h.id: h};
  late final Map<String, SuspectDef> suspectById = {for (final s in suspects) s.id: s};
  late final Map<String, ClueDef> clueById = {for (final c in clues) c.id: c};
  late final Map<String, MotiveDef> motiveById = {for (final m in motives) m.id: m};
  late final Map<String, WeaponDef> weaponById = {for (final w in weapons) w.id: w};
  late final Map<String, ItemDef> itemById = {for (final i in items) i.id: i};
  late final Map<String, LeadDef> leadById = {
    for (final ch in chapters)
      for (final l in ch.leads) l.id: l,
  };
  late final Map<String, ComboDef> comboById = {for (final c in combos) c.id: c};

  List<SuspectDef> get candidates => suspects.where((s) => s.candidate).toList();

  factory ScenarioDef.fromJson(Map<String, dynamic> j) {
    return _wrap('scenario', () {
      return ScenarioDef(
        id: j['id'] as String,
        title: LText.fromJson(j['title']),
        tagline: LText.fromJson(j['tagline']),
        synopsis: LText.fromJson(j['synopsis']),
        difficulty: (j['difficulty'] as num? ?? 1).toInt(),
        minutes: (j['minutes'] as num? ?? 25).toInt(),
        theme: _wrap('theme', () => ThemeDef.fromJson(_map(j['theme']))),
        map: _wrap('map', () => MapDef.fromJson(_map(j['map']))),
        hotspots: _list(j['hotspots'], 'hotspots', HotspotDef.fromJson),
        items: _list(j['items'], 'items', ItemDef.fromJson),
        victim: _wrap('victim', () => VictimDef.fromJson(_map(j['victim']))),
        traits: {
          for (final e in _map(j['traits']).entries)
            e.key: _wrap('traits.${e.key}', () => TraitDef.fromJson(e.key, _map(e.value))),
        },
        suspects: _list(j['suspects'], 'suspects', SuspectDef.fromJson),
        motives: _list(j['motives'], 'motives', MotiveDef.fromJson),
        weapons: _list(j['weapons'], 'weapons', WeaponDef.fromJson),
        story: _wrap('story', () => CaseTruthDef.fromJson(_map(j['story']))),
        clues: _list(j['clues'], 'clues', ClueDef.fromJson),
        combos: _list(j['combos'], 'combos', ComboDef.fromJson),
        chapters: _list(j['chapters'], 'chapters', ChapterDef.fromJson),
        endings: _wrap('endings', () => EndingsDef.fromJson(_map(j['endings']))),
      );
    });
  }
}

class ThemeDef {
  /// Farbpalette als `#rrggbb`-Strings. Pflicht-Schlüssel siehe [paletteKeys].
  final Map<String, String> palette;

  /// `rain`, `snow`, `neon`, `dust` oder `none`.
  final String weather;
  final bool lightning;

  /// Kulisse rund um die Karte (nur Darstellung): `none`, `keller`, `burg`,
  /// `garten`, `gleis`, `motel` oder `schloss` (Ebenen des langen Abends).
  final String backdrop;

  /// Helligkeit bei Tag (0..1) und Restlicht in der Nacht (0..1).
  final double dayAmbient;
  final double nightAmbient;

  static const paletteKeys = [
    'background', 'floor', 'floorAlt', 'wall', 'wallTop', 'trim',
    'accent', 'light', 'danger', 'text', 'fog',
  ];

  static const weathers = {'rain', 'snow', 'neon', 'dust', 'none'};
  static const backdrops = {'none', 'keller', 'burg', 'garten', 'gleis', 'motel', 'schloss'};

  ThemeDef({
    required this.palette,
    required this.weather,
    required this.lightning,
    this.backdrop = 'none',
    required this.dayAmbient,
    required this.nightAmbient,
  });

  factory ThemeDef.fromJson(Map<String, dynamic> j) => ThemeDef(
        palette: {
          for (final e in _map(j['palette']).entries) e.key: e.value as String,
        },
        weather: j['weather'] as String? ?? 'none',
        lightning: j['lightning'] as bool? ?? false,
        backdrop: j['backdrop'] as String? ?? 'none',
        dayAmbient: (j['dayAmbient'] as num? ?? 0.85).toDouble(),
        nightAmbient: (j['nightAmbient'] as num? ?? 0.1).toDouble(),
      );

  /// Farbe als ARGB-Int (Flutter `Color(int)`).
  int color(String key) {
    final hex = (palette[key] ?? '#ff00ff').replaceFirst('#', '');
    final v = int.parse(hex.length == 6 ? 'ff$hex' : hex, radix: 16);
    return v;
  }
}

class MapDef {
  /// ASCII-Zeilen, siehe [TileChar].
  final List<String> rows;
  final List<RoomDef> rooms;
  final List<PropDef> props;
  final List<Pt> spawn;
  final String councilRoom;

  MapDef({
    required this.rows,
    required this.rooms,
    required this.props,
    required this.spawn,
    required this.councilRoom,
  });

  int get height => rows.length;
  int get width => rows.fold(0, (m, r) => r.length > m ? r.length : m);

  /// Zeichen an (x, y); außerhalb = Leere.
  String charAt(int x, int y) {
    if (y < 0 || y >= rows.length) return TileChar.void_;
    final r = rows[y];
    if (x < 0 || x >= r.length) return TileChar.void_;
    return r[x];
  }

  late final Map<Pt, PropDef> propAt = {for (final p in props) Pt(p.x, p.y): p};

  RoomDef? roomAt(int x, int y) {
    for (final r in rooms) {
      if (x >= r.x && y >= r.y && x < r.x + r.w && y < r.y + r.h) return r;
    }
    return null;
  }

  late final Map<String, RoomDef> roomById = {for (final r in rooms) r.id: r};

  factory MapDef.fromJson(Map<String, dynamic> j) => MapDef(
        rows: (j['rows'] as List).cast<String>(),
        rooms: _list(j['rooms'], 'rooms', RoomDef.fromJson),
        props: _list(j['props'], 'props', PropDef.fromJson),
        spawn: (j['spawn'] as List).map(Pt.fromJson).toList(),
        councilRoom: j['councilRoom'] as String,
      );
}

class RoomDef {
  final String id;
  final LText name;
  final int x, y, w, h;
  final String floor;

  /// Beleuchteter Schutzraum: Der Schatten greift hier nicht an.
  final bool lit;
  final bool outdoor;

  RoomDef({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.floor,
    required this.lit,
    required this.outdoor,
  });

  double get cx => x + w / 2;
  double get cy => y + h / 2;

  factory RoomDef.fromJson(Map<String, dynamic> j) => RoomDef(
        id: j['id'] as String,
        name: LText.fromJson(j['name']),
        x: _int(j['x']),
        y: _int(j['y']),
        w: _int(j['w']),
        h: _int(j['h']),
        floor: j['floor'] as String? ?? 'planks',
        lit: j['lit'] as bool? ?? false,
        outdoor: j['outdoor'] as bool? ?? false,
      );
}

class PropDef {
  final String type;
  final int x, y;

  /// Optionale Farbüberschreibung `#rrggbb`.
  final String? color;

  PropDef({required this.type, required this.x, required this.y, this.color});

  PropSpec get spec => propCatalog[type] ?? const PropSpec(true, 0.5);

  factory PropDef.fromJson(Map<String, dynamic> j) => PropDef(
        type: j['type'] as String,
        x: _int(j['x']),
        y: _int(j['y']),
        color: j['color'] as String?,
      );
}

/// Bedingung, damit etwas verfügbar ist.
class Requirement {
  /// Detektiv-Klasse, z. B. `forensic`.
  final String? cls;

  /// Spur, die in einer Beratung gewählt wurde.
  final String? lead;

  const Requirement({this.cls, this.lead});

  static const none = Requirement();

  bool get isNone => cls == null && lead == null;

  factory Requirement.fromJson(Object? j) {
    if (j == null) return none;
    final m = _map(j);
    return Requirement(cls: m['class'] as String?, lead: m['lead'] as String?);
  }
}

class HotspotDef {
  final String id;
  final LText name;
  final int x, y;
  final String kind;
  final int? searchMs;
  final Requirement requires;
  final int fromChapter;

  /// Nur für Geister sichtbar (Echo-Spuren).
  final bool ghost;

  HotspotDef({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.kind,
    required this.searchMs,
    required this.requires,
    required this.fromChapter,
    required this.ghost,
  });

  factory HotspotDef.fromJson(Map<String, dynamic> j) => HotspotDef(
        id: j['id'] as String,
        name: LText.fromJson(j['name']),
        x: _int(j['x']),
        y: _int(j['y']),
        kind: j['kind'] as String? ?? HotspotKind.search,
        searchMs: (j['searchMs'] as num?)?.toInt(),
        requires: Requirement.fromJson(j['requires']),
        fromChapter: (j['fromChapter'] as num? ?? 1).toInt(),
        ghost: j['ghost'] as bool? ?? false,
      );
}

class ItemDef {
  final String id;
  final String type;
  final int x, y;
  final int chapter;

  ItemDef({required this.id, required this.type, required this.x, required this.y, required this.chapter});

  factory ItemDef.fromJson(Map<String, dynamic> j) => ItemDef(
        id: j['id'] as String,
        type: j['type'] as String,
        x: _int(j['x']),
        y: _int(j['y']),
        chapter: (j['chapter'] as num? ?? 1).toInt(),
      );
}

class VictimDef {
  final LText name;
  final LText text;
  final String hotspot;

  /// Aussehen der Leiche (wie [LookDef]).
  final LookDef look;

  VictimDef({required this.name, required this.text, required this.hotspot, required this.look});

  factory VictimDef.fromJson(Map<String, dynamic> j) => VictimDef(
        name: LText.fromJson(j['name']),
        text: LText.fromJson(j['text']),
        hotspot: j['hotspot'] as String,
        look: LookDef.fromJson(_map(j['look'] ?? const {})),
      );
}

class TraitDef {
  final String id;
  final LText label;
  final Map<String, LText> values;

  TraitDef({required this.id, required this.label, required this.values});

  factory TraitDef.fromJson(String id, Map<String, dynamic> j) => TraitDef(
        id: id,
        label: LText.fromJson(j['label']),
        values: {
          for (final e in _map(j['values']).entries) e.key: LText.fromJson(e.value),
        },
      );
}

/// Aussehen einer code-gezeichneten Figur.
class LookDef {
  final String coat;
  final String skin;
  final String hair;

  /// `none`, `bowler`, `fedora`, `cap`, `bun`, `top`, `beret`, `cloche`, `kopftuch`.
  final String hat;

  /// `slim`, `normal`, `broad`, `tall`, `small`.
  final String build;

  /// `suit` (Mantel/Anzug) oder `dress` (Kleid).
  final String outfit;

  /// Optionale Farbe der Kopfbedeckung `#rrggbb` (z. B. Kopftuch); ohne Angabe
  /// leitet der Renderer sie wie bisher aus der Mantelfarbe ab.
  final String? headColor;

  /// Optional `w`, `m` oder `d` (aus dem Kanon); nur für die Darstellung
  /// (etwa kein Bart). Ohne Angabe entscheidet der Renderer nach der Kleidung.
  final String? gender;

  const LookDef({
    this.coat = '#3a3a44',
    this.skin = '#e0b89a',
    this.hair = '#3b2a20',
    this.hat = 'none',
    this.build = 'normal',
    this.outfit = 'suit',
    this.headColor,
    this.gender,
  });

  static const hats = {'none', 'bowler', 'fedora', 'cap', 'bun', 'top', 'beret', 'cloche', 'kopftuch'};
  static const builds = {'slim', 'normal', 'broad', 'tall', 'small'};
  static const outfits = {'suit', 'dress'};

  bool get dress => outfit == 'dress';

  factory LookDef.fromJson(Map<String, dynamic> j) => LookDef(
        coat: j['coat'] as String? ?? '#3a3a44',
        skin: j['skin'] as String? ?? '#e0b89a',
        hair: j['hair'] as String? ?? '#3b2a20',
        hat: j['hat'] as String? ?? 'none',
        build: j['build'] as String? ?? 'normal',
        outfit: j['outfit'] as String? ?? 'suit',
        headColor: j['headColor'] as String?,
        gender: j['gender'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'coat': coat,
        'skin': skin,
        'hair': hair,
        'hat': hat,
        'build': build,
        'outfit': outfit,
        if (headColor != null) 'headColor': headColor,
        if (gender != null) 'gender': gender,
      };
}

class SuspectDef {
  final String id;
  final LText name;
  final LText role;
  final LText bio;
  final LookDef look;
  final int x, y;
  final Map<String, String> traits;

  /// Kann der Täter sein.
  final bool candidate;

  /// Motive, die diese Person als Täter haben kann.
  final List<String> motives;

  /// Waffen, zu denen diese Person Zugang hatte (leer = Zugang zu allen).
  final List<String> weapons;

  /// Kann nachts vom Schatten getötet werden (wenn nicht Täter).
  final bool witness;

  /// Dialogzeilen: `greet`, `alibi`, `alibiLie`, `victim`, `observation`, `rumor`,
  /// `nervous`, `annoyed`.
  final Map<String, LText> lines;

  SuspectDef({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.look,
    required this.x,
    required this.y,
    required this.traits,
    required this.candidate,
    required this.motives,
    this.weapons = const [],
    required this.witness,
    required this.lines,
  });

  LText line(String key) => lines[key] ?? LText.empty;

  /// Hatte diese Person Zugang zur Waffe [weaponId]?
  bool canAccessWeapon(String? weaponId) => weaponId != null && (weapons.isEmpty || weapons.contains(weaponId));

  factory SuspectDef.fromJson(Map<String, dynamic> j) => SuspectDef(
        id: j['id'] as String,
        name: LText.fromJson(j['name']),
        role: LText.fromJson(j['role']),
        bio: LText.fromJson(j['bio']),
        look: LookDef.fromJson(_map(j['look'] ?? const {})),
        x: _int(j['x']),
        y: _int(j['y']),
        traits: {for (final e in _map(j['traits']).entries) e.key: e.value as String},
        candidate: j['candidate'] as bool? ?? true,
        motives: (j['motives'] as List? ?? const []).cast<String>(),
        weapons: (j['weapons'] as List? ?? const []).cast<String>(),
        witness: j['witness'] as bool? ?? true,
        lines: {for (final e in _map(j['lines']).entries) e.key: LText.fromJson(e.value)},
      );
}

class MotiveDef {
  final String id;
  final LText name;

  /// Text des aufgedeckten Motiv-Hinweises.
  final LText reveal;

  MotiveDef({required this.id, required this.name, required this.reveal});

  factory MotiveDef.fromJson(Map<String, dynamic> j) => MotiveDef(
        id: j['id'] as String,
        name: LText.fromJson(j['name']),
        reveal: LText.fromJson(j['reveal']),
      );
}

class WeaponDef {
  final String id;
  final LText name;
  final LText reveal;

  WeaponDef({required this.id, required this.name, required this.reveal});

  factory WeaponDef.fromJson(Map<String, dynamic> j) => WeaponDef(
        id: j['id'] as String,
        name: LText.fromJson(j['name']),
        reveal: LText.fromJson(j['reveal']),
      );
}

/// Die Wahrheit eines Falls.
class CaseTruthDef {
  final String culprit;
  final String motive;
  final String weapon;

  const CaseTruthDef({required this.culprit, required this.motive, required this.weapon});

  factory CaseTruthDef.fromJson(Map<String, dynamic> j) => CaseTruthDef(
        culprit: j['culprit'] as String,
        motive: j['motive'] as String,
        weapon: j['weapon'] as String,
      );

  Map<String, dynamic> toJson() => {'culprit': culprit, 'motive': motive, 'weapon': weapon};

  @override
  bool operator ==(Object other) =>
      other is CaseTruthDef && other.culprit == culprit && other.motive == motive && other.weapon == weapon;

  @override
  int get hashCode => Object.hash(culprit, motive, weapon);
}

/// Woher ein Hinweis stammt.
class ClueSource {
  final String? hotspot;
  final String? npc;
  final String? topic;

  const ClueSource({this.hotspot, this.npc, this.topic});

  factory ClueSource.fromJson(Map<String, dynamic> j) => ClueSource(
        hotspot: j['hotspot'] as String?,
        npc: j['npc'] as String?,
        topic: j['topic'] as String?,
      );
}

class ClueDef {
  final String id;
  final String kind;

  /// Bei `trait`: welches Merkmal.
  final String? trait;

  /// Bei `alibi`: wessen Alibi.
  final String? subject;

  final LText name;

  /// Text auf Stufe 0 (gefunden, noch nicht aufgedeckt).
  final LText found;

  /// Text auf Stufe 1. Bei `trait` mit `{value}`; bei `alibi` der Text für ein
  /// stimmiges Alibi.
  final LText reveal;

  /// Bei `alibi`: Text, wenn das Alibi gelogen ist (subject ist Täter).
  final LText revealFalse;

  final String evolve;
  final int chapters;
  final ClueSource source;
  final int chapter;

  /// Verblasst, wenn bis zum Ende dieses Kapitels nicht gefunden.
  final int? expires;

  final Requirement requires;
  final bool ghost;

  /// Löst das geheime Ende aus, wenn er bei der Anklage auf der Beweiswand ist.
  final bool secret;

  ClueDef({
    required this.id,
    required this.kind,
    required this.trait,
    required this.subject,
    required this.name,
    required this.found,
    required this.reveal,
    required this.revealFalse,
    required this.evolve,
    required this.chapters,
    required this.source,
    required this.chapter,
    required this.expires,
    required this.requires,
    required this.ghost,
    required this.secret,
  });

  factory ClueDef.fromJson(Map<String, dynamic> j) => ClueDef(
        id: j['id'] as String,
        kind: j['kind'] as String,
        trait: j['trait'] as String?,
        subject: j['subject'] as String?,
        name: LText.fromJson(j['name']),
        found: LText.fromJson(j['found']),
        reveal: LText.fromJson(j['reveal']),
        revealFalse: LText.fromJson(j['revealFalse']),
        evolve: j['evolve'] as String? ?? Evolve.none,
        chapters: (j['chapters'] as num? ?? 1).toInt(),
        source: ClueSource.fromJson(_map(j['source'])),
        chapter: (j['chapter'] as num? ?? 1).toInt(),
        expires: (j['expires'] as num?)?.toInt(),
        requires: Requirement.fromJson(j['requires']),
        ghost: j['ghost'] as bool? ?? false,
        secret: j['secret'] as bool? ?? false,
      );
}

/// Zwei Hinweise auf der Beweiswand kombinieren → Schlussfolgerung.
class ComboDef {
  final String id;
  final String a;
  final String b;
  final LText name;
  final LText text;

  /// Deckt diese Hinweise sofort auf (überspringt Labor/Zeit).
  final List<String> reveals;

  /// Fügt diese Spur zur nächsten Beratung hinzu.
  final String? lead;

  ComboDef({
    required this.id,
    required this.a,
    required this.b,
    required this.name,
    required this.text,
    required this.reveals,
    required this.lead,
  });

  factory ComboDef.fromJson(Map<String, dynamic> j) => ComboDef(
        id: j['id'] as String,
        a: j['a'] as String,
        b: j['b'] as String,
        name: LText.fromJson(j['name']),
        text: LText.fromJson(j['text']),
        reveals: (j['reveals'] as List? ?? const []).cast<String>(),
        lead: j['lead'] as String?,
      );
}

class LeadUnlock {
  final List<String> hotspots;
  final List<Pt> doors;
  final List<String> items;

  const LeadUnlock({this.hotspots = const [], this.doors = const [], this.items = const []});

  factory LeadUnlock.fromJson(Map<String, dynamic> j) => LeadUnlock(
        hotspots: (j['hotspots'] as List? ?? const []).cast<String>(),
        doors: (j['doors'] as List? ?? const []).map(Pt.fromJson).toList(),
        items: (j['items'] as List? ?? const []).cast<String>(),
      );
}

/// Eine Spur, über die in der Beratung abgestimmt wird.
class LeadDef {
  final String id;
  final LText name;
  final LText text;
  final LeadUnlock unlock;

  /// Nur angeboten, wenn dieser Hinweis auf der Beweiswand liegt.
  final String? requiresClue;

  /// Nur über eine Kombination freigeschaltet (nicht automatisch angeboten).
  final bool hidden;

  LeadDef({
    required this.id,
    required this.name,
    required this.text,
    required this.unlock,
    required this.requiresClue,
    required this.hidden,
  });

  factory LeadDef.fromJson(Map<String, dynamic> j) => LeadDef(
        id: j['id'] as String,
        name: LText.fromJson(j['name']),
        text: LText.fromJson(j['text']),
        unlock: LeadUnlock.fromJson(_map(j['unlock'] ?? const {})),
        requiresClue: j['requiresClue'] as String?,
        hidden: j['hidden'] as bool? ?? false,
      );
}

class ChapterDef {
  final LText title;
  final LText intro;

  /// Text zu Beginn der Nacht (leer im letzten Kapitel).
  final LText night;

  /// Spuren für die Beratung am Ende dieses Kapitels.
  final List<LeadDef> leads;

  ChapterDef({required this.title, required this.intro, required this.night, required this.leads});

  factory ChapterDef.fromJson(Map<String, dynamic> j) => ChapterDef(
        title: LText.fromJson(j['title']),
        intro: LText.fromJson(j['intro']),
        night: LText.fromJson(j['night']),
        leads: _list(j['leads'], 'leads', LeadDef.fromJson),
      );
}

class TitledText {
  final LText title;
  final LText text;

  TitledText({required this.title, required this.text});

  factory TitledText.fromJson(Map<String, dynamic> j) =>
      TitledText(title: LText.fromJson(j['title']), text: LText.fromJson(j['text']));
}

/// Bausteine für das zusammengesetzte Ende.
class EndingsDef {
  /// Schlüssel: `perfect`, `solid`, `partial`, `wrong`, `unsolved`.
  final Map<String, TitledText> verdict;

  /// Schlüssel: `all`, `some`, `lone`, `none`.
  final Map<String, LText> team;

  /// Pro Verdächtigem: `caught` / `escaped`.
  final Map<String, Map<String, LText>> culprit;

  /// Text für das geheime Ende.
  final LText secret;

  static const verdictKeys = ['perfect', 'solid', 'partial', 'wrong', 'unsolved'];
  static const teamKeys = ['all', 'some', 'lone', 'none'];

  EndingsDef({required this.verdict, required this.team, required this.culprit, required this.secret});

  factory EndingsDef.fromJson(Map<String, dynamic> j) => EndingsDef(
        verdict: {
          for (final e in _map(j['verdict']).entries) e.key: TitledText.fromJson(_map(e.value)),
        },
        team: {for (final e in _map(j['team']).entries) e.key: LText.fromJson(e.value)},
        culprit: {
          for (final e in _map(j['culprit']).entries)
            e.key: {for (final f in _map(e.value).entries) f.key: LText.fromJson(f.value)},
        },
        secret: LText.fromJson(j['secret']),
      );
}

// --- JSON-Helfer -----------------------------------------------------------

Map<String, dynamic> _map(Object? j) {
  if (j == null) return const {};
  return (j as Map).cast<String, dynamic>();
}

int _int(Object? j) => (j as num).toInt();

List<T> _list<T>(Object? j, String ctx, T Function(Map<String, dynamic>) f) {
  if (j == null) return <T>[];
  final l = j as List;
  return [
    for (var i = 0; i < l.length; i++) _wrap('$ctx[$i]', () => f(_map(l[i]))),
  ];
}

T _wrap<T>(String ctx, T Function() f) {
  try {
    return f();
  } on ScenarioFormatException catch (e) {
    throw ScenarioFormatException('$ctx.${e.path}', e.cause);
  } catch (e) {
    throw ScenarioFormatException(ctx, e);
  }
}

class ScenarioFormatException implements Exception {
  final String path;
  final Object cause;
  ScenarioFormatException(this.path, this.cause);

  @override
  String toString() => 'Szenario-Fehler bei $path: $cause';
}
