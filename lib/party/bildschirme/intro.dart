import 'package:flutter/material.dart';

import '../../stil/mappe/abend1_bausteine.dart';
import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Intro (Phase intro, Master 7.6 Schritt 4): Die Fallakte liegt aufgeschlagen
/// auf dem Tisch. Ihr Reiter trägt die Marke, darin liegen die Berichtsblätter
/// der Erzählung mit den drei Lacher-Rückblicken. Der Knopf führt in die erste
/// Runde.
class IntroBildschirm extends StatelessWidget {
  const IntroBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) => PartyRahmen(
        titel: sitzung.ui('ui.intro.titel'),
        aktionen: [PartyKnopf(text: sitzung.ui('ui.intro.weiter'), onPressed: sitzung.kannWeiter ? sitzung.weiter : null)],
        child: LayoutBuilder(
          // Schmal und mit großer Schrift liegen die Blätter fast bis zum Rand der Mappe.
          builder: (context, box) {
            final rand = schmalFuerSchrift(context, box.maxWidth) ? 4.0 : 10.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: MOffeneMappe(
                reiter: sitzung.ui('ui.intro.marke'),
                farbe: context.farben.akzent,
                siegel: AkteStil.fuer(sitzung.daten.fall).sigel,
                padding: EdgeInsets.fromLTRB(rand, 18, rand, 26),
                child: ErzaehlerFeld(sitzung: sitzung, kennungen: sitzung.erzaehler),
              ),
            );
          },
        ),
      );
}
