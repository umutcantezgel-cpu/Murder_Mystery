import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'app/router.dart';
import 'meta/meta_store.dart';
import 'session/scenario_repository.dart';
import 'ui/haptics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Haptics.install();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  final meta = await MetaStore.load();
  Map<String, ScenarioDef> scenarios;
  try {
    scenarios = (await ScenarioRepository.load()).scenarios;
  } catch (e) {
    debugPrint('Szenarien konnten nicht geladen werden: $e');
    final sample = ScenarioDef.fromJson(jsonDecode(sampleScenarioJson) as Map<String, dynamic>);
    scenarios = {sample.id: sample};
  }

  final app = AppState(meta: meta, scenarios: scenarios);
  var initial = _devEntry(app);
  final autoplay = _query['autoplay'];
  final speed = double.tryParse(_query['speed'] ?? '') ?? 1;
  if (autoplay != null && await app.startAutoplay(autoplay, speed: speed)) initial = Routes.game;
  runApp(MordakteApp(app: app, initialLocation: initial));
}

Map<String, String> get _query {
  try {
    return Uri.base.queryParameters;
  } catch (_) {
    return const {};
  }
}

/// Einstieg ohne Parameter ist die Detektei (`/`), der Start des einen Spiels.
///
/// Entwickler-Einstieg (Web): `?fake=<phase>` öffnet eine Fake-Session in dieser Phase,
/// `?screen=detektei|neu|akte|sammlung|profile` springt zu einem Bildschirm des Spiels
/// (`neu` und `akte` mit `&akte=<id>`), `?screen=hub|cases|collection|online` zu den
/// klassischen Bildschirmen (nicht im Menü).
/// Zusätzlich: `open=notebook|board|dialog|signals|map`, `life=downed|ghost`,
/// `name=<Spielername>`, `xp=<Zahl>`. `?autoplay=<scenarioId>` startet ein echtes Solo-Spiel,
/// in dem die KI den eigenen Detektiv steuert. `?party=<fall>` öffnet den Partymodus.
/// `?screen=gewoelbe` öffnet den Begleiter „Spuk im Gewölbe“ (optional `&teil=…&n=…`).
/// Beide gehören nicht mehr zur Navigation des Spiels.
String _devEntry(AppState app) {
  final q = _query;
  final name = q['name'];
  if (name != null && name.trim().isNotEmpty) app.meta.name = name;
  final xp = int.tryParse(q['xp'] ?? '');
  if (xp != null) app.meta.debugSetXp(xp);

  // Partymodus: `?party=schlosskeller` (Parameter siehe lib/party/skript.dart),
  // `&semantik=1` schaltet die Bedienhilfen ein (Klicks in E2E-Läufen).
  if (q['semantik'] == '1') WidgetsBinding.instance.ensureSemantics();
  if (q['party'] != null) return Routes.party;

  final fake = q['fake'];
  if (fake != null) {
    final phase = Phase.values.where((p) => p.name == fake).firstOrNull ?? Phase.investigation;
    if (!app.meta.hasName) app.meta.name = 'Detektiv';
    app.openFake(
      phase,
      dev: DevOptions(open: q['open'], life: q['life']),
    );
    return phase == Phase.lobby ? Routes.lobby : Routes.game;
  }
  return switch (q['screen']) {
    'detektei' => Routes.detektei,
    'neu' => q['akte'] == null ? Routes.abendNeu : Routes.abendNeuMit(q['akte']!),
    'akte' => Routes.akteVon(q['akte'] ?? 'schlosskeller'),
    'sammlung' => Routes.sammlung,
    'hub' => Routes.klassik,
    'cases' => Routes.cases,
    'collection' => Routes.collection,
    'profile' => Routes.profile,
    'online' => Routes.online,
    'gewoelbe' => Routes.gewoelbe,
    _ => Routes.start,
  };
}
