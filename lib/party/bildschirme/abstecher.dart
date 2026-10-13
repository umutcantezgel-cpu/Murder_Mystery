import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';

import '../../karten/widgets/karten_ansicht.dart';
import '../../karten/widgets/karten_hand.dart';
import '../../stil/mappe/abend2_bausteine.dart';
import '../../stil/stil.dart';
import '../karten_figur.dart';
import '../sitzung.dart';
import 'npc_karte.dart';

/// Frage vor einem Abstecher: Name, Hinweis auf Freiwilligkeit und Kosten, auf
/// Wunsch eine Abstecher-Karte (kostenlos). Erst „Erkunden“ beginnt den Weg.
///
/// Gestaltet als Karteikarte mit Formularkopf; die Hand liegt in der dunklen
/// Kartenablage auf der Karte.
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
    return MBlatt(
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      klebestreifen: true,
      neigung: -0.005,
      samen: widget.ort.id.codeUnits.fold(5, (a, b) => (a * 31 + b) & 0xffff),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(KartenTexte.erkundenMarke, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
          const SizedBox(height: 4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          Text(widget.ort.name, style: MPapierSchrift.ueberschrift),
          const SizedBox(height: 10),
          Text(KartenTexte.erkundenText, style: MPapierSchrift.text),
          const SizedBox(height: 8),
          Text(KartenTexte.erkundenKosten(p.abstecher, p.abstecherPechZeit), style: MPapierSchrift.maschine.copyWith(fontSize: 14, color: MRoh.tinteLeise)),
          if (s.hatKarten) ...[
            const SizedBox(height: 12),
            MKartenablage(
              child: KartenHand(
                vorrat: s.vorrat,
                aktiv: karten,
                gewaehlt: {?eingesetzt},
                hinweis: def == null ? null : KartenTexte.erkundenKarte(def.titel),
                figurVon: s.kartenFigur,
                onTipp: (k) {
                  if (k.art != KartenArt.abstecher || !s.vorrat.verfuegbar(k.id)) return;
                  setState(() => _karte = _karte == k.id ? null : k.id);
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 8,
            children: [
              MKnopf(text: KartenTexte.erkundenNein, art: MKnopfArt.zweit, onPressed: widget.onAbbruch),
              MKnopf(text: KartenTexte.erkundenLos, icon: Icons.explore_rounded, onPressed: () => widget.onLos(eingesetzt)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fund eines Abstechers: Ort und Nebenfund (Stimmung, nie ein Hinweis zum Fall).
/// Im Stil der [FundKarte] einer Entscheidung: ein Beweisanhänger, dessen Kopf
/// „Nebenfund“ heißt.
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
    return MBeweisanhaenger(
      // Die Marke in Versalien bleibt: Tests und Browserproben suchen sie so.
      kopf: KartenTexte.erkundenFund.toUpperCase(),
      neigung: 0.006,
      samen: ort.id.codeUnits.fold(9, (a, b) => (a * 31 + b) & 0xffff),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          OrtZeile(symbol: Icons.explore_rounded, name: ort.name, unter: raumName != null && raumName != ort.name ? raumName : null),
          const SizedBox(height: 16),
          Text(text, style: MPapierSchrift.maschine),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: MKnopf(text: sitzung.ui('ui.karte.gelesen'), onPressed: onGelesen)),
        ],
      ),
    );
  }
}
