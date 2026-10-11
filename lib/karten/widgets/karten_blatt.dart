import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';

import '../../l10n/lookup.dart';
import '../../stil/stil.dart';
import '../katalog_laden.dart';
import 'karten_ansicht.dart';

/// Öffnet die große Kartenansicht: die Karte, Titel, Text, Seltenheit, Art und
/// Besitz. Eine unbekannte Karte ([anzahl] gleich 0) zeigt nur, wie man sie bekommt.
Future<void> zeigeKartenBlatt(
  BuildContext context, {
  required KartenDef def,
  KartenFigur? figur,
  String? figurName,
  int anzahl = 0,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: MFarben.von(context).flaeche,
      showDragHandle: true,
      builder: (c) => KartenBlatt(def: def, figur: figur, figurName: figurName, anzahl: anzahl),
    );

/// Inhalt der großen Kartenansicht.
class KartenBlatt extends StatelessWidget {
  const KartenBlatt({super.key, required this.def, this.figur, this.figurName, this.anzahl = 0});

  final KartenDef def;
  final KartenFigur? figur;

  /// Name der Figur oder Klasse für die Überschrift.
  final String? figurName;

  /// Wie oft die Karte im Besitz ist (0 = unbekannt).
  final int anzahl;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final bekannt = anzahl > 0;
    final breite = (MediaQuery.sizeOf(context).width * 0.62).clamp(160.0, 300.0);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(MMass.s20, 0, MMass.s20, MMass.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: bekannt
                      ? KartenKarte(def: def, figur: figur, breite: breite)
                      : UnbekannteKarte(breite: breite, semantik: l.karten_unbekannt_semantik(figurName ?? def.figur)),
                ),
                const SizedBox(height: MMass.s16),
                if (figurName != null) Text(figurName!.toUpperCase(), textAlign: TextAlign.center, style: t.marke),
                const SizedBox(height: MMass.s4),
                Text(bekannt ? def.titel : l.karten_noch_nicht, textAlign: TextAlign.center, style: t.ueberschrift),
                const SizedBox(height: MMass.s12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: MMass.s8,
                  runSpacing: MMass.s8,
                  children: [
                    MChip(KartenTexte.seltenheit(def.seltenheit), farbe: f.seltenheit(seltenheitStufe(def.seltenheit).index)),
                    if (bekannt) MChip(KartenTexte.art(def.art), icon: artSymbol(def.art)),
                    if (bekannt && def.art.spielbar) MChip(l.karten_ladungen(def.ladungen), farbe: f.papierLeise),
                  ],
                ),
                const SizedBox(height: MMass.s16),
                if (bekannt) ...[
                  Text(def.text, textAlign: TextAlign.center, style: t.text),
                  const SizedBox(height: MMass.s12),
                  Text(l.karten_besitz(anzahl), textAlign: TextAlign.center, style: t.leise),
                ] else ...[
                  Text(l.karten_quelle_titel.toUpperCase(), textAlign: TextAlign.center, style: t.marke),
                  const SizedBox(height: MMass.s4),
                  for (final q in def.quellen)
                    if (KartenTexte.quelle(q).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: MMass.s4),
                        child: Text(KartenTexte.quelle(q), textAlign: TextAlign.center, style: t.leise),
                      ),
                ],
                const SizedBox(height: MMass.s20),
                MKnopf(text: l.common_close, art: MKnopfArt.zweit, onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
