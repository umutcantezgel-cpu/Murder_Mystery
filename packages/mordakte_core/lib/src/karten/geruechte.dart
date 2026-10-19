/// Gerüchte einer Akte (`content/welt/<akte>/geruechte.json`, Format
/// `geruechte/1`): je Figur und Runde ein bis zwei kurze Zeilen, die die
/// Journalistin beim Vorbeigehen hört (Klassenfähigkeit Gerüchte, A-055).
///
/// Gerüchte sind reine Stimmung: in allen Pfaden gleich, ohne Fallgegenstand,
/// Suchstelle, Indizort, Lacher oder Sperrort (R15) und ohne Namen. Sie
/// berühren weder Wahl noch Wurf noch Wertung; diese Datei liest darum weder
/// Partie noch Zugschicht noch Würfel.
library;

import '../party/kanon/kanon.dart';
import '../party/textpruefer.dart';
import 'sperrwoerter.dart';

/// Kennung des Dateiformats.
const geruechteFormat = 'geruechte/1';

/// Höchstens so viele Wörter hat eine Gerüchtzeile (R17).
const geruechtWorte = 8;

/// Die Gerüchte einer Akte, unveränderlich.
class Geruechte {
  Geruechte._(this.akte, this._zeilen);

  final String akte;
  final Map<String, Map<int, List<String>>> _zeilen;

  /// Liest `{"format": "geruechte/1", "akte": …, "geruechte": [{figur, runde, zeilen}]}`.
  factory Geruechte.ausJson(Map<String, Object?> j) {
    if (j['format'] != geruechteFormat) throw FormatException('Gerüchte: Format ${j['format']} statt $geruechteFormat');
    final zeilen = <String, Map<int, List<String>>>{};
    for (final e in j['geruechte'] as List) {
      final m = e as Map;
      final je = zeilen.putIfAbsent(m['figur'] as String, () => {});
      je.putIfAbsent(m['runde'] as int, () => []).addAll([for (final z in m['zeilen'] as List) z as String]);
    }
    return Geruechte._(j['akte'] as String, {
      for (final e in zeilen.entries) e.key: {for (final r in e.value.entries) r.key: List.unmodifiable(r.value)},
    });
  }

  /// Zeilen der Figur [figur] (Kanon-Kennung) in Runde [runde]; leer ohne Gerücht.
  List<String> zeilen(String figur, int runde) => _zeilen[figur]?[runde] ?? const [];

  /// Figuren mit Gerüchten.
  Iterable<String> get figuren => _zeilen.keys;

  /// Alle Einträge in Dateireihenfolge der Figuren, je Runde aufsteigend.
  Iterable<({String figur, int runde, List<String> zeilen})> get eintraege sync* {
    for (final f in _zeilen.entries) {
      for (final r in (f.value.keys.toList()..sort())) {
        yield (figur: f.key, runde: r, zeilen: f.value[r]!);
      }
    }
  }
}

/// Wörter aus den Namen von Sperrorten, die zu allgemein sind, um sie zu sperren.
const _allgemeineOrtswoerter = {'hinter', 'direkt', 'linken', 'rechten', 'neben', 'unter', 'vorne', 'beim'};

/// Wörter, die zusätzlich zu den [spoilerWoerter] in keinem Gerücht stehen:
/// rund um den Vorfall.
const _vorfallWoerter = ['scheppern', 'geschepper', 'knall', 'sicherung', 'strom', 'miete', 'geld', 'kassier'];

/// Umwege, die kein Name trägt: Wortteile, die am Anfang oder Ende eines
/// Wortes auf einen Gegenstand, ein Geheimnis oder das Ziel einer Entscheidung
/// zeigen (R15). Gespenst, Geist, Spuk, Schreck und Streich zeigen auf die
/// Leuchtmaske und Cans Streich, Liste, Beleg und Zahl auf Quittung und
/// Notizbuch, Stiftung und Advent auf das Mietgeld, Turm auf den Turmgang. Sie
/// treffen auch Schlossgeist, Gästeliste, bezahlt und Turmuhr, aber nicht
/// begeistert.
const _beinamen = ['gespenst', 'geist', 'spuk', 'schreck', 'streich', 'liste', 'beleg', 'zahl', 'stiftung', 'advent', 'turm'];

/// Verbendungen, die vor dem Vergleich mit den [_beinamen] zusätzlich zu den
/// Endungen der [wortformen] wegfallen (spukt, erschreckt, bezahlt).
const _verbendungen = ['st', 't'];

/// Trägt [wort] einen der [_beinamen] am Anfang oder Ende (auch ohne Endung)?
String? _beiname(String wort) {
  final w = wort.toLowerCase();
  final staemme = {
    ...wortformen(w),
    for (final e in _verbendungen)
      if (w.length - e.length >= 3 && w.endsWith(e)) w.substring(0, w.length - e.length),
  };
  for (final b in _beinamen) {
    if (staemme.any((s) => s.startsWith(b) || s.endsWith(b))) return b;
  }
  return null;
}

/// Prüft die [geruechte] gegen den [kanon]. Liefert Befunde als Sätze; leer
/// heißt in Ordnung.
///
/// - Jede Figur des Kanons hat in jeder Runde ein bis zwei Zeilen, keine
///   unbekannte Figur, keine Runde außerhalb 1–3.
/// - Jede Zeile ist ein Satz mit höchstens [geruechtWorte] Wörtern (R17).
/// - Keine Zeile nennt ein Sperrwort, einen Gegenstand, einen Namen oder ein
///   Wort aus dem Namen eines Sperrorts: Fundorte der Gegenstände, Ziel-Orte
///   und Ziel-Räume der Entscheidungen und Orte der Lacher (R15). Das gilt
///   auch für kurze Wörter und Teile zusammengesetzter Namen ([teilwoerter]):
///   Brot aus Brottasche, Ring aus Silberring, Helm, Foto, Vitrine aus
///   Schauvitrine, Turm aus Turmgang.
/// - Keine Zeile nennt eine Suchstelle aus einer Option, die nur in einem Teil
///   der Pfade richtig ist ([_pfadSuchstellen]), gleich welche Figur sie sagt:
///   Bauchtasche bei Zeynep, Hände bei Tim.
/// - Keine Zeile nimmt einen Umweg zu einem Gegenstand oder Geheimnis
///   ([_beinamen]: Schlossgeist für die Leuchtmaske, Listen für die Quittung).
///   Sonst schiebt das Gerücht die Journalistin in allen Pfaden zur selben
///   Option, die nur in einem Pfad richtig ist.
/// - Keine Zeile einer Figur nennt ein Hauptwort aus dem, was sie verbirgt
///   oder trägt und was eine Entscheidung an ihr untersucht ([_bezug]), auch
///   nicht als Teil eines Wortes (handgewebt bei Fatmas Hand).
/// - Keine Zeile teilt fünf Wörter am Stück mit verborgenen Beobachtungen,
///   Wahrheiten, Rollengeheimnissen, Bonus-Hinweisen, Spuren oder [geschuetzt].
/// - Tonregeln über [ton].
List<String> pruefeGeruechte(Geruechte geruechte, Kanon kanon, {Textpruefer? ton, Iterable<String> geschuetzt = const []}) {
  final befunde = <String>[];
  final figuren = [for (final f in kanon.figuren) f['id'] as String];
  for (final f in geruechte.figuren) {
    if (!figuren.contains(f)) befunde.add('$f: Figur gibt es in ${kanon.settingId} nicht');
  }
  for (final f in figuren) {
    for (var r = 1; r <= 3; r++) {
      final n = geruechte.zeilen(f, r).length;
      if (n < 1 || n > 2) befunde.add('$f, Runde $r: $n Zeilen (erlaubt 1–2)');
    }
  }

  final sperrorte = _sperrorte(kanon);
  final sperren = [
    ...sperrregeln(kanon.figurenJson, kanon.gegenstaendeJson),
    for (final w in _vorfallWoerter) wortAnfang(w),
    for (final o in sperrorte)
      for (final w in kennwoerter(o, mindestens: 5))
        if (!_allgemeineOrtswoerter.contains(w)) wortAnfang(w),
  ];
  // Teile der Namen von Gegenständen, Sperrorten und Ziel-Räumen, je mit ihrem
  // Namen; sie treffen nur ganze Wörter einer Zeile. Ein Ziel-Raum ist nie zu
  // allgemein (Turmgang).
  final teile = <String, String>{};
  for (final (name, ohne, allgemein) in [
    for (final g in kanon.gegenstaende) (g['name'] as String, const <String>{}, allgemeineWoerter),
    for (final o in sperrorte) (o, _allgemeineOrtswoerter, allgemeineWoerter),
    for (final r in _zielRaeume(kanon)) (r, _allgemeineOrtswoerter, const <String>{}),
  ]) {
    for (final t in teilwoerter(name, ohne: ohne, allgemein: allgemein)) {
      teile.putIfAbsent(t, () => name);
    }
  }
  // Ebenso die Suchstellen pfadabhängiger Optionen, je mit dem Text der
  // Option; auch sie sind nie zu allgemein.
  for (final (suchstelle, option) in _pfadSuchstellen(kanon)) {
    for (final t in teilwoerter(suchstelle, allgemein: const {})) {
      teile.putIfAbsent(t, () => option);
    }
  }
  final bezug = _bezug(kanon);
  final gesperrt = <String>{for (final t in [..._geschuetzteTexte(kanon), ...geschuetzt]) ..._fuenfer(t)};

  for (final e in geruechte.eintraege) {
    if (e.runde < 1 || e.runde > 3) befunde.add('${e.figur}: Runde ${e.runde} außerhalb 1–3');
    for (final (i, z) in e.zeilen.indexed) {
      final ort = '${e.figur}, Runde ${e.runde}, Zeile ${i + 1}';
      if (z.trim().isEmpty) befunde.add('$ort: leer');
      final worte = _wortRe.allMatches(z).length;
      if (worte > geruechtWorte) befunde.add('$ort: $worte Wörter (höchstens $geruechtWorte, R17)');
      if (ton != null && ton.saetze(z).length != 1) befunde.add('$ort: mehr oder weniger als ein Satz');
      var r15 = false;
      for (final re in sperren) {
        final m = re.firstMatch(z);
        if (m != null) {
          befunde.add('$ort: „${m.group(0)}“ gehört nicht in ein pfadgleiches Gerücht (R15)');
          r15 = true;
          break;
        }
      }
      // Je Wort: Teil eines gesperrten Namens, Beiname, Hauptwort der eigenen
      // Figur. Für die Figur zerlegt der Prüfer das Wort der Zeile (handgewebt),
      // nie das Hauptwort; so bleiben die Bruchstücke der [teilwoerter] harmlos.
      for (final w in r15 ? const <RegExpMatch>[] : _wortRe.allMatches(z)) {
        final wort = w.group(0)!;
        if (wortformen(wort).map((f) => teile[f]).nonNulls.firstOrNull case final name?) {
          befunde.add('$ort: „$wort“ steckt in „$name“ und gehört nicht in ein pfadgleiches Gerücht (R15)');
        } else if (_beiname(wort) case final b?) {
          befunde.add('$ort: „$wort“ zeigt über „$b“ auf einen Gegenstand, ein Geheimnis oder ein Entscheidungsziel (R15)');
        } else if ([...wortformen(wort), for (final t in teilwoerter(wort)) ...wortformen(t)].map((f) => bezug[e.figur]?[f]).nonNulls.firstOrNull
            case final haupt?) {
          befunde.add('$ort: „$wort“ berührt „$haupt“ aus dem, was ${e.figur} verbirgt, trägt oder was eine Entscheidung an ihr untersucht (R15)');
        } else {
          continue;
        }
        break;
      }
      for (final f in _fuenfer(z)) {
        if (gesperrt.contains(f)) {
          befunde.add('$ort: übernimmt „$f“ aus einer geschützten Kanonstelle');
          break;
        }
      }
      if (ton != null) {
        for (final b in ton.pruefe(TextQuelle(ort: ort, text: z, vorlesen: false))) {
          befunde.add('$ort: ${b.regel} („${b.auszug}“)');
        }
      }
    }
  }
  return befunde;
}

/// Namen der Sperrorte: Fundorte der Gegenstände, Ziel-Orte der Entscheidungen
/// und Orte der Lacher.
List<String> _sperrorte(Kanon kanon) {
  final orte = <String>{
    for (final g in kanon.gegenstaende)
      if ((g['lage'] as Map?)?['ort'] case final String o) o,
    for (final e in kanon.entscheidungenJson['entscheidungen'] as List)
      for (final o in (e as Map)['optionen'] as List)
        if (((o as Map)['ziel'] as Map?)?['ort'] case final String ort) ort,
    for (final l in (kanon.json['setting.json']?['lacher'] as List? ?? const []))
      if ((l as Map)['ort'] case final String o) o,
  };
  return [
    for (final o in orte)
      if (kanon.graph.orte[o] case final ort?) ort.name,
  ];
}

/// Namen der Räume, auf die eine Entscheidung zielt (Ortsentscheidung: Wo
/// suchst du?), mit ihrem Anzeigenamen.
List<String> _zielRaeume(Kanon kanon) => [
      for (final e in kanon.entscheidungenJson['entscheidungen'] as List)
        for (final o in (e as Map)['optionen'] as List)
          if (((o as Map)['ziel'] as Map?)?['raum'] case final String raum)
            if (kanon.graph.raeume[raum] case final r?) ...{r.name, r.anzeigename},
    ];

/// Hauptwörter aus den Optionen der Entscheidungen, deren richtige Option je
/// Pfad verschieden ist, je mit dem Text der Option: die Suchstellen (Cans
/// Bauchtasche, der Ascheneimer, Fatmas Hände und ihr Ring). Kein Gerücht
/// nennt sie, gleich welche Figur es sagt; sonst schiebt es die Journalistin
/// in allen Pfaden zur selben Option.
List<(String, String)> _pfadSuchstellen(Kanon kanon) => [
      for (final e in kanon.entscheidungenJson['entscheidungen'] as List)
        if ((e as Map)['richtig'] case final Map richtig when richtig.values.toSet().length > 1)
          for (final o in e['optionen'] as List)
            for (final m in _hauptwortRe.allMatches((o as Map)['text'] as String)) (m.group(1)!, o['text'] as String),
    ];

/// Hauptwörter, die in den Gerüchten einer Figur nicht stehen, je Figur:
/// Wortform → Hauptwort. Sie kommen aus dem, was die Figur verbirgt (Geheimnis,
/// Motiv, Ziel, Nebendelikt, Lügen samt Wahrheit, Täter- und Unschuldsfassung,
/// Treue, Kennzeichen, Alibi), aus den Gegenständen, die sie trägt, samt Spuren,
/// aus ihren Beobachtungen und aus den Optionen, die auf sie oder ihre
/// Gegenstände zielen. Hauptwörter sind groß geschriebene Wörter ab vier
/// Buchstaben mitten im Satz.
Map<String, Map<String, String>> _bezug(Kanon kanon) {
  final traeger = {
    for (final g in kanon.gegenstaende)
      if ((g['lage'] as Map?)?['traeger'] case final String t) g['id'] as String: t,
  };
  final texte = <String, List<String>>{};
  for (final f in kanon.figuren) {
    final vs = f['visualSpecs'] as Map?;
    texte[f['id'] as String] = [
      for (final k in _bezugsfelder) ..._strings(f[k]),
      ..._strings(vs?['distinguishingFeature']),
    ];
  }
  for (final g in kanon.gegenstaende) {
    if (traeger[g['id']] case final t?) texte[t]?.addAll(_strings(g));
  }
  for (final b in kanon.beobachtungen) {
    if (b['wer'] case final String w) texte[w]?.addAll([..._strings(b['text']), ..._strings(b['duText']), ..._strings(b['grundVerborgen'])]);
  }
  for (final e in kanon.entscheidungenJson['entscheidungen'] as List) {
    for (final o in (e as Map)['optionen'] as List) {
      final ziel = ((o as Map)['ziel'] as Map?) ?? const {};
      if ((ziel['person'] as String?) ?? traeger[ziel['gegenstand']] case final p?) texte[p]?.add(o['text'] as String);
    }
  }
  return {
    for (final MapEntry(key: figur, value: t) in texte.entries)
      figur: {
        for (final text in t)
          for (final m in _hauptwortRe.allMatches(text))
            for (final form in wortformen(m.group(1)!)) form: m.group(1)!,
      },
  };
}

/// Felder einer Figur in `figuren.json`, die sie verbirgt oder die sie verraten.
const _bezugsfelder = [
  'roleSecret', 'motiveAndConflict', 'persoenlichesZiel', 'blackoutAlibi', 'beweisFarbe', 'nebendelikt', 'luegen', 'innocentProfile',
  'killerProfile', 'loyalitaet',
];

/// Ein groß geschriebenes Wort ab vier Buchstaben, das nicht am Satzanfang
/// steht (nicht nach Punkt, Ausrufe- oder Fragezeichen, Doppelpunkt oder
/// Anführungszeichen).
final _hauptwortRe = RegExp(r'(?<![.!?:„“"]\s*|^\s*|\p{L})(\p{Lu}\p{L}{3,})', unicode: true);

/// Alle Zeichenketten in [wert] (auch in Listen und Maps).
Iterable<String> _strings(Object? wert) sync* {
  switch (wert) {
    case final String s:
      yield s;
    case final List l:
      for (final x in l) {
        yield* _strings(x);
      }
    case final Map m:
      for (final x in m.values) {
        yield* _strings(x);
      }
  }
}

/// Texte aus dem Kanon, aus denen nichts in ein Gerücht wandern darf:
/// verborgene oder pfadabhängige Beobachtungen, Rollengeheimnisse, Wahrheiten
/// hinter Lügen, Bonus-Hinweise und Spuren an Gegenständen.
List<String> _geschuetzteTexte(Kanon kanon) => [
      for (final b in kanon.beobachtungen)
        if (b['kanal'] != 'pflichtgespraech' || b['pfade'] != 'alle') b['text'] as String,
      for (final f in kanon.figuren) ...[
        if (f['roleSecret'] case final String s) s,
        for (final l in (f['luegen'] as List? ?? const [])) ...[
          if ((l as Map)['wahrheit'] case final String w) w,
          if (l['duWahrheit'] case final String w) w,
        ],
      ],
      for (final h in (kanon.bonusJson['hinweise'] as List? ?? const []))
        if ((h as Map)['text'] case final String t) t,
      for (final g in kanon.gegenstaende)
        for (final s in (g['spuren'] as List? ?? const [])) ...[
          if ((s as Map)['zeigt'] case final String t) t,
          if (s['harmlos'] case final String t) t,
        ],
    ];

final _wortRe = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// Alle Folgen aus fünf Wörtern (klein geschrieben) eines Textes.
Set<String> _fuenfer(String t) {
  final w = [for (final m in _wortRe.allMatches(t)) m.group(0)!.toLowerCase()];
  return {for (var i = 0; i + 5 <= w.length; i++) w.sublist(i, i + 5).join(' ')};
}
