import 'package:flutter/material.dart';

import '../tokens.dart';

/// Kleine Marke als Aktenetikett: ein Wort oder eine kurze Angabe in einem
/// gestempelten Rahmen (Ton einer Akte, Personenzahl, „bald“).
class MChip extends StatelessWidget {
  const MChip(this.text, {super.key, this.icon, this.farbe, this.gefuellt = false, this.passend = false});

  final String text;
  final IconData? icon;

  /// Farbe von Rahmen und Schrift; ohne Angabe der Akzent.
  final Color? farbe;

  /// Gefülltes Etikett (Hervorhebung) statt Rahmen.
  final bool gefuellt;

  /// Natürliche Größe ohne Kürzen („…“): für eine Umgebung wie `FittedBox`,
  /// die das ganze Etikett verkleinert, wenn der Platz nicht reicht.
  final bool passend;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final c = farbe ?? f.akzent;
    final auf = gefuellt ? f.akzentAuf : c;
    final stil = TextStyle(fontFamily: MRohSchrift.maschine, fontSize: 13, height: 1.2, letterSpacing: 0.5, color: auf);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 9, 3),
      decoration: BoxDecoration(
        color: gefuellt ? c : c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: c.withValues(alpha: gefuellt ? 1 : 0.7), width: 1.2),
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
