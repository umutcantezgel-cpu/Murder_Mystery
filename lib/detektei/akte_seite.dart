import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../l10n/lookup.dart';
import '../stil/stil.dart';
import 'akte_bausteine.dart';
import 'akten.dart';

/// Seite einer Akte (Route `/akte/:id`): Deckel, Titel, Ton und der Weg in den
/// Assistenten für einen neuen Abend, bei Akten mit Druckfassung auch zur Druckmappe.
class AkteSeite extends StatefulWidget {
  const AkteSeite({super.key, required this.akteId});

  final String akteId;

  @override
  State<AkteSeite> createState() => _AkteSeiteState();
}

class _AkteSeiteState extends State<AkteSeite> {
  late Future<List<AkteInfo>> _akten = AktenKatalog.laden();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AkteThema(
      akte: widget.akteId,
      child: Builder(
        builder: (context) {
          final f = MFarben.von(context);
          final t = MSchrift.von(context);
          final zurueck = MKnopf(
            text: l.common_back,
            art: MKnopfArt.zweit,
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go(Routes.start),
          );
          return Scaffold(
            backgroundColor: f.grund,
            body: FutureBuilder<List<AkteInfo>>(
              future: _akten,
              builder: (context, snap) {
                if (snap.hasError) {
                  return MRahmen(
                    aktionen: [zurueck],
                    child: MTafel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l.detektei_akten_fehler, style: t.text),
                          const SizedBox(height: MMass.s12),
                          MKnopf(text: l.detektei_nochmal, art: MKnopfArt.zweit, onPressed: () => setState(() => _akten = AktenKatalog.laden())),
                        ],
                      ),
                    ),
                  );
                }
                final liste = snap.data;
                if (liste == null) return const SizedBox.shrink();
                final akte = liste.where((a) => a.id == widget.akteId).firstOrNull;
                if (akte == null) {
                  return MRahmen(aktionen: [zurueck], child: Text(l.detektei_akte_unbekannt, style: t.text));
                }
                return MRahmen(
                  marke: l.detektei_kampagne,
                  titel: akte.titel,
                  untertitel: akte.untertitel.isEmpty ? null : akte.untertitel,
                  aktionen: [
                    zurueck,
                    if (akte.druckbar)
                      MKnopf(
                        text: l.detektei_akte_druckmappe,
                        art: MKnopfArt.zweit,
                        icon: Icons.print_rounded,
                        onPressed: () => context.go(Routes.druckmappeVon(akte.id)),
                      ),
                    MKnopf(
                      text: l.detektei_akte_spielen,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => context.go(Routes.abendNeuMit(akte.id)),
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(MMass.r14),
                        child: AspectRatio(aspectRatio: 16 / 9, child: AkteDeckel(akte: akte, siegel: 96)),
                      ),
                      const SizedBox(height: MMass.s16),
                      AkteMarken(akte: akte),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
