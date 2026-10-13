import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../rueckblende_ansicht.dart';
import '../sitzung.dart';

final _de = LDe();

/// Finale mit Rückblende (Master 7.6, Schritt 7): oben der Zeitraffer der Tat,
/// darunter Finaltext und Rückblende aus dem Erzähler. Die Schlagzeile ist das
/// Ende des Abends, das erst nach der Anklage feststeht.
///
/// Gestaltet als Titelseite: Zeitungskopf mit dem Namen der Akte, die
/// Schlagzeile, der Urteilsstempel und die Rückblende als Pressefoto. Eine Akte
/// ohne Simulation zeigt die Rückblende als Erinnerungsfoto in Sepia.
class FinaleBildschirm extends StatelessWidget {
  const FinaleBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) => PartyRahmen(
        marke: sitzung.ui('ui.finale.marke'),
        aktionen: [MKnopf(text: sitzung.ui('ui.allgemein.weiter'), onPressed: sitzung.kannWeiter ? sitzung.weiter : null)],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Titelseite(sitzung: sitzung),
            if (!sitzung.hatRueckblende) ...[
              const SizedBox(height: 26),
              // Akte ohne Simulation: die Rückblende wird erzählt, nicht gezeigt.
              RueckblendeText(sitzung: sitzung),
            ],
            const SizedBox(height: 24),
            ErzaehlerFeld(
              sitzung: sitzung,
              kennungen: sitzung.erzaehler,
              // Der Text der Rückblende steht oben schon; die Stimme liest ihn trotzdem vor.
              verborgen: {if (!sitzung.hatRueckblende) 'rueckblende.${sitzung.pfad}'},
            ),
          ],
        ),
      );
}

/// Die Titelseite des Abends: Zeitungskopf, doppelte Linie, Schlagzeile (das
/// Ende), Urteilsstempel und, bei einer Akte mit Simulation, die Rückblende als
/// Pressefoto mit Bildunterschrift.
class _Titelseite extends StatelessWidget {
  const _Titelseite({required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final ende = s.ende;
    final schmal = MediaQuery.sizeOf(context).width < 400;
    final kopf = s.kanon.fall['titel'] as String;
    return MBlatt(
      samen: 57,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zeitungskopf auf einer Zeile; wird es eng, schrumpft er, statt im Wort zu brechen.
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                kopf,
                maxLines: 1,
                softWrap: false,
                style: MPapierSchrift.aufmacher.copyWith(
                  fontSize: 22,
                  height: 1.1,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w900,
                  fontVariations: const [FontVariation('wght', 900)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _Doppellinie(),
          const SizedBox(height: 3),
          const _Doppellinie(umgekehrt: true),
          const SizedBox(height: 18),
          Text(
            ende.name,
            textAlign: TextAlign.center,
            style: MPapierSchrift.aufmacher.copyWith(fontSize: schmal ? 30 : 40),
          ),
          const SizedBox(height: 12),
          Center(
            child: RepaintBoundary(
              child: MStempel(
                text: ende.richtig ? _de.verdict_stamp_solid : _de.verdict_stamp_wrong,
                farbe: ende.richtig ? const Color(0xFF2F6B37) : MRoh.stempelRot,
                groesse: 22,
                winkel: -0.1,
                aufschlagen: true,
              ),
            ),
          ),
          if (s.hatRueckblende) ...[
            const SizedBox(height: 18),
            // Pressefoto: fester Kasten, mindestens 240 px, sonst 38 % der Höhe; so
            // beginnt der Finaltext noch über der Fußleiste (B7).
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF15120F),
                border: Border.all(color: MRoh.tinte.withValues(alpha: 0.6), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  height: math.max(240.0, MediaQuery.sizeOf(context).height * 0.38),
                  // Eigene Ebene: Der Zeitraffer malt in jedem Bild neu, das Papier nicht.
                  child: RepaintBoundary(child: RueckblendeAnsicht(sitzung: s)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(s.ui('ui.finale.rueckblende'), style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: MRoh.tinteLeise)),
          ],
        ],
      ),
    );
  }
}

/// Doppelte Zeitungslinie: dick und dünn (oder umgekehrt).
class _Doppellinie extends StatelessWidget {
  const _Doppellinie({this.umgekehrt = false});

  final bool umgekehrt;

  @override
  Widget build(BuildContext context) {
    final dick = Container(height: 2.4, color: MRoh.tinte.withValues(alpha: 0.85));
    final duenn = Container(height: 0.8, color: MRoh.tinte.withValues(alpha: 0.7));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: umgekehrt ? [duenn, const SizedBox(height: 2), dick] : [dick, const SizedBox(height: 2), duenn],
    );
  }
}
