import '../party/besetzung.dart';
import '../party/entscheidungen.dart';
import '../party/kanon/kanon.dart';
import '../party/texte.dart';
import '../util/rng.dart';

/// Eigener, wiederholbarer Bot-Strom (K-20). Keine Fall-Daten, keine Würfel und
/// kein fremdes Dossier gehen ein. Auch die Täterrolle wählt mit 70 % A;
/// ihr B wird erst durch die unveränderte Gruppenwahl als Sabotage gewertet.
bool botKooperativ({required String salz, required String rolle, required int runde}) {
  if (salz.isEmpty || rolle.isEmpty || runde < 1 || runde > 3) {
    throw ArgumentError('ungültige Bot-Eingabe');
  }
  return Rng(Rng.hashString('bot:$salz:$rolle:$runde')).chance(0.7);
}

/// Öffentliche Sprechblase, ausdrücklich kein Dossier. Nur der Eröffnungssatz
/// und die für dieses Pflichtgespräch freigegebenen Quellen gelangen hinein.
/// Eine Lüge enthält ausschließlich die Behauptung, niemals ihre Wahrheit.
class BotGespraech {
  final String id, rolle, partner, thema, text;
  final int runde;
  final List<({String quelle, String text})> preisgaben;

  BotGespraech._(Gespraech g, this.partner, List<({String quelle, String text})> zeilen)
      : id = g.id, rolle = g.rolle, thema = g.thema, text = g.text,
        runde = g.runde, preisgaben = List.unmodifiable(zeilen);
}

/// Der Host projiziert besetzte Rollen auf erlaubte Tischgespräche. Der Bot
/// bekommt weder [Texte] noch den Kanon, sondern nur diese fertige Ansicht.
/// Die Projektion ist absichtlich pfadunabhängig; Sonderwissen bleibt hinter
/// der endgültigen Detektivwahl in der vorhandenen Fundkarte.
List<BotGespraech> botGespraeche(Texte texte, {required int rollen, required int runde, bool mitNpc = false}) {
  if (runde < 1 || runde > 3) throw ArgumentError('ungültige Bot-Runde');
  final besetzt = texte.besetzung.besetzt(rollen);
  final plan = texte.gespraechsplan(rollen);
  final gespraeche = [for (final g in texte.sammlung.gespraeche) if (g.runde == runde && besetzt.contains(g.rolle)) g];
  if (mitNpc) {
    // Auch ein späteres Befragungsziel kann schon vorher Tischwissen liefern.
    // Der bestehende Erzähler lässt solche NPCs aus; ihre benötigten, ohnehin
    // öffentlichen Aussagen kommen deshalb zusätzlich als Sprechblasen.
    // Die Vereinigungsmenge ALLER Pfade verhindert einen Täter-Seitenkanal.
    final benoetigt = {
      for (final e in Ermittlung(texte.kanon).runde(runde))
        for (final b in e.begruendung.values) ...b.kette,
    };
    final npc = [for (final g in texte.sammlung.gespraeche) if (g.runde <= runde && !besetzt.contains(g.rolle)) g]
      ..sort((a, b) => b.runde.compareTo(a.runde));
    for (final g in npc) {
      if (g.preisgabe.any(benoetigt.contains)) {
        gespraeche.add(g);
        benoetigt.removeAll(g.preisgabe);
      }
    }
  }
  final ergebnis = <BotGespraech>[];
  for (final g in gespraeche) {
    final zeilen = <({String quelle, String text})>[];
    for (final quelle in g.preisgabe) {
      final teile = quelle.split(':');
      if (teile.length != 2) throw StateError('ungültige Bot-Quelle');
      final String text;
      switch (teile.first) {
        case 'beobachtung':
          final b = texte.beobachtung(teile.last);
          if (b == null || b['wer'] != g.rolle || b['kanal'] != 'pflichtgespraech' ||
              !texte.kanon.pfade.every((p) => Kanon.giltIn(b['pfade'], p))) {
            throw StateError('nicht öffentliche Bot-Beobachtung');
          }
          text = b['text'] as String;
        case 'luege':
          final l = texte.luege(teile.last);
          if (l == null || l['person'] != g.rolle) throw StateError('fremde Bot-Behauptung');
          text = l['behauptung'] as String;
        default:
          throw StateError('nicht öffentliche Bot-Quelle');
      }
      zeilen.add((quelle: quelle, text: text));
    }
    ergebnis.add(BotGespraech._(g, besetzt.contains(g.rolle) ? (plan[g.id] ?? g.partner) : Besetzung.detektiv, zeilen));
  }
  final reihenfolge = texte.besetzung.besetzt(texte.besetzung.maxRollen);
  ergebnis.sort((a, b) {
    final rolle = reihenfolge.indexOf(a.rolle).compareTo(reihenfolge.indexOf(b.rolle));
    return rolle == 0 ? a.id.compareTo(b.id) : rolle;
  });
  return List.unmodifiable(ergebnis);
}
