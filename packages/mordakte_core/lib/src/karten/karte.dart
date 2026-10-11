/// Dauerhafte Sammelkarten der Mordakte (A-017): Jede Figur jeder Akte und jede
/// Detektivklasse hat eigene Karten. Karten werden im Spiel erspielt und wirken
/// nur über einen geschlossenen Katalog von Komfort-Wirkungen. Keine Karte
/// berührt Option, Fakten, Punkte, Ende oder Restverdächtige (K-14, K-15, WÜ-4),
/// und Bots halten nie Karten (K-20).
library;

/// Geschlossener Wirkungskatalog. Jede Art ist eine Quelle innerhalb einer schon
/// vorhandenen Kategorie (K-07): Werkzeug, Marke, Nachtminuten, Kostenfreiheit.
enum KartenArt {
  /// +1 auf den nächsten Suchwurf (Werkzeug aus der Welt, Deckel +2 bleibt).
  werkzeug,

  /// Eine Seifenblasen-Marke in den Bestand (Grenzen 1/2/3 bleiben).
  marke,

  /// Nachtminuten dazu ([KartenDef.wert], einmal je Runde und Ladung).
  zeit,

  /// „Gründlich“ ohne die zwei Nachtminuten.
  gruendlich,

  /// Nochmal nach Pech ohne Nachtminuten.
  nochmal,

  /// Umweg nach Pech ohne Nachtminuten.
  umweg,

  /// Ein Abstecher ohne Nachtminuten.
  abstecher,

  /// Wiederholt nur bereits öffentliche Sprechblasen (reine Anzeige).
  erinnerung,

  /// Aussehen (Mantel, Hut, Würfelbild) ohne Spielwirkung.
  kosmetik;

  static KartenArt aus(String name) => KartenArt.values.firstWhere((a) => a.name == name,
      orElse: () => throw FormatException('unbekannte Kartenart $name'));

  /// Wirkt im Spiel (alles außer Kosmetik).
  bool get spielbar => this != KartenArt.kosmetik;
}

enum Seltenheit {
  gewoehnlich,
  selten,
  legendaer;

  static Seltenheit aus(String name) => Seltenheit.values.firstWhere((s) => s.name == name,
      orElse: () => throw FormatException('unbekannte Seltenheit $name'));
}

/// Woher eine Karte kommt (Belohnungsregeln).
class KartenQuelle {
  /// `rolle` (am Abendende für die eigene Rolle/Klasse), `taeter` (richtige
  /// Anklage), `meister` (Meister-Ende), `abstecher` (Fund bei der Erkundung),
  /// `start` (Startset einer neuen Sammlung).
  final String art;
  final String? abstecher;
  const KartenQuelle(this.art, {this.abstecher});

  factory KartenQuelle.fromJson(Map j) => KartenQuelle(j['art'] as String, abstecher: j['abstecher'] as String?);
  Map<String, Object?> toJson() => {'art': art, if (abstecher != null) 'abstecher': abstecher};
}

/// Eine Karte des Katalogs. Kennung: `<akte>:<figur>:<slug>`.
class KartenDef {
  final String id;
  final String akte;

  /// Kanon-Figur der Akte oder `klasse:<name>` für Detektivklassen.
  final String figur;
  final Seltenheit seltenheit;
  final KartenArt art;
  final int ladungen;

  /// Stärke bei Zeit-Karten (Nachtminuten); sonst 1.
  final int wert;
  final String titel;
  final String text;

  /// Bildmotiv (Gegenstand oder Pose) für die gemalte Kartenvorderseite.
  final String? motiv;
  final List<KartenQuelle> quellen;

  const KartenDef({
    required this.id,
    required this.akte,
    required this.figur,
    required this.seltenheit,
    required this.art,
    this.ladungen = 1,
    this.wert = 1,
    required this.titel,
    required this.text,
    this.motiv,
    this.quellen = const [],
  });

  factory KartenDef.fromJson(Map j) => KartenDef(
        id: j['id'] as String,
        akte: j['akte'] as String,
        figur: j['figur'] as String,
        seltenheit: Seltenheit.aus(j['seltenheit'] as String),
        art: KartenArt.aus(j['art'] as String),
        ladungen: j['ladungen'] as int? ?? 1,
        wert: j['wert'] as int? ?? 1,
        titel: j['titel'] as String,
        text: j['text'] as String,
        motiv: j['motiv'] as String?,
        quellen: [for (final q in (j['quellen'] as List? ?? const [])) KartenQuelle.fromJson(q as Map)],
      );

  Map<String, Object?> toJson() => {
        'id': id, 'akte': akte, 'figur': figur, 'seltenheit': seltenheit.name, 'art': art.name,
        'ladungen': ladungen, 'wert': wert, 'titel': titel, 'text': text,
        if (motiv != null) 'motiv': motiv,
        'quellen': [for (final q in quellen) q.toJson()],
      };

  bool hatQuelle(String art, {String? abstecher}) =>
      quellen.any((q) => q.art == art && (abstecher == null || q.abstecher == abstecher));
}

/// Alle Karten aller Akten.
class KartenKatalog {
  final Map<String, KartenDef> karten;
  KartenKatalog(Iterable<KartenDef> liste) : karten = {for (final k in liste) k.id: k};

  /// Aus den Inhalten `content/karten/<akte>.json` (je `{"karten": [...]}`).
  factory KartenKatalog.ausDateien(Iterable<Map<String, Object?>> dateien) => KartenKatalog([
        for (final d in dateien)
          for (final k in (d['karten'] as List? ?? const [])) KartenDef.fromJson(k as Map),
      ]);

  KartenDef? operator [](String id) => karten[id];
  Iterable<KartenDef> get alle => karten.values;
  List<KartenDef> vonFigur(String akte, String figur) =>
      [for (final k in karten.values) if (k.akte == akte && k.figur == figur) k];
  List<KartenDef> vonAkte(String akte) => [for (final k in karten.values) if (k.akte == akte) k];

  /// Befunde zur Katalogqualität (leer heißt gut).
  List<String> pruefe() {
    final f = <String>[];
    for (final k in karten.values) {
      final teile = k.id.split(':');
      if (teile.length != 3 || teile[0] != k.akte) f.add('${k.id}: Kennung nicht <akte>:<figur>:<slug>');
      if (k.ladungen < 1 || k.ladungen > 2) f.add('${k.id}: Ladungen ${k.ladungen} außerhalb 1..2');
      if (k.art == KartenArt.zeit && (k.wert < 3 || k.wert > 5)) f.add('${k.id}: Zeit-Karte mit Wert ${k.wert} statt 3..5');
      if (k.art != KartenArt.zeit && k.wert != 1) f.add('${k.id}: Wert nur bei Zeit-Karten');
      if (k.titel.trim().isEmpty || k.text.trim().isEmpty) f.add('${k.id}: Titel oder Text fehlt');
      if (k.quellen.isEmpty) f.add('${k.id}: keine Quelle, also nie erhältlich');
    }
    return f;
  }
}
