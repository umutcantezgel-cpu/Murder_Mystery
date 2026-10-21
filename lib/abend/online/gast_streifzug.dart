import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show RundenUhr;
import 'package:provider/provider.dart';

import '../../game/game_view.dart';
import '../../game/szenen_erweiterung.dart';
import '../../meta/meta_store.dart';
import '../../party/abend_karte.dart';
import '../../party/bildschirme/streifzug.dart';
import '../../party/daten.dart';
import '../../party/karten_quelle.dart';
import '../../party/klasse_wirkung.dart';
import '../../party/stand/befragung_stand.dart';
import '../../party/streifzug_karte.dart';
import '../../party/streifzug_steuerung.dart';
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_ansicht.dart' show GastKontext;
import 'gast_ermittlung.dart';
import 'gast_karte_session.dart' show AnsichtsKartenQuelle;
import 'gast_lese_sitzung.dart';
import 'gast_uhr.dart';
import 'online_teile.dart';

/// Der Streifzug des Gast-Detektivs im langen Abend (M7b): dieselbe Ansicht
/// wie am Tisch ([StreifzugAnsicht]), eingebettet in seine Seite. Die
/// Abend-Karte läuft auf seinem Gerät; Erkundung und Treffen gehen als
/// Nachrichten an den Raum (`erkunde`, `treffen`), die Befragungen wie im
/// kurzen Abend. Treffpunkte und Fassungen der Erkundungsorte kommen privat
/// aus dem Raum: Der Samen der Welt bleibt beim Gastgeber. Vor jeder
/// Entscheidung geht es zurück in den Keller, dann folgt die unveränderte
/// Ermittlung des Gastes ([GastErmittlung]).
Widget gastDetektivStreifzug(GastKontext c) {
  final s = GastLeseSitzung.fuer(c);
  if (s == null) return const SizedBox.shrink();
  return StreifzugAnsicht(key: ValueKey('streifzug-${c.phase}-${c.runde}'), abend: GastStreifzug(c, s), vollbild: false);
}

/// Der Streifzug aus der Ansicht des Gast-Detektivs.
class GastStreifzug implements StreifzugAbend {
  GastStreifzug(this.c, this.sitzung) : _hoerer = Listenable.merge([c.dienst, sitzung]);

  final GastKontext c;

  @override
  final GastLeseSitzung sitzung;
  final Listenable _hoerer;

  Map<String, Object?> get _weg => jMap(c.v['streifzug']);
  Map<String, Object?> get _privat => jMap(c.privat['streifzug']);

  @override
  void addListener(VoidCallback l) => _hoerer.addListener(l);
  @override
  void removeListener(VoidCallback l) => _hoerer.removeListener(l);

  @override
  StreifzugSteuerung get steuerung => sitzung.streifzug;

  @override
  PartyPhase get phase => PartyPhase.values.where((p) => p.name == c.phase).firstOrNull ?? PartyPhase.titel;

  @override
  int get runde => c.runde;

  @override
  String get uhrzeit {
    for (final r in (sitzung.kanon.fall['runden'] as List).cast<Map>()) {
      if (r['nr'] == c.runde) return r['uhrzeit'] as String;
    }
    return '00:00';
  }

  @override
  bool get reihum => false;

  @override
  String person(String figur) => c.personAmTisch(figur);

  @override
  List<BefragungKarte> get befragungen => sitzung.befragungen;

  @override
  int get befragungenFrei => sitzung.befragungenFrei;

  @override
  void befragen(String id, int frage) => sitzung.befragen(id, frage);

  @override
  void befragungErledigt(String id) => sitzung.befragungErledigt(id);

  @override
  List<TischPaarung> get tisch => [
        for (final (i, t) in jMaps(c.v['tisch']).indexed)
          (id: 'tisch-$i', rolle: jText(t['rolle']), partner: jText(t['partner']), thema: jText(t['thema'])),
      ];

  @override
  Map<String, String> treffpunkte(Erkundung erkundung) => {for (final e in jMap(_privat['treffpunkte']).entries) e.key: jText(e.value)};

  /// Erkundungen, die schon gemeldet, aber noch nicht in der Ansicht sind.
  static final _unterwegs = Expando<Set<String>>();
  Set<String> get _gemeldet => _unterwegs[c.dienst] ??= {};

  @override
  Set<String> get erkundet {
    final raum = jTexte(_weg['erkundet']).toSet();
    _gemeldet.removeAll(raum);
    return {...raum, ..._gemeldet};
  }

  @override
  bool get erkundungFrei => true;

  @override
  void erkunden(String ort) {
    if (erkundet.contains(ort)) return;
    _gemeldet.add(ort);
    unawaited(c.befehl({'typ': 'erkunde', 'ort': ort}).catchError((_) {}));
  }

  @override
  void treffen(String befragung) => unawaited(c.befehl({'typ': 'treffen', 'befragung': befragung}).catchError((_) {}));

  @override
  List<String> erkundungsPunkte(ErkundungsOrt ort) => ort.stichpunkteDer(jZahl(jMap(_privat['varianten'])[ort.id]));

  @override
  String? get entscheidung => c.v['entscheidung'] is Map ? jText(jMap(c.v['entscheidung'])['id']) : null;

  @override
  bool get ruhig => c.v['zug'] is! Map;

  /// „Weiter“ steht auf der Seite des Gastes ([gastWeiter]).
  @override
  bool get kannWeiter => false;

  @override
  void weiter() {}

  @override
  Widget uhr(BuildContext context) => gastRundenUhr(c) ?? const SizedBox.shrink();

  /// Die Uhr steht auf der Seite des Gastes schon oben.
  @override
  RundenUhr? get rundenUhr => null;

  @override
  int Function() get jetzt => () => c.dienst.gastgeberZeit;

  @override
  Widget entscheidungsAblauf(BuildContext context) => GastErmittlung(key: ValueKey('ermittlung-${c.runde}'), kontext: c);

  @override
  KartenQuelle? get kartenQuelle => AnsichtsKartenQuelle(sitzung.daten, () => c.v);

  /// Die Klasse des Detektiv-Sitzes wirkt wie in der Ermittlung des Gastes.
  @override
  SzenenKlasse? klasse(BuildContext context) {
    final daten = sitzung.daten;
    final f = KlassenFaehigkeit.vonKlasse(c.privat['klasse'] is String ? c.privat['klasse'] as String : context.read<MetaStore?>()?.loadout.cls);
    if (f == null || !daten.hat('klassen')) return null;
    final menschen = {for (final p in c.spieler) ?p.rolle};
    return KlasseWirkung(faehigkeit: f, daten: daten, quelle: AnsichtsKartenQuelle(daten, () => c.v), appSprichtFuer: (figur) => !menschen.contains(figur));
  }

  @override
  String get detektivName => c.nameVon(c.ichId);

  @override
  Widget? rundenstart(BuildContext context) => null;
}

/// Statuskarte der übrigen Gäste im Streifzug (R17): Der Detektiv streift
/// durchs Schloss, und wen er gerade trifft, erfährt jeder; wer selbst
/// getroffen wird, liest „Der Detektiv trifft dich am Brunnen“. Freies Laufen
/// für alle kommt erst mit M9. `null` außerhalb des Streifzugs und für das
/// Gerät, das ermittelt.
Widget? gastStreifzugStatus(GastKontext c) {
  final weg = c.v['streifzug'];
  if (weg is! Map || c.ermittelt) return null;
  final l = streifzugTexte(c.context);
  final t = jMap(weg['treffpunkt']);
  final figur = jText(t['figur']);
  final mich = figur.isNotEmpty && figur == c.rolle;
  final punkte = <(String, Key?)>[
    (l.streifzug_laeuft_text, null),
    if (figur.isNotEmpty)
      mich
          ? (l.streifzug_trifft_dich(jText(t['anzeige'])), const ValueKey('gast-streifzug-mich'))
          : (l.streifzug_trifft(c.personAmTisch(figur), jText(t['anzeige'])), const ValueKey('gast-streifzug-treffen')),
    if (figur.isEmpty && weg['ebene'] == kellerEbene) (l.streifzug_im_keller, null),
  ];
  return Padding(
    key: const ValueKey('gast-streifzug'),
    padding: const EdgeInsets.only(bottom: MMass.s16),
    child: MBlatt(
      art: PapierArt.notiz,
      hervorgehoben: mich,
      neigung: -0.004,
      samen: 29 + c.runde,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.streifzug_laeuft_titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
          const SizedBox(height: 6),
          for (final (text, key) in punkte)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(text, key: key, style: mich && key != null ? MPapierSchrift.hand.copyWith(fontSize: 20) : MPapierSchrift.text),
            ),
        ],
      ),
    ),
  );
}

/// Zuschauerkarte des Streifzugs (Erzähler, M7b): die Abend-Karte nur zum
/// Lesen, der Detektiv an der Stelle, die der Raum meldet (Erkundungsort,
/// Treffpunkt oder sein Ermittlungsort im Keller), darunter ein Satz dazu. Sie
/// nimmt keine Eingabe an und meldet nichts.
class StreifzugZuschauer extends StatefulWidget {
  const StreifzugZuschauer({super.key, required this.daten, required this.weg, required this.uhrzeit, required this.person, this.welt});

  final PartyDaten daten;

  /// Öffentliche Ansicht `streifzug` des Raums.
  final Map<String, Object?> weg;
  final String uhrzeit;
  final String Function(String figur) person;

  /// Fertige Welt (Tests); sonst aus den Assets.
  final StreifzugWelt? welt;

  @override
  State<StreifzugZuschauer> createState() => _StreifzugZuschauerState();
}

class _StreifzugZuschauerState extends State<StreifzugZuschauer> {
  StreifzugWelt? _welt;
  AbendKarte? _karte;
  String? _stelle;

  @override
  void initState() {
    super.initState();
    final w = widget.welt ?? StreifzugWelt.vorgabe;
    if (w != null) {
      _welt = w;
    } else {
      StreifzugWelt.laden(rootBundle, widget.daten).then((w) {
        if (mounted) setState(() => _welt = w);
      }, onError: (Object _) {});
    }
  }

  @override
  void dispose() {
    unawaited(_karte?.dispose());
    super.dispose();
  }

  /// Ebene und Punkt der gemeldeten Stelle; ohne Ort der Ermittlungsort im Keller.
  (String, (double, double)?) _wo(StreifzugWelt w) {
    final ebene = jText(widget.weg['ebene'], kellerEbene);
    final ort = jText(widget.weg['ort']);
    if (w.erkundung.ort(ort) case final o?) return (o.ebene, erkundungsStelle(w.welt, o));
    if (w.erkundung.treffpunkt(ort) case final t?) return (t.ebene, treffpunktStelle(w.welt, t));
    return (w.welt.ebenen.containsKey(ebene) ? ebene : kellerEbene, null);
  }

  AbendKarte? _karteFuer(StreifzugWelt w) {
    final (ebene, punkt) = _wo(w);
    final schluessel = '$ebene:${punkt?.$1}:${punkt?.$2}:${widget.uhrzeit}';
    if (_karte != null && _stelle == schluessel) return _karte;
    final alt = _karte;
    if (alt != null) WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(alt.dispose()));
    _stelle = schluessel;
    return _karte = AbendKarte(widget.daten, w.welt, w.szenarien,
        lage: WeltLage(lang: true, uhr: Uhrzeit.parse(widget.uhrzeit)), ebene: ebene, start: ebene == kellerEbene && punkt == null ? null : punkt)
      ..bewegungReduziert = MediaQuery.disableAnimationsOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = streifzugTexte(context);
    final w = _welt;
    final t = jMap(widget.weg['treffpunkt']);
    final ort = jText(widget.weg['ort']);
    final titel = w?.erkundung.ort(ort)?.titel ?? w?.erkundung.treffpunkt(ort)?.anzeige;
    final satz = t['figur'] is String
        ? l.streifzug_trifft(widget.person(jText(t['figur'])), jText(t['anzeige']))
        : titel != null
            ? l.streifzug_ist(titel)
            : l.streifzug_im_keller;
    final k = w == null ? null : _karteFuer(w);
    return Column(
      key: const ValueKey('streifzug-zuschauer'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        OnlineRegisterKopf(l.streifzug_zuschauer_titel.toUpperCase()),
        ClipRRect(
          borderRadius: BorderRadius.circular(MMass.r10),
          child: SizedBox(
            height: 260,
            child: k == null
                ? const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)))
                : IgnorePointer(child: GameView(key: ValueKey('zuschauer-$_stelle'), session: k, steuerung: false, kameraPassend: true)),
          ),
        ),
        const SizedBox(height: MMass.s8),
        Text(satz, key: const ValueKey('streifzug-zuschauer-satz'), style: MSchrift.von(context).text),
        const SizedBox(height: MMass.s16),
      ],
    );
  }
}
