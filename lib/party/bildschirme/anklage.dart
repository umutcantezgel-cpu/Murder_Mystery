import 'package:flutter/material.dart';

import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Anklage gegen eine der vier Kernpersonen (Master 7.6, Schritt 6).
/// Antippen markiert eine Karte, „Anklagen“ fragt nach, ob es endgültig ist.
/// Erst danach ist die Anklage fest und „Weiter“ wird frei.
class AnklageBildschirm extends StatefulWidget {
  const AnklageBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<AnklageBildschirm> createState() => _AnklageBildschirmState();
}

class _AnklageBildschirmState extends State<AnklageBildschirm> {
  /// Markierte Person, solange noch nichts angeklagt ist.
  String? _markiert;

  PartySitzung get s => widget.sitzung;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final angeklagt = s.angeklagt;
          final markiert = _markiert;
          final hinweis = angeklagt == null ? s.ui('ui.anklage.hinweis') : s.ui('ui.anklage.angeklagt', {'name': s.figurName(angeklagt)});
          return PartyRahmen(
            marke: s.ui('ui.anklage.marke'),
            titel: s.ui('ui.anklage.titel'),
            aktionen: [
              PartyKnopf(
                text: s.ui('ui.anklage.anklagen'),
                onPressed: angeklagt == null && markiert != null ? () => _fragen(markiert) : null,
              ),
              PartyKnopf(text: s.ui('ui.allgemein.weiter'), onPressed: s.kannWeiter ? s.weiter : null),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
                const SizedBox(height: 8),
                Text(hinweis, style: Keller.leise),
                const SizedBox(height: 14),
                for (final p in s.kernverdaechtige) ...[
                  _Karte(
                    sitzung: s,
                    person: p,
                    markiert: p == (angeklagt ?? markiert),
                    onTap: angeklagt == null ? () => setState(() => _markiert = p) : null,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );
        },
      );

  /// Bestätigung „Das ist endgültig“. Erst „Ja“ schließt die Anklage.
  Future<void> _fragen(String person) => showDialog<void>(
        context: context,
        builder: (c) => Dialog(
          backgroundColor: Colors.transparent,
          child: PartyTafel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.ui('ui.anklage.bestaetigen', {'name': s.figurName(person)}), style: Keller.ueberschrift),
                const SizedBox(height: 10),
                Text(s.ui('ui.anklage.endgueltig'), style: Keller.text),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    PartyKnopf(text: s.ui('ui.anklage.nein'), haupt: false, onPressed: () => Navigator.of(c).pop()),
                    PartyKnopf(
                      text: s.ui('ui.anklage.ja'),
                      onPressed: () {
                        Navigator.of(c).pop();
                        s.anklagen(person);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

/// Karte einer Kernperson: Farbpunkt, Name, Rolle und Spielername. Die
/// markierte Karte hat einen warmen Rahmen; ohne [onTap] ist sie gesperrt.
class _Karte extends StatelessWidget {
  const _Karte({required this.sitzung, required this.person, required this.markiert, this.onTap});

  final PartySitzung sitzung;
  final String person;
  final bool markiert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final farbe = sitzung.figurFarbe(person);
    final titel = sitzung.figurTitel(person);
    return Semantics(
      button: true,
      selected: markiert,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: markiert ? Keller.kerze : Colors.transparent, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: PartyTafel(
              akzent: farbe,
              child: Row(
                children: [
                  FarbPunkt(farbe, groesse: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(sitzung.figurName(person), style: Keller.ueberschrift),
                        if (titel.isNotEmpty) Text(titel, style: Keller.leise),
                        Text(sitzung.solo ? sitzung.ui('ui.solo.gast') : sitzung.ui('ui.anklage.gespielt', {'name': sitzung.spielerName(person)}), style: Keller.leise),
                      ],
                    ),
                  ),
                  if (markiert) const Icon(Icons.check_circle, color: Keller.kerze),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
