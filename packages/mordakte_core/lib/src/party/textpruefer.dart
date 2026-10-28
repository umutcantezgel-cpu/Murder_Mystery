// Textprüfer und Textlint des Partymodus (F3-BAUMEISTER-01, TON-LEITFADEN §4–§6).
// Reines Dart ohne dart:io. Wortlisten kommen aus content/party/textregeln.json.
import 'dart:math';

import 'kanon/kanon.dart';
import 'texte.dart';

/// Ein Text, den Spielende sehen oder hören. `ort` ist die Fundstelle, z. B. `beobachtungen.json#b_hana_wachs`.
class TextQuelle {
  final String ort;
  final String text;
  final bool vorlesen;
  const TextQuelle({required this.ort, required this.text, required this.vorlesen});
}

/// Ein Befund an einer Fundstelle: verletzte Regel und Ausschnitt.
class TextBefund {
  final String ort;
  final String regel;
  final String auszug;
  const TextBefund({required this.ort, required this.regel, required this.auszug});
}

/// Ein Wort in Kleinschreibung mit seiner Lage im Text. Bindestriche verbinden (E-Zigarette).
class _Wort {
  final String klein;
  final int anfang, ende;
  const _Wort(this.klein, this.anfang, this.ende);
}

/// Ein Fachwort als Wortfolge (z. B. „smoking gun“) mit Ersatz.
class _Fach {
  final List<String> folge;
  final String ersatz;
  const _Fach(this.folge, this.ersatz);

  bool passtAb(List<_Wort> worte, int i) => _passtAb(worte, i, folge);
}

/// Stimmt die Wortfolge ab Position [i] mit [folge] überein?
bool _passtAb(List<_Wort> worte, int i, List<String> folge) {
  if (i + folge.length > worte.length) return false;
  for (var k = 0; k < folge.length; k++) {
    if (worte[i + k].klein != folge[k]) return false;
  }
  return true;
}

/// Eine Ausnahme: ohne Kontext ein Wortanfang („weinrot“), mit Kontext („kater:katze“)
/// nur das ganze Wort und nur, wenn im selben Satz ein Wort mit dem Kontext steht.
class _Ausnahme {
  final String stamm;
  final String? kontext;
  _Ausnahme(String eintrag)
      : stamm = eintrag.split(':').first.toLowerCase(),
        kontext = eintrag.contains(':') ? eintrag.split(':').last.toLowerCase() : null;
}

/// Ein alter Personenname aus `figuren.json` (quelle.name), der in Texten nicht mehr stehen darf.
class _Altname {
  final List<String> folge;
  final String name, heute;
  const _Altname(this.folge, this.name, this.heute);
}

final _wortRe = RegExp(r'[\p{L}\p{N}]+(?:-[\p{L}\p{N}]+)*', unicode: true);
final _buchstabeRe = RegExp(r'\p{L}', unicode: true);
final _ziffernRe = RegExp('[0-9]+');
final _klammernRe = RegExp(r'[()\[\]{}]+');
final _zeitRe = RegExp(r'(?<![\d:])([01]?\d|2[0-3]):([0-5]\d)(?!\d)');

const _satzzeichen = {'.', '!', '?', '…'};
const _schliessend = {'"', '”', '“', '’', "'", '»', ')', ']'};
const _oeffnend = {'"', '„', '“', '‚', '‘', '«', '(', '['};

List<_Wort> _worte(String s) => [
      for (final m in _wortRe.allMatches(s)) _Wort(m.group(0)!.toLowerCase(), m.start, m.end),
    ];

bool _buchstabe(String c) => _buchstabeRe.hasMatch(c);

bool _grossbuchstabe(String c) => _buchstabe(c) && c == c.toUpperCase() && c != c.toLowerCase();

String _schluessel(String stunde, String minute) => '${int.parse(stunde)}:$minute';

List<String> _liste(Object? v) => [for (final x in (v as List? ?? const [])) (x as String).toLowerCase()];

Map<String, Object?> _abschnitt(Map<String, Object?> regeln, String name) =>
    (regeln[name] as Map?)?.cast<String, Object?>() ?? const {};

String _escape(String s) => s.replaceAllMapped(RegExp(r'[.*+?^${}()|\[\]\\]'), (m) => '\\${m[0]}');

/// Ausschnitt rund um eine Fundstelle, für die Befundliste.
String _ausschnitt(String text, int anfang, int ende) {
  final a = max(0, anfang - 40);
  final e = min(text.length, ende + 40);
  return '${a > 0 ? '…' : ''}${text.substring(a, e).trim()}${e < text.length ? '…' : ''}';
}

String _kurz(String s) => s.length <= 90 ? s : '${s.substring(0, 87)}…';

String _wortVor(String s, int i) {
  var a = i;
  while (a > 0 && _buchstabe(s[a - 1])) {
    a--;
  }
  return s.substring(a, i);
}

/// Prüft Spielertexte gegen den TON-LEITFADEN: Satzlängen (§4), Fachwörter (§5),
/// Alkohol, Drogen, Rauchen (§6) und in Vorlesetexten Abkürzungen, Klammern, Ziffern (§4).
class Textpruefer {
  final Map<String, List<_Fach>> _fach = {};
  final List<String> _alkohol;
  final Set<String> _drogen;
  final Set<String> _rauchen;
  final List<_Ausnahme> _ausnahmen;
  final List<String> _abkuerzungen;
  final Set<String> _abkuerzungKurz;
  final bool _klammern, _ziffern;
  final int _mittelHoechstens, _hoechstens;

  Textpruefer(Map<String, Object?> regeln)
      : _alkohol = _liste(_abschnitt(regeln, 'verboten')['alkohol']),
        _drogen = _liste(_abschnitt(regeln, 'verboten')['drogen']).toSet(),
        _rauchen = _liste(_abschnitt(regeln, 'verboten')['rauchen']).toSet(),
        _ausnahmen = [for (final e in _liste(regeln['ausnahmen'])) _Ausnahme(e)],
        _abkuerzungen = [for (final a in (_abschnitt(regeln, 'vorlesen')['abkuerzungen'] as List? ?? const [])) a as String],
        _abkuerzungKurz = {
          for (final a in _liste(_abschnitt(regeln, 'vorlesen')['abkuerzungen'])) a.replaceAll(RegExp(r'[\s.]'), ''),
        },
        _klammern = _abschnitt(regeln, 'vorlesen')['klammern'] == true,
        _ziffern = _abschnitt(regeln, 'vorlesen')['ziffern'] == true,
        _mittelHoechstens = _abschnitt(regeln, 'saetze')['mittelHoechstens'] as int,
        _hoechstens = _abschnitt(regeln, 'saetze')['hoechstens'] as int {
    for (final e in (regeln['fachwoerter'] as Map? ?? const {}).entries) {
      final folge = [for (final w in _worte(e.key as String)) w.klein];
      if (folge.isNotEmpty) (_fach[folge.first] ??= []).add(_Fach(folge, e.value as String));
    }
  }

  /// Zahl der Wörter eines Satzes. Zahlen zählen mit.
  int woerter(String satz) => _worte(satz).length;

  /// Teilt einen Text in Sätze. Satzende ist `. ! ? …` (auch `...`), gefolgt von Leerraum und
  /// einem Großbuchstaben, einer öffnenden Anführung oder dem Textende. Schließende Anführungszeichen
  /// und Klammern gehören zum Satz. Abkürzungen (`ca.`, `z. B.`, `Nr.`), Initialen (`B.`) und
  /// Ordnungszahlen (`3.`) trennen nicht. Ein Auslassungspunkt vor Kleinschreibung trennt nicht.
  List<String> saetze(String text) {
    final ergebnis = <String>[];
    var anfang = 0;
    var i = 0;
    while (i < text.length) {
      if (!_satzzeichen.contains(text[i])) {
        i++;
        continue;
      }
      var j = i;
      while (j < text.length && _satzzeichen.contains(text[j])) {
        j++;
      }
      var k = j;
      while (k < text.length && _schliessend.contains(text[k])) {
        k++;
      }
      if (_satzende(text, i, j, k)) {
        final satz = text.substring(anfang, k).trim();
        if (satz.isNotEmpty) ergebnis.add(satz);
        anfang = k;
      }
      i = j;
    }
    final rest = text.substring(anfang).trim();
    if (rest.isNotEmpty) ergebnis.add(rest);
    return ergebnis;
  }

  bool _satzende(String s, int i, int j, int k) {
    if (k >= s.length) return true;
    if (s[k].trim().isNotEmpty) return false;
    var m = k;
    while (m < s.length && s[m].trim().isEmpty) {
      m++;
    }
    if (m >= s.length) return true;
    if (!_grossbuchstabe(s[m]) && !_oeffnend.contains(s[m])) return false;
    if (j - i == 1 && s[i] == '.') {
      if (i > 0 && _ziffernRe.hasMatch(s[i - 1])) return false;
      final wort = _wortVor(s, i).toLowerCase();
      if (wort.length == 1 || _abkuerzungKurz.contains(wort)) return false;
    }
    return true;
  }

  /// Befunde eines einzelnen Textes: Satzlänge, Fachwörter, Verbote und in Vorlesetexten Zeichen.
  List<TextBefund> pruefe(TextQuelle q) {
    final f = <TextBefund>[];
    for (final satz in saetze(q.text)) {
      final worte = _worte(satz);
      if (worte.length > _hoechstens) {
        f.add(TextBefund(ort: q.ort, regel: 'Satzlänge', auszug: '${worte.length} Wörter: ${_kurz(satz)}'));
      }
      f.addAll(_wortBefunde(q.ort, satz, worte));
    }
    if (q.vorlesen) f.addAll(_vorlesBefunde(q));
    return f;
  }

  List<TextBefund> _wortBefunde(String ort, String satz, List<_Wort> worte) {
    final f = <TextBefund>[];
    for (var i = 0; i < worte.length; i++) {
      final w = worte[i];
      for (final fw in _fach[w.klein] ?? const <_Fach>[]) {
        if (fw.passtAb(worte, i)) {
          final ende = worte[i + fw.folge.length - 1].ende;
          f.add(TextBefund(ort: ort, regel: 'Fachwort, Ersatz: ${fw.ersatz}', auszug: _ausschnitt(satz, w.anfang, ende)));
        }
      }
      final art = _art(w.klein);
      if (art != null && !_ausgenommen(w, worte)) {
        f.add(TextBefund(ort: ort, regel: art, auszug: _ausschnitt(satz, w.anfang, w.ende)));
      }
    }
    return f;
  }

  /// Welche Verbotsliste trifft das Wort? Alkohol auch als Wortanfang, Drogen und Rauchen nur ganz.
  String? _art(String klein) {
    if (_alkohol.any((v) => klein.startsWith(v))) return 'Alkohol';
    if (_drogen.contains(klein)) return 'Drogen';
    if (_rauchen.contains(klein)) return 'Rauchen';
    return null;
  }

  bool _ausgenommen(_Wort w, List<_Wort> worte) => _ausnahmen.any((a) => a.kontext == null
      ? w.klein.startsWith(a.stamm)
      : w.klein == a.stamm && worte.any((x) => x.klein.startsWith(a.kontext!)));

  List<TextBefund> _vorlesBefunde(TextQuelle q) {
    final f = <TextBefund>[];
    for (final a in _abkuerzungen) {
      final re = RegExp('(?<!\\p{L})${_escape(a)}(?!\\p{L})', unicode: true, caseSensitive: false);
      for (final m in re.allMatches(q.text)) {
        f.add(TextBefund(ort: q.ort, regel: 'Abkürzung (nur Vorlesen)', auszug: _ausschnitt(q.text, m.start, m.end)));
      }
    }
    if (_klammern) {
      for (final m in _klammernRe.allMatches(q.text)) {
        f.add(TextBefund(ort: q.ort, regel: 'Klammer (nur Vorlesen)', auszug: _ausschnitt(q.text, m.start, m.end)));
      }
    }
    if (_ziffern) {
      for (final m in _ziffernRe.allMatches(q.text)) {
        f.add(TextBefund(ort: q.ort, regel: 'Ziffer (nur Vorlesen)', auszug: _ausschnitt(q.text, m.start, m.end)));
      }
    }
    return f;
  }

  /// Mittelwert der Wörter je Satz über alle Texte eines Bereichs (Datei). Mehr als 14 meldet.
  List<TextBefund> pruefeMittel(String bereich, List<TextQuelle> quellen) {
    var worte = 0;
    var anzahl = 0;
    for (final q in quellen) {
      for (final satz in saetze(q.text)) {
        worte += woerter(satz);
        anzahl++;
      }
    }
    if (anzahl == 0) return const [];
    final mittel = worte / anzahl;
    if (mittel <= _mittelHoechstens) return const [];
    return [
      TextBefund(
        ort: bereich,
        regel: 'Mittelwert',
        auszug: 'Mittel ${mittel.toStringAsFixed(1).replaceAll('.', ',')} Wörter je Satz über $anzahl Sätze (höchstens $_mittelHoechstens)',
      ),
    ];
  }
}

/// Alle Texte, die Spielende sehen oder hören (texte/SCHLUESSEL.md, Abschnitt Sichtbarkeit).
/// Vorlesen tragen der Erzähler und die Bonus-Hinweise, die er spricht; Dossiers, Täterfassungen, Gespräche, Wahlen
/// und die übrigen Kanon-Felder sind Lesetext. Im Bereich `einfluss` entscheidet der Schlüssel
/// ([einflussVorlesetext]): Folgen, Ereignisse, Ende und Epiloge liest der Erzähler, Karten sind Lesetext.
List<TextQuelle> textQuellen(Kanon kanon, Textsammlung t) {
  final q = <TextQuelle>[];
  void add(String ort, Object? text, {bool vorlesen = false}) {
    if (text is String && text.trim().isNotEmpty) q.add(TextQuelle(ort: ort, text: text, vorlesen: vorlesen));
  }

  for (final e in t.bausteine.entries) {
    final datei = t.herkunft[e.key]!;
    final bereich = t.dateien[datei]!['bereich'];
    add('$datei#${e.key}', e.value, vorlesen: bereich == 'erzaehler' || (bereich == 'einfluss' && einflussVorlesetext(e.key)));
  }
  for (final e in t.dossiers.entries) {
    final d = e.value;
    final o = '${t.herkunft['dossier.${e.key}']}#dossier.${e.key}';
    add('$o.wer', d.wer);
    add('$o.ziel', d.ziel);
    add('$o.besetzung', d.besetzung);
    for (var i = 0; i < d.weiss.length; i++) {
      add('$o.weiss[$i]', d.weiss[i].text);
    }
    for (var i = 0; i < d.verbirgt.length; i++) {
      add('$o.verbirgt[$i]', d.verbirgt[i].text);
    }
  }
  for (final e in t.taeter.entries) {
    final x = e.value;
    final o = '${t.herkunft['taeter.${e.key}']}#taeter.${e.key}';
    add('$o.tarnung', x.tarnung);
    add('$o.ziel', x.ziel);
    for (var i = 0; i < x.tatwissen.length; i++) {
      add('$o.tatwissen[$i]', x.tatwissen[i].text);
    }
    for (var i = 0; i < x.verbirgt.length; i++) {
      add('$o.verbirgt[$i]', x.verbirgt[i].text);
    }
  }
  for (final g in t.gespraeche) {
    final o = '${t.herkunft[g.id]}#${g.id}';
    add('$o.thema', g.thema);
    add('$o.ziel', g.ziel);
    add('$o.text', g.text);
    for (var i = 0; i < g.stichpunkte.length; i++) {
      add('$o.stichpunkte[$i]', g.stichpunkte[i]);
    }
  }
  for (final b in t.befragungen.values) {
    final o = '${t.herkunft[b.id]}#${b.id}';
    add('$o.thema', b.thema);
    for (var i = 0; i < b.fragen.length; i++) {
      add('$o.fragen[$i]', b.fragen[i]);
    }
    for (var i = 0; i < b.stichpunkte.length; i++) {
      add('$o.stichpunkte[$i]', b.stichpunkte[i]);
    }
  }
  for (final k in t.kurzfassungen.values) {
    final o = '${t.herkunft['kurz.${k.quelle}']}#${k.quelle}';
    for (var i = 0; i < k.antwort.length; i++) {
      add('$o.antwort[$i]', k.antwort[i]);
    }
    for (var i = 0; i < (k.du?.length ?? 0); i++) {
      add('$o.du[$i]', k.du![i]);
    }
  }
  for (final e in t.wahlen.entries) {
    final o = '${t.herkunft[e.key]}#${e.key}';
    add('$o.a', e.value.a);
    add('$o.b', e.value.b);
    add('$o.sabotage', e.value.sabotage);
  }

  for (final b in kanon.beobachtungen) {
    add('beobachtungen.json#${b['id']}', b['text']);
    add('beobachtungen.json#${b['id']}.duText', b['duText']);
  }
  for (final g in kanon.gegenstaende) {
    for (final s in (g['spuren'] as List? ?? const [])) {
      final sp = s as Map;
      add('gegenstaende.json#${sp['id']}.zeigt', sp['zeigt']);
      add('gegenstaende.json#${sp['id']}.harmlos', sp['harmlos']);
    }
  }
  for (final e in kanon.entscheidungenJson['entscheidungen'] as List) {
    final en = e as Map;
    final id = en['id'];
    add('entscheidungen.json#$id.frage', en['frage']);
    for (final o in en['optionen'] as List) {
      final op = o as Map;
      add('entscheidungen.json#${op['id']}.text', op['text']);
    }
    for (final b in (en['begruendung'] as Map).entries) {
      add('entscheidungen.json#$id.begruendung.${b.key}', (b.value as Map)['text']);
    }
  }
  // Hinweise spricht der Erzähler (Baustein hinweis.<id>), also Vorlesetext.
  for (final h in kanon.bonusJson['hinweise'] as List) {
    add('bonus.json#${(h as Map)['id']}', h['text'], vorlesen: true);
  }
  for (final z in kanon.zeitleiste) {
    add('zeitleiste.json#${z['id']}', z['text']);
  }
  for (final f in kanon.figuren) {
    for (final l in (f['luegen'] as List? ?? const [])) {
      final lu = l as Map;
      add('figuren.json#${lu['id']}.behauptung', lu['behauptung']);
      add('figuren.json#${lu['id']}.wahrheit', lu['wahrheit']);
      add('figuren.json#${lu['id']}.duWahrheit', lu['duWahrheit']);
    }
    add('figuren.json#${f['id']}.alltag', f['alltag']);
    add('figuren.json#${f['id']}.persoenlichesZiel', f['persoenlichesZiel']);
  }
  for (final n in (kanon.gegenstaendeJson['nebendelikte'] as List? ?? const [])) {
    add('gegenstaende.json#${(n as Map)['id']}', n['text']);
    add('gegenstaende.json#${n['id']}.duText', n['duText']);
  }
  final setting = kanon.json['setting.json']!;
  for (final e in setting.entries) {
    if (e.key == 'settingId' || e.key == 'hinweis') continue;
    final v = e.value;
    if (v is String) add('setting.json#${e.key}', v);
    if (v is List) {
      for (var i = 0; i < v.length; i++) {
        final x = v[i];
        if (x is String) add('setting.json#${e.key}[$i]', x);
        if (x is Map) {
          add('setting.json#${e.key}[$i].was', x['was']);
          add('setting.json#${e.key}[$i].traegt', x['traegt']);
        }
      }
    }
  }
  return q;
}

void _zeitenAus(Object? x, Set<String> zeiten) {
  if (x is Map) {
    for (final v in x.values) {
      _zeitenAus(v, zeiten);
    }
  } else if (x is List) {
    for (final v in x) {
      _zeitenAus(v, zeiten);
    }
  } else if (x is String) {
    for (final m in _zeitRe.allMatches(x)) {
      zeiten.add(_schluessel(m.group(1)!, m.group(2)!));
    }
  }
}

/// Raum- und Anzeigenamen aus raeume.json. Ortsnamen zählen nur als einzelnes Wort:
/// „oben im Turm“ macht „Turm“ nicht zum Raumnamen.
List<String> _raumnamen(Kanon kanon) {
  final r = kanon.json['raeume.json']!;
  return [
    for (final raum in r['rooms'] as List)
      for (final k in ['name', 'anzeigename'])
        if ((raum as Map)[k] is String) raum[k] as String,
    for (final o in r['orte'] as List)
      if (!((o as Map)['name'] as String).contains(' ')) o['name'] as String,
  ];
}

/// Textlint gegen den Kanon (TON-LEITFADEN §4, §5, §6). Die Regeln `raumwortEndungen` und
/// `raumAusnahmen` stehen in textregeln.json, nicht im Kanon, daher braucht die Funktion `regeln`.
///
/// - Uhrzeiten (`H:MM`, `HH:MM`) müssen irgendwo im Kanon vorkommen.
/// - Ein Wort mit Raumendung muss Raum- oder Ortsname aus raeume.json oder in `raumAusnahmen` sein.
/// - Alte Personennamen (figuren.json, `quelle.name`) sind verboten.
List<TextBefund> textLint(Kanon kanon, List<TextQuelle> quellen, {required Map<String, Object?> regeln}) {
  final zeiten = <String>{};
  _zeitenAus(kanon.json, zeiten);
  final endungen = _liste(regeln['raumwortEndungen']);
  final raeume = <String>{};
  for (final n in [..._raumnamen(kanon), ..._liste(regeln['raumAusnahmen'])]) {
    raeume.addAll(_worte(n).map((w) => w.klein));
  }
  final alt = [
    for (final f in kanon.figuren)
      if (f['quelle'] is Map && (f['quelle'] as Map)['name'] is String)
        _Altname(
          [for (final w in _worte((f['quelle'] as Map)['name'] as String)) w.klein],
          (f['quelle'] as Map)['name'] as String,
          f['name'] as String,
        ),
  ];

  final f = <TextBefund>[];
  for (final q in quellen) {
    for (final m in _zeitRe.allMatches(q.text)) {
      if (!zeiten.contains(_schluessel(m.group(1)!, m.group(2)!))) {
        f.add(TextBefund(ort: q.ort, regel: 'Uhrzeit', auszug: '${m.group(0)} kommt im Kanon nicht vor: ${_ausschnitt(q.text, m.start, m.end)}'));
      }
    }
    final worte = _worte(q.text);
    for (final w in worte) {
      if (endungen.any((e) => w.klein.endsWith(e)) && !raeume.contains(w.klein)) {
        f.add(TextBefund(
          ort: q.ort,
          regel: 'Raumwort',
          auszug: '„${q.text.substring(w.anfang, w.ende)}“ ist kein Raum- oder Ortsname: ${_ausschnitt(q.text, w.anfang, w.ende)}',
        ));
      }
    }
    for (final a in alt) {
      for (var i = 0; i < worte.length; i++) {
        if (_passtAb(worte, i, a.folge)) {
          final ende = worte[i + a.folge.length - 1].ende;
          f.add(TextBefund(
            ort: q.ort,
            regel: 'Altname',
            auszug: 'alter Name „${a.name}“ (heute ${a.heute}): ${_ausschnitt(q.text, worte[i].anfang, ende)}',
          ));
        }
      }
    }
  }
  return f;
}
