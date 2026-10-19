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
/// rund um den Vorfall und Beinamen von Gegenständen, die kein Name trägt
/// (Gespenst für die Leuchtmaske).
const _vorfallWoerter = ['scheppern', 'geschepper', 'knall', 'sicherung', 'strom', 'miete', 'geld', 'kassier', 'gespenst'];

/// Prüft die [geruechte] gegen den [kanon]. Liefert Befunde als Sätze; leer
/// heißt in Ordnung.
///
/// - Jede Figur des Kanons hat in jeder Runde ein bis zwei Zeilen, keine
///   unbekannte Figur, keine Runde außerhalb 1–3.
/// - Jede Zeile ist ein Satz mit höchstens [geruechtWorte] Wörtern (R17).
/// - Keine Zeile nennt ein Sperrwort, einen Gegenstand, einen Namen oder ein
///   Wort aus dem Namen eines Sperrorts: Fundorte der Gegenstände, Ziel-Orte
///   der Entscheidungen und Orte der Lacher (R15). Das gilt auch für kurze
///   Wörter und Teile zusammengesetzter Namen ([teilwoerter]): Brot aus
///   Brottasche, Ring aus Silberring, Helm, Foto, Vitrine aus Schauvitrine.
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
  // Teile der Namen von Gegenständen und Sperrorten, je mit ihrem Namen; sie
  // treffen nur ganze Wörter einer Zeile.
  final teile = <String, String>{};
  for (final (name, ohne) in [
    for (final g in kanon.gegenstaende) (g['name'] as String, const <String>{}),
    for (final o in sperrorte) (o, _allgemeineOrtswoerter),
  ]) {
    for (final t in teilwoerter(name, ohne: ohne)) {
      teile.putIfAbsent(t, () => name);
    }
  }
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
      if (!r15) {
        for (final w in _wortRe.allMatches(z)) {
          if (wortformen(w.group(0)!).map((f) => teile[f]).nonNulls.firstOrNull case final name?) {
            befunde.add('$ort: „${w.group(0)}“ steckt in „$name“ und gehört nicht in ein pfadgleiches Gerücht (R15)');
            break;
          }
        }
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
