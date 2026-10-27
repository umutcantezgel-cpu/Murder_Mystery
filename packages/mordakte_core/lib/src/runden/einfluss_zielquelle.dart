// Ziele der Erzählerakte aus der Einfluss-Schicht (Finale §2, §3.9): Mit der Fähigkeit `einfluss`
// zeigt die Akte je Figur die zwei Sterne aus `einfluss.json` mit ihren Kartentexten
// `einfluss.ziel.<figur>.<nr>`; ohne Schicht liest sie `persoenlichesZiel` ([KanonZiele]).
// Sie kennt die Lösung so wenig wie die Sterne selbst. Genutzt von Druck (Erzählerakte) und App
// (Erzählerakte-Ansicht).
import '../party/erzaehlerakte.dart';
import '../party/texte.dart';
import 'einfluss.dart';
import 'einfluss_ziele.dart';

/// [ZielQuelle] der Einfluss-Schicht: die Sterne einer Figur in ihrer Reihenfolge,
/// Kennung aus `einfluss.json`, Text aus dem Bereich `einfluss` der [texte].
class EinflussZielQuelle implements ZielQuelle {
  EinflussZielQuelle(EinflussRegeln regeln, this.texte) : ziele = EinflussZiele.aus(regeln);

  final EinflussZiele ziele;
  final Texte texte;

  /// Unbekannte Text-Schlüssel sind ein Fehler wie überall (F-11).
  @override
  List<ErzaehlerZiel> zieleVon(String figur) => [
        for (final z in ziele.von(figur)) ErzaehlerZiel(id: z.id, text: texte.einflussText(z.schluessel, figur: figur)),
      ];
}
