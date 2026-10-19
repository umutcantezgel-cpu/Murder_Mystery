import 'besetzung.dart';
import 'kanon/kanon.dart';
import 'texte.dart';
import 'textpruefer.dart';

/// Steckbrief-Zusatz einer Figur (K3, A-059): was es braucht, um eine Figur
/// Wochen vor dem Abend zu wählen und zu üben. Kostümtipp, Auftritt in
/// Stichpunkten und ein typischer Satz; alles ohne Bezug zum Fall.
class SteckbriefEintrag {
  final String figur, kostuem, satz;
  final List<String> auftritt;
  SteckbriefEintrag(Map j)
      : figur = j['figur'] as String,
        kostuem = j['kostuem'] as String,
        satz = j['satz'] as String,
        auftritt = [for (final x in (j['auftritt'] as List? ?? const [])) x as String];
}

/// Die Steckbriefe einer Akte (`steckbriefe.json`), je Figur ein Eintrag, dazu
/// der Detektiv (`Besetzung.detektiv`). Die Datei gehört nicht zum Kanon der
/// Partie: Kein Spielzustand liest sie, nur Steckbrief und Charakterübersicht.
class Steckbriefe {
  final Map<String, Object?> json;
  final Map<String, SteckbriefEintrag> je;

  /// Einträge, deren Figur schon einmal vorkam (der erste gilt).
  final List<String> doppelt;

  Steckbriefe._(this.json, this.je, this.doppelt);

  factory Steckbriefe.ausJson(Map<String, Object?> j) {
    final je = <String, SteckbriefEintrag>{};
    final doppelt = <String>[];
    for (final e in (j['eintraege'] as List? ?? const [])) {
      final s = SteckbriefEintrag(e as Map);
      if (je.containsKey(s.figur)) {
        doppelt.add(s.figur);
      } else {
        je[s.figur] = s;
      }
    }
    return Steckbriefe._(j, je, doppelt);
  }

  /// Eintrag zu [figur]; fehlt er, ist die Datei unvollständig (siehe [pruefeSteckbriefe]).
  SteckbriefEintrag von(String figur) => je[figur] ?? (throw StateError('kein Steckbrief für $figur'));
}

/// Höchstens so viele Wörter hat ein Stichpunkt oder der Kostümtipp (R17).
const steckbriefWorte = 8;

/// Höchstens so viele Wörter hat der typische Satz einer Figur.
const steckbriefSatzWorte = 10;

final _ziffer = RegExp(r'\p{N}', unicode: true);

/// Prüft die Steckbriefe gegen den Kanon (K3). Leer heißt grün.
/// - Jede Figur und der Detektiv haben genau einen Eintrag, unbekannte Figuren gibt es nicht.
/// - Kartenformat R17: zwei bis drei Auftritts-Stichpunkte, jeder wie der Kostümtipp
///   höchstens [steckbriefWorte] Wörter; der Satz höchstens [steckbriefSatzWorte].
/// - Ohne Fallbezug: keine Ziffern (Uhrzeiten), kein Geburtstag (A-061), kein Name
///   einer Figur, keine Fünf-Wort-Folge aus den geheimen Feldern ([geheimeFelder])
///   oder aus [geschuetzt] (Ort → Text, meist [steckbriefGeschuetzt]).
/// - [ton]: dieselben Tonregeln wie alle Spielertexte (Sätze, Verbote, Fachwörter).
List<String> pruefeSteckbriefe(Steckbriefe s, Kanon kanon, {Textpruefer? ton, Map<String, String> geschuetzt = const {}}) {
  final f = <String>[for (final d in s.doppelt) 'Steckbrief $d: doppelt'];
  final figuren = [for (final x in kanon.figuren) x['id'] as String];
  final soll = {...figuren, Besetzung.detektiv};
  for (final id in soll) {
    if (!s.je.containsKey(id)) f.add('Steckbrief $id fehlt');
  }
  for (final id in s.je.keys) {
    if (!soll.contains(id)) f.add('Steckbrief $id: unbekannte Figur');
  }
  final namen = <String>{
    for (final x in kanon.figuren) x['name'] as String,
    for (final x in kanon.figuren)
      if (x['vollerName'] is String) x['vollerName'] as String,
    ((kanon.figurenJson['opfer'] as Map)['name'] as String).split(' ').last,
  };
  final geheim = {..._folgen(geschuetzt), ..._folgen(geheimeFelder(kanon))};
  for (final e in s.je.values) {
    final wo = 'Steckbrief ${e.figur}';
    if (e.auftritt.length < 2 || e.auftritt.length > 3) f.add('$wo: ${e.auftritt.length} Auftritts-Stichpunkte statt 2 bis 3 (R17)');
    final texte = <(String, String, int)>[
      ('kostuem', e.kostuem, steckbriefWorte),
      for (var i = 0; i < e.auftritt.length; i++) ('auftritt[$i]', e.auftritt[i], steckbriefWorte),
      ('satz', e.satz, steckbriefSatzWorte),
    ];
    for (final (feld, text, hoechstens) in texte) {
      if (text.trim().isEmpty) f.add('$wo.$feld: leer');
      final n = stichpunktWoerter(text);
      if (n > hoechstens) f.add('$wo.$feld: $n Wörter statt höchstens $hoechstens (R17): $text');
      if (_ziffer.hasMatch(text)) f.add('$wo.$feld: Ziffern verraten Zeiten oder Mengen: $text');
      if (text.toLowerCase().contains('geburtstag')) f.add('$wo.$feld: Geburtstag (A-061): $text');
      for (final name in namen) {
        if (RegExp('(?<!\\p{L})${RegExp.escape(name)}(?!\\p{L})', unicode: true).hasMatch(text)) f.add('$wo.$feld: nennt $name');
      }
      for (final folge in fuenfWortFolgen(text)) {
        final quelle = geheim[folge];
        if (quelle != null) f.add('$wo.$feld: „$folge“ stammt aus $quelle');
      }
      if (ton != null) {
        for (final b in ton.pruefe(TextQuelle(ort: '$wo.$feld', text: text, vorlesen: false))) {
          f.add('${b.ort}: ${b.regel}: ${b.auszug}');
        }
      }
    }
  }
  return f;
}

final _wort = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// Alle Folgen aus fünf Wörtern eines Textes (klein, ohne Satzzeichen).
Set<String> fuenfWortFolgen(String text) {
  final w = [for (final m in _wort.allMatches(text.toLowerCase())) m.group(0)!];
  return {for (var i = 0; i + 5 <= w.length; i++) w.sublist(i, i + 5).join(' ')};
}

/// Texte der Felder, die nie auf einen Steckbrief gehören (A-059): Motiv,
/// Geheimnis, Alibi, Lügen, Ziel, Nebendelikt, Loyalität, Aussehen der Tatnacht
/// und die beiden Profile, je Figur mit Feldname.
Map<String, String> geheimeFelder(Kanon kanon) {
  final q = <String, String>{};
  void add(String wo, Object? t) {
    if (t is String && t.trim().isNotEmpty) q[wo] = t;
  }

  for (final x in kanon.figuren) {
    final id = x['id'] as String;
    for (final feld in const ['motiveAndConflict', 'roleSecret', 'blackoutAlibi', 'persoenlichesZiel']) {
      add('$id.$feld', x[feld]);
    }
    add('$id.nebendelikt', (x['nebendelikt'] as Map?)?['text']);
    add('$id.loyalitaet', (x['loyalitaet'] as Map?)?['grund']);
    for (final e in ((x['visualSpecs'] as Map?) ?? const {}).entries) {
      add('$id.visualSpecs.${e.key}', e.value);
    }
    for (final profil in const ['innocentProfile', 'killerProfile']) {
      for (final e in ((x[profil] as Map?) ?? const {}).entries) {
        add('$id.$profil.${e.key}', e.value);
      }
    }
    final luegen = x['luegen'] as List? ?? const [];
    for (var i = 0; i < luegen.length; i++) {
      final l = luegen[i] as Map;
      for (final k in const ['behauptung', 'wahrheit', 'duWahrheit']) {
        add('$id.luegen[$i].$k', l[k]);
      }
    }
  }
  return q;
}

/// Texte der Akte, die wie die geheimen Felder ([geheimeFelder]) nie auf einen
/// Steckbrief gehören (A-059), je mit Ort: was jede Rolle weiß, verbirgt und
/// will (Dossier), die Täterfassungen, Finale und Auflösung. Verweise gelten in
/// jedem Pfad, in dem es sie gibt.
Map<String, String> steckbriefGeschuetzt(Texte texte) {
  final q = <String, String>{};
  void add(String wo, String? t) {
    if (t != null && t.trim().isNotEmpty) q[wo] = t;
  }

  void punkte(String wo, List<TextPunkt> l) {
    for (final (i, p) in l.indexed) {
      final ref = p.ref;
      if (ref == null) {
        add('$wo[$i]', p.text);
      } else if (texte.bekannt(ref)) {
        for (final pfad in texte.kanon.pfade) {
          final z = texte.aufloesen(ref, pfad);
          add('$wo[$i] $ref ($pfad)', z?.text);
          add('$wo[$i] $ref (Behauptung)', z?.behauptung);
        }
      }
    }
  }

  for (final d in texte.sammlung.dossiers.values) {
    add('Dossier ${d.rolle}.ziel', d.ziel);
    punkte('Dossier ${d.rolle}.weiss', d.weiss);
    punkte('Dossier ${d.rolle}.verbirgt', d.verbirgt);
  }
  for (final t in texte.sammlung.taeter.values) {
    add('Täterfassung ${t.rolle}.tarnung', t.tarnung);
    add('Täterfassung ${t.rolle}.ziel', t.ziel);
    punkte('Täterfassung ${t.rolle}.tatwissen', t.tatwissen);
    punkte('Täterfassung ${t.rolle}.verbirgt', t.verbirgt);
  }
  // Täterfassungen, Finale und Auflösung: jeder Text der Dateien, auch was oben schon steht.
  for (final d in texte.sammlung.dateien.entries) {
    if (!RegExp(r'texte/(taeter-|erzaehler-finale|erzaehler-aufloesung)').hasMatch(d.key)) continue;
    for (final (i, t) in _strings(d.value).indexed) {
      add('${d.key} #$i', t);
    }
  }
  return q;
}

Iterable<String> _strings(Object? o) sync* {
  if (o is String) yield o;
  if (o is Map) {
    for (final v in o.values) {
      yield* _strings(v);
    }
  }
  if (o is List) {
    for (final v in o) {
      yield* _strings(v);
    }
  }
}

/// Fünf-Wort-Folge → Ort, aus dem sie stammt (der erste gilt).
Map<String, String> _folgen(Map<String, String> texte) {
  final q = <String, String>{};
  for (final e in texte.entries) {
    for (final folge in fuenfWortFolgen(e.value)) {
      q.putIfAbsent(folge, () => e.key);
    }
  }
  return q;
}
