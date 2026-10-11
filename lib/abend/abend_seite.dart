import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../meta/meta_store.dart';
import '../party/party_seite.dart';
import '../party/sitzung.dart';
import '../stil/stil.dart';
import 'abend_halter.dart';

/// Der laufende Abend (Route `/abend`): zeigt je Abschnitt dieselben
/// Bildschirme wie der alte Einstieg `/party`, teilt sich mit ihm den
/// Phasenwechsel ([PartyAblauf]), beginnt aber hinter dem Assistenten bei den
/// Rollen. Am Ende führt die Abschlusstafel zur Belohnung (`/abend/belohnung`),
/// von dort geht es in die Detektei zurück.
class AbendSeite extends StatefulWidget {
  const AbendSeite({super.key});

  @override
  State<AbendSeite> createState() => _AbendSeiteState();
}

class _AbendSeiteState extends State<AbendSeite> {
  late final AbendHalter _halter = context.read<AbendHalter>();
  late final PartySitzung? _sitzung = _halter.sitzung;

  @override
  void initState() {
    super.initState();
    // Ohne Abend (z. B. nach dem Neuladen der Seite) zurück in die Detektei.
    if (_sitzung == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.start);
      });
    }
  }

  @override
  void dispose() {
    final s = _sitzung;
    if (s != null) _halter.freigeben(s);
    super.dispose();
  }

  /// Das Ende ist gelesen: Ergebnis für die Belohnung merken und dorthin wechseln.
  /// Die Rolle des Geräts ist die gewählte Detektivklasse (`klasse:<name>`).
  void _zurBelohnung() {
    final s = _sitzung;
    if (s == null) return;
    final klasse = context.read<MetaStore>().loadout.cls;
    _halter.beende(AbendAbschluss(
      abendId: s.abendId,
      ergebnis: s.abendErgebnis(rolle: 'klasse:$klasse'),
      punkte: s.spiel.punkte,
      endeName: s.ende.name,
    ));
    context.go(Routes.abendBelohnung);
  }

  @override
  Widget build(BuildContext context) {
    final s = _sitzung;
    return Scaffold(
      backgroundColor: MFarben.von(context).grund,
      body: s == null ? const PartyMeldung(fehler: false) : PartyAblauf(sitzung: s, onEnde: _zurBelohnung),
    );
  }
}
