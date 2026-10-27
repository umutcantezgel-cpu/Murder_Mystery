import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show RundenUhr;

import '../../game/game_view.dart';
import '../../game/szenen_erweiterung.dart';
import '../../l10n/gen/app_localizations_de.dart';
import '../../l10n/lookup.dart';
import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../karten_quelle.dart';
import '../klasse_wirkung.dart';
import '../party_stil.dart';
import '../runden_uhr.dart';
import '../sitzung.dart';
import '../stand/befragung_stand.dart';
import '../streifzug_karte.dart';
import '../streifzug_steuerung.dart';
import 'befragung.dart';
import 'einfluss_teile.dart';
import 'karte.dart';
import 'moment.dart';
import 'spickzettel.dart';

final _de = LDe();

/// Texte des Streifzugs: die ARB der App, ohne Lokalisierung im Baum (Tests,
/// Werkzeuge) die deutsche Fassung.
L streifzugTexte(BuildContext context) => Localizations.of<L>(context, L) ?? _de;

/// Was der Streifzug vom Abend liest und wohin er meldet (Langer Abend M7b):
/// am Tisch und beim Gastgeber die Sitzung ([SitzungsStreifzug]), beim
/// Gast-Detektiv seine Ansicht des Raums (`gast_streifzug.dart`).
abstract class StreifzugAbend implements Listenable {
  /// Sitzung für Texte, Figuren und Befragungskarten.
  PartySitzung get sitzung;

  /// Bedienung dieses Geräts (Skript, Tests).
  StreifzugSteuerung get steuerung;

  PartyPhase get phase;
  int get runde;

  /// Uhrzeit der Runde im Spiel („00:30“): die Lage der Welt.
  String get uhrzeit;

  /// Ein Gerät mit Menschen am Tisch (nicht solo, nicht online): Spickzettel
  /// gehen verdeckt herum, und die freie Erkundung ist je Runde gedeckelt.
  bool get reihum;

  /// Name am Tisch zu einer Figur.
  String person(String figur);

  List<BefragungKarte> get befragungen;
  int get befragungenFrei;
  void befragen(String id, int frage);
  void befragungErledigt(String id);

  /// Die Tischgespräche der Runde (wer mit wem worüber, nie Stichpunkte).
  List<TischPaarung> get tisch;

  /// Befragung → Treffpunkt in dieser Runde.
  Map<String, String> treffpunkte(Erkundung erkundung);
  Set<String> get erkundet;
  bool get erkundungFrei;
  void erkunden(String ort);
  void treffen(String befragung);

  /// Stichpunkte eines Erkundungsorts an diesem Abend.
  List<String> erkundungsPunkte(ErkundungsOrt ort);

  /// Kennung der laufenden Entscheidung (sonst `null`).
  String? get entscheidung;

  /// Läuft gerade kein Zug, kein Vorschlag, kein Fund, kein Randgespräch?
  bool get ruhig;

  bool get kannWeiter;
  void weiter();

  /// Die Rundenuhr in voller Größe (Taschenuhr mit Knöpfen für den, der sie stellt).
  Widget uhr(BuildContext context);

  /// Die Rundenuhr zum Mitlesen (Restzeit), sonst `null`.
  RundenUhr? get rundenUhr;
  int Function() get jetzt;

  /// Der unveränderte Ablauf einer Entscheidung (am Tisch der Kartenbildschirm).
  Widget entscheidungsAblauf(BuildContext context);

  /// Woher die Karte im Keller die Ziele der laufenden Entscheidung kennt.
  KartenQuelle? get kartenQuelle;
  SzenenKlasse? klasse(BuildContext context);
  String get detektivName;

  /// Inhalt der Karte „Rundenstart“ (Erzähltext, Uhr); `null`: keine.
  Widget? rundenstart(BuildContext context);
}

/// Der Streifzug am Tisch und beim Gastgeber: alles aus der [PartySitzung].
/// Online meldet der Gastgeber Erkundung und Treffen dem Raum
/// (`GastgeberSitzung`); an einem Gerät bleibt beides kosmetisch.
class SitzungsStreifzug implements StreifzugAbend {
  SitzungsStreifzug(this.sitzung);

  @override
  final PartySitzung sitzung;
  PartySitzung get s => sitzung;

  @override
  void addListener(VoidCallback l) => s.addListener(l);
  @override
  void removeListener(VoidCallback l) => s.removeListener(l);

  @override
  StreifzugSteuerung get steuerung => s.streifzug;
  @override
  PartyPhase get phase => s.phase;
  @override
  int get runde => s.runde;
  @override
  String get uhrzeit => s.rundenUhrzeit;
  @override
  bool get reihum => !s.solo && !s.online;
  @override
  String person(String figur) => s.personAmTisch(figur);
  @override
  List<BefragungKarte> get befragungen => s.befragungen;
  @override
  int get befragungenFrei => s.befragungenFrei;
  @override
  void befragen(String id, int frage) => s.befragen(id, frage);
  @override
  void befragungErledigt(String id) => s.befragungErledigt(id);
  @override
  List<TischPaarung> get tisch => s.runde < 1 ? const [] : s.tisch(s.runde);
  @override
  Map<String, String> treffpunkte(Erkundung erkundung) => s.streifzugTreffpunkte(erkundung);
  @override
  Set<String> get erkundet => s.erkundet;
  @override
  bool get erkundungFrei => s.erkundungFrei;
  @override
  void erkunden(String ort) => s.erkunden(ort);
  @override
  void treffen(String befragung) => s.streifzugTreffen(befragung);
  @override
  List<String> erkundungsPunkte(ErkundungsOrt ort) => s.erkundungsPunkte(ort);
  @override
  String? get entscheidung => s.laufendeEntscheidung?.id;
  @override
  bool get ruhig => s.zug == null && s.vorschlag == null && s.letzterFund == null && s.gespraech == null;
  @override
  bool get kannWeiter => s.kannWeiter;
  @override
  void weiter() => s.weiter();
  @override
  Widget uhr(BuildContext context) => SitzungsUhr(sitzung: s, groesse: 240);
  @override
  RundenUhr? get rundenUhr => s.uhrInPhase ? s.uhr : null;
  @override
  int Function() get jetzt => s.abendzeit;
  @override
  Widget entscheidungsAblauf(BuildContext context) => KartenBildschirm(sitzung: s);
  @override
  KartenQuelle? get kartenQuelle => SitzungsKartenQuelle(s);
  @override
  SzenenKlasse? klasse(BuildContext context) => KlasseWirkung.diesesGeraets(context, s);
  @override
  String get detektivName => s.personAmTisch((s.kanon.figurenJson['detektiv'] as Map)['id'] as String);
  @override
  Widget? rundenstart(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SitzungsUhr(sitzung: s, groesse: 240),
          const SizedBox(height: 20),
          ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
          // „Dein Moment“ in den Gesprächen: reihum die Liste, online der letzte Aufruf.
          if (s.einfluss && s.phase == PartyPhase.gespraeche) ...[
            const SizedBox(height: 20),
            s.online ? MomentAufruf(sitzung: s) : MomentListe(sitzung: s),
          ],
        ],
      );
}

/// Gespräche und Entscheidungen im langen Abend (M7b, Streifzug) am Tisch und
/// beim Gastgeber, der ermittelt: die Abend-Karte des ganzen Schlosses, die
/// Rundenuhr und unten die Karten des Streifzugs ([StreifzugAnsicht]).
class StreifzugBildschirm extends StatefulWidget {
  const StreifzugBildschirm({super.key, required this.sitzung, this.welt});

  final PartySitzung sitzung;

  /// Fertige Welt (Tests); sonst aus den Assets.
  final StreifzugWelt? welt;

  @override
  State<StreifzugBildschirm> createState() => _StreifzugBildschirmState();
}

class _StreifzugBildschirmState extends State<StreifzugBildschirm> {
  late final SitzungsStreifzug _abend = SitzungsStreifzug(widget.sitzung);

  @override
  Widget build(BuildContext context) => StreifzugAnsicht(abend: _abend, welt: widget.welt);
}

/// Der Streifzug (Langer Abend M7b): In den Gesprächen hat jede Befragung der
/// Runde einen Treffpunkt im Schloss („Triff Ahmet am Brunnen“). Ein Tipp auf
/// die Karte unten führt den Detektiv hin; dort öffnet sich dieselbe
/// Befragungskarte wie im kurzen Abend, darüber kurz, worüber die Figur gerade
/// am Tisch spricht (Impulskarte). Zwischendurch und zwischen den
/// Entscheidungen funkeln Erkundungsorte: Ankunft zeigt eine Karte mit
/// Stimmung, ohne Zeit, Würfel oder Fall. Vor jeder Entscheidung führt „Zur
/// Entscheidung“ den Detektiv zurück in den Keller, danach läuft die
/// Entscheidung unverändert ([StreifzugAbend.entscheidungsAblauf]).
///
/// Reihum (ein Gerät, Menschen am Tisch) gehen Spickzettel verdeckt herum wie
/// im kurzen Abend, und nach [streifzugDeckelReihum] freien Erkundungen in
/// einer Runde gehört die Zeit dem Tisch.
///
/// [vollbild]: der ganze Bildschirm (Tisch, Gastgeber); sonst eingebettet in
/// die Seite eines Gastes (Karte fester Höhe, Karten darunter).
class StreifzugAnsicht extends StatefulWidget {
  const StreifzugAnsicht({super.key, required this.abend, this.welt, this.vollbild = true});

  final StreifzugAbend abend;
  final StreifzugWelt? welt;
  final bool vollbild;

  /// Höhe der Karte, wenn sie eingebettet ist.
  static const eingebetteteHoehe = 340.0;

  @override
  State<StreifzugAnsicht> createState() => _StreifzugAnsichtState();
}

/// Kennung der Karte „Rundenstart“, der Tischkarte und der Uhr in [StreifzugSteuerung.offen].
const streifzugStart = 'start', streifzugTisch = 'tisch', streifzugUhr = 'uhr';

class _StreifzugAnsichtState extends State<StreifzugAnsicht> implements StreifzugBedienung {
  StreifzugWelt? _welt;
  Object? _fehler;
  StreifzugKarte? _karte;

  /// Offene Karte: eine Marke, [streifzugStart], [streifzugTisch], [streifzugUhr] oder `null`.
  String? _offen;

  /// Marke, zu der der Detektiv gerade geführt geht.
  String? _unterwegs;
  StreifzugModus _modus = StreifzugModus.streifzug;

  /// Entscheidung beim Eintritt in den Ablauf; ist sie entschieden, geht es zurück auf den Streifzug.
  String? _entscheidungBeiEintritt;

  /// Lief beim Eintritt ein Zug ohne Entscheidung (der Auftakt der ersten Runde)?
  bool _auftakt = false;

  /// Reihum: Rolle, deren Zwischenstufe offen ist, und die Befragung, die sie ausgelöst hat.
  String? _vorbereitet;
  String? _befragt;

  /// Treffen, die schon gemeldet sind (je Befragung einmal).
  final Set<String> _gemeldet = {};

  StreifzugAbend get a => widget.abend;
  PartySitzung get s => a.sitzung;

  /// Abschnitt, für den dieser Bildschirm gebaut ist. Wechselt er, blendet der
  /// nächste Bildschirm über diesen; bedient wird dann nur noch jener.
  late final PartyPhase _phase;
  late final int _runde;
  bool get _gilt => a.phase == _phase && a.runde == _runde;

  @override
  void initState() {
    super.initState();
    _phase = a.phase;
    _runde = a.runde;
    a.addListener(_abendGeaendert);
    // Eine neue Runde beginnt mit dem Rundenstart (Erzähltext, Uhr), wenn es ihn gibt.
    final pos = a.steuerung.position;
    if (a.phase == PartyPhase.gespraeche && (pos == null || pos.runde != a.runde)) _offen = streifzugStart;
    final w = widget.welt ?? StreifzugWelt.vorgabe;
    if (w != null) {
      _welt = w;
    } else {
      StreifzugWelt.laden(rootBundle, s.daten).then((w) {
        if (!mounted) return;
        setState(() => _welt = w);
      }, onError: (Object e) {
        if (mounted) setState(() => _fehler = e);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_offen == streifzugStart && a.rundenstart(context) == null) _offen = null;
    final k = _karte;
    if (k != null) k.bewegungReduziert = MediaQuery.disableAnimationsOf(context);
    _melden();
  }

  @override
  void dispose() {
    final k = _karte;
    if (k != null && !k.entsorgt && a.steuerung.angemeldet(this)) {
      a.steuerung.position = (runde: a.runde, ebene: k.aktuelleEbene, x: k.position.$1, y: k.position.$2);
    }
    a.removeListener(_abendGeaendert);
    a.steuerung.abmelden(this);
    unawaited(_karte?.dispose());
    super.dispose();
  }

  // ---------------------------------------------------------------- Karte

  WeltLage get _lage => WeltLage(lang: true, uhr: Uhrzeit.parse(a.uhrzeit));

  /// Die Karte entsteht, sobald die Welt geladen ist; dieselbe Runde beginnt
  /// dort, wo der Detektiv zuletzt stand, eine neue im Keller.
  StreifzugKarte? _karteFuer(BuildContext context) {
    final w = _welt;
    if (w == null) return null;
    final vorhanden = _karte;
    if (vorhanden != null) return vorhanden;
    a.steuerung.orte = [for (final o in w.erkundung.orte) o.id];
    final pos = a.steuerung.position;
    final hier = pos != null && pos.runde == a.runde && w.szenarien.containsKey(pos.ebene) ? pos : null;
    final k = StreifzugKarte(
      s.daten,
      w.welt,
      w.szenarien,
      lage: _lage,
      quelle: a.kartenQuelle,
      ebene: hier?.ebene ?? kellerEbene,
      start: hier == null ? null : (hier.x, hier.y),
      klasse: a.klasse(context),
      detektivName: a.detektivName,
      onMarke: _marke,
      ansprechen: streifzugTexte(context).streifzug_ansprechen,
    )..bewegungReduziert = MediaQuery.disableAnimationsOf(context);
    _karte = k;
    _markenSetzen();
    // Bedienbar (Skript, Tests) erst mit der Karte und nur im eigenen Abschnitt.
    if (_gilt) a.steuerung.anmelden(this);
    _melden();
    return k;
  }

  /// Befragungen, die noch einen Treffpunkt brauchen: feste und gewählte, die
  /// nicht erledigt sind, und freie, solange die Runde Wahlen hat.
  List<BefragungKarte> get _offeneBefragungen => a.phase != PartyPhase.gespraeche
      ? const []
      : [
          for (final k in a.befragungen)
            if (!k.erledigt && (k.pflicht || k.gefragt || (a.befragungenFrei > 0 && k.waehlbar))) k,
        ];

  /// Erkundungsorte, die noch nicht besucht sind (solange die Erkundung frei ist).
  List<ErkundungsOrt> get _offeneErkundung {
    final w = _welt;
    if (w == null || !a.erkundungFrei) return const [];
    final besucht = a.erkundet;
    return [for (final o in w.erkundung.orte) if (!besucht.contains(o.id)) o];
  }

  void _markenSetzen() {
    final w = _welt, k = _karte;
    if (w == null || k == null) return;
    final treff = a.treffpunkte(w.erkundung);
    k.marken = [
      for (final b in _offeneBefragungen)
        if (w.erkundung.treffpunkt(treff[b.id] ?? '') case final t?)
          if (treffpunktStelle(w.welt, t) case final p?)
            () {
              final (fx, fy) = k.nebenOrt(t.ebene, p.$1, p.$2);
              return StreifzugMarke(id: '${StreifzugMarke.treffPraefix}${b.id}', ebene: t.ebene, x: p.$1, y: p.$2, ort: t.ort, figur: b.rolle, figurX: fx, figurY: fy);
            }(),
      for (final o in _offeneErkundung)
        if (erkundungsStelle(w.welt, o, raster: k.rasterVon(o.ebene)) case final p?)
          StreifzugMarke(id: '${StreifzugMarke.erkundePraefix}${o.id}', ebene: o.ebene, x: p.$1, y: p.$2, ort: o.ziel.ort),
    ];
  }

  void _abendGeaendert() {
    if (!mounted) return;
    if (!_gilt) {
      // Neuer Abschnitt: Dieser Bildschirm blendet nur noch aus.
      a.steuerung.abmelden(this);
      return;
    }
    // Ist die Entscheidung entschieden und alles still, geht es zurück auf den
    // Streifzug. Lief beim Eintritt noch der Auftakt (keine Entscheidung offen),
    // gilt danach die erste Entscheidung als die, um die es geht.
    if (_modus == StreifzugModus.entscheidung && a.ruhig) {
      if (_entscheidungBeiEintritt == null && _auftakt) {
        _entscheidungBeiEintritt = a.entscheidung;
        _auftakt = false;
      } else if (a.entscheidung != _entscheidungBeiEintritt) {
        _modus = StreifzugModus.streifzug;
        _entscheidungBeiEintritt = null;
      }
    }
    _markenSetzen();
    setState(() {});
    _melden();
  }

  /// Meldet den Stand an die Steuerung (Skript, Tests), mit der Stelle des Detektivs.
  void _melden() {
    if (!a.steuerung.angemeldet(this)) return;
    final k = _karte;
    if (k != null && !k.entsorgt) a.steuerung.position = (runde: a.runde, ebene: k.aktuelleEbene, x: k.position.$1, y: k.position.$2);
    a.steuerung.melde(offen: _offen, unterwegs: _unterwegs, modus: _modus);
  }

  /// Ankunft an einer Marke: Treffpunkt öffnet die Befragung, ein Erkundungsort seine Karte.
  void _marke(StreifzugMarke m) {
    if (!mounted) return;
    if (_offen != null && _offen != m.id) return;
    if (m.treffen) {
      if (!a.befragungen.any((k) => k.id == m.kennung)) return;
      _treffenMelden(m.kennung);
    } else {
      if (!a.erkundet.contains(m.kennung)) {
        if (!a.erkundungFrei) return;
        a.erkunden(m.kennung);
      }
    }
    setState(() {
      _offen = m.id;
      _unterwegs = null;
    });
    _melden();
  }

  void _treffenMelden(String befragung) {
    if (_gemeldet.add('${a.runde}:$befragung')) a.treffen(befragung);
  }

  // ---------------------------------------------------------------- Bedienung

  @override
  bool gehe(String id) {
    final k = _karte;
    final m = k?.marke(id);
    if (k == null || m == null || _modus != StreifzugModus.streifzug || !_gilt) return false;
    if (m.treffen) _treffenMelden(m.kennung);
    setState(() {
      _offen = null;
      _unterwegs = id;
    });
    _melden();
    if (k.steht(m)) {
      _marke(m);
      return true;
    }
    unawaited(k.geheZu(m).then((ok) {
      if (!ok && mounted && _unterwegs == id) {
        setState(() => _unterwegs = null);
        _melden();
      }
    }));
    return true;
  }

  @override
  void schliessen() {
    if (!mounted) return;
    setState(() {
      _offen = null;
      _befragt = null;
      _vorbereitet = null;
    });
    _melden();
  }

  @override
  void abkuerzen() => _karte?.abkuerzen();

  /// Ist eine Entscheidung offen (oder läuft noch ein Zug wie der Auftakt)?
  bool get _entscheidungOffen => a.phase == PartyPhase.entscheidungen && (a.entscheidung != null || !a.ruhig);

  @override
  bool zurEntscheidung() {
    if (!_entscheidungOffen || _modus != StreifzugModus.streifzug || !_gilt) return false;
    setState(() {
      _offen = null;
      _unterwegs = null;
      _modus = StreifzugModus.rueckweg;
    });
    _melden();
    final k = _karte;
    void dort() {
      if (!mounted || _modus != StreifzugModus.rueckweg) return;
      setState(() {
        _modus = StreifzugModus.entscheidung;
        _entscheidungBeiEintritt = a.entscheidung;
        _auftakt = a.entscheidung == null;
      });
      _melden();
    }

    if (k == null) {
      dort();
    } else {
      unawaited(k.zurueckInDenKeller().then((_) => dort()));
    }
    return true;
  }

  // ---------------------------------------------------------------- Aufbau

  @override
  Widget build(BuildContext context) {
    final l = streifzugTexte(context);
    if (a.reihum && widget.vollbild) {
      // „Dein Moment“ (Finale §3): Die verdeckte Ansicht einer Person geht vor.
      if (s.momentAnsicht case final r?) return MomentBildschirm(sitzung: s, rolle: r);
      final v = s.verdeckt;
      if (v != null) return _spickzettel(v);
      final vorbereitet = _vorbereitet;
      if (vorbereitet != null) return _zwischenstufe(vorbereitet);
    }
    if (a.phase == PartyPhase.entscheidungen && _modus == StreifzugModus.entscheidung) return a.entscheidungsAblauf(context);
    final karte = _karteWidget(context, l);
    final panel = _panel(context, l);
    final aktionen = _aktionen(l);
    if (!widget.vollbild) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _kopfzeile(l),
          const SizedBox(height: 8),
          if (_offen != streifzugStart) SizedBox(height: StreifzugAnsicht.eingebetteteHoehe, child: karte),
          const SizedBox(height: 12),
          panel,
          if (aktionen.isNotEmpty) ...[const SizedBox(height: 12), Wrap(alignment: WrapAlignment.end, spacing: 12, runSpacing: 8, children: aktionen)],
        ],
      );
    }
    return PartyRahmen(
      marke: s.ui('ui.allgemein.runde', {'nr': '${a.runde}'}),
      titel: l.streifzug_titel,
      scroll: false,
      aktionen: aktionen,
      child: LayoutBuilder(
        builder: (context, box) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _kopfzeile(l),
            const SizedBox(height: 8),
            if (_offen == streifzugStart)
              Expanded(child: SingleChildScrollView(child: panel))
            else ...[
              Expanded(flex: _offen == null ? 5 : 2, child: ClipRRect(borderRadius: BorderRadius.circular(MMass.r10), child: karte)),
              const SizedBox(height: 10),
              if (_offen == null)
                ConstrainedBox(constraints: BoxConstraints(maxHeight: box.maxHeight * 0.45), child: SingleChildScrollView(child: panel))
              else
                Expanded(flex: 3, child: SingleChildScrollView(child: panel)),
            ],
          ],
        ),
      ),
    );
  }

  /// Uhrzeit der Runde und die Restzeit der Rundenuhr.
  Widget _kopfzeile(L l) => Row(
        children: [
          Expanded(child: Text(s.ui('ui.allgemein.uhrzeit', {'uhrzeit': a.uhrzeit}), style: context.schrift.leise)),
          if (a.rundenUhr case final uhr?)
            _UhrKurz(
              key: const ValueKey('streifzug-uhr'),
              uhr: uhr,
              jetzt: a.jetzt,
              text: l.streifzug_uhr_rest,
              onTap: _offen == streifzugStart ? null : () => _oeffne(streifzugUhr),
            ),
        ],
      );

  void _oeffne(String id) {
    setState(() => _offen = id);
    _melden();
  }

  Widget _karteWidget(BuildContext context, L l) {
    if (_fehler != null) return Center(child: Text(s.ui('ui.allgemein.fehler'), style: context.schrift.leise));
    final k = _karteFuer(context);
    if (k == null) return const Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3)));
    return GameView(
      key: const ValueKey('streifzug-karte'),
      session: k,
      steuerung: _offen == null && _modus == StreifzugModus.streifzug,
      kameraPassend: true,
      umgebung: SzenenUmgebung(mitte: Color.lerp(MFarben.von(context).nachtOben, MFarben.von(context).schein, 0.1)!, rand: MFarben.von(context).grund),
    );
  }

  /// Knöpfe im Fuß: zur Entscheidung, Abkürzen auf dem Weg, Weiter.
  List<Widget> _aktionen(L l) => [
        if (_modus == StreifzugModus.rueckweg)
          PartyKnopf(key: const ValueKey('streifzug-abkuerzen'), text: l.streifzug_abkuerzen, haupt: false, onPressed: abkuerzen),
        if (_modus == StreifzugModus.streifzug && _entscheidungOffen)
          Semantics(
            container: true,
            identifier: 'streifzug-zur-entscheidung',
            child: PartyKnopf(key: const ValueKey('streifzug-zur-entscheidung'), text: l.streifzug_zur_entscheidung, onPressed: zurEntscheidung),
          ),
        // Eingebettet (Gast) steht „Weiter“ auf der Seite selbst.
        if (widget.vollbild && _modus == StreifzugModus.streifzug && !_entscheidungOffen)
          PartyKnopf(
            key: const ValueKey('streifzug-weiter'),
            text: a.phase == PartyPhase.gespraeche ? s.ui('ui.runde.weiter') : s.ui('ui.allgemein.weiter'),
            onPressed: a.kannWeiter ? a.weiter : null,
          ),
      ];

  // ---------------------------------------------------------------- Karten

  Widget _panel(BuildContext context, L l) {
    final offen = _offen;
    if (_modus == StreifzugModus.rueckweg) return _hinweis(l.streifzug_rueckweg);
    if (offen == null) return _leiste(l);
    if (offen == streifzugStart) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          a.rundenstart(context) ?? const SizedBox.shrink(),
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerRight, child: MKnopf(key: const ValueKey('streifzug-los'), text: l.streifzug_los, onPressed: schliessen)),
        ],
      );
    }
    if (offen == streifzugUhr) return _schliessbar(l, a.uhr(context));
    if (offen == streifzugTisch) return _schliessbar(l, _tischKarte(l));
    if (offen.startsWith(StreifzugMarke.treffPraefix)) return _befragung(l, offen.substring(StreifzugMarke.treffPraefix.length));
    if (offen.startsWith(StreifzugMarke.erkundePraefix)) return _erkundung(l, offen.substring(StreifzugMarke.erkundePraefix.length));
    return _leiste(l);
  }

  Widget _schliessbar(L l, Widget inhalt, {String? text}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          inhalt,
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: MKnopf(key: const ValueKey('streifzug-schliessen'), text: text ?? l.streifzug_zur_karte, art: MKnopfArt.zweit, onPressed: schliessen),
          ),
        ],
      );

  Widget _hinweis(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, key: const ValueKey('streifzug-hinweis'), style: context.schrift.text),
      );

  /// Die Kartenleiste: Treffpunkte, Erkundungsorte, reihum der Tisch und der
  /// Deckel; in den Entscheidungen der Hinweis auf die nächste Entscheidung.
  Widget _leiste(L l) {
    final w = _welt;
    final karten = <Widget>[];
    final hinweise = <String>[];
    if (a.phase == PartyPhase.gespraeche) {
      final treff = w == null ? const <String, String>{} : a.treffpunkte(w.erkundung);
      final offen = _offeneBefragungen;
      if (offen.isEmpty && a.befragungen.isNotEmpty) hinweise.add(l.streifzug_befragungen_fertig);
      for (final b in offen) {
        final t = w?.erkundung.treffpunkt(treff[b.id] ?? '');
        karten.add(_Leistenkarte(
          key: ValueKey('streifzug-${StreifzugMarke.treffPraefix}${b.id}'),
          kennung: '${StreifzugMarke.treffPraefix}${b.id}',
          titel: l.streifzug_triff(a.person(b.rolle), t?.anzeige ?? ''),
          unter: b.gefragt ? l.streifzug_antwort_offen : (b.pflicht ? s.ui('ui.befragung.pflicht') : l.streifzug_frei),
          icon: Icons.record_voice_over_rounded,
          farbe: s.figurFarbe(b.rolle),
          aktiv: _unterwegs == '${StreifzugMarke.treffPraefix}${b.id}',
          onTap: () => gehe('${StreifzugMarke.treffPraefix}${b.id}'),
        ));
      }
    } else if (_entscheidungOffen) {
      hinweise.add(l.streifzug_entscheidung_wartet);
    }
    if (a.reihum && !a.erkundungFrei) {
      karten.add(_DeckelKarte(titel: l.streifzug_deckel_titel, punkte: [l.streifzug_deckel_1, l.streifzug_deckel_2, l.streifzug_deckel_3]));
    }
    for (final o in _offeneErkundung) {
      final m = _karte?.marke('${StreifzugMarke.erkundePraefix}${o.id}');
      final raum = m == null ? null : w?.welt.ebenen[o.ebene]?.graph.raumAn(m.x, m.y)?.anzeigename;
      karten.add(_Leistenkarte(
        key: ValueKey('streifzug-${StreifzugMarke.erkundePraefix}${o.id}'),
        kennung: '${StreifzugMarke.erkundePraefix}${o.id}',
        titel: l.streifzug_erkunde(o.titel),
        unter: raum ?? '',
        icon: Icons.travel_explore_rounded,
        aktiv: _unterwegs == '${StreifzugMarke.erkundePraefix}${o.id}',
        onTap: () => gehe('${StreifzugMarke.erkundePraefix}${o.id}'),
      ));
    }
    if (a.reihum && a.phase == PartyPhase.gespraeche) {
      karten.add(_Leistenkarte(
        key: const ValueKey('streifzug-tisch'),
        kennung: streifzugTisch,
        titel: l.streifzug_tisch,
        unter: l.streifzug_tisch_unter,
        icon: Icons.groups_rounded,
        onTap: () => _oeffne(streifzugTisch),
      ));
    }
    if (a.phase == PartyPhase.gespraeche && a.rundenstart(context) != null) {
      karten.add(_Leistenkarte(
        key: const ValueKey('streifzug-rundenstart'),
        kennung: streifzugStart,
        titel: l.streifzug_rundenstart,
        unter: l.streifzug_rundenstart_unter,
        icon: Icons.menu_book_rounded,
        onTap: () => _oeffne(streifzugStart),
      ));
    }
    if (_unterwegs != null) hinweise.insert(0, l.streifzug_unterwegs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final h in hinweise) _hinweis(h),
        SingleChildScrollView(
          key: const ValueKey('streifzug-leiste'),
          scrollDirection: Axis.horizontal,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final k in karten) Padding(padding: const EdgeInsets.only(right: 10), child: k)]),
        ),
      ],
    );
  }

  /// Befragung am Treffpunkt: die Impulskarte (worüber die Figur am Tisch
  /// spricht) und dieselbe Befragungskarte wie im kurzen Abend.
  Widget _befragung(L l, String id) {
    final k = a.befragungen.where((b) => b.id == id).firstOrNull;
    if (k == null) return _schliessbar(l, const SizedBox.shrink());
    final paare = [for (final t in a.tisch) if (t.rolle == k.rolle || t.partner == k.rolle) t].take(3).toList();
    return _schliessbar(
      l,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MBlatt(
            key: const ValueKey('streifzug-impuls'),
            art: PapierArt.notiz,
            neigung: 0.004,
            samen: 61 + a.runde,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.streifzug_impuls_titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
                const SizedBox(height: 8),
                if (paare.isEmpty) Text(l.streifzug_impuls_leer, style: MPapierSchrift.leise),
                for (final t in paare) TischZeile(sitzung: s, paarung: t),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BefragungsKarte(
            sitzung: s,
            karte: k,
            onFrage: (f) => _frage(k, f),
            aktionen: _befragungsKnoepfe(k),
          ),
        ],
      ),
    );
  }

  /// Eine Frage. Reihum antwortet die Person aus ihrem Spickzettel: Das Gerät geht kurz verdeckt zu ihr.
  void _frage(BefragungKarte k, int frage) {
    a.befragen(k.id, frage);
    if (a.reihum && k.mensch) {
      setState(() {
        _vorbereitet = k.rolle;
        _befragt = k.id;
      });
    }
  }

  List<Widget> _befragungsKnoepfe(BefragungKarte k) => [
        if (k.gefragt && k.mensch && !k.erledigt) ...[
          if (a.reihum)
            MKnopf(
              text: s.ui('ui.befragung.antwort_zeigen'),
              art: MKnopfArt.zweit,
              onPressed: () => setState(() {
                _vorbereitet = k.rolle;
                _befragt = k.id;
              }),
            ),
          Semantics(
            container: true,
            identifier: 'befragung-beantwortet-${k.id}',
            child: MKnopf(text: s.ui('ui.befragung.beantwortet'), onPressed: () => a.befragungErledigt(k.id)),
          ),
        ],
      ];

  /// Die Karte eines Erkundungsorts (R17): Titel und Stichpunkte.
  Widget _erkundung(L l, String id) {
    final o = _welt?.erkundung.ort(id);
    if (o == null) return _schliessbar(l, const SizedBox.shrink());
    return _schliessbar(
      l,
      MBlatt(
        key: ValueKey('streifzug-erkundung-${o.id}'),
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        neigung: -0.004,
        samen: o.id.length + 11,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            MGanzeWorte(o.titel, stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
            const SizedBox(height: 10),
            for (final p in a.erkundungsPunkte(o)) spickPunkt(p),
          ],
        ),
      ),
      text: l.streifzug_weiter_erkunden,
    );
  }

  /// Reihum: wer am Tisch mit wem worüber spricht, und die Spickzettel je Person.
  Widget _tischKarte(L l) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MBlatt(
            art: PapierArt.karteikarte,
            kopfLinie: 7,
            linien: false,
            neigung: 0.003,
            samen: 23 + a.runde,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.ui('ui.befragung.tisch_titel'), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                for (final t in a.tisch) TischZeile(sitzung: s, paarung: t),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(s.ui('ui.befragung.spickzettel'), style: context.schrift.marke),
          const SizedBox(height: 8),
          for (var i = 0; i < s.besetzt.length; i++) ...[_person(i, s.besetzt[i]), const SizedBox(height: 8)],
        ],
      );

  /// Eine Person am Tisch: Tipp öffnet die Zwischenstufe zu ihrem Spickzettel.
  Widget _person(int i, String rolle) => Semantics(
        button: true,
        child: MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          randFarbe: s.figurFarbe(rolle),
          neigung: i.isEven ? -0.003 : 0.003,
          samen: 70 + i,
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
          onTap: () => setState(() {
            _vorbereitet = rolle;
            _befragt = null;
          }),
          child: Row(
            children: [
              MFotoabzug(look: s.figurAussehen(rolle), groesse: 40, neigung: i.isEven ? -0.05 : 0.04, akzent: s.figurFarbe(rolle)),
              const SizedBox(width: 14),
              Expanded(child: MGanzeWorte(s.spielerName(rolle), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18))),
              const Icon(Icons.visibility_off_rounded, size: 20, color: MRoh.tinteLeise),
            ],
          ),
        ),
      );

  // ---------------------------------------------------------------- Reihum verdeckt

  /// Zwischenstufe: Das Gerät geht an diese Person; erst ihr Knopf öffnet den Zettel.
  Widget _zwischenstufe(String rolle) {
    final name = s.spielerName(rolle);
    return PartyRahmen(
      marke: s.ui('ui.allgemein.runde', {'nr': '${a.runde}'}),
      titel: s.rundenName,
      child: MBlatt(
        art: PapierArt.telegramm,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        neigung: -0.006,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: MSiegel(kuerzel: AkteStil.fuer(s.daten.fall).sigel, farbe: context.farben.gefahr, groesse: 54)),
            const SizedBox(height: 16),
            Text(s.ui(_befragt != null ? 'ui.befragung.geraet' : 'ui.verdeckt.weitergeben', {'name': name}),
                style: MPapierSchrift.ueberschrift, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PartyKnopf(
              text: s.ui('ui.verdeckt.frage', {'name': name}),
              onPressed: () {
                setState(() => _vorbereitet = null);
                s.zeigeVerdeckt(rolle);
              },
            ),
            const SizedBox(height: 10),
            PartyKnopf(
              text: s.ui('ui.allgemein.zurueck'),
              haupt: false,
              onPressed: () => setState(() {
                _vorbereitet = null;
                _befragt = null;
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Der verdeckte Spickzettel der laufenden Runde; nach einer Frage steht die Befragung oben.
  Widget _spickzettel(String rolle) => PartyRahmen(
        marke: s.ui('ui.befragung.spickzettel'),
        titel: s.figurName(rolle),
        untertitel: s.ui('ui.allgemein.runde', {'nr': '${a.runde}'}),
        aktionen: [PartyKnopf(text: s.ui('ui.verdeckt.schliessen'), onPressed: () => _zudecken(rolle))],
        child: MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          randFarbe: s.figurFarbe(rolle),
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
          child: SpickzettelInhalt(sitzung: s, rolle: rolle, runde: a.runde, befragungZuerst: _befragt != null),
        ),
      );

  /// Zudecken; kam der Blick von einer Befragung, ist sie damit beantwortet.
  void _zudecken(String rolle) {
    final id = _befragt;
    setState(() => _befragt = null);
    s.verdecken();
    if (id != null && s.befragungVon(rolle)?.id == id) a.befragungErledigt(id);
  }
}

/// Eine Karte der Leiste (R17): Symbol, eine Zeile Titel, eine Zeile darunter.
class _Leistenkarte extends StatelessWidget {
  const _Leistenkarte({
    super.key,
    required this.kennung,
    required this.titel,
    required this.unter,
    required this.icon,
    required this.onTap,
    this.farbe,
    this.aktiv = false,
  });

  final String kennung;
  final String titel;
  final String unter;
  final IconData icon;
  final VoidCallback onTap;
  final Color? farbe;
  final bool aktiv;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        button: true,
        identifier: 'streifzug-$kennung',
        child: SizedBox(
          width: 190,
          child: MBlatt(
            art: PapierArt.karteikarte,
            kopfLinie: 7,
            linien: false,
            randFarbe: farbe,
            hervorgehoben: aktiv,
            neigung: kennung.length.isEven ? 0.004 : -0.004,
            samen: kennung.length + 3,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: MRoh.tinteLeise),
                const SizedBox(height: 4),
                Text(titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 16)),
                if (unter.isNotEmpty) Text(unter, style: MPapierSchrift.maschine.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ),
      );
}

/// Reihum nach dem Deckel: Die Zeit gehört dem Tisch (R17, drei Stichpunkte).
class _DeckelKarte extends StatelessWidget {
  const _DeckelKarte({required this.titel, required this.punkte});

  final String titel;
  final List<String> punkte;

  @override
  Widget build(BuildContext context) => SizedBox(
        key: const ValueKey('streifzug-deckel'),
        width: 230,
        child: MBlatt(
          art: PapierArt.notiz,
          neigung: -0.004,
          samen: 47,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
              const SizedBox(height: 6),
              for (final p in punkte) spickPunkt(p),
            ],
          ),
        ),
      );
}

/// Die Restzeit der Rundenuhr in einer Zeile; ein Tipp zeigt die ganze Uhr.
class _UhrKurz extends StatefulWidget {
  const _UhrKurz({super.key, required this.uhr, required this.jetzt, required this.text, this.onTap});

  final RundenUhr uhr;
  final int Function() jetzt;
  final String Function(String zeit) text;
  final VoidCallback? onTap;

  @override
  State<_UhrKurz> createState() => _UhrKurzState();
}

class _UhrKurzState extends State<_UhrKurz> {
  Timer? _takt;

  @override
  void initState() {
    super.initState();
    _pruefen();
  }

  @override
  void didUpdateWidget(_UhrKurz alt) {
    super.didUpdateWidget(alt);
    _pruefen();
  }

  @override
  void dispose() {
    _takt?.cancel();
    super.dispose();
  }

  void _pruefen() {
    final soll = widget.uhr.laeuft && !widget.uhr.abgelaufen(widget.jetzt());
    if (soll && _takt == null) {
      _takt = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        if (widget.uhr.abgelaufen(widget.jetzt())) {
          _takt?.cancel();
          _takt = null;
        }
      });
    } else if (!soll) {
      _takt?.cancel();
      _takt = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rest = widget.uhr.rest(widget.jetzt()) ~/ 1000;
    final zeit = '${rest ~/ 60}:${(rest % 60).toString().padLeft(2, '0')}';
    return TextButton.icon(
      onPressed: widget.onTap,
      icon: const Icon(Icons.timer_outlined, size: 18),
      label: Text(widget.text(zeit)),
    );
  }
}
