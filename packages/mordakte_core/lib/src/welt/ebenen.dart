/// Welt-Ebenen des langen Abends (A-056, M7a): Erdgeschoss mit Schlosshof und
/// Garten, Turm und die Außenwelt vor dem Schloss
/// (`content/welt/<akte>/langfassung.json`, Format `langfassung/1`).
///
/// Jede Ebene außer dem Keller ist ein eigener [RaumGraph] im Format von
/// `raeume.json` mit eigenem Raster. Der Keller ist der Kanon-Graph selbst
/// (`kanon.graph`, nie kopiert, nie verändert): Tatmatrix, Wahrnehmung,
/// Plausibilität und Entscheidungen sehen nur ihn. Portale verbinden Kacheln
/// zweier Ebenen (Wendeltreppe, Hoftür, Außentor, Einfahrtstor) und öffnen nach
/// einer [Oeffnung]. Die neuen Zonen sind reine Darstellung und freies Gehen:
/// keine Spur, kein Kettenglied, kein Sperrort, in allen Pfaden gleich.
library;

import '../karten/sperrwoerter.dart';
import '../party/kanon/kanon.dart';
import '../party/raumgraph.dart';
import '../party/szenario_export.dart';
import '../party/textpruefer.dart';
import '../party/zeit.dart';
import '../scenario/catalog.dart';
import '../scenario/grid.dart';
import '../scenario/scenario_def.dart';
import '../util/geom.dart';

/// Kennung des Dateiformats.
const langfassungFormat = 'langfassung/1';

/// Kennung der Kanon-Ebene.
const kellerEbene = 'keller';

/// Höchstmaße einer Ebene in Kacheln (Leistung im mobilen Web, erkundung2/1).
const ebeneHoechstBreite = 70, ebeneHoechstHoehe = 60;

/// Größte Summe aus Breite und Länge eines Raums: Darüber backt die Szene
/// den Boden nicht mehr in voller Auflösung (Grenze 4096 Bildpunkte).
const raumHoechstSumme = 75;

/// Wann ein Portal oder eine Tür einer Ebene offen ist (K1, A-056).
///
/// - [immer]: immer offen (Wendeltreppe zur Toilette, wie im Kanon).
/// - [nachErsatzschluessel]: nur im langen Abend, ab dem Ersatzschlüssel
///   (00:15) bis in den Morgen; davor und im kurzen Abend zu.
/// - [vorspielMorgen]: nur im langen Abend, im Vorspiel vor der Sperre (18:50)
///   und am Morgen ab sieben; in den Runden nie. So Außentor und Einfahrtstor:
///   Um 18:50 schließt Herr Schneider beide ab, erst die Kollegin öffnet sie
///   um sieben mit dem Torschlüssel.
/// - [nieInRunden]: nur im langen Abend und erst am Morgen ab sieben
///   (Torschlüssel der Kollegin); im Vorspiel und in den Runden zu.
/// - [vorspielNachErsatzschluessel]: nur im langen Abend, im Vorspiel vor der
///   Sperre und wieder ab dem Ersatzschlüssel bis in den Morgen; dazwischen
///   zu. So die Hoftür im Kanon: Um 18:30 läuft die Lieferung durch Hof und
///   Hoftür, um 18:50 schließt Herr Schneider ab, um 00:15 öffnet er wieder.
enum Oeffnung {
  immer('immer'),
  nachErsatzschluessel('nach_ersatzschluessel'),
  vorspielMorgen('vorspiel_morgen'),
  nieInRunden('nie_in_runden'),
  vorspielNachErsatzschluessel('vorspiel_nach_ersatzschluessel');

  const Oeffnung(this.kennung);

  /// Schreibweise in der Datei.
  final String kennung;

  static Oeffnung lies(Object? s) =>
      values.where((o) => o.kennung == s).firstOrNull ?? (throw FormatException('Langfassung: unbekannte Öffnung $s'));
}

/// Ein Zeitpunkt des Abends: Fassung (kurz oder lang) und Uhrzeit.
class WeltLage {
  const WeltLage({required this.lang, required this.uhr});

  /// Lage um [uhr] (`HH:MM`), Vorgabe langer Abend.
  WeltLage.um(String uhr, {bool lang = true}) : this(lang: lang, uhr: Uhrzeit.parse(uhr));

  final bool lang;
  final Uhrzeit uhr;

  @override
  String toString() => '${lang ? 'lang' : 'kurz'} $uhr';
}

/// Feste Zeiten der Öffnungen, gelesen aus der Kanon-Zeitleiste.
class WeltZeiten {
  const WeltZeiten({required this.sperre, required this.ersatzschluessel, required this.morgen});

  /// Herr Schneider schließt Hoftür, Einfahrtstor und Außentor ab (18:50).
  final Uhrzeit sperre;

  /// Der Ersatzschlüssel öffnet Hoftür, Turm und Seitentür (00:15).
  final Uhrzeit ersatzschluessel;

  /// Die Kollegin schließt um sieben mit dem Torschlüssel auf.
  final Uhrzeit morgen;
}

/// Eine Ebene: der Kanon-Keller oder ein eigener Raumgraph.
class Ebene {
  Ebene._({
    required this.id,
    required this.name,
    required this.stockwerk,
    required this.ausKanon,
    required this.zugang,
    required this.graph,
    required this.aussen,
    required this.kulisse,
    required this.wetter,
    required this.dunkel,
    required this.palette,
    required this.tuerBedingung,
  });

  final String id;
  final String name;
  final int stockwerk;

  /// Der Keller: [graph] ist `kanon.graph`.
  final bool ausKanon;

  /// In welchen Lagen die Ebene betreten werden darf (eine der Öffnungen genügt).
  final List<Oeffnung> zugang;
  final RaumGraph graph;

  /// Räume unter freiem Himmel (Fassaden, Wetter).
  final Set<String> aussen;

  /// Darstellung: Kulisse jenseits der Karte, Wetter, Dunkelheit der Szene
  /// (0 hell … 1 schwarz) und Farben; beim Keller `null`/leer (welt.json gilt).
  final String? kulisse;
  final String? wetter;
  final double dunkel;
  final Map<String, String>? palette;

  /// Bedingung je Tür der Ebene mit Feld `offen` (sonst gilt der Zustand).
  final Map<String, Oeffnung> tuerBedingung;
}

/// Eine Seite eines Portals: Kacheln auf der Ebene und der Ankunftspunkt davor.
class PortalSeite {
  const PortalSeite({required this.ebene, required this.kacheln, required this.ankunftX, required this.ankunftY, required this.aktion});

  final String ebene;
  final List<Pt> kacheln;
  final double ankunftX, ankunftY;

  /// Beschriftung der Handlung auf dieser Seite („Die Wendeltreppe hinauf“).
  final String aktion;

  Pt get ankunft => Pt(ankunftX.floor(), ankunftY.floor());

  factory PortalSeite._aus(Map j) {
    final a = j['ankunft'] as List;
    return PortalSeite(
      ebene: j['ebene'] as String,
      kacheln: [for (final k in j['kacheln'] as List) Pt.fromJson(k)],
      ankunftX: (a[0] as num).toDouble(),
      ankunftY: (a[1] as num).toDouble(),
      aktion: j['aktion'] as String,
    );
  }
}

/// Übergang zwischen zwei Ebenen.
class Portal {
  const Portal({required this.id, required this.art, required this.offen, required this.weg, required this.a, required this.b});

  final String id;

  /// `treppe`, `tuer` oder `tor`.
  final String art;
  final Oeffnung offen;

  /// Weg in Metern, der nicht auf den Rastern liegt (Treppenlauf).
  final double weg;
  final PortalSeite a, b;

  /// Seite auf [ebene], sonst `null`.
  PortalSeite? seiteAuf(String ebene) => a.ebene == ebene ? a : (b.ebene == ebene ? b : null);

  /// Die andere Seite.
  PortalSeite gegenueber(PortalSeite s) => identical(s, a) ? b : a;
}

/// Blick von einem Ort auf eine andere Ebene (Wehrgang über die Außenwelt).
class Ausblick {
  const Ausblick({required this.id, required this.ebene, required this.ort, required this.zeigt, required this.mitteX, required this.mitteY, required this.zoom});

  final String id;
  final String ebene;
  final String ort;
  final String zeigt;
  final double mitteX, mitteY;
  final double zoom;
}

/// Alle Ebenen einer Akte, unveränderlich.
class WeltEbenen {
  WeltEbenen._(this.akte, this.kanon, this.zeiten, this.ebenen, this.portale, this.ausblicke);

  final String akte;
  final Kanon kanon;
  final WeltZeiten zeiten;

  /// Ebenen in Dateireihenfolge, der Keller zuerst.
  final Map<String, Ebene> ebenen;
  final List<Portal> portale;
  final List<Ausblick> ausblicke;

  /// Liest `langfassung.json`. Die Kanon-Ebene (`quelle: kanon`) bekommt
  /// `kanon.graph`; die Zeiten kommen aus der Kanon-Zeitleiste.
  factory WeltEbenen.ausJson(Map<String, Object?> j, Kanon kanon) {
    if (j['format'] != langfassungFormat) throw FormatException('Langfassung: Format ${j['format']} statt $langfassungFormat');
    final z = j['zeiten'] as Map;
    Uhrzeit zeit(String name) {
      final id = z[name] as String;
      final e = kanon.zeitleiste.where((e) => e['id'] == id).firstOrNull;
      if (e == null) throw FormatException('Langfassung: Zeitleiste kennt $id nicht ($name)');
      return Uhrzeit.parse(e['zeit'] as String);
    }

    final ebenen = <String, Ebene>{};
    for (final e in (j['ebenen'] as List).cast<Map>()) {
      final id = e['id'] as String;
      final kanonisch = e['quelle'] == 'kanon';
      final st = (e['stimmung'] as Map?) ?? const {};
      ebenen[id] = Ebene._(
        id: id,
        name: e['name'] as String,
        stockwerk: (e['stockwerk'] as num).toInt(),
        ausKanon: kanonisch,
        zugang: [for (final o in e['zugang'] as List) Oeffnung.lies(o)],
        graph: kanonisch ? kanon.graph : RaumGraph.fromJson(e.cast<String, Object?>()),
        aussen: {...((e['aussen'] as List?) ?? const []).cast<String>()},
        kulisse: st['kulisse'] as String?,
        wetter: st['wetter'] as String?,
        dunkel: (st['dunkel'] as num?)?.toDouble() ?? 0.58,
        palette: (st['palette'] as Map?)?.cast<String, String>(),
        tuerBedingung: {
          for (final t in (e['tueren'] as List? ?? const []).cast<Map>())
            if (t['offen'] != null) t['id'] as String: Oeffnung.lies(t['offen']),
        },
      );
    }
    return WeltEbenen._(
      j['akte'] as String,
      kanon,
      WeltZeiten(sperre: zeit('sperre'), ersatzschluessel: zeit('ersatzschluessel'), morgen: zeit('morgen')),
      ebenen,
      [
        for (final p in (j['portale'] as List).cast<Map>())
          Portal(
            id: p['id'] as String,
            art: p['art'] as String,
            offen: Oeffnung.lies(p['offen']),
            weg: (p['weg'] as num).toDouble(),
            a: PortalSeite._aus(p['a'] as Map),
            b: PortalSeite._aus(p['b'] as Map),
          ),
      ],
      [
        for (final a in (j['ausblicke'] as List? ?? const []).cast<Map>())
          Ausblick(
            id: a['id'] as String,
            ebene: a['ebene'] as String,
            ort: a['ort'] as String,
            zeigt: a['zeigt'] as String,
            mitteX: ((a['mitte'] as List)[0] as num).toDouble(),
            mitteY: ((a['mitte'] as List)[1] as num).toDouble(),
            zoom: (a['zoom'] as num).toDouble(),
          ),
      ],
    );
  }

  /// Die Kanon-Ebene.
  Ebene get keller => ebenen[kellerEbene]!;

  /// Ist [o] in [lage] offen?
  bool offen(Oeffnung o, WeltLage lage) {
    final vorspiel = lage.uhr < zeiten.sperre;
    final morgen = lage.uhr >= zeiten.morgen;
    return switch (o) {
      Oeffnung.immer => true,
      Oeffnung.nachErsatzschluessel => lage.lang && lage.uhr >= zeiten.ersatzschluessel,
      Oeffnung.vorspielMorgen => lage.lang && (vorspiel || morgen),
      Oeffnung.nieInRunden => lage.lang && morgen,
      Oeffnung.vorspielNachErsatzschluessel => lage.lang && (vorspiel || lage.uhr >= zeiten.ersatzschluessel),
    };
  }

  bool _erfuellt(Oeffnung? o, WeltLage lage) => o != null && offen(o, lage);

  /// Darf [ebene] in [lage] betreten werden?
  bool zugangOffen(String ebene, WeltLage lage) => ebenen[ebene]!.zugang.any((o) => offen(o, lage));

  /// Portale mit einer Seite auf [ebene], mit dieser Seite.
  Iterable<(Portal, PortalSeite)> portaleAuf(String ebene) sync* {
    for (final p in portale) {
      if (p.a.ebene == ebene) yield (p, p.a);
      if (p.b.ebene == ebene) yield (p, p.b);
    }
  }

  /// Kacheln, die auf [ebene] in [lage] offen stehen: verschlossene Türen der
  /// Ebene mit erfüllter Bedingung und die Türkacheln offener Portale. Nur für
  /// Darstellungsraster; das Kanon-Raster bleibt, wie es ist.
  Set<Pt> offeneKacheln(String ebene, WeltLage lage) {
    final e = ebenen[ebene]!;
    final karte = e.graph.karte;
    return {
      if (!e.ausKanon)
        for (final t in e.graph.tueren.values)
          if (t.verschlossen && _erfuellt(e.tuerBedingung[t.id], lage)) ...t.kacheln,
      for (final (p, s) in portaleAuf(ebene))
        if (offen(p.offen, lage))
          for (final k in s.kacheln)
            if (karte.charAt(k.x, k.y) == TileChar.lockedDoor) k,
    };
  }

  /// Neues Darstellungsraster von [ebene] mit den in [lage] offenen Kacheln
  /// (nie `kanon.graph.raster` selbst).
  TileGrid raster(String ebene, WeltLage lage) => TileGrid(ebenen[ebene]!.graph.karte)..setOpenDoors(offeneKacheln(ebene, lage));

  /// Startkachel im Keller: der Ermittlungsort des Detektivs.
  Pt get kellerStart {
    final d = kanon.figurenJson['detektiv'] as Map;
    final o = kanon.graph.orte[d['ermittlungsOrt'] as String]!;
    return Pt(o.x.floor(), o.y.floor());
  }

  /// Begehbare Kacheln je Ebene, die in [lage] vom Keller aus (oder von
  /// [von]) erreichbar sind, über offene Türen und offene Portale.
  Map<String, Set<Pt>> erreichbar(WeltLage lage, {(String, Pt)? von}) {
    final raster = {for (final id in ebenen.keys) id: this.raster(id, lage)};
    final besucht = <String, Set<Pt>>{for (final id in ebenen.keys) id: <Pt>{}};
    final start = von ?? (kellerEbene, kellerStart);
    final offen = <(String, Pt)>[start];
    besucht[start.$1]!.add(start.$2);
    while (offen.isNotEmpty) {
      final (e, p) = offen.removeLast();
      void dazu(String ebene, Pt q) {
        if (!raster[ebene]!.walkable(q.x, q.y)) return;
        if (besucht[ebene]!.add(q)) offen.add((ebene, q));
      }

      for (final (dx, dy) in const [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
        dazu(e, Pt(p.x + dx, p.y + dy));
      }
      for (final (portal, s) in portaleAuf(e)) {
        if (s.ankunft == p && this.offen(portal.offen, lage)) {
          final g = portal.gegenueber(s);
          dazu(g.ebene, g.ankunft);
        }
      }
    }
    return besucht;
  }

  /// Räume je Ebene, die in [lage] erreichbar sind; Ebenen ohne erreichbare Kachel fehlen.
  Map<String, Set<String>> erreichbareRaeume(WeltLage lage, {(String, Pt)? von}) {
    final aus = <String, Set<String>>{};
    for (final MapEntry(key: e, value: kacheln) in erreichbar(lage, von: von).entries) {
      final g = ebenen[e]!.graph;
      final raeume = {for (final k in kacheln) ?g.raumAn(k.x + 0.5, k.y + 0.5)?.id};
      if (kacheln.isNotEmpty) aus[e] = raeume;
    }
    return aus;
  }

  /// Alle Kennungen der neuen Zonen (Räume, Türen, Einrichtung, Orte,
  /// Lichtquellen) mit ihrer Ebene.
  Iterable<(String, String)> get kennungen sync* {
    for (final e in ebenen.values) {
      if (e.ausKanon) continue;
      final g = e.graph;
      for (final id in [...g.raeume.keys, ...g.tueren.keys, ...g.einrichtung.keys, ...g.orte.keys, ...g.lichtquellen.keys]) {
        yield (e.id, id);
      }
    }
    for (final p in portale) {
      yield ('portale', p.id);
    }
    for (final a in ausblicke) {
      yield ('ausblicke', a.id);
    }
  }
}

// ---------------------------------------------------------------- Prüfen

/// Lagen, in denen [pruefeEbenen] die Öffnungen nachrechnet: beide Fassungen,
/// Vorspiel, Sperre, Nacht vor und nach dem Ersatzschlüssel, Runden, Finale,
/// letzte Sekunde vor dem Morgen und der Morgen.
List<WeltLage> probeLagen(WeltZeiten z) => [
      for (final lang in [false, true])
        for (final uhr in [
          Uhrzeit.parse('18:00'),
          z.sperre,
          Uhrzeit.parse('23:30'),
          z.ersatzschluessel.plus(-1),
          z.ersatzschluessel,
          Uhrzeit.parse('00:30'),
          Uhrzeit.parse('01:15'),
          Uhrzeit.parse('02:45'),
          z.morgen.plus(-1),
          z.morgen,
        ])
          WeltLage(lang: lang, uhr: uhr),
    ];

/// Prüft [w] gegen den Kanon. Liefert Befunde als Sätze; leer heißt in Ordnung.
///
/// - Der Keller ist die erste Ebene und kommt aus dem Kanon; jede andere Ebene
///   bleibt unter [ebeneHoechstBreite] × [ebeneHoechstHoehe], jeder Raum
///   liegt im Raster mit Wandrand und unter [raumHoechstSumme].
/// - Keine Kennung der neuen Zonen kommt doppelt vor oder steht irgendwo im
///   Kanon (Räume, Orte, Gegenstände, Spuren, Sperrorte, Figuren).
/// - Türen liegen auf der Wand zwischen ihren Räumen; verschlossene Türen
///   haben eine Bedingung oder sind Portalkacheln. Einrichtung steht in einem
///   Raum und hat eine Darstellung aus dem Katalog; Orte stehen frei im
///   eigenen Raum.
/// - Portale verbinden zwei Ebenen. Im Keller liegen sie auf Kanon-Kacheln
///   (Türen oder Einrichtung), sonst auf Türen oder Einrichtung der Ebene. Der
///   Ankunftspunkt ist begehbar (im Keller auf dem Kanon-Raster) und grenzt
///   an jede Portalkachel. Eine verschlossene Kanon-Tür öffnet nie immer.
/// - Erreichbarkeit: Mit allem offen ist jede begehbare Kachel jeder Ebene
///   vom Keller aus erreichbar. In keiner [probeLagen] ist eine Ebene
///   erreichbar, deren Zugang zu ist: Die Außenwelt bleibt in den Runden
///   unerreichbar, das Erdgeschoss im kurzen Abend und von der Sperre bis
///   zum Ersatzschlüssel.
/// - Ein Kanon-Ort mit Zusatzweg (Toilette oben im Turm) passt zu einer
///   Treppe: Treppenlauf plus Weg auf der oberen Ebene zu einem Ort weicht
///   höchstens drei Meter vom Zusatzweg ab.
/// - Ausblicke zeigen auf einen Punkt einer vorhandenen Ebene.
/// - Namen, Beschreibungen und Handlungen: Tonregeln über [ton] (wie
///   Vorlesetext: keine Ziffern, Abkürzungen, Klammern), kein Sperrwort, kein
///   Gegenstand, keine Figur ([sperrregeln]), Raumwörter nur für Räume des
///   Kanons, der Ebenen oder aus `raumAusnahmen` in [regeln].
List<String> pruefeEbenen(WeltEbenen w, {Textpruefer? ton, Map<String, Object?>? regeln}) {
  final f = <String>[];
  final kanon = w.kanon;
  final ids = w.ebenen.keys.toList();
  if (ids.isEmpty || ids.first != kellerEbene || !w.keller.ausKanon) f.add('die erste Ebene ist nicht der Kanon-Keller');
  for (final e in w.ebenen.values) {
    if (e.id != kellerEbene && e.ausKanon) f.add('${e.id}: nur der Keller kommt aus dem Kanon');
  }
  if (!(w.zeiten.sperre < w.zeiten.ersatzschluessel && w.zeiten.ersatzschluessel < w.zeiten.morgen)) {
    f.add('Zeiten: Sperre, Ersatzschlüssel und Morgen stehen nicht in dieser Reihenfolge');
  }

  // Kennungen: eindeutig, keine aus dem Kanon.
  final kanonIds = <String>{};
  void sammle(Object? x) {
    if (x is Map) {
      for (final e in x.entries) {
        if (e.key == 'id' && e.value is String) kanonIds.add(e.value as String);
        sammle(e.value);
      }
    } else if (x is List) {
      x.forEach(sammle);
    }
  }

  kanon.json.values.forEach(sammle);
  final gesehen = <String>{};
  for (final (wo, id) in w.kennungen) {
    if (!gesehen.add(id)) f.add('$wo: Kennung $id kommt doppelt vor');
    if (kanonIds.contains(id) || kanon.graph.orte.containsKey(id)) f.add('$wo: Kennung $id gehört dem Kanon');
  }

  final alles = WeltLage(lang: true, uhr: w.zeiten.morgen);
  for (final e in w.ebenen.values) {
    if (e.ausKanon) continue;
    f.addAll(_pruefeEbene(w, e, alles));
  }
  f.addAll(_pruefePortale(w, alles));

  // Erreichbarkeit mit allem offen: jede begehbare Kachel jeder Ebene.
  final erreicht = w.erreichbar(alles);
  for (final e in w.ebenen.values) {
    if (e.ausKanon) continue;
    final r = w.raster(e.id, alles);
    final fehlt = <Pt>[
      for (var y = 0; y < r.height; y++)
        for (var x = 0; x < r.width; x++)
          if (r.walkable(x, y) && !erreicht[e.id]!.contains(Pt(x, y))) Pt(x, y),
    ];
    if (fehlt.isNotEmpty) f.add('${e.id}: ${fehlt.length} begehbare Kacheln sind nicht erreichbar, etwa ${fehlt.take(4).join(' ')}');
  }

  // Zugang je Lage: keine Ebene ist erreichbar, deren Zugang zu ist.
  for (final lage in probeLagen(w.zeiten)) {
    for (final MapEntry(key: e, value: kacheln) in w.erreichbar(lage).entries) {
      if (kacheln.isNotEmpty && !w.zugangOffen(e, lage)) f.add('$e ist in der Lage $lage erreichbar, der Zugang ist aber zu');
    }
  }

  // Kanon-Orte mit Zusatzweg (Toilette oben im Turm) und die Treppe dorthin.
  for (final o in kanon.graph.orte.values.where((o) => o.zusatzweg > 0)) {
    var passt = false;
    for (final p in w.portale.where((p) => p.art == 'treppe')) {
      final unten = p.seiteAuf(kellerEbene);
      if (unten == null || dist(unten.ankunftX, unten.ankunftY, o.x, o.y) > 1.5) continue;
      final oben = p.gegenueber(unten);
      final g = w.ebenen[oben.ebene]?.graph;
      if (g == null) continue;
      final r = w.raster(oben.ebene, alles);
      for (final ziel in g.orte.values) {
        final pfad = r.findPath(oben.ankunft, Pt(ziel.x.floor(), ziel.y.floor()));
        if (pfad != null && (p.weg + pfad.length - o.zusatzweg).abs() <= 3) passt = true;
      }
    }
    if (!passt) f.add('Kanon-Ort ${o.id} (Zusatzweg ${o.zusatzweg} m) hat keine passende Treppe mit Ort auf einer Ebene');
  }

  for (final a in w.ausblicke) {
    final e = w.ebenen[a.ebene], z = w.ebenen[a.zeigt];
    if (e == null || z == null) {
      f.add('Ausblick ${a.id}: Ebene ${a.ebene} oder ${a.zeigt} fehlt');
      continue;
    }
    if (!e.graph.orte.containsKey(a.ort)) f.add('Ausblick ${a.id}: Ort ${a.ort} fehlt auf ${a.ebene}');
    if (a.mitteX >= z.graph.breite || a.mitteY >= z.graph.hoehe) f.add('Ausblick ${a.id}: Mitte liegt außerhalb von ${a.zeigt}');
  }

  f.addAll(_pruefeTexte(w, ton: ton, regeln: regeln));
  return f;
}

/// Raster, Räume, Türen, Einrichtung und Orte einer neuen Ebene.
List<String> _pruefeEbene(WeltEbenen w, Ebene e, WeltLage alles) {
  final f = <String>[];
  final g = e.graph;
  if (g.breite > ebeneHoechstBreite || g.hoehe > ebeneHoechstHoehe) {
    f.add('${e.id}: Raster ${g.breite} × ${g.hoehe} ist größer als $ebeneHoechstBreite × $ebeneHoechstHoehe');
  }
  for (final r in g.raeume.values) {
    if (r.x < 1 || r.y < 1 || r.x + r.b > g.breite - 1 || r.y + r.l > g.hoehe - 1) f.add('${e.id}: Raum ${r.id} hat keinen Wandrand im Raster');
    if (r.b + r.l > raumHoechstSumme) f.add('${e.id}: Raum ${r.id} ist mit ${r.b} + ${r.l} zu groß für die Szene');
  }
  if (f.isNotEmpty) return f;
  final karte = g.karte;
  final portalKacheln = {for (final (_, s) in w.portaleAuf(e.id)) ...s.kacheln};
  for (final t in g.tueren.values) {
    for (final k in t.kacheln) {
      final an = <String>{
        for (final (dx, dy) in const [(1, 0), (-1, 0), (0, 1), (0, -1)])
          if (karte.charAt(k.x + dx, k.y + dy) == TileChar.floor) ?g.raumAn(k.x + dx + 0.5, k.y + dy + 0.5)?.id,
      };
      if (!an.contains(t.von)) f.add('${e.id}: Tür ${t.id} grenzt bei $k nicht an ${t.von}');
      if (g.raeume.containsKey(t.nach) && !an.contains(t.nach)) f.add('${e.id}: Tür ${t.id} grenzt bei $k nicht an ${t.nach}');
      if (!g.raeume.containsKey(t.nach) && !portalKacheln.contains(k)) f.add('${e.id}: Tür ${t.id} führt nach ${t.nach}, ist aber kein Portal');
    }
    final bedingt = e.tuerBedingung.containsKey(t.id);
    final portal = t.kacheln.every(portalKacheln.contains);
    if (t.verschlossen && !bedingt && !portal) f.add('${e.id}: verschlossene Tür ${t.id} hat keine Bedingung (offen)');
    if (!t.verschlossen && bedingt) f.add('${e.id}: Tür ${t.id} hat eine Bedingung, steht aber offen');
  }
  for (final d in g.einrichtung.values) {
    if (g.raumAn(d.x + 0.5, d.y + 0.5) == null) f.add('${e.id}: ${d.id} steht in keinem Raum');
    if (!propCatalog.containsKey(d.darstellung ?? d.typ)) f.add('${e.id}: ${d.id} hat keine Darstellung aus dem Katalog');
    if ((propCatalog[d.darstellung ?? d.typ]?.blocks ?? true) != d.blockiert) f.add('${e.id}: ${d.id} blockiert anders als seine Darstellung');
  }
  final r = w.raster(e.id, alles);
  for (final o in g.orte.values) {
    if (!g.raeume.containsKey(o.raum)) f.add('${e.id}: Ort ${o.id} nennt unbekannten Raum ${o.raum}');
    if (g.raumAn(o.x, o.y)?.id != o.raum) f.add('${e.id}: Ort ${o.id} liegt nicht in ${o.raum}');
    if (!r.canStand(o.x, o.y, 0.28)) f.add('${e.id}: Ort ${o.id} steht nicht frei');
  }
  for (final id in e.aussen) {
    if (!g.raeume.containsKey(id)) f.add('${e.id}: Außenraum $id fehlt');
  }
  for (final l in g.lichtquellen.values) {
    for (final raum in l.raeume) {
      if (!g.raeume.containsKey(raum)) f.add('${e.id}: Licht ${l.id} nennt unbekannten Raum $raum');
    }
    if (l.ort != null && !g.orte.containsKey(l.ort)) f.add('${e.id}: Licht ${l.id} nennt unbekannten Ort ${l.ort}');
  }
  for (final (a, b) in g.nachbarn) {
    if (!g.raeume.containsKey(a) || !g.raeume.containsKey(b)) f.add('${e.id}: Geräuschnachbarn $a und $b sind keine Räume der Ebene');
  }
  return f;
}

/// Portale: Ebenen, Kacheln, Ankunft und Kanon-Türen.
List<String> _pruefePortale(WeltEbenen w, WeltLage alles) {
  final f = <String>[];
  final kanon = w.kanon.graph;
  final kanonTuerAn = {for (final t in kanon.tueren.values) for (final k in t.kacheln) k: t};
  final kanonDinge = {for (final d in kanon.einrichtung.values) Pt(d.x, d.y)};
  for (final p in w.portale) {
    if (p.a.ebene == p.b.ebene) f.add('Portal ${p.id} verbindet ${p.a.ebene} mit sich selbst');
    for (final s in [p.a, p.b]) {
      final e = w.ebenen[s.ebene];
      if (e == null) {
        f.add('Portal ${p.id}: Ebene ${s.ebene} fehlt');
        continue;
      }
      final g = e.graph;
      final eigeneTueren = {for (final t in g.tueren.values) ...t.kacheln};
      final eigeneDinge = {for (final d in g.einrichtung.values) Pt(d.x, d.y)};
      for (final k in s.kacheln) {
        final ok = e.ausKanon ? (kanonTuerAn.containsKey(k) || kanonDinge.contains(k)) : (eigeneTueren.contains(k) || eigeneDinge.contains(k));
        if (!ok) f.add('Portal ${p.id}: Kachel $k auf ${s.ebene} ist weder Tür noch Einrichtung${e.ausKanon ? ' des Kanons' : ''}');
        if ((k.x - s.ankunft.x).abs() > 1 || (k.y - s.ankunft.y).abs() > 1) f.add('Portal ${p.id}: Kachel $k liegt nicht am Ankunftspunkt auf ${s.ebene}');
        final t = e.ausKanon ? kanonTuerAn[k] : null;
        if (t != null && t.verschlossen && p.offen == Oeffnung.immer) f.add('Portal ${p.id}: verschlossene Kanon-Tür ${t.id} öffnet immer');
      }
      final raster = e.ausKanon ? kanon.raster : w.raster(s.ebene, alles);
      if (!raster.canStand(s.ankunftX, s.ankunftY, 0.28)) f.add('Portal ${p.id}: Ankunft auf ${s.ebene} ist nicht begehbar');
    }
  }
  return f;
}

/// Texte der neuen Zonen mit ihrer Fundstelle.
List<TextQuelle> ebenenTexte(WeltEbenen w) => [
      for (final e in w.ebenen.values) ...[
        TextQuelle(ort: 'langfassung.json#${e.id}', text: e.name, vorlesen: true),
        if (!e.ausKanon) ...[
          for (final r in e.graph.raeume.values) ...[
            TextQuelle(ort: 'langfassung.json#${r.id}', text: r.name, vorlesen: true),
            TextQuelle(ort: 'langfassung.json#${r.id}', text: r.anzeigename, vorlesen: true),
            TextQuelle(ort: 'langfassung.json#${r.id}', text: r.beschreibung, vorlesen: true),
            for (final x in r.features) TextQuelle(ort: 'langfassung.json#${r.id}', text: x, vorlesen: true),
          ],
          for (final t in e.graph.tueren.values) ...[
            TextQuelle(ort: 'langfassung.json#${t.id}', text: t.name, vorlesen: true),
            TextQuelle(ort: 'langfassung.json#${t.id}', text: t.art, vorlesen: true),
          ],
          for (final d in e.graph.einrichtung.values) TextQuelle(ort: 'langfassung.json#${d.id}', text: d.name, vorlesen: true),
          for (final o in e.graph.orte.values) TextQuelle(ort: 'langfassung.json#${o.id}', text: o.name, vorlesen: true),
          for (final l in e.graph.lichtquellen.values) TextQuelle(ort: 'langfassung.json#${l.id}', text: l.name, vorlesen: true),
        ],
      ],
      for (final p in w.portale)
        for (final s in [p.a, p.b]) TextQuelle(ort: 'langfassung.json#${p.id}', text: s.aktion, vorlesen: true),
    ];

final _wortRe = RegExp(r'[\p{L}]+(?:-[\p{L}]+)*', unicode: true);

List<String> _pruefeTexte(WeltEbenen w, {Textpruefer? ton, Map<String, Object?>? regeln}) {
  final f = <String>[];
  final kanon = w.kanon;
  final sperre = sperrregeln(kanon.figurenJson, kanon.gegenstaendeJson);
  final endungen = [for (final x in (regeln?['raumwortEndungen'] as List? ?? const [])) (x as String).toLowerCase()];
  final raumworte = <String>{
    for (final n in [
      for (final r in kanon.graph.raeume.values) ...[r.name, r.anzeigename],
      for (final e in w.ebenen.values)
        if (!e.ausKanon)
          for (final r in e.graph.raeume.values) ...[r.name, r.anzeigename],
      ...((regeln?['raumAusnahmen'] as List?) ?? const []).cast<String>(),
    ])
      for (final m in _wortRe.allMatches(n)) m.group(0)!.toLowerCase(),
  };
  for (final q in ebenenTexte(w)) {
    if (ton != null) {
      for (final b in ton.pruefe(q)) {
        f.add('${b.ort}: ${b.regel}: ${b.auszug}');
      }
    }
    for (final s in sperre) {
      final m = s.firstMatch(q.text);
      if (m != null) f.add('${q.ort}: Sperrwort „${m.group(0)}“ in „${q.text}“');
    }
    for (final m in _wortRe.allMatches(q.text)) {
      final wort = m.group(0)!.toLowerCase();
      if (endungen.any(wort.endsWith) && !raumworte.contains(wort)) f.add('${q.ort}: Raumwort „${m.group(0)}“ ist kein Raum');
    }
  }
  return f;
}

// ---------------------------------------------------------------- Szenarien

/// Szenario-Kennung einer Ebene: der Keller behält [basis], die übrigen
/// heißen `<basis>~<ebene>`.
String ebenenSzenarioId(String ebene, {String basis = 'party_schlosskeller'}) => ebene == kellerEbene ? basis : '$basis~$ebene';

/// Hotspots der Portale auf [ebene] (Kennung = Portal, Name = Handlung).
List<Map<String, Object?>> portalHotspots(WeltEbenen w, String ebene) => [
      for (final (p, s) in w.portaleAuf(ebene))
        {'id': p.id, 'name': {'de': s.aktion}, 'x': s.kacheln.first.x, 'y': s.kacheln.first.y, 'kind': 'search'},
    ];

/// Renderer-Szenarien je Ebene, der Keller zuerst. Der Keller ist das
/// Szenario aus [partySzenarioJson] (Zeilen, Räume, Möbel und Ziele der
/// Entscheidungen unverändert) mit den Portalen als zusätzlichen Hotspots.
/// Die übrigen Ebenen übernehmen Thema und Figuren der Vorlage und bringen
/// Karte, Möbel, Kulisse, Wetter und Farben mit; ihre einzigen Hotspots sind
/// die Portale (keine Fallhinweise).
Map<String, ScenarioDef> partyEbenenSzenarien(Kanon kanon, Map<String, dynamic> vorlage, WeltEbenen w,
    {String id = 'party_schlosskeller', Map<String, Object?>? welt}) {
  final aus = <String, ScenarioDef>{};
  for (final e in w.ebenen.values) {
    final j = partySzenarioJson(kanon, vorlage, id: ebenenSzenarioId(e.id, basis: id), welt: welt);
    if (e.ausKanon) {
      j['hotspots'] = [...(j['hotspots'] as List), ...portalHotspots(w, e.id)];
      aus[e.id] = ScenarioDef.fromJson(j);
      continue;
    }
    final g = e.graph;
    final theme = j['theme'] as Map<String, dynamic>;
    j['theme'] = {
      ...theme,
      if (e.palette != null) 'palette': e.palette,
      'weather': e.wetter ?? 'none',
      'lightning': false,
      'backdrop': e.kulisse ?? 'none',
    };
    final start = w.portaleAuf(e.id).first.$2;
    j['map'] = {
      'rows': g.karte.rows,
      'rooms': [
        for (final r in g.raeume.values)
          {
            'id': r.id,
            'name': {'de': r.anzeigename},
            'x': r.x,
            'y': r.y,
            'w': r.b,
            'h': r.l,
            'floor': r.boden,
            if (e.aussen.contains(r.id)) 'outdoor': true,
          },
      ],
      'props': [
        for (final d in g.einrichtung.values)
          if (propCatalog.containsKey(d.darstellung ?? d.typ)) {'type': d.darstellung ?? d.typ, 'x': d.x, 'y': d.y},
      ],
      'spawn': [
        [start.ankunft.x, start.ankunft.y],
      ],
      'councilRoom': g.raeume.keys.first,
    };
    j['hotspots'] = portalHotspots(w, e.id);
    aus[e.id] = ScenarioDef.fromJson(j);
  }
  return aus;
}
