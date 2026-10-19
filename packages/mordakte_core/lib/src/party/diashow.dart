/// Diashow zur Einleitung (Langer Abend M4, `content/welt/<akte>/diashow.json`,
/// Format `diashow/1`): Während der Erzähler die Einleitung vorliest, zeigen die
/// Geräte Bilder aus der Spielgrafik, eines je Abschnitt des Intros
/// ([Erzaehler.introAbschnitte]). Die App rendert sie in der Engine
/// (`lib/party/dia_session.dart`); fremde Dienste oder Bilddateien gibt es nicht.
///
/// Ein Dia ist reine Regie ohne Text: welcher Baustein, wohin die Kamera schaut
/// und wie sie fährt, wer im Bild steht, welches Licht. Eine Bildunterschrift
/// gibt es nicht; was zu sagen ist, liest der Erzähler vor.
library;

import 'erzaehler.dart';
import 'kanon/kanon.dart';

/// Kennung des Dateiformats.
const diashowFormat = 'diashow/1';

/// So viele Bilder hat eine Diashow (Besitzer: drei bis sechs).
const diaMin = 3, diaMax = 6;

/// So viele Wörter hat ein Baustein mit Bild höchstens bzw. mindestens: Länger
/// steht ein Bild zu lange, kürzer wechselt es zu schnell.
const diaWorteMin = 20, diaWorteMax = 60;

/// Höchstens so viele Figuren stehen in einem Bild.
const diaFigurenMax = 4;

/// Wie sich die Kamera während eines Bildes bewegt (mit „Bewegung reduzieren“ nie).
enum DiaFahrt {
  /// Steht still.
  ruhig,

  /// Fährt langsam heran.
  heran,

  /// Fährt langsam zurück (vom Nahen ins Weite).
  zurueck,

  /// Schwenkt langsam zur Seite.
  schwenk,
}

/// Licht und Färbung eines Bildes.
enum DiaStimmung {
  /// Der Abend vor dem Stromausfall: warmes Licht.
  feier,

  /// Nach dem Knall: dunkel, nur Kerzen und das grüne Notausgangsschild.
  stromausfall,

  /// Rückblick auf einen Lacher früher am Abend: warm und sepiagetönt.
  rueckblick,
}

/// Wohin die Kamera eines Bildes schaut: ein Ort oder ein ganzer Raum des
/// Raumgraphen, mit Vergrößerung ([zoom], 1 = Grundausschnitt) und [fahrt].
class DiaKamera {
  const DiaKamera({this.ort, this.raum, this.zoom = 1, this.fahrt = DiaFahrt.ruhig});

  final String? ort;
  final String? raum;
  final double zoom;
  final DiaFahrt fahrt;

  static const zoomMin = 1.0, zoomMax = 2.0;
}

/// Ein Bild der Diashow.
class Dia {
  const Dia({required this.baustein, required this.kamera, this.figuren = const [], this.liegt = const [], this.stimmung = DiaStimmung.feier});

  /// Abschnitt des Intros ohne Fassung: `intro.start`, `intro.ausfall`,
  /// `intro.lacher.<id>`, `intro.auftrag`.
  final String baustein;
  final DiaKamera kamera;

  /// Kanon-Personen im Bild (Kennungen; der Detektiv heißt wie im Kanon).
  final List<String> figuren;

  /// Personen aus [figuren], die liegen (nur das Opfer, bewusstlos nach dem Knall).
  final List<String> liegt;
  final DiaStimmung stimmung;

  /// Gehört der Erzähler-Baustein [kennung] (mit Fassung) zu diesem Bild?
  bool zeigt(String kennung) => kennung == baustein || kennung.startsWith('$baustein.');
}

/// Die Diashow einer Akte, unveränderlich.
class Diashow {
  Diashow._(this.akte, this.dias);

  final String akte;
  final List<Dia> dias;

  /// Liest `{"format": "diashow/1", "akte": …, "dias": […]}`. Unbekannte
  /// Felder sind ein Fehler: Ein Dia trägt nie einen Text.
  factory Diashow.ausJson(Map<String, Object?> j) {
    if (j['format'] != diashowFormat) throw FormatException('Diashow: Format ${j['format']} statt $diashowFormat');
    _nur(j, const {'format', 'akte', 'hinweis', 'dias'}, 'Diashow');
    final dias = <Dia>[];
    for (final (i, e) in (j['dias'] as List).indexed) {
      final m = (e as Map).cast<String, Object?>();
      _nur(m, const {'baustein', 'kamera', 'figuren', 'liegt', 'stimmung'}, 'Dia ${i + 1}');
      final k = (m['kamera'] as Map).cast<String, Object?>();
      _nur(k, const {'ort', 'raum', 'zoom', 'fahrt'}, 'Dia ${i + 1}, kamera');
      dias.add(Dia(
        baustein: m['baustein'] as String,
        kamera: DiaKamera(
          ort: k['ort'] as String?,
          raum: k['raum'] as String?,
          zoom: (k['zoom'] as num? ?? 1).toDouble(),
          fahrt: _enum(DiaFahrt.values, k['fahrt'] ?? 'ruhig', 'fahrt'),
        ),
        figuren: [for (final f in (m['figuren'] as List? ?? const [])) f as String],
        liegt: [for (final f in (m['liegt'] as List? ?? const [])) f as String],
        stimmung: _enum(DiaStimmung.values, m['stimmung'] ?? 'feier', 'stimmung'),
      ));
    }
    return Diashow._(j['akte'] as String, List.unmodifiable(dias));
  }

  /// Nummer des Bildes (ab 0) zum Erzähler-Baustein [kennung], sonst `null`.
  int? nrFuer(String kennung) {
    for (final (i, d) in dias.indexed) {
      if (d.zeigt(kennung)) return i;
    }
    return null;
  }

  static void _nur(Map<String, Object?> m, Set<String> erlaubt, String wo) {
    final fremd = m.keys.where((k) => !erlaubt.contains(k));
    if (fremd.isNotEmpty) throw FormatException('$wo: unbekanntes Feld ${fremd.join(', ')}');
  }

  static T _enum<T extends Enum>(List<T> werte, Object? name, String feld) =>
      werte.where((w) => w.name == name).firstOrNull ?? (throw FormatException('Diashow: $feld $name unbekannt'));
}

final _wortRe = RegExp(r'[\p{L}\p{N}]+(?:-[\p{L}\p{N}]+)*', unicode: true);

/// Wörter eines Textes, klein geschrieben.
List<String> _worte(String text) => [for (final m in _wortRe.allMatches(text)) m.group(0)!.toLowerCase()];

/// Prüft die Diashow [d] gegen [kanon] und die Erzähltexte der Akte ([text]
/// liefert den Baustein zu einer Kennung, `null`, wenn es ihn nicht gibt).
/// Liefert Befunde als Sätze; leer heißt in Ordnung.
///
/// - [diaMin] bis [diaMax] Bilder; jedes gehört zu genau einem Abschnitt des
///   Intros, jeder Abschnitt hat genau ein Bild, in der Reihenfolge des Intros.
/// - Jede Fassung des Bausteins hat [diaWorteMin] bis [diaWorteMax] Wörter.
/// - Die Kamera schaut auf genau einen bekannten Ort oder Raum, mit Zoom
///   zwischen [DiaKamera.zoomMin] und [DiaKamera.zoomMax]; im Bild stehen nur
///   bekannte Personen, jede einmal, höchstens [diaFigurenMax]; liegen darf nur
///   das Opfer, und nur, wenn es im Bild steht.
/// - Keine Fallhinweise (R15): Ein Sperrort (Fundort eines Gegenstands,
///   Ziel-Ort einer Entscheidung, Ort eines Lachers) oder ein Ziel-Raum ist
///   Kameraziel nur, wenn der Baustein seinen Raum nennt oder das Bild den
///   Lacher an seinem Ort zeigt; ein Ort, an dem nur in manchen Pfaden eine
///   Spur liegt, nur im Bild seines Lachers. Im Bild steht eine Person nur, wenn der Baustein sie nennt, sie
///   den Lacher des Bildes spielt oder sie der Detektiv im Auftrag ist; sonst
///   nur Gäste, die nicht verdächtig sind. So zeigt kein Bild etwas, das auf
///   allen Pfaden zur selben Spur schiebt.
List<String> pruefeDiashow(Diashow d, Kanon kanon, String? Function(String kennung) text) {
  final befunde = <String>[];
  if (d.dias.length < diaMin || d.dias.length > diaMax) befunde.add('${d.dias.length} Bilder (erlaubt $diaMin–$diaMax)');

  final abschnitte = Erzaehler(kanon).introAbschnitte;
  final basen = [for (final a in abschnitte) a.basis];
  final gezeigt = [for (final dia in d.dias) dia.baustein];
  for (final b in gezeigt.toSet()) {
    if (!basen.contains(b)) befunde.add('$b ist kein Abschnitt des Intros (${basen.join(', ')})');
    final n = gezeigt.where((x) => x == b).length;
    if (n > 1) befunde.add('$b hat $n Bilder (genau eines je Abschnitt)');
  }
  for (final b in basen) {
    if (!gezeigt.contains(b)) befunde.add('$b hat kein Bild');
  }
  final reihe = [for (final b in gezeigt) if (basen.contains(b)) b];
  if (reihe.toSet().length == reihe.length && reihe.join(',') != [for (final b in basen) if (reihe.contains(b)) b].join(',')) {
    befunde.add('Bilder stehen nicht in der Reihenfolge des Intros (${basen.join(', ')})');
  }

  final g = kanon.graph;
  final lacher = {
    for (final l in (kanon.json['setting.json']?['lacher'] as List? ?? const []))
      'intro.lacher.${(l as Map)['id']}': (wer: l['wer'] as String, ort: l['ort'] as String),
  };
  final sperrorte = _sperrorte(kanon);
  final spurOrte = _pfadSpurOrte(kanon);
  final zielRaeume = _zielRaeume(kanon);
  final detektiv = (kanon.figurenJson['detektiv'] as Map)['id'] as String;
  final opfer = (kanon.figurenJson['opfer'] as Map)['id'] as String;
  final verdaechtig = {...kanon.kernverdaechtige};

  for (final (i, dia) in d.dias.indexed) {
    final wo = 'Bild ${i + 1} (${dia.baustein})';
    final fassungen = abschnitte.where((a) => a.basis == dia.baustein).firstOrNull?.fassungen ?? const <String>[];
    final saetze = <String>[];
    for (final f in fassungen) {
      final t = text(f);
      if (t == null) {
        befunde.add('$wo: Baustein $f fehlt');
        continue;
      }
      saetze.add(t);
      final n = _worte(t).length;
      if (n < diaWorteMin || n > diaWorteMax) befunde.add('$wo: $f hat $n Wörter (erlaubt $diaWorteMin–$diaWorteMax)');
    }
    // Nennt jede Fassung des Bausteins den Raum [raum]? Ein Wort ab fünf
    // Buchstaben zählt, wenn es ein Wort des Raumnamens ist oder dessen Anfang
    // (Buffet für den Buffetsaal).
    bool nenntRaum(String raum) {
      final r = g.raeume[raum];
      if (r == null || saetze.isEmpty) return false;
      final namen = {for (final w in [..._worte(r.name), ..._worte(r.anzeigename)]) if (w.length >= 5) w};
      return saetze.every((t) => _worte(t).any((w) => w.length >= 5 && namen.any((n) => n == w || n.startsWith(w))));
    }

    // Kamera
    final k = dia.kamera;
    if ((k.ort == null) == (k.raum == null)) befunde.add('$wo: Kamera braucht genau einen Ort oder einen Raum');
    if (k.zoom < DiaKamera.zoomMin || k.zoom > DiaKamera.zoomMax) befunde.add('$wo: Zoom ${k.zoom} (erlaubt ${DiaKamera.zoomMin}–${DiaKamera.zoomMax})');
    final l = lacher[dia.baustein];
    if (k.ort case final ort?) {
      final o = g.orte[ort];
      if (o == null) {
        befunde.add('$wo: Ort $ort gibt es in ${kanon.settingId} nicht');
      } else if (l?.ort == ort) {
        // Der Lacher an seinem Ort: steht so in jeder Fassung des Intros.
      } else if (spurOrte.contains(ort)) {
        befunde.add('$wo: Kamera auf ${o.name}, wo nur in manchen Pfaden eine Spur liegt (R15)');
      } else if (sperrorte.contains(ort) && !nenntRaum(o.raum)) {
        befunde.add('$wo: Kamera auf ${o.name}, einen Sperrort, den der Baustein nicht nennt (R15)');
      }
    }
    if (k.raum case final raum?) {
      if (!g.raeume.containsKey(raum)) {
        befunde.add('$wo: Raum $raum gibt es in ${kanon.settingId} nicht');
      } else if (zielRaeume.contains(raum) && !nenntRaum(raum)) {
        befunde.add('$wo: Kamera auf ${g.raeume[raum]!.anzeigename}, einen Ziel-Raum, den der Baustein nicht nennt (R15)');
      }
    }

    // Figuren
    if (dia.figuren.length > diaFigurenMax) befunde.add('$wo: ${dia.figuren.length} Figuren (höchstens $diaFigurenMax)');
    if (dia.figuren.toSet().length != dia.figuren.length) befunde.add('$wo: eine Figur steht doppelt im Bild');
    for (final f in dia.liegt) {
      if (!dia.figuren.contains(f)) befunde.add('$wo: $f liegt, steht aber nicht im Bild');
      if (f != opfer) befunde.add('$wo: $f liegt; liegen darf nur das Opfer');
    }
    for (final f in dia.figuren) {
      final fig = kanon.figur(f);
      if (fig == null) {
        befunde.add('$wo: Figur $f gibt es in ${kanon.settingId} nicht');
        continue;
      }
      final name = fig['name'];
      final genannt = name is String && saetze.isNotEmpty && saetze.every((t) => t.contains(name));
      final erlaubt = genannt ||
          l?.wer == f ||
          (f == detektiv && dia.baustein == 'intro.auftrag') ||
          (f != detektiv && f != opfer && !verdaechtig.contains(f));
      if (!erlaubt) befunde.add('$wo: $f steht im Bild, aber der Baustein nennt die Figur nicht (R15)');
    }
  }
  return befunde;
}

/// Sperrorte (R15) als Ort-Kennungen: Fundorte der Gegenstände, Ziel-Orte der
/// Entscheidungen und Orte der Lacher.
Set<String> _sperrorte(Kanon kanon) => {
      for (final g in kanon.gegenstaende)
        if ((g['lage'] as Map?)?['ort'] case final String o) o,
      for (final e in kanon.entscheidungenJson['entscheidungen'] as List)
        for (final o in (e as Map)['optionen'] as List)
          if (((o as Map)['ziel'] as Map?)?['ort'] case final String ort) ort,
      for (final l in (kanon.json['setting.json']?['lacher'] as List? ?? const []))
        if ((l as Map)['ort'] case final String o) o,
    };

/// Räume, auf die eine Entscheidung zielt (Wo suchst du?).
Set<String> _zielRaeume(Kanon kanon) => {
      for (final e in kanon.entscheidungenJson['entscheidungen'] as List)
        for (final o in (e as Map)['optionen'] as List)
          if (((o as Map)['ziel'] as Map?)?['raum'] case final String raum) raum,
    };

/// Orte, an denen eine Gegenstandsspur der Tatmatrix nur in einem Teil der
/// Pfade liegt; ohne Simulation keine.
Set<String> _pfadSpurOrte(Kanon kanon) {
  if (!kanon.hatSimulation) return const {};
  final je = [
    for (final p in kanon.pfade)
      {
        for (final s in kanon.tatmatrix(p).gegenstaende.values)
          for (final punkt in s.spur)
            if (punkt.ort case final o?) o,
      },
  ];
  if (je.isEmpty) return const {};
  final alle = je.reduce((a, b) => a.union(b));
  final ueberall = je.reduce((a, b) => a.intersection(b));
  return alle.difference(ueberall);
}
