// Kammerspiel (ARCHITEKTUR A1/A2, Aufgabe P1): Textprüfer für alle Zeichenketten der
// Inhaltsdateien unter content/kammerspiel/schlosskeller/. Er prüft die Regeln, die für jeden
// Spieltext gelten, unabhängig von Teil und Leser (FALL-BIBEL WELT 0.2, REG §6, TON-LEITFADEN,
// E4, E5, E11). Reines Dart ohne dart:io: Eingabe ist eine Karte Dateipfad → JSON, Ausgabe sind
// Befunde mit Datei, JSON-Pfad, Regel und Ausschnitt und, getrennt, die Felder, die noch mit
// „OFFEN:“ beginnen. Alle Wortlisten, Uhrzeiten, Raumnamen und die Vorgabe-Ausnahmen stehen in
// content/kammerspiel/schlosskeller/textregeln.json; hier steht nur die Logik, kein Spielertext.
//
// Was nur für bestimmte Leser oder Teile gilt (Vorlesetext ohne Ziffern, Spoiler, Gleiche
// Gestalt, Platzhalter je Besetzung), prüft dieser Prüfer nicht. Dafür liefert er die
// Textstellen ([kammerTextStellen]) und die Einzelprüfung ([KammerTextpruefer.pruefeText]).
//
// Sätze zählt er so, wie sie gedruckt werden: Satzlänge und Satzmittel über die aufgelösten
// Fassungen eines Texts (Platzhalter je Besetzung und Detektiv, platzhalter.dart) ohne
// Auszeichnung (`**`, `*`). Die Besetzungen kommen aus fall.json, wenn sie unter den Dateien
// liegt (Plätze in Reihenfolge, Personen min bis max); sonst zählen die beiden Extreme (alle
// genannten Rollen da, keine da). Alle anderen Regeln prüfen den Rohtext mit allen Zweigen.
import 'dart:convert';
import 'dart:math';

import '../../textpruefer.dart' show Textpruefer;
import 'platzhalter.dart' show KammerTextWerte, kammerKlartext, kammerTextRollen, loeseKammerText;

/// Regel-IDs, die die Logik selbst setzt. Die Wortregeln tragen ihre ID in textregeln.json
/// (`wortregeln[].regel`: `schlagverb`, `gewalt`, `alkohol`, `bargeld`, `drogen`, `rauchen`,
/// `fachwort`, `herkunft`, `schatulle`, `anglizismus`, `erzaehler`, `name`, `gestrichene-figur`,
/// `sperrliste`). [KammerTextpruefer.regeln] nennt alle.
abstract final class KammerTextRegel {
  /// Ein Satz hat mehr Wörter als `saetze.hoechstens`.
  static const satzlaenge = 'satzlaenge';

  /// Eine Datei hat im Mittel mehr Wörter je Satz als `saetze.mittelHoechstens`.
  static const satzmittel = 'satzmittel';

  /// Eine Uhrzeit H:MM steht nicht in `uhrzeiten`.
  static const uhrzeit = 'uhrzeit';

  /// Uhrzeit mit führender Null („00:12“) oder mit Punkt („23.58 Uhr“).
  static const uhrzeitForm = 'uhrzeit-form';

  /// Sekundenangabe (H:MM:SS oder „30 Sek.“) außerhalb der Ausnahmen (Teil 90).
  static const sekunden = 'sekunden';

  /// Das erste „…punsch“ eines Textes steht ohne „alkoholfrei“ im selben Satz.
  static const punsch = 'punsch';

  /// Bloß „Schneider“ ohne „Herr“/„Herrn“ davor.
  static const herrSchneider = 'herr-schneider';

  /// Falsche Schreibung eines Raumnamens („Ostsaal“, „Kamin-Saal“, „Westsaal“).
  static const raumname = 'raumname';

  /// Ein Wort mit Raumendung, das kein Raumname des Kammerspiels ist („Saal“, „Gewölbegang“).
  static const raumwort = 'raumwort';

  /// Platzhalter-Rest: TODO, XXX, usw., „…“ als Lücke am Textende, „[…]“, „???“.
  static const platzhalter = 'platzhalter';

  /// Unpaarige geschweifte oder eckige Klammer.
  static const klammer = 'klammer';

  /// Schlüssel einer Ausnahmeliste, der für alle Regeln gilt.
  static const alle = '*';

  /// Die Regeln, die die Logik selbst setzt, in Prüfreihenfolge.
  static const logik = [
    satzlaenge,
    satzmittel,
    uhrzeit,
    uhrzeitForm,
    sekunden,
    punsch,
    herrSchneider,
    raumname,
    raumwort,
    platzhalter,
    klammer,
  ];
}

/// Eine Zeichenkette aus einer Inhaltsdatei mit ihrem Fundort.
class KammerTextStelle {
  const KammerTextStelle(this.datei, this.jsonPfad, this.text);

  /// Pfad relativ zu content/kammerspiel/schlosskeller/, mit `/`, z. B. `rollen/03-olli.json`.
  final String datei;

  /// JSON-Pfad ab `$`, z. B. `$.runden[0].auftraege[1]`. Schlüssel, die keine Bezeichner sind,
  /// stehen als `["…"]`.
  final String jsonPfad;

  final String text;
}

/// Ein Regelverstoß an einer Fundstelle.
class KammerTextBefund {
  const KammerTextBefund({
    required this.datei,
    required this.jsonPfad,
    required this.regel,
    required this.treffer,
    required this.auszug,
    this.ersatz,
    this.hinweis,
  });

  final String datei;
  final String jsonPfad;

  /// Regel-ID (siehe [KammerTextRegel] und `wortregeln[].regel`).
  final String regel;

  /// Die gefundene Stelle (Wort, Wendung, Uhrzeit, Zeichen; bei Satzlängen die Wortzahl).
  final String treffer;

  /// Ausschnitt um die Fundstelle (bei Satzlängen der gekürzte Satz).
  final String auszug;

  /// Ersatz aus textregeln.json, falls die Liste einen nennt.
  final String? ersatz;

  /// Allgemeiner Hinweis zur Regel aus textregeln.json.
  final String? hinweis;

  @override
  String toString() => '$datei $jsonPfad [$regel] „$treffer“${ersatz == null ? '' : ' → $ersatz'}: $auszug';
}

/// Ein Feld, dessen Text noch mit einer Marke wie „OFFEN:“ beginnt. Kein Regelverstoß, aber
/// noch nicht druckfertig.
class KammerUnvollstaendig {
  const KammerUnvollstaendig(this.datei, this.jsonPfad, this.text);

  final String datei;
  final String jsonPfad;
  final String text;

  @override
  String toString() => '$datei $jsonPfad: $text';
}

/// Ergebnis einer Prüfung über alle Dateien.
class KammerTextErgebnis {
  const KammerTextErgebnis(this.befunde, this.unvollstaendig, this.dateien);

  /// Regelverstöße, nach Datei und Fundstelle geordnet.
  final List<KammerTextBefund> befunde;

  /// Felder, die noch mit einer Marke aus `unvollstaendigMarken` beginnen.
  final List<KammerUnvollstaendig> unvollstaendig;

  /// Die geprüften Dateien (ohne `dateienAusgenommen`), sortiert.
  final List<String> dateien;
}

/// Alle Zeichenketten der [dateien] (Pfad → JSON) mit Fundort, Dateien nach Pfad sortiert,
/// innerhalb einer Datei in Dokumentreihenfolge. Schlüssel von Karten sind Kennungen und werden
/// nicht geliefert, nur Werte.
Iterable<KammerTextStelle> kammerTextStellen(Map<String, Object?> dateien) sync* {
  for (final datei in dateien.keys.toList()..sort()) {
    yield* _stellen(datei, r'$', dateien[datei]);
  }
}

final _bezeichnerRe = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

Iterable<KammerTextStelle> _stellen(String datei, String pfad, Object? wert) sync* {
  if (wert is String) {
    yield KammerTextStelle(datei, pfad, wert);
  } else if (wert is Map) {
    for (final e in wert.entries) {
      final k = '${e.key}';
      yield* _stellen(datei, _bezeichnerRe.hasMatch(k) ? '$pfad.$k' : '$pfad[${jsonEncode(k)}]', e.value);
    }
  } else if (wert is List) {
    for (var i = 0; i < wert.length; i++) {
      yield* _stellen(datei, '$pfad[$i]', wert[i]);
    }
  }
}

/// Ein Ausnahme-Muster `datei` oder `datei#jsonPfad`.
///
/// Datei: Glob über den ganzen relativen Pfad (`*` beliebig ohne `/`, `**` beliebig, `?` ein
/// Zeichen ohne `/`). JSON-Pfad: Präfix ab `$` an einer Segmentgrenze (`*` ein Schlüssel,
/// `[*]` jeder Index, `**` beliebig); `#$.olli` trifft `$.olli` und `$.olli.satz`, nicht `$.ollie`.
class _Muster {
  factory _Muster(String muster) {
    final i = muster.indexOf('#');
    final datei = i < 0 ? muster : muster.substring(0, i);
    final pfad = i < 0 ? null : muster.substring(i + 1);
    return _Muster._(RegExp(_globDatei(datei)), pfad == null ? null : RegExp(_globPfad(pfad)));
  }

  _Muster._(this.datei, this.pfad);

  final RegExp datei;
  final RegExp? pfad;

  bool passt(String d, String p) => datei.hasMatch(d) && (pfad?.hasMatch(p) ?? true);
}

String _globDatei(String g) {
  final b = StringBuffer('^');
  for (var i = 0; i < g.length; i++) {
    final c = g[i];
    if (c == '*' && i + 1 < g.length && g[i + 1] == '*') {
      b.write('.*');
      i++;
    } else if (c == '*') {
      b.write('[^/]*');
    } else if (c == '?') {
      b.write('[^/]');
    } else {
      b.write(RegExp.escape(c));
    }
  }
  b.write(r'$');
  return b.toString();
}

String _globPfad(String g) {
  final b = StringBuffer('^');
  var i = 0;
  while (i < g.length) {
    if (g.startsWith('[*]', i)) {
      b.write(r'\[\d+\]');
      i += 3;
    } else if (g.startsWith('**', i)) {
      b.write('.*');
      i += 2;
    } else if (g[i] == '*') {
      b.write(r'[^.\[\]]*');
      i++;
    } else {
      b.write(RegExp.escape(g[i]));
      i++;
    }
  }
  b.write(r'(?=$|[.\[])');
  return b.toString();
}

/// Ausnahmen je Regel-ID; der Schlüssel [KammerTextRegel.alle] gilt für jede Regel.
class _Ausnahmen {
  _Ausnahmen(Map<String, List<String>> roh)
      : _je = {for (final e in roh.entries) e.key: [for (final m in e.value) _Muster(m)]};

  final Map<String, List<_Muster>> _je;

  bool gilt(String regel, String datei, String pfad) =>
      (_je[regel] ?? const []).any((m) => m.passt(datei, pfad)) ||
      (_je[KammerTextRegel.alle] ?? const []).any((m) => m.passt(datei, pfad));
}

/// Ein Wort in seiner Lage im Text und die Nummer seines Satzes. Bindestriche verbinden.
class _Wort {
  _Wort(this.text, this.anfang, this.ende, this.satz) : klein = text.toLowerCase();

  final String text, klein;
  final int anfang, ende, satz;
}

final _wortRe = RegExp(r'[\p{L}\p{N}]+(?:-[\p{L}\p{N}]+)*', unicode: true);

/// Einträge einer Liste (ohne Ersatz) oder einer Karte Eintrag → Ersatz.
Map<String, String?> _eintraege(Object? v) {
  if (v is Map) return {for (final e in v.entries) e.key as String: e.value as String?};
  if (v is List) return {for (final e in v) e as String: null};
  return const {};
}

List<String> _texte(Object? v) => [for (final e in (v as List? ?? const [])) e as String];

/// Eine Wortregel aus `wortregeln` (siehe `beschreibung` in textregeln.json).
class _Wortregel {
  _Wortregel(Map<String, Object?> j)
      : regel = j['regel'] as String,
        gross = j['gross'] == true,
        hinweis = j['hinweis'] as String? {
    String norm(String s) => gross ? s : s.toLowerCase();
    for (final e in _eintraege(j['ganz']).entries) {
      final folge = [for (final m in _wortRe.allMatches(e.key)) norm(m[0]!)];
      if (folge.length > 1) {
        folgen.add((folge, e.value));
      } else if (folge.length == 1) {
        ganz[folge.first] = e.value;
      }
    }
    for (final (feld, ziel) in [('anfang', anfang), ('ende', ende), ('teil', teil)]) {
      for (final e in _eintraege(j[feld]).entries) {
        ziel[norm(e.key)] = e.value;
      }
    }
    for (final a in _texte(j['ausser'])) {
      if (a.startsWith('=')) {
        ausserGanz.add(a.substring(1).toLowerCase());
      } else {
        ausser.add(a.toLowerCase());
      }
    }
    for (final e in ((j['kontextAusser'] as Map?) ?? const {}).entries) {
      final v = e.value;
      kontextAusser[(e.key as String).toLowerCase()] = [
        for (final k in (v is List ? v : [v])) (k as String).toLowerCase(),
      ];
    }
    nurMit.addAll([for (final n in _texte(j['nurMit'])) n.toLowerCase()]);
  }

  final String regel;
  final bool gross;
  final String? hinweis;
  final Map<String, String?> ganz = {}, anfang = {}, ende = {}, teil = {};
  final List<(List<String>, String?)> folgen = [];
  final List<String> ausser = [];
  final Set<String> ausserGanz = {};
  final Map<String, List<String>> kontextAusser = {};
  final List<String> nurMit = [];

  /// Der getroffene Eintrag mit seinem Ersatz oder null.
  (String, String?)? trifft(_Wort w) {
    final s = gross ? w.text : w.klein;
    if (ganz.containsKey(s)) return (s, ganz[s]);
    for (final e in anfang.entries) {
      if (s.startsWith(e.key)) return (e.key, e.value);
    }
    for (final e in ende.entries) {
      if (s.endsWith(e.key)) return (e.key, e.value);
    }
    for (final e in teil.entries) {
      if (s.contains(e.key)) return (e.key, e.value);
    }
    return null;
  }

  bool ausgenommen(_Wort w, List<_Wort> worte) {
    if (ausserGanz.contains(w.klein) || ausser.any(w.klein.contains)) return true;
    final k = kontextAusser[w.klein];
    return k != null && worte.any((x) => x.satz == w.satz && k.any(x.klein.startsWith));
  }

  bool folgeAb(List<_Wort> worte, int i, List<String> folge) {
    if (i + folge.length > worte.length) return false;
    for (var k = 0; k < folge.length; k++) {
      if ((gross ? worte[i + k].text : worte[i + k].klein) != folge[k]) return false;
    }
    return true;
  }
}

final _zeitRe = RegExp(r'(?<![\d:.,])(\d{1,2}):(\d{2})(?::(\d{2}))?(?!\d)(?!:\d)');
final _punktZeitRe = RegExp(r'(?<![\d.,])\d{1,2}\.\d{2}\s?Uhr(?![\p{L}])', unicode: true);
final _sekundenZahlRe = RegExp(r'(?<![\p{L}\p{N}])\d+(?:[.,]\d+)?\s?(?:Sek\.|Sekunden?(?![\p{L}]))', unicode: true);
final _schneiderRe = RegExp(r'(?<![\p{L}\p{N}])Schneiders?(?![\p{L}\p{N}])', unicode: true);
final _herrDavorRe = RegExp(r'Herrn?[\s\u00A0\u202F]+$');
final _klammerAuslassungRe = RegExp(r'[\[({]\s*(?:…|\.\.\.)\s*[\])}]');
final _fragezeichenRe = RegExp(r'\?{3,}');

/// Ausschnitt rund um eine Fundstelle.
String _ausschnitt(String text, int anfang, int ende) {
  final a = max(0, anfang - 40);
  final e = min(text.length, ende + 40);
  return '${a > 0 ? '…' : ''}${text.substring(a, e).trim()}${e < text.length ? '…' : ''}';
}

String _kurz(String s) => s.length <= 120 ? s : '${s.substring(0, 117)}…';

String _escapeTeil(String alternativen) => [for (final a in alternativen.split('|')) RegExp.escape(a)].join('|');

final _wertPlatzhalterRe = RegExp(r'\{([a-z][A-Za-z0-9]*)\}');

/// Trennstelle nach einem Doppelpunkt, dem wörtliche Rede folgt (die Länge bleibt).
final _redeNachDoppelpunktRe = RegExp('(?<=:)(?=\\s+[„‚"»])');
final _platzhalterKopfRe = RegExp(r'\{(?:rolle|wenn|ab):[^|{}]*\||\{detektiv:');

/// Die Besetzungen, für die Sätze gezählt werden: aus fall.json (Plätze in Reihenfolge,
/// Personen `min` bis `max`, ohne die Personen in `ohneRolle`), sonst die beiden Extreme.
class _Besetzungen {
  _Besetzungen._(this._faelle, this._namen);

  /// Ohne fall.json: alle im Text genannten Rollen da (viele Personen) oder keine.
  factory _Besetzungen.extreme() => _Besetzungen._(null, const {});

  /// Aus fall.json ([fall] als JSON-Objekt oder -Text); unlesbar: [_Besetzungen.extreme].
  factory _Besetzungen.aus(Object? fall) {
    try {
      final f = (fall is String ? jsonDecode(fall) : fall) as Map;
      final personen = f['personen'] as Map;
      final ohne = (personen['ohneRolle'] as List).length;
      final plaetze = [for (final p in f['plaetze'] as List) p as Map];
      final ids = [for (final p in plaetze) p['id'] as String];
      return _Besetzungen._(
        [
          for (var n = personen['max'] as int; n >= (personen['min'] as int); n--) (ids.take(max(0, n - ohne)).toSet(), n),
        ],
        {for (final p in plaetze) p['id'] as String: p['name'] as String},
      );
    } on Object {
      return _Besetzungen.extreme();
    }
  }

  final List<(Set<String>, int)>? _faelle;
  final Map<String, String> _namen;

  /// Besetzte Rollen und Personenzahl je Fall, die größte Besetzung zuerst.
  List<(Set<String>, int)> faelle(Set<String> ids) => _faelle ?? [(ids, 1 << 20), (const {}, 0)];

  String name(String id) => _namen[id] ?? (id.isEmpty ? id : '${id[0].toUpperCase()}${id.substring(1)}');
}

/// [text] mit gleicher Länge, aber ohne Auszeichnung und Platzhalter-Syntax (Kopf, `|`,
/// Klammern werden Leerzeichen): So endet „{wenn:marek|Marek sah es.|…}“ den Satz nach „es.“,
/// und „. **Erfüllt**“ beginnt einen neuen. Nur für die Satzgrenzen der Wortregeln.
String _ohneSyntax(String text) => text
    .replaceAllMapped(_platzhalterKopfRe, (m) => ' ' * m[0]!.length)
    .replaceAll(RegExp(r'[*{}|]'), ' ');

/// Prüft alle Zeichenketten des Kammerspiel-Inhalts gegen die Regeln aus textregeln.json.
class KammerTextpruefer {
  KammerTextpruefer(Map<String, Object?> regeln)
      : _saetzeTp = Textpruefer({
          'saetze': {
            'hoechstens': _pflicht<Map>(regeln, 'saetze')['hoechstens'] as int,
            'mittelHoechstens': _pflicht<Map>(regeln, 'saetze')['mittelHoechstens'] as int,
          },
          'vorlesen': {'abkuerzungen': _texte(_pflicht<Map>(regeln, 'saetze')['abkuerzungen'])},
        }),
        _hoechstens = _pflicht<Map>(regeln, 'saetze')['hoechstens'] as int,
        _mittelHoechstens = _pflicht<Map>(regeln, 'saetze')['mittelHoechstens'] as int,
        _uhrzeiten = _texte(_pflicht<List>(regeln, 'uhrzeiten')).toSet(),
        _hinweise = {
          for (final e in ((regeln['hinweise'] as Map?) ?? const {}).entries) e.key as String: e.value as String,
        },
        _wortregeln = [
          for (final r in _pflicht<List>(regeln, 'wortregeln')) _Wortregel((r as Map).cast<String, Object?>()),
        ],
        _punschWort = (_pflicht<Map>(regeln, 'punsch')['wort'] as String).toLowerCase(),
        _punschPflicht = (_pflicht<Map>(regeln, 'punsch')['pflicht'] as String).toLowerCase(),
        _schneiderWendungen = _texte(_pflicht<Map>(regeln, 'herrSchneider')['erlaubteWendungen']),
        _raumwortEndungen = [for (final e in _texte(_pflicht<Map>(regeln, 'raumwort')['endungen'])) e.toLowerCase()],
        _raumwortErlaubtEndung = [
          for (final e in _texte(_pflicht<Map>(regeln, 'raumwort')['erlaubtEndung'])) e.toLowerCase(),
        ],
        _platzWoerter = {for (final w in _texte(_pflicht<Map>(regeln, 'platzhalter')['woerter'])) w.toLowerCase()},
        _platzAusdruecke = [
          for (final a in _texte(_pflicht<Map>(regeln, 'platzhalter')['ausdruecke']))
            RegExp(
              '(?<![\\p{L}\\p{N}])${RegExp.escape(a)}${RegExp(r'\p{L}$', unicode: true).hasMatch(a) ? '(?![\\p{L}\\p{N}])' : ''}',
              unicode: true,
              caseSensitive: false,
            ),
        ],
        _marken = _texte(_pflicht<List>(regeln, 'unvollstaendigMarken')),
        _dateienAusgenommen = [for (final m in _texte(regeln['dateienAusgenommen'])) _Muster(m)],
        vorgabeAusnahmen = {
          for (final e in ((regeln['ausnahmen'] as Map?) ?? const {}).entries) e.key as String: _texte(e.value),
        } {
    for (final r in _pflicht<List>(regeln, 'raumnamen')) {
      final m = r as Map;
      final name = m['name'] as String;
      final teile = [for (final t in _texte(m['teile'])) '(?:${_escapeTeil(t)})'];
      _raumMuster.add((
        RegExp('(?<![\\p{L}\\p{N}-])(${teile.join('[ \\u00A0-]?')})(e?s)?(?![\\p{L}\\p{N}])', unicode: true, caseSensitive: false),
        name,
      ));
      _raumwortErlaubt.add(name.toLowerCase());
    }
    for (final e in ((regeln['raumnamenFalsch'] as Map?) ?? const {}).entries) {
      _raumFalsch.add((
        RegExp('(?<![\\p{L}\\p{N}])${RegExp.escape(e.key as String)}', unicode: true, caseSensitive: false),
        e.value as String,
      ));
    }
    _raumwortErlaubt.addAll([for (final e in _texte(_pflicht<Map>(regeln, 'raumwort')['erlaubt'])) e.toLowerCase()]);
  }

  final Textpruefer _saetzeTp;
  final int _hoechstens, _mittelHoechstens;
  final Set<String> _uhrzeiten;
  final Map<String, String> _hinweise;
  final List<_Wortregel> _wortregeln;
  final String _punschWort, _punschPflicht;
  final List<String> _schneiderWendungen;
  final List<(RegExp, String)> _raumMuster = [];
  final List<(RegExp, String)> _raumFalsch = [];
  final Set<String> _raumwortErlaubt = {};
  final List<String> _raumwortEndungen, _raumwortErlaubtEndung;
  final Set<String> _platzWoerter;
  final List<RegExp> _platzAusdruecke;
  final List<String> _marken;
  final List<_Muster> _dateienAusgenommen;

  /// Vorgabe-Ausnahmen aus textregeln.json (`ausnahmen`): Regel-ID → Muster. [pruefe] und
  /// [pruefeText] nehmen sie immer dazu.
  final Map<String, List<String>> vorgabeAusnahmen;

  /// Alle Regel-IDs: erst die der Logik ([KammerTextRegel.logik]), dann die Wortregeln.
  List<String> get regeln => [...KammerTextRegel.logik, for (final r in _wortregeln) r.regel];

  /// Wird die Datei geprüft? Nein für `dateienAusgenommen` (textregeln.json, Schemata).
  bool dateiGeprueft(String datei) => !_dateienAusgenommen.any((m) => m.passt(datei, r'$'));

  /// Beginnt der Text mit einer Marke aus `unvollstaendigMarken` (z. B. „OFFEN:“)?
  bool unvollstaendig(String text) {
    final t = text.trimLeft();
    return _marken.any(t.startsWith);
  }

  /// Prüft alle Zeichenketten aller [dateien] (Pfad relativ zum Inhaltsordner → JSON).
  /// [ausnahmen] (Regel-ID → Muster, siehe textregeln.json `beschreibung`) kommen zu den
  /// [vorgabeAusnahmen] dazu. Texte mit einer Unvollständig-Marke stehen nur in
  /// [KammerTextErgebnis.unvollstaendig] und zählen für keine Regel.
  KammerTextErgebnis pruefe(Map<String, Object?> dateien, {Map<String, List<String>> ausnahmen = const {}}) {
    final aus = _Ausnahmen(_zusammen(ausnahmen));
    final fall = [for (final e in dateien.entries) if (e.key == 'fall.json' || e.key.endsWith('/schlosskeller/fall.json')) e.value];
    final besetzungen = fall.isEmpty ? _Besetzungen.extreme() : _Besetzungen.aus(fall.first);
    final befunde = <KammerTextBefund>[];
    final offen = <KammerUnvollstaendig>[];
    final geprueft = <String>[];
    String? aktuell;
    var worte = 0, saetze = 0;
    void mittelAbschliessen() {
      final datei = aktuell;
      if (datei != null && saetze > 0 && worte / saetze > _mittelHoechstens) {
        final m = (worte / saetze).toStringAsFixed(1).replaceAll('.', ',');
        befunde.add(KammerTextBefund(
          datei: datei,
          jsonPfad: r'$',
          regel: KammerTextRegel.satzmittel,
          treffer: m,
          auszug: '$m > $_mittelHoechstens ($saetze)',
          hinweis: _hinweise[KammerTextRegel.satzmittel],
        ));
      }
    }

    for (final s in kammerTextStellen(dateien)) {
      if (!dateiGeprueft(s.datei)) continue;
      if (s.datei != aktuell) {
        mittelAbschliessen();
        aktuell = s.datei;
        geprueft.add(s.datei);
        worte = 0;
        saetze = 0;
      }
      if (unvollstaendig(s.text)) {
        offen.add(KammerUnvollstaendig(s.datei, s.jsonPfad, s.text));
        continue;
      }
      befunde.addAll(_pruefeStelle(s, aus, besetzungen));
      if (!aus.gilt(KammerTextRegel.satzmittel, s.datei, s.jsonPfad)) {
        // Das Mittel zählt die Fassung bei größter Besetzung (die erste).
        final t = _fassungen(s.text, besetzungen).first;
        for (final (a, e) in _satzGrenzen(t)) {
          worte += _saetzeTp.woerter(t.substring(a, e));
          saetze++;
        }
      }
    }
    mittelAbschliessen();
    return KammerTextErgebnis(befunde, offen, geprueft);
  }

  /// Prüft einen einzelnen Text mit allen Regeln außer [KammerTextRegel.satzmittel] (die gilt je
  /// Datei). Unvollständig-Marken spielen hier keine Rolle; dafür gibt es [unvollstaendig].
  /// Satzlängen zählen in den aufgelösten Fassungen; ohne [fall] (fall.json) in den beiden
  /// Extremen der Besetzung.
  List<KammerTextBefund> pruefeText(
    String text, {
    String datei = 'probe.json',
    String jsonPfad = r'$',
    Map<String, List<String>> ausnahmen = const {},
    Object? fall,
  }) =>
      _pruefeStelle(
        KammerTextStelle(datei, jsonPfad, text),
        _Ausnahmen(_zusammen(ausnahmen)),
        fall == null ? _Besetzungen.extreme() : _Besetzungen.aus(fall),
      );

  /// Die gedruckten Fassungen von [text]: Platzhalter je Besetzung und Detektiv aufgelöst,
  /// ohne Auszeichnung, ohne Doppelte; die erste gehört zur größten Besetzung. Wert-Platzhalter
  /// (`{name}`) werden ein Wort. Ist der Text kein gültiger Platzhaltertext, bleibt er, wie er
  /// ist (die Klammer-Regel meldet ihn).
  List<String> _fassungen(String text, _Besetzungen b) {
    if (!text.contains('{') && !text.contains('*')) return [text];
    try {
      final ids = kammerTextRollen(text);
      final werte = {for (final m in _wertPlatzhalterRe.allMatches(text)) m[1]!: 'X'};
      final fassungen = <String>{};
      for (final (besetzt, personen) in b.faelle(ids)) {
        for (final weiblich in const [true, false]) {
          final w = KammerTextWerte(
            besetzt: besetzt,
            namen: {for (final id in besetzt) id: b.name(id)},
            personen: personen,
            detektivWeiblich: weiblich,
            werte: werte,
          );
          fassungen.add(kammerKlartext(loeseKammerText(text, w)));
        }
      }
      return fassungen.toList();
    } on FormatException {
      return [text];
    }
  }

  Map<String, List<String>> _zusammen(Map<String, List<String>> dazu) => {
        for (final k in {...vorgabeAusnahmen.keys, ...dazu.keys}) k: [...?vorgabeAusnahmen[k], ...?dazu[k]],
      };

  /// Satzgrenzen (Anfang, Ende) im Text. Ein Zeilenumbruch beendet immer einen Satz (Listen,
  /// Notizen), ebenso ein Doppelpunkt vor wörtlicher Rede (in „Sprich mit Sibel: ‚Wenn …‘“ ist
  /// die Rede ein eigener Satz); innerhalb davon teilt [Textpruefer.saetze]. Das deutsche
  /// schließende einfache Anführungszeichen (U+2018, „‚Hab ich dich!‘“) kennt dessen
  /// Satzteiler nicht; es zählt hier wie U+2019 (gleiche Länge, die Lage bleibt).
  List<(int, int)> _satzGrenzen(String text) {
    final g = <(int, int)>[];
    var zeile = 0;
    for (final z in text.replaceAll('\u2018', '\u2019').split('\n')) {
      var stueck = 0;
      for (final teil in z.split(_redeNachDoppelpunktRe)) {
        var ab = 0;
        for (final s in _saetzeTp.saetze(teil)) {
          final a = teil.indexOf(s, ab);
          if (a < 0) continue;
          g.add((zeile + stueck + a, zeile + stueck + a + s.length));
          ab = a + s.length;
        }
        stueck += teil.length;
      }
      zeile += z.length + 1;
    }
    return g;
  }

  List<KammerTextBefund> _pruefeStelle(KammerTextStelle s, _Ausnahmen aus, _Besetzungen besetzungen) {
    final text = s.text;
    final f = <KammerTextBefund>[];
    void melde(String regel, int a, int e, {String? treffer, String? auszug, String? ersatz, String? hinweis}) {
      if (aus.gilt(regel, s.datei, s.jsonPfad)) return;
      f.add(KammerTextBefund(
        datei: s.datei,
        jsonPfad: s.jsonPfad,
        regel: regel,
        treffer: treffer ?? text.substring(a, e),
        auszug: auszug ?? _ausschnitt(text, a, e),
        ersatz: ersatz,
        hinweis: hinweis ?? _hinweise[regel],
      ));
    }

    // Satzgrenzen für die Wortregeln „im selben Satz“: Rohtext ohne Auszeichnung und
    // Platzhalter-Syntax, gleich lang, damit die Lage der Wörter bleibt.
    final grenzen = _satzGrenzen(_ohneSyntax(text));
    var nr = 0;
    final worte = <_Wort>[];
    for (final m in _wortRe.allMatches(text)) {
      while (nr < grenzen.length - 1 && m.start >= grenzen[nr].$2) {
        nr++;
      }
      worte.add(_Wort(m[0]!, m.start, m.end, nr));
    }

    // Satzlänge (TON §4) in jeder gedruckten Fassung; derselbe Satz zählt einmal.
    final gemeldet = <String>{};
    for (final t in _fassungen(text, besetzungen)) {
      for (final (a, e) in _satzGrenzen(t)) {
        final satz = t.substring(a, e);
        final n = _saetzeTp.woerter(satz);
        if (n > _hoechstens && gemeldet.add(satz)) melde(KammerTextRegel.satzlaenge, 0, 0, treffer: '$n', auszug: _kurz(satz));
      }
    }

    // Wortregeln aus textregeln.json.
    for (final r in _wortregeln) {
      if (r.nurMit.isNotEmpty && !worte.any((w) => r.nurMit.any(w.klein.contains))) continue;
      for (var i = 0; i < worte.length; i++) {
        final w = worte[i];
        final t = r.trifft(w);
        if (t != null && !r.ausgenommen(w, worte)) {
          melde(r.regel, w.anfang, w.ende, ersatz: t.$2, hinweis: r.hinweis);
        }
        for (final (folge, ersatz) in r.folgen) {
          if (r.folgeAb(worte, i, folge)) {
            melde(r.regel, w.anfang, worte[i + folge.length - 1].ende, ersatz: ersatz, hinweis: r.hinweis);
          }
        }
      }
    }

    // Apfelpunsch beim ersten Nennen mit „alkoholfrei“ (TON §6).
    final p = worte.indexWhere((w) => w.klein.contains(_punschWort));
    if (p >= 0 && !worte.any((x) => x.satz == worte[p].satz && x.klein.startsWith(_punschPflicht))) {
      melde(KammerTextRegel.punsch, worte[p].anfang, worte[p].ende);
    }

    // „Herr Schneider“ / „Herrn Schneider“ (WELT 0.2).
    for (final m in _schneiderRe.allMatches(text)) {
      if (_herrDavorRe.hasMatch(text.substring(max(0, m.start - 12), m.start))) continue;
      if (_inWendung(text, m.start, m.end)) continue;
      melde(KammerTextRegel.herrSchneider, m.start, m.end);
    }

    // Uhrzeiten, Form, Sekunden (WELT 0.2).
    for (final m in _zeitRe.allMatches(text)) {
      final hm = '${int.parse(m[1]!)}:${m[2]}';
      if (!_uhrzeiten.contains(hm)) melde(KammerTextRegel.uhrzeit, m.start, m.end);
      if (m[1]!.length == 2 && m[1]!.startsWith('0')) melde(KammerTextRegel.uhrzeitForm, m.start, m.end, ersatz: hm);
      if (m[3] != null) melde(KammerTextRegel.sekunden, m.start, m.end, ersatz: hm);
    }
    for (final m in _punktZeitRe.allMatches(text)) {
      melde(KammerTextRegel.uhrzeitForm, m.start, m.end);
    }
    for (final m in _sekundenZahlRe.allMatches(text)) {
      melde(KammerTextRegel.sekunden, m.start, m.end);
    }

    // Raumnamen (WELT 0.2) und Raumwörter (REG §6.9).
    final raumStellen = <(int, int)>[];
    for (final (re, name) in _raumMuster) {
      for (final m in re.allMatches(text)) {
        raumStellen.add((m.start, m.end));
        if (m[1] != name) melde(KammerTextRegel.raumname, m.start, m.start + m[1]!.length, ersatz: name);
      }
    }
    for (final (re, ersatz) in _raumFalsch) {
      for (final m in re.allMatches(text)) {
        raumStellen.add((m.start, m.end));
        melde(KammerTextRegel.raumname, m.start, m.end, ersatz: ersatz);
      }
    }
    for (final w in worte) {
      if (!_raumwortEndungen.any(w.klein.endsWith)) continue;
      if (_raumwortErlaubt.contains(w.klein) || _raumwortErlaubtEndung.any(w.klein.endsWith)) continue;
      if (raumStellen.any((r) => r.$1 < w.ende && w.anfang < r.$2)) continue;
      melde(KammerTextRegel.raumwort, w.anfang, w.ende);
    }

    // Platzhalter-Reste (AUFTRAG §5.5, A-2 A4.9).
    for (final w in worte) {
      if (_platzWoerter.contains(w.klein)) melde(KammerTextRegel.platzhalter, w.anfang, w.ende);
    }
    for (final re in _platzAusdruecke) {
      for (final m in re.allMatches(text)) {
        melde(KammerTextRegel.platzhalter, m.start, m.end);
      }
    }
    for (final re in [_klammerAuslassungRe, _fragezeichenRe]) {
      for (final m in re.allMatches(text)) {
        melde(KammerTextRegel.platzhalter, m.start, m.end);
      }
    }
    // „…“ als Lücke am Textende; in wörtlicher Rede („Ich wollte nur …“) steht danach die Anführung.
    final rechts = text.trimRight();
    for (final punkte in ['…', '...']) {
      if (rechts.endsWith(punkte)) {
        melde(KammerTextRegel.platzhalter, rechts.length - punkte.length, rechts.length);
        break;
      }
    }

    // Klammern paarweise.
    final offen = <(String, int)>[];
    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (c == '{' || c == '[') {
        offen.add((c, i));
      } else if (c == '}' || c == ']') {
        if (offen.isNotEmpty && offen.last.$1 == (c == '}' ? '{' : '[')) {
          offen.removeLast();
        } else {
          melde(KammerTextRegel.klammer, i, i + 1);
        }
      }
    }
    for (final (_, i) in offen) {
      melde(KammerTextRegel.klammer, i, i + 1);
    }
    return f;
  }

  bool _inWendung(String text, int anfang, int ende) {
    for (final w in _schneiderWendungen) {
      var i = text.indexOf(w);
      while (i >= 0) {
        if (i <= anfang && ende <= i + w.length) return true;
        i = text.indexOf(w, i + 1);
      }
    }
    return false;
  }
}

T _pflicht<T>(Map<String, Object?> regeln, String schluessel) {
  final v = regeln[schluessel];
  if (v is! T) throw FormatException('textregeln.json: $schluessel fehlt oder hat die falsche Form');
  return v;
}
