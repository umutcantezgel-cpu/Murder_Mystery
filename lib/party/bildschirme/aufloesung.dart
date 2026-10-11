import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../app/router.dart';
import '../../l10n/gen/app_localizations_de.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Auflösung (Master 7.6, Schritt 8, Phase aufloesung) und das Ende (Phase ende).
/// In der Auflösung steht je Baustein der Erzählertext, bei den Rollen mit Name
/// am Tisch und Farbpunkt. Im Ende steht die Abschlusstafel mit dem Weg ins Hauptmenü.
class AufloesungBildschirm extends StatelessWidget {
  const AufloesungBildschirm({super.key, required this.sitzung, this.onEnde});

  final PartySitzung sitzung;

  /// Weg vom Ende: im Abend die Belohnung, sonst (alter Einstieg) die Detektei.
  final VoidCallback? onEnde;

  PartySitzung get s => sitzung;

  @override
  Widget build(BuildContext context) => s.phase == PartyPhase.ende ? _ende(context) : _aufloesung();

  Widget _aufloesung() => PartyRahmen(
        marke: s.ui('ui.aufloesung.marke'),
        titel: s.ui('ui.aufloesung.titel'),
        aktionen: [PartyKnopf(text: s.ui('ui.allgemein.weiter'), onPressed: s.kannWeiter ? s.weiter : null)],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final k in s.erzaehler) ...[
              if (_rolle(k) case final r?) _Rolle(sitzung: s, rolle: r),
              ErzaehlerFeld(sitzung: s, kennungen: [k]),
            ],
          ],
        ),
      );

  Widget _ende(BuildContext context) {
    final ende = s.ende;
    return PartyRahmen(
      marke: s.ui('ui.aufloesung.ende_marke'),
      titel: ende.name,
      // Der Abend ist zu Ende: in der Detektei beginnt ein neuer Abend; im Abend
      // der Weg über die Belohnung (Karten, Erfahrung, Rang).
      aktionen: [
        if (onEnde == null)
          PartyKnopf(text: s.ui('ui.aufloesung.hauptmenue'), haupt: false, icon: Icons.home_rounded, onPressed: () => context.go(Routes.start))
        else
          PartyKnopf(text: LDe().abend_belohnung_ansehen, icon: Icons.style_rounded, onPressed: onEnde),
      ],
      child: PartyTafel(
        akzent: ende.richtig ? Keller.notlicht : Keller.gefahr,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Wert(titel: s.ui('ui.aufloesung.punkte_titel'), wert: s.ui('ui.aufloesung.punkte', {'punkte': '${s.spiel.punkte}'})),
            _Wert(titel: s.ui('ui.aufloesung.taeter_titel'), wert: s.figurName(s.pfad)),
            _Wert(titel: s.ui('ui.aufloesung.code_titel'), wert: s.fallCode.code),
            Text(s.ui('ui.aufloesung.code_hinweis'), style: Keller.leise),
            const SizedBox(height: 18),
            Text(s.ui('ui.aufloesung.dank'), style: Keller.text),
          ],
        ),
      ),
    );
  }
}

/// Rolle einer Kennung `aufloesung.<rolle>` oder `aufloesung.<rolle>.<taeter|unschuldig>`.
/// Die Gruppenzeile `aufloesung.gruppe.<n>` hat keine Rolle.
String? _rolle(String kennung) {
  final teile = kennung.split('.');
  return teile.length >= 2 && teile[0] == 'aufloesung' && teile[1] != 'gruppe' ? teile[1] : null;
}

/// Name am Tisch mit Farbpunkt der Rolle, über ihrem Baustein. Die Figur steht
/// nur darunter, wenn sie anders heißt als der Spieler.
class _Rolle extends StatelessWidget {
  const _Rolle({required this.sitzung, required this.rolle});

  final PartySitzung sitzung;
  final String rolle;

  @override
  Widget build(BuildContext context) {
    final spieler = sitzung.spielerName(rolle);
    final figur = sitzung.figurName(rolle);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          FarbPunkt(sitzung.figurFarbe(rolle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spieler, style: Keller.ueberschrift),
                if (figur != spieler) Text(sitzung.ui('ui.aufloesung.figur', {'name': figur}), style: Keller.leise),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Zeile der Abschlusstafel: Marke als Überschrift, darunter der Wert.
class _Wert extends StatelessWidget {
  const _Wert({required this.titel, required this.wert});

  final String titel;
  final String wert;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titel.toUpperCase(), style: context.schrift.marke),
            const SizedBox(height: 4),
            Text(wert, style: Keller.ueberschrift),
          ],
        ),
      );
}
