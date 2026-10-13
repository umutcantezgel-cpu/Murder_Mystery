import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../klang/klang.dart';
import '../../l10n/lookup.dart';
import '../../stil/mappe/assistent_formular.dart' show MFormkopf;
import '../../stil/stil.dart';
import '../sitzung.dart';

/// Randgespräch mit einem Zeugen als Vernehmungsprotokoll (M6): oben der
/// Fotoabzug und der Name, darunter der letzte eigene Satz in Füllertinte und
/// die Antwort der Figur, getippt. Darunter die Haltungen als Karteireiter;
/// am Ende „Gespräch beenden“. Alle Texte kommen aus `content/erzaehlung`.
class GespraechsSzene extends StatelessWidget {
  const GespraechsSzene({super.key, required this.sitzung});

  final PartySitzung sitzung;

  static IconData _icon(Haltung h) => switch (h) {
        Haltung.freundlich => Icons.waving_hand_outlined,
        Haltung.draengen => Icons.priority_high_rounded,
        Haltung.bluffen => Icons.theater_comedy_outlined,
        Haltung.vorlegen => Icons.description_outlined,
      };

  static String _name(L l, Haltung h) => switch (h) {
        Haltung.freundlich => l.gespraech_haltung_freundlich,
        Haltung.draengen => l.gespraech_haltung_draengen,
        Haltung.bluffen => l.gespraech_haltung_bluffen,
        Haltung.vorlegen => l.gespraech_haltung_vorlegen,
      };

  @override
  Widget build(BuildContext context) {
    final lauf = sitzung.gespraech;
    if (lauf == null) return const SizedBox.shrink();
    final l = L.of(context);
    final id = lauf.gespraech.figur;
    final figur = sitzung.kanon.figur(id) ?? const <String, Object?>{};
    final name = figur['name'] as String? ?? id;
    final titel = figur['roleTitle'] as String?;
    final schritt = lauf.verlauf.length;
    final vorher = schritt >= 2 ? lauf.verlauf[schritt - 2] : null;
    final jetzt = lauf.verlauf.last;
    return MBlatt(
      key: const ValueKey('randgespraech'),
      art: PapierArt.akte,
      klammer: true,
      neigung: -0.003,
      samen: id.codeUnits.fold(5, (a, b) => (a * 31 + b) & 0xffff),
      randFarbe: sitzung.figurFarbe(id),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: MFotoabzug(look: sitzung.figurAussehen(id), groesse: 46, neigung: 0.03, akzent: sitzung.figurFarbe(id)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MFormkopf(l.gespraech_marke),
                    const SizedBox(height: 2),
                    MGanzeWorte(name, stil: MPapierSchrift.ueberschrift, minimum: 15),
                    if (titel != null) Text(titel, style: MPapierSchrift.leise),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.25)),
          const SizedBox(height: 8),
          if (vorher?.detektiv case final satz?) ...[
            // Der eigene Satz als Randnotiz in Füllertinte.
            Text('${l.gespraech_ich}: $satz', style: MPapierSchrift.hand),
            const SizedBox(height: 8),
          ],
          // Gespräche tippen schneller als der Erzähler; Antippen zeigt alles.
          MSchreibmaschine(
            jetzt.figur,
            key: ValueKey('zeile-$schritt'),
            stil: MPapierSchrift.erzaehler.copyWith(fontSize: 17, height: 1.45),
            zeichenProSekunde: 90,
          ),
          const SizedBox(height: 12),
          if (!lauf.fertig)
            for (final w in lauf.wahlen) ...[
              _HaltungsKnopf(
                haltung: _name(l, w.haltung),
                icon: _icon(w.haltung),
                text: w.text,
                onTap: () {
                  Klang.instanz.spiele('blatt', laut: 0.6);
                  sitzung.randgespraechWaehlen(w);
                },
              ),
              const SizedBox(height: 8),
            ]
          else
            Align(
              alignment: Alignment.centerRight,
              child: MKnopf(text: l.gespraech_beenden, art: MKnopfArt.zweit, onPressed: sitzung.randgespraechBeenden),
            ),
        ],
      ),
    );
  }
}

/// Eine Antwort als Karteikarte: Reiter mit Haltung und Symbol, darunter der Satz.
class _HaltungsKnopf extends StatelessWidget {
  const _HaltungsKnopf({required this.haltung, required this.icon, required this.text, required this.onTap});

  final String haltung;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '$haltung: $text',
        excludeSemantics: true,
        child: MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 20, color: MRoh.tinteBlau)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(haltung, style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: MRoh.tinteBlau)),
                    const SizedBox(height: 2),
                    Text(text, style: MPapierSchrift.kursiv),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
