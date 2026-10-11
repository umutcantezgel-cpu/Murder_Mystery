import 'package:flutter/material.dart';

import '../../l10n/lookup.dart';
import '../../party/party_stil.dart';
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gastgeber_sitzung.dart';

/// Rollenphase auf dem Gastgebergerät: Jede Person liest ihre Rolle auf dem
/// eigenen Gerät; hier steht nur, wer schon fertig ist. Statt der Geräteübergabe
/// des Spiels an einem Gerät (`RollenBildschirm`), im selben Rahmen.
class GastgeberRollenWarten extends StatelessWidget {
  const GastgeberRollenWarten({super.key, required this.sitzung});

  final GastgeberSitzung sitzung;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: sitzung,
        builder: (context, _) {
          final s = sitzung;
          final l = L.of(context);
          final t = MSchrift.von(context);
          final menschen = [for (final g in s.dienst.gaeste) if (g.rolle != null) g];
          final gelesen = menschen.where((g) => s.gelesen.contains(g.rolle)).length;
          final alle = gelesen == menschen.length;
          return PartyRahmen(
            marke: s.ui('ui.rollen.marke'),
            titel: s.ui('ui.rollen.titel'),
            aktionen: [PartyKnopf(text: s.ui('ui.rollen.weiter'), onPressed: s.kannWeiter ? s.weiter : null)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.online_rollen_erklaerung, style: t.text),
                const SizedBox(height: MMass.s16),
                MTafel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        menschen.isEmpty
                            ? l.online_rollen_ohne_gaeste
                            : alle
                                ? l.online_rollen_alle
                                : l.online_rollen_warten(gelesen, menschen.length),
                        key: const ValueKey('rollen-warten'),
                        style: t.ueberschrift,
                      ),
                      if (menschen.isNotEmpty) const SizedBox(height: MMass.s12),
                      for (final g in menschen)
                        _GastZeile(
                          name: g.name,
                          figur: s.figurName(g.rolle!),
                          farbe: s.figurFarbe(g.rolle!),
                          fertig: s.gelesen.contains(g.rolle),
                          online: g.online,
                          fertigText: l.online_rollen_gelesen,
                          offenText: l.online_rollen_liest,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}

/// Gruppenwahl auf dem Gastgebergerät: Die Gäste wählen auf ihren Geräten, die
/// Bots stimmen selbst ab. Gezeigt wird nur, wer schon gewählt hat, nie was.
class GastgeberGruppenwahl extends StatelessWidget {
  const GastgeberGruppenwahl({super.key, required this.sitzung});

  final GastgeberSitzung sitzung;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: sitzung,
        builder: (context, _) {
          final s = sitzung;
          final l = L.of(context);
          final t = MSchrift.von(context);
          final menschen = [for (final g in s.dienst.gaeste) if (g.rolle != null) g];
          final fertig = menschen.where((g) => s.gestimmt.contains(g.rolle)).length;
          return PartyRahmen(
            marke: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
            titel: s.ui('ui.gruppenwahl.titel'),
            untertitel: l.online_wahl_hinweis,
            aktionen: [
              if (s.alleGestimmt) PartyKnopf(text: s.ui('ui.allgemein.weiter'), onPressed: s.kannWeiter ? s.weiter : null),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MTafel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        s.alleGestimmt
                            ? s.ui('ui.gruppenwahl.alle')
                            : menschen.isEmpty
                                ? l.online_wahl_nur_bots
                                : l.online_wahl_fortschritt(fertig, menschen.length),
                        key: const ValueKey('wahl-fortschritt'),
                        style: t.ueberschrift,
                      ),
                      if (menschen.isNotEmpty) const SizedBox(height: MMass.s12),
                      for (final g in menschen)
                        _GastZeile(
                          name: g.name,
                          figur: s.figurName(g.rolle!),
                          farbe: s.figurFarbe(g.rolle!),
                          fertig: s.gestimmt.contains(g.rolle),
                          online: g.online,
                          fertigText: l.online_wahl_abgegeben_kurz,
                          offenText: l.online_wahl_waehlt,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}

/// Ein Gast mit Farbpunkt, Figur und Zustand (fertig, noch dabei, getrennt).
class _GastZeile extends StatelessWidget {
  const _GastZeile({
    required this.name,
    required this.figur,
    required this.farbe,
    required this.fertig,
    required this.online,
    required this.fertigText,
    required this.offenText,
  });

  final String name;
  final String figur;
  final Color farbe;
  final bool fertig;
  final bool online;
  final String fertigText;
  final String offenText;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final MChip marke = fertig
        ? MChip(fertigText, icon: Icons.check_circle_rounded, farbe: f.erfolg)
        : online
            ? MChip(offenText, icon: Icons.hourglass_empty_rounded, farbe: f.papierLeise)
            : MChip(l.online_getrennt, icon: Icons.wifi_off_rounded, farbe: f.warnung);
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: Row(
        children: [
          Padding(padding: const EdgeInsets.only(right: MMass.s12), child: FarbPunkt(farbe)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: t.text),
                if (figur != name) Text(figur, style: t.leise),
              ],
            ),
          ),
          const SizedBox(width: MMass.s8),
          Flexible(child: marke),
        ],
      ),
    );
  }
}

/// Zeile `Name (online/offline)` für die Raumübersicht im Menü des Gastgebers.
class PlatzZeile extends StatelessWidget {
  const PlatzZeile({super.key, required this.spieler});

  final SpielerInfo spieler;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s8),
      child: Row(
        children: [
          Expanded(child: Text(spieler.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.text)),
          const SizedBox(width: MMass.s8),
          Flexible(
            child: spieler.istGastgeber
                ? MChip(l.online_spielleitung, icon: Icons.star_rounded)
                : spieler.online
                    ? MChip(l.online_verbunden, icon: Icons.wifi_rounded, farbe: f.erfolg)
                    : MChip(l.online_getrennt, icon: Icons.wifi_off_rounded, farbe: f.warnung),
          ),
        ],
      ),
    );
  }
}
