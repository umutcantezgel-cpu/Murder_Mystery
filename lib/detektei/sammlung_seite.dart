import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../karten/widgets/spielkarte.dart';
import '../l10n/lookup.dart';
import '../stil/stil.dart';

/// Sammlung (Route `/sammlung`): vorerst ein Platzhalter. Die Karten der
/// Figuren kommen mit den nächsten Ausbaustufen; gezeigt werden verdeckte
/// Karten als Vorgeschmack.
class SammlungSeite extends StatelessWidget {
  const SammlungSeite({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    return Scaffold(
      backgroundColor: f.grund,
      body: MRahmen(
        titel: l.karten_sammlung_titel,
        untertitel: l.karten_sammlung_text,
        aktionen: [
          MKnopf(
            text: l.common_back,
            art: MKnopfArt.zweit,
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go(Routes.start),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MMass.s16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: MMass.s16,
            runSpacing: MMass.s16,
            children: [
              for (final (neigung, farbe) in [(-0.05, f.blutgold), (0.0, f.zinn), (0.05, f.messing)])
                Transform.rotate(
                  angle: neigung,
                  child: SpielKarte(
                    name: '',
                    farbe: farbe,
                    aufgedeckt: false,
                    umdrehbar: false,
                    breite: 104,
                    rueckseitenSemantik: l.karten_rueckseite,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
