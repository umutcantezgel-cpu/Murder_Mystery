import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/mappe/abend2_bausteine.dart';
import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

final _de = LDe();

/// Anklage gegen eine der vier Kernpersonen (Master 7.6, Schritt 6).
/// Antippen markiert eine Karte, „Anklagen“ fragt nach, ob es endgültig ist.
/// Erst danach ist die Anklage fest und „Weiter“ wird frei.
///
/// Die Verdächtigen hängen als Fahndungskarten mit Fotoabzug am Korkbrett,
/// alle in derselben Gestalt (K-22): Nichts verrät vor der Wahl, wer es war.
/// Die markierte Karte trägt einen roten Bleistiftkringel, die angeklagte den
/// Stempel „Angeklagt“.
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
          final personen = s.kernverdaechtige;
          return PartyRahmen(
            marke: s.ui('ui.anklage.marke'),
            titel: s.ui('ui.anklage.titel'),
            aktionen: [
              MKnopf(
                text: s.ui('ui.anklage.anklagen'),
                onPressed: angeklagt == null && markiert != null ? () => _fragen(markiert) : null,
              ),
              MKnopf(text: s.ui('ui.allgemein.weiter'), onPressed: s.kannWeiter ? s.weiter : null),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
                const SizedBox(height: 8),
                Text(hinweis, style: context.schrift.leise),
                const SizedBox(height: 10),
                MKorkbrett(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      // Zwei Karten nebeneinander, auf breiten Bildschirmen vier; bei
                      // großer Schrift eine je Zeile, damit Namen nicht zerbrechen.
                      final gross = MediaQuery.textScalerOf(context).scale(10) > 15;
                      final spalten = box.maxWidth >= 640 && !gross ? 4 : (box.maxWidth >= 260 && !gross ? 2 : 1);
                      const abstand = 14.0;
                      final breite = (box.maxWidth - abstand * (spalten - 1)) / spalten;
                      return Wrap(
                        spacing: abstand,
                        runSpacing: 18,
                        children: [
                          for (var i = 0; i < personen.length; i++)
                            SizedBox(
                              width: breite,
                              child: _Karte(
                                sitzung: s,
                                person: personen[i],
                                nr: i,
                                markiert: personen[i] == (angeklagt ?? markiert),
                                angeklagt: personen[i] == angeklagt,
                                onTap: angeklagt == null ? () => setState(() => _markiert = personen[i]) : null,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

  /// Bestätigung „Das ist endgültig“ als Karteikarte. Erst „Ja“ schließt die
  /// Anklage; Wegtippen gilt als „Noch nicht“. Der Titel mit dem Namen bricht
  /// um und bleibt auch bei großer Schrift ganz lesbar.
  Future<void> _fragen(String person) async {
    final ja = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (c) => MKarteiFenster(
        titel: s.ui('ui.anklage.bestaetigen', {'name': s.figurName(person)}),
        inhalt: Text(s.ui('ui.anklage.endgueltig'), style: MPapierSchrift.text),
        aktionen: [
          MKnopf(text: s.ui('ui.anklage.nein'), art: MKnopfArt.zweit, onPressed: () => Navigator.of(c).pop(false)),
          MKnopf(text: s.ui('ui.anklage.ja'), art: MKnopfArt.gefahr, onPressed: () => Navigator.of(c).pop(true)),
        ],
      ),
    );
    if ((ja ?? false) && mounted) s.anklagen(person);
  }
}

/// Fahndungskarte einer Kernperson: Fotoabzug mit Nummerntafel, Name, Rolle und
/// Spielername. Jede Karte hat dieselbe Gestalt; die Neigung hängt nur an der
/// festen Reihenfolge. Die markierte Karte ist angehoben und rot umkringelt;
/// ohne [onTap] ist sie gesperrt.
class _Karte extends StatelessWidget {
  const _Karte({required this.sitzung, required this.person, required this.nr, required this.markiert, required this.angeklagt, this.onTap});

  final PartySitzung sitzung;
  final String person;
  final int nr;
  final bool markiert;
  final bool angeklagt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final farbe = sitzung.figurFarbe(person);
    final titel = sitzung.figurTitel(person);
    return LayoutBuilder(
      builder: (context, box) {
        final foto = (box.maxWidth - 64).clamp(64.0, 120.0);
        return Semantics(
          button: true,
          selected: markiert,
          enabled: onTap != null,
          child: MBlatt(
            art: PapierArt.karteikarte,
            kopfLinie: 7,
            linien: false,
            reissnagel: true,
            onTap: onTap,
            hervorgehoben: markiert,
            randFarbe: farbe,
            neigung: nr.isEven ? -0.012 : 0.01,
            samen: nr + 31,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Der Name steht oben auf der Karte: Der Knopf heißt wie die Person.
                MGanzwortText(sitzung.figurName(person), textAlign: TextAlign.center, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20, height: 1.2)),
                if (titel.isNotEmpty) Text(titel, textAlign: TextAlign.center, style: MPapierSchrift.leise),
                const SizedBox(height: 6),
                // Foto, Nummerntafel und Kringel sind Zierde.
                ExcludeSemantics(
                  child: SizedBox(
                    width: foto + 28,
                    height: foto + 36,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        MFotoabzug(
                          look: sitzung.figurAussehen(person),
                          groesse: foto,
                          neigung: nr.isEven ? 0.025 : -0.03,
                          akzent: farbe,
                        ),
                        Positioned(
                          bottom: 6,
                          child: _Nummerntafel(text: 'Nr. ${(nr + 1).toString().padLeft(2, '0')}'),
                        ),
                        if (markiert) const Positioned.fill(child: MKringel()),
                        // Erst nach „Ja, ich klage an“: der Stempel schlägt quer über das Foto.
                        if (angeklagt)
                          RepaintBoundary(
                            child: MStempel(text: _de.abend2_angeklagt, groesse: (foto * 0.16).clamp(12.0, 19.0), winkel: -0.22, aufschlagen: true),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Ohne eingetragenen Namen hieße es „gespielt von“ der Figur selbst:
                // dann bleibt die Zeile leer, die Karten bleiben gleich hoch.
                Visibility(
                  visible: sitzung.solo || sitzung.spielerName(person) != sitzung.figurName(person),
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Text(
                    sitzung.solo ? sitzung.ui('ui.solo.gast') : sitzung.ui('ui.anklage.gespielt', {'name': sitzung.spielerName(person)}),
                    textAlign: TextAlign.center,
                    style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: MRoh.tinteLeise),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Kleine schwarze Nummerntafel vor dem Fotoabzug, wie bei einer Polizeiaufnahme.
class _Nummerntafel extends StatelessWidget {
  const _Nummerntafel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(8, 3, 8, 2),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1714),
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1))],
        ),
        // Zierde auf dem Foto: wächst mit der Schrift nur wenig, damit das Gesicht frei bleibt.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.2,
          child: Text(text, style: MRohSchrift.schreibmaschine.copyWith(fontSize: 12, letterSpacing: 1.4, color: MRoh.blatt)),
        ),
      );
}
