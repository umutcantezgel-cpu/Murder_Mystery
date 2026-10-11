import 'package:flutter/material.dart';

import '../tokens.dart';

/// Kleine Marke: ein Wort oder eine kurze Angabe in einer Kapsel
/// (Ton einer Akte, Personenzahl, „bald“).
class MChip extends StatelessWidget {
  const MChip(this.text, {super.key, this.icon, this.farbe, this.gefuellt = false, this.passend = false});

  final String text;
  final IconData? icon;

  /// Farbe von Linie und Schrift; ohne Angabe der Akzent.
  final Color? farbe;

  /// Gefüllte Kapsel (Hervorhebung) statt Umriss.
  final bool gefuellt;

  /// Natürliche Größe ohne Kürzen („…“): für eine Umgebung wie `FittedBox`,
  /// die die ganze Kapsel verkleinert, wenn der Platz nicht reicht.
  final bool passend;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final c = farbe ?? f.akzent;
    final auf = gefuellt ? f.akzentAuf : c;
    final stil = TextStyle(fontFamily: MRohSchrift.text, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: auf);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: gefuellt ? c : c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MMass.r20),
        border: Border.all(color: c.withValues(alpha: gefuellt ? 1 : 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: auf), const SizedBox(width: 4)],
          if (passend)
            Text(text, maxLines: 1, softWrap: false, style: stil)
          else
            Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: stil)),
        ],
      ),
    );
  }
}
