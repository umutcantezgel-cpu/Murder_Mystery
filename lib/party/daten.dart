import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';

/// Alles, was ein Partyabend aus dem Kanon braucht: Kanon, Textsammlung,
/// Karte und das Renderer-Szenario. Wird einmal geladen und nie verändert.
class PartyDaten {
  final String fall;
  final Kanon kanon;
  final Texte texte;
  final PartyKarte karte;
  final ScenarioDef szenario;

  /// Renderer-Kennung je Kanon-Person (Opfer und Rollen).
  final Map<String, String> npcKennung;

  /// Kanon-Person je Renderer-Kennung.
  final Map<String, String> kanonKennung;

  PartyDaten._(this.fall, this.kanon, this.texte, this.karte, this.szenario, this.npcKennung)
      : kanonKennung = {for (final e in npcKennung.entries) e.value: e.key};

  /// Aus einem synchronen Leser (Tests) und der Szenario-Vorlage. Für Akten
  /// außer dem Schlosskeller ergänzt [basis] fehlende Oberflächentexte aus
  /// dem unveränderten Schlosskeller.
  factory PartyDaten.aus(KanonLeser lies, Map<String, dynamic> vorlage, {String fall = 'schlosskeller', KanonLeser? basis}) {
    final kanon = Kanon.lade(lies);
    final sammlung = Textsammlung.lade(lies);
    if (basis != null) sammlung.ergaenzeUi(Textsammlung.lade(basis));
    final texte = Texte(kanon, sammlung);
    final karte = PartyKarte(kanon);
    final szenario = ScenarioDef.fromJson(partySzenarioJson(kanon, vorlage, id: 'party_$fall'));
    return PartyDaten._(fall, kanon, texte, karte, szenario, partyNpcKennungen(kanon, vorlage));
  }

  /// Lädt alle Dateien einer Akte aus den Assets (`content/party/<fall>/`).
  static Future<PartyDaten> laden(AssetBundle bundle, {String fall = 'schlosskeller'}) async {
    final eigen = await _ordner(bundle, 'content/party/$fall');
    final basis = fall == 'schlosskeller' ? null : await _ordner(bundle, 'content/party/schlosskeller', nurTexte: true);
    final vorlagePfad = eigen.vorlage ?? 'content/scenarios/ravensmoor.json';
    final vorlage = jsonDecode(await bundle.loadString(vorlagePfad)) as Map<String, dynamic>;
    return PartyDaten.aus(eigen.lies, vorlage, fall: fall, basis: basis?.lies);
  }

  static Future<_Ordner> _ordner(AssetBundle bundle, String basis, {bool nurTexte = false}) async {
    Future<Map<String, Object?>> json(String pfad) async => jsonDecode(await bundle.loadString('$basis/$pfad')) as Map<String, Object?>;
    final dateien = <String, Map<String, Object?>>{};
    Future<void> lade(Iterable<String> pfade) async {
      final liste = pfade.where((p) => !dateien.containsKey(p)).toList();
      final inhalte = await Future.wait(liste.map(json));
      for (var i = 0; i < liste.length; i++) {
        dateien[liste[i]] = inhalte[i];
      }
    }

    await lade([if (!nurTexte) ...Kanon.grunddateien, 'texte/index.json']);
    final index = dateien['texte/index.json']!;
    await lade([
      if (!nurTexte) ...Kanon.simulationsdateien(dateien['fall.json']!),
      for (final d in index['dateien'] as List)
        if (!nurTexte || (d as Map)['datei'].toString().startsWith('ui')) 'texte/${(d as Map)['datei']}',
    ]);
    if (nurTexte) {
      // Nur die Oberflächendateien; der Index wird darauf gekürzt.
      dateien['texte/index.json'] = {
        ...index,
        'dateien': [for (final d in index['dateien'] as List) if ((d as Map)['datei'].toString().startsWith('ui')) d],
      };
    }
    final darstellung = (dateien['setting.json']?['darstellung'] as Map?) ?? const {};
    return _Ordner((p) => dateien[p] ?? (throw StateError('Datei fehlt: $basis/$p')), darstellung['vorlage'] as String?);
  }
}

class _Ordner {
  final KanonLeser lies;
  final String? vorlage;
  const _Ordner(this.lies, this.vorlage);
}
