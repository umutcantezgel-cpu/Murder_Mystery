import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../game/game_view.dart';
import '../game/mordakte_game.dart';
import '../game/szenen_erweiterung.dart';
import '../session/game_session.dart';
import 'daten.dart';

/// Vorschau der Welt-Ebenen des langen Abends (M7a, `?ebene=<id>`): Der
/// Detektiv geht frei über jede Ebene. Portale (Wendeltreppe, Hoftür,
/// Außentor, Einfahrtstor) sind Hotspots; offen in der [lage] wechseln sie
/// die Ebene und setzen den Detektiv an den Ankunftspunkt der anderen Seite.
/// Noch ohne Einbindung in den Abend (M7b): keine Figuren, keine
/// Entscheidungen, keine Zeit. Der Kanon-Keller bleibt unberührt; offene
/// Portaltüren gelten nur für das Darstellungsraster des Renderers.
class EbenenVorschau implements GameSession, SzenenErweiterung, SzenenEbenen {
  EbenenVorschau(this.welt, Map<String, ScenarioDef> szenarien, {String ebene = kellerEbene, WeltLage? lage, (double, double)? at})
      : _jeEbene = szenarien,
        _jeId = {for (final s in szenarien.values) s.id: s},
        lage = lage ?? WeltLage(lang: true, uhr: welt.zeiten.morgen),
        _ebene = szenarien.containsKey(ebene) ? ebene : kellerEbene {
    final d = welt.kanon.figur((welt.kanon.figurenJson['detektiv'] as Map)['id'] as String)!;
    _aussehen = LookDef.fromJson(renderLook(d));
    final start = at ?? _start(_ebene);
    _x = start.$1;
    _y = start.$2;
    _zeigeFall();
    _zeigeWelt(korrektur: true);
  }

  /// Lädt Kanon, Vorlage, `welt.json` und die Langfassung aus den Assets.
  static Future<EbenenVorschau> laden(AssetBundle bundle,
      {String fall = 'schlosskeller', String ebene = kellerEbene, WeltLage? lage, (double, double)? at}) async {
    final daten = await PartyDaten.laden(bundle, fall: fall);
    final weltJson = jsonDecode(await bundle.loadString('content/welt/$fall/welt.json')) as Map<String, Object?>;
    final lang = jsonDecode(await bundle.loadString('content/welt/$fall/${weltJson['langfassung']}')) as Map<String, Object?>;
    final welt = WeltEbenen.ausJson(lang, daten.kanon);
    final darstellung = (daten.kanon.json['setting.json']?['darstellung'] as Map?) ?? const {};
    final vorlage = jsonDecode(await bundle.loadString(darstellung['vorlage'] as String? ?? 'content/scenarios/ravensmoor.json')) as Map<String, dynamic>;
    final szenarien = partyEbenenSzenarien(daten.kanon, vorlage, welt, id: daten.szenario.id, welt: weltJson);
    return EbenenVorschau(welt, szenarien, ebene: ebene, lage: lage, at: at);
  }

  final WeltEbenen welt;

  /// Zeitpunkt des Abends, nach dem die Portale öffnen (Vorgabe: Morgen im
  /// langen Abend, dann ist alles offen).
  final WeltLage lage;

  /// Benutzt die Vorschau Portale? Aus, wenn ein Test nur die Wege prüft.
  bool portaleBenutzen = true;

  final Map<String, ScenarioDef> _jeEbene;
  final Map<String, ScenarioDef> _jeId;
  String _ebene;
  late final LookDef _aussehen;
  final _world = ValueNotifier<WorldSnapshot?>(null);
  final _case = ValueNotifier<CaseView?>(null);
  final _events = StreamController<GameEvent>.broadcast();
  final _connected = ValueNotifier<bool>(true);
  double _x = 0, _y = 0, _f = 0.8;
  int _t = 0, _version = 0;
  String? _letzterRaum;
  bool _entsorgt = false;

  /// Die gezeigte Ebene.
  String get ebene => _ebene;

  /// Szenario der Ebene [ebene].
  ScenarioDef szenarioVon(String ebene) => _jeEbene[ebene]!;

  /// Erster Ankunftspunkt eines Portals auf [ebene].
  (double, double) _start(String ebene) {
    final s = welt.portaleAuf(ebene).first.$2;
    return (s.ankunftX, s.ankunftY);
  }

  /// Portal [id] mit seiner Seite auf der gezeigten Ebene.
  (Portal, PortalSeite)? _portalHier(String id) => welt.portaleAuf(_ebene).where((e) => e.$1.id == id).firstOrNull;

  /// Wechselt durch das Portal [id] auf die andere Ebene, wenn es von hier
  /// aus erreichbar und in der [lage] offen ist.
  bool wechsle(String id) {
    final hier = _portalHier(id);
    if (_entsorgt || hier == null || !welt.offen(hier.$1.offen, lage)) return false;
    final dort = hier.$1.gegenueber(hier.$2);
    _ebene = dort.ebene;
    _x = dort.ankunftX;
    _y = dort.ankunftY;
    _letzterRaum = null;
    _zeigeFall();
    _zeigeWelt(korrektur: true);
    return true;
  }

  /// Detektiv an eine Stelle der gezeigten Ebene setzen (Tests, Vorschau).
  void setzeDetektiv(double x, double y) {
    _x = x;
    _y = y;
    _zeigeWelt(korrektur: true);
  }

  void _zeigeFall() {
    if (_entsorgt) return;
    _case.value = CaseView(
      version: ++_version,
      roomCode: roomCode,
      hostId: playerId,
      scenarioId: _jeEbene[_ebene]!.id,
      mode: 'story',
      seed: 0,
      bots: 0,
      lobby: const [],
      phase: Phase.investigation,
      chapter: 1,
      notebook: const [],
      board: const [],
      deductions: const [],
      contradictions: 0,
      hotspots: {
        for (final (p, _) in welt.portaleAuf(_ebene))
          if (welt.offen(p.offen, lage)) p.id: HotspotState.open,
      },
      openDoors: [
        for (final k in welt.offeneKacheln(_ebene, lage)) [k.x, k.y],
      ],
      items: const [],
      inventory: const [],
      leadOptions: const [],
      leadVotes: const {},
      chosenLeads: const [],
      accusations: const {},
      heard: const {},
      deadNpcs: const [],
      abilityCooldownMs: 0,
      abilityCharges: 0,
      pingsLeft: 0,
      ending: null,
    );
  }

  void _zeigeWelt({bool korrektur = false}) {
    if (_entsorgt) return;
    _t += 100;
    _world.value = WorldSnapshot(
      t: _t,
      phase: Phase.investigation,
      chapter: 1,
      phaseRemainingMs: 0,
      phaseTotalMs: 0,
      detectives: [
        DetectiveView(
          id: playerId, name: '', cls: 'forensic', coat: 0, hat: 'fedora', bot: false, connected: true,
          x: _x, y: _y, facing: _f, life: LifeState.alive, hp: 3, maxHp: 3, nerves: 100, hidden: false,
          moving: false, channel: null, effects: const [], downedLeftMs: 0,
        ),
      ],
      npcs: const [],
      shadow: null,
      signals: const [],
      ackSeq: 0,
      correctX: korrektur ? _x : null,
      correctY: korrektur ? _y : null,
    );
  }

  // ---------------------------------------------------------------------------
  // GameSession

  @override
  String get playerId => 'me';

  @override
  String get roomCode => 'EBENE';

  @override
  bool get isOnline => false;

  @override
  ValueListenable<WorldSnapshot?> get world => _world;

  @override
  ValueListenable<CaseView?> get caseView => _case;

  @override
  Stream<GameEvent> get events => _events.stream;

  @override
  ValueListenable<bool> get connected => _connected;

  @override
  Map<String, ScenarioDef> get scenarios => _jeId;

  @override
  ScenarioDef? get scenario => _jeEbene[_ebene];

  @override
  void move(double x, double y, double facing) {
    _x = x;
    _y = y;
    _f = facing;
  }

  @override
  void send(Command command) {
    if (command case Interact(:final target) when portaleBenutzen) wechsle(target);
  }

  @override
  Future<void> dispose() async {
    if (_entsorgt) return;
    _entsorgt = true;
    _world.dispose();
    _case.dispose();
    _connected.dispose();
    await _events.close();
  }

  // ---------------------------------------------------------------------------
  // SzenenEbenen

  @override
  Set<String> get ebenenSzenarien => _jeId.keys.toSet();

  // ---------------------------------------------------------------------------
  // SzenenErweiterung

  @override
  String? npcAktion(String npcId) => null;

  @override
  bool npcUntersuchen(String npcId) => false;

  @override
  String? hotspotAktion(String hotspotId) => _portalHier(hotspotId)?.$2.aktion;

  /// Licht der Ebene: Grunddunkel aus der Stimmung, Raumlicht und Lichtpunkte
  /// der Lichtquellen, die zur Uhrzeit der [lage] brennen. Laternen leuchten
  /// als Requisiten selbst.
  @override
  SzenenLicht? get licht {
    final e = welt.ebenen[_ebene]!;
    final g = e.graph;
    final brennt = [for (final l in g.lichtquellen.values) if (l.traeger == null && l.brennt(lage.uhr)) l];
    return SzenenLicht(
      dunkel: e.dunkel,
      helleRaeume: {for (final l in brennt) ...l.raeume},
      punkte: [
        for (final l in brennt)
          if (g.orte[l.ort] case final o?)
            SzenenLichtpunkt(o.x, o.y, z: 1.6, radius: l.radius, farbe: _farbe(l.farbe ?? '#FFF1C9'), flackern: l.flackern),
      ],
    );
  }

  static Color _farbe(String hex) => Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);

  /// Der eigene Raum und die Räume hinter offenen Türen (wie am Tisch).
  @override
  Set<String>? sichtbareRaeume(double x, double y) {
    final g = welt.ebenen[_ebene]!.graph;
    final raum = g.raumAn(x, y)?.id ?? _letzterRaum;
    if (raum == null) return null;
    _letzterRaum = raum;
    final offen = welt.offeneKacheln(_ebene, lage);
    return {
      raum,
      for (final t in g.tueren.values)
        if (!t.verschlossen || t.kacheln.every(offen.contains))
          if (t.von == raum) t.nach else if (t.nach == raum) t.von,
    };
  }

  @override
  double? hervorhebung(String npcId) => null;

  @override
  bool get ruheAnimation => true;

  @override
  bool get kleineEffekte => false;

  @override
  LookDef? get detektivAussehen => _aussehen;

  @override
  Offset? get kamera => null;

  @override
  bool get exakteFiguren => false;
}

/// Seite der Ebenen-Vorschau (Entwickler-Einstieg, nicht im Menü):
/// `?ebene=<keller|erdgeschoss|turm|aussen>&uhr=00:30&fassung=kurz&at=x,y&zoom=0.8`.
/// Ohne `uhr` gilt der Morgen im langen Abend (alle Portale offen). Meldet
/// sich mit `WELT ebene=<id>` in der Konsole, sobald die Szene steht.
class EbenenVorschauSeite extends StatefulWidget {
  const EbenenVorschauSeite({super.key, this.fall = 'schlosskeller', this.ebene = kellerEbene, this.uhr, this.lang = true, this.at, this.zoom});

  /// Aus den URL-Parametern.
  factory EbenenVorschauSeite.ausUrl(Map<String, String> q) => EbenenVorschauSeite(
        fall: q['akte'] ?? 'schlosskeller',
        ebene: (q['ebene'] ?? '').isEmpty ? kellerEbene : q['ebene']!,
        uhr: Uhrzeit.istGueltig(q['uhr'] ?? '') ? q['uhr'] : null,
        lang: q['fassung'] != 'kurz',
        at: switch ((q['at'] ?? '').split(',').map(double.tryParse).toList()) {
          [final double x, final double y] => (x, y),
          _ => null,
        },
        zoom: double.tryParse(q['zoom'] ?? ''),
      );

  final String fall;
  final String ebene;
  final String? uhr;
  final bool lang;
  final (double, double)? at;
  final double? zoom;

  @override
  State<EbenenVorschauSeite> createState() => _EbenenVorschauSeiteState();
}

class _EbenenVorschauSeiteState extends State<EbenenVorschauSeite> {
  EbenenVorschau? _vorschau;

  @override
  void initState() {
    super.initState();
    if (widget.zoom case final z?) MordakteGame.debugInitialZoom = z;
    final uhr = widget.uhr;
    final lage = uhr == null ? null : WeltLage(lang: widget.lang, uhr: Uhrzeit.parse(uhr));
    EbenenVorschau.laden(rootBundle, fall: widget.fall, ebene: widget.ebene, lage: lage, at: widget.at).then((v) {
      if (!mounted) {
        v.dispose();
        return;
      }
      setState(() => _vorschau = v);
      debugPrint('WELT ebene=${v.ebene}');
    });
  }

  @override
  void dispose() {
    _vorschau?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _vorschau;
    return Scaffold(
      backgroundColor: const Color(0xFF080B14),
      body: v == null ? const SizedBox.expand() : GameView(session: v),
    );
  }
}
