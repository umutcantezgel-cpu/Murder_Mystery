// Gemeinsame Hilfen der Einfluss-Tests (Finale §3): echte Daten der Akte und im Test erzeugte
// Fixture-Texte für alle Schlüssel des Bereichs `einfluss` (keine Inhaltstexte, die schreibt das Inhaltsteam).
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../party/kanon_hilfe.dart';

/// `content/party/zusatz/schlosskeller/einfluss.json`, je Aufruf frisch (tief kopierbar).
Map<String, Object?> einflussJson() => leseJson('$repoWurzel/content/party/zusatz/schlosskeller/einfluss.json');

/// Tiefe Kopie, um Fehlerproben zu bauen.
Map<String, Object?> kopie(Map<String, Object?> j) => jsonDecode(jsonEncode(j)) as Map<String, Object?>;

Ermittlung? _erm;
EinflussRegeln? _regeln;

Ermittlung get einflussErmittlung => _erm ??= Ermittlung(kanon);
EinflussRegeln get einflussRegeln => _regeln ??= EinflussRegeln.ausJson(einflussJson(), einflussErmittlung);

/// Ein neutraler Satz ohne Fallbezug und ohne Ort (11 Wörter), für Fixture-Texte.
const fixtureSatz = 'Ringsum wird es kurz still, und alle halten den Atem an.';

/// Fixture-Texte für jeden Schlüssel aus [einflussKatalog]: Karten ein Stichpunkt, Ereignistitel drei
/// Wörter, Vorlesetexte zwei Sätze (22 Wörter), Epiloge ein Satz; Platzhalter, wo der Schlüssel sie verlangt.
Map<String, String> fixtureTexte(EinflussRegeln r) {
  final aus = <String, String>{};
  for (final k in einflussKatalog(r)) {
    final platz = einflussPlatzhalter(k);
    final vorne = [for (final p in ['figur', 'ziel', 'zug', 'liste', 'letzte']) if (platz.contains(p)) '@$p'].join(' und ');
    if (k.startsWith('einfluss.ereignis.') && k.endsWith('.titel')) {
      aus[k] = 'Kurz und klar';
    } else if (!einflussVorlesetext(k)) {
      aus[k] = vorne.isEmpty ? 'Kurz und klar für alle' : 'Nur $vorne für alle';
    } else if (k.startsWith('einfluss.epilog.')) {
      aus[k] = fixtureSatz;
    } else {
      aus[k] = vorne.isEmpty ? '$fixtureSatz $fixtureSatz' : 'Gleich danach nennt jemand $vorne beim Namen. $fixtureSatz';
    }
  }
  return aus;
}

/// Texte des Schlosskellers mit den Fixture-Texten des Bereichs `einfluss` als zusätzlicher Datei, solange
/// die Akte selbst keine Einfluss-Texte hat (danach gelten ihre echten). Für Raum und Ansichten.
Texte einflussTexte() {
  final ordner = '$repoWurzel/content/party/schlosskeller';
  final index = leseJson('$ordner/texte/index.json');
  final dateien = index['dateien'] as List;
  final echt = dateien.any((d) => (d as Map)['bereich'] == 'einfluss');
  final probe = {
    'settingId': kanon.settingId,
    'bereich': 'einfluss',
    'hinweis': 'Fixture',
    'eintraege': [for (final e in fixtureTexte(einflussRegeln).entries) {'id': e.key, 'text': e.value}],
  };
  return Texte(
    kanon,
    Textsammlung.lade((p) {
      if (p == 'texte/index.json' && !echt) {
        return {...index, 'dateien': [...dateien, {'datei': 'einfluss-probe.json', 'bereich': 'einfluss'}]};
      }
      if (p == 'texte/einfluss-probe.json') return probe;
      return leseJson('$ordner/$p');
    }),
  );
}
