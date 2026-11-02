// Kammerspiel P2 (ARCHITEKTUR A1/A2): Leser-Prüfung des Inhalts unter content/kammerspiel/schlosskeller/.
// Der Textprüfer (textpruefer.dart) prüft, was für jeden Text gilt. Diese Prüfung fragt, wer einen Text
// wann liest und was er dabei nicht erfahren darf: Täterwissen und Geheimnisse (E7, E10, MECH 10.4),
// Indizkarten ohne Urteil und ohne Geständnis (E3, A:18, MECH 3.1), neutrale Außenseiten (E8), gleiche
// Gestalt der vier Verdächtigen (E9, RK 1, RK 7.7, RK 8), Tugba unbelastet (E11) und Namen fehlender Rollen
// (WELT 0.2). Reines Dart ohne dart:io; alle Wortlisten, Quellen und Vorgabe-Ausnahmen stehen im Abschnitt
// `leser` von content/kammerspiel/schlosskeller/textregeln.json, hier steht nur die Logik, kein Spielertext.
//
// Texte, die noch mit einer Marke aus `unvollstaendigMarken` beginnen („OFFEN:“), prüft sie nicht und zählt
// sie nicht. Vergleiche, die solche Texte bräuchten (Gestalt), lässt sie aus und nennt sie in
// [KammerLeserErgebnis.ausgelassen].
import 'dart:convert';

import '../../steckbriefe.dart' show fuenfWortFolgen;
import 'besetzung.dart';
import 'inhalt.dart';
import 'platzhalter.dart';
import 'textpruefer.dart';

/// Regel-IDs der Leser-Prüfung (Präfix `leser-`); die Begründung je Regel steht in textregeln.json
/// unter `leser.hinweise`.
abstract final class KammerLeserRegel {
  /// Fünf-Wort-Folge aus dem Tatkern (RN7 ab dem Knall, Stufe 3, Teil 90) in einem Text, den andere vor
  /// der Auflösung lesen: Hefte (auch Ollis), Erzählerheft, Detektivbogen, Tisch, Außenseiten, Beschriftungen.
  static const taeterwissen = 'leser-taeterwissen';

  /// Wort der Tat oder des Geständnisses (`leser.tatwoerter`) außerhalb von RN7 und Teil 90.
  static const tatwort = 'leser-tatwort';

  /// Fünf-Wort-Folge aus einem Geheimnis (Stufe 2, Geheimniskarte, Freigabe nach der Karte, Teil 90,
  /// Tatkern) in Erzählerheft, Detektivbogen, Tisch, Außenseiten oder Beschriftungen (E10); auf einem
  /// Zeugenstreifen aus dem eigenen Geheimnis seines Zeugen (E7).
  static const geheimnis = 'leser-geheimnis';

  /// Fassungscode im Klartext außerhalb von Teil 90 (MECH 9, RK 7.2).
  static const fassungscode = 'leser-fassungscode';

  /// Name auf einer Indizkarte aus `leser.indiz.ohneNamen` (XD3, PP9) oder in einem Vermerk mit
  /// Urteilswort (Schlüsselbeweis, Fundort; E3, MECH 3.1 Nr. 3).
  static const indizName = 'leser-indiz-name';

  /// Geständniswort auf einer Indizkarte oder ein Satz, in dem eine Person etwas sah, hörte, wusste oder
  /// sagte (A:18, MECH 3.1 Nr. 1).
  static const indizGestaendnis = 'leser-indiz-gestaendnis';

  /// Spoiler-Wort auf einer Indizkarte; rote Teilchen am Fundort (MECH 3.1 Nr. 7).
  static const indizWort = 'leser-indiz-wort';

  /// Außenseite (`leser.vorderseiten`) mit fremdem Wert, Name, Code, Bedingung oder fehlend (E8).
  static const vorderseite = 'leser-vorderseite';

  /// Bedingung auf einer Geheimniskarte oder ein Heft ohne Bedingung (E8, MECH 4.1).
  static const bedingung = 'leser-bedingung';

  /// Tugba (`leser.kopftuch.rolle`) belastet (E11).
  static const kopftuch = 'leser-kopftuch';

  /// Name einer Rolle, die bei einer Besetzung, bei der der Text gedruckt wird, niemand spielt (WELT 0.2).
  static const platzhalter = 'leser-platzhalter';

  /// Felder, Zahl der Einträge oder feste Werte der vier Verdächtigen ungleich (E9, RK 1.1, RK 8.2).
  static const gestaltGliederung = 'leser-gestalt-gliederung';

  /// Wortzahl eines Teils mehr als `leser.gestalt.toleranz` vom Mittel der vier entfernt (RK 7.7).
  static const gestaltLaenge = 'leser-gestalt-laenge';

  /// Stufe 2 ohne den gemeinsamen Schlusssatz oder ein Satz nur der Unschuldigen im Heft (RK 8.2).
  static const gestaltSchluss = 'leser-gestalt-schluss';

  /// Aktionskarten der vier ungleich gebaut oder verräterisch benannt (E9, MECH 4.5).
  static const gestaltAktion = 'leser-gestalt-aktion';

  /// Tat in der Fassung einer Unschuldigen oder Stufe 3 des Täters ohne Tat (E9, MECH 8.1).
  static const gestaltTat = 'leser-gestalt-tat';

  /// Alle Regel-IDs in Prüfreihenfolge.
  static const alle = [
    taeterwissen,
    tatwort,
    geheimnis,
    fassungscode,
    indizName,
    indizGestaendnis,
    indizWort,
    vorderseite,
    bedingung,
    kopftuch,
    platzhalter,
    gestaltGliederung,
    gestaltLaenge,
    gestaltSchluss,
    gestaltAktion,
    gestaltTat,
  ];
}

/// Wer einen Text liest.
enum KammerLeserArt {
  /// Kennungen, Zahlen und fall.json: kein eigener Leser, von keiner Leser-Regel geprüft.
  struktur,

  /// gemeinsam.json und ui/gemeinsam.json: in mehreren Teilen, für alle.
  alle,

  /// Teil 00: der Erzähler, von Anfang an, ohne die Lösung zu kennen.
  erzaehler,

  /// Teil 01: der Detektiv, von Anfang an.
  detektiv,

  /// Teil 02: Lageplan, Markerfelder, Marker, Tipp-Zettel; alle am Tisch.
  tisch,

  /// Teil 02: Zeugenstreifen eines fehlenden Zeugen, Etikett von Anfang an, Protokoll nach dem Umdrehen.
  streifen,

  /// Teile 10 und 12: Rollen- oder Zusatzheft, vorab sendbar.
  heft,

  /// Teil 11 innen: versiegelte Fassung, geöffnet nach dem Tat-Moment.
  fassung,

  /// Teil 11 außen: Code und Siegelhinweis.
  fassungAussen,

  /// Teil 20 innen: Indizkarte, vorgelesen, wenn der Detektiv sie zieht.
  indizkarte,

  /// Teil 20 innen: Geheimniskarte, offen nach dem Umdrehen.
  geheimniskarte,

  /// Teil 20: offene Aktionskarte.
  aktionskarte,

  /// Teil 20 außen: Vorderseiten der Geheimnis- und Indizkarten.
  karteAussen,

  /// Teil 90: versiegelt bis nach der Anklage.
  aufloesung,
}

/// Ein Leser eines Texts: Art, Teil des Drucks und, bei Rollentexten, die Rolle.
class KammerLeser {
  const KammerLeser(this.art, {this.teil, this.rolle});

  final KammerLeserArt art;

  /// Teil des Drucks (`00` … `90`), null bei [KammerLeserArt.struktur] und [KammerLeserArt.alle].
  final String? teil;

  /// Rollen-ID bei Texten aus rollen/, sonst null (auch bei abwesenheit.json; der Zeuge eines Streifens
  /// ergibt sich aus seinem Index, siehe [KammerInhalt.streifen]).
  final String? rolle;

  @override
  bool operator ==(Object other) => other is KammerLeser && other.art == art && other.teil == teil && other.rolle == rolle;

  @override
  int get hashCode => Object.hash(art, teil, rolle);

  @override
  String toString() {
    final r = rolle == null ? '' : ':$rolle';
    final t = teil == null ? '' : '/$teil';
    return '${art.name}$r$t';
  }
}

/// Ergebnis der Leser-Prüfung.
class KammerLeserErgebnis {
  const KammerLeserErgebnis(this.befunde, this.ausgelassen);

  /// Befunde mit Datei, JSON-Pfad und Regel-ID, nach Datei und Fundstelle geordnet (wie beim Textprüfer).
  final List<KammerTextBefund> befunde;

  /// Vergleiche, die wegen unvollständiger Texte nicht liefen, als „Regel · Teil“.
  final List<String> ausgelassen;
}

/// Sätze eines Texts: Ein Zeilenumbruch endet immer, sonst endet ein Satz an . ! ? : ; … vor einem
/// Leerraum (auch nach einem schließenden Anführungszeichen).
List<String> kammerSaetze(String text) => [
      for (final s in text.split(_satzGrenze))
        if (s.trim().isNotEmpty) s.trim(),
    ];

/// Fünf-Wort-Folgen ([fuenfWortFolgen]) je Satz ([kammerSaetze]); keine Folge reicht über ein Satzende.
Set<String> kammerSatzFolgen(String text) => {for (final s in kammerSaetze(text)) ...fuenfWortFolgen(s)};

final _satzGrenze = RegExp('\\n|(?<=[.!?:;…][“”‘’"\']?)\\s+');
final _wortRe = RegExp(r'[\p{L}\p{N}]+', unicode: true);
final _wertRe = RegExp(r'\{([a-z][A-Za-z0-9]*)\}');
final _redeRe = RegExp(r'„([^“]*)“');
final _indexRe = RegExp(r'\[(\d+)\]');
final _bezeichnerRe = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
final _zaehlWortRe = RegExp(r'[\p{L}\p{N}€]', unicode: true);
final _rolleDateiRe = RegExp(r'^rollen/(\d+)-([a-z0-9]+)\.json$');
final _auftragRe = RegExp(r'^\$\.gespraechsauftraege\[(\d+)\]\.(\w+)');
final _zeitzeileRe = RegExp(r'^\$\.fassung\.zeitleiste\[(\d+)\]\.text$');

/// Schlüssel, deren Zeichenketten Kennungen sind (IDs, Codes, Feld-IDs), keine Leser-Texte, je Datei
/// (`rollen/` für alle Rollendateien). Dazu in den Rollendateien `gespraechsauftraege[n].ziel`.
const _kennungsFelder = <String, Set<String>>{
  'erzaehlerheft.json': {'teil', 'abschnitt', 'art', 'id', 'rolle', 'zeuge'},
  'detektiv.json': {'nr', 'id', 'spalten', 'rolle'},
  'tisch.json': {'id', 'feld', 'zustand', 'art', 'wer', 'z2357', 'scheppern'},
  'abwesenheit.json': {'zeuge', 'feld', 'oeffnen'},
  'indizkarten.json': {'code', 'art', 'felder', 'zeugen', 'meilensteine'},
  'aufloesung.json': {'nr'},
  'gemeinsam.json': {'nr'},
  'rollen/': {'id', 'z2357', 'scheppern', 'impuls', 'indizkarte', 'klasse', 'pflichtCodes', 'code'},
};

/// Ist die Zeichenkette an [datei] und [pfad] eine Kennung?
bool _istKennung(String datei, String pfad) {
  final rolle = datei.startsWith('rollen/');
  final schluessel = _letzterSchluessel(pfad);
  if (rolle && RegExp(r'^\$\.gespraechsauftraege\[\d+\]\.ziel$').hasMatch(pfad)) return true;
  return _kennungsFelder[rolle ? 'rollen/' : datei]?.contains(schluessel) ?? false;
}

List<String> _woerter(String text) => [for (final m in _wortRe.allMatches(text.toLowerCase())) m[0]!];

int _zaehle(String text) => text.replaceAll('*', ' ').split(RegExp(r'\s+')).where(_zaehlWortRe.hasMatch).length;

String _komma(double x) => x.toStringAsFixed(1).replaceAll('.', ',');

String _kurz(String s) => s.length <= 140 ? s : '${s.substring(0, 137)}…';

/// Letzter Schlüssel eines JSON-Pfads ohne Listenindex (`$.a.b[3]` → `b`, `$["x.y"]` → `x.y`).
String _letzterSchluessel(String pfad) {
  final p = pfad.replaceAll(RegExp(r'(\[\d+\])+$'), '');
  final q = RegExp(r'\["((?:[^"\\]|\\.)*)"\]$').firstMatch(p);
  if (q != null) return jsonDecode('"${q[1]}"') as String;
  final i = p.lastIndexOf('.');
  return i < 0 ? '' : p.substring(i + 1);
}

/// JSON-Pfad eines ui-Schlüssels in der Form von [kammerTextStellen].
String _uiPfad(String schluessel) => _bezeichnerRe.hasMatch(schluessel) ? '\$.$schluessel' : '\$[${jsonEncode(schluessel)}]';

/// Datenpfad aus textregeln.json (`stufe1.kernsaetze`, `gespraechsauftraege[*].ausweich`) als JSON-Pfad-Muster.
String _datenPfad(String p) => p.startsWith(r'$') ? p : '\$.$p';

/// Ein Muster `datei` oder `datei#jsonPfad` mit derselben Bedeutung wie die Ausnahmen des Textprüfers:
/// Datei-Glob über den ganzen relativen Pfad (`*` ohne `/`, `**` beliebig, `?` ein Zeichen), JSON-Pfad als
/// Präfix ab `$` an einer Segmentgrenze (`*` ein Schlüssel, `[*]` jeder Index, `**` beliebig).
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

String _globPfad(String g, {bool ganz = false}) {
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
  b.write(ganz ? r'$' : r'(?=$|[.\[])');
  return b.toString();
}

bool _passtEins(List<_Muster> muster, String datei, String pfad) => muster.any((m) => m.passt(datei, pfad));

/// Eine Wortliste aus textregeln.json: `ganz` (ganze Wörter), `anfang` (Wortanfänge), `folgen`
/// (Wortfolgen, je mit `nichtVor`: das nächste Wort darf keins davon sein). Alles klein.
class _Wortliste {
  factory _Wortliste(Object? json) {
    final j = json is Map ? json : const {};
    return _Wortliste._(
      {for (final w in _texte(j['ganz'])) w.toLowerCase()},
      [for (final w in _texte(j['anfang'])) w.toLowerCase()],
      [
        for (final f in (j['folgen'] as List? ?? const []).cast<Map>())
          (_woerter(f['folge'] as String), {for (final n in _texte(f['nichtVor'])) n.toLowerCase()}),
      ],
    );
  }

  _Wortliste._(this.ganz, this.anfang, this.folgen);

  final Set<String> ganz;
  final List<String> anfang;
  final List<(List<String>, Set<String>)> folgen;

  /// Der erste Treffer in [text] (Wort oder Wortfolge, klein) oder null.
  String? treffer(String text) {
    final w = _woerter(text);
    for (var i = 0; i < w.length; i++) {
      if (ganz.contains(w[i])) return w[i];
      for (final a in anfang) {
        if (w[i].startsWith(a)) return w[i];
      }
      for (final (folge, nicht) in folgen) {
        if (folge.isEmpty || i + folge.length > w.length) continue;
        var gleich = true;
        for (var k = 0; k < folge.length && gleich; k++) {
          gleich = w[i + k] == folge[k];
        }
        if (!gleich) continue;
        final danach = i + folge.length < w.length ? w[i + folge.length] : null;
        if (danach != null && nicht.contains(danach)) continue;
        return folge.join(' ');
      }
    }
    return null;
  }
}

String _grundSchluessel(String regel, String muster) => '$regel $muster';

List<String> _texte(Object? v) => [for (final e in (v as List? ?? const [])) e as String];

T _pflicht<T>(Map<String, Object?> m, String schluessel) {
  final v = m[schluessel];
  if (v is! T) throw FormatException('textregeln.json: leser.$schluessel fehlt oder hat die falsche Form');
  return v;
}

/// Eine konfigurierte Außenseite: ui-Datei, Schlüssel und erlaubte Wert-Platzhalter.
class _Vorderseite {
  const _Vorderseite(this.datei, this.schluessel, this.werte);
  final String datei;
  final String schluessel;
  final Set<String> werte;
}

/// Eine Zeile der Längenprüfung: Name und Feldpfade (relativ zur Rollendatei).
class _Laenge {
  const _Laenge(this.name, this.felder);
  final String name;
  final List<RegExp> felder;
}

/// Prüft den Kammerspiel-Inhalt nach Lesern. Nimmt jsonDecode von textregeln.json (Abschnitt `leser`,
/// dazu `unvollstaendigMarken`); fehlt ein Pflichtteil, wirft der Konstruktor eine [FormatException].
class KammerLeserpruefer {
  KammerLeserpruefer(Map<String, Object?> regeln) : this._(_pflicht<Map>(regeln, 'leser').cast<String, Object?>(), regeln);

  KammerLeserpruefer._(Map<String, Object?> l, Map<String, Object?> regeln)
      : _marken = _texte(regeln['unvollstaendigMarken']),
        _hinweise = {
          for (final e in _pflicht<Map>(l, 'hinweise').entries) e.key as String: e.value as String,
        },
        _tatkern = _texte(_pflicht<Map>(l, 'tatkern')['muster']),
        _zeitleisteNur = _texte(_pflicht<Map>(l, 'tatkern')['zeitleisteNur']).toSet(),
        _nurRede = _texte(_pflicht<Map>(l, 'tatkern')['nurRede']),
        _geheimnisquellen = _texte(_pflicht<List>(l, 'geheimnisquellen')),
        _oeffentlich = _texte(_pflicht<List>(l, 'oeffentlich')),
        _zeugenwissen = _texte(_pflicht<List>(l, 'zeugenwissen')),
        erlaubteFolgen = {
          for (final e in _pflicht<Map>(l, 'erlaubteFolgen').entries)
            e.key as String: {for (final f in (e.value as Map).entries) f.key as String: f.value as String},
        },
        vorgabeAusnahmen = {
          for (final e in _pflicht<Map>(l, 'ausnahmen').entries)
            e.key as String: [for (final a in e.value as List) (a as Map)['muster'] as String],
        },
        ausnahmeGruende = {
          for (final e in _pflicht<Map>(l, 'ausnahmen').entries)
            for (final a in (e.value as List).cast<Map>()) _grundSchluessel(e.key as String, a['muster'] as String): a['grund'] as String,
        },
        _tatwoerter = _Wortliste(_pflicht<Map>(l, 'tatwoerter')),
        _ohneNamen = _texte(_pflicht<Map>(l, 'indiz')['ohneNamen']).toSet(),
        _urteil = _Wortliste(_pflicht<Map>(l, 'indiz')['urteil']),
        _fundort = (_pflicht<Map>(l, 'indiz')['fundort'] as String).toLowerCase(),
        _fundortOhne = _Wortliste(_pflicht<Map>(l, 'indiz')['fundortOhne']),
        _gestaendnis = _Wortliste(_pflicht<Map>(l, 'indiz')['gestaendnis']),
        _wahrnehmung = _Wortliste(_pflicht<Map>(l, 'indiz')['wahrnehmung']),
        _spoiler = _Wortliste(_pflicht<Map>(l, 'indiz')['spoiler']),
        _vorderseiten = [
          for (final v in _pflicht<List>(l, 'vorderseiten'))
            _Vorderseite((v as Map)['datei'] as String, v['schluessel'] as String, _texte(v['werte']).toSet()),
        ],
        _bedingung = _Wortliste(_pflicht<Map>(l, 'bedingung')),
        _kopftuch = _pflicht<Map>(l, 'kopftuch').cast<String, Object?>(),
        _gestalt = _pflicht<Map>(l, 'gestalt').cast<String, Object?>() {
    _belastend = _Wortliste(_kopftuch['belastend']);
    _verraeterisch = _Wortliste((_gestalt['aktion'] as Map)['verraeterisch']);
    _toleranz = (_gestalt['toleranz'] as num).toDouble();
    _laengen = [
      for (final z in _gestalt['laengen'] as List)
        _Laenge((z as Map)['name'] as String, [for (final f in _texte(z['felder'])) RegExp(_globPfad(_datenPfad(f)))]),
    ];
    _laengenOhne = [for (final f in _texte(_gestalt['ohne'])) RegExp(_globPfad(_datenPfad(f)))];
    _ungleichErlaubt = [for (final f in _texte(_gestalt['ungleichErlaubt'])) RegExp(_globPfad(_datenPfad(f)))];
    _gleicheWerte = [for (final f in _texte(_gestalt['gleicheWerte'])) RegExp(_globPfad(_datenPfad(f), ganz: true))];
  }

  final List<String> _marken;
  final Map<String, String> _hinweise;
  final List<String> _tatkern, _nurRede, _geheimnisquellen, _oeffentlich, _zeugenwissen;
  final Set<String> _zeitleisteNur;

  /// Folgen, die eine Regel nicht meldet, mit Begründung (`leser.erlaubteFolgen`): Regel-ID → Folge → Grund.
  final Map<String, Map<String, String>> erlaubteFolgen;

  /// Vorgabe-Ausnahmen (`leser.ausnahmen`): Regel-ID → Muster. [pruefe] nimmt sie immer dazu.
  final Map<String, List<String>> vorgabeAusnahmen;

  /// Begründung je Vorgabe-Ausnahme, Schlüssel „Regel-ID Muster“.
  final Map<String, String> ausnahmeGruende;

  final _Wortliste _tatwoerter, _urteil, _fundortOhne, _gestaendnis, _wahrnehmung, _spoiler, _bedingung;
  final Set<String> _ohneNamen;
  final String _fundort;
  final List<_Vorderseite> _vorderseiten;
  final Map<String, Object?> _kopftuch, _gestalt;
  late final _Wortliste _belastend, _verraeterisch;
  late final double _toleranz;
  late final List<_Laenge> _laengen;
  late final List<RegExp> _laengenOhne, _ungleichErlaubt, _gleicheWerte;

  /// Alle Regel-IDs ([KammerLeserRegel.alle]).
  List<String> get regeln => KammerLeserRegel.alle;

  /// Beginnt der Text mit einer Marke aus `unvollstaendigMarken` (etwa „OFFEN:“)?
  bool unvollstaendig(String text) {
    final t = text.trimLeft();
    return _marken.any(t.startsWith);
  }

  bool _istVorderseite(String datei, String schluessel) =>
      _vorderseiten.any((v) => v.datei == datei && v.schluessel == schluessel);

  /// Die Leser eines Texts an [datei] (relativ zum Inhaltsordner) und [jsonPfad], der wichtigste zuerst.
  /// Leer für Dateien, die nicht zum Inhalt gehören (textregeln.json, SCHEMA.md).
  List<KammerLeser> leserVon(String datei, String jsonPfad) {
    if (!kammerInhaltDateien.contains(datei)) return const [];
    const struktur = [KammerLeser(KammerLeserArt.struktur)];
    if (datei == 'fall.json' || _istKennung(datei, jsonPfad)) return struktur;
    bool unter(String p) => jsonPfad == p || jsonPfad.startsWith('$p.') || jsonPfad.startsWith('$p[');
    final rolle = _rolleDateiRe.firstMatch(datei);
    if (rolle != null) {
      final platz = int.parse(rolle[1]!);
      final id = rolle[2]!;
      final heft = KammerLeser(KammerLeserArt.heft, teil: platz <= 10 ? '10' : '12', rolle: id);
      if (unter(r'$.platz')) return struktur;
      if (unter(r'$.vorstellung.frage')) return [KammerLeser(KammerLeserArt.erzaehler, teil: '00', rolle: id)];
      if (unter(r'$.teil90')) return [KammerLeser(KammerLeserArt.aufloesung, teil: '90', rolle: id)];
      if (unter(r'$.fassung')) return [KammerLeser(KammerLeserArt.fassung, teil: '11', rolle: id)];
      if (unter(r'$.geheimniskarte')) {
        return [KammerLeser(KammerLeserArt.geheimniskarte, teil: '20', rolle: id), if (platz > 4) heft];
      }
      if (unter(r'$.aktionskarte') && !unter(r'$.aktionskarte.tipp')) {
        return [
          KammerLeser(KammerLeserArt.aktionskarte, teil: '20', rolle: id),
          heft,
          if (platz > 4 && platz <= 10) KammerLeser(KammerLeserArt.detektiv, teil: '01', rolle: id),
        ];
      }
      if (unter(r'$.notiz')) return [heft, KammerLeser(KammerLeserArt.streifen, teil: '02', rolle: id)];
      return [heft];
    }
    final ui = datei.startsWith('ui/') ? _letzterSchluessel(jsonPfad) : '';
    switch (datei) {
      case 'gemeinsam.json' || 'ui/gemeinsam.json':
        return const [KammerLeser(KammerLeserArt.alle)];
      case 'erzaehlerheft.json' || 'ui/00.json':
        return const [KammerLeser(KammerLeserArt.erzaehler, teil: '00')];
      case 'detektiv.json' || 'ui/01.json':
        return const [KammerLeser(KammerLeserArt.detektiv, teil: '01')];
      case 'tisch.json' || 'ui/02.json':
        return const [KammerLeser(KammerLeserArt.tisch, teil: '02')];
      case 'abwesenheit.json':
        return const [KammerLeser(KammerLeserArt.streifen, teil: '02')];
      case 'indizkarten.json':
        return [
          const KammerLeser(KammerLeserArt.indizkarte, teil: '20'),
          if (_letzterSchluessel(jsonPfad) == 'titel') const KammerLeser(KammerLeserArt.detektiv, teil: '01'),
        ];
      case 'aufloesung.json' || 'ui/90.json':
        return const [KammerLeser(KammerLeserArt.aufloesung, teil: '90')];
      case 'ui/10.json':
        return const [KammerLeser(KammerLeserArt.heft, teil: '10')];
      case 'ui/12.json':
        return const [KammerLeser(KammerLeserArt.heft, teil: '12')];
      case 'ui/11.json':
        return [KammerLeser(_istVorderseite(datei, ui) ? KammerLeserArt.fassungAussen : KammerLeserArt.fassung, teil: '11')];
      case 'ui/20.json':
        if (_istVorderseite(datei, ui)) return const [KammerLeser(KammerLeserArt.karteAussen, teil: '20')];
        return [
          if (!ui.startsWith('geheimnis.') && !ui.startsWith('aktion.')) const KammerLeser(KammerLeserArt.indizkarte, teil: '20'),
          if (!ui.startsWith('indiz.') && !ui.startsWith('aktion.')) const KammerLeser(KammerLeserArt.geheimniskarte, teil: '20'),
          if (!ui.startsWith('indiz.') && !ui.startsWith('geheimnis.')) const KammerLeser(KammerLeserArt.aktionskarte, teil: '20'),
        ];
    }
    return struktur;
  }

  /// Prüft den Inhalt [dateien] (Pfad relativ zum Inhaltsordner oder zum Repo → JSON-Objekt oder JSON-Text;
  /// andere Dateien wie textregeln.json werden übergangen). Der Inhalt wird mit [KammerInhalt.ausJson]
  /// geladen und muss gültig sein (sonst [FormatException]). [ausnahmen] (Regel-ID → Muster wie beim
  /// Textprüfer) kommen zu den [vorgabeAusnahmen] dazu.
  KammerLeserErgebnis pruefe(Map<String, Object?> dateien, {Map<String, List<String>> ausnahmen = const {}}) {
    final json = <String, Object?>{};
    for (final e in dateien.entries) {
      final name = e.key.startsWith('$kammerInhaltOrdner/') ? e.key.substring(kammerInhaltOrdner.length + 1) : e.key;
      if (!kammerInhaltDateien.contains(name)) continue;
      json[name] = e.value is String ? jsonDecode(e.value as String) : e.value;
    }
    final lauf = _Lauf(this, KammerInhalt.ausJson(json), json);
    lauf.alles();
    final aus = {
      for (final k in {...vorgabeAusnahmen.keys, ...ausnahmen.keys})
        k: [for (final m in [...?vorgabeAusnahmen[k], ...?ausnahmen[k]]) _Muster(m)],
    };
    bool ausgenommen(KammerTextBefund b) =>
        _passtEins(aus[b.regel] ?? const [], b.datei, b.jsonPfad) || _passtEins(aus['*'] ?? const [], b.datei, b.jsonPfad);
    final gesehen = <String>{};
    final befunde = [
      for (final b in lauf.befunde)
        if (!ausgenommen(b) && gesehen.add('${b.datei}|${b.jsonPfad}|${b.regel}|${b.treffer}')) b,
    ];
    int nr(KammerTextBefund b) => lauf.nummer['${b.datei}#${b.jsonPfad}'] ?? -1;
    final regelNr = {for (final (i, r) in KammerLeserRegel.alle.indexed) r: i};
    final geordnet = [for (final (i, b) in befunde.indexed) (i, b)]
      ..sort((a, b) {
        var c = a.$2.datei.compareTo(b.$2.datei);
        if (c == 0) c = nr(a.$2).compareTo(nr(b.$2));
        if (c == 0) c = regelNr[a.$2.regel]!.compareTo(regelNr[b.$2.regel]!);
        return c == 0 ? a.$1.compareTo(b.$1) : c;
      });
    return KammerLeserErgebnis([for (final (_, b) in geordnet) b], List.unmodifiable(lauf.ausgelassen));
  }
}

/// Eine Zeichenkette des Inhalts mit Fundort und Lesern.
class _Stelle {
  _Stelle(this.nr, this.datei, this.pfad, this.text, this.leser, this.rolle, this.offen);

  final int nr;
  final String datei, pfad, text;
  final List<KammerLeser> leser;

  /// Rollen-ID der Datei rollen/…, sonst null.
  final String? rolle;

  /// Beginnt mit einer Unvollständig-Marke.
  final bool offen;

  KammerLeserArt get art => leser.isEmpty ? KammerLeserArt.struktur : leser.first.art;

  bool hat(Set<KammerLeserArt> arten) => leser.any((l) => arten.contains(l.art));

  String get ort => '$datei#$pfad';
}

/// Ein Prüflauf über einen geladenen Inhalt.
class _Lauf {
  _Lauf(this.p, this.inhalt, this.json) {
    for (final s in kammerTextStellen(json)) {
      final rolle = _rolleDateiRe.firstMatch(s.datei)?[2];
      final st = _Stelle(stellen.length, s.datei, s.jsonPfad, s.text, p.leserVon(s.datei, s.jsonPfad), rolle, p.unvollstaendig(s.text));
      stellen.add(st);
      nummer[st.ort] = st.nr;
    }
    final f = inhalt.fall;
    for (var n = f.personenMin; n <= f.personenMax; n++) {
      besetzung[n] = KammerBesetzung.fuer(inhalt, personen: n);
    }
    voll = besetzung[f.personenMax]!;
    for (final pl in f.plaetze) {
      namen[pl.id] = RegExp('(?<![\\p{L}\\p{N}])${RegExp.escape(pl.name)}(s|’s|\'s)?(?![\\p{L}\\p{N}])', unicode: true);
    }
    final codes = [...f.fassungsCodes, ...f.indizCodes].map(RegExp.escape).join('|');
    codeRe = RegExp('(?<![A-Za-z0-9])($codes)(?![A-Za-z0-9])');
    fassungsCodeRe = RegExp('(?<![A-Za-z0-9])(${f.fassungsCodes.map(RegExp.escape).join('|')})(?![A-Za-z0-9])');
    taeterDatei = inhalt.platzVon(f.taeter).datei;
    unschuldig = [
      for (final pl in f.plaetze)
        if (pl.art == KammerArt.verdaechtig && pl.id != f.taeter) pl.datei,
    ];
  }

  final KammerLeserpruefer p;
  final KammerInhalt inhalt;
  final Map<String, Object?> json;
  final stellen = <_Stelle>[];
  final nummer = <String, int>{};
  final besetzung = <int, KammerBesetzung>{};
  late final KammerBesetzung voll;
  final namen = <String, RegExp>{};
  late final RegExp codeRe, fassungsCodeRe;
  late final String taeterDatei;
  late final List<String> unschuldig;
  final befunde = <KammerTextBefund>[];
  final ausgelassen = <String>[];
  final _aufgeloest = <int, Map<String, List<int>>>{};

  void melde(String regel, String datei, String pfad, String treffer, String auszug) => befunde.add(KammerTextBefund(
        datei: datei,
        jsonPfad: pfad,
        regel: regel,
        treffer: treffer,
        auszug: _kurz(auszug),
        hinweis: p._hinweise[regel],
      ));

  void meldeAn(String regel, _Stelle s, String treffer, String auszug) => melde(regel, s.datei, s.pfad, treffer, auszug);

  /// Muster aus textregeln.json mit {taeter} und {unschuldig} ausgefüllt.
  List<_Muster> muster(List<String> roh) => [
        for (final m in roh)
          if (m.startsWith('{unschuldig}'))
            for (final d in unschuldig) _Muster(m.replaceFirst('{unschuldig}', d))
          else
            _Muster(m.replaceFirst('{taeter}', taeterDatei)),
      ];

  bool passt(List<_Muster> m, _Stelle s) => _passtEins(m, s.datei, s.pfad);

  Iterable<_Stelle> get texte => stellen.where((s) => !s.offen && s.art != KammerLeserArt.struktur);

  String loese(KammerBesetzung b, String text, bool weiblich) {
    if (!text.contains('{')) return text;
    return b.text(text, detektivWeiblich: weiblich, werte: {for (final m in _wertRe.allMatches(text)) m[1]!: ''});
  }

  /// Wird [s] bei Besetzung [b] gedruckt? Rollentexte nur, wenn die Rolle spielt (Karten der Zeugen 5–10
  /// auch, wenn sie fehlen); Frage und Nachschlag nur mit Ziel, das Ausweichziel nur ohne; Solo-Abschnitt nur
  /// ohne Partner; Streifen, Lacher und Aktionskarten-Tipps nur für fehlende Rollen.
  bool gedruckt(_Stelle s, KammerBesetzung b) {
    final rolle = s.rolle;
    if (rolle != null) {
      if (s.pfad.startsWith(r'$.notiz')) return true;
      final besetzt = b.istBesetzt(rolle);
      if (s.art == KammerLeserArt.geheimniskarte || s.art == KammerLeserArt.aktionskarte) {
        return besetzt || inhalt.platzVon(rolle).art == KammerArt.zeuge;
      }
      if (!besetzt) return false;
      final a = _auftragRe.firstMatch(s.pfad);
      if (a != null && const {'frage', 'nachschlag', 'ausweich'}.contains(a[2])) {
        final ziel = inhalt.rolle(rolle).gespraechsauftraege[int.parse(a[1]!)].ziel;
        return (a[2] == 'ausweich') != b.istBesetzt(ziel);
      }
      if (s.pfad.startsWith(r'$.solo')) {
        final pl = inhalt.platzVon(rolle);
        final t = inhalt.fall.tandems.firstWhere((t) => t.nr == pl.tandem);
        return t.plaetze.where((x) => x != pl.platz).every((x) => !b.istBesetzt(inhalt.platz(x).id));
      }
      return true;
    }
    int? index(String vor) => s.pfad.startsWith(vor) ? int.tryParse(_indexRe.firstMatch(s.pfad.substring(vor.length - 1))?[1] ?? '') : null;
    switch (s.datei) {
      case 'abwesenheit.json':
        final i = index(r'$.streifen[');
        return i == null || !b.istBesetzt(inhalt.streifen[i].zeuge);
      case 'erzaehlerheft.json':
        final l = index(r'$.vorstellung.lacherFehlend[');
        if (l != null) return !b.istBesetzt(inhalt.erzaehlerheft.vorstellung.lacherFehlend[l].schluessel);
        final h = index(r'$.skalierung.hinweise[');
        if (h != null) {
          final x = inhalt.erzaehlerheft.skalierungsHinweise[h];
          return b.personen >= x.von && b.personen <= x.bis;
        }
        if (s.pfad.startsWith(r'$.kartenUnterStreifen')) return b.abwesenheitsblatt;
        final f = index(r'$.lageplanFuehrung[');
        if (f != null && inhalt.erzaehlerheft.lageplanFuehrung[f].nurMitStreifen) return b.abwesenheitsblatt;
        return true;
      case 'detektiv.json':
        final t = index(r'$.aktionskartenTipps[');
        return t == null || !b.istBesetzt(inhalt.detektiv.aktionskartenTipps[t].schluessel);
    }
    return true;
  }

  /// Die verschiedenen Fassungen von [s] über alle Besetzungen, bei denen [s] gedruckt wird (beide
  /// Detektiv-Fassungen), mit den Personenzahlen.
  Map<String, List<int>> aufgeloest(_Stelle s) => _aufgeloest.putIfAbsent(s.nr, () {
        final aus = <String, List<int>>{};
        for (final b in besetzung.values) {
          if (!gedruckt(s, b)) continue;
          for (final w in const [false, true]) {
            final l = aus.putIfAbsent(loese(b, s.text, w), () => []);
            if (!l.contains(b.personen)) l.add(b.personen);
            if (!s.text.contains('{')) break;
          }
        }
        return aus;
      });

  /// [s] bei voller Besetzung (Namen statt Platzhalter), beide Detektiv-Fassungen.
  Set<String> vollFassungen(_Stelle s) => {for (final w in const [false, true]) loese(voll, s.text, w)};

  /// [s] bei allen Besetzungen, gedruckt oder nicht.
  Set<String> alleFassungen(_Stelle s) => {
        for (final b in besetzung.values)
          for (final w in const [false, true]) loese(b, s.text, w),
      };

  String personen(List<int> l) {
    final s = [...l]..sort();
    final teile = <String>[];
    var i = 0;
    while (i < s.length) {
      var j = i;
      while (j + 1 < s.length && s[j + 1] == s[j] + 1) {
        j++;
      }
      teile.add(i == j ? '${s[i]}' : '${s[i]}–${s[j]}');
      i = j + 1;
    }
    return teile.join(', ');
  }

  void alles() {
    folgenRegeln();
    tatwort();
    fassungscode();
    indizkarten();
    vorderseiten();
    bedingung();
    kopftuch();
    platzhalter();
    gestalt();
  }

  // ------------------------------------------------------------ Täterwissen und Geheimnisse (Fünf-Wort-Folgen)

  /// Text einer Tatkern-Stelle, wie er als Quelle zählt: Zeitleiste des Täters nur in `zeitleisteNur`,
  /// Felder aus `nurRede` nur ihre wörtliche Rede („…“).
  String zuschnitt(_Stelle s, String text, List<_Muster> rede) {
    final z = _zeitzeileRe.firstMatch(s.pfad);
    if (z != null && s.rolle != null && p._zeitleisteNur.isNotEmpty) {
      final zeile = inhalt.rolle(s.rolle!).fassung?.zeitleiste[int.parse(z[1]!)];
      if (zeile == null || !p._zeitleisteNur.contains(zeile.zeit)) return '';
    }
    if (passt(rede, s)) return [for (final m in _redeRe.allMatches(text)) m[1]!].join('\n');
    return text;
  }

  /// Folge → erste Quelle (Fundort) aus [quellen] bei voller Besetzung.
  Map<String, String> quellFolgen(Iterable<_Stelle> quellen, [String Function(_Stelle, String)? schnitt]) {
    final q = <String, String>{};
    for (final s in quellen) {
      for (final t in vollFassungen(s)) {
        for (final f in kammerSatzFolgen(schnitt == null ? t : schnitt(s, t))) {
          q.putIfAbsent(f, () => s.ort);
        }
      }
    }
    return q;
  }

  Set<String> neutraleFolgen(Iterable<_Stelle> neutral) => {
        for (final s in neutral)
          for (final t in alleFassungen(s)) ...kammerSatzFolgen(t),
      };

  /// Erster verbotener Treffer in den gedruckten Fassungen von [s]: (Folge, Satz, Quelle).
  (String, String, String)? folgenTreffer(_Stelle s, Map<String, String> verboten) {
    for (final t in aufgeloest(s).keys) {
      for (final satz in kammerSaetze(t)) {
        final treffer = fuenfWortFolgen(satz).where(verboten.containsKey).toList()..sort();
        if (treffer.isNotEmpty) return (treffer.first, satz, verboten[treffer.first]!);
      }
    }
    return null;
  }

  late Map<String, String> verbotenTat;

  void folgenRegeln() {
    final tatkern = muster(p._tatkern);
    final rede = muster(p._nurRede);
    final geheim = muster(p._geheimnisquellen);
    final oeffentlich = muster(p._oeffentlich);
    final zeugen = muster(p._zeugenwissen);
    final tatQuellen = [for (final s in texte) if (passt(tatkern, s)) s];
    final tatFolgen = quellFolgen(tatQuellen, (s, t) => zuschnitt(s, t, rede));
    final neutralO = neutraleFolgen(texte.where((s) => passt(oeffentlich, s)));
    final neutralZ = neutraleFolgen(texte.where((s) => passt(zeugen, s)));
    Map<String, String> ohne(Map<String, String> q, Set<String> n, String regel) => {
          for (final e in q.entries)
            if (!n.contains(e.key) && !(p.erlaubteFolgen[regel]?.containsKey(e.key) ?? false)) e.key: e.value,
        };
    verbotenTat = ohne(tatFolgen, {...neutralO, ...neutralZ}, KammerLeserRegel.taeterwissen);
    final geheimQuellen = [for (final s in texte) if (passt(geheim, s) || passt(tatkern, s)) s];
    final verbotenGeheim = ohne(
      {...quellFolgen(geheimQuellen.where((s) => !passt(tatkern, s))), ...tatFolgen},
      neutralO,
      KammerLeserRegel.geheimnis,
    );

    const tatLeser = {
      KammerLeserArt.alle,
      KammerLeserArt.erzaehler,
      KammerLeserArt.detektiv,
      KammerLeserArt.tisch,
      KammerLeserArt.streifen,
      KammerLeserArt.heft,
      KammerLeserArt.fassungAussen,
      KammerLeserArt.karteAussen,
    };
    const geheimLeser = {
      KammerLeserArt.alle,
      KammerLeserArt.erzaehler,
      KammerLeserArt.detektiv,
      KammerLeserArt.tisch,
      KammerLeserArt.fassungAussen,
      KammerLeserArt.karteAussen,
    };
    bool beschriftung(_Stelle s) => s.datei.startsWith('ui/') && s.art != KammerLeserArt.aufloesung;
    for (final s in texte) {
      final quelle = passt(tatkern, s) || passt(oeffentlich, s) || passt(zeugen, s);
      if (!quelle && (s.hat(tatLeser) || beschriftung(s)) && s.art != KammerLeserArt.aufloesung && s.art != KammerLeserArt.fassung) {
        final t = folgenTreffer(s, verbotenTat);
        if (t != null) meldeAn(KammerLeserRegel.taeterwissen, s, t.$1, '${t.$2} ← ${t.$3}');
      }
      // Fassungen der Unschuldigen: keine Tat (E9).
      if (s.art == KammerLeserArt.fassung && s.rolle != null && unschuldig.contains(s.datei)) {
        final t = folgenTreffer(s, verbotenTat);
        if (t != null) meldeAn(KammerLeserRegel.gestaltTat, s, t.$1, '${t.$2} ← ${t.$3}');
      }
      final geheimQuelle = passt(geheim, s) || passt(tatkern, s) || passt(oeffentlich, s);
      if (!geheimQuelle && (s.hat(geheimLeser) || beschriftung(s)) && s.art != KammerLeserArt.aufloesung) {
        final t = folgenTreffer(s, verbotenGeheim);
        if (t != null) meldeAn(KammerLeserRegel.geheimnis, s, t.$1, '${t.$2} ← ${t.$3}');
      }
    }
    // Zeugenstreifen: nicht das eigene Geheimnis (Stufe 2, Geheimniskarte) des Zeugen (E7).
    for (final str in inhalt.streifen) {
      final datei = inhalt.platzVon(str.zeuge).datei;
      final eigen = ohne(
        quellFolgen(texte.where((s) => s.datei == datei && passt(geheim, s) && !s.pfad.startsWith(r'$.teil90'))),
        neutralO,
        KammerLeserRegel.geheimnis,
      );
      final i = inhalt.streifen.indexOf(str);
      for (final s in texte) {
        if (s.datei != 'abwesenheit.json' || !s.pfad.startsWith('\$.streifen[$i]')) continue;
        final t = folgenTreffer(s, eigen);
        if (t != null) meldeAn(KammerLeserRegel.geheimnis, s, t.$1, '${t.$2} ← ${t.$3}');
      }
    }
  }

  // ------------------------------------------------------------ Wörter der Tat, Codes

  void tatwort() {
    final tatkern = muster(p._tatkern);
    for (final s in texte) {
      if (s.art == KammerLeserArt.aufloesung || passt(tatkern, s) || (s.art == KammerLeserArt.fassung && s.datei == taeterDatei)) continue;
      final regel = s.art == KammerLeserArt.fassung && unschuldig.contains(s.datei) ? KammerLeserRegel.gestaltTat : KammerLeserRegel.tatwort;
      for (final t in aufgeloest(s).keys) {
        final w = p._tatwoerter.treffer(t);
        if (w != null) {
          meldeAn(regel, s, w, t);
          break;
        }
      }
    }
    // Ollis Stufe 3 gesteht (nur RN7 enthält die Tat).
    final stufe3 = stellen.where((s) => s.datei == taeterDatei && s.pfad == r'$.fassung.stufe3' && !s.offen);
    for (final s in stufe3) {
      if (vollFassungen(s).every((t) => p._tatwoerter.treffer(t) == null)) {
        meldeAn(KammerLeserRegel.gestaltTat, s, inhalt.fall.taeter, s.text);
      }
    }
  }

  void fassungscode() {
    for (final s in texte) {
      if (s.art == KammerLeserArt.aufloesung) continue;
      final m = fassungsCodeRe.firstMatch(s.text);
      if (m != null) meldeAn(KammerLeserRegel.fassungscode, s, m[1]!, s.text);
    }
  }

  // ------------------------------------------------------------ Indizkarten

  /// Rollen-IDs mit Namen in [text]; [nurNominativ]: ohne Genitiv („Ollis“).
  List<String> namenIn(String text, {bool nurNominativ = false}) => [
        for (final e in namen.entries)
          if (e.value.allMatches(text).any((m) => !nurNominativ || m[1] == null)) e.key,
      ];

  void indizkarten() {
    final karten = inhalt.indizkarten.karten;
    String? codeVon(_Stelle s) {
      final m = RegExp(r'^\$\.karten\[(\d+)\]').firstMatch(s.pfad);
      return m == null ? null : karten[int.parse(m[1]!)].code;
    }

    final fundortKarten = {
      for (final k in karten)
        if (k.vermerke.any((v) => _woerter(v).contains(p._fundort))) k.code,
    };
    for (final s in texte) {
      if (s.datei != 'indizkarten.json') continue;
      final code = codeVon(s);
      for (final t in vollFassungen(s)) {
        final n = namenIn(t);
        if (code != null && p._ohneNamen.contains(code) && n.isNotEmpty) {
          meldeAn(KammerLeserRegel.indizName, s, inhalt.platzVon(n.first).name, t);
        }
        if (s.pfad.contains('.vermerke[') && p._urteil.treffer(t) != null && n.isNotEmpty) {
          meldeAn(KammerLeserRegel.indizName, s, inhalt.platzVon(n.first).name, t);
        }
        final g = p._gestaendnis.treffer(t);
        if (g != null) meldeAn(KammerLeserRegel.indizGestaendnis, s, g, t);
        for (final satz in kammerSaetze(t)) {
          final w = p._wahrnehmung.treffer(satz);
          final wer = namenIn(satz, nurNominativ: true);
          if (w != null && wer.isNotEmpty) meldeAn(KammerLeserRegel.indizGestaendnis, s, '${inhalt.platzVon(wer.first).name} $w', satz);
        }
        final sp = p._spoiler.treffer(t);
        if (sp != null) meldeAn(KammerLeserRegel.indizWort, s, sp, t);
        if (code != null && fundortKarten.contains(code)) {
          final r = p._fundortOhne.treffer(t);
          if (r != null) meldeAn(KammerLeserRegel.indizWort, s, r, t);
        }
      }
    }
  }

  // ------------------------------------------------------------ Außenseiten und Bedingung (E8)

  void vorderseiten() {
    for (final v in p._vorderseiten) {
      final teil = v.datei.substring(3, v.datei.length - 5);
      final pfad = _uiPfad(v.schluessel);
      final text = inhalt.ui[teil]?[v.schluessel];
      if (text == null) {
        melde(KammerLeserRegel.vorderseite, v.datei, pfad, v.schluessel, v.datei);
        continue;
      }
      if (p.unvollstaendig(text)) continue;
      for (final m in _wertRe.allMatches(text)) {
        if (!v.werte.contains(m[1])) melde(KammerLeserRegel.vorderseite, v.datei, pfad, m[0]!, text);
      }
      final rollen = kammerTextRollen(text);
      if (rollen.isNotEmpty) melde(KammerLeserRegel.vorderseite, v.datei, pfad, rollen.first, text);
      final n = namenIn(text);
      if (n.isNotEmpty) melde(KammerLeserRegel.vorderseite, v.datei, pfad, inhalt.platzVon(n.first).name, text);
      final c = codeRe.firstMatch(text);
      if (c != null) melde(KammerLeserRegel.vorderseite, v.datei, pfad, c[1]!, text);
      final b = p._bedingung.treffer(text);
      if (b != null) melde(KammerLeserRegel.vorderseite, v.datei, pfad, b, text);
    }
  }

  /// Auf der Geheimniskarte steht kein Bedingungswort und keiner ihrer eigenen Pflicht-Codes; ein Verweis auf
  /// eine andere Karte („Vergleiche die Bogentür (YT4)“) ist keine Bedingung. Jedes Heft nennt Auslöser.
  void bedingung() {
    for (final s in texte) {
      if (s.art != KammerLeserArt.geheimniskarte || s.rolle == null) continue;
      final eigene = inhalt.rolle(s.rolle!).geheimniskarte.pflichtCodes.toSet();
      for (final t in aufgeloest(s).keys) {
        final b = p._bedingung.treffer(t) ?? [for (final m in codeRe.allMatches(t)) if (eigene.contains(m[1])) m[1]!].firstOrNull;
        if (b != null) {
          meldeAn(KammerLeserRegel.bedingung, s, b, t);
          break;
        }
      }
    }
    for (final r in inhalt.rollen) {
      final a = r.stufe2.ausloeser;
      if (a.isEmpty) melde(KammerLeserRegel.bedingung, inhalt.platzVon(r.id).datei, r'$.stufe2.ausloeser', '0', r.id);
    }
  }

  // ------------------------------------------------------------ Kopftuch-Regel (E11)

  /// Wert unter einem Datenpfad (`a.b.c`) in einem JSON-Objekt.
  Object? wert(Object? json, String pfad) {
    Object? v = json;
    for (final teil in pfad.split('.')) {
      if (v is! Map) return null;
      v = v[teil];
    }
    return v;
  }

  bool enthaeltOffen(Object? v) => switch (v) {
        String s => p.unvollstaendig(s),
        List l => l.any(enthaeltOffen),
        Map m => m.values.any(enthaeltOffen),
        _ => false,
      };

  void kopftuch() {
    final k = p._kopftuch;
    final id = k['rolle'] as String;
    final datei = inhalt.platzVon(id).datei;
    final r = inhalt.rolle(id);
    final roh = json[datei];
    final erlaubt = _texte(k['vermerkeErlaubt']).toSet();
    for (final (i, v) in r.geheimniskarte.vermerke.indexed) {
      if (!p.unvollstaendig(v) && !erlaubt.contains(v)) melde(KammerLeserRegel.kopftuch, datei, '\$.geheimniskarte.vermerke[$i]', v, v);
    }
    if (r.geheimniskarte.sperre != k['sperre']) {
      melde(KammerLeserRegel.kopftuch, datei, r'$.geheimniskarte.sperre', '${r.geheimniskarte.sperre}', id);
    }
    for (final f in _texte(k['leer'])) {
      final v = wert(roh, f);
      if (v is List) {
        for (final (i, e) in v.indexed) {
          if (!enthaeltOffen(e)) melde(KammerLeserRegel.kopftuch, datei, '${_datenPfad(f)}[$i]', '$e', '$e');
        }
      }
    }
    // Ohne Text, außer dem wörtlichen Satz der Bibel (ZR 8.6: „Du hast nichts zu verbergen. …“).
    final ausser = {for (final e in ((k['ohneTextAusser'] as Map?) ?? const {}).entries) e.key as String: _texte(e.value).toSet()};
    for (final f in _texte(k['ohneText'])) {
      final v = wert(roh, f);
      if (v is String && !p.unvollstaendig(v) && !(ausser[f]?.contains(v) ?? false)) melde(KammerLeserRegel.kopftuch, datei, _datenPfad(f), v, v);
    }
    if (r.marker.behauptet2357 != r.marker.wahr2357 || r.marker.behauptetScheppern != r.marker.wahrScheppern) {
      melde(KammerLeserRegel.kopftuch, datei, r'$.marker', '${r.marker.behauptet2357}/${r.marker.behauptetScheppern}', r.marker.zeile);
    }
    // Kein belastendes Wort in einem Satz mit ihrem Namen, in keinem Text.
    final name = namen[id]!;
    for (final s in texte) {
      for (final t in vollFassungen(s)) {
        for (final satz in kammerSaetze(t)) {
          if (!name.hasMatch(satz)) continue;
          final b = p._belastend.treffer(satz);
          if (b != null) meldeAn(KammerLeserRegel.kopftuch, s, b, satz);
        }
      }
    }
  }

  // ------------------------------------------------------------ Platzhalter (WELT 0.2)

  void platzhalter() {
    const ziel = {
      KammerLeserArt.alle,
      KammerLeserArt.erzaehler,
      KammerLeserArt.detektiv,
      KammerLeserArt.tisch,
      KammerLeserArt.heft,
      KammerLeserArt.fassung,
      KammerLeserArt.fassungAussen,
      KammerLeserArt.indizkarte,
      KammerLeserArt.geheimniskarte,
      KammerLeserArt.aktionskarte,
      KammerLeserArt.karteAussen,
      KammerLeserArt.aufloesung,
    };
    final zeugeBis = inhalt.fall.plaetze.where((x) => x.art == KammerArt.zeuge).map((x) => x.platz).fold(0, (a, b) => a > b ? a : b);
    for (final s in texte) {
      if (!ziel.contains(s.art)) continue;
      final fehlend = <String, List<int>>{};
      final auszug = <String, String>{};
      for (final e in aufgeloest(s).entries) {
        for (final id in namenIn(e.key)) {
          final pl = inhalt.platzVon(id);
          if (pl.art == KammerArt.verdaechtig) continue;
          for (final n in e.value) {
            final b = besetzung[n]!;
            if (b.istBesetzt(id)) continue;
            // Teil 90 nennt Zeugen 5–10 immer (MECH 8.3), Karten fehlender Zeugen auch (MECH 5.3).
            if (pl.platz <= zeugeBis && s.art == KammerLeserArt.aufloesung) continue;
            final karte = s.art == KammerLeserArt.geheimniskarte || s.art == KammerLeserArt.aktionskarte;
            if (pl.platz <= zeugeBis && karte && s.rolle != null && !b.istBesetzt(s.rolle!)) continue;
            (fehlend[id] ??= []).add(n);
            auszug[id] ??= e.key;
          }
        }
      }
      for (final e in fehlend.entries) {
        meldeAn(KammerLeserRegel.platzhalter, s, inhalt.platzVon(e.key).name, '[${personen(e.value.toSet().toList())}] ${auszug[e.key]}');
      }
    }
  }

  // ------------------------------------------------------------ Gleiche Gestalt der vier (E9)

  List<KammerPlatz> get vier => [for (final x in inhalt.fall.plaetze) if (x.art == KammerArt.verdaechtig) x];

  void gestalt() {
    gliederung();
    laengen();
    schluss();
    aktion();
  }

  /// Gestalt einer Rollendatei: Pfad → Form; Listen mit unvollständigen Texten gelten als offen.
  void signatur(Object? v, String pfad, Map<String, String> sig, Set<String> offen) {
    bool gleicherWert(String pf) => p._gleicheWerte.any((r) => r.hasMatch(pf));
    switch (v) {
      case String s:
        if (p.unvollstaendig(s)) {
          offen.add(pfad);
        } else {
          sig[pfad] = gleicherWert(pfad) ? 'wert=$s' : 'text';
        }
      case null:
        sig[pfad] = 'null';
      case num n:
        sig[pfad] = 'zahl=$n';
      case bool b:
        sig[pfad] = 'ja=$b';
      case List l:
        if (l.any(enthaeltOffen)) {
          offen.add(pfad);
          return;
        }
        sig[pfad] = 'liste=${l.length}';
        for (final (i, e) in l.indexed) {
          signatur(e, '$pfad[$i]', sig, offen);
        }
      case Map m:
        sig[pfad] = 'objekt';
        for (final k in m.keys.map((k) => '$k').toList()..sort()) {
          signatur(m[k], _bezeichnerRe.hasMatch(k) ? '$pfad.$k' : '$pfad[${jsonEncode(k)}]', sig, offen);
        }
    }
  }

  bool unter(String pfad, String vor) => pfad == vor || pfad.startsWith('$vor.') || pfad.startsWith('$vor[');

  void gliederung() {
    final sig = <String, Map<String, String>>{};
    final offen = <String, Set<String>>{};
    for (final x in vier) {
      signatur(json[x.datei], r'$', sig[x.datei] = {}, offen[x.datei] = {});
    }
    final alleOffen = {for (final o in offen.values) ...o};
    if (alleOffen.isNotEmpty) ausgelassen.add('${KammerLeserRegel.gestaltGliederung} · ${alleOffen.length}');
    final pfade = {for (final s in sig.values) ...s.keys}.toList()..sort();
    final gemeldet = <String>[];
    for (final pfad in pfade) {
      if (alleOffen.any((o) => unter(pfad, o)) || p._ungleichErlaubt.any((r) => r.hasMatch(pfad))) continue;
      if (gemeldet.any((g) => unter(pfad, g))) continue;
      final werte = {for (final x in vier) x.datei: sig[x.datei]![pfad] ?? '-'};
      final zaehler = <String, int>{};
      for (final w in werte.values) {
        zaehler[w] = (zaehler[w] ?? 0) + 1;
      }
      if (zaehler.length < 2) continue;
      final mehrheit = (zaehler.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
      for (final e in werte.entries) {
        if (e.value != mehrheit) melde(KammerLeserRegel.gestaltGliederung, e.key, pfad, e.value, '${e.value} ≠ $mehrheit');
      }
      gemeldet.add(pfad);
    }
    // Feste Zahl an Einträgen (RK 1.1, RK 8.2) und Spielraum der Zeitleiste (RK 7.1).
    final anzahl = (p._gestalt['anzahl'] as Map).cast<String, Object?>();
    final spielraum = (p._gestalt['spielraum'] as Map).cast<String, Object?>();
    for (final x in vier) {
      void pruefe(String f, int von, int bis) {
        final v = wert(json[x.datei], f);
        if (v is! List) return;
        if (v.any(enthaeltOffen)) return;
        if (v.length < von || v.length > bis) {
          melde(KammerLeserRegel.gestaltGliederung, x.datei, _datenPfad(f), '${v.length}', von == bis ? '${v.length} ≠ $von' : '${v.length} ∉ $von–$bis');
        }
      }

      for (final e in anzahl.entries) {
        pruefe(e.key, e.value as int, e.value as int);
      }
      for (final e in spielraum.entries) {
        final r = (e.value as List).cast<int>();
        pruefe(e.key, r.first, r.last);
      }
    }
  }

  void laengen() {
    for (final z in p._laengen) {
      final zahl = <String, int>{};
      final erster = <String, String>{};
      var offen = false;
      for (final x in vier) {
        var n = 0;
        for (final s in stellen) {
          if (s.datei != x.datei || s.art == KammerLeserArt.struktur) continue;
          if (!z.felder.any((r) => r.hasMatch(s.pfad)) || p._laengenOhne.any((r) => r.hasMatch(s.pfad))) continue;
          if (s.offen) {
            offen = true;
            break;
          }
          erster[x.datei] ??= s.pfad;
          n += _zaehle(loese(voll, s.text, false));
        }
        zahl[x.datei] = n;
      }
      if (offen) {
        ausgelassen.add('${KammerLeserRegel.gestaltLaenge} · ${z.name}');
        continue;
      }
      final mittel = zahl.values.fold(0, (a, b) => a + b) / zahl.length;
      if (mittel == 0) continue;
      for (final e in zahl.entries) {
        final abw = (e.value - mittel) / mittel;
        if (abw.abs() > p._toleranz + 1e-9) {
          final vorzeichen = abw >= 0 ? '+' : '';
          final prozent = '$vorzeichen${_komma(abw * 100)} %';
          final alle = [for (final x in vier) zahl[x.datei]].join(' · ');
          melde(KammerLeserRegel.gestaltLaenge, e.key, erster[e.key] ?? r'$', prozent, '${z.name}: ${e.value} / ${_komma(mittel)} ($alle)');
        }
      }
    }
  }

  void schluss() {
    final satz = p._gestalt['schlusssatz'] as String;
    final nurFassung = _texte(p._gestalt['nurInFassungen']);
    for (final x in vier) {
      final ab = inhalt.rolle(x.id).stufe2.abDann;
      if (ab != null && !p.unvollstaendig(ab) && !loese(voll, ab, false).trim().endsWith(satz)) {
        melde(KammerLeserRegel.gestaltSchluss, x.datei, r'$.stufe2.abDann', satz, ab);
      }
      if (ab != null && p.unvollstaendig(ab)) ausgelassen.add('${KammerLeserRegel.gestaltSchluss} · ${x.id}');
    }
    for (final s in texte) {
      if (s.art != KammerLeserArt.heft || !vier.any((x) => x.datei == s.datei)) continue;
      for (final t in vollFassungen(s)) {
        final klein = t.toLowerCase();
        for (final f in nurFassung) {
          if (klein.contains(f.toLowerCase())) meldeAn(KammerLeserRegel.gestaltSchluss, s, f, t);
        }
      }
    }
  }

  void aktion() {
    final klasse = (p._gestalt['aktion'] as Map)['klasse'] as String;
    final karten = {for (final x in vier) x.datei: inhalt.rolle(x.id).aktionskarte};
    String mehrheit(Iterable<String> w) {
      final z = <String, int>{};
      for (final x in w) {
        z[x] = (z[x] ?? 0) + 1;
      }
      return (z.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
    }

    final runde = mehrheit(karten.values.map((k) => '${k.abRunde}'));
    final grenzen = mehrheit(karten.values.map((k) => k.grenzen));
    for (final e in karten.entries) {
      final k = e.value;
      if (k.klasse.name != klasse) melde(KammerLeserRegel.gestaltAktion, e.key, r'$.aktionskarte.klasse', k.klasse.name, '${k.klasse.name} ≠ $klasse');
      if ('${k.abRunde}' != runde) melde(KammerLeserRegel.gestaltAktion, e.key, r'$.aktionskarte.abRunde', '${k.abRunde}', '${k.abRunde} ≠ $runde');
      if (!p.unvollstaendig(k.grenzen) && k.grenzen != grenzen) melde(KammerLeserRegel.gestaltAktion, e.key, r'$.aktionskarte.grenzen', k.name, k.grenzen);
      for (final (feld, text) in [('name', k.name), ('wirkung', k.wirkung), ('grenzen', k.grenzen), ('tipp', k.tipp)]) {
        if (p.unvollstaendig(text)) continue;
        final w = p._verraeterisch.treffer(text);
        if (w != null) melde(KammerLeserRegel.gestaltAktion, e.key, '\$.aktionskarte.$feld', w, text);
      }
    }
  }
}
