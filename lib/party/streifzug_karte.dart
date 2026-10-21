import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../game/szenen_erweiterung.dart';
import 'abend_karte.dart';
import 'daten.dart';

/// Welt des Streifzugs (Langer Abend M7b): Ebenen, Renderer-Szenarien und die
/// Erkundung der Akte, einmal je Akte aus den Assets geladen.
class StreifzugWelt {
  const StreifzugWelt(this.welt, this.szenarien, this.erkundung);

  final WeltEbenen welt;
  final Map<String, ScenarioDef> szenarien;
  final Erkundung erkundung;

  /// Fertige Welt statt der Assets (Tests, Werkzeuge); `null`: aus den Assets.
  static StreifzugWelt? vorgabe;

  static final _geladen = Expando<Future<StreifzugWelt>>();

  /// Ebenen und Szenarien wie die Abend-Karte ([AbendKarte.ladeWelt]) und die
  /// Erkundung aus `welt.json` (`erkundung`). Einmal je Akte; ein Fehler wird
  /// nicht gemerkt.
  static Future<StreifzugWelt> laden(AssetBundle bundle, PartyDaten daten) {
    final v = vorgabe;
    if (v != null) return Future.value(v);
    return _geladen[daten] ??= () async {
      try {
        final (welt, szenarien) = await AbendKarte.ladeWelt(bundle, daten);
        final erkundung = await ladeErkundung(bundle, daten.fall) ?? (throw StateError('Die Akte ${daten.fall} hat keine Erkundung'));
        return StreifzugWelt(welt, szenarien, erkundung);
      } catch (_) {
        _geladen[daten] = null;
        rethrow;
      }
    }();
  }

  /// Die Erkundung der Akte [fall] (`content/welt/<fall>/welt.json`, Feld
  /// `erkundung`), `null` ohne sie.
  static Future<Erkundung?> ladeErkundung(AssetBundle bundle, String fall) async {
    final welt = jsonDecode(await bundle.loadString('content/welt/$fall/welt.json')) as Map<String, Object?>;
    final datei = welt['erkundung'];
    if (datei is! String) return null;
    return Erkundung.ausJson(jsonDecode(await bundle.loadString('content/welt/$fall/$datei')) as Map<String, Object?>);
  }
}

/// Eine Marke des Streifzugs auf der Karte: ein Treffpunkt einer Befragung
/// (`treff:<befragung>`, mit der Figur daneben) oder ein Erkundungsort
/// (`erkunde:<ort>`). [x], [y] ist die Stelle, an der der Detektiv ankommt.
class StreifzugMarke {
  const StreifzugMarke({required this.id, required this.ebene, required this.x, required this.y, this.ort, this.figur, this.figurX = 0, this.figurY = 0});

  final String id;
  final String ebene;
  final double x, y;

  /// Ort des Raumgraphen (geführter Weg über [AbendKarte.laufeZu]); sonst eine Stelle.
  final String? ort;

  /// Kanon-Kennung der Figur am Treffpunkt und wo sie steht.
  final String? figur;
  final double figurX, figurY;

  bool get treffen => id.startsWith(treffPraefix);

  static const treffPraefix = 'treff:', erkundePraefix = 'erkunde:';

  /// Kennung hinter dem Präfix (Befragung bzw. Erkundungsort).
  String get kennung => id.substring(id.indexOf(':') + 1);
}

/// Die Abend-Karte des Streifzugs (Langer Abend M7b): Treffpunkte und
/// Erkundungsorte als Marken. Wer zu einem Treffpunkt geht, findet dort die
/// Figur der Befragung; Erkundungsorte funkeln. Kommt der Detektiv an einer
/// Marke an, geführt ([geheZu]) oder getippt (im [AbendKarte.ankunftsRadius]),
/// meldet [onMarke] sie einmal je Ankunft; ein Treffpunkt geht einem
/// Erkundungsort vor. Antippen der Figur spricht sie an.
///
/// Wie die Abend-Karte ohne jede Wirkung auf den Abend: Marken und Figuren
/// sind Darstellung, nichts geht an Partie, Würfel oder Nachtminuten.
class StreifzugKarte extends AbendKarte {
  StreifzugKarte(
    super.daten,
    super.welt,
    super.szenarien, {
    required super.lage,
    super.quelle,
    super.ebene,
    super.start,
    super.klasse,
    super.detektivName,
    this.onMarke,
    this.ansprechen = '',
  }) {
    onInteraktion = _interaktion;
  }

  /// Ankunft an einer Marke.
  void Function(StreifzugMarke marke)? onMarke;

  /// Beschriftung der Handlung an einer Figur am Treffpunkt.
  final String ansprechen;

  List<StreifzugMarke> _marken = const [];
  String? _amMarke;

  /// Die Marken des Streifzugs (alle Ebenen).
  List<StreifzugMarke> get marken => _marken;

  set marken(List<StreifzugMarke> m) {
    _marken = List.unmodifiable(m);
    if (_amMarke != null && !_marken.any((x) => x.id == _amMarke)) _amMarke = null;
    zeigeWelt();
  }

  /// Stelle des Detektivs auf der gezeigten Ebene (Kachelkoordinaten).
  (double, double) get position => (detektivX, detektivY);

  /// Marke [id] oder `null`.
  StreifzugMarke? marke(String id) => _marken.where((m) => m.id == id).firstOrNull;

  /// Geht geführt zur Marke [m]; am Ziel meldet [onMarke] sie. `false` ohne
  /// offenen Weg oder wenn ein neuer Weg diesen ablöst.
  Future<bool> geheZu(StreifzugMarke m) async {
    final ok = m.ort != null ? await laufeZu(m.ebene, m.ort!) : await laufeZuPunkt(m.ebene, (m.x, m.y), ziel: m.id);
    if (ok && !entsorgt) _ankunft(m);
    return ok;
  }

  /// Steht der Detektiv bei [m] (Ebene und Ankunftsradius)?
  bool steht(StreifzugMarke m) => m.ebene == aktuelleEbene && dist(m.x, m.y, detektivX, detektivY) <= AbendKarte.ankunftsRadius + 1e-6;

  void _ankunft(StreifzugMarke m) {
    _amMarke = m.id;
    onMarke?.call(m);
  }

  /// Nach jedem eigenen Schritt (Tippen, Joystick): die nächste Marke im
  /// Ankunftsradius, ein Treffpunkt vor einem Erkundungsort.
  void _pruefeMarken() {
    if (laeuft || entsorgt) return;
    StreifzugMarke? best;
    var bestD = double.infinity;
    for (final m in _marken) {
      if (!steht(m)) continue;
      final d = dist(m.x, m.y, detektivX, detektivY);
      if (best == null || (m.treffen && !best.treffen) || (m.treffen == best.treffen && d < bestD)) {
        best = m;
        bestD = d;
      }
    }
    if (best == null) {
      _amMarke = null;
    } else if (_amMarke != best.id) {
      _ankunft(best);
    }
  }

  @override
  void move(double x, double y, double facing) {
    super.move(x, y, facing);
    _pruefeMarken();
  }

  /// Ein Platz für die Figur neben dem Treffpunkt ([x], [y]) auf [ebene]:
  /// eine Armlänge daneben auf freiem Boden, sonst die Stelle selbst.
  (double, double) nebenOrt(String ebene, double x, double y) {
    final r = rasterVon(ebene);
    for (final (dx, dy) in const [(0.9, 0.0), (-0.9, 0.0), (0.0, 0.9), (0.0, -0.9), (0.7, 0.7), (-0.7, 0.7), (0.7, -0.7), (-0.7, -0.7)]) {
      if (r.canStand(x + dx, y + dy, Tuning.playerRadius)) return (x + dx, y + dy);
    }
    return (x, y);
  }

  /// Marke mit der Figur [npcId] (Renderer-Kennung) auf der gezeigten Ebene.
  StreifzugMarke? _treffMit(String npcId) {
    final figur = daten.kanonKennung[npcId];
    if (figur == null) return null;
    return _marken.where((m) => m.treffen && m.figur == figur && m.ebene == aktuelleEbene).firstOrNull;
  }

  void _interaktion(String ziel) {
    final m = _treffMit(ziel);
    if (m == null || laeuft) return;
    if (dist(m.figurX, m.figurY, detektivX, detektivY) > Tuning.interactRange + 0.5) return;
    _ankunft(m);
  }

  @override
  List<NpcView> figurenAufEbene(String ebene) => [
        for (final m in _marken)
          if (m.treffen && m.ebene == ebene && m.figur != null)
            if (daten.npcKennung[m.figur] case final id?) NpcView(id: id, x: m.figurX, y: m.figurY, alive: true),
      ];

  @override
  String? npcAktion(String npcId) => eingabeGesperrt || _treffMit(npcId) == null ? null : ansprechen;

  @override
  List<SzenenGlanzPunkt> get glanzpunkte => [
        ...super.glanzpunkte,
        for (final m in _marken)
          if (m.ebene == aktuelleEbene) SzenenGlanzPunkt(m.id, m.x, m.y),
      ];
}
