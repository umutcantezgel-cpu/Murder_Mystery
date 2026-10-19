import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../stil/stil.dart';
import '../sitzung.dart';

/// Spickzettel einer Rolle für eine Runde (Modell befragung, A-051), nur in der
/// verdeckten Ansicht dieser Rolle: das eigene Tischgespräch in Stichpunkten,
/// wer sie anspricht und was sie sagt, wenn der Detektiv sie befragt. Kein
/// Wissen über andere Rollen, keine Ziele anderer und nichts aus einer anderen
/// Runde. Gesetzt wie die Abschnitte des Dossiers.
class SpickzettelInhalt extends StatelessWidget {
  const SpickzettelInhalt({super.key, required this.sitzung, required this.rolle, required this.runde, this.befragungZuerst = false});

  final PartySitzung sitzung;
  final String rolle;
  final int runde;

  /// Hat der Detektiv gerade gefragt? Dann steht die Befragung oben.
  final bool befragungZuerst;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final d = s.dossier(rolle);
    final tisch = d.gespraeche[runde] ?? const <(Gespraech, String)>[];
    final angesprochen = d.alsPartner[runde] ?? const <(Gespraech, String)>[];
    final abschnitte = [
      _abschnitt(s.ui('ui.befragung.tisch_eigen'), [for (final (g, partner) in tisch) _tisch(g, partner)]),
      _abschnitt(s.ui('ui.befragung.anspricht'), [
        if (angesprochen.isEmpty) Text(s.ui('ui.befragung.niemand'), style: MPapierSchrift.leise),
        for (final (g, sprecher) in angesprochen)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.spielerName(sprecher), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
                Text(g.thema, style: MPapierSchrift.maschine.copyWith(fontSize: 14)),
              ],
            ),
          ),
      ]),
      if (d.befragungen[runde] case final b?) _abschnitt(s.ui('ui.befragung.dich'), _befragung(s, b)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: befragungZuerst && abschnitte.length == 3 ? [abschnitte[2], abschnitte[0], abschnitte[1]] : abschnitte,
    );
  }

  /// Das eigene Tischgespräch: mit wem, Thema, Ziel, Stichpunkte.
  Widget _tisch(Gespraech g, String partner) {
    final s = sitzung;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.ui('ui.rollen.gespraech_mit', {'name': s.personAmTisch(partner)}), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17, height: 1.4)),
          const SizedBox(height: 4),
          Text(s.ui('ui.rollen.gespraech_thema'), style: MPapierSchrift.leise),
          Text(g.thema, style: MPapierSchrift.text),
          const SizedBox(height: 4),
          Text(s.ui('ui.rollen.gespraech_ziel'), style: MPapierSchrift.leise),
          Text(g.ziel, style: MPapierSchrift.text),
          const SizedBox(height: 4),
          Text(s.ui('ui.befragung.stichpunkte'), style: MPapierSchrift.leise),
          for (final p in g.stichpunkte) spickPunkt(p),
        ],
      ),
    );
  }

  /// Die eigene Befragung: ob und wie der Detektiv fragt, Thema, Fragen und was die Rolle sagt.
  List<Widget> _befragung(PartySitzung s, BefragungText b) {
    final z = s.spickzettel(rolle, runde);
    final karte = runde == s.runde ? s.befragungVon(rolle) : null;
    final fest = s.befragungFest(rolle, runde);
    final frage = karte?.frage;
    final stand = frage != null
        ? s.ui('ui.befragung.fragt', {'frage': karte!.fragen[frage]})
        : fest == true
            ? s.ui('ui.befragung.sicher')
            : karte != null && !karte.waehlbar
                ? s.ui('ui.befragung.entfaellt')
                : fest == false
                    ? s.ui('ui.befragung.vielleicht')
                    : null;
    final karten = z.kartenZeilen((x) => s.ui('ui.befragung.behaupte', {'text': x}));
    return [
      if (stand != null) ...[
        Text(stand, style: frage != null ? MPapierSchrift.hand.copyWith(fontSize: 22) : MPapierSchrift.kursiv),
        const SizedBox(height: 8),
      ],
      Text(s.ui('ui.befragung.thema'), style: MPapierSchrift.leise),
      Text(b.thema, style: MPapierSchrift.text),
      const SizedBox(height: 4),
      Text(s.ui('ui.befragung.fragen'), style: MPapierSchrift.leise),
      for (final f in b.fragen) spickPunkt(f),
      const SizedBox(height: 4),
      Text(s.ui('ui.befragung.sagen'), style: MPapierSchrift.leise),
      if (karten.isEmpty) Text(s.ui('ui.befragung.nichts'), style: MPapierSchrift.kursiv),
      ...spickKarten(karten),
    ];
  }

  Widget _abschnitt(String titel, List<Widget> kinder) => Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titel, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, fontSize: 15)),
            const SizedBox(height: 4),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
            const SizedBox(height: 10),
            ...kinder,
          ],
        ),
      );
}

/// Mehrere Karten untereinander (R17, E-044): je Karte ihre Stichpunkte,
/// zwischen zwei Karten ein feiner Strich. So steht nie mehr als eine Karte in
/// einem Block, auch wenn eine Befragung zwei Preisgaben und Würze hat.
List<Widget> spickKarten(List<List<String>> karten) => [
      for (final (i, k) in karten.indexed) SpickKarte(zeilen: k, trenner: i > 0),
    ];

/// Eine Karte des Spickzettels: höchstens drei Stichpunkte, darüber auf Wunsch ein Trennstrich.
class SpickKarte extends StatelessWidget {
  const SpickKarte({super.key, required this.zeilen, this.trenner = false});

  final List<String> zeilen;
  final bool trenner;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trenner)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 2, bottom: 8),
              child: Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.18)),
            ),
          for (final z in zeilen) spickPunkt(z),
        ],
      );
}

/// Eine Zeile mit Tintenpunkt (Stichpunkt auf Papier).
Widget spickPunkt(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 9, right: 10),
            child: Container(width: 6, height: 6, decoration: BoxDecoration(color: MRoh.stempelRot.withValues(alpha: 0.8), shape: BoxShape.circle)),
          ),
          Expanded(child: Text(text, style: MPapierSchrift.text)),
        ],
      ),
    );
