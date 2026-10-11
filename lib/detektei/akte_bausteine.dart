import 'package:flutter/material.dart';

import '../l10n/lookup.dart';
import '../stil/stil.dart';
import 'akten.dart';

/// Ton einer Akte in Worten (`spuk` → „Spuk“); unbekannte Töne erscheinen, wie sie in der Datei stehen.
String akteTonText(L l, String ton) => switch (ton) {
      'spuk' => l.detektei_ton_spuk,
      _ => ton,
    };

/// Kürzel im Siegel einer Akte: das des Akten-Stils, sonst die ersten Buchstaben des Titels.
String akteSigel(AkteInfo akte) {
  final stil = AkteStil.fuer(akte.id);
  return stil.id.isEmpty ? akte.kuerzel : stil.sigel;
}

/// Deckel einer Akte: Verlauf in den Farben der Akte mit zwei Ringen und dem
/// Siegel. Die Fläche füllt den verfügbaren Platz; [siegel] ist der Durchmesser.
class AkteDeckel extends StatelessWidget {
  const AkteDeckel({super.key, required this.akte, this.siegel = 56});

  final AkteInfo akte;
  final double siegel;

  @override
  Widget build(BuildContext context) {
    final stil = AkteStil.fuer(akte.id);
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [stil.hintergrund, Color.lerp(stil.hintergrund, stil.akzent, 0.5)!],
          ),
        ),
        child: Center(
          child: Container(
            width: siegel,
            height: siegel,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x33000000),
              border: Border.all(color: stil.akzentHell.withValues(alpha: 0.8), width: 2),
            ),
            child: Container(
              width: siegel - 10,
              height: siegel - 10,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: stil.akzentHell.withValues(alpha: 0.4)),
              ),
              child: Text(
                akteSigel(akte),
                maxLines: 1,
                style: TextStyle(
                  fontFamily: MRohSchrift.anzeige,
                  fontSize: siegel * 0.36,
                  letterSpacing: 1,
                  color: stil.akzentHell,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Marken einer Akte: Ton und (falls bekannt) Zahl der Personen.
class AkteMarken extends StatelessWidget {
  const AkteMarken({super.key, required this.akte});

  final AkteInfo akte;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final stil = AkteStil.fuer(akte.id);
    final min = akte.minRollen, max = akte.maxRollen;
    return Wrap(
      spacing: MMass.s8,
      runSpacing: MMass.s8,
      children: [
        if (akte.ton.isNotEmpty) MChip(akteTonText(l, akte.ton), farbe: stil.akzent),
        if (min != null && max != null) MChip(l.detektei_personen(min, max), icon: Icons.group_outlined, farbe: f.papierLeise),
      ],
    );
  }
}

/// Karte einer Akte: Deckel links, Titel, Untertitel und Marken rechts.
///
/// In der Kampagnenliste ([gewaehlt] `null`) ist die Karte ein Knopf, dessen Text
/// der Bildschirmleser vorliest. Im Assistenten ([gewaehlt] gesetzt) ist sie eine
/// Auswahl mit dem Titel als Beschriftung und dem Untertitel als Hinweis.
class AkteKarte extends StatelessWidget {
  const AkteKarte({super.key, required this.akte, required this.onTap, this.gewaehlt});

  final AkteInfo akte;
  final VoidCallback onTap;
  final bool? gewaehlt;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final auswahl = gewaehlt != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: LayoutBuilder(
        builder: (context, box) {
          // Am kleinen Handy bleibt dem Titel genug Breite für „Schlosskeller“.
          final schmal = box.maxWidth < 340;
          final karte = MTafel(
            hervorgehoben: gewaehlt ?? false,
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: schmal ? 60 : 88, child: AkteDeckel(akte: akte, siegel: schmal ? 40 : 52)),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(schmal ? MMass.s12 : MMass.s16, MMass.s16, MMass.s8, MMass.s16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(akte.titel, style: t.ueberschrift),
                              if (akte.untertitel.isNotEmpty) ...[
                                const SizedBox(height: MMass.s4),
                                Text(akte.untertitel, style: t.leise),
                              ],
                              const SizedBox(height: MMass.s12),
                              AkteMarken(akte: akte),
                            ],
                          ),
                        ),
                      ),
                      if (auswahl || !schmal)
                        Padding(
                          padding: const EdgeInsets.only(right: MMass.s8),
                          child: Icon(
                            auswahl ? (gewaehlt! ? Icons.check_circle_rounded : Icons.circle_outlined) : Icons.chevron_right_rounded,
                            color: gewaehlt == true ? f.akzent : f.papierLeise,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
          if (!auswahl) return Semantics(button: true, child: karte);
          return Semantics(
            button: true,
            selected: gewaehlt,
            label: akte.titel,
            hint: akte.untertitel,
            onTap: onTap,
            excludeSemantics: true,
            child: karte,
          );
        },
      ),
    );
  }
}
