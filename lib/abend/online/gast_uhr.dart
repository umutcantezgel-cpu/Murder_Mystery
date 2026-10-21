import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart' show RundenUhr;

import '../../l10n/lookup.dart';
import '../../party/runden_uhr.dart';
import '../../stil/stil.dart';
import 'gast_ansicht.dart' show GastKontext;

/// Die gemeinsame Rundenuhr auf dem Gerät eines Gastes (M4): der Zustand aus
/// der Ansicht (`uhr`), die Restzeit aus der Abendzeit des Gastgebers
/// ([GastKontext.dienst], Versatz aus dem `pong`). Knöpfe hat nur, wer leitet
/// ([GastKontext.leitet]); alle anderen sehen, wer die Uhr stellt.
///
/// `null` ohne Uhr in der Ansicht (andere Abschnitte).
Widget? gastRundenUhr(GastKontext c) {
  final uhr = RundenUhr.ausJson(c.v['uhr']);
  if (uhr == null) return null;
  final l = c.l;
  return Padding(
    key: const ValueKey('gast-rundenuhr'),
    padding: const EdgeInsets.only(bottom: MMass.s16),
    child: RundenUhrAnzeige(
      uhr: uhr,
      jetzt: () => c.dienst.gastgeberZeit,
      texte: gastUhrTexte(l),
      groesse: 220,
      steuern: c.leitet && c.verbunden
          ? (aktion, {minuten}) => c.befehl({'typ': 'uhr', 'aktion': aktion.name, 'minuten': ?minuten})
          : null,
      stellt: c.leitet ? null : c.leiterName,
    ),
  );
}

/// Texte der Uhr auf dem Gerät eines Gastes (ARB).
RundenUhrTexte gastUhrTexte(L l) => RundenUhrTexte(
      titel: l.online_uhr_titel,
      start: l.online_uhr_start,
      weiter: l.party_runde_weiterlaufen,
      pause: l.online_uhr_pause,
      plus: l.party_runde_plus,
      zeitUm: l.online_uhr_um,
      angehalten: l.party_runde_angehalten,
      stellt: l.party_runde_stellt,
    );
