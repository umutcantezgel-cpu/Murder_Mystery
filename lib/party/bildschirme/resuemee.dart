import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../stil/mappe/abend1_bausteine.dart';
import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Bonus-Hinweis (Phase bonus) und Zwischenresümee (Phase resuemee), Master 7.6
/// Schritt 5 und 7.12. Der Hinweis zeigt nie, ob er stimmt (E-024), und das
/// Resümee nennt keine Stimmen.
///
/// Beide liegen in der aufgeschlagenen Fallakte. Das Resümee ist ein getippter
/// Bericht mit drei Abschnitten; jeder Abschnittskopf ist ein Stempelabdruck,
/// der nur das Fach nennt, nie eine Wertung.
class ResuemeeBildschirm extends StatelessWidget {
  const ResuemeeBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) => sitzung.phase == PartyPhase.bonus ? _bonus(context) : _resuemee(context);

  /// Rahmen und Hinweis aus dem Erzähler, ohne Angabe der Qualität.
  Widget _bonus(BuildContext context) => PartyRahmen(
        marke: _runde,
        aktionen: [PartyKnopf(text: sitzung.ui('ui.allgemein.weiter'), onPressed: sitzung.weiter)],
        child: _mappe(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final titel = sitzung.ui('ui.resuemee.bonus_titel');
                    final stil = MPapierSchrift.ueberschrift;
                    return Text(titel, style: stil.copyWith(fontSize: ganzeWorteGroesse(context, titel, stil, box.maxWidth, minimum: 13)));
                  },
                ),
              ),
              const SizedBox(height: 16),
              ErzaehlerFeld(sitzung: sitzung, kennungen: sitzung.erzaehler),
            ],
          ),
        ),
      );

  /// Drei Fächer in fester Reihenfolge: Gruppenergebnis, Stand, Lage. Ein
  /// Erzählerfeld liest alle drei nacheinander vor; der Bericht zeigt sie.
  Widget _resuemee(BuildContext context) {
    final faecher = [
      ('ui.resuemee.fach_gruppe', _bausteinVon('resuemee.gruppe.')),
      ('ui.resuemee.fach_rest', _bausteinVon('resuemee.rest.')),
      ('ui.resuemee.fach_lage', _bausteinVon('resuemee.lage.')),
    ];
    final kennungen = [for (final (_, k) in faecher) ...k];
    return PartyRahmen(
      marke: _runde,
      titel: sitzung.ui('ui.resuemee.titel'),
      aktionen: [PartyKnopf(text: _weiterText, onPressed: sitzung.weiter)],
      child: _mappe(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ErzaehlerFeld(sitzung: sitzung, kennungen: kennungen, verborgen: kennungen.toSet()),
            MBlatt(
              klammer: true,
              samen: 40 + sitzung.runde,
              neigung: -0.003,
              padding: EdgeInsets.fromLTRB(_blattRand(context), 30, _blattRand(context), 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MBlattKopf(zeile: sitzung.rundenName),
                  for (var i = 0; i < faecher.length; i++) _fach(i, faecher[i].$1, faecher[i].$2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Die aufgeschlagene Fallakte mit dem Kürzel der Akte als Siegel. Schmal
  /// (gemessen an der Schriftgröße) liegen die Blätter fast bis zum Rand.
  Widget _mappe(BuildContext context, Widget kind) => LayoutBuilder(
        builder: (context, box) {
          final rand = schmalFuerSchrift(context, box.maxWidth) ? 4.0 : 10.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: MOffeneMappe(
              farbe: context.farben.akzent,
              siegel: AkteStil.fuer(sitzung.daten.fall).sigel,
              samen: 7 + sitzung.runde,
              padding: EdgeInsets.fromLTRB(rand, 18, rand, 26),
              child: kind,
            ),
          );
        },
      );

  /// Ein Fach des Berichts: Stempelabdruck mit dem Namen des Fachs, darunter
  /// genau ein Baustein mit dem Präfix.
  Widget _fach(int i, String ueberschrift, List<String> bausteine) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MStempelZeile(sitzung.ui(ueberschrift), winkel: i.isEven ? -0.025 : 0.018, aufschlagen: true),
            const SizedBox(height: 12),
            for (final k in bausteine)
              if (sitzung.hatText(k))
                LayoutBuilder(
                  builder: (context, box) {
                    final text = sitzung.text(k);
                    final stil = MPapierSchrift.erzaehler;
                    return Text(text, style: stil.copyWith(fontSize: ganzeWorteGroesse(context, text, stil, box.maxWidth, minimum: 15)));
                  },
                ),
          ],
        ),
      );

  /// Innenrand des Berichtsblatts: bei großer Schrift auf schmalem Gerät enger.
  double _blattRand(BuildContext context) => MediaQuery.textScalerOf(context).scale(1) > 1.5 && MediaQuery.sizeOf(context).width < 420 ? 14 : 22;

  /// Der Baustein mit diesem Präfix. Die Reihenfolge der Erzählerbausteine ist egal.
  List<String> _bausteinVon(String praefix) => [
        for (final k in sitzung.erzaehler)
          if (k.startsWith(praefix)) k,
      ].take(1).toList();

  String get _runde => sitzung.ui('ui.allgemein.runde', {'nr': '${sitzung.runde}'});

  /// Nach der letzten Runde folgt die Anklage.
  String get _weiterText => sitzung.runde == _letzteRunde ? sitzung.ui('ui.resuemee.zur_anklage') : sitzung.ui('ui.resuemee.naechste_runde');

  int get _letzteRunde => (sitzung.kanon.fall['runden'] as List).length;
}
