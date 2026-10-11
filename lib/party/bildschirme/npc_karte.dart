import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../party_stil.dart';
import '../sitzung.dart';

/// Fundkarte nach einer Entscheidung (F4-BAUMEISTER-09, Master 7.7 und 7.10).
/// Was die Handlung zeigt, steht wortgleich im Kanon. Bei einer Person zeigt
/// die Karte Name, Farbe und Rolle und sagt, ob ein Gast die Rolle spielt.
/// So erreicht das Wissen unbesetzter Rollen den Detektiv über die Karte.
class FundKarte extends StatelessWidget {
  const FundKarte({super.key, required this.sitzung, required this.ziel, required this.funde, required this.onGelesen});

  final PartySitzung sitzung;
  final KartenZiel ziel;
  final List<Aufdeckung> funde;
  final VoidCallback onGelesen;

  @override
  Widget build(BuildContext context) {
    final person = ziel.person;
    return PartyTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          person == null
              ? _OrtKopf(sitzung: sitzung, ziel: ziel)
              : _PersonKopf(sitzung: sitzung, ziel: ziel, person: person),
          if (funde.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(sitzung.ui('ui.karte.fund').toUpperCase(), style: context.schrift.marke),
            const SizedBox(height: 8),
            for (final f in funde) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(f.text, style: Keller.text)),
          ],
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: PartyKnopf(text: sitzung.ui('ui.karte.gelesen'), onPressed: onGelesen)),
        ],
      ),
    );
  }
}

/// Personenkarte: Farbpunkt, Name und Rolle. Trägt die Person einen
/// Gegenstand, steht er darunter. Ob ein Gast die Rolle spielt, sagt ein Satz.
class _PersonKopf extends StatelessWidget {
  const _PersonKopf({required this.sitzung, required this.ziel, required this.person});

  final PartySitzung sitzung;
  final KartenZiel ziel;
  final String person;

  @override
  Widget build(BuildContext context) {
    final titel = sitzung.figurTitel(person);
    final besetzt = sitzung.besetzt.contains(person);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            FarbPunkt(sitzung.figurFarbe(person), groesse: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sitzung.figurName(person), style: Keller.ueberschrift),
                  if (titel.isNotEmpty) Text(titel, style: Keller.leise),
                ],
              ),
            ),
          ],
        ),
        if (ziel.art == ZielArt.gegenstand) ...[
          const SizedBox(height: 10),
          Text(ziel.name, style: Keller.text),
        ],
        const SizedBox(height: 12),
        Text(
          sitzung.solo ? sitzung.ui('ui.solo.gast') :
              besetzt ? sitzung.ui('ui.npc.besetzt', {'name': sitzung.spielerName(person)}) : sitzung.ui('ui.npc.unbesetzt'),
          style: Keller.text,
        ),
      ],
    );
  }
}

/// Ortskarte für Gegenstände und Räume: Symbol, Name der Stelle und der Raum.
/// Bei einem Raum steht der Name schon oben, daher kommt er nicht noch einmal.
class _OrtKopf extends StatelessWidget {
  const _OrtKopf({required this.sitzung, required this.ziel});

  final PartySitzung sitzung;
  final KartenZiel ziel;

  @override
  Widget build(BuildContext context) {
    final raum = sitzung.kanon.graph.raeume[ziel.raum]!.anzeigename;
    return Row(
      children: [
        Icon(ziel.art == ZielArt.raum ? Icons.meeting_room : Icons.search, size: 40, color: context.farben.akzent),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ziel.name, style: Keller.ueberschrift),
              if (raum != ziel.name) Text(raum, style: Keller.leise),
            ],
          ),
        ),
      ],
    );
  }
}
