// Pfadwissen (S-1): Texte, die nur in einem Teil der Täterpfade gelten, und die
// Fünf-Wort-Folgen daraus, die nie an den Tisch gehören. Gemeinsame Quelle für
// spoiler_test, die Prüfer der Einstimmung und der Erzählerakte (A-063) und die
// Druckprüfungen. Reines Dart ohne dart:io.
import 'kanon/kanon.dart';
import 'spuren.dart';
import 'steckbriefe.dart' show fuenfWortFolgen;

/// Beschreibt ein Text den Schlag als Handlung? (TON §1: nur Schatten und Geräusch.)
final schlagVerbRe = RegExp(r'\b(schlägst|schlägt|schlage|schlug|schlugen|zugeschlagen|zuschlagen|zuzuschlagen|niedergeschlagen)\b', caseSensitive: false);

/// Texte, die nur in einem Teil der Pfade gelten, mit diesen Pfaden (Quelle → (Text, Pfade)): Spuren mit Feld
/// rolle (Pfade, in denen sie entstehen), Beobachtungen mit pfade ungleich „alle“, Täter- und Unschuldsprofil der
/// vier Kernfiguren (eigener Pfad bzw. alle anderen), Ereignisse der vier Tatmatrizen (E-029).
Map<String, (String, Set<String>)> pfadwissen(Kanon kanon) {
  final alle = kanon.pfade.toSet();
  final spuren = SpurRechner(kanon);
  final q = <String, (String, Set<String>)>{};
  for (final g in kanon.gegenstaende) {
    for (final s in (g['spuren'] as List? ?? const [])) {
      final m = s as Map;
      if (!m.containsKey('rolle')) continue;
      q['Spur ${m['id']}'] = (m['zeigt'] as String, {for (final p in alle) if (spuren.entsteht(m['entstehtWenn'] as Map, p)) p});
    }
  }
  for (final b in kanon.beobachtungen) {
    if (b['pfade'] != 'alle') q['Beobachtung ${b['id']}'] = (b['text'] as String, {for (final p in b['pfade'] as List) p as String});
    if (b['pfade'] != 'alle' && b['duText'] != null) q['Beobachtung ${b['id']} (Du-Fassung)'] = (b['duText'] as String, {for (final p in b['pfade'] as List) p as String});
  }
  for (final k in kanon.kernverdaechtige) {
    for (final (feld, pfade) in [('killerProfile', {k}), ('innocentProfile', alle.difference({k}))]) {
      final profil = kanon.figur(k)![feld] as Map? ?? const {};
      for (final e in profil.entries) {
        if (e.value is String) q['${feld == 'killerProfile' ? 'Täterprofil' : 'Unschuldsprofil'} $k.${e.key}'] = (e.value as String, pfade);
      }
    }
  }
  for (final p in kanon.pfade) {
    for (final e in (kanon.json['tatmatrix/$p.json']?['ereignisse'] as List? ?? const [])) {
      final m = e as Map;
      if (m['text'] is String) q['Ereignis ${m['id']} (tatmatrix/$p.json)'] = (m['text'] as String, {p});
    }
  }
  return q;
}

/// Folgen aus pfadneutralen Kanon-Texten (Beobachtungen und Zeitleiste mit „alle“, Gegenstandsbeschreibungen).
/// Eine Folge, die dort vorkommt, zählt nicht als Pfadwissen.
Set<String> pfadneutraleFolgen(Kanon kanon) {
  final texte = [
    for (final b in kanon.beobachtungen)
      if (b['pfade'] == 'alle') ...[b['text'] as String, ?b['duText'] as String?],
    for (final z in kanon.zeitleiste)
      if (z['pfade'] == 'alle') z['text'] as String,
    for (final g in kanon.gegenstaende)
      if (g['beschreibung'] is String) g['beschreibung'] as String,
  ];
  return {for (final t in texte) ...fuenfWortFolgen(t)};
}

/// Folge → Quelle für alle Fünf-Wort-Folgen aus Pfadwissen ([pfadwissen]), die in keinem pfadneutralen Text
/// stehen ([pfadneutraleFolgen]) und nicht in allen Pfaden gelten (etwa dieselbe Wendung im Täter- und im
/// Unschuldsprofil derselben Figur).
Map<String, String> pfadwissenVerboten(Kanon kanon) {
  final neutral = pfadneutraleFolgen(kanon);
  final alle = kanon.pfade.toSet();
  final quelle = <String, String>{};
  final pfade = <String, Set<String>>{};
  pfadwissen(kanon).forEach((q, eintrag) {
    final (text, gilt) = eintrag;
    for (final folge in fuenfWortFolgen(text)) {
      if (neutral.contains(folge)) continue;
      quelle.putIfAbsent(folge, () => q);
      (pfade[folge] ??= {}).addAll(gilt);
    }
  });
  return {
    for (final e in quelle.entries)
      if (!pfade[e.key]!.containsAll(alle)) e.key: e.value,
  };
}
