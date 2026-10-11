import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';

import '../../stil/stil.dart';
import 'karten_ansicht.dart';

/// Die Karten des Tisches als kleiner Fächer: je Karte die Ladungen, die noch
/// übrig sind, ein Leuchten, wenn sie jetzt spielbar ist, und eine Hebung, wenn
/// sie für den laufenden Zug eingesetzt ist. Ohne Karten ist das Widget leer.
///
/// Die Hand entscheidet nichts: Ein Tipp geht an [onTipp], der Bildschirm
/// darunter spielt oder wählt die Karte (Wurf, Tischruf, Entscheidung, Karte).
class KartenHand extends StatelessWidget {
  const KartenHand({
    super.key,
    required this.vorrat,
    this.aktiv = const {},
    this.gewaehlt = const {},
    this.onTipp,
    this.kompakt = false,
    this.hinweis,
  });

  final TischVorrat vorrat;

  /// Karten (Kennungen), die jetzt gespielt oder eingesetzt werden können: sie leuchten.
  final Set<String> aktiv;

  /// Karten, die für den laufenden Zug eingesetzt sind: sie sind angehoben.
  final Set<String> gewaehlt;
  final ValueChanged<KartenDef>? onTipp;

  /// Kleine Karten für die Kartenansicht.
  final bool kompakt;

  /// Zeile unter dem Fächer (was ein Tipp bewirkt).
  final String? hinweis;

  @override
  Widget build(BuildContext context) {
    final karten = vorrat.karten;
    if (karten.isEmpty) return const SizedBox.shrink();
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final basis = kompakt ? 68.0 : 92.0;
    final mitte = (karten.length - 1) / 2;
    return LayoutBuilder(builder: (context, box) {
      // Auch auf schmalen Bildschirmen (320 px, große Schrift) bleibt der Fächer in der Breite.
      final n = karten.length;
      final platz = box.maxWidth.isFinite ? (box.maxWidth - 8) / (n * 0.94 + 0.06) : basis;
      final breite = platz < basis ? math.max(52.0, platz) : basis;
      return _faecher(context, t, f, karten, breite, mitte);
    });
  }

  Widget _faecher(BuildContext context, MSchrift t, MFarben f, List<KartenDef> karten, double breite, double mitte) {
    return Semantics(
      container: true,
      label: KartenTexte.handTitel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!kompakt) ...[
            Text(KartenTexte.handTitel.toUpperCase(), style: t.marke),
            const SizedBox(height: MMass.s8),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < karten.length; i++)
                  Align(
                    widthFactor: 0.94,
                    child: _Handkarte(
                      key: ValueKey('hand-${karten[i].id}'),
                      def: karten[i],
                      rest: vorrat.rest(karten[i].id),
                      breite: breite,
                      winkel: (i - mitte) * 0.07,
                      senkung: (i - mitte).abs() * 4,
                      aktiv: aktiv.contains(karten[i].id) && vorrat.rest(karten[i].id) > 0,
                      gewaehlt: gewaehlt.contains(karten[i].id),
                      onTipp: onTipp,
                    ),
                  ),
              ],
            ),
          ),
          if (hinweis != null && !kompakt) ...[
            const SizedBox(height: MMass.s8),
            Text(hinweis!, textAlign: TextAlign.center, style: t.leise.copyWith(fontSize: 13, color: f.papierLeise)),
          ],
        ],
      ),
    );
  }
}

class _Handkarte extends StatelessWidget {
  const _Handkarte({
    super.key,
    required this.def,
    required this.rest,
    required this.breite,
    required this.winkel,
    required this.senkung,
    required this.aktiv,
    required this.gewaehlt,
    required this.onTipp,
  });

  final KartenDef def;
  final int rest;
  final double breite;
  final double winkel;
  final double senkung;
  final bool aktiv;
  final bool gewaehlt;
  final ValueChanged<KartenDef>? onTipp;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final leer = rest <= 0;
    final zustand = gewaehlt
        ? KartenTexte.handGewaehlt
        : leer
            ? KartenTexte.handLeer
            : aktiv
                ? KartenTexte.handSpielbar
                : KartenTexte.handGesperrt;
    final hebung = gewaehlt ? -12.0 : 0.0;
    final glanz = aktiv || gewaehlt;
    final karte = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(breite * 0.06),
        boxShadow: [
          if (glanz) BoxShadow(color: f.akzent.withValues(alpha: gewaehlt ? 0.85 : 0.6), blurRadius: gewaehlt ? 16 : 12, spreadRadius: gewaehlt ? 2 : 1),
          const BoxShadow(color: Color(0x88000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Opacity(
        opacity: leer ? 0.45 : (aktiv || gewaehlt ? 1 : 0.78),
        child: KartenKarte(def: def, breite: breite),
      ),
    );
    return Semantics(
      button: true,
      enabled: onTipp != null,
      selected: gewaehlt,
      label: '${KartenTexte.handKarte(def.titel, rest, def.ladungen)}, $zustand',
      onTap: onTipp == null ? null : () => onTipp!(def),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTipp == null ? null : () => onTipp!(def),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, senkung + hebung),
              child: Transform.rotate(angle: winkel, child: karte),
            ),
            const SizedBox(height: 6),
            Transform.translate(
              offset: Offset(0, senkung),
              child: _Ladungen(rest: rest, gesamt: def.ladungen, farbe: f.akzentHell, leise: f.linieStark),
            ),
          ],
        ),
      ),
    );
  }
}

/// Punkte für die Ladungen: gefüllt = noch übrig.
class _Ladungen extends StatelessWidget {
  const _Ladungen({required this.rest, required this.gesamt, required this.farbe, required this.leise});

  final int rest;
  final int gesamt;
  final Color farbe;
  final Color leise;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < gesamt; i++)
            Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < rest ? farbe : Colors.transparent,
                border: Border.all(color: i < rest ? farbe : leise, width: 1.5),
              ),
            ),
        ],
      );
}

/// Welche Karten wirken jetzt in welchem Moment? Gemeinsame Zuordnung für die
/// Bildschirme: Karten mit Ladung und passender Art.
Set<String> kartenDerArt(TischVorrat vorrat, Set<KartenArt> arten) => {
      for (final k in vorrat.karten)
        if (arten.contains(k.art) && vorrat.rest(k.id) > 0) k.id,
    };
