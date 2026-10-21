import 'package:flutter/material.dart';

import '../../party/diashow_ansicht.dart';
import '../../stil/stil.dart';
import 'gast_ansicht.dart' show GastKontext;

/// Hat die Einleitung auf diesem Gast-Gerät eine Diashow (M4)? Der Raum schickt
/// die Nummer (`dia`), die Bilder rendert das Gerät aus seiner Akte; solange
/// die Akte lädt, bleibt es bei den Texten.
bool gastMitDiashow(GastKontext c) => c.v['dia'] is int && c.daten?.diashow != null;

/// Die Diashow zur Einleitung auf dem Gerät eines Gastes (M4): Alle Gäste sehen
/// dasselbe Bild. Den Text dazu sieht nur der Vorleser-Sitz (privat
/// `erzaehler`, je Abschnitt ein Text in der Reihenfolge der Bilder), alle
/// anderen sehen, wer vorliest (die Karte dazu stellt die Gastseite). Wer
/// leitet, schaltet mit „Nächstes Bild“ weiter.
class GastDiashow extends StatelessWidget {
  const GastDiashow({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  Widget build(BuildContext context) {
    final c = kontext;
    final l = c.l;
    final daten = c.daten!;
    final n = daten.diashow!.dias.length;
    final nr = (c.v['dia'] as int).clamp(0, n - 1);
    final beschriftung = l.party_intro_bild('${nr + 1}', '$n');
    final texte = c.erzaehlerTexte;
    // Je Abschnitt des Intros ein Bild, in derselben Reihenfolge wie die Texte.
    final text = c.vorleser && texte.length == n ? texte[nr] : null;
    return Column(
      key: const ValueKey('gast-diashow'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DiashowAnsicht(daten: daten, nr: nr, beschriftung: beschriftung),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: MMass.s12),
          child: ExcludeSemantics(child: Text(beschriftung.toUpperCase(), style: c.t.marke, textAlign: TextAlign.center)),
        ),
        if (text != null)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s16),
            child: MBlatt(
              key: ValueKey('gast-dia-text-$nr'),
              klammer: true,
              samen: nr + 3,
              neigung: nr.isEven ? -0.004 : 0.005,
              padding: const EdgeInsets.fromLTRB(22, 34, 22, 22),
              child: MGanzeWorte(text, stil: MPapierSchrift.erzaehler, minimum: 14),
            ),
          )
        else if (c.vorleser)
          // Passen Texte und Bilder nicht zusammen, stehen alle Texte da.
          for (final t in texte)
            Padding(
              padding: const EdgeInsets.only(bottom: MMass.s12),
              child: MBlatt(padding: const EdgeInsets.all(20), child: MGanzeWorte(t, stil: MPapierSchrift.erzaehler, minimum: 14)),
            ),
        if (c.leitet && nr < n - 1)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s16),
            child: Align(
              alignment: Alignment.centerRight,
              child: MKnopf(
                key: const ValueKey('gast-dia-naechstes'),
                text: l.party_intro_naechstes,
                icon: Icons.photo_library_outlined,
                onPressed: c.verbunden ? () => c.befehl({'typ': 'dia', 'nr': nr + 1}) : null,
              ),
            ),
          ),
      ],
    );
  }
}
