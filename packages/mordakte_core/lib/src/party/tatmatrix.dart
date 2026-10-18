import '../util/geom.dart';
import 'raumgraph.dart';
import 'zeit.dart';

/// Ein Schritt im Plan einer Person (Tatmatrix-Datei).
///
/// Arten: Aufenthalt (`ort`), Weg (`nach` + `bis`), Haltungswechsel
/// (`haltung` allein), Gesagtes (`sagt`), Geräusch (`geraeusch`) und
/// getragenes Licht (`licht` + `an`).
class PlanSchritt {
  final Uhrzeit t;
  final String? ort;
  final String? nach;
  final Uhrzeit? bis;
  final String tempo;
  final List<String> ueber;
  final String? haltung;
  final String? sagt;
  final String? geraeusch;
  final String lautstaerke;
  final String? licht;
  final bool? an;

  PlanSchritt({
    required this.t,
    this.ort,
    this.nach,
    this.bis,
    this.tempo = 'gehen',
    this.ueber = const [],
    this.haltung,
    this.sagt,
    this.geraeusch,
    this.lautstaerke = 'leise',
    this.licht,
    this.an,
  });

  bool get istWeg => nach != null;

  factory PlanSchritt.fromJson(Map j) => PlanSchritt(
        t: Uhrzeit.parse(j['t'] as String),
        ort: j['ort'] as String?,
        nach: j['nach'] as String?,
        bis: j['bis'] == null ? null : Uhrzeit.parse(j['bis'] as String),
        tempo: j['tempo'] as String? ?? 'gehen',
        ueber: [for (final u in (j['ueber'] as List? ?? const [])) u as String],
        haltung: j['haltung'] as String?,
        sagt: j['sagt'] as String?,
        geraeusch: j['geraeusch'] as String?,
        lautstaerke: j['lautstaerke'] as String? ?? 'leise',
        licht: j['licht'] as String?,
        an: j['an'] as bool?,
      );
}

/// Ein Ereignis der Tatnacht mit Ort (Geräusch, Geruch, Handlung, Türzustand).
class TatEreignis {
  final String id;
  final Uhrzeit t;
  final String ort;
  final String art;
  final String? lautstaerke;
  final String text;
  final String? person;
  final String? ziel;
  final String? tuer;
  final String? zustand;

  TatEreignis({
    required this.id,
    required this.t,
    required this.ort,
    required this.art,
    required this.text,
    this.lautstaerke,
    this.person,
    this.ziel,
    this.tuer,
    this.zustand,
  });

  factory TatEreignis.fromJson(Map j) => TatEreignis(
        id: j['id'] as String,
        t: Uhrzeit.parse(j['t'] as String),
        ort: j['ort'] as String,
        art: j['art'] as String,
        text: j['text'] as String? ?? '',
        lautstaerke: j['lautstaerke'] as String?,
        person: j['person'] as String?,
        ziel: j['ziel'] as String?,
        tuer: j['tuer'] as String?,
        zustand: j['zustand'] as String?,
      );
}

/// Ein Punkt in der Spur eines Gegenstands: getragen, an einem Ort oder auf
/// einem Einrichtungsstück.
class SpurPunkt {
  final Uhrzeit t;
  final String? traeger;
  final String? ort;
  final String? einrichtung;
  final String? stelle;

  SpurPunkt({required this.t, this.traeger, this.ort, this.einrichtung, this.stelle});

  factory SpurPunkt.fromJson(Map j) => SpurPunkt(
        t: Uhrzeit.parse(j['t'] as String),
        traeger: j['traeger'] as String?,
        ort: j['ort'] as String?,
        einrichtung: j['einrichtung'] as String?,
        stelle: j['stelle'] as String?,
      );
}

class GegenstandSpur {
  final String id;
  final List<SpurPunkt> spur;
  GegenstandSpur(this.id, this.spur);

  factory GegenstandSpur.fromJson(Map j) =>
      GegenstandSpur(j['id'] as String, [for (final p in j['spur'] as List) SpurPunkt.fromJson(p as Map)]);

  /// Letzter Spurpunkt bis einschließlich [t].
  SpurPunkt? stand(Uhrzeit t) {
    SpurPunkt? s;
    for (final p in spur) {
      if (p.t <= t) s = p;
    }
    return s;
  }
}

/// Inhalt einer Tatmatrix-Datei (`tatmatrix/basis.json` oder ein Pfad).
class TatmatrixDatei {
  final String pfad;
  final Map<String, List<PlanSchritt>> plaene;
  final List<TatEreignis> ereignisse;
  final Map<String, GegenstandSpur> gegenstaende;

  TatmatrixDatei({required this.pfad, required this.plaene, required this.ereignisse, required this.gegenstaende});

  factory TatmatrixDatei.fromJson(Map j) => TatmatrixDatei(
        pfad: j['pfad'] as String,
        plaene: {
          for (final e in (j['plaene'] as Map? ?? const {}).entries)
            e.key as String: [for (final s in e.value as List) PlanSchritt.fromJson(s as Map)],
        },
        ereignisse: [for (final e in (j['ereignisse'] as List? ?? const [])) TatEreignis.fromJson(e as Map)],
        gegenstaende: {
          for (final g in (j['gegenstaende'] as List? ?? const []).map((e) => GegenstandSpur.fromJson(e as Map))) g.id: g,
        },
      );
}

/// Zusammengeführte Tatmatrix eines Pfads: Basis plus Pfaddatei.
class Tatmatrix {
  final String pfad;
  final Map<String, List<PlanSchritt>> plaene;
  final List<TatEreignis> ereignisse;
  final Map<String, GegenstandSpur> gegenstaende;

  Tatmatrix({required this.pfad, required this.plaene, required this.ereignisse, required this.gegenstaende});

  factory Tatmatrix.zusammen(TatmatrixDatei basis, TatmatrixDatei pfad) => Tatmatrix(
        pfad: pfad.pfad,
        plaene: {...basis.plaene, ...pfad.plaene},
        ereignisse: [...basis.ereignisse, ...pfad.ereignisse]..sort((a, b) => a.t.compareTo(b.t)),
        gegenstaende: {...basis.gegenstaende, ...pfad.gegenstaende},
      );
}

/// Ein Abschnitt im Ablauf einer Person: Aufenthalt oder Weg.
class Abschnitt {
  final Uhrzeit von;
  final Uhrzeit bis;
  final List<(double, double)> linie;
  final double laenge;
  final String? ort;
  final String haltung;
  final String? tempo;
  final String? zielOrt;

  Abschnitt.aufenthalt({required this.von, required this.bis, required String this.ort, required this.haltung, required double x, required double y})
      : linie = [(x, y)],
        laenge = 0,
        tempo = null,
        zielOrt = ort;

  Abschnitt.weg({
    required this.von,
    required this.bis,
    required this.linie,
    required this.laenge,
    required this.tempo,
    required this.zielOrt,
    required this.haltung,
  }) : ort = null;

  bool get istWeg => tempo != null;

  (double, double) posAm(Uhrzeit t) => posAmBruch(t.sekunden.toDouble());

  /// Wie [posAm], aber zu einer Zeit mit Sekundenbruchteil ([sekunden] seit
  /// 12:00 Uhr). Die Rückblende zeichnet damit jedes Bild genau auf der Linie;
  /// für ganze Sekunden ist das Ergebnis dasselbe wie bei [posAm].
  (double, double) posAmBruch(double sekunden) {
    if (!istWeg || linie.length == 1) return linie.first;
    final dauer = bis.minus(von);
    final f = dauer <= 0 ? 1.0 : ((sekunden - von.sekunden) / dauer).clamp(0.0, 1.0);
    var rest = f * laenge;
    for (var i = 1; i < linie.length; i++) {
      final a = linie[i - 1], b = linie[i];
      final d = dist(a.$1, a.$2, b.$1, b.$2);
      if (rest <= d || i == linie.length - 1) {
        final g = d == 0 ? 1.0 : (rest / d).clamp(0.0, 1.0);
        return (a.$1 + (b.$1 - a.$1) * g, a.$2 + (b.$2 - a.$2) * g);
      }
      rest -= d;
    }
    return linie.last;
  }
}

/// Zustand einer Person zu einem Zeitpunkt.
class PersonZustand {
  final String person;
  final double x, y;
  final String? raum;
  final String? ort;
  final String haltung;
  final String? tempo;
  const PersonZustand({required this.person, required this.x, required this.y, required this.raum, required this.ort, required this.haltung, required this.tempo});

  bool get bewegtSich => tempo != null;
}

/// Ein Fehler beim Aufbau des Ablaufs (fehlender Ort, kein Weg, …).
class AblaufFehler {
  final String person;
  final Uhrzeit t;
  final String text;
  AblaufFehler(this.person, this.t, this.text);
  @override
  String toString() => '$person @ $t: $text';
}

/// Der räumliche Ablauf aller Personen eines Pfads.
class Ablauf {
  final RaumGraph graph;
  final Tatmatrix matrix;
  final Uhrzeit start;
  final Uhrzeit ende;
  final Map<String, List<Abschnitt>> abschnitte = {};
  final List<AblaufFehler> fehler = [];

  Ablauf(this.graph, this.matrix, {required this.start, required this.ende}) {
    for (final e in matrix.plaene.entries) {
      abschnitte[e.key] = _baue(e.key, e.value);
    }
  }

  List<Abschnitt> _baue(String person, List<PlanSchritt> plan) {
    final out = <Abschnitt>[];
    if (plan.isEmpty || plan.first.ort == null) {
      fehler.add(AblaufFehler(person, start, 'Plan beginnt nicht mit einem Aufenthalt'));
      return out;
    }
    String ort = plan.first.ort!;
    String haltung = plan.first.haltung ?? 'steht';
    Uhrzeit seit = plan.first.t;
    if (seit > start) fehler.add(AblaufFehler(person, seit, 'Plan beginnt nach $start'));
    if (graph.orte[ort] == null) fehler.add(AblaufFehler(person, seit, 'unbekannter Ort $ort'));

    void schliesse(Uhrzeit bis) {
      final o = graph.orte[ort];
      if (o == null) return;
      if (bis > seit) out.add(Abschnitt.aufenthalt(von: seit, bis: bis, ort: ort, haltung: haltung, x: o.x, y: o.y));
    }

    Uhrzeit? letzteZeit;
    for (final s in plan.skip(1)) {
      if (letzteZeit != null && s.t < letzteZeit) fehler.add(AblaufFehler(person, s.t, 'Schritte nicht zeitlich sortiert'));
      letzteZeit = s.t;
      if (s.istWeg) {
        if (s.bis == null || s.bis! <= s.t) {
          fehler.add(AblaufFehler(person, s.t, 'Weg ohne gültiges Ende'));
          continue;
        }
        if (s.t < seit) fehler.add(AblaufFehler(person, s.t, 'Weg beginnt vor dem vorigen Schritt'));
        schliesse(s.t);
        final stationen = [ort, ...s.ueber, s.nach!];
        final linie = <(double, double)>[];
        var laenge = 0.0;
        var ok = true;
        for (var i = 1; i < stationen.length; i++) {
          final a = graph.orte[stationen[i - 1]], b = graph.orte[stationen[i]];
          if (a == null || b == null) {
            fehler.add(AblaufFehler(person, s.t, 'unbekannter Ort ${a == null ? stationen[i - 1] : stationen[i]}'));
            ok = false;
            break;
          }
          final teil = _linie(a, b);
          if (teil == null) {
            fehler.add(AblaufFehler(person, s.t, 'kein begehbarer Weg ${a.id} → ${b.id}'));
            ok = false;
            break;
          }
          if (linie.isEmpty) linie.add(teil.$1.first);
          linie.addAll(teil.$1.skip(1));
          laenge += teil.$2;
        }
        if (!ok) continue;
        out.add(Abschnitt.weg(
          von: s.t,
          bis: s.bis!,
          linie: linie,
          laenge: laenge,
          tempo: s.tempo,
          zielOrt: s.nach,
          haltung: switch (s.tempo) {
            'rennen' => 'rennt',
            'faellt' => 'faellt',
            _ => 'geht',
          },
        ));
        ort = s.nach!;
        haltung = s.haltung ?? 'steht';
        seit = s.bis!;
      } else if (s.ort != null && s.ort != ort) {
        fehler.add(AblaufFehler(person, s.t, 'Ortswechsel ohne Weg ($ort → ${s.ort})'));
      } else if (s.haltung != null) {
        if (s.t < seit) {
          // Haltungswechsel während eines Wegs: gilt ab Ankunft.
          haltung = s.haltung!;
        } else {
          schliesse(s.t);
          haltung = s.haltung!;
          seit = s.t;
        }
      }
    }
    schliesse(ende.plus(1));
    return out;
  }

  /// Polylinie und Länge zwischen zwei Standorten über das Raster.
  (List<(double, double)>, double)? _linie(Ort a, Ort b) {
    final start = Pt(a.x.floor(), a.y.floor()), ziel = Pt(b.x.floor(), b.y.floor());
    final punkte = <(double, double)>[(a.x, a.y)];
    if (start != ziel) {
      final pfad = graph.raster.findPath(start, ziel);
      if (pfad == null) return null;
      for (var i = 0; i < pfad.length - 1; i++) {
        punkte.add((pfad[i].x + 0.5, pfad[i].y + 0.5));
      }
    }
    punkte.add((b.x, b.y));
    var laenge = 0.0;
    for (var i = 1; i < punkte.length; i++) {
      laenge += dist(punkte[i - 1].$1, punkte[i - 1].$2, punkte[i].$1, punkte[i].$2);
    }
    return (punkte, laenge + a.zusatzweg + b.zusatzweg);
  }

  Abschnitt? abschnittAm(String person, Uhrzeit t) {
    final l = abschnitte[person];
    if (l == null) return null;
    for (final a in l) {
      if (t >= a.von && t < a.bis) return a;
    }
    return null;
  }

  /// Zustand zur Uhrzeit [t]; mit [bruch] (0 bis unter 1) liegt die Position
  /// um diesen Sekundenbruchteil später auf dem Weg. Abschnitte beginnen und
  /// enden auf ganzen Sekunden, der Abschnitt bleibt also derselbe.
  PersonZustand? zustand(String person, Uhrzeit t, {double bruch = 0}) {
    final a = abschnittAm(person, t);
    if (a == null) return null;
    final p = bruch == 0 ? a.posAm(t) : a.posAmBruch(t.sekunden + bruch);
    return PersonZustand(
      person: person,
      x: p.$1,
      y: p.$2,
      raum: a.ort != null ? graph.orte[a.ort]!.raum : (graph.raumAn(p.$1, p.$2)?.id ?? _raumDerTuer(p.$1, p.$2)),
      ort: a.ort,
      haltung: a.haltung,
      tempo: a.tempo,
    );
  }

  /// Auf einer Türkachel gilt der Raum auf der Seite, von der die Person kommt;
  /// vereinfacht: der erste Raum der Tür.
  String? _raumDerTuer(double x, double y) {
    for (final t in graph.tueren.values) {
      for (final k in t.kacheln) {
        if (k.x == x.floor() && k.y == y.floor()) return t.von;
      }
    }
    return null;
  }

  Iterable<String> get personen => abschnitte.keys;

  /// Standort-Beschreibung für die 15-Sekunden-Matrix.
  String ortText(String person, Uhrzeit t) {
    final z = zustand(person, t);
    if (z == null) return '–';
    if (z.ort != null) return z.ort!;
    final naechster = _naechsterOrt(z.x, z.y);
    return 'unterwegs bei $naechster (x ${z.x.toStringAsFixed(1)}, y ${z.y.toStringAsFixed(1)})';
  }

  String _naechsterOrt(double x, double y) {
    String? best;
    var bd = double.infinity;
    for (final o in graph.orte.values) {
      final d = dist(o.x, o.y, x, y);
      if (d < bd) {
        bd = d;
        best = o.id;
      }
    }
    return best ?? '?';
  }
}
