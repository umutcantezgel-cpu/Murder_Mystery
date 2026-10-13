import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';
import 'package:provider/provider.dart';

import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../stil/mappe/assistent_formular.dart' show MFormkopf;
import '../../stil/stil.dart';
import 'karten_ansicht.dart';

/// „Deck für diesen Abend“ im Assistenten: ein Blatt mit Büroklammer, darauf die
/// ausgerüsteten Karten des Geräts als kleiner Fächer und als getippte Liste,
/// dazu ein Knopf zum Ändern. Ohne Katalog zeigt es nur den Knopf.
class DeckZeile extends StatelessWidget {
  const DeckZeile({super.key, required this.katalog, required this.onAendern});

  final KartenKatalog? katalog;
  final VoidCallback onAendern;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final meta = context.watch<MetaStore>();
    final k = katalog;
    final karten = [
      if (k != null)
        for (final id in meta.deck)
          if (k[id] != null) k[id]!,
    ];
    return MBlatt(
      klammer: true,
      neigung: -0.004,
      samen: 61,
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MFormkopf(l.karten_deck_abend_titel.toUpperCase()),
          const SizedBox(height: MMass.s4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: MMass.s12),
          if (karten.isEmpty)
            Text(l.karten_deck_abend_leer, style: MPapierSchrift.leise)
          else
            LayoutBuilder(
              builder: (context, box) {
                final liste = _Liste(karten: karten);
                // Schmal oder mit großer Schrift: der Fächer über der Liste.
                final skala = MediaQuery.textScalerOf(context).scale(1);
                if (box.maxWidth < 260 * (skala < 1 ? 1 : skala)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [Center(child: _Faecher(karten: karten)), const SizedBox(height: MMass.s12), liste],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [_Faecher(karten: karten), const SizedBox(width: MMass.s16), Expanded(child: liste)],
                );
              },
            ),
          const SizedBox(height: MMass.s16),
          Align(
            alignment: Alignment.centerLeft,
            child: MKnopf(text: l.karten_deck_aendern, art: MKnopfArt.zweit, icon: Icons.style_rounded, onPressed: onAendern),
          ),
        ],
      ),
    );
  }
}

/// Die Karten als kleiner Fächer (nur Bild; die Liste daneben liest vor).
class _Faecher extends StatelessWidget {
  const _Faecher({required this.karten});

  final List<KartenDef> karten;

  static const _breite = 50.0;

  @override
  Widget build(BuildContext context) {
    final n = karten.length;
    final mitte = (n - 1) / 2;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MMass.s4, vertical: MMass.s8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < n; i++)
              Align(
                widthFactor: i == n - 1 ? 1 : 0.62,
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset(0, (i - mitte).abs() * 3),
                  child: Transform.rotate(angle: (i - mitte) * 0.12, child: KartenKarte(def: karten[i], breite: _breite)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Getippte Liste der Karten: Symbol der Wirkung und Titel.
class _Liste extends StatelessWidget {
  const _Liste({required this.karten});

  final List<KartenDef> karten;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in karten)
            Semantics(
              label: '${c.titel}, ${KartenTexte.art(c.art)}, ${KartenTexte.ladungen(c.ladungen)}',
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(artSymbol(c.art), size: 16, color: seltenheitTinte(c.seltenheit)),
                    ),
                    const SizedBox(width: MMass.s8),
                    Expanded(child: Text(c.titel, style: MPapierSchrift.maschine.copyWith(fontSize: 15))),
                  ],
                ),
              ),
            ),
        ],
      );
}
