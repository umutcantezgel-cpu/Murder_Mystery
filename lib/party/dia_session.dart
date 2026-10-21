import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' hide KartenQuelle;

import '../game/szenen_erweiterung.dart';
import '../game/welt_szene.dart';
import 'daten.dart';
import 'karten_quelle.dart';

/// Die Szene der Diashow zur Einleitung (Langer Abend M4): eine Kamerafahrt
/// über den Keller in der Engine, ohne Steuerung und ohne Ermittlung. Jedes
/// Bild ([Dia], `content/welt/<akte>/diashow.json`) stellt seine Figuren an
/// den Ort, auf den die Kamera schaut, setzt das Licht seiner Stimmung und
/// fährt langsam (heran und zurück übernimmt die Ansicht, der Schwenk liegt
/// hier). Zwischen zwei Bildern fährt die Kamera weich zum neuen Ort.
///
/// Die Szene braucht nur die Akte ([PartyDaten]), nie eine Sitzung: Jeder Gast
/// rendert dieselben Bilder selbst, der Raum schickt nur die Nummer. Keine
/// Hotspots, kein Glanz, kein Nebel; im Bild stehen nur die Figuren des Bildes
/// (der Detektiv kommt als Fotoabzug dazu, `diashow_ansicht.dart`).
///
/// Der unsichtbare Detektiv steht immer am Ziel der Kamera (M7b): Der Renderer
/// schneidet die Wände vor dem Raum des Detektivs auf, also vor dem Raum, auf
/// den das Bild schaut. Sonst verdeckt etwa die Wand vor dem Vorratsraum Herrn
/// Schneider in Bild 2.
class DiaSession extends WeltSzene implements GefuehrteSzene {
  DiaSession(PartyDaten daten, this.diashow, {int nr = 0, this.testUhr}) : super(daten, _Einleitung()) {
    _start = Offset(detektivX, detektivY);
    _zeige(nr);
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => zeigeWelt());
  }

  final Diashow diashow;

  /// Ersatz für die Wanduhr der Fahrt (Sekunden seit Beginn des Bildes), für Tests
  /// und den Kontaktbogen.
  final double Function()? testUhr;

  late final Timer _timer;

  /// Wo der Detektiv anfangs steht (sein Ermittlungsort).
  late final Offset _start;
  final Stopwatch _seit = Stopwatch()..start();
  int _nr = 0;
  List<({String npc, double x, double y, bool liegt})> _stand = const [];

  /// Dauer einer langsamen Fahrt (Schwenk, heran, zurück).
  static const fahrtSekunden = 16.0;

  /// Dunkelheit bei Notlicht ([DiaStimmung.notlicht]); der Stromausfall hat 0,8.
  static const notlichtDunkel = 0.6;

  /// Laufendes Bild (ab 0).
  int get nr => _nr;

  Dia get dia => diashow.dias[_nr];

  /// Zeigt Bild [nr]; die Fahrt beginnt von vorn.
  void zeige(int nr) {
    if (entsorgt) return;
    final neu = nr.clamp(0, diashow.dias.length - 1);
    if (neu == _nr && _stand.isNotEmpty) return;
    _zeige(neu);
  }

  void _zeige(int nr) {
    _nr = nr.clamp(0, diashow.dias.length - 1);
    _seit
      ..reset()
      ..start();
    _stand = _stellen(dia);
    final z = ziel;
    stelleDetektiv(z.dx, z.dy);
    zeigeFall();
  }

  /// Fortschritt der langsamen Fahrt dieses Bildes (0 bis 1); mit „Bewegung
  /// reduzieren“ immer 0.
  double get fahrt {
    if (bewegungReduziert) return 0;
    final s = testUhr?.call() ?? _seit.elapsedMicroseconds / 1e6;
    return (s / fahrtSekunden).clamp(0.0, 1.0);
  }

  /// Ziel der Kamera in Kachelkoordinaten: der Ort oder die Mitte des Raums;
  /// ohne beides der Ermittlungsort des Detektivs.
  Offset get ziel {
    final k = dia.kamera;
    final g = daten.kanon.graph;
    if (k.ort case final ort?) {
      if (g.orte[ort] case final o?) return Offset(o.x, o.y);
    }
    if (k.raum case final raum?) {
      if (g.raeume[raum] case final r?) return Offset(r.x + r.b / 2, r.y + r.l / 2);
    }
    return _start;
  }

  /// Stellt die Figuren eines Bildes: die erste genau aufs Ziel (oder den
  /// nächsten freien Fleck), die übrigen im Kreis darum, nur auf freien Boden
  /// und nie auf eine andere. Der Detektiv steht nicht im Bild (er hat keine
  /// Figur im Szenario); die Ansicht zeigt ihn als Fotoabzug.
  List<({String npc, double x, double y, bool liegt})> _stellen(Dia d) {
    final z = ziel;
    final aus = <({String npc, double x, double y, bool liegt})>[];
    bool frei(double x, double y) =>
        raster.canStand(x, y, Tuning.playerRadius) && aus.every((a) => (Offset(a.x, a.y) - Offset(x, y)).distance > 0.75);
    var winkel = 0;
    for (final f in d.figuren) {
      final npc = daten.npcKennung[f];
      if (npc == null) continue;
      var stelle = frei(z.dx, z.dy) ? z : null;
      for (var r = 1; stelle == null && r <= 4; r++) {
        for (var i = 0; i < 8 && stelle == null; i++) {
          final a = (winkel + i) * math.pi / 4 + 0.4;
          final p = z + Offset(math.cos(a), math.sin(a)) * (r * 0.9);
          if (frei(p.dx, p.dy)) stelle = p;
        }
      }
      winkel += 3;
      final s = stelle ?? z;
      aus.add((npc: npc, x: s.dx, y: s.dy, liegt: d.liegt.contains(f)));
    }
    return aus;
  }

  @override
  bool get zeigtErmittlung => false;

  @override
  String get detektivName => '';

  @override
  ({List<NpcView> npcs, Set<String> gehend}) figurenAnsicht() => (
        npcs: [for (final s in _stand) NpcView(id: s.npc, x: s.x, y: s.y, alive: !s.liegt)],
        gehend: const <String>{},
      );

  /// Fester Kamerapunkt (die eigene Figur bleibt unsichtbar). Der Schwenk
  /// gleitet quer durchs Bild; die Engine folgt dem Punkt weich.
  @override
  Offset? get kamera {
    final z = ziel;
    if (dia.kamera.fahrt != DiaFahrt.schwenk) return z;
    final v = (fahrt - 0.5) * 2.4;
    return z + Offset(v * 0.7, -v * 0.7);
  }

  static const _warm = Color(0xFFFFC27A);
  static const _kalt = Color(0xFFB8C6E0);
  static const _notlicht = Color(0xFFD6E2F5);

  /// Licht der Stimmung: warm und hell am Abend und im Rückblick, nach dem
  /// Knall dunkel mit dem grünen Notausgangsschild und einem schwachen Schein
  /// am Ort des Bildes (sonst wäre nichts zu sehen). Mit Notlicht ist es
  /// heller, und ein kalter Kegel von oben leuchtet den Ort des Bildes aus,
  /// dazu ein schwacher Schein von vorn auf die Figuren.
  @override
  SzenenLicht? get licht {
    final g = daten.kanon.graph;
    final z = ziel;
    final notausgang = [
      if (g.lichtquellen['licht_notausgang'] case final l?)
        if (g.orte[l.ort] case final o?) SzenenLichtpunkt(o.x, o.y, z: 1.8, radius: l.radius, farbe: WeltSzene.lichtFarbe(l.farbe ?? '#3CFF8A')),
    ];
    return switch (dia.stimmung) {
      DiaStimmung.feier || DiaStimmung.rueckblick => SzenenLicht(
          dunkel: dia.stimmung == DiaStimmung.rueckblick ? 0.36 : 0.3,
          taschenlampe: false,
          helleRaeume: g.raeume.keys.toSet(),
          punkte: [
            ...dekoKerzen,
            SzenenLichtpunkt(z.dx, z.dy, z: 1.6, radius: 3.2, farbe: _warm),
          ],
        ),
      DiaStimmung.stromausfall => SzenenLicht(
          dunkel: 0.8,
          taschenlampe: false,
          punkte: [
            ...notausgang,
            SzenenLichtpunkt(z.dx, z.dy, z: 1.4, radius: 2.6, farbe: _kalt, flackern: bewegungReduziert ? 0 : 0.15),
          ],
        ),
      DiaStimmung.notlicht => SzenenLicht(
          dunkel: notlichtDunkel,
          taschenlampe: false,
          punkte: [
            ...notausgang,
            SzenenLichtpunkt(z.dx, z.dy, z: 2.2, radius: 4.2, farbe: _notlicht, flackern: bewegungReduziert ? 0 : 0.06),
            SzenenLichtpunkt(z.dx + 1.2, z.dy + 1.2, z: 1.2, radius: 2.4, farbe: _kalt),
          ],
        ),
    };
  }

  // ---------------------------------------------------------------------------
  // GameSession: keine Eingabe

  @override
  void move(double x, double y, double facing) {}

  @override
  void send(Command command) {}

  @override
  String? npcAktion(String npcId) => null;

  @override
  bool npcUntersuchen(String npcId) => false;

  @override
  String? hotspotAktion(String hotspotId) => null;

  // ---------------------------------------------------------------------------
  // GefuehrteSzene: Ohne Eingabe; mit „Bewegung reduzieren“ springt die Kamera.

  @override
  bool get eingabeGesperrt => true;

  @override
  SzenenPose? get figurenPose => null;

  @override
  double get posenFortschritt => 0;

  @override
  Offset? get handlungsZiel => null;

  @override
  void szenenSchritt(double sekunden) {}

  @override
  Future<void> dispose() async {
    if (entsorgt) return;
    _timer.cancel();
    await super.dispose();
  }
}

/// Die Einleitung als Quelle der Karte: keine Runde, keine Entscheidung, kein Zug.
class _Einleitung implements KartenQuelle {
  @override
  PartyPhase get phase => PartyPhase.intro;

  @override
  int get runde => 0;

  @override
  Entscheidung? get laufendeEntscheidung => null;

  @override
  Map<String, String> get gewaehlt => const {};

  @override
  RundenZug? get zug => null;

  @override
  List<AbstecherOrt> get abstecherOffen => const [];
}
