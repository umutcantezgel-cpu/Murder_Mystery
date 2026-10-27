// Erzählerakte (Finale Schlosskeller, A-063, SPEZIFIKATION §2): Hintergründe,
// Stimme und Beziehungsnetz nur für die Person, die erzählt. Die Datei
// `erzaehlerakte.json` liegt neben dem Kanon (wie `steckbriefe.json`); kein
// Spielzustand liest sie. Pfadgleich: Die Akte kennt weder Pfad noch Fall-Code.
// Was im Kanon steht, wird beim Laden gezogen, nie kopiert. Reines Dart ohne dart:io.
import 'kanon/kanon.dart';
import 'pfadwissen.dart';
import 'steckbriefe.dart' show fuenfWortFolgen;
import 'texte.dart';
import 'textpruefer.dart';

/// Format der Datei (`format`).
const erzaehlerakteFormat = 'erzaehlerakte/1';

/// Arten einer Kante im Beziehungsnetz.
const netzArten = {'familie', 'freundschaft', 'schule', 'studium', 'arbeit', 'nachbarschaft', 'verein', 'gefallen', 'schuld', 'streit'};

/// Sichtbarkeit einer Kante: am Tisch bekannt oder nur dem Erzähler.
const netzOeffentlich = 'oeffentlich', netzHeimlich = 'heimlich';

/// Größen (SPEZIFIKATION §2): Wörter je Hintergrund (Figuren und Herr Schneider, Detektiv),
/// Verhältnis zu Herrn Schneider, Stimme (Punkte und Wörter je Punkt), Kantentext, Sätze der Einleitung.
const erzaehlerHintergrundMin = 80,
    erzaehlerHintergrundMax = 140,
    erzaehlerDetektivMin = 40,
    erzaehlerDetektivMax = 80,
    erzaehlerZuSchneiderWorte = 40,
    erzaehlerStimmeMin = 2,
    erzaehlerStimmeMax = 3,
    erzaehlerStimmeWorte = 8,
    erzaehlerKanteWorte = 12,
    erzaehlerEinleitungSaetzeMin = 2,
    erzaehlerEinleitungSaetzeMax = 4;

/// Netz: mindestens so viele Kanten je Figur; insgesamt etwa 45 Kanten.
const erzaehlerKantenJeFigur = 2, erzaehlerNetzMin = 35, erzaehlerNetzMax = 60;

/// Eine Kante im Beziehungsnetz zwischen zwei Knoten (Figuren-Kennungen oder
/// das Opfer, `schneider`).
class NetzKante {
  const NetzKante({required this.a, required this.b, required this.art, required this.sichtbar, required this.text});

  factory NetzKante.ausJson(Map j) => NetzKante(
        a: j['a'] as String? ?? '',
        b: j['b'] as String? ?? '',
        art: j['art'] as String? ?? '',
        sichtbar: j['sichtbar'] as String? ?? '',
        text: j['text'] as String? ?? '',
      );

  final String a, b, art, sichtbar, text;

  /// Am Tisch bekannt ([netzOeffentlich]); sonst weiß es nur der Erzähler.
  bool get oeffentlich => sichtbar == netzOeffentlich;

  bool beruehrt(String x) => a == x || b == x;
  bool verbindet(String x, String y) => (a == x && b == y) || (a == y && b == x);

  /// Der andere Knoten, von [x] aus gesehen.
  String anderer(String x) => a == x ? b : a;

  Map<String, Object?> toJson() => {'a': a, 'b': b, 'art': art, 'sichtbar': sichtbar, 'text': text};
}

/// Ein Ziel einer Figur, wie es der Erzähler sieht.
class ErzaehlerZiel {
  const ErzaehlerZiel({required this.id, required this.text});
  final String id, text;
  Map<String, Object?> toJson() => {'id': id, 'text': text};
}

/// Woher die Akte die Ziele einer Figur nimmt. Standard ist der Kanon
/// ([KanonZiele]); die Einfluss-Schicht liefert ihre Sterne. Nie mit Pfad.
abstract interface class ZielQuelle {
  List<ErzaehlerZiel> zieleVon(String figur);
}

/// Ziele aus dem Kanon: das persönliche Ziel der Figur (`persoenlichesZiel`).
class KanonZiele implements ZielQuelle {
  const KanonZiele(this.kanon);
  final Kanon kanon;

  @override
  List<ErzaehlerZiel> zieleVon(String figur) => switch (kanon.figur(figur)?['persoenlichesZiel']) {
        final String t when t.trim().isNotEmpty => [ErzaehlerZiel(id: 'persoenlichesZiel', text: t)],
        _ => const [],
      };
}

/// Blatt für Herrn Schneider oder den Detektiv: Hintergrund und Stimme aus der
/// Datei, Name, Alter und Rolle aus dem Kanon.
class ErzaehlerakteBlatt {
  const ErzaehlerakteBlatt({required this.person, this.name, this.alter, this.rolle, required this.hintergrund, required this.stimme});
  final String person;
  final String? name, rolle;
  final int? alter;
  final String hintergrund;
  final List<String> stimme;

  Map<String, Object?> toJson() => {
        'person': person,
        'name': ?name,
        'alter': ?alter,
        'rolle': ?rolle,
        'hintergrund': hintergrund,
        'stimme': [...stimme],
      };
}

/// Eine Figur der Erzählerakte: [hintergrund], [zuSchneider] und [stimme] aus
/// der Datei, alles andere aus dem Kanon gezogen (Name, Alter, Rolle, Alltag,
/// Motiv, Geheimnis, Nebendelikt, Loyalität) und die Ziele über die [ZielQuelle].
class ErzaehlerakteFigur {
  const ErzaehlerakteFigur({
    required this.figur,
    required this.name,
    this.vollerName,
    this.alter,
    required this.platz,
    required this.rolle,
    required this.alltag,
    required this.hintergrund,
    required this.zuSchneider,
    required this.stimme,
    this.motiv,
    this.geheimnis,
    this.nebendelikt,
    this.loyalitaet,
    required this.ziele,
  });

  final String figur, name, rolle, alltag, hintergrund, zuSchneider;
  final String? vollerName, motiv, geheimnis, nebendelikt;
  final int? alter;

  /// Besetzungsplatz (1 = immer besetzt zuerst).
  final int platz;
  final List<String> stimme;
  final ({String zu, String grund})? loyalitaet;
  final List<ErzaehlerZiel> ziele;

  /// Schlüssel ohne `ziel`, `weiss` und `verbirgt` (die Felder eines Dossiers).
  Map<String, Object?> toJson() => {
        'figur': figur,
        'name': name,
        'vollerName': ?vollerName,
        'alter': ?alter,
        'platz': platz,
        'rolle': rolle,
        'alltag': alltag,
        'hintergrund': hintergrund,
        'zuSchneider': zuSchneider,
        'stimme': [...stimme],
        'motiv': ?motiv,
        'geheimnis': ?geheimnis,
        'nebendelikt': ?nebendelikt,
        if (loyalitaet case final l?) 'loyalitaet': {'zu': l.zu, 'grund': l.grund},
        'ziele': [for (final z in ziele) z.toJson()],
      };
}

String _text(Object? v) => v is String ? v : '';
List<String> _texte(Object? v) => [for (final x in (v as List? ?? const [])) if (x is String) x];

/// Die Erzählerakte einer Akte, zusammengesetzt aus Datei und Kanon. Keine
/// Pfad- und keine Code-Parameter: Sie ist in allen Pfaden gleich.
class Erzaehlerakte {
  Erzaehlerakte._({
    required this.format,
    required this.settingId,
    required this.hinweis,
    required this.einleitung,
    required this.schneider,
    required this.detektiv,
    required this.figuren,
    required this.netz,
    required this.unbekannt,
    required this.doppelt,
  });

  /// Liest die Datei [j] und zieht die Kanonfelder aus [kanon]. Nie gelesen:
  /// Profile, Lügen, Alibi, Tatmatrix, Täterfassungen, Finale, Auflösung,
  /// Bonus und Begründungen. [ziele] ersetzt die Ziele aus dem Kanon.
  factory Erzaehlerakte.ausJson(Map<String, Object?> j, Kanon kanon, {ZielQuelle? ziele}) {
    final quelle = ziele ?? KanonZiele(kanon);
    final opfer = (kanon.figurenJson['opfer'] as Map).cast<String, Object?>();
    final det = (kanon.figurenJson['detektiv'] as Map).cast<String, Object?>();
    final s = (j['schneider'] as Map?) ?? const {};
    final d = (j['detektiv'] as Map?) ?? const {};
    final eintraege = <String, Map>{};
    final unbekannt = <String>[], doppelt = <String>[];
    final ids = {for (final f in kanon.figuren) f['id'] as String};
    for (final e in (j['figuren'] as List? ?? const [])) {
      final m = e as Map;
      final id = _text(m['figur']);
      if (!ids.contains(id)) {
        unbekannt.add(id);
      } else if (eintraege.containsKey(id)) {
        doppelt.add(id);
      } else {
        eintraege[id] = m;
      }
    }
    return Erzaehlerakte._(
      format: _text(j['format']),
      settingId: _text(j['settingId']),
      hinweis: _text(j['hinweis']),
      einleitung: _text(j['einleitung']),
      schneider: ErzaehlerakteBlatt(
        person: opfer['id'] as String,
        name: opfer['name'] as String?,
        alter: opfer['age'] as int?,
        rolle: opfer['roleTitle'] as String?,
        hintergrund: _text(s['hintergrund']),
        stimme: _texte(s['stimme']),
      ),
      detektiv: ErzaehlerakteBlatt(
        person: det['id'] as String,
        rolle: det['title'] as String?,
        hintergrund: _text(d['hintergrund']),
        stimme: _texte(d['stimme']),
      ),
      figuren: [
        for (final f in kanon.figuren)
          if (eintraege[f['id']] case final e?) _figur(f, e, quelle),
      ],
      netz: [for (final k in (j['netz'] as List? ?? const [])) NetzKante.ausJson(k as Map)],
      unbekannt: unbekannt,
      doppelt: doppelt,
    );
  }

  static ErzaehlerakteFigur _figur(Map<String, Object?> f, Map e, ZielQuelle ziele) {
    final id = f['id'] as String;
    final l = f['loyalitaet'] as Map?;
    return ErzaehlerakteFigur(
      figur: id,
      name: f['name'] as String,
      vollerName: f['vollerName'] as String?,
      alter: f['age'] as int?,
      platz: f['besetzungsplatz'] as int? ?? 0,
      rolle: _text(f['roleTitle']),
      alltag: _text(f['alltag']),
      hintergrund: _text(e['hintergrund']),
      zuSchneider: _text(e['zuSchneider']),
      stimme: _texte(e['stimme']),
      motiv: f['motiveAndConflict'] as String?,
      geheimnis: f['roleSecret'] as String?,
      nebendelikt: (f['nebendelikt'] as Map?)?['text'] as String?,
      loyalitaet: l == null ? null : (zu: _text(l['zu']), grund: _text(l['grund'])),
      ziele: ziele.zieleVon(id),
    );
  }

  final String format, settingId, hinweis, einleitung;
  final ErzaehlerakteBlatt schneider, detektiv;

  /// Figuren der Datei in Kanon-Reihenfolge (Besetzungsplätze).
  final List<ErzaehlerakteFigur> figuren;
  final List<NetzKante> netz;

  /// Einträge, deren Figur der Kanon nicht kennt, und doppelte (der erste gilt).
  final List<String> unbekannt, doppelt;

  ErzaehlerakteFigur? figur(String id) {
    for (final f in figuren) {
      if (f.figur == id) return f;
    }
    return null;
  }

  /// Kanten, die [knoten] berühren, in der Reihenfolge der Datei.
  List<NetzKante> kantenVon(String knoten) => [for (final k in netz) if (k.beruehrt(knoten)) k];

  /// Die zusammengesetzte Akte (Datei und Kanon), wie Ansicht und Druck sie
  /// zeigen. Ohne die Dossier-Schlüssel `ziel`, `weiss` und `verbirgt`.
  Map<String, Object?> toJson() => {
        'format': format,
        'settingId': settingId,
        'hinweis': hinweis,
        'einleitung': einleitung,
        'schneider': schneider.toJson(),
        'detektiv': detektiv.toJson(),
        'figuren': [for (final f in figuren) f.toJson()],
        'netz': [for (final k in netz) k.toJson()],
      };
}

final _wortRe = RegExp(r'[\p{L}\p{N}]+(?:-[\p{L}\p{N}]+)*', unicode: true);

int _worte(String s) => _wortRe.allMatches(s).length;

/// Sätze eines Textes: Ende ist `.`, `!`, `?` oder `…` vor Leerraum oder Textende;
/// ein Text ohne Satzzeichen ist ein Satz.
int _saetze(String s) {
  final t = s.trim();
  if (t.isEmpty) return 0;
  final n = RegExp(r'[.!?…]+["“”»]*(?=\s|$)').allMatches(t).length;
  return n == 0 ? 1 : n;
}

/// Wortanfänge, die außerhalb von Hinweis und Einleitung nie in der Akte stehen.
final _verbotenRe = RegExp(r'(?<!\p{L})(täter|pfad|fall-?code|tarnung|tatwissen|sabotage|qualität)\p{L}*', unicode: true, caseSensitive: false);

/// Muster für den Namen einer Figur, auch im Genitiv („Ahmets“).
RegExp namensMuster(String name) => RegExp('(?<!\\p{L})${RegExp.escape(name)}(?:s|’s|\'s)?(?!\\p{L})', unicode: true);

/// Alle Zeichenketten unter [o] mit ihrem Ort (`figuren[3].hintergrund`).
Iterable<(String, String)> _strings(Object? o, String wo) sync* {
  if (o is String) yield (wo, o);
  if (o is Map) {
    for (final e in o.entries) {
      yield* _strings(e.value, wo.isEmpty ? '${e.key}' : '$wo.${e.key}');
    }
  }
  if (o is List) {
    for (final (i, v) in o.indexed) {
      yield* _strings(v, '$wo[$i]');
    }
  }
}

/// Texte der Täterfassungen, des Finales und der Auflösung (Ort → Text).
Map<String, String> _tatTexte(Textsammlung t) => {
      for (final d in t.dateien.entries)
        if (RegExp(r'texte/(taeter-|erzaehler-finale|erzaehler-aufloesung)').hasMatch(d.key))
          for (final (wo, s) in _strings(d.value, d.key)) wo: s,
    };

/// Prüft die Erzählerakte gegen Kanon und Texte ([texte]). Leer heißt grün.
/// - Format und settingId; Vollständigkeit: je Figur des Kanons genau ein
///   Eintrag, keine unbekannte Figur; Herr Schneider und der Detektiv.
/// - Größen: Einleitung [erzaehlerEinleitungSaetzeMin] bis
///   [erzaehlerEinleitungSaetzeMax] Sätze; Hintergrund der Figuren und Herrn
///   Schneiders [erzaehlerHintergrundMin]–[erzaehlerHintergrundMax] Wörter,
///   des Detektivs [erzaehlerDetektivMin]–[erzaehlerDetektivMax]; zu Herrn
///   Schneider höchstens [erzaehlerZuSchneiderWorte]; Stimme
///   [erzaehlerStimmeMin]–[erzaehlerStimmeMax] Punkte zu höchstens
///   [erzaehlerStimmeWorte] Wörtern; Kantentext höchstens [erzaehlerKanteWorte].
/// - Netz: Art aus [netzArten], Sichtbarkeit öffentlich oder heimlich, Knoten
///   sind Figuren oder das Opfer, keine Schleife, kein Paar doppelt; je Figur
///   mindestens [erzaehlerKantenJeFigur] Kanten; jede Loyalität ist eine
///   Kante; jedes Paar, das ein Dossier unter „Wer du bist“ nennt, ist eine
///   öffentliche Kante; insgesamt [erzaehlerNetzMin] bis [erzaehlerNetzMax].
/// - Pfadfrei auf dem zusammengesetzten [Erzaehlerakte.toJson]: keine
///   Fünf-Wort-Folge aus Pfadwissen ([pfadwissenVerboten]) oder aus
///   Täterfassungen, Finale und Auflösung. Ausgenommen sind Folgen der
///   gezogenen Kanonfelder: Die sind in jedem Pfad dieselben.
/// - Außerhalb von Hinweis und Einleitung keine Wörter wie Täter, Pfad,
///   Fall-Code, Tarnung, Tatwissen, Sabotage, Qualität; kein Geburtstag (A-061).
/// - [ton]: Tonregeln wie alle Lesetexte (Ziffern erlaubt, kein Vorlesetext).
List<String> pruefeErzaehlerakte(Erzaehlerakte akte, Texte texte, {Textpruefer? ton}) {
  final f = <String>[];
  final kanon = texte.kanon;
  if (akte.format != erzaehlerakteFormat) f.add('Format ${akte.format} statt $erzaehlerakteFormat');
  if (akte.settingId != kanon.settingId) f.add('settingId ${akte.settingId} statt ${kanon.settingId}');

  // Vollständigkeit
  for (final id in akte.unbekannt) {
    f.add('Figur $id: unbekannt');
  }
  for (final id in akte.doppelt) {
    f.add('Figur $id: doppelt');
  }
  for (final x in kanon.figuren) {
    if (akte.figur(x['id'] as String) == null) f.add('Figur ${x['id']} fehlt');
  }

  // Größen
  void worte(String wo, String text, {int min = 1, required int max}) {
    final n = _worte(text);
    if (n < min || n > max) f.add('$wo: $n Wörter statt ${min <= 1 ? 'höchstens $max' : '$min bis $max'}');
  }

  void stimme(String wo, List<String> l) {
    if (l.length < erzaehlerStimmeMin || l.length > erzaehlerStimmeMax) {
      f.add('$wo.stimme: ${l.length} Punkte statt $erzaehlerStimmeMin bis $erzaehlerStimmeMax');
    }
    for (final (i, p) in l.indexed) {
      worte('$wo.stimme[$i]', p, max: erzaehlerStimmeWorte);
    }
  }

  final saetze = _saetze(akte.einleitung);
  if (saetze < erzaehlerEinleitungSaetzeMin || saetze > erzaehlerEinleitungSaetzeMax) {
    f.add('einleitung: $saetze Sätze statt $erzaehlerEinleitungSaetzeMin bis $erzaehlerEinleitungSaetzeMax');
  }
  worte('schneider.hintergrund', akte.schneider.hintergrund, min: erzaehlerHintergrundMin, max: erzaehlerHintergrundMax);
  stimme('schneider', akte.schneider.stimme);
  worte('detektiv.hintergrund', akte.detektiv.hintergrund, min: erzaehlerDetektivMin, max: erzaehlerDetektivMax);
  stimme('detektiv', akte.detektiv.stimme);
  for (final x in akte.figuren) {
    final wo = 'Figur ${x.figur}';
    worte('$wo.hintergrund', x.hintergrund, min: erzaehlerHintergrundMin, max: erzaehlerHintergrundMax);
    worte('$wo.zuSchneider', x.zuSchneider, max: erzaehlerZuSchneiderWorte);
    stimme(wo, x.stimme);
  }

  // Netz
  final opfer = (kanon.figurenJson['opfer'] as Map)['id'] as String;
  final figuren = [for (final x in kanon.figuren) x['id'] as String];
  final knoten = {...figuren, opfer};
  final paare = <String>{};
  for (final (i, k) in akte.netz.indexed) {
    final wo = 'Kante ${k.a}–${k.b}';
    if (!netzArten.contains(k.art)) f.add('$wo: Art ${k.art} unbekannt');
    if (k.sichtbar != netzOeffentlich && k.sichtbar != netzHeimlich) f.add('$wo: Sichtbarkeit ${k.sichtbar} unbekannt');
    for (final x in [k.a, k.b]) {
      if (!knoten.contains(x)) f.add('$wo: Knoten $x unbekannt');
    }
    if (k.a == k.b) f.add('$wo: verbindet eine Figur mit sich selbst');
    if (!paare.add(([k.a, k.b]..sort()).join('|'))) f.add('$wo: Paar doppelt (Kante ${i + 1})');
    worte('$wo.text', k.text, max: erzaehlerKanteWorte);
  }
  if (akte.netz.length < erzaehlerNetzMin || akte.netz.length > erzaehlerNetzMax) {
    f.add('Netz: ${akte.netz.length} Kanten statt etwa 45 ($erzaehlerNetzMin bis $erzaehlerNetzMax)');
  }
  for (final id in figuren) {
    final n = akte.kantenVon(id).length;
    if (n < erzaehlerKantenJeFigur) f.add('Netz: $id hat $n Kanten statt mindestens $erzaehlerKantenJeFigur');
  }
  for (final x in kanon.figuren) {
    final zu = (x['loyalitaet'] as Map?)?['zu'];
    if (zu is String && !akte.netz.any((k) => k.verbindet(x['id'] as String, zu))) {
      f.add('Netz: Loyalität ${x['id']}–$zu ist keine Kante');
    }
  }
  final namen = {for (final x in kanon.figuren) x['id'] as String: [x['name'] as String, if (x['vollerName'] is String) x['vollerName'] as String]};
  for (final d in texte.sammlung.dossiers.values) {
    for (final g in figuren) {
      if (g == d.rolle || !namen[g]!.any((n) => namensMuster(n).hasMatch(d.wer))) continue;
      if (!akte.netz.any((k) => k.verbindet(d.rolle, g) && k.oeffentlich)) {
        f.add('Netz: Dossier ${d.rolle} nennt ${namen[g]!.first}, das Paar ${d.rolle}–$g ist keine öffentliche Kante');
      }
    }
  }

  // Pfadfrei auf dem zusammengesetzten Dokument.
  final json = akte.toJson();
  final gezogen = <String>{
    for (final x in akte.figuren)
      for (final t in [x.name, ?x.vollerName, x.rolle, x.alltag, ?x.motiv, ?x.geheimnis, ?x.nebendelikt, ?x.loyalitaet?.grund, for (final z in x.ziele) z.text])
        ...fuenfWortFolgen(t),
  };
  final geschuetzt = <String, String>{
    ...pfadwissenVerboten(kanon),
    for (final e in _tatTexte(texte.sammlung).entries)
      for (final folge in fuenfWortFolgen(e.value)) folge: e.key,
  }..removeWhere((folge, _) => gezogen.contains(folge));
  for (final (wo, s) in _strings(json, '')) {
    for (final folge in fuenfWortFolgen(s)) {
      final q = geschuetzt[folge];
      if (q != null) f.add('$wo: „$folge“ stammt aus $q');
    }
    if (wo != 'hinweis' && wo != 'einleitung') {
      for (final m in _verbotenRe.allMatches(s)) {
        f.add('$wo: „${m.group(0)}“ gehört nicht in die Erzählerakte');
      }
    }
    if (s.toLowerCase().contains('geburtstag')) f.add('$wo: Geburtstag (A-061)');
  }

  // Ton der eigenen Texte (Lesetext).
  if (ton != null) {
    final eigene = <(String, String)>[
      ('einleitung', akte.einleitung),
      for (final b in [akte.schneider, akte.detektiv]) ...[
        ('${b.person}.hintergrund', b.hintergrund),
        for (final (i, p) in b.stimme.indexed) ('${b.person}.stimme[$i]', p),
      ],
      for (final x in akte.figuren) ...[
        ('Figur ${x.figur}.hintergrund', x.hintergrund),
        ('Figur ${x.figur}.zuSchneider', x.zuSchneider),
        for (final (i, p) in x.stimme.indexed) ('Figur ${x.figur}.stimme[$i]', p),
      ],
      for (final k in akte.netz) ('Kante ${k.a}–${k.b}.text', k.text),
    ];
    for (final (wo, text) in eigene) {
      for (final b in ton.pruefe(TextQuelle(ort: wo, text: text, vorlesen: false))) {
        f.add('${b.ort}: ${b.regel}: ${b.auszug}');
      }
    }
  }
  return f;
}
