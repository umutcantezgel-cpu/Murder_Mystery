import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart' show Sitz;

import '../klang/klang.dart';
import '../l10n/lookup.dart';
import '../stil/mappe/assistent_formular.dart' show MAnkreuzWahl;
import '../stil/stil.dart';
import 'einrichtung/abend_neu_seite.dart' show Spielweise;

/// Abschnitte des Abends, wie die Übersicht sie zusammenfasst (Bonus und
/// Resümee bzw. Finale und Auflösung gehören zusammen).
enum UebersichtPhase { rollen, intro, gespraeche, entscheidungen, gruppenwahl, resuemee, anklage, finale }

/// Die Sitze eines Abends je Spielweise (Langer Abend M3): Solo ermittelt nur
/// der Detektiv (Bots spielen die Rollen, nie ein Erzähler); an einem Gerät
/// kommen die Rollen und optional ein Erzähler dazu; online außerdem Geräte
/// ohne Figur (Assistenz). Einen Erzähler gibt es nur in Akten mit
/// Erzähler-Sitz ([mitErzaehler], `PartyDaten.mitErzaehlerSitz`); die Altakten
/// kennen weder Pult noch Erzähler.
List<Sitz> sitzeBei(Spielweise weise, {bool mitErzaehler = true}) => switch (weise) {
      Spielweise.solo => const [Sitz.detektiv],
      Spielweise.reihum => [Sitz.detektiv, if (mitErzaehler) Sitz.erzaehler, Sitz.rolle],
      Spielweise.eigene => [Sitz.detektiv, if (mitErzaehler) Sitz.erzaehler, Sitz.rolle, Sitz.assistenz],
    };

/// Der Sitzzeitplan: die aktive Aufgabe von [sitz] im Abschnitt [phase] bei
/// [weise], höchstens acht Wörter (R17). Jeder Sitz hat in jedem Abschnitt eine
/// (Beleg: `rollen_uebersicht_test`). Den kurzen und den langen Abend trennt die
/// Übersicht noch nicht; der lange kommt mit M7. Mit [einfluss] („Dein Moment“,
/// Finale §3) ziehen die Rollen in den Gesprächen ihren Moment, der Detektiv
/// liest Tischwerte und ruft nach Pech, der Erzähler liest die Folgen vor.
String aufgabe(L l, Spielweise weise, Sitz sitz, UebersichtPhase phase, {bool einfluss = false}) {
  final solo = weise == Spielweise.solo;
  final reihum = weise == Spielweise.reihum;
  if (einfluss) {
    switch ((sitz, phase)) {
      case (Sitz.rolle, UebersichtPhase.gespraeche):
        return l.aufgabe_rolle_moment;
      case (Sitz.detektiv, UebersichtPhase.entscheidungen):
        return l.aufgabe_detektiv_tischwerte;
      case (Sitz.erzaehler, UebersichtPhase.entscheidungen):
        return l.aufgabe_erzaehler_folgen;
      default:
        break;
    }
  }
  return switch (sitz) {
    Sitz.detektiv => switch (phase) {
        UebersichtPhase.rollen => l.aufgabe_detektiv_rollen,
        UebersichtPhase.intro => solo ? l.aufgabe_detektiv_solo_intro : l.aufgabe_detektiv_intro,
        UebersichtPhase.gespraeche => solo ? l.aufgabe_detektiv_solo_gespraeche : l.aufgabe_detektiv_gespraeche,
        UebersichtPhase.entscheidungen => l.aufgabe_detektiv_entscheidungen,
        UebersichtPhase.gruppenwahl => l.aufgabe_detektiv_gruppenwahl,
        UebersichtPhase.resuemee => solo ? l.aufgabe_detektiv_solo_resuemee : l.aufgabe_detektiv_resuemee,
        UebersichtPhase.anklage => l.aufgabe_detektiv_anklage,
        UebersichtPhase.finale => l.aufgabe_detektiv_finale,
      },
    Sitz.erzaehler => switch (phase) {
        UebersichtPhase.rollen => l.aufgabe_erzaehler_rollen,
        // An einem Gerät liest der Erzähler am verdeckten Pult.
        UebersichtPhase.intro || UebersichtPhase.resuemee when reihum => l.aufgabe_erzaehler_reihum,
        UebersichtPhase.intro => l.aufgabe_erzaehler_intro,
        UebersichtPhase.gespraeche => l.aufgabe_erzaehler_gespraeche,
        UebersichtPhase.entscheidungen => l.aufgabe_erzaehler_entscheidungen,
        UebersichtPhase.gruppenwahl => l.aufgabe_erzaehler_gruppenwahl,
        UebersichtPhase.resuemee => l.aufgabe_erzaehler_resuemee,
        UebersichtPhase.anklage => l.aufgabe_erzaehler_anklage,
        UebersichtPhase.finale => l.aufgabe_erzaehler_finale,
      },
    Sitz.rolle => switch (phase) {
        UebersichtPhase.rollen => l.aufgabe_rolle_rollen,
        UebersichtPhase.intro => l.aufgabe_rolle_intro,
        UebersichtPhase.gespraeche => l.aufgabe_rolle_gespraeche,
        UebersichtPhase.entscheidungen => l.aufgabe_rolle_entscheidungen,
        UebersichtPhase.gruppenwahl => l.aufgabe_rolle_gruppenwahl,
        UebersichtPhase.resuemee => l.aufgabe_rolle_resuemee,
        UebersichtPhase.anklage => l.aufgabe_rolle_anklage,
        UebersichtPhase.finale => l.aufgabe_rolle_finale,
      },
    Sitz.assistenz => switch (phase) {
        UebersichtPhase.rollen => l.aufgabe_assistenz_rollen,
        UebersichtPhase.intro => l.aufgabe_assistenz_intro,
        UebersichtPhase.gespraeche => l.aufgabe_assistenz_gespraeche,
        UebersichtPhase.entscheidungen => l.aufgabe_assistenz_entscheidungen,
        UebersichtPhase.gruppenwahl => l.aufgabe_assistenz_gruppenwahl,
        UebersichtPhase.resuemee => l.aufgabe_assistenz_resuemee,
        UebersichtPhase.anklage => l.aufgabe_assistenz_anklage,
        UebersichtPhase.finale => l.aufgabe_assistenz_finale,
      },
  };
}

String _phase(L l, UebersichtPhase p) => switch (p) {
      UebersichtPhase.rollen => l.uebersicht_phase_rollen,
      UebersichtPhase.intro => l.uebersicht_phase_intro,
      UebersichtPhase.gespraeche => l.uebersicht_phase_gespraeche,
      UebersichtPhase.entscheidungen => l.uebersicht_phase_entscheidungen,
      UebersichtPhase.gruppenwahl => l.uebersicht_phase_gruppenwahl,
      UebersichtPhase.resuemee => l.uebersicht_phase_resuemee,
      UebersichtPhase.anklage => l.uebersicht_phase_anklage,
      UebersichtPhase.finale => l.uebersicht_phase_finale,
    };

(String, String, IconData) _sitz(L l, Sitz s, String? detektivWort) => switch (s) {
      Sitz.detektiv => (detektivWort ?? l.uebersicht_sitz_detektiv, l.uebersicht_sitz_detektiv_kurz, Icons.search_rounded),
      Sitz.erzaehler => (l.uebersicht_sitz_erzaehler, l.uebersicht_sitz_erzaehler_kurz, Icons.menu_book_rounded),
      Sitz.rolle => (l.uebersicht_sitz_rolle, l.uebersicht_sitz_rolle_kurz, Icons.theater_comedy_outlined),
      Sitz.assistenz => (l.uebersicht_sitz_assistenz, l.uebersicht_sitz_assistenz_kurz, Icons.visibility_outlined),
    };

/// „Wer macht was“ (Langer Abend M3): je Spielweise die Sitze mit ihrer
/// Aufgabe in jedem Abschnitt. Erreichbar aus dem Assistenten, der Lobby und
/// dem Abendmenü ([zeigeRollenUebersicht]). Der eigene Sitz ([hervorheben])
/// steht oben und offen. Ohne Erzähler-Sitz der Akte ([mitErzaehler]) fehlt
/// der Erzähler; der Detektiv heißt, wie die Akte ihn nennt ([detektivWort]).
class RollenUebersicht extends StatefulWidget {
  const RollenUebersicht({super.key, this.weise = Spielweise.eigene, this.hervorheben, this.mitErzaehler = true, this.detektivWort, this.einfluss = false});

  final Spielweise weise;
  final Sitz? hervorheben;
  final bool mitErzaehler;

  /// Spielt der Abend „Dein Moment“ (Aufgaben je Sitz, [aufgabe])?
  final bool einfluss;

  /// Bezeichnung des Detektiv-Sitzes in dieser Akte (Noir „Inspektor“); sonst „Detektiv“.
  final String? detektivWort;

  @override
  State<RollenUebersicht> createState() => _RollenUebersichtState();
}

class _RollenUebersichtState extends State<RollenUebersicht> {
  late Spielweise _weise = widget.weise;
  late final Set<Sitz> _offen = {?widget.hervorheben};

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final alle = sitzeBei(_weise, mitErzaehler: widget.mitErzaehler);
    final sitze = [
      ...alle.where((s) => s == widget.hervorheben),
      ...alle.where((s) => s != widget.hervorheben),
    ];
    return Column(
      key: const ValueKey('rollen-uebersicht'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l.rollen_uebersicht_hinweis, style: MPapierSchrift.leise),
        const SizedBox(height: MMass.s8),
        MAnkreuzWahl<Spielweise>(
          optionen: [
            (Spielweise.solo, l.uebersicht_weise_solo),
            (Spielweise.reihum, l.uebersicht_weise_reihum),
            (Spielweise.eigene, l.uebersicht_weise_online),
          ],
          gewaehlt: _weise,
          onWahl: (w) => setState(() => _weise = w),
        ),
        const SizedBox(height: MMass.s12),
        for (final s in sitze)
          _SitzKarte(
            weise: _weise,
            sitz: s,
            einfluss: widget.einfluss,
            detektivWort: widget.detektivWort,
            offen: _offen.contains(s),
            onTap: () => setState(() => _offen.contains(s) ? _offen.remove(s) : _offen.add(s)),
          ),
      ],
    );
  }
}

/// Ein Sitz als aufklappbare Karteikarte: Name und was er tut; offen je
/// Abschnitt seine Aufgabe.
class _SitzKarte extends StatelessWidget {
  const _SitzKarte({required this.weise, required this.sitz, required this.offen, required this.onTap, this.detektivWort, this.einfluss = false});

  final Spielweise weise;
  final Sitz sitz;
  final bool einfluss;
  final String? detektivWort;
  final bool offen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final (name, kurz, icon) = _sitz(l, sitz, detektivWort);
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: Semantics(
        button: true,
        expanded: offen,
        child: MBlatt(
          key: ValueKey('uebersicht-${sitz.name}'),
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          neigung: sitz.index.isEven ? -0.003 : 0.003,
          samen: 140 + sitz.index,
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: MRoh.tinteBlau),
                  const SizedBox(width: MMass.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MGanzeWorte(name, stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
                        Text(kurz, style: MPapierSchrift.leise),
                      ],
                    ),
                  ),
                  Icon(offen ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: MRoh.tinte),
                ],
              ),
              if (offen) ...[
                const SizedBox(height: MMass.s8),
                for (final p in UebersichtPhase.values)
                  Padding(
                    padding: const EdgeInsets.only(top: MMass.s4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(_phase(l, p).toUpperCase(), style: MPapierSchrift.marke),
                        Text(aufgabe(l, weise, sitz, p, einfluss: einfluss), style: MPapierSchrift.text),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Öffnet „Wer macht was“ als Karteikarte über der Seite.
Future<void> zeigeRollenUebersicht(
  BuildContext context, {
  Spielweise weise = Spielweise.eigene,
  Sitz? hervorheben,
  bool mitErzaehler = true,
  String? detektivWort,
  bool einfluss = false,
}) {
  Klang.instanz.spiele('blatt', laut: 0.7);
  final l = L.of(context);
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (c) => MKarteikartenDialog(
      titel: l.rollen_uebersicht_titel,
      inhalt: RollenUebersicht(weise: weise, hervorheben: hervorheben, mitErzaehler: mitErzaehler, detektivWort: detektivWort, einfluss: einfluss),
      aktionen: [MKnopf(text: l.common_close, art: MKnopfArt.zweit, onPressed: () => Navigator.of(c).pop())],
    ),
  );
}

/// Knopf „Wer macht was?“ (leise), der die Übersicht öffnet; [mitErzaehler]
/// und [detektivWort] wie bei [RollenUebersicht].
class RollenUebersichtKnopf extends StatelessWidget {
  const RollenUebersichtKnopf({
    super.key,
    this.weise = Spielweise.eigene,
    this.hervorheben,
    this.art = MKnopfArt.leise,
    this.mitErzaehler = true,
    this.detektivWort,
    this.einfluss = false,
  });

  final Spielweise weise;
  final Sitz? hervorheben;
  final MKnopfArt art;
  final bool mitErzaehler;
  final String? detektivWort;

  /// Spielt der Abend „Dein Moment“?
  final bool einfluss;

  @override
  Widget build(BuildContext context) => MKnopf(
        key: const ValueKey('wer-macht-was'),
        text: L.of(context).rollen_uebersicht_oeffnen,
        art: art,
        icon: Icons.groups_outlined,
        onPressed: () => zeigeRollenUebersicht(
          context,
          weise: weise,
          hervorheben: hervorheben,
          mitErzaehler: mitErzaehler,
          detektivWort: detektivWort,
          einfluss: einfluss,
        ),
      );
}
