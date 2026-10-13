import 'package:flutter/material.dart';

import '../../klang/klang.dart';
import '../tokens.dart';

/// Kleiner Messingknopf mit Lautsprecher: schaltet den Ton an oder aus und
/// merkt sich die Wahl. [an] und [aus] beschriften ihn für den Bildschirmleser
/// (der jeweils aktuelle Zustand).
class MTonSchalter extends StatelessWidget {
  const MTonSchalter({super.key, required this.an, required this.aus});

  final String an;
  final String aus;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    return ValueListenableBuilder<bool>(
      valueListenable: Klang.instanz.an,
      builder: (context, ein, _) => Semantics(
        button: true,
        toggled: ein,
        label: ein ? an : aus,
        excludeSemantics: true,
        child: Tooltip(
          message: ein ? an : aus,
          child: InkResponse(
            radius: 26,
            onTap: () async {
              await Klang.instanz.schalten(!ein);
              if (!ein) Klang.instanz.spiele('knopf');
            },
            child: Container(
              width: MMass.tippflaeche,
              height: MMass.tippflaeche,
              alignment: Alignment.center,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [MRoh.messingHell, MRoh.messingMitte, MRoh.messingDunkel],
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 6, offset: const Offset(0, 2))],
                  border: Border.all(color: f.linieStark.withValues(alpha: 0.6)),
                ),
                child: Icon(ein ? Icons.volume_up_rounded : Icons.volume_off_rounded, size: 20, color: const Color(0xFF2A1A06)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
