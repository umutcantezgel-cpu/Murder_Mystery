import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';

import '../../karten/widgets/karten_ansicht.dart';
import '../../karten/widgets/karten_hand.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Frage vor einem Abstecher: Name, Hinweis auf Freiwilligkeit und Kosten, auf
/// Wunsch eine Abstecher-Karte (kostenlos). Erst „Erkunden“ beginnt den Weg.
class AbstecherBestaetigung extends StatefulWidget {
  const AbstecherBestaetigung({super.key, required this.sitzung, required this.ort, required this.onAbbruch, required this.onLos});

  final PartySitzung sitzung;
  final AbstecherOrt ort;
  final VoidCallback onAbbruch;

  /// Beginnt die Erkundung; [karte] ist die eingesetzte Abstecher-Karte oder null.
  final ValueChanged<String?> onLos;

  @override
  State<AbstecherBestaetigung> createState() => _AbstecherBestaetigungState();
}

class _AbstecherBestaetigungState extends State<AbstecherBestaetigung> {
  String? _karte;

  PartySitzung get s => widget.sitzung;

  @override
  Widget build(BuildContext context) {
    const p = ZugParameter();
    final karten = kartenDerArt(s.vorrat, const {KartenArt.abstecher});
    final eingesetzt = karten.contains(_karte) ? _karte : null;
    final def = karten.isEmpty ? null : s.vorrat.karte(karten.first);
    return PartyTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(KartenTexte.erkundenMarke.toUpperCase(), style: Keller.marke),
          const SizedBox(height: 8),
          Text(widget.ort.name, style: Keller.ueberschrift),
          const SizedBox(height: 10),
          Text(KartenTexte.erkundenText, style: Keller.text),
          const SizedBox(height: 8),
          Text(KartenTexte.erkundenKosten(p.abstecher, p.abstecherPechZeit), style: Keller.leise),
          if (s.hatKarten) ...[
            const SizedBox(height: 12),
            Center(child: KartenHand(
              vorrat: s.vorrat,
              aktiv: karten,
              gewaehlt: {?eingesetzt},
              hinweis: def == null ? null : KartenTexte.erkundenKarte(def.titel),
              onTipp: (k) {
                if (k.art != KartenArt.abstecher || !s.vorrat.verfuegbar(k.id)) return;
                setState(() => _karte = _karte == k.id ? null : k.id);
              },
            )),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 8,
            children: [
              PartyKnopf(text: KartenTexte.erkundenNein, haupt: false, onPressed: widget.onAbbruch),
              PartyKnopf(text: KartenTexte.erkundenLos, icon: Icons.explore_rounded, onPressed: () => widget.onLos(eingesetzt)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fund eines Abstechers: Ort und Nebenfund (Stimmung, nie ein Hinweis zum Fall).
/// Im Stil der [FundKarte] einer Entscheidung.
class AbstecherFundKarte extends StatelessWidget {
  const AbstecherFundKarte({super.key, required this.sitzung, required this.ort, required this.text, required this.onGelesen});

  final PartySitzung sitzung;
  final AbstecherOrt ort;
  final String text;
  final VoidCallback onGelesen;

  @override
  Widget build(BuildContext context) {
    final raum = sitzung.kanon.graph.orte[ort.ort]?.raum;
    final raumName = raum == null ? null : sitzung.kanon.graph.raeume[raum]?.anzeigename;
    return PartyTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.explore_rounded, size: 40, color: Keller.kerze),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ort.name, style: Keller.ueberschrift),
                    if (raumName != null && raumName != ort.name) Text(raumName, style: Keller.leise),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(KartenTexte.erkundenFund.toUpperCase(), style: Keller.marke),
          const SizedBox(height: 8),
          Text(text, style: Keller.text),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: PartyKnopf(text: sitzung.ui('ui.karte.gelesen'), onPressed: onGelesen)),
        ],
      ),
    );
  }
}
