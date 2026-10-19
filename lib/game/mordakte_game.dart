import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show FocusNode, KeyEventResult;
import 'package:mordakte_core/mordakte_core.dart';

import '../klang/klang.dart';
import '../session/game_session.dart';
import 'iso_math.dart';
import 'scene/figure_painter.dart';
import 'scene/klassen_ebene.dart';
import 'scene/lighting.dart';
import 'szenen_erweiterung.dart';
import 'scene/markers.dart';
import 'scene/nebel.dart';
import 'scene/palette.dart';
import 'scene/prop_painter.dart';
import 'scene/static_scene.dart';
import 'scene/wall_painter.dart' show kDoorTop;
import 'scene/weather.dart';

/// Ziel des Aktionsknopfs.
class ActionTarget {
  /// Hotspot-, Verdächtigen-, Item- oder Spieler-ID; leer bei `cancel`.
  final String id;
  final String label;

  /// `search`, `lab`, `hide`, `body`, `blood`, `npc`, `item`, `trace`, `revive`, `cancel`.
  final String kind;
  final double x, y, z;
  final String name;

  /// Ziel ist eine Figur (Namensschild über dem Kopf), auch wenn [kind] die
  /// Lupe zeigt, weil die Figur untersucht wird (Partymodus, E-038).
  final bool figur;

  const ActionTarget({
    required this.id,
    required this.label,
    required this.kind,
    required this.x,
    required this.y,
    this.z = 0,
    this.name = '',
    this.figur = false,
  });

  bool get isCancel => kind == 'cancel';

  bool sameAs(ActionTarget? o) => o != null && o.id == id && o.label == label && o.kind == kind;
}

class _Sample {
  final double t, x, y, f;
  const _Sample(this.t, this.x, this.y, this.f);
}

/// Interpolierte Position einer fremden Figur (~120 ms Puffer).
class _Track {
  final List<_Sample> samples = [];
  double x = 0, y = 0;
  double facing = math.pi / 4;
  double walk = 0;
  double move = 0;
  bool init = false;

  void add(double t, double x, double y, double f) {
    samples.add(_Sample(t, x, y, f));
    if (samples.length > 12) samples.removeAt(0);
  }

  /// Genau diese Stelle, ohne Puffer (exakte Figuren der Szene).
  void setze(double t, double x, double y, double f) {
    samples
      ..clear()
      ..add(_Sample(t, x, y, f));
  }

  /// [teleport]: Sprünge über drei Kacheln setzen die Figur ohne Laufanimation um.
  void step(double rt, double dt, {bool useReportedFacing = true, bool teleport = true}) {
    if (samples.isEmpty) return;
    double nx, ny, nf;
    if (rt <= samples.first.t) {
      nx = samples.first.x;
      ny = samples.first.y;
      nf = samples.first.f;
    } else if (rt >= samples.last.t) {
      nx = samples.last.x;
      ny = samples.last.y;
      nf = samples.last.f;
    } else {
      var i = 0;
      while (i < samples.length - 2 && samples[i + 1].t < rt) {
        i++;
      }
      final a = samples[i], b = samples[i + 1];
      final k = ((rt - a.t) / math.max(1e-6, b.t - a.t)).clamp(0.0, 1.0);
      nx = a.x + (b.x - a.x) * k;
      ny = a.y + (b.y - a.y) * k;
      nf = k < 0.5 ? a.f : b.f;
    }
    if (!init) {
      x = nx;
      y = ny;
      facing = useReportedFacing ? nf : facing;
      init = true;
      return;
    }
    final dx = nx - x, dy = ny - y;
    final d = math.sqrt(dx * dx + dy * dy);
    if (teleport && d > 3) {
      // Teleport
      x = nx;
      y = ny;
      return;
    }
    final speed = dt > 0 ? d / dt : 0.0;
    final moving = speed > 0.3;
    move += ((moving ? 1.0 : 0.0) - move) * math.min(1.0, dt * 10);
    walk += d * 7.5;
    if (moving) {
      facing = _lerpAngle(facing, math.atan2(dy, dx), math.min(1.0, dt * 12));
    } else if (useReportedFacing) {
      facing = _lerpAngle(facing, nf, math.min(1.0, dt * 8));
    }
    x = nx;
    y = ny;
  }
}

double _lerpAngle(double a, double b, double t) {
  var d = (b - a) % (math.pi * 2);
  if (d > math.pi) d -= math.pi * 2;
  if (d < -math.pi) d += math.pi * 2;
  return a + d * t;
}

/// Teilchen der kleinen Effekte (Seifenblasen, Staub, Ruß) in Szenen-Pixeln.
class _Teilchen {
  _Teilchen(this.x, this.y, this.vx, this.vy, this.max, this.r, this.farbe, {this.blase = false, this.wachsen = 0});
  double x, y, vx, vy, r, life = 0;
  final double max, wachsen;
  final Color farbe;
  final bool blase;
}

/// Türblatt mit Feder: Winkel und Winkelgeschwindigkeit.
class _Tuer {
  double winkel = 0.32, tempo = 0;
  bool offen = false, neu = true;
}

class _Nebel {
  _Nebel(this.sicht)
      : offen = sicht > 0.5,
        erinnert = sicht > 0.5;
  double sicht;
  bool offen;

  /// Der Raum war schon einmal im Sichtfeld: Sein Schleier ist dann leichter.
  bool erinnert;
  Offset? ursprung;
}

class _Smoke {
  double x, y, vx, vy, life, max, r;
  _Smoke(this.x, this.y, this.vx, this.vy, this.max, this.r) : life = 0;
}

class _LocalPing {
  final double x, y;
  final bool ok;
  double age = 0;
  _LocalPing(this.x, this.y, this.ok);
}

/// Die isometrische Spielszene. Liest `session.world.value` direkt pro Frame.
class MordakteGame extends Game with KeyboardEvents {
  MordakteGame({required this.session});

  GameSession session;

  /// Fokus der Szene (für Tastatur).
  FocusNode? focusNode;

  /// Joystick-Vektor in Bildschirmrichtung, Länge 0..1.
  Offset stick = Offset.zero;

  /// Benutzer-Zoom (Pinch/Mausrad).
  double userZoom = debugInitialZoom;

  /// Nur für Entwicklungs-Vorschau/Screenshots.
  static double debugInitialZoom = 1;

  /// Kamera passt Zoom und Ausschnitt an Detektiv und Ziele an (Partykarte,
  /// braucht eine Sitzung mit [SzenenKamera]); sonst der feste Zoom wie bisher.
  bool kameraPassend = false;

  /// Vom Bedienfeld verdeckter Teil des Bildes; der Ausschnitt liegt im Rest.
  SzenenRand sichtRand = SzenenRand.keiner;

  /// Hintergrund außerhalb der Karte statt reinem Schwarz (Palette der Akte).
  SzenenUmgebung? umgebung;

  /// Aktuelles Ziel für den Aktionsknopf.
  final ValueNotifier<ActionTarget?> target = ValueNotifier(null);

  /// Fortschritt der eigenen Kanal-Aktion (0..1), für den Aktionsknopf.
  final ValueNotifier<double> channelProgress = ValueNotifier(0);

  /// Farben des aktuellen Szenarios.
  ScenePalette get palette => _pal;

  // --- Szene ---
  StaticScene? _scene;
  String? _scenarioId;

  /// Gebackene Szenen anderer Ebenen ([SzenenEbenen], M7a): Der Weg die
  /// Treppe hinauf und zurück backt nicht neu. Höchstens [_szenenHalten]
  /// neben der gezeigten, die am längsten nicht gezeigte geht zuerst.
  final Map<String, StaticScene> _szenen = {};
  static const _szenenHalten = 2;

  /// Dauer der Überblendung nach einem Ebenenwechsel (Sekunden).
  static const ebenenBlende = 0.3;

  /// Restzeit der Überblendung (0 ohne Wechsel).
  double _blende = 0;

  /// Restzeit der Überblendung nach einem Ebenenwechsel (Tests).
  @visibleForTesting
  double get blende => _blende;

  /// Szenario-Kennungen, deren Szenen gerade gebacken bereitliegen (Tests).
  @visibleForTesting
  Set<String> get szenenImSpeicher => {..._szenen.keys, ?_scenarioId};

  /// Wie oft eine Szene neu gebacken wurde (Tests).
  @visibleForTesting
  int szenenGebacken = 0;
  bool _buildFailed = false;
  TileGrid? _grid;
  ScenePalette _pal = ScenePalette.fallback;
  final FigurePainter _fig = FigurePainter();
  final TextCache _text = TextCache();
  MarkerPainter? _markers;
  LightingRenderer? _lighting;
  WeatherSystem? _weather;

  double _time = 0;
  double _lastDt = 1 / 60;

  // --- Kamera ---
  Offset _cam = Offset.zero;
  bool _camInit = false;
  double _zoom = 1;

  /// Grundzoom der passenden Kamera (ohne Pinch), sanft nachgeführt.
  double _zoomBasis = 1;
  static const double _camY = 0.5;

  // --- eigener Spieler ---
  double _px = 0, _py = 0, _pf = math.pi / 4;
  bool _hasPos = false;
  double _walk = 0, _moveAmt = 0;

  /// Trägheit der eigenen Figur: Anteil der Sollgeschwindigkeit (0..1) und
  /// zuletzt gewünschte Richtung auf dem Bildschirm (Anlaufen und Abbremsen).
  double _tempo = 0;
  Offset _richtung = Offset.zero;

  /// Szenenregie: 0 = freie Kamera, 1 = Zweier-Einstellung auf Detektiv und Handlungsziel.
  double _regie = 0;

  /// Etablierungsschwenk beim ersten Betreten einer Akte (0..1, −1 = aus).
  double _intro = -1;
  bool _introOffen = false;

  /// Der Schwenk läuft nach Wanduhr: Auf langsamen Geräten (gekappte
  /// Bildzeit) dauert er sonst ewig.
  final Stopwatch _introUhr = Stopwatch();

  /// Kinobalken während des Schwenks (1 = voll, blendet zum Ende aus).
  double _introBalken = 0;
  static final Set<String> _introGespielt = {};

  // Tippen-zum-Gehen: Wegpunkte (Welt), Ziel einer Handlung und die Zielmarke.
  List<Offset>? _tippWeg;
  String? _tippAktion;
  Offset? _tippMarke;
  double _tippMarkeT = 0;

  /// Ziel des Tippwegs und ob er in Reichweite davor endet (zum Neuplanen).
  Offset? _tippZielPunkt;
  bool _tippNah = false;

  /// Hängenbleiben auf dem Tippweg: Stelle und Zeit seit dem letzten
  /// Fortschritt; ein zweites Hängen nach dem Neuplanen bricht ab.
  Offset _haengAb = Offset.zero;
  double _haengT = 0;
  bool _neuGeplant = false;
  double _lastSendT = -1;
  double _sentX = double.nan, _sentY = double.nan, _sentF = double.nan;
  double _farTimer = 0;

  // --- Netzwerkdaten ---
  WorldSnapshot? _lastWorld;
  double _worldRecvT = 0;
  final Map<String, _Track> _tracks = {};
  Set<Pt> _openDoors = {};
  int _caseVersion = -1;

  // --- Effekte ---
  final List<_Smoke> _smoke = [];
  final List<_LocalPing> _localPings = [];
  final math.Random _rnd = math.Random(3);
  double _nextFlash = 6;
  double _flashT = -1;
  double _flash = 0;
  double _actionPulse = 0;

  @override
  Color backgroundColor() => _pal.background;

  // ---------------------------------------------------------------------------
  // Öffentliche API für GameView

  void triggerAction() {
    if (_fuehrung?.eingabeGesperrt == true) return;
    final t = target.value;
    if (t == null) return;
    if (t.isCancel) {
      session.send(const CancelAction());
    } else {
      // Aktuelle Position zuerst senden, sonst startet der Server den Kanal an
      // einer veralteten Stelle und bricht ihn beim nächsten Move sofort ab.
      _flushPose();
      session.send(Interact(t.id));
    }
    _actionPulse = 1;
  }

  /// Tippen auf die Szene: auf eine Person oder einen Ort → hingehen und die
  /// Handlung vorschlagen; auf den Boden → dorthin gehen. `false`, wenn nichts
  /// erreichbar ist (oder die Eingabe gesperrt ist).
  bool tippen(Offset local) {
    final grid = _grid;
    if (_scene == null || grid == null || !_hasPos || _fuehrung?.eingabeGesperrt == true) return false;
    _freistellen(grid);
    final ziel = _tippZiel(local);
    final w = ziel?.$2 ?? screenToWorld(local);
    final weg = _wegZu(grid, w, nah: ziel != null);
    if (weg == null) return false;
    _tippWeg = weg;
    _tippAktion = ziel?.$1;
    _tippMarke = ziel?.$2 ?? w;
    _tippMarkeT = 0;
    _tippZielPunkt = w;
    _tippNah = ziel != null;
    _haengAb = Offset(_px, _py);
    _haengT = 0;
    _neuGeplant = false;
    // Steht man schon da, gilt die Handlung sofort.
    if (weg.isEmpty && ziel != null) _tippAnkunft();
    return true;
  }

  /// Person oder Ort unter dem Finger (Bildschirmabstand), mit Weltposition.
  (String, Offset)? _tippZiel(Offset local) {
    final cv = session.caseView.value;
    final s = session.scenario;
    if (cv == null || s == null) return null;
    final bild = worldToScreen;
    (String, Offset)? best;
    var bestD = double.infinity;
    final ext = _ext;
    for (final n in _world?.npcs ?? const <NpcView>[]) {
      if (!n.alive || (ext != null && ext.npcAktion(n.id) == null)) continue;
      final tr = _tracks['n:${n.id}'];
      final nx = tr?.x ?? n.x, ny = tr?.y ?? n.y;
      if (_nebelSicht(nx, ny) < 0.5) continue;
      final fuss = bild(nx, ny);
      final kopf = fuss.translate(0, -58 * _zoom);
      // Abstand zur Strecke Fuß–Kopf.
      final t = ((local.dy - kopf.dy) / (fuss.dy - kopf.dy)).clamp(0.0, 1.0);
      final p = Offset.lerp(kopf, fuss, t)!;
      final d = (local - p).distance;
      if (d < 26 * _zoom + 10 && d < bestD) {
        bestD = d;
        best = (n.id, Offset(nx, ny));
      }
    }
    for (final e in cv.hotspots.entries) {
      final h = s.hotspotById[e.key];
      if (h == null || e.value == HotspotState.searched) continue;
      if (_nebelSicht(h.x + 0.5, h.y + 0.5) < 0.5) continue;
      final d = (local - bild(h.x + 0.5, h.y + 0.5, 0.5)).distance;
      if (d < 30 * _zoom + 10 && d + 6 < bestD) {
        bestD = d + 6;
        best = (h.id, Offset(h.x + 0.5, h.y + 0.5));
      }
    }
    return best;
  }

  /// Weg (Wegpunkte in Weltkoordinaten) zum Punkt [w]; mit [nah] endet er in
  /// Reichweite des Ziels statt darauf. Gerade Strecken werden zusammengefasst,
  /// aber nur, wo der ganze Körper frei durchkommt ([TileGrid.freieBahn]).
  List<Offset>? _wegZu(TileGrid grid, Offset w, {required bool nah}) {
    if (nah && dist(_px, _py, w.dx, w.dy) <= Tuning.interactRange * 0.9) return const [];
    final start = Pt(_px.floor(), _py.floor());
    // Andere Figuren: nicht auf ihnen stehen bleiben und möglichst um sie herum.
    final leute = [
      for (final e in _tracks.entries)
        if (e.key != 'shadow') Offset(e.value.x, e.value.y),
    ];
    // Auf freien Boden getippt: genau dorthin. Sonst auf die beste erreichbare
    // Kachel daneben (die nächste liegt manchmal hinter einer verschlossenen Tür).
    final genau = !nah && grid.canStand(w.dx, w.dy, Tuning.playerRadius);
    final kandidaten = <(Pt, double)>[];
    if (genau) {
      kandidaten.add((Pt(w.dx.floor(), w.dy.floor()), 0));
    } else {
      for (var dy = -2; dy <= 2; dy++) {
        for (var dx = -2; dx <= 2; dx++) {
          final p = Pt(w.dx.floor() + dx, w.dy.floor() + dy);
          final mx = p.x + 0.5, my = p.y + 0.5;
          if (!grid.canStand(mx, my, Tuning.playerRadius)) continue;
          final d = dist(mx, my, w.dx, w.dy);
          if (nah && d > Tuning.interactRange * 0.85) continue;
          // Ungern auf einer Person stehen bleiben.
          final belegt = leute.any((l) => dist(mx, my, l.dx, l.dy) < 0.6);
          kandidaten.add((p, d + dist(mx, my, _px, _py) * 0.05 + (belegt ? 4 : 0)));
        }
      }
      kandidaten.sort((a, b) => a.$2.compareTo(b.$2));
    }
    final personen = {for (final l in leute) Pt(l.dx.floor(), l.dy.floor())};
    Pt? ziel;
    List<Pt>? kacheln;
    for (final (p, _) in kandidaten) {
      kacheln = grid.findPath(start, p, extraBlockiert: personen);
      if (kacheln != null) {
        ziel = p;
        break;
      }
    }
    if (ziel == null || kacheln == null) return null;
    final punkte = [
      // Erst die eigene Kachelmitte: Von dort ist jeder A*-Schritt frei.
      Offset(start.x + 0.5, start.y + 0.5),
      for (final k in kacheln) Offset(k.x + 0.5, k.y + 0.5),
      if (genau && dist(w.dx, w.dy, ziel.x + 0.5, ziel.y + 0.5) > 1e-6) w,
    ];
    // Abkürzen, wo der Körper frei durchkommt und an niemandem vorbeistreift
    // (keine Treppenstufen im Gang). Nachbarpunkte sind immer frei.
    bool frei(Offset a, Offset b) =>
        grid.freieBahn(a.dx, a.dy, b.dx, b.dy, Tuning.playerRadius) &&
        leute.every((l) => distToSegment(l.dx, l.dy, a.dx, a.dy, b.dx, b.dy) >= 0.5);
    final glatt = <Offset>[];
    var von = Offset(_px, _py);
    var i = 0;
    while (i < punkte.length) {
      var j = punkte.length - 1;
      while (j > i && !frei(von, punkte[j])) {
        j--;
      }
      glatt.add(punkte[j]);
      von = punkte[j];
      i = j + 1;
    }
    // Schon an der Stelle: kein Schritt auf der Stelle.
    if (glatt.length == 1 && dist(_px, _py, glatt.first.dx, glatt.first.dy) < 1e-3) glatt.clear();
    return glatt;
  }

  /// Eingabe aus dem Tippweg (Bildschirmrichtung) oder null.
  Offset _tippEingabe() {
    final weg = _tippWeg;
    if (weg == null) return Offset.zero;
    while (weg.isNotEmpty && dist(_px, _py, weg.first.dx, weg.first.dy) < 1e-3) {
      // Rundungsrest: genau auf den Wegpunkt, er liegt auf der freien Bahn.
      _px = weg.first.dx;
      _py = weg.first.dy;
      weg.removeAt(0);
    }
    if (weg.isEmpty) {
      _tippAnkunft();
      return Offset.zero;
    }
    final z = weg.first;
    final d = Iso.worldDirToScreen(z.dx - _px, z.dy - _py);
    final l = d.distance;
    if (l < 1e-6) return Offset.zero;
    // Auf den letzten Metern langsamer (Ankommen statt Aufprallen).
    final rest = weg.length == 1 ? dist(_px, _py, z.dx, z.dy) : 9.0;
    return d / l * (0.45 + 0.55 * (rest / 0.8).clamp(0.0, 1.0));
  }

  /// Ein Schritt der Länge [schritt] auf dem Tippweg, genau auf der geglätteten
  /// Linie: Wegpunkte werden erreicht, nicht geschnitten. Die Strecken sind
  /// beim Planen geprüft; steht die Figur trotzdem nicht frei (eine Tür ist
  /// inzwischen zu), bleibt sie stehen und plant gleich neu.
  (double, double) _folgeWeg(TileGrid grid, List<Offset> weg, double schritt) {
    var x = _px, y = _py, rest = schritt;
    while (rest > 1e-9 && weg.isNotEmpty) {
      final z = weg.first;
      final d = dist(x, y, z.dx, z.dy);
      final s = math.min(d, rest);
      final nx = s >= d ? z.dx : x + (z.dx - x) * s / d, ny = s >= d ? z.dy : y + (z.dy - y) * s / d;
      if (!grid.canStand(nx, ny, Tuning.playerRadius)) break;
      x = nx;
      y = ny;
      rest -= s;
      if (s >= d) weg.removeAt(0);
    }
    if (weg.isEmpty) _tempo = 0;
    return (x, y);
  }

  /// Ein Schritt der frei gesteuerten Figur um ([dx], [dy]) mit Kollision.
  /// An einer Kante gleitet sie nur, wenn die gesperrte Komponente klein ist
  /// (unter 30 %); sonst geht sie bis an die Kante heran und bleibt stehen.
  (double, double) _gehe(TileGrid grid, double dx, double dy) {
    const r = Tuning.playerRadius;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-9) return (_px, _py);
    if (grid.freieBahn(_px, _py, _px + dx, _py + dy, r)) return (_px + dx, _py + dy);
    if (dy.abs() / len < 0.3 && grid.freieBahn(_px, _py, _px + dx, _py, r)) return (_px + dx, _py);
    if (dx.abs() / len < 0.3 && grid.freieBahn(_px, _py, _px, _py + dy, r)) return (_px, _py + dy);
    for (var k = 0.5; k > 0.05; k /= 2) {
      if (grid.freieBahn(_px, _py, _px + dx * k, _py + dy * k, r)) return (_px + dx * k, _py + dy * k);
    }
    return (_px, _py);
  }

  /// Steht die eigene Figur nicht frei (Entwicklerposition, Korrektur in eine
  /// Wand), rückt sie auf die Mitte der nächsten begehbaren Kachel. Sie läuft
  /// nie ohne Kollision weiter.
  void _freistellen(TileGrid grid) {
    if (grid.canStand(_px, _py, Tuning.playerRadius)) return;
    final p = grid.nearestWalkable(_px.floor(), _py.floor());
    if (p == null) return;
    _px = p.x + 0.5;
    _py = p.y + 0.5;
  }

  /// Hängt die Figur auf dem Tippweg fest (weniger als 0,01 Kacheln in 0,3 s),
  /// plant sie einmal vom aktuellen Feld neu; beim zweiten Mal bricht sie ab.
  void _pruefeHaengen(TileGrid grid, double dt, {required bool aktiv}) {
    if (!aktiv || _tippWeg == null || dist(_px, _py, _haengAb.dx, _haengAb.dy) >= 0.01) {
      _haengAb = Offset(_px, _py);
      _haengT = 0;
      return;
    }
    _haengT += dt;
    if (_haengT < 0.3) return;
    _haengT = 0;
    final ziel = _tippZielPunkt;
    final neu = _neuGeplant || ziel == null ? null : _wegZu(grid, ziel, nah: _tippNah);
    if (neu == null) {
      _tippWeg = null;
      _tippAktion = null;
      _tempo = 0;
    } else {
      _tippWeg = neu;
      _neuGeplant = true;
    }
  }

  /// Joystick und Tasten rasten auf die acht Weltrichtungen (Achsen und
  /// Diagonalen der Karte): So läuft die Figur genau einen Gang entlang,
  /// statt schräg an der Wand zu schaben.
  static Offset _rasten(Offset d) {
    if (d.distance < 1e-9) return Offset.zero;
    return _weltRichtungen[(math.atan2(d.dy, d.dx) / (math.pi / 4)).round() % 8];
  }

  static const double _diag = 0.7071067811865476;
  static const _weltRichtungen = [
    Offset(1, 0), Offset(_diag, _diag), Offset(0, 1), Offset(-_diag, _diag),
    Offset(-1, 0), Offset(-_diag, -_diag), Offset(0, -1), Offset(_diag, -_diag),
  ];

  void _tippAnkunft() {
    final aktion = _tippAktion;
    _tippWeg = null;
    _tippAktion = null;
    // Angekommen: stehen, nicht über das Ziel hinausrutschen.
    _tempo = 0;
    if (aktion == null) return;
    // Bei gleich weiten Zielen gilt das angetippte (Wendeltreppe neben der Hoftür, M7a).
    _bevorzugtesZiel = aktion;
    _updateTarget();
    _bevorzugtesZiel = null;
    if (target.value?.id == aktion) triggerAction();
  }

  /// Ziel, das bei Gleichstand gewinnt (gerade angetippt).
  String? _bevorzugtesZiel;

  /// Bildschirmpunkt (lokal im Widget) → Welt-Kachelkoordinaten.
  Offset screenToWorld(Offset local) {
    final ws = (local - Offset(size.x / 2, size.y * _camY)) / _zoom + _cam;
    return Iso.toWorld(ws.dx, ws.dy);
  }

  /// Welt-Kachelkoordinaten (Höhe [z]) → Bildschirmpunkt lokal im Widget.
  Offset worldToScreen(double x, double y, [double z = 0]) =>
      (Iso.toScreen(x, y, z) - _cam) * _zoom + Offset(size.x / 2, size.y * _camY);

  /// Eigene Position in Kachelkoordinaten (Tests).
  @visibleForTesting
  Offset get eigenePosition => Offset(_px, _py);

  /// Restliche Wegpunkte des Tippwegs; `null` ohne Tippweg (Tests).
  @visibleForTesting
  List<Offset>? get tippWeg => _tippWeg == null ? null : List.unmodifiable(_tippWeg!);

  /// Musste der laufende oder letzte Tippweg nach einem Hängen neu geplant werden? (Tests)
  @visibleForTesting
  bool get tippNeuGeplant => _neuGeplant;

  /// Gezeichnete Stelle einer fremden Figur, `null` ohne Spur (Tests).
  @visibleForTesting
  Offset? figurPosition(String npcId) {
    final t = _tracks['n:$npcId'];
    return t == null ? null : Offset(t.x, t.y);
  }

  /// Langes Drücken → Ping. Gibt `false` zurück, wenn keine Pings übrig sind.
  bool ping(Offset local) {
    if (_scene == null || _fuehrung?.eingabeGesperrt == true) return false;
    final w = screenToWorld(local);
    final cv = session.caseView.value;
    final ok = cv == null || cv.pingsLeft > 0;
    _localPings.add(_LocalPing(w.dx, w.dy, ok));
    if (ok) {
      session.send(Signal(kind: 'ping', value: 'look', x: (w.dx * 100).round() / 100, y: (w.dy * 100).round() / 100));
    }
    return ok;
  }

  void dispose() {
    _scene?.dispose();
    _scene = null;
    for (final sz in _szenen.values) {
      sz.dispose();
    }
    _szenen.clear();
    _text.dispose();
    target.dispose();
    channelProgress.dispose();
  }

  // ---------------------------------------------------------------------------
  // Tastatur

  static final _moveKeys = {
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
  };

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.keyE || k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.enter) {
      if (event is KeyDownEvent) triggerAction();
      return KeyEventResult.handled;
    }
    if (_moveKeys.contains(k)) return KeyEventResult.handled;
    return KeyEventResult.ignored;
  }

  Offset _keyboardDir() {
    final node = focusNode;
    if (node != null && !node.hasFocus) return Offset.zero;
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    if (keys.isEmpty) return Offset.zero;
    var dx = 0.0, dy = 0.0;
    if (keys.contains(LogicalKeyboardKey.keyW) || keys.contains(LogicalKeyboardKey.arrowUp)) dy -= 1;
    if (keys.contains(LogicalKeyboardKey.keyS) || keys.contains(LogicalKeyboardKey.arrowDown)) dy += 1;
    if (keys.contains(LogicalKeyboardKey.keyA) || keys.contains(LogicalKeyboardKey.arrowLeft)) dx -= 1;
    if (keys.contains(LogicalKeyboardKey.keyD) || keys.contains(LogicalKeyboardKey.arrowRight)) dx += 1;
    final l = math.sqrt(dx * dx + dy * dy);
    return l < 1e-6 ? Offset.zero : Offset(dx / l, dy / l);
  }

  // ---------------------------------------------------------------------------
  // Update

  @override
  void update(double dt) {
    if (_tippMarke != null) _tippMarkeT += dt;
    // Nur gegen Hänger begrenzen (wie die Engine mit 250 ms). Die eigene Figur
    // läuft in Teilschritten ≤ 50 ms, damit sie auch bei < 20 fps volle
    // Geschwindigkeit hat und die Wandkollision pro Schritt greift.
    final frameDt = dt.clamp(0.0, 0.25);
    dt = math.min(frameDt, 0.05);
    _lastDt = dt;
    _time += frameDt;
    _syncScenario();
    if (_scene == null) return;
    if (_blende > 0) _blende = math.max(0, _blende - frameDt);
    _fuehrung?.szenenSchritt(frameDt);
    _ingestWorld();
    _syncCase();
    var rem = frameDt;
    do {
      final s = math.min(rem, 0.05);
      _updatePlayer(s);
      rem -= s;
    } while (rem > 1e-9);
    _updateTracks(dt);
    _updateCamera(dt);
    _updateNebel(frameDt);
    _updateTarget();
    _updateEffects(dt);
    _updateTueren(dt);
    _updateHinlenken(frameDt);
    _schrittKlang();
    if (_donnerIn >= 0) {
      _donnerIn -= frameDt;
      if (_donnerIn < 0) Klang.instanz.spiele('donner', laut: 0.75, streuung: 0.1);
    }
  }

  // Schwingende Türen (M4): Unverschlossene Türen stehen einen Spalt offen,
  // schwingen auf, wenn jemand nahe kommt, und federn danach zurück.
  final Map<Pt, _Tuer> _tueren = {};

  void _updateTueren(double dt) {
    final scene = _scene;
    if (scene == null) return;
    final ruhig = _fuehrung?.bewegungReduziert == true;
    final leute = <Offset>[
      if (_hasPos) Offset(_px, _py),
      for (final t in _tracks.values) Offset(t.x, t.y),
    ];
    for (final d in scene.doors) {
      final info = d.door!;
      if (info.locked) continue;
      final t = _tueren.putIfAbsent(Pt(d.x, d.y), _Tuer.new);
      final cx = d.x + 0.5, cy = d.y + 0.5;
      final nah = leute.any((p) => (p.dx - cx).abs() < 1.2 && (p.dy - cy).abs() < 1.2);
      final ziel = nah ? 1.5 : 0.32;
      if (nah && !t.offen && !t.neu && _hasPos && dist(_px, _py, cx, cy) < 7) {
        Klang.instanz.spiele('tuer', laut: 0.45 * (1 - dist(_px, _py, cx, cy) / 8), streuung: 0.12);
      }
      t.offen = nah;
      t.neu = false;
      if (ruhig) {
        t.winkel = ziel;
        t.tempo = 0;
        continue;
      }
      t.tempo += (40 * (ziel - t.winkel) - 6.5 * t.tempo) * dt;
      t.winkel += t.tempo * dt;
    }
  }

  void _syncScenario() {
    final s = session.scenario;
    if (s == null) return;
    if (s.id == _scenarioId && (_scene != null || _buildFailed)) return;
    final ebenen = session is SzenenEbenen ? (session as SzenenEbenen).ebenenSzenarien : const <String>{};
    final alt = _scene, altId = _scenarioId;
    // Ebenenwechsel: die alte Szene bleibt gebacken, die neue kommt aus dem Speicher.
    final wechsel = alt != null && altId != null && ebenen.contains(altId) && ebenen.contains(s.id);
    if (wechsel) {
      _szenen[altId] = alt;
      while (_szenen.length > _szenenHalten) {
        _szenen.remove(_szenen.keys.firstWhere((k) => k != s.id))!.dispose();
      }
    } else {
      alt?.dispose();
    }
    _scene = null;
    _buildFailed = false;
    try {
      final gespeichert = _szenen.remove(s.id);
      if (gespeichert == null) szenenGebacken++;
      // Türen wie frisch gebacken: Den Stand der Ebene setzt gleich _syncCase.
      _scene = (gespeichert?..setOpenDoors(const {})) ?? StaticScene.build(s);
    } catch (e, st) {
      debugPrint('Mordakte: Szene konnte nicht gebaut werden: $e\n$st');
      _scene = null;
      _scenarioId = s.id;
      _buildFailed = true;
      return;
    }
    _scenarioId = s.id;
    _pal = _scene!.pal;
    _grid = TileGrid(s.map);
    _openDoors = {};
    _caseVersion = -1;
    _markers = MarkerPainter(_pal, _text);
    _klassenEbene = KlassenEbene(_pal, _text);
    _lighting = LightingRenderer(_pal);
    _weather = WeatherSystem(ThemeDef.weathers.contains(s.theme.weather) ? s.theme.weather : 'none', _pal);
    _tracks.clear();
    _hasPos = false;
    _camInit = false;
    _introOffen = true;
    _intro = -1;
    _playerRoom = null;
    _nebel.clear();
    _blende = 0;
    if (wechsel) {
      // Kein Kameraflug über die neue Ebene: Sie blendet am Ankunftspunkt auf.
      _introGespielt.add(s.id);
      _blende = ebenenBlende;
    }
    if (_angemeldet) Klang.instanz.atmosphaereSpielen(_atmosphaere);
  }

  // --- Hinlenken bei Untätigkeit (M5) ---
  double _untaetig = 0;
  Offset? _leuchtZiel;

  /// Nach zehn Sekunden ohne Eingabe zeigt eine Lichtsäule das nächste Ziel,
  /// die Kamera schaut kurz hin und kehrt zurück. Jede Eingabe setzt zurück.
  void _updateHinlenken(double dt) {
    final sitzung = session;
    final gefuehrt = _fuehrung?.eingabeGesperrt == true;
    final eingabe = stick.distance > 0.05 || _keyboardDir().distance > 0.05 || _tippWeg != null;
    if (eingabe || gefuehrt || !_hasPos || _moveAmt > 0.05 || sitzung is! SzenenKamera || _intro >= 0) {
      _untaetig = 0;
      _leuchtZiel = null;
      return;
    }
    _untaetig += dt;
    if (_untaetig < 10) return;
    if (_leuchtZiel == null) {
      final ziele = (sitzung as SzenenKamera).kameraZiele;
      if (ziele.isEmpty) return;
      _leuchtZiel = ziele.reduce((a, b) => dist(a.dx, a.dy, _px, _py) <= dist(b.dx, b.dy, _px, _py) ? a : b);
    }
  }

  /// Lichtsäule über dem Ziel: weicher Strahl und ein Ring am Boden.
  void _zeichneLeuchtzeichen(Canvas c) {
    final z = _leuchtZiel;
    if (z == null) return;
    final t = _untaetig - 10;
    final ein = (t / 0.6).clamp(0.0, 1.0);
    final puls = 0.6 + 0.4 * math.sin(_time * 3);
    final fuss = Iso.toScreen(z.dx, z.dy);
    final hoehe = 150.0;
    final strahl = Rect.fromLTRB(fuss.dx - 9, fuss.dy - hoehe, fuss.dx + 9, fuss.dy);
    c.drawRect(
      strahl,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = Gradient.linear(
          strahl.bottomCenter,
          strahl.topCenter,
          [withAlpha(_pal.light, 0.42 * ein * puls), withAlpha(_pal.light, 0)],
        ),
    );
    c.save();
    c.translate(fuss.dx, fuss.dy);
    Iso.applyGround(c);
    final r = 0.35 + ((_time * 0.8) % 1) * 0.7;
    c.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05
        ..color = withAlpha(_pal.light, 0.6 * ein * (1 - (r - 0.35) / 0.7)),
    );
    c.restore();
  }

  // --- Ton (M7) ---
  bool _angemeldet = false;
  double _donnerIn = -1;
  int _letzterSchrittKlang = 0;

  /// Atmosphäre der Akte nach Kulisse, sonst nach Wetter.
  String? get _atmosphaere {
    final t = _scene?.scenario.theme;
    if (t == null) return null;
    return switch (t.backdrop) {
      'keller' => 'atmo_keller',
      'burg' || 'schloss' => 'atmo_wind',
      'garten' => 'atmo_regen',
      'gleis' => 'atmo_zug',
      'motel' => 'atmo_neon',
      _ => switch (t.weather) {
          'rain' => 'atmo_regen',
          'snow' => 'atmo_wind',
          'neon' => 'atmo_neon',
          _ => null,
        },
    };
  }

  @override
  void onAttach() {
    super.onAttach();
    _angemeldet = true;
    Klang.instanz.atmosphaereSpielen(_atmosphaere);
  }

  @override
  void onDetach() {
    _angemeldet = false;
    Klang.instanz.atmosphaereSpielen(null);
    super.onDetach();
  }

  /// Schrittklang der eigenen Figur je Boden (leiser auf Teppich).
  void _schrittKlang() {
    final schritt = (_walk / math.pi).floor();
    if (schritt == _letzterSchrittKlang) return;
    _letzterSchrittKlang = schritt;
    if (_moveAmt < 0.4 || !_hasPos) return;
    final raum = _grid?.roomAtPos(_px, _py);
    final aussen = raum?.outdoor ?? false;
    final boden = raum?.floor ?? 'stone';
    final wetter = _scene?.scenario.theme.weather;
    final (name, laut) = switch (boden) {
      'snow' => ('schritt_schnee', 0.35),
      _ when aussen && wetter == 'snow' => ('schritt_schnee', 0.35),
      'grass' => ('schritt_schnee', 0.22),
      'gravel' || 'asphalt' => ('schritt_kies', 0.3),
      'parquet' || 'planks' => ('schritt_holz', 0.32),
      'carpet' => ('schritt_holz', 0.14),
      _ => ('schritt_stein', 0.3),
    };
    Klang.instanz.spiele(name, varianten: 2, laut: laut, streuung: 0.07);
  }

  WorldSnapshot? get _world => session.world.value;

  DetectiveView? get _me => _world?.detective(session.playerId);

  void _ingestWorld() {
    final w = _world;
    if (w == null || identical(w, _lastWorld)) return;
    _lastWorld = w;
    _worldRecvT = _time;
    if (w.ackSeq != _ackSeen) {
      _ackSeen = w.ackSeq;
      _unackedSince = null;
    }
    final present = <String>{};
    for (final d in w.detectives) {
      if (d.id == session.playerId) continue;
      final key = 'd:${d.id}';
      present.add(key);
      (_tracks[key] ??= _Track()).add(_time, d.x, d.y, d.facing);
    }
    final exakt = _ext?.exakteFiguren == true;
    for (final n in w.npcs) {
      final key = 'n:${n.id}';
      present.add(key);
      final tr = _tracks[key] ??= _Track();
      if (exakt) {
        tr.setze(_time, n.x, n.y, 0);
      } else {
        tr.add(_time, n.x, n.y, 0);
      }
    }
    final sh = w.shadow;
    if (sh != null) {
      present.add('shadow');
      (_tracks['shadow'] ??= _Track()).add(_time, sh.x, sh.y, 0);
    }
    // Nur entfernen, was im Snapshot fehlt – bei Funkstille bleibt die letzte Pose stehen.
    _tracks.removeWhere((k, _) => !present.contains(k));
    // Eigene Position: Start, Korrektur, Teleport.
    final me = w.detective(session.playerId);
    if (me != null) {
      if (!_hasPos) {
        _px = me.x;
        _py = me.y;
        _pf = me.facing;
        _hasPos = true;
        _sentX = _px;
        _sentY = _py;
        _sentF = _pf;
      }
    }
    if (w.correctX != null && w.correctY != null) {
      _px = w.correctX!;
      _py = w.correctY!;
      _sentX = _px;
      _sentY = _py;
      _hasPos = true;
    }
  }

  void _syncCase() {
    final cv = session.caseView.value;
    if (cv == null || cv.version == _caseVersion) return;
    _caseVersion = cv.version;
    final open = <Pt>{
      for (final d in cv.openDoors)
        if (d.length >= 2) Pt(d[0], d[1]),
    };
    if (open.length != _openDoors.length || !open.containsAll(_openDoors)) {
      _openDoors = open;
      _grid?.setOpenDoors(open);
      _scene?.setOpenDoors(open);
    }
  }

  Phase? get _phase => _world?.phase ?? session.caseView.value?.phase;

  /// Interaktionen sind nur in Ermittlung und Nacht erlaubt (wie in der Engine).
  bool get _actionPhase {
    final p = _phase;
    return p == Phase.investigation || p == Phase.night;
  }

  bool get _canMovePhase {
    final p = _phase;
    return p == Phase.investigation || p == Phase.council || p == Phase.night || p == Phase.accusation;
  }

  double _effectMul(DetectiveView? d, double Function(Modifiers) f) {
    if (d == null) return 1;
    var m = 1.0;
    for (final e in d.effects) {
      final def = effectCatalog[e];
      if (def != null) m *= f(def.mods);
    }
    return m;
  }

  void _updatePlayer(double dt) {
    final me = _me;
    final grid = _grid;
    if (!_hasPos || grid == null) {
      _moveAmt = 0;
      return;
    }
    // Geführte Partyaktionen besitzen ihre Pose. Joystick, Vorhersage und
    // _sendPose dürfen den A*-Lauf weder überschreiben noch zurückmelden.
    if (_fuehrung?.eingabeGesperrt == true && me != null) {
      _tippWeg = null;
      _tippAktion = null;
      _walk += dist(_px, _py, me.x, me.y) * 7.5;
      _px = _sentX = me.x;
      _py = _sentY = me.y;
      _pf = _sentF = me.facing;
      _moveAmt = me.moving && _fuehrung?.bewegungReduziert != true ? 1 : 0;
      _following = false;
      _farTimer = _idleT = _followT = 0;
      _unackedSince = null;
      final raum = grid.roomAtPos(_px, _py);
      if (raum != null && !_isDoorTile(_px, _py)) _playerRoom = raum.id;
      return;
    }
    // Die Serverposition gilt nur, wenn der Snapshot frisch ist und der Server
    // unsere letzten Moves bestätigt hat – sonst zieht ein Funkloch uns zurück.
    final w = _world;
    final unacked = _unackedSince;
    final meTrusted =
        w != null && _time - _worldRecvT < 0.5 && (w.ackSeq == 0 || unacked == null || _time - unacked < 0.8);
    if (!meTrusted) {
      _farTimer = 0;
      _followT = 0;
    }
    // Sicherheitsnetz: Server sieht uns ganz woanders (Teleport ohne Korrektur).
    if (me != null && meTrusted) {
      final far = dist(me.x, me.y, _px, _py) > 4;
      _farTimer = far ? _farTimer + dt : 0;
      if (_farTimer > 1.2) {
        _px = me.x;
        _py = me.y;
        _farTimer = 0;
      }
    }
    var input = stick;
    if (input.distance < 0.05) input = _keyboardDir();
    if (input.distance >= 0.05) {
      // Eigene Steuerung bricht einen Tippweg ab.
      _tippWeg = null;
      _tippAktion = null;
    } else {
      input = _tippEingabe();
    }
    final mag = math.min(1.0, input.distance);
    final canMove = me != null && _canMovePhase && me.life != LifeState.downed && !me.hidden;
    var moved = 0.0;
    // Folgemodus: Ohne eigene Eingabe übernimmt der Client die Serverposition
    // (Autopilot, Versetzen in der Beratung), ohne sie zurückzusenden.
    final idle = mag <= 0.05;
    _idleT = idle ? _idleT + dt : 0;
    if (!idle) {
      _following = false;
      _followT = 0;
    } else if (me != null && meTrusted && _idleT > 0.25) {
      final d = dist(me.x, me.y, _px, _py);
      _followT = d > 0.12 ? _followT + dt : 0;
      if (_followT > 0.45) _following = true;
      if (_following && d > 0.001) {
        final k = math.min(1.0, dt * 10);
        final nx = _px + (me.x - _px) * k, ny = _py + (me.y - _py) * k;
        moved = dist(nx, ny, _px, _py);
        if (moved > 0.004) _pf = _lerpAngle(_pf, math.atan2(ny - _py, nx - _px), math.min(1.0, dt * 12));
        _px = nx;
        _py = ny;
        _sentX = _px;
        _sentY = _py;
        _sentF = _pf;
      }
    }
    // Anlaufen in ~0,2 s, Abbremsen etwas schneller; die Richtung folgt sofort.
    final soll = canMove && mag > 0.05 ? mag : 0.0;
    if (!canMove) {
      _tempo = 0;
    } else {
      _tempo += (soll - _tempo) * (1 - math.exp(-dt * (soll > _tempo ? 11 : 16)));
      if (_tempo < 0.015 && soll == 0) _tempo = 0;
    }
    if (soll > 0) _richtung = input;
    final weg = _tippWeg != null && _tippWeg!.isNotEmpty ? _tippWeg : null;
    if (canMove && _tempo > 0 && _richtung.distance > 0.05) {
      // Statt der früheren Notluke ohne Kollision: zuerst auf freien Boden.
      _freistellen(grid);
      // Der Tippweg gibt die Richtung genau vor; Joystick und Tasten rasten.
      final dir = weg != null ? Offset(weg.first.dx - _px, weg.first.dy - _py) : _rasten(Iso.screenDirToWorld(_richtung.dx, _richtung.dy));
      final dl = dir.distance;
      if (dl > 1e-6) {
        // Geister sind wie in der Engine (PlayerState.speedMul) 10 % schneller.
        // Laufschritt der Detektivklasse (A-055): nur das Tempo der eigenen Figur.
        final speed = Tuning.playerSpeed * (me.life == LifeState.ghost ? 1.1 : _effectMul(me, (m) => m.speed)) * _tempo * (_klasse?.tempoFaktor ?? 1);
        final step = speed * dt;
        final (nx, ny) = weg != null ? _folgeWeg(grid, weg, step) : _gehe(grid, dir.dx / dl * step, dir.dy / dl * step);
        moved = dist(nx, ny, _px, _py);
        _px = nx;
        _py = ny;
        _pf = _lerpAngle(_pf, math.atan2(dir.dy, dir.dx), math.min(1.0, dt * 16));
      }
    }
    _pruefeHaengen(grid, dt, aktiv: canMove && weg != null);
    final r = grid.roomAtPos(_px, _py);
    if (r != null && !_isDoorTile(_px, _py)) _playerRoom = r.id;
    _walk += moved * 7.5;
    _moveAmt += ((moved > 1e-4 ? 1.0 : 0.0) - _moveAmt) * math.min(1.0, dt * 12);
    // Senden: ≤ 15 Hz und nur bei Änderung.
    if (me != null && _time - _lastSendT >= 1 / 15) {
      final changed = (_px - _sentX).abs() > 0.004 || (_py - _sentY).abs() > 0.004 || (_angleDiff(_pf, _sentF)) > 0.05;
      if (changed || _sentX.isNaN) _sendPose();
    }
  }

  void _sendPose() {
    if (_fuehrung?.eingabeGesperrt == true) return;
    session.move(_px, _py, _pf);
    _sentX = _px;
    _sentY = _py;
    _sentF = _pf;
    _lastSendT = _time;
    _unackedSince ??= _time;
  }

  /// Sendet die vorhergesagte Position sofort (ohne 15-Hz-Drossel), falls sie sich geändert hat.
  void _flushPose() {
    final me = _me;
    if (!_hasPos || me == null || me.life == LifeState.downed || me.hidden) return;
    final changed = (_px - _sentX).abs() > 0.004 || (_py - _sentY).abs() > 0.004 || (_angleDiff(_pf, _sentF)) > 0.05;
    if (changed || _sentX.isNaN) _sendPose();
  }

  String? _playerRoom;
  int _ackSeen = -1;
  double? _unackedSince;
  double _idleT = 0, _followT = 0;
  bool _following = false;

  bool _isDoorTile(double x, double y) {
    final c = _scene?.map.charAt(x.floor(), y.floor());
    return c == TileChar.door || c == TileChar.lockedDoor;
  }

  double _angleDiff(double a, double b) {
    if (a.isNaN || b.isNaN) return 10;
    var d = (a - b) % (math.pi * 2);
    if (d > math.pi) d = math.pi * 2 - d;
    return d.abs();
  }

  void _updateTracks(double dt) {
    final exakt = _ext?.exakteFiguren == true;
    final rt = _time - 0.12;
    for (final e in _tracks.entries) {
      final isNpc = e.key.startsWith('n:');
      final genau = exakt && isNpc;
      e.value.step(genau ? _time : rt, dt, useReportedFacing: !isNpc && e.key != 'shadow', teleport: !genau);
      if (isNpc && e.value.move < 0.3) {
        // NPCs schauen Spieler in der Nähe an, sonst in die Kamera.
        final t = e.value;
        final d = dist(t.x, t.y, _px, _py);
        final want = d < 4 && _hasPos ? math.atan2(_py - t.y, _px - t.x) : math.pi / 4;
        t.facing = _lerpAngle(t.facing, want, math.min(1.0, dt * 4));
      }
    }
  }

  void _updateCamera(double dt) {
    if (size.x <= 0 || size.y <= 0) return;
    final short = math.min(size.x, size.y);
    // Näher an den Figuren (Figuren 2.0): rund 7 Kacheln über die kurze Seite.
    final base = (short / (7.2 * Iso.tileW)).clamp(0.42, 2.6);
    final user = userZoom.clamp(0.6, 1.8);
    final ruhig = _fuehrung?.bewegungReduziert == true;
    final festeKamera = _ext?.kamera;
    final passend = festeKamera == null ? _passendeKamera(base, user) : null;
    final k = 1 - math.exp(-dt * 7);
    if (passend == null) {
      _zoomBasis = base;
    } else if (!_camInit || ruhig) {
      _zoomBasis = passend.zoom;
    } else {
      _zoomBasis += (passend.zoom - _zoomBasis) * k;
    }
    // Szenenregie: Beim Befragen oder Untersuchen fährt die Kamera langsam auf
    // Detektiv und Ziel heran (Zweier-Einstellung), Kinobalken blenden ein.
    final ziel = festeKamera == null && _hasPos ? _fuehrung?.handlungsZiel : null;
    final zielRegie = ziel == null ? 0.0 : 1.0;
    _regie = ruhig || !_camInit ? zielRegie : _regie + (zielRegie - _regie) * (1 - math.exp(-dt * 2.4));
    if (_regie > 0.001) {
      final regieZoom = math.min(base * 1.75, 2.6);
      _zoomBasis += (regieZoom - _zoomBasis) * _regie * (ruhig ? 1 : (1 - math.exp(-dt * 3)));
    }
    _zoom = _zoomBasis * user;
    Offset targetCam;
    if (festeKamera != null) {
      targetCam = Iso.toScreen(festeKamera.dx, festeKamera.dy, 0.6);
    } else if (passend != null) {
      // Die Mitte des Ausschnitts liegt in der Mitte des freien Bildteils.
      final frei = _freierBereich();
      targetCam = passend.mitte - (frei.center - Offset(size.x / 2, size.y * _camY)) / _zoom;
    } else if (_hasPos) {
      targetCam = Iso.toScreen(_px, _py, 0.6);
    } else {
      final m = _scene!.map;
      final sp = m.spawn.isNotEmpty ? m.spawn.first : Pt(m.width ~/ 2, m.height ~/ 2);
      targetCam = Iso.toScreen(sp.x + 0.5, sp.y + 0.5, 0.6);
    }
    final leucht = _leuchtZiel;
    if (leucht != null && !ruhig) {
      // Blick zum Ziel: hin in 1,2 s, kurz halten, zurück (Glocke über 4 s).
      final t = ((_untaetig - 10) / 4).clamp(0.0, 1.0);
      final glocke = math.sin(math.pi * t);
      targetCam = Offset.lerp(targetCam, Iso.toScreen(leucht.dx, leucht.dy, 0.6), 0.55 * glocke)!;
    }
    if (ziel != null && _regie > 0.001) {
      // Mitte zwischen Detektiv und Ziel, im freien Bildteil, etwas über Kopfhöhe.
      final paar = (Iso.toScreen(_px, _py, 0.9) + Iso.toScreen(ziel.dx, ziel.dy, 0.9)) / 2;
      final frei = _freierBereich();
      final regieCam = paar - (frei.center - Offset(size.x / 2, size.y * _camY)) / _zoom;
      targetCam = Offset.lerp(targetCam, regieCam, _regie)!;
    }
    // Etablierungsschwenk (M5): Beim ersten Betreten einer Akte zeigt die
    // Kamera den ganzen Schauplatz samt Kulisse, hält kurz und fährt dann zum
    // Detektiv. Eigene Eingabe, ruhige Bewegung oder feste Kamera brechen ab.
    if (_introOffen && _hasPos) {
      _introOffen = false;
      if (_ext != null && festeKamera == null && !ruhig && _introGespielt.add(_scenarioId ?? '')) {
        _intro = 0;
        _introUhr
          ..reset()
          ..start();
      }
    }
    if (_intro >= 0) {
      if (ruhig || festeKamera != null || stick.distance > 0.05 || _tippWeg != null || _keyboardDir().distance > 0.05) {
        _intro = -1;
      } else {
        const dauer = 3.4;
        _intro = _introUhr.elapsedMicroseconds / 1e6 / dauer;
        if (_intro < 1) {
          final m = _scene!.map;
          final mitte = Iso.toScreen(m.width / 2, m.height / 2, 0.4);
          final breite = (m.width + m.height) * Iso.halfW;
          final weit = math.min(_zoom, (_freierBereich().width / breite * 1.35).clamp(0.3, 2.0));
          final t = ((_intro * dauer - 0.8) / (dauer - 0.8)).clamp(0.0, 1.0);
          final e = t * t * (3 - 2 * t);
          _zoom = weit + (_zoom - weit) * e;
          _cam = Offset.lerp(mitte, targetCam, e)!;
          _introBalken = 1 - e;
          _camInit = true;
          return;
        }
        _intro = -1;
      }
    }
    _introBalken = 0;
    if (!_camInit || ruhig) {
      _cam = targetCam;
      _camInit = true;
    } else {
      _cam = Offset.lerp(_cam, targetCam, k)!;
    }
  }

  /// Der Teil des Bildes, den kein Bedienfeld verdeckt (mit kleinem Rand).
  Rect _freierBereich() => Rect.fromLTRB(
        sichtRand.links + 8,
        sichtRand.oben + 8,
        size.x - sichtRand.rechts - 8,
        size.y - sichtRand.unten - 8,
      );

  /// Zoom und Mitte (Welt-Bildpunkt), bei denen der Detektiv und seine Ziele
  /// den freien Bildteil füllen, ohne unter den Grundzoom [base] · 0,85 zu
  /// fallen. Ziele, die dafür zu weit weg liegen, bleiben außen vor. `null`
  /// ohne [kameraPassend], ohne [SzenenKamera] oder ohne Position.
  ({double zoom, Offset mitte})? _passendeKamera(double base, double user) {
    final sitzung = session;
    if (!kameraPassend || sitzung is! SzenenKamera || !_hasPos) return null;
    final frei = _freierBereich();
    if (frei.width < 120 || frei.height < 120) return null;
    // Platz für Namen und Sprechblasen über den Köpfen.
    Rect punkt(double x, double y) {
      final o = Iso.toScreen(x, y);
      return Rect.fromLTRB(o.dx - 44, o.dy - 96, o.dx + 44, o.dy + 16);
    }

    // Mindestgröße des Ausschnitts, damit ein einzelnes Ziel nicht übergroß wird.
    Rect weiten(Rect r) => Rect.fromCenter(
          center: r.center,
          width: math.max(r.width, 330.0),
          height: math.max(r.height, 230.0),
        );
    double zoomFuer(Rect r) {
      final b = weiten(r);
      return math.min(frei.width / b.width, frei.height / b.height);
    }

    final zMin = base * 0.85;
    final zMax = math.min(base * 1.8, 2.6);
    final ich = punkt(_px, _py);
    final nah = Iso.toScreen(_px, _py);
    final ziele = [...(sitzung as SzenenKamera).kameraZiele]
      ..sort((a, b) => (Iso.toScreen(a.dx, a.dy) - nah).distanceSquared.compareTo((Iso.toScreen(b.dx, b.dy) - nah).distanceSquared));
    var box = ich;
    for (final z in ziele) {
      final erweitert = box.expandToInclude(punkt(z.dx, z.dy));
      if (zoomFuer(erweitert) >= zMin) box = erweitert;
    }
    final zoom = zoomFuer(box).clamp(zMin, zMax);
    var mitte = weiten(box).center;
    // Wer hineinzoomt, folgt dem Detektiv statt dem Ausschnitt.
    final folgen = ((user - 1) / 0.4).clamp(0.0, 1.0);
    mitte = Offset.lerp(mitte, ich.center, folgen)!;
    // Der Detektiv bleibt immer im freien Bildteil.
    final zf = zoom * user;
    final halbB = frei.width / (2 * zf), halbH = frei.height / (2 * zf);
    final minX = ich.right - halbB, maxX = ich.left + halbB;
    final minY = ich.bottom - halbH, maxY = ich.top + halbH;
    mitte = Offset(
      minX <= maxX ? mitte.dx.clamp(minX, maxX) : ich.center.dx,
      minY <= maxY ? mitte.dy.clamp(minY, maxY) : ich.center.dy,
    );
    return (zoom: zoom, mitte: mitte);
  }

  static const _itemNames = {
    'coffee': 'Kaffee',
    'battery': 'Batterie',
    'salts': 'Riechsalz',
    'antidote': 'Gegengift',
    'medkit': 'Verbandskasten',
    'flare': 'Leuchtfackel',
    'trace': 'Spur des Schattens',
  };

  void _updateTarget() {
    final prog = _me?.channel?.progress ?? 0.0;
    if ((prog - channelProgress.value).abs() > 0.005) channelProgress.value = prog;
    final t = _computeTarget();
    final cur = target.value;
    if (t == null) {
      if (cur != null) target.value = null;
    } else if (!t.sameAs(cur)) {
      target.value = t;
    } else if (cur != null && (cur.x != t.x || cur.y != t.y)) {
      // gleiche Aktion, neue Position (NPC läuft) – ohne Benachrichtigung aktualisieren
      _targetPos = Offset(t.x, t.y);
      return;
    }
    _targetPos = t == null ? null : Offset(t.x, t.y);
  }

  Offset? _targetPos;

  ActionTarget? _computeTarget() {
    if (_fuehrung?.eingabeGesperrt == true) return null;
    final me = _me;
    final cv = session.caseView.value;
    final s = session.scenario;
    if (me == null || cv == null || s == null || !_hasPos) return null;
    if (!_actionPhase) return null;
    final ch = me.channel;
    if (ch != null) {
      return ActionTarget(id: '', label: 'Abbrechen', kind: 'cancel', x: _px, y: _py, name: '');
    }
    if (me.life == LifeState.downed) return null;
    const range = Tuning.interactRange;
    ActionTarget? best;
    var bestD = double.infinity;
    void consider(ActionTarget t, double d, [double bias = 0]) {
      if (d > range) return;
      if (t.id == _bevorzugtesZiel) bias -= 0.02;
      if (d + bias < bestD) {
        bestD = d + bias;
        best = t;
      }
    }

    final ghost = me.life == LifeState.ghost;
    for (final e in cv.hotspots.entries) {
      final h = s.hotspotById[e.key];
      if (h == null) continue;
      if (me.hidden && h.kind != HotspotKind.hide) continue;
      if (e.value == HotspotState.searched && h.kind != HotspotKind.lab && h.kind != HotspotKind.hide) continue;
      if (_nebelSicht(h.x + 0.5, h.y + 0.5) < 0.5) continue;
      final label = _ext?.hotspotAktion(h.id) ?? switch (h.kind) {
        HotspotKind.search => 'Durchsuchen',
        HotspotKind.lab => 'Analysieren',
        HotspotKind.hide => me.hidden ? 'Rauskommen' : 'Verstecken',
        HotspotKind.body => 'Untersuchen',
        HotspotKind.blood => 'Untersuchen',
        _ => 'Untersuchen',
      };
      final prop = _scene?.propAt[Pt(h.x, h.y)]?.prop;
      final z = prop != null ? PropPainter.topZ(prop) : 0.0;
      final hx = h.x + 0.5, hy = h.y + 0.5;
      final d = dist(_px, _py, hx, hy);
      consider(
        ActionTarget(id: h.id, label: label, kind: h.kind, x: hx, y: hy, z: z, name: h.name.resolve()),
        me.hidden ? math.min(d, range - 0.01) : d,
      );
    }
    if (me.hidden) return best;
    if (!ghost) {
      final dead = cv.deadNpcs.toSet();
      final held = <String>{for (final c in cv.notebook) c.id, for (final c in cv.board) c.id};
      for (final n in _world?.npcs ?? const <NpcView>[]) {
        if (!n.alive || dead.contains(n.id)) {
          // Leiche durchsuchen (Engine: Suche nach den Hinweisen dieses NPCs),
          // solange er noch Hinweise hat, die wir nicht kennen.
          if (me.life != LifeState.alive) continue;
          if (!s.clues.any((d) => d.source.npc == n.id && !held.contains(d.id))) continue;
          final tr = _tracks['n:${n.id}'];
          final nx = tr?.x ?? n.x, ny = tr?.y ?? n.y;
          final sus = s.suspectById[n.id];
          consider(
            ActionTarget(
              id: n.id,
              label: 'Durchsuchen',
              kind: 'search',
              x: nx,
              y: ny,
              z: 0.2,
              name: sus?.name.resolve() ?? n.id,
            ),
            dist(_px, _py, nx, ny),
          );
          continue;
        }
        final ext = _ext;
        final aktion = ext == null ? 'Befragen' : ext.npcAktion(n.id);
        if (aktion == null) continue;
        final tr = _tracks['n:${n.id}'];
        final nx = tr?.x ?? n.x, ny = tr?.y ?? n.y;
        final sus = s.suspectById[n.id];
        consider(
          ActionTarget(
            id: n.id,
            label: aktion,
            // Eine Figur, die untersucht wird, bekommt die Lupe statt der Sprechblase (E-038).
            kind: ext != null && ext.npcUntersuchen(n.id) ? HotspotKind.search : 'npc',
            figur: true,
            x: nx,
            y: ny,
            z: 1.5,
            name: sus?.name.resolve() ?? n.id,
          ),
          dist(_px, _py, nx, ny),
          -0.05,
        );
      }
      for (final it in cv.items) {
        final isTrace = it.type == 'trace';
        consider(
          ActionTarget(
            id: it.id,
            label: isTrace ? 'Spur untersuchen' : 'Aufheben',
            kind: isTrace ? 'trace' : 'item',
            x: it.x,
            y: it.y,
            z: isTrace ? 0.1 : 0.5,
            name: _itemNames[it.type] ?? it.type,
          ),
          dist(_px, _py, it.x, it.y),
        );
      }
      if (me.life == LifeState.alive) {
        for (final d in _world?.detectives ?? const <DetectiveView>[]) {
          if (d.id == me.id || d.life != LifeState.downed) continue;
          final tr = _tracks['d:${d.id}'];
          final dx = tr?.x ?? d.x, dy = tr?.y ?? d.y;
          consider(
            ActionTarget(id: d.id, label: 'Wiederbeleben', kind: 'revive', x: dx, y: dy, z: 0.4, name: d.name),
            dist(_px, _py, dx, dy),
            -0.3,
          );
        }
      }
    }
    return best;
  }

  // --- kleine Effekte (Partymodus) ---
  final List<_Teilchen> _teilchen = [];
  double _stillT = 0, _blasenT = 0;
  final Map<String, double> _gagSperre = {};

  void _updateKleineEffekte(double dt) {
    final scene = _scene;
    if (scene == null || _ext?.kleineEffekte != true || !_hasPos) return;
    // Seifenblasen aus der Pfeife, wenn das Geburtstagskind kurz stillsteht.
    _stillT = _moveAmt < 0.08 ? _stillT + dt : 0;
    if (_stillT > 1.4 && _ext?.kamera == null) {
      _blasenT -= dt;
      if (_blasenT <= 0) {
        _blasenT = 0.35 + _rnd.nextDouble() * 0.5;
        final o = Iso.toScreen(_px, _py).translate(9 + _rnd.nextDouble() * 4, -40);
        _teilchen.add(_Teilchen(o.dx, o.dy, 4 + _rnd.nextDouble() * 8, -16 - _rnd.nextDouble() * 10, 2.2 + _rnd.nextDouble(), 2.2 + _rnd.nextDouble() * 2.4, const Color(0xFFE8F4FF), blase: true));
      }
    }
    // Gags an Rüstung und Kamin, höchstens alle 10 s je Stück.
    for (final p in scene.scenario.map.props) {
      if (p.type != 'party_ruestung' && p.type != 'party_kamin') continue;
      final k = '${p.type}@${p.x},${p.y}';
      _gagSperre[k] = math.max(0, (_gagSperre[k] ?? 0) - dt);
      if (_gagSperre[k]! > 0 || dist(_px, _py, p.x + 0.5, p.y + 0.5) > 1.7) continue;
      _gagSperre[k] = 10;
      if (p.type == 'party_ruestung') {
        // Das Visier klappert: Staub rieselt vom Helm, ein kurzes Blitzen.
        final o = Iso.toScreen(p.x + 0.5, p.y + 0.5, 1.45);
        for (var i = 0; i < 9; i++) {
          _teilchen.add(_Teilchen(o.dx + (_rnd.nextDouble() - 0.5) * 10, o.dy, (_rnd.nextDouble() - 0.5) * 14, 6 + _rnd.nextDouble() * 18, 1.2 + _rnd.nextDouble() * 0.6, 1.2, const Color(0xFFBFB8AA)));
        }
        _teilchen.add(_Teilchen(o.dx + 4, o.dy - 2, 0, 0, 0.45, 6, const Color(0xFFFFFFFF), wachsen: 18));
      } else {
        // Aus dem kalten Kamin pufft eine Rußwolke.
        final o = Iso.toScreen(p.x + 0.5, p.y + 0.9, 0.3);
        for (var i = 0; i < 14; i++) {
          _teilchen.add(_Teilchen(o.dx + (_rnd.nextDouble() - 0.5) * 18, o.dy, (_rnd.nextDouble() - 0.5) * 22, -10 - _rnd.nextDouble() * 22, 1.4 + _rnd.nextDouble() * 0.8, 3 + _rnd.nextDouble() * 3, const Color(0xFF3B3632), wachsen: 7));
        }
      }
    }
    _trittWoelkchen(scene);
    for (var i = _teilchen.length - 1; i >= 0; i--) {
      final t = _teilchen[i];
      t.life += dt;
      t.x += t.vx * dt + (t.blase ? math.sin(t.life * 3 + i) * 6 * dt : 0);
      t.y += t.vy * dt;
      t.r += t.wachsen * dt;
      if (t.life >= t.max) _teilchen.removeAt(i);
    }
  }

  double _letzterTritt = 0;

  /// Bei jedem Schritt ein Wölkchen am Fuß: Schnee, Kies und Staub draußen,
  /// Pfützenspritzer im Regen, drinnen nur ein Hauch.
  void _trittWoelkchen(StaticScene scene) {
    final schritt = (_walk / math.pi).floor();
    if (schritt == _letzterTritt || _moveAmt < 0.4) {
      _letzterTritt = schritt.toDouble();
      return;
    }
    _letzterTritt = schritt.toDouble();
    final raum = _grid?.roomAtPos(_px, _py);
    final aussen = raum?.outdoor ?? false;
    final wetter = scene.scenario.theme.weather;
    final boden = raum?.floor ?? 'stone';
    final (farbe, menge, groesse) = switch ((aussen, boden, wetter)) {
      (true, _, 'snow') || (_, 'snow', _) => (const Color(0xFFF2F6FA), 5, 2.4),
      (true, _, 'rain') => (const Color(0xFFBFD0E0), 4, 1.6),
      (true, 'grass', _) => (const Color(0xFF9DB07A), 2, 1.3),
      (true, _, _) => (const Color(0xFFC9BCA4), 4, 2.0),
      _ => (const Color(0xFFD8CFC0), schritt.isEven ? 2 : 0, 1.5),
    };
    if (menge == 0) return;
    final seite = schritt.isEven ? 1.0 : -1.0;
    final fuss = Iso.toScreen(_px, _py).translate(seite * 2.5, 1);
    for (var i = 0; i < menge; i++) {
      _teilchen.add(_Teilchen(
        fuss.dx + (_rnd.nextDouble() - 0.5) * 6,
        fuss.dy + (_rnd.nextDouble() - 0.5) * 2,
        (_rnd.nextDouble() - 0.5) * 16,
        -4 - _rnd.nextDouble() * 8,
        0.45 + _rnd.nextDouble() * 0.35,
        groesse * (0.6 + _rnd.nextDouble() * 0.6),
        farbe,
        wachsen: 3,
      ));
    }
  }

  /// Schwebestaub im Lampenlicht: ruhig kreisende Fünkchen, nur aus der Uhr
  /// berechnet (kein Zustand).
  void _lichtStaub(Canvas c, StaticScene scene, Rect cull) {
    final p = Paint()..blendMode = BlendMode.plus;
    var n = 0;
    for (final l in scene.lightProps) {
      final o = Iso.toScreen(l.x + 0.5, l.y + 0.5, 0.9);
      if (!cull.contains(o)) continue;
      if (++n > 12) break;
      final seed = l.x * 7 + l.y * 13;
      for (var i = 0; i < 6; i++) {
        final ph = seed * 0.37 + i * 1.91;
        final t = _time * (0.18 + i * 0.02);
        final pos = o.translate(math.sin(t + ph) * 22 + math.sin(t * 2.3 + ph) * 5, math.cos(t * 0.8 + ph * 1.3) * 14 - 6);
        final a = 0.5 + 0.5 * math.sin(_time * 1.3 + ph * 2);
        p.color = withAlpha(scene.pal.light, 0.10 + 0.22 * a);
        c.drawCircle(pos, 0.8 + 0.5 * a, p);
      }
    }
  }

  void _zeichneKleineEffekte(Canvas c) {
    for (final t in _teilchen) {
      final a = (1 - t.life / t.max).clamp(0.0, 1.0);
      final o = Offset(t.x, t.y);
      if (t.blase) {
        c.drawCircle(o, t.r, Paint()..color = withAlpha(t.farbe, 0.10 * a));
        c.drawCircle(
          o,
          t.r,
          Paint()
            ..color = withAlpha(t.farbe, 0.65 * a)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7,
        );
        c.drawCircle(o.translate(-t.r * 0.35, -t.r * 0.35), t.r * 0.25, Paint()..color = withAlpha(const Color(0xFFFFFFFF), 0.8 * a));
      } else {
        c.drawCircle(o, t.r, Paint()..color = withAlpha(t.farbe, 0.75 * a));
      }
    }
  }

  void _updateEffects(double dt) {
    _updateKleineEffekte(dt);
    _actionPulse = math.max(0, _actionPulse - dt * 3);
    for (var i = _localPings.length - 1; i >= 0; i--) {
      _localPings[i].age += dt;
      if (_localPings[i].age > 1.6) _localPings.removeAt(i);
    }
    // Rauch des Schattens
    final sh = _tracks['shadow'];
    final shadowVisible = sh != null && _world?.shadow != null;
    if (shadowVisible) {
      final o = Iso.toScreen(sh.x, sh.y);
      final n = (dt * 26).ceil();
      for (var i = 0; i < n && _smoke.length < 42; i++) {
        _smoke.add(
          _Smoke(
            o.dx + (_rnd.nextDouble() - 0.5) * 26,
            o.dy - _rnd.nextDouble() * 10,
            (_rnd.nextDouble() - 0.5) * 10,
            -12 - _rnd.nextDouble() * 18,
            0.9 + _rnd.nextDouble() * 0.9,
            4 + _rnd.nextDouble() * 5,
          ),
        );
      }
    }
    for (var i = _smoke.length - 1; i >= 0; i--) {
      final p = _smoke[i];
      p.life += dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.r += dt * 6;
      if (p.life >= p.max) _smoke.removeAt(i);
    }
    // Blitze
    final theme = _scene!.scenario.theme;
    if (theme.lightning && _phase == Phase.night) {
      _nextFlash -= dt;
      if (_nextFlash <= 0) {
        _flashT = 0;
        // Der Donner folgt dem Blitz mit Abstand.
        _donnerIn = 0.5 + _rnd.nextDouble() * 1.2;
        _nextFlash = 6 + _rnd.nextDouble() * 9;
      }
    }
    if (_flashT >= 0) {
      _flashT += dt;
      final t = _flashT;
      _flash = t < 0.07
          ? 1.0
          : t < 0.14
          ? 0.25
          : t < 0.22
          ? 0.85
          : math.max(0.0, 0.85 * (1 - (t - 0.22) / 0.5));
      if (t > 0.75) {
        _flashT = -1;
        _flash = 0;
      }
    }
    // Wetter
    final room = _hasPos ? _grid?.roomAtPos(_px, _py) : null;
    final outdoor = room?.outdoor ?? false;
    final wk = _weather?.kind ?? 'none';
    final want = switch (wk) {
      'dust' => outdoor ? 1.0 : 0.55,
      'neon' => outdoor ? 1.0 : 0.35,
      _ => outdoor ? 1.0 : 0.0,
    };
    final camBefore = _lastCamForWeather;
    _lastCamForWeather = _cam;
    final pan = camBefore == null ? Offset.zero : (_cam - camBefore) * _zoom;
    _weather?.update(dt, Size(size.x, size.y), want, pan);
  }

  Offset? _lastCamForWeather;

  // ---------------------------------------------------------------------------
  // Render

  Offset _toView(Offset worldScreen) => (worldScreen - _cam) * _zoom + Offset(size.x / 2, size.y * _camY);

  @override
  void render(Canvas canvas) {
    final scene = _scene;
    final viewSize = Size(size.x, size.y);
    if (scene == null || viewSize.isEmpty) return;
    final markers = _markers!;
    final w = _world;
    final cv = session.caseView.value;
    final s = scene.scenario;
    final t = _time;
    final phase = _phase;

    canvas.save();
    canvas.translate(size.x / 2, size.y * _camY);
    canvas.scale(_zoom);
    canvas.translate(-_cam.dx, -_cam.dy);
    final view = Rect.fromCenter(
      center: _cam.translate(0, (0.5 - _camY) * size.y / _zoom),
      width: size.x / _zoom,
      height: size.y / _zoom,
    );
    final cull = view.inflate(48);

    // 0) Kulisse jenseits der Karte (Gelände, Bäume, Gleise …)
    final floorPaint = Paint()..filterQuality = FilterQuality.medium;
    scene.kulisse?.zeichne(canvas, cull, floorPaint);

    // 1) Böden
    for (final f in scene.floors) {
      if (!f.dst.overlaps(cull)) continue;
      final img = f.image;
      if (img != null) {
        canvas.drawImageRect(img, Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()), f.dst, floorPaint);
      } else if (f.picture != null) {
        canvas.drawPicture(f.picture!);
      }
    }

    // 2) Bodendekor: Leichen, Niedergeschlagene, Spuren, Zielring
    _renderGround(canvas, scene, cv, cull);

    // 3) Tiefensortierte Objekte
    _renderSorted(canvas, scene, cv, cull);

    // 4) Licht
    final szLicht = _ext?.licht;
    if (szLicht != null) {
      _renderSzenenLicht(canvas, view, scene, szLicht, cull, t);
    } else {
      _renderPhasenLicht(canvas, view, scene, phase, s, cull, t);
    }

    // 4b) Nebel des Krieges (Partymodus), nur im Sichtbereich
    _renderNebel(canvas, scene, cull);

    // 4c) Detektivklasse (A-055): Leuchten im Umkreis, Türen und Treppen
    if (_klasse case final k? when _hasPos) {
      final glanz = session is SzenenGlanz ? (session as SzenenGlanz).glanzpunkte : const <SzenenGlanzPunkt>[];
      _klassenEbene?.boden(canvas, k, scene: scene, fall: cv, glanz: glanz, ich: Offset(_px, _py), offen: _openDoors, cull: cull, t: t,
          ruhig: _fuehrung?.bewegungReduziert == true);
    }

    // 5) Über der Dunkelheit: Augen, Pings, Notsignale
    _renderPostLight(canvas, scene, w, cv, cull);
    canvas.restore();

    // 5b) Außerhalb der Karte: Palette der Akte statt Schwarz
    final umg = umgebung;
    if (umg != null) _renderUmgebung(canvas, scene, umg, cull);

    // 6) Wetter (Bildschirm)
    _weather?.render(canvas, viewSize, t);

    // 7) Bildschirm-Overlays: Namen, Blasen, Ringe, Ziel
    _renderOverlays(canvas, scene, w, markers);

    // 8) Vignette + Blitz
    final vr = Rect.fromLTWH(0, 0, size.x, size.y);
    final night = szLicht != null || phase == Phase.night;
    // Mit Umgebung der Akte: leichterer Rand in einem dunklen Ton der Akte, nie reines Schwarz.
    final vignette = umg == null ? const Color(0xFF000000) : Color.lerp(umg.rand, const Color(0xFF000000), 0.45)!;
    canvas.drawRect(
      vr,
      Paint()
        ..shader = Gradient.radial(
          vr.center,
          vr.longestSide * 0.72,
          [vignette.withValues(alpha: 0), withAlpha(vignette, umg == null ? (night ? 0.62 : 0.38) : 0.5)],
          const [0.45, 1.0],
        ),
    );
    if (_flash > 0.01) {
      canvas.drawRect(vr, Paint()..color = withAlpha(const Color(0xFFE6EEFF), 0.22 * _flash));
    }

    // 9) Kinobalken der Szenenregie: vom Bildrand bis in den freien Bildteil hinein,
    // damit über und unter den Balken keine Karte durchscheint.
    final balkenGrad = math.max(_regie, _introBalken);
    if (balkenGrad > 0.01) {
      final frei = _freierBereich();
      final r = balkenGrad.clamp(0.0, 1.0);
      final h = frei.height * 0.085 * (1 - (1 - r) * (1 - r));
      final balken = Paint()..color = withAlpha(const Color(0xFF050407), 0.94 * r);
      canvas.drawRect(Rect.fromLTRB(0, 0, size.x, frei.top + h), balken);
      canvas.drawRect(Rect.fromLTRB(0, frei.bottom - h, size.x, size.y), balken);
    }

    // 10) Ebenenwechsel (M7a): aus dem Dunkel der Akte aufblenden.
    if (_blende > 0) {
      final a = (_blende / ebenenBlende).clamp(0.0, 1.0);
      canvas.drawRect(vr, Paint()..color = withAlpha(_pal.background, a * a * (3 - 2 * a)));
    }
  }

  /// Silhouette der Karte (Kacheln samt Wandhöhe) in Welt-Bildkoordinaten, zeilenweise.
  Path? _umriss;
  String? _umrissFuer;

  Path _kartenUmriss(StaticScene scene) {
    final id = scene.scenario.id;
    if (_umriss != null && _umrissFuer == id) return _umriss!;
    final m = scene.scenario.map;
    final p = Path();
    const hoehe = 1.6;
    for (var y = 0; y < m.height; y++) {
      var x = 0;
      while (x < m.width) {
        if (m.charAt(x, y) == TileChar.void_) {
          x++;
          continue;
        }
        final a = x;
        while (x < m.width && m.charAt(x, y) != TileChar.void_) {
          x++;
        }
        // Lauf [a, x) in Zeile y: Boden samt hochgezogenem Rand als Sechseck.
        final p1 = Iso.toScreen(a.toDouble(), y.toDouble());
        final p2 = Iso.toScreen(x.toDouble(), y.toDouble());
        final p3 = Iso.toScreen(x.toDouble(), y + 1.0);
        final p4 = Iso.toScreen(a.toDouble(), y + 1.0);
        const hub = Offset(0, -hoehe * Iso.unitZ);
        p.addPolygon([p1 + hub, p2 + hub, p2, p3, p4, p4 + hub], true);
      }
    }
    _umrissFuer = id;
    return _umriss = p;
  }

  /// Verlauf außerhalb der Karte: Die Silhouette wird aus einer Ebene mit dem
  /// Verlauf ausgestanzt, innen bleibt die Szene unverändert.
  void _renderUmgebung(Canvas canvas, StaticScene scene, SzenenUmgebung u, Rect cull) {
    final vr = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.saveLayer(vr, Paint());
    canvas.drawRect(
      vr,
      Paint()
        ..shader = Gradient.radial(
          _freierBereich().center,
          vr.longestSide * 0.75,
          [u.mitte, u.rand],
          const [0.0, 1.0],
        ),
    );
    canvas.save();
    canvas.translate(size.x / 2, size.y * _camY);
    canvas.scale(_zoom);
    canvas.translate(-_cam.dx, -_cam.dy);
    canvas.drawPath(
      _kartenUmriss(scene),
      Paint()
        ..blendMode = BlendMode.dstOut
        ..color = const Color(0xFF000000),
    );
    // Die Kulisse bleibt sichtbar und läuft weich in den Verlauf aus.
    scene.kulisse?.zeichne(canvas, cull, Paint()..blendMode = BlendMode.dstOut);
    canvas.restore();
    canvas.restore();
  }

  void _renderPhasenLicht(Canvas canvas, Rect view, StaticScene scene, Phase? phase, ScenarioDef s, Rect cull, double t) {
    final lightMode = phase == Phase.night
        ? LightMode.night
        : (phase == Phase.council || phase == Phase.accusation)
        ? LightMode.council
        : LightMode.day;
    _lighting!.render(
      canvas,
      view.inflate(4),
      mode: lightMode,
      darkness: lightMode == LightMode.night ? (1 - s.theme.nightAmbient).clamp(0.3, 0.97) : 0.42,
      lights: _lights(lightMode),
      litRooms: lightMode == LightMode.day
          ? const []
          : [
              for (final r in s.map.rooms)
                if (r.lit) r,
            ],
      glows: _glows(scene, cull, t),
      flash: _flash,
      dayTint: ((1 - s.theme.dayAmbient) * 0.55).clamp(0.0, 0.5),
    );
  }

  // ---------------------------------------------------------------------------
  // Szenen-Erweiterung (Partymodus, E-030): Licht nach Master 7.13, Nebel des
  // Krieges je Raum, Umrisse in der Rückblende. Ohne Erweiterung ungenutzt.

  GefuehrteSzene? get _fuehrung {
    final s = session;
    return s is GefuehrteSzene ? s as GefuehrteSzene : null;
  }

  SzenenErweiterung? get _ext {
    final s = session;
    return s is SzenenErweiterung ? s as SzenenErweiterung : null;
  }

  SzenenKlasse? get _klasse {
    final s = session;
    return s is SzenenKlasse ? s as SzenenKlasse : null;
  }

  KlassenEbene? _klassenEbene;

  void _renderSzenenLicht(Canvas canvas, Rect view, StaticScene scene, SzenenLicht l, Rect cull, double t) {
    final lights = <SceneLight>[];
    if (l.taschenlampe && _hasPos) {
      lights.add(SceneLight(_px, _py, Tuning.nightLightRadius, cone: _pf));
      lights.add(SceneLight(_px, _py, 1.2, strength: 0.75));
    }
    final glows = _glows(scene, cull, t);
    for (final p in l.punkte) {
      final seed = (p.x * 3 + p.y * 7).round();
      final fl = 1 - p.flackern * 0.3 * (0.5 + 0.5 * math.sin(t * 7 + seed) * math.sin(t * 4.1 + seed * 2));
      lights.add(SceneLight(p.x, p.y, p.radius * fl, strength: 0.85));
      glows.add(GlowLight(p.x, p.y, p.z, p.radius * 0.55 * fl, p.farbe, fl));
    }
    _lighting!.render(
      canvas,
      view.inflate(4),
      mode: LightMode.night,
      darkness: l.dunkel.clamp(0.0, 1.0),
      lights: lights,
      litRooms: [
        for (final r in scene.scenario.map.rooms)
          if (l.helleRaeume.contains(r.id)) r,
      ],
      glows: glows,
      flash: 0,
      dayTint: 0,
    );
    // Umrisse und Hervorhebungen über der Dunkelheit (Rückblende)
    final ext = _ext!;
    for (final n in _world?.npcs ?? const <NpcView>[]) {
      final h = ext.hervorhebung(n.id);
      if (h == null) continue;
      final tr = _tracks['n:${n.id}'];
      if (tr == null || _nebelSicht(tr.x, tr.y) < 0.5) continue;
      final o = Iso.toScreen(tr.x, tr.y);
      if (!cull.contains(o)) continue;
      final sus = scene.scenario.suspectById[n.id];
      final look = sus != null ? FigureLook.fromLook(sus.look) : FigureLook.fromLook(const LookDef());
      if (h > 0) {
        canvas.save();
        canvas.translate(o.dx, o.dy);
        Iso.applyGround(canvas);
        final ph = 0.5 + 0.5 * math.sin(t * 3);
        canvas.drawCircle(
          Offset.zero,
          0.42 + 0.06 * ph,
          Paint()
            ..color = withAlpha(_pal.accent, 0.55 + 0.35 * ph)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.07,
        );
        canvas.restore();
      }
      canvas.saveLayer(Rect.fromCenter(center: o.translate(0, -30), width: 80, height: 90), Paint()..color = Color.fromRGBO(0, 0, 0, h > 0 ? 0.92 : 0.2));
      _fig.standing(canvas, o, look, facing: tr.facing, walk: tr.walk, moveAmt: tr.move, shadow: false);
      canvas.restore();
    }
  }

  // ---------------------------------------------------------------------------
  // NPC-Leben (M4): ruhige Tätigkeiten im Stand, nur Darstellung. Sie hängen nur
  // von der Kennung der Figur und der Uhr ab, nie vom Täterpfad oder Spielstand.

  static const _taetigkeiten = [
    Taetigkeit.keine,
    Taetigkeit.uhr,
    Taetigkeit.umsehen,
    Taetigkeit.notiz,
    Taetigkeit.keine,
    Taetigkeit.tasse,
    Taetigkeit.verschraenkt,
  ];

  /// Tätigkeit, Einblendung (0..1) und Zeit seit Beginn. Wer gerade befragt
  /// wird oder wem der Detektiv nahe kommt, hält inne und schaut auf.
  (Taetigkeit, double, double) _npcTaetigkeit(String id, double x, double y, double move) {
    if (move > 0.1) return (Taetigkeit.keine, 0, 0);
    final gespraech = session is SzenenGespraech ? (session as SzenenGespraech).gespraechsGeste : null;
    if (gespraech != null && gespraech.npc == id) return _gespraechsTaetigkeit(id, gespraech.geste);
    final ziel = _fuehrung?.handlungsZiel;
    if (ziel != null && (ziel.dx - x).abs() + (ziel.dy - y).abs() < 1.2) return (Taetigkeit.keine, 0, 0);
    final s = fnv32(id);
    final lang = 8.0 + s % 5;
    final t = _time + (s % 17);
    final k = (t / lang).floor();
    final tat = _taetigkeiten[fnv32('$id:$k') % _taetigkeiten.length];
    final tz = t - k * lang;
    final rein = math.min(1.0, math.min(tz, lang - tz) / 0.7);
    var grad = rein * rein * (3 - 2 * rein);
    if (_hasPos) {
      final d = math.sqrt((x - _px) * (x - _px) + (y - _py) * (y - _py));
      grad *= ((d - 1.6) / 0.8).clamp(0.0, 1.0);
    }
    return (tat, grad, tz);
  }

  /// Seit wann (Spielzeit) eine Figur ihre aktuelle Gesprächsgeste zeigt.
  final Map<String, (SzenenGeste, double)> _gesteSeit = {};

  /// Geste der aktuellen Gesprächszeile, ab ihrem Wechsel sanft eingeblendet.
  (Taetigkeit, double, double) _gespraechsTaetigkeit(String id, SzenenGeste geste) {
    final alt = _gesteSeit[id];
    if (alt == null || alt.$1 != geste) _gesteSeit[id] = (geste, _time);
    final tz = _time - _gesteSeit[id]!.$2;
    final tat = switch (geste) {
      SzenenGeste.abwehr => Taetigkeit.verschraenkt,
      SzenenGeste.nachdenken => Taetigkeit.umsehen,
      SzenenGeste.zuhoeren => Taetigkeit.keine,
    };
    final rein = math.min(1.0, tz / 0.45);
    return (tat, rein * rein * (3 - 2 * rein), tz);
  }

  /// Sichtbarkeit je Raum (0 schwarz … 1 sichtbar) mit radialem Aufblenden.
  final Map<String, _Nebel> _nebel = {};

  /// Nebelräume, die außerhalb des Sichtbereichs nicht gezeichnet wurden (Tests).
  @visibleForTesting
  int nebelVerworfen = 0;
  Set<String>? _sichtbar;

  void _updateNebel(double dt) {
    final ext = _ext;
    final scene = _scene;
    if (ext == null || scene == null || !_hasPos) {
      _sichtbar = null;
      return;
    }
    final sicht = ext.sichtbareRaeume(_px, _py);
    _sichtbar = sicht;
    if (sicht == null) return;
    for (final r in scene.scenario.map.rooms) {
      final n = _nebel.putIfAbsent(r.id, () => _Nebel(sicht.contains(r.id) ? 1 : 0));
      final soll = sicht.contains(r.id);
      if (soll) n.erinnert = true;
      if (soll && !n.offen) {
        n.offen = true;
        n.ursprung = Offset(_px, _py);
      } else if (!soll && n.offen) {
        n.offen = false;
        n.ursprung = null;
      }
      // 0,4 s bis zur vollen Sicht (Master 7.13).
      n.sicht = (n.sicht + (n.offen ? dt : -dt) / 0.4).clamp(0.0, 1.0);
    }
  }

  /// Sichtbarkeit an einer Kachelposition (1 ohne Nebel).
  double _nebelSicht(double x, double y) {
    if (_sichtbar == null) return 1;
    final s = session.scenario;
    if (s == null) return 1;
    for (final r in s.map.rooms) {
      if (x >= r.x && x < r.x + r.w && y >= r.y && y < r.y + r.h) return _nebel[r.id]?.sicht ?? 1;
    }
    return 1;
  }

  /// Weicher Schleier statt schwarzer Fläche: unbekannte Räume liegen zu
  /// höchstens 62 % im Dunst, bekannte zu 38 % ([nebelDeckkraft]).
  ///
  /// Nur Räume, deren Umriss den Sichtbereich [cull] berührt (große Ebenen
  /// des langen Abends, M7a): Der weiche Rand kostet je Raum einen Weichzeichner.
  void _renderNebel(Canvas c, StaticScene scene, Rect cull) {
    if (_sichtbar == null) return;
    const wand = 1.6;
    final schleier = nebelSchleier(_pal);
    for (final r in scene.scenario.map.rooms) {
      final n = _nebel[r.id];
      if (n == null || n.sicht >= 0.999) continue;
      final deckkraft = nebelDeckkraft(n.sicht, erinnert: n.erinnert);
      if (deckkraft < 0.01) continue;
      // Boden randgenau, nur die hinteren Kanten (eigene Rückwände) angehoben.
      final x0 = r.x.toDouble(), y0 = r.y.toDouble(), x1 = (r.x + r.w).toDouble(), y1 = (r.y + r.h).toDouble();
      final a = Iso.toScreen(x0, y0), b = Iso.toScreen(x1, y0), d = Iso.toScreen(x1, y1), e = Iso.toScreen(x0, y1);
      final ah = Iso.toScreen(x0, y0, wand), bh = Iso.toScreen(x1, y0, wand), eh = Iso.toScreen(x0, y1, wand);
      final umriss = Rect.fromLTRB(e.dx, math.min(ah.dy, bh.dy), b.dx, d.dy);
      if (!umriss.overlaps(cull)) {
        nebelVerworfen++;
        continue;
      }
      final path = Path()
        ..moveTo(ah.dx, ah.dy)
        ..lineTo(bh.dx, bh.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(d.dx, d.dy)
        ..lineTo(e.dx, e.dy)
        ..lineTo(eh.dx, eh.dy)
        ..close();
      // Weicher Rand statt harter Kante zwischen Schleier und sichtbarem Raum.
      final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final u = n.ursprung;
      if (n.offen && u != null) {
        // Radialer Übergang von der Stelle, an der der Raum ins Sichtfeld kam.
        final o = Iso.toScreen(u.dx, u.dy);
        final weit = (a - d).distance + (b - e).distance;
        final rad = math.max(1.0, weit * n.sicht);
        final klar = schleier.withValues(alpha: 0);
        final voll = schleier.withValues(alpha: nebelDeckkraft(0, erinnert: n.erinnert));
        paint.shader = Gradient.radial(o, rad, [klar, klar, voll], const [0.0, 0.7, 1.0]);
      } else {
        paint.color = schleier.withValues(alpha: deckkraft);
      }
      c.drawPath(path, paint);
    }
  }

  void _renderGround(Canvas c, StaticScene scene, CaseView? cv, Rect cull) {
    final s = scene.scenario;
    final w = _world;
    // Zielmarke des Tippwegs: zwei Ringe, die sich zusammenziehen und verblassen.
    final marke = _tippMarke;
    if (marke != null) {
      final t = (_tippMarkeT / 0.9).clamp(0.0, 1.0);
      if (t >= 1 && _tippWeg == null) {
        _tippMarke = null;
      } else {
        final o = Iso.toScreen(marke.dx, marke.dy);
        c.save();
        c.translate(o.dx, o.dy);
        Iso.applyGround(c);
        final a = _tippWeg == null ? 1 - t : 0.75;
        for (final k in [0.0, 0.5]) {
          final p = ((_tippMarkeT * 1.4 + k) % 1.0);
          c.drawCircle(
            Offset.zero,
            0.42 - 0.22 * p,
            Paint()
              ..color = withAlpha(_pal.accent, a * (0.25 + 0.6 * p))
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.035,
          );
        }
        c.restore();
      }
    }
    // Opfer
    final vh = s.hotspotById[s.victim.hotspot];
    if (vh != null) {
      final o = Iso.toScreen(vh.x + 0.5, vh.y + 0.5);
      if (cull.contains(o)) {
        _fig.lying(c, vh.x + 0.5, vh.y + 0.5, FigureLook.fromLook(s.victim.look), rot: 0.5, chalk: true, scale: 1.35);
      }
    }
    // Tote NPCs
    final deadIds = <String>{...?cv?.deadNpcs};
    for (final n in w?.npcs ?? const <NpcView>[]) {
      if (!n.alive) deadIds.add(n.id);
    }
    final npcPos = {for (final n in w?.npcs ?? const <NpcView>[]) n.id: n};
    for (final id in deadIds) {
      final sus = s.suspectById[id];
      if (sus == null) continue;
      final tr = _tracks['n:$id'];
      final nv = npcPos[id];
      final x = tr?.x ?? nv?.x ?? sus.x + 0.5, y = tr?.y ?? nv?.y ?? sus.y + 0.5;
      if (!cull.contains(Iso.toScreen(x, y))) continue;
      _fig.lying(c, x, y, FigureLook.fromLook(sus.look), rot: 2.2 + (id.length % 3) * 0.7, scale: 1.25);
    }
    // Niedergeschlagene Detektive
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      if (d.life != LifeState.downed) continue;
      final isMe = d.id == session.playerId;
      final tr = _tracks['d:${d.id}'];
      final x = isMe ? _px : (tr?.x ?? d.x), y = isMe ? _py : (tr?.y ?? d.y);
      if (!cull.contains(Iso.toScreen(x, y))) continue;
      final pulse = 0.5 + 0.5 * math.sin(_time * 5);
      _fig.lying(
        c,
        x,
        y,
        FigureLook.detective(d.coat, d.hat, d.id),
        rot: 0.9,
        scale: 1.25,
        glow: withAlpha(_pal.danger, 0.35 + 0.35 * pulse),
      );
    }
    // Spuren des Schattens
    for (final it in cv?.items ?? const <ItemView>[]) {
      if (it.type != 'trace') continue;
      if (!cull.contains(Iso.toScreen(it.x, it.y))) continue;
      _markers!.traceGround(c, it.x, it.y, _time, it.id.hashCode % 7);
    }
    // Zielring
    final tp = _targetPos;
    final tg = target.value;
    if (tp != null && tg != null && !tg.isCancel) {
      _markers!.targetRing(c, tp.dx, tp.dy, _time);
    }
  }

  void _renderSorted(Canvas c, StaticScene scene, CaseView? cv, Rect cull) {
    final s = scene.scenario;
    final w = _world;
    final items = <(double, int, void Function())>[];
    // Verdeckungsrechteck des eigenen Spielers
    Rect? meRect;
    double meDepth = 0;
    if (_hasPos) {
      final o = Iso.toScreen(_px, _py);
      meRect = Rect.fromLTRB(o.dx - 13, o.dy - 58, o.dx + 13, o.dy + 2);
      meDepth = _px + _py;
    }
    final fade = math.min(1.0, _lastDt * 10);
    final cutK = math.min(1.0, _lastDt * 7);
    final room = _playerRoom;
    for (final d in scene.drawables) {
      if (!d.bounds.overlaps(cull)) continue;
      if (d.lowPicture != null) {
        final want = room != null && d.backRooms.contains(room) ? 1.0 : 0.0;
        d.cut += (want - d.cut) * cutK;
        if ((d.cut - want).abs() < 0.01) d.cut = want;
      }
      var targetAlpha = 1.0;
      if (d.tall && d.cut < 0.5 && meRect != null && d.depth > meDepth + 0.05 && d.occludes(meRect)) targetAlpha = 0.32;
      d.alpha += (targetAlpha - d.alpha) * fade;
      if ((d.alpha - targetAlpha).abs() < 0.01) d.alpha = targetAlpha;
      items.add((d.depth, 0, () => _drawStatic(c, d, scene)));
    }
    // Hotspots
    for (final e in cv?.hotspots.entries ?? const <MapEntry<String, String>>[]) {
      final h = s.hotspotById[e.key];
      if (h == null) continue;
      if (_nebelSicht(h.x + 0.5, h.y + 0.5) < 0.5) continue;
      final prop = scene.propAt[Pt(h.x, h.y)];
      final z = prop != null ? PropPainter.topZ(prop.prop!) + 0.22 : 0.42;
      final o = Iso.toScreen(h.x + 0.5, h.y + 0.5, z);
      if (!cull.contains(o)) continue;
      final seed = h.id.hashCode % 13;
      items.add((
        h.x + h.y + 1.0 + (prop != null ? 0.01 : 0),
        1,
        () => _markers!.hotspot(c, o, e.value, h.kind, _time, seed),
      ));
    }
    // Freiwillige Funkelstellen der Szene (offene Abstecher): kühles Funkeln,
    // damit sie nicht mit den goldenen Hotspots der Entscheidung verwechselt werden.
    final glanz = session is SzenenGlanz ? (session as SzenenGlanz).glanzpunkte : const <SzenenGlanzPunkt>[];
    for (final g in glanz) {
      if (_nebelSicht(g.x, g.y) < 0.5) continue;
      final o = Iso.toScreen(g.x, g.y, 0.42);
      if (!cull.contains(o)) continue;
      final seed = g.id.hashCode % 13;
      items.add((g.x + g.y + 1.0, 1, () => _markers!.hotspot(c, o, 'fresh', 'lab', _time, seed)));
    }
    // Items (Spuren: nur der Rauchfaden steht im Raum)
    for (final it in cv?.items ?? const <ItemView>[]) {
      if (it.type == 'trace') {
        if (cull.contains(Iso.toScreen(it.x, it.y))) {
          items.add((it.x + it.y, 1, () => _markers!.traceSmoke(c, it.x, it.y, _time, it.id.hashCode % 7)));
        }
        continue;
      }
      final o = Iso.toScreen(it.x, it.y);
      if (!cull.contains(o)) continue;
      final seed = it.id.hashCode % 11;
      items.add((it.x + it.y, 1, () => _markers!.item(c, o, it.type, _time, seed)));
    }
    // NPCs
    final deadIds = <String>{...?cv?.deadNpcs};
    for (final n in w?.npcs ?? const <NpcView>[]) {
      if (!n.alive || deadIds.contains(n.id)) continue;
      final sus = s.suspectById[n.id];
      final tr = _tracks['n:${n.id}'];
      if (tr == null) continue;
      final o = Iso.toScreen(tr.x, tr.y);
      if (!cull.contains(o)) continue;
      if (_nebelSicht(tr.x, tr.y) < 0.02) continue;
      final look = sus != null ? FigureLook.fromLook(sus.look) : FigureLook.fromLook(const LookDef());
      final ruhe = _ext?.ruheAnimation == true && tr.move < 0.3 ? _time * (1.1 + (n.id.hashCode % 7) * 0.08) + n.id.hashCode % 13 : 0.0;
      final (tat, grad, tz) = ruhe == 0 ? (Taetigkeit.keine, 0.0, 0.0) : _npcTaetigkeit(n.id, tr.x, tr.y, tr.move);
      final blick = tat == Taetigkeit.umsehen ? tr.facing + math.sin(tz * 0.6) * 0.7 * grad : tr.facing;
      items.add((
        tr.x + tr.y,
        2,
        () => _fig.standing(c, o, look,
            facing: blick, walk: tr.walk, moveAmt: tr.move, ruhe: ruhe, taetigkeit: tat, taetigkeitsGrad: grad, taetigkeitsZeit: tz),
      ));
    }
    // Detektive
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      if (d.life == LifeState.downed) continue;
      final isMe = d.id == session.playerId;
      if (d.hidden && !isMe) continue;
      final tr = _tracks['d:${d.id}'];
      if (!isMe && tr == null) continue;
      if (isMe && _ext?.kamera != null) continue;
      final x = isMe ? _px : tr!.x, y = isMe ? _py : tr!.y;
      final o = Iso.toScreen(x, y);
      if (!cull.contains(o)) continue;
      final eigenesAussehen = isMe ? _ext?.detektivAussehen : null;
      final look = eigenesAussehen != null ? FigureLook.fromLook(eigenesAussehen) : FigureLook.detective(d.coat, d.hat, d.id);
      final facing = isMe ? _pf : tr!.facing;
      final walk = isMe ? _walk : tr!.walk;
      final move = isMe ? _moveAmt : tr!.move;
      final ghost = d.life == LifeState.ghost;
      items.add((
        x + y,
        2,
        () => _drawDetective(c, o, look, facing, walk, move, ghost: ghost, hidden: d.hidden, isMe: isMe),
      ));
    }
    // Schatten
    final sh = w?.shadow;
    final st = _tracks['shadow'];
    if (sh != null && st != null) {
      final o = Iso.toScreen(st.x, st.y);
      if (cull.contains(o)) {
        final alpha = sh.mode == 'flee' ? 0.3 + 0.15 * math.sin(_time * 9) : 1.0;
        items.add((
          st.x + st.y,
          2,
          () {
            _drawSmoke(c, alpha);
            _fig.shadowFigure(c, o, _time, facing: st.facing, mode: sh.mode, alpha: alpha);
          },
        ));
      }
    }
    items.sort((a, b) {
      final r = a.$1.compareTo(b.$1);
      return r != 0 ? r : a.$2.compareTo(b.$2);
    });
    for (final it in items) {
      it.$3();
    }
  }

  void _drawStatic(Canvas c, StaticDrawable d, StaticScene scene) {
    final pic = d.picture;
    if (pic == null) return;
    final faded = d.alpha < 0.99;
    if (faded) {
      c.saveLayer(d.bounds, Paint()..color = Color.fromRGBO(0, 0, 0, d.alpha));
    }
    final low = d.lowPicture;
    if (low != null && d.cut > 0.01) {
      c.drawPicture(low);
      if (d.cut < 0.99) {
        c.saveLayer(d.bounds, Paint()..color = Color.fromRGBO(0, 0, 0, 1 - d.cut));
        c.drawPicture(pic);
        c.restore();
      }
    } else {
      c.drawPicture(pic);
    }
    final p = d.prop;
    if (p != null && PropPainter.dynamicTypes.contains(p.type)) {
      scene.propPainter.paintDynamic(c, p, _time, east: d.east, night: _phase == Phase.night ? 1 : 0);
    }
    final tuer = d.door;
    if (tuer != null && !tuer.locked) {
      final hoch = tuer.tall ? kDoorTop : 0.6;
      final hoehe = hoch + (0.55 - hoch) * d.cut.clamp(0.0, 1.0);
      scene.wallPainter.paintDoorLeaf(c, tuer, _tueren[Pt(d.x, d.y)]?.winkel ?? 0.32, hoehe);
    }
    final wall = d.wall;
    if (wall != null && wall.hasWindowFace && d.cut < 0.5) {
      scene.wallPainter.paintWindowWeather(c, wall, scene.scenario.theme.weather, _time, _flash);
    }
    if (faded) c.restore();
  }

  void _drawDetective(
    Canvas c,
    Offset o,
    FigureLook look,
    double facing,
    double walk,
    double move, {
    required bool ghost,
    required bool hidden,
    required bool isMe,
  }) {
    if (isMe && !ghost && !hidden) {
      // dezenter Ring unter dem eigenen Detektiv
      c.save();
      c.translate(o.dx, o.dy);
      Iso.applyGround(c);
      c.drawCircle(
        Offset.zero,
        0.36,
        Paint()
          ..color = withAlpha(_pal.accent, 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.035,
      );
      c.restore();
    }
    if (ghost) {
      final float = math.sin(_time * 2.2) * 3 - 6;
      final rect = Rect.fromLTRB(o.dx - 30, o.dy - 90, o.dx + 30, o.dy + 10);
      c.saveLayer(
        rect,
        Paint()
          ..colorFilter = const ColorFilter.matrix([
            0.25, 0.25, 0.25, 0, 30, //
            0.3, 0.3, 0.3, 0, 50,
            0.35, 0.35, 0.35, 0, 90,
            0, 0, 0, 0.5, 0,
          ]),
      );
      c.drawCircle(
        o.translate(0, -30 + float),
        26,
        Paint()
          ..shader = Gradient.radial(o.translate(0, -30 + float), 26, [
            const Color(0x557FA8FF),
            const Color(0x007FA8FF),
          ]),
      );
      _fig.standing(c, o.translate(0, float), look, facing: facing, walk: walk, moveAmt: move * 0.3, ghost: true);
      c.restore();
      return;
    }
    if (hidden) {
      final rect = Rect.fromLTRB(o.dx - 30, o.dy - 80, o.dx + 30, o.dy + 10);
      c.saveLayer(rect, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.32));
      _fig.standing(c, o, look, facing: facing, walk: walk, moveAmt: 0);
      c.restore();
      return;
    }
    final pose = isMe ? _fuehrung?.figurenPose : null;
    _fig.standing(c, o, look, facing: facing, walk: walk, moveAmt: move,
      suchen: pose == SzenenPose.suchen, befragen: pose == SzenenPose.befragen,
      handlungsZeit: _fuehrung?.bewegungReduziert == true ? 0 : _time,
    );
  }

  void _drawSmoke(Canvas c, double alpha) {
    final p = Paint();
    for (final s in _smoke) {
      final k = s.life / s.max;
      p.color = withAlpha(const Color(0xFF0A0812), (1 - k) * 0.55 * alpha);
      c.drawCircle(Offset(s.x, s.y), s.r, p);
    }
  }

  List<SceneLight> _lights(LightMode mode) {
    if (mode == LightMode.day) return const [];
    final out = <SceneLight>[];
    final w = _world;
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      final isMe = d.id == session.playerId;
      if (d.hidden && !isMe) continue;
      final tr = _tracks['d:${d.id}'];
      if (!isMe && tr == null) continue;
      final x = isMe ? _px : tr!.x, y = isMe ? _py : tr!.y;
      final f = isMe ? _pf : tr!.facing;
      if (mode == LightMode.council) {
        out.add(SceneLight(x, y, 5.5));
        continue;
      }
      switch (d.life) {
        case LifeState.alive:
          if (d.hidden) {
            out.add(SceneLight(x, y, 1.6, strength: 0.8));
          } else {
            final r = Tuning.nightLightRadius * _effectMul(d, (m) => m.light);
            out.add(SceneLight(x, y, math.max(0.8, r), cone: f));
          }
        case LifeState.downed:
          out.add(SceneLight(x, y, 1.3, strength: 0.7));
        case LifeState.ghost:
          if (isMe) out.add(SceneLight(x, y, 3.2, strength: 0.85));
      }
    }
    for (final lp in _localPings) {
      out.add(SceneLight(lp.x, lp.y, 1.0 * (1 - lp.age / 1.6), strength: 0.6));
    }
    return out;
  }

  List<GlowLight> _glows(StaticScene scene, Rect cull, double t) {
    final out = <GlowLight>[];
    for (final p in scene.lightProps) {
      final o = Iso.toScreen(p.x + 0.5, p.y + 0.5);
      if (!cull.inflate(200).contains(o)) continue;
      final l = scene.propPainter.light(p);
      if (l == null) continue;
      final seed = p.x * 3 + p.y * 7;
      final fl = 1 - l.flicker * 0.25 * (0.5 + 0.5 * math.sin(t * 9 + seed) * math.sin(t * 5.3 + seed * 2));
      out.add(GlowLight(p.x + 0.5, p.y + 0.5, l.z, l.radius * fl, l.color, fl));
    }
    for (final g in scene.kulisse?.lichter ?? const <GlowLight>[]) {
      if (cull.inflate(200).contains(Iso.toScreen(g.x, g.y))) out.add(g);
    }
    return out;
  }

  void _renderPostLight(Canvas c, StaticScene scene, WorldSnapshot? w, CaseView? cv, Rect cull) {
    if (_ext?.kleineEffekte == true && _fuehrung?.bewegungReduziert != true) _lichtStaub(c, scene, cull);
    _zeichneLeuchtzeichen(c);
    if (_teilchen.isNotEmpty) _zeichneKleineEffekte(c);
    // Augen des Schattens
    final sh = w?.shadow;
    final st = _tracks['shadow'];
    if (sh != null && st != null) {
      final o = Iso.toScreen(st.x, st.y);
      if (cull.contains(o) &&
          !_occluded(scene, Rect.fromCenter(center: o.translate(0, -51), width: 10, height: 6), st.x + st.y)) {
        final alpha = sh.mode == 'flee' ? 0.35 : 1.0;
        _fig.shadowEyes(c, o, _time, facing: st.facing, mode: sh.mode, alpha: alpha);
      }
    }
    // Glimmen der Spuren (nachts, wenn nicht verdeckt)
    if (_phase == Phase.night) {
      for (final it in cv?.items ?? const <ItemView>[]) {
        if (it.type != 'trace') continue;
        final o = Iso.toScreen(it.x, it.y);
        if (!cull.contains(o) || _occluded(scene, Rect.fromCenter(center: o, width: 8, height: 6), it.x + it.y)) {
          continue;
        }
        _markers!.traceGlow(c, it.x, it.y, _time, it.id.hashCode % 7);
      }
    }
    // Niedergeschlagene: roter Puls, auch im Dunkeln sichtbar
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      if (d.life != LifeState.downed) continue;
      final isMe = d.id == session.playerId;
      final tr = _tracks['d:${d.id}'];
      final x = isMe ? _px : (tr?.x ?? d.x), y = isMe ? _py : (tr?.y ?? d.y);
      final o = Iso.toScreen(x, y);
      if (!cull.contains(o)) continue;
      final ph = (_time * 0.8) % 1.0;
      c.save();
      c.translate(o.dx, o.dy);
      Iso.applyGround(c);
      c.drawCircle(
        Offset.zero,
        0.3 + ph * 0.6,
        Paint()
          ..color = withAlpha(_pal.danger, (1 - ph) * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.05,
      );
      c.restore();
    }
    // Pings
    final recvAge = _time - _worldRecvT;
    for (final sg in w?.signals ?? const <SignalView>[]) {
      if (sg.kind != 'ping' || sg.x == null || sg.y == null) continue;
      final age = sg.ageMs / 1000 + recvAge;
      const life = Tuning.signalLifetimeMs / 1000;
      if (age > life) continue;
      if (!cull.contains(Iso.toScreen(sg.x!, sg.y!))) continue;
      _markers!.ping(c, sg.x!, sg.y!, age, life, _coatOf(sg.by) ?? _pal.accent);
    }
    for (final lp in _localPings) {
      final col = lp.ok ? _pal.accent : const Color(0xFF8A8A8A);
      c.save();
      final o = Iso.toScreen(lp.x, lp.y);
      c.translate(o.dx, o.dy);
      Iso.applyGround(c);
      final k = lp.age / 1.6;
      c.drawCircle(
        Offset.zero,
        0.2 + k * 1.1,
        Paint()
          ..color = withAlpha(col, (1 - k) * 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.06,
      );
      c.restore();
    }
  }

  /// Wird [r] (Bildschirm) von einem hohen statischen Objekt vor [depth] verdeckt?
  bool _occluded(StaticScene scene, Rect r, double depth) {
    for (final d in scene.drawables) {
      if (!d.tall || d.cut > 0.5 || d.depth <= depth + 0.05) continue;
      if (d.occludes(r)) return true;
    }
    return false;
  }

  Color? _coatOf(String id) {
    final d = _world?.detective(id);
    if (d == null) return null;
    return parseHex(detectiveCoats[d.coat.abs() % detectiveCoats.length]);
  }

  void _renderOverlays(Canvas c, StaticScene scene, WorldSnapshot? w, MarkerPainter m) {
    final headPx = 54.0 * _zoom;
    // Namensschilder und Kanal-Ringe; merkt sich die Oberkante für Sprechblasen.
    final stackTop = <String, Offset>{};
    final placed = <Rect>[];
    // Zielbeschriftung zuerst vermessen, damit Namensschilder darüber ausweichen
    // statt vom Banner verdeckt zu werden (gezeichnet wird sie zuletzt).
    final tg = target.value;
    final tp = _targetPos;
    Offset? targetAnchor;
    if (tg != null && tp != null && !tg.isCancel && tg.kind != 'revive' && tg.name.isNotEmpty) {
      final figur = tg.kind == 'npc' || tg.figur;
      final z = figur ? 0.0 : tg.z;
      final a = _toView(Iso.toScreen(tp.dx, tp.dy, z));
      targetAnchor = a.translate(0, figur ? -headPx - 10 : -18 * _zoom - 10);
      placed.add(m.targetLabelRect(targetAnchor, tg.name).inflate(1));
    }
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      final isMe = d.id == session.playerId;
      if (d.hidden && !isMe) continue;
      final tr = _tracks['d:${d.id}'];
      if (!isMe && tr == null) continue;
      final x = isMe ? _px : tr!.x, y = isMe ? _py : tr!.y;
      final feet = _toView(Iso.toScreen(x, y));
      if (feet.dx < -60 || feet.dy < -60 || feet.dx > size.x + 60 || feet.dy > size.y + 100) continue;
      final down = d.life == LifeState.downed;
      final ghostLift = d.life == LifeState.ghost ? 8 * _zoom : 0.0;
      var top = down
          ? feet.translate(0, -16 * _zoom)
          : feet.translate(0, -headPx - (d.hat == 'top' ? 12 : 4) * _zoom - ghostLift);
      if (!isMe) {
        final col = parseHex(detectiveCoats[d.coat.abs() % detectiveCoats.length]) ?? _pal.accent;
        // Überlappende Schilder nach oben schieben.
        var anchor = top.translate(0, -4);
        for (var guard = 0; guard < 4; guard++) {
          final r = Rect.fromCenter(center: anchor.translate(0, -9), width: 70, height: 18);
          final hit = placed.where((p) => p.overlaps(r)).toList();
          if (hit.isEmpty) break;
          anchor = Offset(anchor.dx, hit.map((h) => h.top).reduce(math.min) - 2);
        }
        placed.add(Rect.fromCenter(center: anchor.translate(0, -9), width: 70, height: 18));
        m.nameTag(c, anchor, d.name, col, alpha: d.life == LifeState.ghost ? 0.5 : (d.connected ? 1 : 0.55));
        top = Offset(top.dx, anchor.dy - 20);
      }
      final ch = d.channel;
      if (ch != null) {
        m.channelRing(c, top.translate(0, -12), ch.progress, _pal.accent);
        top = top.translate(0, -26);
      }
      stackTop[d.id] = top;
    }
    // Sprechende NPCs
    for (final n in w?.npcs ?? const <NpcView>[]) {
      if (n.talkingTo == null || !n.alive) continue;
      final tr = _tracks['n:${n.id}'];
      if (tr == null) continue;
      final top = _toView(Iso.toScreen(tr.x, tr.y)).translate(0, -headPx - 6 * _zoom);
      m.bubble(c, top, 'quick', '...', 0.9, 0.75);
    }
    // Emotes / Schnellchat
    final recvAge = _time - _worldRecvT;
    for (final sg in w?.signals ?? const <SignalView>[]) {
      if (sg.kind != 'emote' && sg.kind != 'quick') continue;
      final age = sg.ageMs / 1000 + recvAge;
      const life = Tuning.signalLifetimeMs / 1000;
      if (age > life) continue;
      final top = stackTop[sg.by];
      if (top == null) continue;
      var anchor = top.translate(0, -2);
      for (var guard = 0; guard < 4; guard++) {
        final r = Rect.fromLTRB(anchor.dx - 18, anchor.dy - 36, anchor.dx + 18, anchor.dy);
        final hit = placed.where((p) => p.overlaps(r)).toList();
        if (hit.isEmpty) break;
        anchor = Offset(anchor.dx, hit.map((h) => h.top).reduce(math.min) - 2);
      }
      placed.add(Rect.fromLTRB(anchor.dx - 18, anchor.dy - 36, anchor.dx + 18, anchor.dy));
      final alpha = (life - age).clamp(0.0, 1.0);
      final pop = age < 0.25 ? _easeOutBack(age / 0.25) : 1.0;
      m.bubble(c, anchor, sg.kind, sg.value, alpha, pop);
    }
    // Detektivklasse (A-055): Gesprächsmarker, Stimmung und Gerüchte über den Köpfen
    if (_klasse case final k? when _hasPos) {
      _klassenEbene?.ueberKoepfen(
        c,
        k,
        figuren: [
          for (final n in w?.npcs ?? const <NpcView>[])
            if (_tracks['n:${n.id}'] case final tr? when n.alive && _nebelSicht(tr.x, tr.y) >= 0.5)
              (id: n.id, kopf: _toView(Iso.toScreen(tr.x, tr.y)).translate(0, -headPx - 6 * _zoom), abstand: dist(tr.x, tr.y, _px, _py)),
        ],
        gespraech: session is SzenenGespraech ? (session as SzenenGespraech).gespraechsGeste : null,
        t: _time,
        dt: _lastDt,
      );
    }
    // Zielbeschriftung
    if (tg != null && targetAnchor != null) m.targetLabel(c, targetAnchor, tg.name, 1);
  }

  double _easeOutBack(double x) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2);
  }
}
