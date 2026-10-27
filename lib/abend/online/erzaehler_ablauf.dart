import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show PartyPhase;
import 'package:mordakte_core/runden.dart' show RundenZugPhase;

import '../../game/game_view.dart';
import '../../l10n/lookup.dart';
import '../../party/bildschirme/einfluss_teile.dart' show MomentAufruf, ZugTafelAnsicht;
import '../../party/bildschirme/moment.dart' show EinflussDarstellung;
import '../../party/erzaehler_ausgabe.dart';
import '../../party/erzaehlerakte_ansicht.dart';
import '../../party/karte_session.dart';
import '../../party/klasse_wirkung.dart';
import '../../party/party_stil.dart';
import '../../party/runden_uhr.dart';
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_erzaehler.dart';
import 'gast_streifzug.dart' show StreifzugZuschauer;
import 'gastgeber_sitzung.dart';
import 'online_teile.dart';

/// Der Gastgeber auf dem Erzähler-Sitz (Langer Abend M3): Er liest vor, führt
/// weiter und entscheidet nichts. In Gesprächen, Entscheidungen und Anklage
/// zeigt sein Gerät statt der Detektiv-Bildschirme das Erzählerpult
/// ([ErzaehlerPultOnline]); alle übrigen Abschnitte bleiben die des Abends
/// (Intro, Bonus, Resümee, Finale und Auflösung lesen ohnehin nur vor).
///
/// `null`, wenn der Gastgeber ermittelt (dann gelten die üblichen Bildschirme).
Widget? erzaehlerErsatz(GastgeberSitzung s) {
  if (s.istDetektiv) return null;
  return switch (s.phase) {
    PartyPhase.gespraeche || PartyPhase.entscheidungen || PartyPhase.anklage => ErzaehlerPultOnline(sitzung: s),
    _ => null,
  };
}

/// Das Pult des Erzähler-Gastgebers: oben die Erzähltexte dieses Schritts
/// (wortgleich, mit Stimme), darunter, was gerade am Tisch geschieht (wen der
/// Detektiv befragt, die Zuschauerkarte der Ermittlung, die Anklage), dann das
/// Erzählerpaket der Runde. „Weiter“ gilt, sobald der Raum weiter kann.
class ErzaehlerPultOnline extends StatefulWidget {
  const ErzaehlerPultOnline({super.key, required this.sitzung});

  final GastgeberSitzung sitzung;

  @override
  State<ErzaehlerPultOnline> createState() => _ErzaehlerPultOnlineState();
}

class _ErzaehlerPultOnlineState extends State<ErzaehlerPultOnline> {
  PartyKartenSession? _karte;

  GastgeberSitzung get s => widget.sitzung;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final k = _karte;
    if (k != null) k.bewegungReduziert = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    unawaited(_karte?.dispose());
    super.dispose();
  }

  /// Die Zuschauerkarte: zeigt Detektiv, Ziele und den sichtbaren Weg, nimmt
  /// keine Eingabe an und meldet nichts. Von der Klasse des Detektiv-Sitzes
  /// wirkt nur das Tempo (Gleichlauf des Wegs); was sie zeigt, sieht nur der
  /// Detektiv (M6.4).
  PartyKartenSession _zuschauer() => _karte ??= PartyKartenSession(s, zuschauer: true, klasse: KlasseWirkung.zuschauer(KlasseWirkung.diesesGeraets(context, s)))
    ..bewegungReduziert = MediaQuery.disableAnimationsOf(context);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final l = L.of(context);
          final anklage = s.phase == PartyPhase.anklage;
          final privat = jMap(s.dienst.ansicht['privat']);
          final paket = privat['erzaehlerPaket'] is Map ? jMap(privat['erzaehlerPaket']) : null;
          final befragungen = jMaps(s.dienst.ansicht['befragungen']);
          // Langer Abend (M7b): Der Erzähler sieht den Streifzug des Detektivs, nur lesend.
          final weg = s.dienst.ansicht['streifzug'];
          final streifzug = weg is Map
              ? StreifzugZuschauer(daten: s.daten, weg: jMap(weg), uhrzeit: s.rundenUhrzeit, person: s.personAmTisch)
              : null;
          return PartyRahmen(
            marke: anklage ? s.ui('ui.anklage.marke') : s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
            titel: anklage ? s.ui('ui.anklage.titel') : s.rundenName,
            untertitel: l.erzaehler_pult_marke,
            aktionen: [PartyKnopf(key: const ValueKey('pult-weiter'), text: s.ui('ui.allgemein.weiter'), onPressed: s.kannWeiter ? s.weiter : null)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
                const SizedBox(height: MMass.s16),
                // Die Erzählerakte (A-063) liegt am Pult des Erzähler-Sitzes bereit.
                if (s.erzaehlerakteSichtbar) ...[
                  Align(alignment: Alignment.centerLeft, child: ErzaehlerakteKnopf(sitzung: s)),
                  const SizedBox(height: MMass.s16),
                ],
                ...switch (s.phase) {
                  PartyPhase.gespraeche => [
                      // Die gemeinsame Rundenuhr (M4): Wer leitet, stellt sie hier.
                      SitzungsUhr(sitzung: s, groesse: 240),
                      const SizedBox(height: MMass.s16),
                      _status(s.abschnittFertig ? l.erzaehler_detektiv_fertig : l.erzaehler_befragt),
                      // „Dein Moment“ (Finale §3): wer noch zieht, und der letzte Aufruf.
                      if (s.einfluss) ...[MomentAufruf(sitzung: s), const SizedBox(height: MMass.s16)],
                      ?streifzug,
                      if (befragungen.isNotEmpty)
                        BefragungsStand(befragungen: befragungen, person: s.personAmTisch, erledigtText: l.party_befragung_erledigt),
                    ],
                  // Zwischen den Entscheidungen der Streifzug, während eines Zugs die Karte im Keller.
                  PartyPhase.entscheidungen when streifzug != null && s.zug == null => [
                      streifzug,
                      _status(_ermittlung(l)),
                    ],
                  PartyPhase.entscheidungen => [
                      OnlineRegisterKopf(l.erzaehler_zuschauer_titel.toUpperCase()),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(MMass.r10),
                        child: SizedBox(
                          height: 280,
                          child: IgnorePointer(child: GameView(key: const ValueKey('zuschauerkarte'), session: _zuschauer(), steuerung: false, kameraPassend: true)),
                        ),
                      ),
                      const SizedBox(height: MMass.s12),
                      _status(_ermittlung(l)),
                    ],
                  PartyPhase.anklage => [
                      _status(s.angeklagt == null ? l.erzaehler_anklage_wartet : l.erzaehler_angeklagt(s.figurName(s.angeklagt!))),
                    ],
                  _ => const <Widget>[],
                },
                // „Dein Moment“ (Finale §3.12): Die Zug-Tafel der Runde sieht nur der Erzähler.
                if (s.einflussTafel case final t?) ...[
                  ZugTafelAnsicht(tafel: t, darstellung: EinflussDarstellung.sitzung(s)),
                  const SizedBox(height: MMass.s16),
                ],
                if (paket != null && !anklage)
                  ErzaehlerPaketAnsicht(
                    key: ValueKey('pult-paket-${s.runde}'),
                    paket: paket,
                    person: s.personAmTisch,
                    aussehen: (id) => onlineAussehen(s.daten, id),
                    offen: s.phase == PartyPhase.gespraeche,
                  ),
              ],
            ),
          );
        },
      );

  /// Was der Detektiv gerade tut, in einem Satz: Frage, Weg, Würfel, Fund.
  String _ermittlung(L l) {
    final z = s.zug;
    if (z == null) return s.laufendeEntscheidung == null ? l.erzaehler_detektiv_fertig : '${l.erzaehler_detektiv_waehlt} ${s.laufendeEntscheidung!.frage}';
    return switch (z.phase) {
      RundenZugPhase.aktion => l.online_zug_aktion,
      RundenZugPhase.wurf => l.online_wuerfelt(s.wuerfelPate),
      RundenZugPhase.tischruf => l.online_tischruf_wartet,
      RundenZugPhase.fund => l.online_fund_wartet,
    };
  }

  Widget _status(String text) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s16),
        child: OnlineWarteNotiz(key: const ValueKey('pult-status'), text: text, uhr: !s.abschnittFertig),
      );
}
