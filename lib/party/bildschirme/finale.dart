import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../rueckblende_ansicht.dart';
import '../sitzung.dart';

/// Finale mit Rückblende (Master 7.6, Schritt 7): oben der Zeitraffer der Tat,
/// darunter Finaltext und Rückblende aus dem Erzähler. Die Überschrift ist das
/// Ende des Abends, das erst nach der Anklage feststeht.
class FinaleBildschirm extends StatelessWidget {
  const FinaleBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) => PartyRahmen(
        marke: sitzung.ui('ui.finale.marke'),
        titel: sitzung.ende.name,
        aktionen: [PartyKnopf(text: sitzung.ui('ui.allgemein.weiter'), onPressed: sitzung.kannWeiter ? sitzung.weiter : null)],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(sitzung.ui('ui.finale.rueckblende').toUpperCase(), style: Keller.marke),
            const SizedBox(height: 8),
            // Fester Kasten: mindestens 260 px, sonst 45 % der Höhe; so beginnt der
            // Finaltext noch über der Fußleiste (B7).
            if (sitzung.hatRueckblende)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: math.max(260.0, MediaQuery.sizeOf(context).height * 0.45),
                  child: RueckblendeAnsicht(sitzung: sitzung),
                ),
              )
            else
              // Akte ohne Simulation: die Rückblende wird erzählt, nicht gezeigt.
              RueckblendeText(sitzung: sitzung),
            const SizedBox(height: 20),
            ErzaehlerFeld(
              sitzung: sitzung,
              kennungen: sitzung.erzaehler,
              // Der Text der Rückblende steht oben schon; die Stimme liest ihn trotzdem vor.
              verborgen: {if (!sitzung.hatRueckblende) 'rueckblende.${sitzung.pfad}'},
            ),
          ],
        ),
      );
}
