import 'package:flutter/material.dart';

import '../../l10n/lookup.dart';
import '../../party/bildschirme/detektiv_karte.dart';
import '../../party/party_stil.dart';
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gastgeber_sitzung.dart';
import 'online_teile.dart';

/// Rollenphase auf dem Gastgebergerät: Jede Person liest ihre Rolle auf dem
/// eigenen Gerät; hier steht nur, wer schon fertig ist. Statt der Geräteübergabe
/// des Spiels an einem Gerät (`RollenBildschirm`), im selben Rahmen: ein
/// Wartezettel, das Gästeregister mit den Fotoabzügen der Figuren und darunter
/// die Bots mit ihrem Stempel.
class GastgeberRollenWarten extends StatelessWidget {
  const GastgeberRollenWarten({super.key, required this.sitzung});

  final GastgeberSitzung sitzung;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: sitzung,
        builder: (context, _) {
          final s = sitzung;
          final l = L.of(context);
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
                Text(l.online_rollen_erklaerung, style: context.schrift.text),
                const SizedBox(height: MMass.s16),
                // Der Gastgeber ermittelt (bis es Sitze gibt): seine Detektivkarte.
                DetektivKarteEintrag(sitzung: s),
                const SizedBox(height: MMass.s16),
                OnlineWarteNotiz(
                  text: menschen.isEmpty
                      ? l.online_rollen_ohne_gaeste
                      : alle
                          ? l.online_rollen_alle
                          : l.online_rollen_warten(gelesen, menschen.length),
                  textKey: const ValueKey('rollen-warten'),
                  gross: true,
                  uhr: !alle,
                ),
                const SizedBox(height: MMass.s24),
                for (var i = 0; i < menschen.length; i++)
                  _GastZeile(
                    nr: i,
                    name: menschen[i].name,
                    rolle: menschen[i].rolle!,
                    sitzung: s,
                    fertig: s.gelesen.contains(menschen[i].rolle),
                    online: menschen[i].online,
                    fertigText: l.online_rollen_gelesen,
                    offenText: l.online_rollen_liest,
                  ),
                _Bots(sitzung: s),
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
                OnlineWarteNotiz(
                  text: s.alleGestimmt
                      ? s.ui('ui.gruppenwahl.alle')
                      : menschen.isEmpty
                          ? l.online_wahl_nur_bots
                          : l.online_wahl_fortschritt(fertig, menschen.length),
                  textKey: const ValueKey('wahl-fortschritt'),
                  gross: true,
                  uhr: !s.alleGestimmt && menschen.isNotEmpty,
                ),
                const SizedBox(height: MMass.s24),
                for (var i = 0; i < menschen.length; i++)
                  _GastZeile(
                    nr: i,
                    name: menschen[i].name,
                    rolle: menschen[i].rolle!,
                    sitzung: s,
                    fertig: s.gestimmt.contains(menschen[i].rolle),
                    online: menschen[i].online,
                    fertigText: l.online_wahl_abgegeben_kurz,
                    offenText: l.online_wahl_waehlt,
                  ),
                _Bots(sitzung: s),
              ],
            ),
          );
        },
      );
}

/// Ein Gast als Karteikarte: Fotoabzug der Figur, Name, Figur und Zustand
/// (Stempel, wenn fertig; sonst „noch dabei“ oder „getrennt“).
class _GastZeile extends StatelessWidget {
  const _GastZeile({
    required this.nr,
    required this.name,
    required this.rolle,
    required this.sitzung,
    required this.fertig,
    required this.online,
    required this.fertigText,
    required this.offenText,
  });

  final int nr;
  final String name;
  final String rolle;
  final GastgeberSitzung sitzung;
  final bool fertig;
  final bool online;
  final String fertigText;
  final String offenText;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final figur = sitzung.figurName(rolle);
    final Widget marke = fertig
        ? onlineStempel(fertigText)
        : online
            ? MChip(offenText, icon: Icons.hourglass_empty_rounded, farbe: MRoh.tinteLeise)
            : MChip(l.online_getrennt, icon: Icons.wifi_off_rounded, farbe: onlineWarnTinte);
    return OnlinePlatzKarte(
      nr: nr,
      name: name,
      unter: figur != name ? figur : null,
      look: sitzung.figurAussehen(rolle),
      farbe: sitzung.figurFarbe(rolle),
      zustand: marke,
    );
  }
}

/// Die Rollen ohne Gast: Fotoabzüge mit dem Stempel „Bot“.
class _Bots extends StatelessWidget {
  const _Bots({required this.sitzung});

  final GastgeberSitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final menschen = s.menschenRollen.toSet();
    final bots = [for (final r in s.besetzt) if (!menschen.contains(r)) r];
    if (bots.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: MMass.s12),
      child: OnlineBotReihe(
        stempel: L.of(context).online_bot_stempel,
        bots: [for (final r in bots) (look: s.figurAussehen(r), name: s.figurName(r), farbe: s.figurFarbe(r))],
      ),
    );
  }
}

/// Zeile `Name (online/offline)` für die Raumübersicht im Menü des Gastgebers.
/// Auf der Karteikarte in Tinte, auf dem Schreibtisch hell.
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
