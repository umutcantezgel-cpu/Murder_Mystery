import 'package:flutter/material.dart';

import '../../stil/mappe/abend1_bausteine.dart';
import '../../stil/stil.dart';
import '../diashow_ansicht.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Intro (Phase intro, Master 7.6 Schritt 4): Die Fallakte liegt aufgeschlagen
/// auf dem Tisch. Ihr Reiter trägt die Marke, darin liegen die Berichtsblätter
/// der Erzählung mit den drei Lacher-Rückblicken. Der Knopf führt in die erste
/// Runde.
///
/// Mit Diashow (Akten mit `diashow.json`, Langer Abend M4) gehört zu jedem
/// Abschnitt ein Bild ([DiashowAnsicht]):
/// - Liest dieses Gerät vor (Solo, reihum ohne Begleiter, online der
///   Vorleser-Sitz), steht das Bild oben und darunter nur der Baustein dazu;
///   „Nächstes Bild“ schaltet Bild und Text zusammen weiter, die Stimme auch.
/// - Liest ein anderes Gerät (der Erzähler am eigenen Handy, online ein anderer
///   Sitz), zeigt dieses Gerät die Diashow groß, darunter nur, wer vorliest.
///
/// Weiterschalten darf nur, wer leitet ([PartySitzung.diaSteuerbar]); online
/// sehen alle Geräte dasselbe Bild. Ohne Diashow bleibt das Intro wie bisher.
class IntroBildschirm extends StatelessWidget {
  const IntroBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) {
    if (sitzung.diashow == null) return _ohneDiashow(context);
    return ListenableBuilder(listenable: sitzung, builder: (context, _) => _mitDiashow(context));
  }

  /// Die aufgeschlagene Mappe. Schmal und mit großer Schrift liegen die Blätter
  /// fast bis zum Rand der Mappe.
  Widget _mappe(BuildContext context, Widget kind) => LayoutBuilder(
        builder: (context, box) {
          final rand = schmalFuerSchrift(context, box.maxWidth) ? 4.0 : 10.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: MOffeneMappe(
              reiter: sitzung.ui('ui.intro.marke'),
              farbe: context.farben.akzent,
              siegel: AkteStil.fuer(sitzung.daten.fall).sigel,
              padding: EdgeInsets.fromLTRB(rand, 18, rand, 26),
              child: kind,
            ),
          );
        },
      );

  Widget _ohneDiashow(BuildContext context) => PartyRahmen(
        titel: sitzung.ui('ui.intro.titel'),
        aktionen: [PartyKnopf(text: sitzung.ui('ui.intro.weiter'), onPressed: sitzung.kannWeiter ? sitzung.weiter : null)],
        child: _mappe(context, ErzaehlerFeld(sitzung: sitzung, kennungen: sitzung.erzaehler)),
      );

  Widget _mitDiashow(BuildContext context) {
    final s = sitzung;
    final show = s.diashow!;
    final n = show.dias.length;
    final nr = s.dia.clamp(0, n - 1);
    final kennungen = s.erzaehler;
    // Der Baustein zum Bild: Die Diashow hat je Abschnitt des Intros genau ein Bild.
    final zumBild = kennungen.indexWhere((k) => show.nrFuer(k) == nr);
    final letztes = nr >= n - 1;
    final beschriftung = s.ui('ui.intro.bild', {'nr': '${nr + 1}', 'anzahl': '$n'});
    final bild = DiashowAnsicht(key: const ValueKey('intro-diashow'), daten: s.daten, nr: nr, beschriftung: beschriftung);
    final zaehler = Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: ExcludeSemantics(
        child: Text(beschriftung.toUpperCase(), key: const ValueKey('dia-zaehler'), style: context.schrift.marke, textAlign: TextAlign.center),
      ),
    );
    // Liest ein anderes Gerät vor, zeigt das Feld nur, wer liest; sonst den Baustein zum Bild.
    final feld = s.istVorleser
        ? ErzaehlerFeld(
            sitzung: s,
            kennungen: kennungen,
            nur: zumBild < 0 ? null : zumBild,
            onBaustein: (i) {
              final d = show.nrFuer(kennungen[i]);
              if (d != null) s.diaSetzen(d);
            },
          )
        : ErzaehlerFeld(sitzung: s, kennungen: kennungen);
    return PartyRahmen(
      titel: s.ui('ui.intro.titel'),
      aktionen: [
        if (!letztes)
          PartyKnopf(
            key: const ValueKey('dia-naechstes'),
            text: s.ui('ui.intro.naechstes'),
            icon: Icons.photo_library_outlined,
            onPressed: s.diaSteuerbar ? () => s.diaSetzen(nr + 1) : null,
          ),
        PartyKnopf(text: s.ui('ui.intro.weiter'), haupt: letztes, onPressed: s.kannWeiter ? s.weiter : null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bild,
          zaehler,
          if (s.istVorleser) _mappe(context, feld) else feld,
        ],
      ),
    );
  }
}
