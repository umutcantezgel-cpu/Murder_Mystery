import 'ablauf.dart';
import 'entscheidungen.dart';
import 'kanon/kanon.dart';
import 'raumgraph.dart';
import 'tatmatrix.dart';
import 'zeit.dart';

/// Woran eine Entscheidung auf der Karte hängt (Master 7.7).
enum ZielArt { person, gegenstand, raum }

/// Eine Option einer Detektiv-Entscheidung als Handlung auf der Karte: eine
/// Person befragen, einen Gegenstand untersuchen oder eine Stelle absuchen.
class KartenZiel {
  final String option;
  final String entscheidung;
  final ZielArt art;

  /// Handlung am Ziel, wie der Optionstext sie nennt (E-038): „… befragen“ und
  /// „… fragen“ heißen Befragen, „… untersuchen“ Untersuchen, „… suchen“ Absuchen.
  /// So steht am Knopf dasselbe Verb wie in der Bestätigung, auch wenn das Ziel
  /// eine Person ist („Olli und seine Weste untersuchen“).
  final ZielArt aktion;

  /// Kanon-Kennung des Ziels (Person, Gegenstand oder Raum).
  final String kanonId;

  /// Angesprochene Person: die befragte Person oder der Träger des
  /// Gegenstands. Sonst `null`, dann hängt das Ziel an einem Hotspot.
  final String? person;

  /// Kachel des Hotspots (nur ohne [person]).
  final int? x, y;

  /// Raum, in dem das Ziel liegt.
  final String raum;

  /// Anzeigename der Stelle (Gegenstand, Raum oder Person).
  final String name;

  const KartenZiel({
    required this.option,
    required this.entscheidung,
    required this.art,
    required this.aktion,
    required this.kanonId,
    required this.person,
    required this.x,
    required this.y,
    required this.raum,
    required this.name,
  });

  /// Kennung des Hotspots im Renderer-Szenario.
  String get hotspot => 'ziel_$option';
}

/// Handlung aus dem Verb am Ende eines Optionstexts; sonst die Art des Ziels.
ZielArt aktionAus(String text, ZielArt art) {
  final t = text.trim().toLowerCase();
  if (t.endsWith('untersuchen') || t.endsWith('durchsuchen')) return ZielArt.gegenstand;
  if (t.endsWith('befragen') || t.endsWith('fragen') || t.endsWith('sprechen')) return ZielArt.person;
  if (t.endsWith('suchen')) return ZielArt.raum;
  return art;
}

/// Was die Karte zu einem Spielstand zeigt. Vor dem Finale hängt das nur an
/// Phase, Runde und gewählten Optionen, nie am Pfad (E-008, F-12).
class KartenZustand {
  final PartyPhase phase;
  final int runde;

  /// Laufende Entscheidung (nur in der Phase `entscheidungen`).
  final String? entscheidung;

  /// Offene Hotspots der laufenden Entscheidung → Art der Handlung.
  final Map<String, ZielArt> offen;

  /// Ansprechbare Personen der laufenden Entscheidung → Art der Handlung.
  final Map<String, ZielArt> ansprechbar;

  /// Hotspots schon gewählter Optionen.
  final Set<String> erledigt;

  /// Brennende Lichtquellen (Kanon-Kennungen).
  final List<String> lichter;

  const KartenZustand({
    required this.phase,
    required this.runde,
    required this.entscheidung,
    required this.offen,
    required this.ansprechbar,
    required this.erledigt,
    required this.lichter,
  });

  /// Vergleichbare Form für Tests (Objektliste, Marker, Licht).
  Map<String, Object?> toJson() => {
        'phase': phase.name,
        'runde': runde,
        'entscheidung': entscheidung,
        'offen': {for (final k in offen.keys.toList()..sort()) k: offen[k]!.name},
        'ansprechbar': {for (final k in ansprechbar.keys.toList()..sort()) k: ansprechbar[k]!.name},
        'erledigt': erledigt.toList()..sort(),
        'lichter': lichter,
      };
}

/// Ein Objekt der Karte: Person an ihrem Ermittlungsort.
class KartenFigur {
  final String id;
  final double x, y;
  final String raum;
  const KartenFigur(this.id, this.x, this.y, this.raum);
}

/// Die Karte eines Partyfalls: Ziele aller neun Entscheidungen, Figuren an
/// ihren Ermittlungsorten, Licht der Ermittlung und die Rückblende.
class PartyKarte {
  final Kanon kanon;
  final Ermittlung ermittlung;

  /// Ziele aller Optionen, nach Option.
  late final Map<String, KartenZiel> ziele;

  /// Alle Personen der Karte außer dem Detektiv (Opfer und 20 Rollen).
  late final List<KartenFigur> figuren;

  /// Lichtquellen an festen Orten, die nach der Tat noch brennen (Ende der
  /// Tatmatrix). Grundlicht und Deko-Kerzen gibt der Renderer als Stimmung
  /// (Master 7.13); getragene Lichter gehören zur Rückblende.
  late final List<String> ermittlungsLichter;

  /// Elektrische Deko-Kerzen auf Tafeln, Buffets und Theke (B-04, E-019):
  /// warme Lichtpunkte mit leichtem Flackern (Master 7.13). Jede zweite
  /// Tischreihe und jede dritte Thekenkachel trägt eine.
  late final List<(double, double)> dekoKerzen;

  PartyKarte(this.kanon, {Ermittlung? ermittlung}) : ermittlung = ermittlung ?? Ermittlung(kanon) {
    final g = kanon.graph;
    final gegenstaende = {for (final x in kanon.gegenstaende) x['id'] as String: x};
    ziele = {};
    for (final e in this.ermittlung.entscheidungen) {
      for (final o in e.optionen) {
        ziele[o.id] = _ziel(e, o, g, gegenstaende);
      }
    }
    figuren = [];
    for (final id in kanon.personen.skip(1)) {
      final ort = g.orte[kanon.figur(id)!['ermittlungsOrt'] as String]!;
      figuren.add(KartenFigur(id, ort.x, ort.y, ort.raum));
    }
    dekoKerzen = [
      for (final e in g.einrichtung.values)
        if ((e.typ == 'table' && e.y.isOdd) || (e.typ == 'counter' && e.x % 3 == 0)) (e.x + 0.5, e.y + 0.5),
    ];
    final nachTat = kanon.regeln.planBis;
    ermittlungsLichter = [
      for (final l in g.lichtquellen.values)
        if (l.ort != null && l.brennt(nachTat)) l.id,
    ];
  }

  KartenZiel _ziel(Entscheidung e, EntscheidungsOption o, RaumGraph g, Map<String, Map<String, Object?>> gegenstaende) {
    final z = o.ziel;
    String? person;
    String kanonId;
    ZielArt art;
    int? x, y;
    String raum;
    String name;
    KartenFigur personBei(String p) {
      final f = kanon.figur(p) ?? (throw StateError('Option ${o.id}: unbekannte Person $p'));
      final ort = g.orte[f['ermittlungsOrt'] as String]!;
      return KartenFigur(p, ort.x, ort.y, ort.raum);
    }

    if (z['person'] != null) {
      art = ZielArt.person;
      kanonId = person = z['person']!;
      raum = personBei(person).raum;
      name = kanon.figur(person)!['name'] as String;
    } else if (z['gegenstand'] != null) {
      art = ZielArt.gegenstand;
      kanonId = z['gegenstand']!;
      final gg = gegenstaende[kanonId] ?? (throw StateError('Option ${o.id}: unbekannter Gegenstand $kanonId'));
      name = gg['name'] as String;
      final lage = (gg['lage'] as Map?)?.cast<String, Object?>() ?? const {};
      if (lage['traeger'] != null) {
        person = lage['traeger'] as String;
        raum = personBei(person).raum;
      } else if (lage['einrichtung'] != null && g.einrichtung[lage['einrichtung']] != null) {
        final ein = g.einrichtung[lage['einrichtung']]!;
        x = ein.x;
        y = ein.y;
        raum = g.raumAn(ein.x + 0.5, ein.y + 0.5)?.id ?? g.orte[lage['ort']]!.raum;
      } else if (lage['ort'] != null) {
        final ort = g.orte[lage['ort']]!;
        x = ort.x.floor();
        y = ort.y.floor();
        raum = ort.raum;
      } else {
        throw StateError('Option ${o.id}: Gegenstand $kanonId hat keine Stelle auf der Karte');
      }
    } else if (z['raum'] != null) {
      art = ZielArt.raum;
      kanonId = raum = z['raum']!;
      final r = g.raeume[raum] ?? (throw StateError('Option ${o.id}: unbekannter Raum $raum'));
      name = r.anzeigename;
      final ort = z['ort'] != null ? g.orte[z['ort']]! : null;
      if (ort == null) throw StateError('Option ${o.id}: Raum-Ziel ohne Ort');
      x = ort.x.floor();
      y = ort.y.floor();
    } else {
      throw StateError('Option ${o.id}: Ziel ohne Person, Gegenstand oder Raum');
    }
    return KartenZiel(option: o.id, entscheidung: e.id, art: art, aktion: aktionAus(o.text, art), kanonId: kanonId, person: person, x: x, y: y, raum: raum, name: name);
  }

  /// Hotspots für das Renderer-Szenario: jedes Ziel ohne Person, in allen
  /// Pfaden gleich.
  List<Map<String, Object?>> hotspotJson() => [
        for (final z in ziele.values)
          if (z.person == null) {'id': z.hotspot, 'name': {'de': z.name}, 'x': z.x, 'y': z.y, 'kind': 'search'},
      ];

  /// Laufende Entscheidung: die erste offene der Runde nach Nummer.
  String? laufend(Spiel s) => laufendBei(s.phase, s.runde, s.gewaehlt);

  /// Wie [laufend], aus Phase, Runde und Wahl (eine Kartenquelle ohne Spiel).
  String? laufendBei(PartyPhase phase, int runde, Map<String, String> gewaehlt) {
    if (phase != PartyPhase.entscheidungen) return null;
    for (final e in ermittlung.runde(runde)) {
      if (!gewaehlt.containsKey(e.id)) return e.id;
    }
    return null;
  }

  /// Ziele einer Entscheidung.
  List<KartenZiel> zieleVon(String entscheidung) => [for (final z in ziele.values) if (z.entscheidung == entscheidung) z];

  /// Option zu einer Handlung: Hotspot-Kennung oder Kanon-Person, nur in der
  /// laufenden Entscheidung.
  KartenZiel? zielFuer(Spiel s, String kennung) {
    final e = laufend(s);
    if (e == null) return null;
    for (final z in zieleVon(e)) {
      if (z.person == null ? z.hotspot == kennung : z.person == kennung) return z;
    }
    return null;
  }

  /// Kartenzustand zu einem Spielstand. Liest nur Phase, Runde und Wahl.
  KartenZustand zustand(Spiel s) => zustandBei(s.phase, s.runde, s.gewaehlt);

  /// Wie [zustand], aus Phase, Runde und Wahl (eine Kartenquelle ohne Spiel).
  KartenZustand zustandBei(PartyPhase phase, int runde, Map<String, String> gewaehlt) {
    final e = laufendBei(phase, runde, gewaehlt);
    final offen = <String, ZielArt>{};
    final ansprechbar = <String, ZielArt>{};
    if (e != null) {
      for (final z in zieleVon(e)) {
        if (z.person == null) {
          offen[z.hotspot] = z.aktion;
        } else {
          ansprechbar[z.person!] = z.aktion;
        }
      }
    }
    return KartenZustand(
      phase: phase,
      runde: runde,
      entscheidung: e,
      offen: offen,
      ansprechbar: ansprechbar,
      erledigt: {for (final o in gewaehlt.values) if (ziele[o]!.person == null) ziele[o]!.hotspot},
      lichter: ermittlungsLichter,
    );
  }

  /// Rückblende des Pfads (erst nach dem Finale zeigen).
  Rueckblende rueckblende(String pfad) => Rueckblende(kanon, pfad);
}

/// Eine Lichtquelle in einem Bild der Rückblende.
class RueckblendeLicht {
  final String id;
  final double x, y;
  final String farbe;
  final double radius;
  final double flackern;
  const RueckblendeLicht(this.id, this.x, this.y, this.farbe, this.radius, this.flackern);
}

/// Ein Bild der Rückblende zu einer Uhrzeit.
class RueckblendeBild {
  final Uhrzeit t;
  final Map<String, PersonZustand> personen;
  final List<RueckblendeLicht> lichter;

  /// Räume mit brennendem Raumlicht (Deckenlicht, Deko-Kerzen).
  final Set<String> helleRaeume;

  /// Lage des Schlüsselbunds, falls er offen liegt oder getragen wird.
  final (double, double)? bund;

  const RueckblendeBild(this.t, this.personen, this.lichter, this.helleRaeume, this.bund);
}

/// Zeitraffer der Tatmatrix eines Pfads in 15-Sekunden-Schritten (Master 7.13).
/// Hervorgehoben sind die Person mit dem Schlag, Herr Schneider und der Bund.
class Rueckblende {
  final Kanon kanon;
  final String pfad;
  late final Ablauf ablauf;
  late final List<Uhrzeit> schritte;

  Rueckblende(this.kanon, this.pfad) {
    ablauf = Ablauf(kanon.graph, kanon.tatmatrix(pfad), start: kanon.regeln.planVon, ende: kanon.regeln.planBis);
    schritte = [for (var t = kanon.regeln.planVon; t <= kanon.regeln.planBis; t = t.plus(15)) t];
  }

  Set<String> get hervorgehoben => {pfad, (kanon.figurenJson['opfer'] as Map)['id'] as String};

  /// Bild zur Uhrzeit [t]. Mit [bruch] (Sekundenbruchteil, 0 bis unter 1)
  /// stehen die Personen genau dort, wo sie zwischen zwei Sekunden auf ihrem
  /// Weg sind (flüssiger Zeitraffer). Ob ein Licht brennt und wer den Bund
  /// trägt, entscheidet die ganze Sekunde.
  RueckblendeBild bild(Uhrzeit t, {double bruch = 0}) {
    final g = kanon.graph;
    final personen = <String, PersonZustand>{
      for (final p in ablauf.personen)
        p: ?ablauf.zustand(p, t, bruch: bruch),
    };
    final lichter = <RueckblendeLicht>[];
    final hell = <String>{};
    for (final l in g.lichtquellen.values) {
      if (!l.brennt(t)) continue;
      if (l.ort == null && l.traeger == null) {
        hell.addAll(l.raeume);
        continue;
      }
      double? x, y;
      if (l.ort != null) {
        final o = g.orte[l.ort]!;
        (x, y) = (o.x, o.y);
      } else if (personen[l.traeger] case final z?) {
        (x, y) = (z.x, z.y);
      }
      if (x == null || y == null) continue;
      lichter.add(RueckblendeLicht(l.id, x, y, l.farbe ?? '#FFF1C9', l.radius, l.flackern));
    }
    (double, double)? bund;
    final spur = ablauf.matrix.gegenstaende['bund_schneider']?.stand(t);
    if (spur != null) {
      if (spur.traeger != null && personen[spur.traeger] != null) {
        bund = (personen[spur.traeger]!.x, personen[spur.traeger]!.y);
      } else if (spur.ort != null && g.orte[spur.ort] != null) {
        bund = (g.orte[spur.ort]!.x, g.orte[spur.ort]!.y);
      }
    }
    return RueckblendeBild(t, personen, lichter, hell, bund);
  }
}
