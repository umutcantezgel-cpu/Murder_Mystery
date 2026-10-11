import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';

import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Der Mensch bleibt Detektiv: eine öffentliche Sprechblase nach der anderen,
/// ohne Rollenwechsel, Gesprächsuhr oder Zugriff auf ein fremdes Dossier.
class SoloGespraecheBildschirm extends StatefulWidget {
  const SoloGespraecheBildschirm({super.key, required this.sitzung});
  final PartySitzung sitzung;

  @override
  State<SoloGespraecheBildschirm> createState() => _SoloGespraecheBildschirmState();
}

class _SoloGespraecheBildschirmState extends State<SoloGespraecheBildschirm> {
  int _nummer = 0;
  PartySitzung get s => widget.sitzung;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: s,
    builder: (context, _) {
      final liste = s.soloGespraeche;
      final g = _nummer < liste.length ? liste[_nummer] : null;
      return PartyRahmen(
        key: ValueKey('solo-${s.runde}-$_nummer'),
        marke: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
        titel: s.ui('ui.solo.gespraeche'),
        untertitel: s.ui('ui.solo.gespraeche_hinweis'),
        aktionen: [
          if (_nummer > 0) PartyKnopf(text: s.ui('ui.solo.vorheriges'), haupt: false,
            onPressed: () => setState(() => _nummer--)),
          if (g != null) PartyKnopf(text: s.ui('ui.solo.gehoert'), onPressed: () {
            s.soloGespraechGelesen(g.id);
            setState(() => _nummer++);
          }),
          if (s.kannWeiter) PartyKnopf(text: s.ui('ui.runde.weiter'), onPressed: s.weiter),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_nummer == 0) ...[
            ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
            const SizedBox(height: 20),
          ],
          if (g != null) ...[
            Text(s.ui('ui.solo.fortschritt', {'nr': '${_nummer + 1}', 'gesamt': '${liste.length}'}), style: context.schrift.marke),
            const SizedBox(height: 12),
            BotSprechblase(sitzung: s, gespraech: g),
          ] else PartyTafel(child: Text(s.ui('ui.solo.fertig'), style: Keller.text)),
        ]),
      );
    },
  );
}

/// Auch das Notizbuch verwendet nur diese öffentliche, unveränderliche Ansicht.
class BotSprechblase extends StatelessWidget {
  const BotSprechblase({super.key, required this.sitzung, required this.gespraech});
  final PartySitzung sitzung;
  final BotGespraech gespraech;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final g = gespraech;
    return Container(
      key: ValueKey(g.id),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Keller.stein,
        border: Border.all(color: s.figurFarbe(g.rolle).withValues(alpha: 0.7)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18), topRight: Radius.circular(18),
          bottomRight: Radius.circular(18), bottomLeft: Radius.circular(3),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          FarbPunkt(s.figurFarbe(g.rolle), groesse: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(s.figurName(g.rolle), style: Keller.ueberschrift)),
        ]),
        Text(s.ui('ui.rollen.gespraech_mit', {'name': s.personAmTisch(g.partner)}), style: Keller.leise),
        if (!s.besetzt.contains(g.rolle)) Text(s.ui('ui.solo.npc'), style: Keller.leise),
        const SizedBox(height: 12),
        Text(g.thema, style: Keller.leise),
        const SizedBox(height: 8),
        Text(g.text, style: Keller.text),
        for (final z in g.preisgaben) ...[
          const SizedBox(height: 12),
          Text(z.text, style: Keller.text),
        ],
      ]),
    );
  }
}
