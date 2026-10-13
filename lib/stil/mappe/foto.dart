import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../ui/widgets/portrait.dart';
import '../tokens.dart';
import 'material.dart';
import 'zeichen.dart';

/// Fotoabzug einer Person: weißer Rand, leicht schräg, Beschriftung in
/// Handschrift. Das Bild ist die gezeichnete Büste der Figur ([Portrait]).
class MFotoabzug extends StatelessWidget {
  const MFotoabzug({
    super.key,
    required this.look,
    this.beschriftung,
    this.groesse = 96,
    this.neigung = 0,
    this.akzent,
    this.klammer = false,
    this.stempel,
    this.gedaempft = false,
    this.semantik,
  });

  final LookDef look;

  /// Handschriftliche Zeile unter dem Bild (z. B. der Name).
  final String? beschriftung;

  /// Kantenlänge des Bildes.
  final double groesse;
  final double neigung;

  /// Farbe des Hintergrundscheins im Bild.
  final Color? akzent;

  /// Büroklammer oben.
  final bool klammer;

  /// Stempel quer über das Bild (z. B. „Angeklagt“).
  final String? stempel;

  /// Verblasst (z. B. das Opfer).
  final bool gedaempft;

  /// Beschriftung für den Bildschirmleser; ohne sie zählt [beschriftung].
  final String? semantik;

  @override
  Widget build(BuildContext context) {
    Widget bild = SizedBox.square(
      dimension: groesse,
      child: ClipRect(child: Portrait(look: look, size: groesse, dead: gedaempft, accent: akzent ?? MRoh.akzent)),
    );
    if (gedaempft) bild = Opacity(opacity: 0.75, child: bild);
    Widget abzug = DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0x88000000), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: CustomPaint(
        painter: const PapierMaler(art: PapierArt.foto, flecken: false),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, beschriftung == null ? 8 : 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(border: Border.all(color: Colors.black.withValues(alpha: 0.18))),
                child: bild,
              ),
              if (beschriftung != null)
                SizedBox(
                  width: groesse,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      beschriftung!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: MPapierSchrift.hand.copyWith(fontSize: (groesse * 0.2).clamp(15, 22)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    abzug = Stack(
      clipBehavior: Clip.none,
      children: [
        abzug,
        if (klammer) const Positioned(top: -16, right: 14, child: MBueroklammer(hoehe: 36)),
        if (stempel != null) Positioned(left: 0, right: 0, top: groesse * 0.38, child: Center(child: MStempel(text: stempel!, groesse: 14, aufschlagen: true))),
      ],
    );
    abzug = Semantics(
      image: true,
      label: semantik ?? beschriftung,
      excludeSemantics: true,
      child: RepaintBoundary(child: abzug),
    );
    return neigung == 0 ? abzug : Transform.rotate(angle: neigung, child: abzug);
  }
}
