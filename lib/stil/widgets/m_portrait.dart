import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../ui/widgets/portrait.dart';
import '../tokens.dart';

/// Porträt einer Figur im Stil des Spiels: die gezeichnete Büste aus
/// `Portrait`, gerahmt mit einer Haarlinie. [semantik] beschriftet das Bild.
class MPortrait extends StatelessWidget {
  const MPortrait({
    super.key,
    required this.look,
    this.groesse = 96,
    this.rahmen = true,
    this.kreis = false,
    this.tot = false,
    this.akzent,
    this.semantik,
  });

  final LookDef look;
  final double groesse;

  /// Haarlinie um das Bild.
  final bool rahmen;

  /// Rund zugeschnitten statt quadratisch.
  final bool kreis;

  /// Gedämpft dargestellt (Opfer).
  final bool tot;

  /// Farbe des Hintergrundscheins; ohne Angabe der Akzent.
  final Color? akzent;

  /// Beschriftung für den Bildschirmleser; ohne sie bleibt das Bild stumm.
  final String? semantik;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final bild = Portrait(look: look, size: groesse, circle: kreis, dead: tot, accent: akzent ?? f.akzent);
    Widget w = rahmen
        ? DecoratedBox(
            decoration: BoxDecoration(
              shape: kreis ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: kreis ? null : BorderRadius.circular(MMass.r6),
              border: Border.all(color: f.linieStark),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kreis ? groesse : MMass.r6 - 1),
              child: bild,
            ),
          )
        : bild;
    w = semantik == null ? ExcludeSemantics(child: w) : Semantics(image: true, label: semantik, child: ExcludeSemantics(child: w));
    return w;
  }
}
