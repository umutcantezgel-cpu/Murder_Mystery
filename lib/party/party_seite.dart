import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../app/router.dart';
import '../game/mordakte_game.dart';
import '../l10n/lookup.dart';
import '../stil/stil.dart';
import 'bildschirme/anklage.dart';
import 'bildschirme/aufloesung.dart';
import 'bildschirme/befragung.dart';
import 'bildschirme/einrichtung.dart';
import 'bildschirme/finale.dart';
import 'bildschirme/gruppenwahl.dart';
import 'bildschirme/intro.dart';
import 'bildschirme/karte.dart';
import 'bildschirme/resuemee.dart';
import 'bildschirme/rollen.dart';
import 'bildschirme/runde.dart';
import 'bildschirme/rundgang.dart';
import 'bildschirme/solo_gespraeche.dart';
import 'bildschirme/streifzug.dart';
import 'bildschirme/titel.dart';
import 'daten.dart';
import 'party_stil.dart';
import 'sitzung.dart';
import 'skript.dart';

/// Einstieg des Partymodus (Route `/party`): lädt den Fall und zeigt je
/// Abschnitt des Abends den passenden Bildschirm.
class PartySeite extends StatefulWidget {
  const PartySeite({super.key, this.dev});

  /// Entwickler-Einstieg (`?party=…`), sonst `null`.
  final PartyDev? dev;

  @override
  State<PartySeite> createState() => _PartySeiteState();
}

class _PartySeiteState extends State<PartySeite> {
  late final Future<PartySitzung> _laden;
  PartySitzung? _sitzung;

  @override
  void initState() {
    super.initState();
    final dev = widget.dev;
    _laden = PartyDaten.laden(rootBundle, fall: dev?.fall ?? 'schlosskeller').then((d) {
      final s = _sitzung = PartySitzung(d);
      if (dev != null) {
        PartySitzung.protokoll = true;
        debugPrint('PARTY geladen fall=${d.fall}');
        if (dev.zoom != null) MordakteGame.debugInitialZoom = dev.zoom!;
        if (dev.at != null) s.detektivAn.value = dev.at;
        if (dev.skript != null) {
          PartySkript(s, dev).starten();
        } else if (dev.bis != null) {
          PartySkript.vorspielenMitGespraech(s, dev, dev.bis!);
          debugPrint('PARTY foto=${dev.bis!.name}');
        } else if (dev.rollen != null) {
          s.einrichten(rollen: dev.rollen!, detektiv: dev.detektiv, code: dev.fallCode(d.kanon), fassung: dev.fassungFuer(s));
          if (dev.dauerSekunden != null) s.rundendauer = Duration(seconds: dev.dauerSekunden!);
        }
      }
      return s;
    });
  }

  @override
  void dispose() {
    _sitzung?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Keller.nacht,
        body: FutureBuilder<PartySitzung>(
          future: _laden,
          builder: (context, snap) {
            if (snap.hasError) {
              debugPrint('PARTY fehler ${snap.error}\n${snap.stackTrace}');
              return const PartyMeldung(fehler: true);
            }
            final s = snap.data;
            if (s == null) return const PartyMeldung(fehler: false);
            return PartyAblauf(
              sitzung: s,
              menu: PartyKnopf(
                text: L.of(context).party_menu,
                icon: Icons.apps_rounded,
                haupt: false,
                onPressed: () => context.go(Routes.start),
              ),
            );
          },
        ),
      );
}

/// Zeigt je Abschnitt des Abends den passenden Bildschirm und blendet beim
/// Wechsel über. Gemeinsam für den alten Einstieg `/party` ([PartySeite]) und
/// den Abend im Spiel (`AbendSeite`). [menu] erscheint nur auf dem Titel.
class PartyAblauf extends StatelessWidget {
  const PartyAblauf({super.key, required this.sitzung, this.menu, this.onEnde, this.ersatz});

  final PartySitzung sitzung;
  final Widget? menu;

  /// Eigener Bildschirm für einen Abschnitt (Online-Abend des Gastgebers: Warten
  /// auf die Gäste statt der Geräteübergabe); `null` heißt der übliche Bildschirm.
  final Widget? Function(PartySitzung sitzung)? ersatz;

  /// Weg vom Ende des Abends; ohne Angabe führt die Abschlusstafel in die Detektei.
  final VoidCallback? onEnde;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    return AkteThema(
      akte: s.daten.fall,
      child: ListenableBuilder(
        listenable: s,
        builder: (context, _) => AnimatedSwitcher(
          duration: MBewegung.ruhig(context) ? Duration.zero : const Duration(milliseconds: 350),
          child: KeyedSubtree(
            // Vorspiel und Morgen (M7b) blenden wie ein eigener Abschnitt über; kurz bleibt der Schlüssel gleich.
            key: ValueKey('${s.phase.name}-${s.runde}${s.rundgang == null ? '' : '-${s.rundgang!.name}'}'),
            child: ersatz?.call(s) ?? bildschirm(s, menu: menu, onEnde: onEnde),
          ),
        ),
      ),
    );
  }
}

/// Bildschirm je Abschnitt des Abends.
Widget bildschirm(PartySitzung s, {Widget? menu, VoidCallback? onEnde}) => switch (s.phase) {
      PartyPhase.titel => TitelBildschirm(sitzung: s, menu: menu),
      PartyPhase.einrichtung => EinrichtungBildschirm(sitzung: s),
      PartyPhase.rollen => RollenBildschirm(sitzung: s),
      // Langer Abend (M7b): erst das Vorspiel, dann die Diashow der Einleitung.
      PartyPhase.intro when s.rundgang != null => RundgangBildschirm(sitzung: s),
      PartyPhase.intro => IntroBildschirm(sitzung: s),
      // Langer Abend (M7b): Gespräche und Entscheidungen werden zum Streifzug durchs Schloss.
      PartyPhase.gespraeche || PartyPhase.entscheidungen when s.lang && s.daten.hat('langfassung') => StreifzugBildschirm(sitzung: s),
      // Modell befragung (A-051): Im Solo befragt der Detektiv die Bots; Altakten hören Sprechblasen.
      PartyPhase.gespraeche => s.solo
          ? (s.befragungsmodell ? BefragungBildschirm(sitzung: s) : SoloGespraecheBildschirm(sitzung: s))
          : RundeBildschirm(sitzung: s),
      PartyPhase.entscheidungen => KartenBildschirm(sitzung: s),
      PartyPhase.gruppenwahl => GruppenwahlBildschirm(sitzung: s),
      PartyPhase.bonus || PartyPhase.resuemee => ResuemeeBildschirm(sitzung: s),
      PartyPhase.anklage => AnklageBildschirm(sitzung: s),
      PartyPhase.finale => FinaleBildschirm(sitzung: s),
      // Langer Abend (M7b): nach der Auflösung der Morgen, dann das Schlussbild.
      PartyPhase.ende when s.rundgang != null => RundgangBildschirm(sitzung: s),
      PartyPhase.aufloesung || PartyPhase.ende => AufloesungBildschirm(sitzung: s, onEnde: onEnde),
    };

/// Lade- und Fehleranzeige ohne Textsammlung (die ist dann noch nicht da).
class PartyMeldung extends StatelessWidget {
  const PartyMeldung({super.key, required this.fehler});
  final bool fehler;

  @override
  Widget build(BuildContext context) => Center(
        child: fehler
            ? const Icon(Icons.error_outline, color: Keller.gefahr, size: 48)
            : const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Keller.kerze, strokeWidth: 3)),
      );
}
