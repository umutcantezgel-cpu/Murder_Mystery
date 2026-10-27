import 'dart:async';
import 'dart:ui';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' hide KartenQuelle;

import '../../game/szenen_erweiterung.dart';
import '../../game/welt_szene.dart';
import '../../party/daten.dart';
import '../../party/karten_aktion.dart';
import '../../party/karten_quelle.dart';
import 'ansicht.dart';

/// Was die Karte eines Gastes vom Abend weiß (Langer Abend M3): alles aus der
/// Ansicht des Raums, der Positivliste dieses Geräts. Phase, Runde, Wahl bisher,
/// die offene Entscheidung, der laufende Zug und die offenen Abstecher; nie
/// Pfad, Salz oder die richtige Option.
class AnsichtsKartenQuelle implements KartenQuelle {
  AnsichtsKartenQuelle(this.daten, this.ansicht);

  final PartyDaten daten;

  /// Die jüngste Ansicht des Raums für dieses Gerät.
  final Map<String, Object?> Function() ansicht;

  /// Abstecher, die dieses Gerät schon gesehen hat: Läuft einer, steht er nicht
  /// mehr unter den offenen, sein Ort gilt aber für den Weg.
  final Map<String, AbstecherOrt> _bekannt = {};

  Map<String, Object?> get _v => ansicht();

  @override
  PartyPhase get phase => PartyPhase.values.where((p) => p.name == _v['phase']).firstOrNull ?? PartyPhase.titel;

  @override
  int get runde => jZahl(_v['runde']);

  @override
  Entscheidung? get laufendeEntscheidung {
    final e = _v['entscheidung'];
    if (e is! Map || _v['zug'] is Map) return null;
    try {
      return daten.karte.ermittlung.entscheidung(jText(e['id']));
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, String> get gewaehlt => {for (final e in jMap(_v['gewaehlt']).entries) if (e.value is String) e.key: e.value as String};

  @override
  RundenZug? get zug {
    final z = _v['zug'];
    if (z is! Map) return null;
    final phase = RundenZugPhase.values.where((p) => p.name == z['phase']).firstOrNull;
    if (phase == null) return null;
    return RundenZug.ansicht(
      id: jText(z['id']),
      option: z['option'] is String ? z['option'] as String : null,
      suche: z['suche'] == true,
      phase: phase,
      aktion: jZahl(z['aktion']),
      ruf: Tischruf.values.where((r) => r.name == z['ruf']).firstOrNull,
      abstecher: z['abstecher'] is String ? z['abstecher'] as String : null,
      // „Dein Moment“ (Finale §3.4): Tischwert, verwischte Spur und Kennzeichen des Fundes.
      tisch: z['tisch'] is int ? z['tisch'] as int : null,
      verwischt: z['verwischt'] == true,
      einfluss: _einflussFund(z['einfluss']),
    );
  }

  /// Kennzeichen des Fundes aus der Ansicht, sonst `null` (ohne Schicht oder unlesbar).
  static EinflussFund? _einflussFund(Object? j) {
    if (j is! Map) return null;
    try {
      return EinflussFund.ausJson(j.cast<String, Object?>());
    } on FormatException {
      return null;
    }
  }

  @override
  List<AbstecherOrt> get abstecherOffen => [
        for (final a in jMaps(_v['abstecher']))
          _bekannt[jText(a['id'])] = AbstecherOrt(id: jText(a['id']), ort: jText(a['ort']), name: jText(a['name']), erfolg: '', teilerfolg: '', pech: ''),
      ];

  /// Der Erkundungsort des laufenden Zugs, wenn dieses Gerät ihn gesehen hat.
  AbstecherOrt? get abstecherLaufend {
    abstecherOffen;
    final id = zug?.abstecher;
    return id == null ? null : _bekannt[id];
  }
}

/// Die Karte des Gast-Detektivs (Langer Abend M3), nur lesend: Sie zeigt den
/// Detektiv, alle Personen an ihren Ermittlungsorten, die Ziele der offenen
/// Entscheidung und funkelt am gewählten Ziel ([markiert]). Bestätigt der
/// Detektiv, läuft der Weg hier sichtbar ab; an seinem Ende meldet die Karte
/// [onAktionFertig] (der Raum nimmt `aktionFertig` vom Detektiv-Sitz an,
/// ersatzweise meldet der Gastgeber nach [KartenAktion.hoechstDauer]).
///
/// Keine Steuerung: Wahl, Würfel und Funde laufen über die Karten der
/// Gastseite. Die Klasse des Detektiv-Sitzes wirkt über [klasse] wie am Tisch.
class GastKarteSession extends WeltSzene implements GefuehrteSzene {
  GastKarteSession(PartyDaten daten, this._quelle, {required this.name, this.onAktionFertig, super.klasse}) : super(daten, _quelle) {
    zeigeFall();
    zeigeWelt();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => zeigeWelt());
  }

  final AnsichtsKartenQuelle _quelle;

  /// Name des Detektivs am Tisch (Namensschild).
  final String Function() name;

  /// Das Ende eines sichtbaren Wegs mit seiner Nummer.
  final void Function(int aktion)? onAktionFertig;

  late final Timer _timer;
  KartenAktion? _aktion;
  int? _aktionsNummer;
  int? _gemeldet;
  Offset? _aktionsZiel;

  /// Option der offenen Entscheidung, die der Detektiv gerade ansieht (noch
  /// nicht bestätigt); ihr Ziel funkelt und bleibt im Bild.
  String? markiert;

  /// Neue Ansicht des Raums: Ziele, Zug und Weg neu lesen.
  void ansichtGeaendert() => zeigeFall();

  // ------------------------------------------------------------ GefuehrteSzene

  @override
  bool get eingabeGesperrt => true;

  @override
  SzenenPose? get figurenPose {
    final a = _aktion;
    if (a == null) return null;
    return a.geht ? SzenenPose.gehen : a.suchen ? SzenenPose.suchen : SzenenPose.befragen;
  }

  @override
  double get posenFortschritt => _aktion?.posenFortschritt ?? 0;

  @override
  Offset? get handlungsZiel {
    final a = _aktion;
    if (a == null || a.geht) return null;
    return Offset(a.zielX, a.zielY);
  }

  void _synchronisiereAktion() {
    final z = _quelle.zug;
    if (z == null || z.phase != RundenZugPhase.aktion) {
      _aktion = null;
      _aktionsNummer = null;
      return;
    }
    if (_aktionsNummer == z.aktion) return;
    _aktionsNummer = z.aktion;
    final ziel = daten.karte.ziele[z.option];
    double zx = detektivX, zy = detektivY;
    String? raum = raster.roomAtPos(detektivX, detektivY)?.id;
    final ort = z.istAbstecher ? _quelle.abstecherLaufend : null;
    final stelle = ort == null ? null : daten.kanon.graph.orte[ort.ort];
    if (stelle != null) {
      zx = stelle.x;
      zy = stelle.y;
      raum = stelle.raum;
    } else if (ziel != null) {
      raum = ziel.raum;
      if (ziel.person case final person?) {
        final f = daten.karte.figuren.firstWhere((f) => f.id == person);
        zx = f.x;
        zy = f.y;
      } else {
        zx = ziel.x! + 0.5;
        zy = ziel.y! + 0.5;
      }
    }
    _aktion = raum == null
        ? null
        : KartenAktion.planen(
            raster: raster, startX: detektivX, startY: detektivY, facing: detektivBlick,
            zielX: zx, zielY: zy, raum: raum, suchen: z.suche, umweg: z.ruf == Tischruf.umweg,
            personen: [for (final f in daten.karte.figuren) (f.x, f.y)],
            tempo: tempoFaktor,
          );
    _aktionsZiel = Offset(zx, zy);
    if (bewegungReduziert) _aktion?.abkuerzen();
  }

  @override
  void szenenSchritt(double sekunden) {
    if (entsorgt) return;
    _synchronisiereAktion();
    final a = _aktion;
    final nr = _aktionsNummer;
    if (nr == null) return;
    // Ohne begehbaren Weg (oder unbekannten Ort) endet die Aktion sofort, nie eine blockierte Würfelbühne.
    if (a == null) {
      _melde(nr);
      return;
    }
    a.schritt(sekunden);
    detektivX = a.x;
    detektivY = a.y;
    detektivBlick = a.facing;
    zeigeWelt();
    if (a.fertig) _melde(nr);
  }

  void _melde(int nr) {
    if (_gemeldet == nr) return;
    _gemeldet = nr;
    onAktionFertig?.call(nr);
  }

  // --------------------------------------------------------------- WeltSzene

  @override
  Offset? get laufZiel => _aktionsZiel;

  @override
  String get detektivName => name();

  @override
  bool get detektivGeht => _aktion?.geht ?? false;

  @override
  ChannelView? get detektivKanal {
    final a = _aktion;
    if (a == null || a.geht) return null;
    return ChannelView(kind: a.suchen ? 'search' : 'talk', target: _quelle.zug?.option ?? _quelle.zug?.id ?? 'auftakt', progress: posenFortschritt);
  }

  @override
  bool sprichtMit(String figur) => figurenPose == SzenenPose.befragen && daten.karte.ziele[_quelle.zug?.option]?.person == figur;

  @override
  void vorDemZeigen() => _synchronisiereAktion();

  /// Das gewählte, noch nicht bestätigte Ziel funkelt wie ein offener Abstecher.
  @override
  List<SzenenGlanzPunkt> get glanzpunkte {
    final ziel = daten.karte.ziele[markiert];
    if (ziel == null || _quelle.zug != null) return super.glanzpunkte;
    final (x, y) = switch (ziel.person) {
      final p? => () {
          final f = daten.karte.figuren.firstWhere((f) => f.id == p);
          return (f.x, f.y);
        }(),
      _ => (ziel.x! + 0.5, ziel.y! + 0.5),
    };
    return [...super.glanzpunkte, SzenenGlanzPunkt('ziel:${ziel.option}', x, y)];
  }

  // ------------------------------------------------------------- GameSession

  @override
  void move(double x, double y, double facing) {}

  @override
  void send(Command command) {}

  @override
  Future<void> dispose() async {
    if (entsorgt) return;
    _timer.cancel();
    await super.dispose();
  }

  // ------------------------------------------------------ SzenenErweiterung

  @override
  String? npcAktion(String npcId) => null;

  @override
  bool npcUntersuchen(String npcId) => false;

  @override
  String? hotspotAktion(String hotspotId) => null;
}
