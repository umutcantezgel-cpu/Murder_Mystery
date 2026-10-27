// Prüfer der Einfluss-Schicht (Finale §3, §4): Daten (`einfluss.json`) gegen Kanon und Regeln, Ziele
// und die Texte des Bereichs `einfluss`. Rein, ohne dart:io; `akte_pruefen` liest die Dateien.
import '../karten/geruechte.dart' show PfadgleichRegeln;
import '../party/entscheidungen.dart';
import '../party/kanon/kanon.dart';
import '../party/texte.dart' show einflussVorlesetext, stichpunktWoerter;
import '../party/textpruefer.dart';
import 'einfluss.dart';
import 'einfluss_ziele.dart';

/// Wortgrenzen der Vorlesetexte („Änderungen“ zu §3.13): Schlüsselanfang → (mindestens, höchstens).
const einflussWortgrenzen = <String, (int, int)>{
  'einfluss.auspacken.': (20, 45),
  'einfluss.ablenken.': (15, 35),
  'einfluss.ereignis.': (20, 50),
  'einfluss.morgen.': (20, 50),
  'einfluss.epilog.': (1, 30),
};

/// Höchstens so viele Wörter hat eine Karte des Bereichs `einfluss` (R17: ein Stichpunkt).
const einflussKartenWorte = 8;

/// Höchstens so viele Wörter hat ein Ereignistitel (`einfluss.ereignis.<id>.titel`, „Änderungen“ 3).
const einflussTitelWorte = 3;

/// Schlüsselanfänge, für die R15 gilt („Änderungen“ 8): pfadgleiche Texte vor dem Finale. Nicht für
/// `einfluss.auspacken.*` (nennt seine Quelle, §3.6) und nicht für Texte nach dem Finale (Epiloge, Preise,
/// Morgen, Tischbonus).
const einflussR15Bereiche = ['einfluss.geruecht.', 'einfluss.ereignis.', 'einfluss.ablenken.', 'einfluss.folgen.', 'einfluss.leiste.', 'einfluss.bot.'];

/// Spielbegriffe, die R15 in Einfluss-Texten nicht sperrt („Änderungen“ 8).
const einflussSpielbegriffe = {'spuk', 'schlossgeist', 'spur', 'geheimnis'};

/// Freie Wörter der R15-Prüfung von Einfluss-Texten („Änderungen“ 8 und 15, klein): alle Wörter der
/// Anzeigenamen und vollen Namen der Figuren und des Namens von Herrn Schneider (R23) und die
/// [einflussSpielbegriffe]. Genitive („Fatmas“) trifft [PfadgleichRegeln.r15Woerter] über die Wortformen.
Set<String> einflussR15Frei(Kanon kanon) => {
      ...einflussSpielbegriffe,
      for (final f in [...kanon.figuren, (kanon.figurenJson['opfer'] as Map).cast<String, Object?>()])
        for (final n in [f['name'], f['vollerName']])
          if (n is String)
            for (final m in RegExp(r'\p{L}+', unicode: true).allMatches(n)) m.group(0)!.toLowerCase(),
    };

/// Platzhalter je Schlüssel (Pflicht, „Änderungen“ zu §3.13 und 1); andere Schlüssel tragen keinen.
Set<String> einflussPlatzhalter(String kennung) => switch (kennung) {
      'einfluss.ertappt' => const {'figur', 'ziel'},
      'einfluss.ertappt.selbst' => const {'figur'},
      'einfluss.privat.gelauscht' => const {'figur', 'ziel', 'zug'},
      'einfluss.privat.gelauscht.$lauschOhneZiel' => const {'figur', 'zug'},
      'einfluss.privat.gelauscht.$lauschAbgewartet' => const {'figur'},
      _ when kennung.startsWith('einfluss.geruecht.') || kennung.startsWith('einfluss.preis.') => const {'figur'},
      _ => const {},
    };

final _platzhalterRe = RegExp(r'@([A-Za-z]+)');
final _satzEndeRe = RegExp(r'[.!?…]\s+\S');

/// Prüft die Einfluss-Schicht einer Akte. Leer heißt grün.
/// - Daten: [EinflussRegeln.ausJson] (Format, Zahlen, Arten, Bezug-Optionen, Verweise); je Figur
///   Auspacken, Bot und zwei Sterne; Bots mit Auspacken haben etwas auszupacken.
/// - Bezug-Ausgewogenheit (§3.3): je Runde kommen die Kernfiguren in gleich vielen Optionen vor (±1).
/// - Pfadgleichheit (§3.5, §3.6): Randnotizen und Auspack-Notizen sind Beobachtungen mit `pfade: alle`,
///   Auspack-Fakten gibt es in allen Pfaden der Ermittlung.
/// - Ziele (§3.9): parsebar, erreichbar und verfehlbar ([zielProbe]); die Kernfiguren haben je Stern
///   dieselbe Form ([zielForm]).
/// - Texte (§3.13, „Änderungen“), nur mit [texteNoetig]: jeder Schlüssel aus [einflussKatalog] in [texte],
///   keiner darüber hinaus; Karten ein Stichpunkt mit höchstens [einflussKartenWorte] Wörtern,
///   Ereignistitel höchstens [einflussTitelWorte] Wörter und ohne „Kerze“ („Änderungen“ 3);
///   Vorlesetexte in ihren [einflussWortgrenzen]; Platzhalter nach [einflussPlatzhalter]; Texte der
///   [einflussR15Bereiche] ohne Fallgegenstand, Suchstelle, Indizort, Lacher und Sperrort nach ganzen
///   Wörtern, Namen und [einflussSpielbegriffe] frei ([r15], [PfadgleichRegeln.r15Woerter], R15,
///   „Änderungen“ 8 und 15); mit [ton] dazu die Tonregeln (Vorlesen nach [einflussVorlesetext]).
/// - Kragen erzwingt den chaotischen Morgen („Änderungen“ 2).
List<String> pruefeEinfluss(
  Map<String, Object?> json,
  Ermittlung erm, {
  Map<String, String> texte = const {},
  bool texteNoetig = true,
  Textpruefer? ton,
  PfadgleichRegeln? r15,
}) {
  final EinflussRegeln r;
  try {
    r = EinflussRegeln.ausJson(json, erm);
  } on FormatException catch (e) {
    return ['einfluss.json: ${e.message}'];
  }
  final f = <String>[];

  // Vollständigkeit je Figur.
  for (final fig in r.figuren) {
    if (!r.auspacken.containsKey(fig)) f.add('auspacken.$fig fehlt');
    if (!r.bots.containsKey(fig)) f.add('bots.$fig fehlt');
    if (!r.ziele.containsKey(fig)) f.add('ziele.$fig fehlt');
  }
  for (final e in r.bots.entries) {
    final p = e.value;
    if (((p.gewichte[ZugArt.auspacken] ?? 0) > 0 || p.auspacken != null) && !r.auspacken.containsKey(e.key)) {
      f.add('bots.${e.key}: packt aus, aber auspacken.${e.key} fehlt');
    }
  }

  // Kragen erzwingt den chaotischen Morgen, auch gegen hohen Zusammenhalt („Änderungen“ 2).
  for (final e in r.ereignisse) {
    if (e.id == 'kragen' && e.morgen != MorgenVariante.chaotisch) f.add('ereignisse.kragen: erzwingt den chaotischen Morgen nicht');
  }

  // Bezug-Ausgewogenheit (§3.3).
  for (final runde in r.optionenJeRunde.keys.toList()..sort()) {
    final zahl = {for (final k in r.kern) k: r.optionen(runde).where((o) => r.bezug[o]!.contains(k)).length};
    final werte = zahl.values;
    final tief = werte.reduce((a, b) => a < b ? a : b), hoch = werte.reduce((a, b) => a > b ? a : b);
    if (hoch - tief > 1) f.add('bezug: Runde $runde nennt die Kernfiguren ungleich oft ($zahl)');
  }

  // Pfadgleiche Quellen (§3.5, §3.6).
  bool alle(String b) => erm.beobachtungJson(b)?['pfade'] == 'alle';
  for (final e in r.randnotizen.entries) {
    for (final b in e.value) {
      if (!alle(b)) f.add('randnotizen.${e.key}: $b gilt nicht in allen Pfaden');
    }
  }
  for (final e in r.auspacken.entries) {
    final fakt = e.value.fakt, notiz = e.value.notiz;
    if (fakt != null && erm.faktPfade(fakt).length != erm.pfade.length) {
      f.add('auspacken.${e.key}: Fakt $fakt gibt es nicht in allen Pfaden (${(erm.faktPfade(fakt).toList()..sort()).join(', ')})');
    }
    if (notiz != null && !alle(notiz)) f.add('auspacken.${e.key}: $notiz gilt nicht in allen Pfaden');
  }

  // Ziele (§3.9).
  EinflussZiele? ziele;
  try {
    ziele = EinflussZiele.aus(r);
  } on FormatException catch (e) {
    f.add(e.message);
  }
  if (ziele != null) {
    for (final fig in r.figuren) {
      for (final z in ziele.von(fig)) {
        final probe = zielProbe(z, r);
        if (!probe.erreichbar) f.add('ziele.$fig[${z.nr}] ${z.id}: nie erreichbar');
        if (!probe.verfehlbar) f.add('ziele.$fig[${z.nr}] ${z.id}: nie verfehlbar');
      }
    }
    for (var nr = 1; nr <= 2; nr++) {
      final formen = {for (final k in r.kern) if (ziele.von(k).length >= nr) k: zielForm(ziele.von(k)[nr - 1].bedingung)};
      if (formen.values.toSet().length > 1) {
        f.add('ziele: Stern $nr der Kernfiguren hat nicht dieselbe Form (${[for (final e in formen.entries) '${e.key}: ${e.value}'].join('; ')})');
      }
    }
  }

  if (texteNoetig) f.addAll(_pruefeTexte(r, texte, ton: ton, r15: r15, frei: r15 == null ? const {} : einflussR15Frei(erm.kanon)));
  return f;
}

List<String> _pruefeTexte(EinflussRegeln r, Map<String, String> texte, {Textpruefer? ton, PfadgleichRegeln? r15, Set<String> frei = const {}}) {
  final f = <String>[];
  final katalog = einflussKatalog(r);
  final soll = katalog.toSet();
  for (final k in katalog) {
    if (!texte.containsKey(k)) f.add('Text $k fehlt');
  }
  for (final k in texte.keys) {
    if (k.startsWith('einfluss.') && !soll.contains(k)) f.add('Text $k gehört nicht zum Einfluss-Katalog');
  }
  for (final k in katalog) {
    final t = texte[k];
    if (t == null) continue;
    final vorlesen = einflussVorlesetext(k);
    final worte = stichpunktWoerter(t);
    if (t.trim().isEmpty) {
      f.add('$k: leer');
      continue;
    }
    if (vorlesen) {
      for (final g in einflussWortgrenzen.entries) {
        if (!k.startsWith(g.key)) continue;
        final (tief, hoch) = g.value;
        if (worte < tief || worte > hoch) f.add('$k: $worte Wörter statt $tief bis $hoch');
      }
    } else {
      // Karte nach R17: genau ein Stichpunkt, keine Prosa; Ereignistitel kürzer und ohne „Kerze“.
      final titel = k.startsWith('einfluss.ereignis.') && k.endsWith('.titel');
      final hoechstens = titel ? einflussTitelWorte : einflussKartenWorte;
      if (t.contains('\n')) f.add('$k: mehr als ein Stichpunkt (R17)');
      if (worte > hoechstens) f.add('$k: $worte Wörter statt höchstens $hoechstens (R17)');
      if (_satzEndeRe.hasMatch(t.trim())) f.add('$k: mehr als ein Satz statt eines Stichpunkts (R17)');
      if (titel && t.toLowerCase().contains('kerze')) f.add('$k: Ereignistitel ohne „Kerze“');
    }
    // Platzhalter: genau die des Schlüssels.
    final erlaubt = einflussPlatzhalter(k);
    final da = {for (final m in _platzhalterRe.allMatches(t)) m.group(1)!};
    for (final p in da.difference(erlaubt)) {
      f.add('$k: Platzhalter @$p hier nicht erlaubt');
    }
    for (final p in erlaubt.difference(da)) {
      f.add('$k: Platzhalter @$p fehlt');
    }
    if (t.toLowerCase().contains('geburtstag')) f.add('$k: Geburtstag (A-061)');
    if (r15 != null && einflussR15Bereiche.any(k.startsWith)) {
      final befund = r15.r15Woerter(t.replaceAll(_platzhalterRe, ''), frei: frei);
      if (befund != null) f.add('$k: $befund');
    }
    if (ton != null) {
      for (final b in ton.pruefe(TextQuelle(ort: k, text: t.replaceAll(_platzhalterRe, 'Name'), vorlesen: vorlesen))) {
        f.add('${b.ort}: ${b.regel}: ${b.auszug}');
      }
    }
  }
  return f;
}
