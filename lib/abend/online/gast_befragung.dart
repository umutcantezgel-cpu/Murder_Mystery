import 'package:flutter/material.dart';

import '../../party/bildschirme/spickzettel.dart' show spickPunkt;
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_ansicht.dart' show GastKontext;
import 'online_teile.dart';

/// Gespräche eines Gastes im Modell befragung (A-051): die eigene Karte mit
/// Tischgespräch in Stichpunkten, wer dich anspricht und was du sagst, wenn
/// der Detektiv dich befragt (privat, nur dieses Gerät). Dazu öffentlich, wen
/// der Detektiv befragt und wer am Tisch mit wem worüber spricht – nie eine
/// Antwort und nie ein fremder Stichpunkt.
class GastBefragung extends StatelessWidget {
  const GastBefragung({super.key, required this.c});

  final GastKontext c;

  @override
  Widget build(BuildContext context) {
    final l = c.l;
    final privat = c.privat;
    final eigene = jMaps(privat['gespraeche']);
    final angesprochen = jMaps(privat['angesprochen']);
    final befragung = privat['befragung'] is Map ? jMap(privat['befragung']) : null;
    final befragungen = jMaps(c.v['befragungen']);
    final tisch = jMaps(c.v['tisch']);
    // Fragt der Detektiv gerade, steht die eigene Befragung ganz oben: Jetzt antwortest du.
    final jetzt = befragung != null && befragung['frage'] is int && befragung['erledigt'] != true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (c.dossier != null && jetzt) ...[
          const SizedBox(height: MMass.s8),
          _befragung(befragung),
        ],
        if (c.dossier != null) ...[
          const SizedBox(height: MMass.s8),
          OnlineRegisterKopf(l.party_befragung_tisch_eigen.toUpperCase()),
          for (var i = 0; i < eigene.length; i++)
            Padding(padding: const EdgeInsets.only(top: MMass.s8, bottom: MMass.s16), child: _tischKarte(eigene[i], i)),
          _blatt(l.party_befragung_anspricht, [
            if (angesprochen.isEmpty) Text(l.party_befragung_niemand, style: MPapierSchrift.leise),
            for (final a in angesprochen) _zeile(c.personAmTisch(jText(a['sprecher'])), jText(a['thema'])),
          ], samen: 81),
          if (befragung != null && !jetzt) _befragung(befragung),
        ],
        if (befragungen.isNotEmpty)
          _blatt(l.party_befragung_oeffentlich, [
            for (final b in befragungen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _zeile(c.personAmTisch(jText(b['rolle'])), jText(b['thema']))),
                  if (b['erledigt'] == true) Icon(Icons.check_rounded, color: MRoh.stempelRot, semanticLabel: l.party_befragung_erledigt),
                ],
              ),
          ], samen: 83),
        if (tisch.isNotEmpty)
          _blatt(l.party_befragung_tisch_titel, [
            for (final t in tisch)
              _zeile(l.online_bot_spricht(c.personAmTisch(jText(t['rolle'])), c.personAmTisch(jText(t['partner']))), jText(t['thema'])),
          ], samen: 85),
      ],
    );
  }

  /// Das eigene Tischgespräch: mit wem, Thema, Ziel und die Stichpunkte.
  Widget _tischKarte(Map<String, Object?> g, int nr) {
    final partner = jText(g['partner']);
    final look = c.aussehen(partner);
    return MBlatt(
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      klammer: true,
      randFarbe: c.figurFarbe(partner),
      neigung: nr.isEven ? -0.004 : 0.004,
      samen: 40 + nr,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (look != null) ...[
                MFotoabzug(look: look, groesse: 52, neigung: 0.04, akzent: c.figurFarbe(partner)),
                const SizedBox(width: 14),
              ],
              Expanded(child: Text(c.l.online_gespraech_mit(c.personAmTisch(partner)), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20))),
            ],
          ),
          const SizedBox(height: MMass.s16),
          MFeld(name: c.l.online_gespraech_thema, wert: jText(g['thema'])),
          MFeld(name: c.l.online_gespraech_ziel, wert: jText(g['ziel'])),
          Text(c.l.party_befragung_stichpunkte, style: MPapierSchrift.leise),
          const SizedBox(height: 4),
          for (final p in jTexte(g['stichpunkte'])) spickPunkt(p),
        ],
      ),
    );
  }

  /// Die eigene Befragung: ob und was der Detektiv fragt, Thema, Fragen und was du sagst.
  Widget _befragung(Map<String, Object?> b) {
    final l = c.l;
    final fragen = jTexte(b['fragen']);
    final frage = b['frage'] is int ? b['frage'] as int : null;
    final stand = frage != null && frage < fragen.length
        ? l.party_befragung_fragt(fragen[frage])
        : b['pflicht'] == true
            ? l.party_befragung_sicher
            : b['entfaellt'] == true
                ? l.party_befragung_entfaellt
                : l.party_befragung_vielleicht;
    final sagen = [...jTexte(b['stichpunkte']), for (final x in jTexte(b['behaupte'])) l.party_befragung_behaupte(x)];
    return _blatt(l.party_befragung_dich, [
      Text(stand, style: frage != null ? MPapierSchrift.hand.copyWith(fontSize: 22) : MPapierSchrift.kursiv),
      const SizedBox(height: MMass.s8),
      MFeld(name: l.party_befragung_thema, wert: jText(b['thema'])),
      Text(l.party_befragung_fragen, style: MPapierSchrift.leise),
      const SizedBox(height: 4),
      for (final f in fragen) spickPunkt(f),
      const SizedBox(height: 4),
      Text(l.party_befragung_sagen, style: MPapierSchrift.leise),
      const SizedBox(height: 4),
      if (sagen.isEmpty) Text(l.party_befragung_nichts, style: MPapierSchrift.kursiv),
      for (final x in sagen) spickPunkt(x),
    ], samen: 87, stempel: b['erledigt'] == true ? l.party_befragung_erledigt : null);
  }

  /// Eine Zeile: Name oder Paarung, darunter das Thema in Schreibmaschine.
  Widget _zeile(String oben, String thema) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(oben, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
            if (thema.isNotEmpty) Text(thema, style: MPapierSchrift.maschine.copyWith(fontSize: 14)),
          ],
        ),
      );

  /// Ein Blatt mit Formularkopf.
  Widget _blatt(String titel, List<Widget> kinder, {required int samen, String? stempel}) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s16),
        child: MBlatt(
          art: PapierArt.notiz,
          samen: samen,
          neigung: samen.isEven ? -0.004 : 0.004,
          stempel: stempel,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titel.toUpperCase(), style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
              const SizedBox(height: 4),
              Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
              const SizedBox(height: MMass.s12),
              ...kinder,
            ],
          ),
        ),
      );
}
