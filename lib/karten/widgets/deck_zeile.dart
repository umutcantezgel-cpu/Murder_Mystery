import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';
import 'package:provider/provider.dart';

import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../stil/stil.dart';
import 'karten_ansicht.dart';

/// Zeile „Deck für diesen Abend“ im Assistenten: die ausgerüsteten Karten des
/// Geräts und ein Knopf zum Ändern. Ohne Katalog zeigt sie nur den Knopf.
class DeckZeile extends StatelessWidget {
  const DeckZeile({super.key, required this.katalog, required this.onAendern});

  final KartenKatalog? katalog;
  final VoidCallback onAendern;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final meta = context.watch<MetaStore>();
    final k = katalog;
    final karten = [
      if (k != null)
        for (final id in meta.deck)
          if (k[id] != null) k[id]!,
    ];
    return MTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.karten_deck_abend_titel.toUpperCase(), style: t.marke),
          const SizedBox(height: MMass.s12),
          if (karten.isEmpty)
            Text(l.karten_deck_abend_leer, style: t.leise)
          else
            Wrap(
              spacing: MMass.s8,
              runSpacing: MMass.s8,
              children: [
                for (final c in karten)
                  Semantics(
                    label: '${c.titel}, ${KartenTexte.art(c.art)}, ${KartenTexte.ladungen(c.ladungen)}',
                    excludeSemantics: true,
                    child: MChip(c.titel, icon: artSymbol(c.art), farbe: f.seltenheit(seltenheitStufe(c.seltenheit).index)),
                  ),
              ],
            ),
          const SizedBox(height: MMass.s12),
          Align(
            alignment: Alignment.centerLeft,
            child: MKnopf(text: l.karten_deck_aendern, art: MKnopfArt.zweit, icon: Icons.style_rounded, onPressed: onAendern),
          ),
        ],
      ),
    );
  }
}
