import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show RundgangTeil, RundgangText;

import '../../party/bildschirme/erzaehlerpult.dart' show VorleserKarte;
import '../../party/bildschirme/rundgang.dart' show RundgangKarteBlatt;
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_ansicht.dart' show GastKontext;
import 'online_teile.dart';

/// Der laufende Rundgang des Raums (Vorspiel oder Morgen, Langer Abend M7b),
/// sonst `null`: öffentlich `rundgang` mit Teil, Station und Karte.
Map<String, Object?>? gastRundgang(GastKontext c) => c.v['rundgang'] is Map ? jMap(c.v['rundgang']) : null;

/// Teil des laufenden Rundgangs, sonst `null`.
RundgangTeil? gastRundgangTeil(GastKontext c) => RundgangTeil.lesen(gastRundgang(c)?['teil']);

/// Vorspiel oder Morgen auf dem Gerät eines Gastes (M7b): „Das Vorspiel
/// läuft“ bzw. „Der Morgen läuft“, die Karte der Station nach R17 (Titel und
/// Stichpunkte) für alle und den Vorlesetext nur beim Vorleser-Sitz (privat
/// `rundgangText`); alle anderen sehen, wer vorliest. Wer leitet, schaltet zur
/// nächsten Station oder überspringt den Rest ([gastRundgangAktionen]); alle
/// anderen sehen, wer führt. Die Karte des Rundgangs zeigt nur das Gerät, das
/// den Abend hält; hier reicht die Karte der Station.
class GastRundgang extends StatelessWidget {
  const GastRundgang({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  Widget build(BuildContext context) {
    final c = kontext;
    final l = c.l;
    final r = gastRundgang(c)!;
    final teil = gastRundgangTeil(c);
    final station = jZahl(r['station']);
    final anzahl = jZahl(r['anzahl'], 1);
    final karte = jMap(r['karte']);
    final text = RundgangText(titel: jText(karte['titel']), punkte: jTexte(karte['punkte']), vorlesen: '');
    final vorlesen = c.privat['rundgangText'];
    return Column(
      key: ValueKey('gast-rundgang-${teil?.name}-$station'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: MMass.s12),
          child: Text(
            (teil == RundgangTeil.morgen ? l.rundgang_laeuft_morgen : l.rundgang_laeuft_vorspiel).toUpperCase(),
            key: const ValueKey('gast-rundgang-laeuft'),
            style: c.t.marke,
          ),
        ),
        RundgangKarteBlatt(text: text, zaehler: l.rundgang_station('${station + 1}', '$anzahl')),
        const SizedBox(height: MMass.s12),
        if (vorlesen is String)
          MBlatt(
            key: const ValueKey('gast-rundgang-vorlesetext'),
            klammer: true,
            neigung: 0.004,
            samen: vorlesen.length,
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 20),
            child: MGanzeWorte(vorlesen, stil: MPapierSchrift.erzaehler, minimum: 14),
          )
        else
          VorleserKarte(name: c.leiterName, texte: 1),
        if (!c.leitet) ...[
          const SizedBox(height: MMass.s16),
          OnlineWarteNotiz(text: l.rundgang_fuehrt(c.leiterName.isEmpty ? l.vorleser_erzaehler : c.leiterName), uhr: false),
        ],
      ],
    );
  }
}

/// Knöpfe des Rundgangs für das Gerät, das leitet: zur nächsten Station (an der
/// letzten zur Einleitung bzw. zum Schluss) und den Rest überspringen. Sonst keine.
List<Widget> gastRundgangAktionen(GastKontext c) {
  final r = gastRundgang(c);
  if (r == null || !c.leitet) return const [];
  final l = c.l;
  final teil = gastRundgangTeil(c);
  final station = jZahl(r['station']);
  final letzte = station >= jZahl(r['anzahl'], 1) - 1;
  return [
    if (!letzte)
      MKnopf(
        key: const ValueKey('gast-rundgang-ueberspringen'),
        text: l.rundgang_ueberspringen,
        art: MKnopfArt.zweit,
        icon: Icons.fast_forward_rounded,
        onPressed: c.verbunden ? () => c.befehl({'typ': 'rundgang', 'ueberspringen': true}) : null,
      ),
    MKnopf(
      key: const ValueKey('gast-rundgang-weiter'),
      text: letzte ? (teil == RundgangTeil.morgen ? l.rundgang_zum_schluss : l.rundgang_zur_einleitung) : l.rundgang_weiter,
      icon: Icons.arrow_forward_rounded,
      onPressed: c.verbunden ? () => c.befehl({'typ': 'rundgang', 'station': station}) : null,
    ),
  ];
}
