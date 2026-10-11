import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show DetectiveClass, detectiveClasses;
import 'package:provider/provider.dart';

import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../stil/stil.dart';
import '../../ui/icons.dart';

/// Die fünf Detektivklassen nach Freischaltung: erst die frei verfügbaren, dann
/// die höheren Ränge (bei gleichem Rang bleibt die Reihenfolge der Regeln).
List<DetectiveClass> klassenNachRang() {
  final liste = detectiveClasses.values.toList();
  final reihenfolge = {for (var i = 0; i < liste.length; i++) liste[i].id: i};
  liste.sort((a, b) {
    final r = a.unlockRank.compareTo(b.unlockRank);
    return r != 0 ? r : reihenfolge[a.id]!.compareTo(reihenfolge[b.id]!);
  });
  return liste;
}

/// „Deine Ermittlerklasse“: Auswahl der Klasse dieses Geräts als kleine Kapseln.
/// Die Wahl liegt im [MetaStore] (Ausrüstung), gilt für jeden Abend und
/// bestimmt die Rolle `klasse:<name>` für die Belohnung. Noch nicht
/// freigeschaltete Klassen sind gesperrt und nennen den nötigen Rang.
class KlasseZeile extends StatelessWidget {
  const KlasseZeile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final meta = context.watch<MetaStore>();
    final gewaehlt = meta.loadout.cls;
    return MTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.abend_klasse_titel.toUpperCase(), style: t.marke),
          const SizedBox(height: MMass.s12),
          Wrap(
            spacing: MMass.s8,
            runSpacing: MMass.s8,
            children: [
              for (final c in klassenNachRang())
                _KlasseKapsel(
                  klasse: c,
                  gewaehlt: c.id == gewaehlt,
                  gesperrt: !meta.classUnlocked(c.id),
                  onTap: () => _waehle(meta, c.id),
                ),
            ],
          ),
          const SizedBox(height: MMass.s12),
          Text(l.abend_klasse_hinweis, style: t.leise),
        ],
      ),
    );
  }

  /// Merkt die Klasse in der Ausrüstung; Mantel und Hut bleiben unverändert.
  static void _waehle(MetaStore meta, String id) {
    final lo = meta.loadout;
    if (lo.cls == id || !meta.classUnlocked(id)) return;
    meta.loadout = Loadout(cls: id, coat: lo.coat, hat: lo.hat);
  }
}

/// Eine Klasse zur Wahl: Symbol, Name und bei gesperrten der nötige Rang.
class _KlasseKapsel extends StatelessWidget {
  const _KlasseKapsel({required this.klasse, required this.gewaehlt, required this.gesperrt, required this.onTap});

  final DetectiveClass klasse;
  final bool gewaehlt;
  final bool gesperrt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final name = l.className(klasse.id);
    final rang = l.common_unlock_at(l.rankName(klasse.unlockRank));
    final vorn = gewaehlt ? f.akzentAuf : (gesperrt ? f.papierLeise : f.papier);
    final rahmen = BorderRadius.circular(MMass.r20);
    return Semantics(
      button: true,
      selected: gewaehlt,
      enabled: !gesperrt,
      label: gesperrt ? l.abend_klasse_gesperrt(name, rang) : name,
      excludeSemantics: true,
      onTap: gesperrt ? null : onTap,
      child: Material(
        color: gewaehlt ? f.akzent : f.flaeche,
        shape: RoundedRectangleBorder(
          borderRadius: rahmen,
          side: BorderSide(color: gewaehlt ? f.akzent : f.linieStark),
        ),
        child: InkWell(
          borderRadius: rahmen,
          onTap: gesperrt ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MMass.s12, vertical: MMass.s8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(gesperrt ? Icons.lock_rounded : GameIcons.cls(klasse.id), size: 18, color: vorn),
                  const SizedBox(width: MMass.s8),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(fontFamily: MRohSchrift.text, fontSize: 15, fontWeight: FontWeight.w600, color: vorn),
                        ),
                        if (gesperrt)
                          Text(rang, style: TextStyle(fontFamily: MRohSchrift.text, fontSize: 12, color: f.papierLeise)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
