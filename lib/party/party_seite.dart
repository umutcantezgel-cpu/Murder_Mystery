import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../app/router.dart';
import '../game/mordakte_game.dart';
import '../l10n/lookup.dart';
import 'bildschirme/anklage.dart';
import 'bildschirme/aufloesung.dart';
import 'bildschirme/einrichtung.dart';
import 'bildschirme/finale.dart';
import 'bildschirme/gruppenwahl.dart';
import 'bildschirme/intro.dart';
import 'bildschirme/karte.dart';
import 'bildschirme/resuemee.dart';
import 'bildschirme/rollen.dart';
import 'bildschirme/runde.dart';
import 'bildschirme/solo_gespraeche.dart';
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
          PartySkript.vorspielen(s, dev, dev.bis!);
          debugPrint('PARTY foto=${dev.bis!.name}');
        } else if (dev.rollen != null) {
          s.einrichten(rollen: dev.rollen!, detektiv: dev.detektiv, code: dev.fallCode(d.kanon));
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
              return const _Meldung(fehler: true);
            }
            final s = snap.data;
            if (s == null) return const _Meldung(fehler: false);
            return ListenableBuilder(
              listenable: s,
              builder: (context, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: KeyedSubtree(
                  key: ValueKey('${s.phase.name}-${s.runde}'),
                  child: bildschirm(s, menu: PartyKnopf(
                    text: L.of(context).party_menu,
                    icon: Icons.apps_rounded,
                    haupt: false,
                    onPressed: () => context.go(Routes.hub),
                  )),
                ),
              ),
            );
          },
        ),
      );
}

/// Bildschirm je Abschnitt des Abends.
Widget bildschirm(PartySitzung s, {Widget? menu}) => switch (s.phase) {
      PartyPhase.titel => TitelBildschirm(sitzung: s, menu: menu),
      PartyPhase.einrichtung => EinrichtungBildschirm(sitzung: s),
      PartyPhase.rollen => RollenBildschirm(sitzung: s),
      PartyPhase.intro => IntroBildschirm(sitzung: s),
      PartyPhase.gespraeche => s.solo ? SoloGespraecheBildschirm(sitzung: s) : RundeBildschirm(sitzung: s),
      PartyPhase.entscheidungen => KartenBildschirm(sitzung: s),
      PartyPhase.gruppenwahl => GruppenwahlBildschirm(sitzung: s),
      PartyPhase.bonus || PartyPhase.resuemee => ResuemeeBildschirm(sitzung: s),
      PartyPhase.anklage => AnklageBildschirm(sitzung: s),
      PartyPhase.finale => FinaleBildschirm(sitzung: s),
      PartyPhase.aufloesung || PartyPhase.ende => AufloesungBildschirm(sitzung: s),
    };

/// Lade- und Fehleranzeige ohne Textsammlung (die ist dann noch nicht da).
class _Meldung extends StatelessWidget {
  const _Meldung({required this.fehler});
  final bool fehler;

  @override
  Widget build(BuildContext context) => Center(
        child: fehler
            ? const Icon(Icons.error_outline, color: Keller.gefahr, size: 48)
            : const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Keller.kerze, strokeWidth: 3)),
      );
}
