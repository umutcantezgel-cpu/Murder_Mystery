import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/runden.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../karten/katalog_laden.dart';
import '../karten/widgets/karten_ansicht.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../meta/progression.dart';
import '../stil/stil.dart';
import '../ui/widgets/meters.dart' show RankBadge;
import 'abend_halter.dart';

/// Belohnung nach dem Abend (Route `/abend/belohnung`): bucht den Abend im
/// [MetaStore] (genau einmal, Schlüssel ist die Abendkennung) und zeigt die
/// erhaltenen Karten (verdeckt hereingleitend, Tipp dreht sie um, „NEU“ für
/// erstmals besessene), die Erfahrungsleiste und, bei einer Beförderung, den
/// Rangstempel. Mit „Bewegung reduzieren“ liegen alle Karten offen in einer Liste.
class BelohnungSeite extends StatefulWidget {
  const BelohnungSeite({super.key});

  @override
  State<BelohnungSeite> createState() => _BelohnungSeiteState();
}

class _BelohnungSeiteState extends State<BelohnungSeite> {
  late final AbendHalter _halter = context.read<AbendHalter>();
  late final MetaStore _meta = context.read<MetaStore>();
  late final AbendAbschluss? _abschluss = _halter.abschluss;

  KartenKatalog? _katalog;
  Map<String, Map<String, KartenFigur>> _figuren = const {};
  AbendBelohnung? _belohnung;
  bool _fehler = false;
  final Set<int> _aufgedeckt = {};

  @override
  void initState() {
    super.initState();
    // Die Buchung meldet den MetaStore: nie während des Aufbaus der Seite.
    scheduleMicrotask(_buchen);
  }

  Future<void> _buchen() async {
    final a = _abschluss;
    if (a == null) {
      if (mounted) context.go(Routes.start);
      return;
    }
    if (mounted && _fehler) setState(() => _fehler = false);
    try {
      final katalog = await kartenBereit(_meta);
      final figuren = await ladeAlleKartenFiguren(katalog);
      final b = _meta.verbucheAbend(abendId: a.abendId, ergebnis: a.ergebnis, katalog: katalog, punkte: a.punkte);
      if (!mounted) return;
      setState(() {
        _katalog = katalog;
        _figuren = figuren;
        _belohnung = b;
      });
    } catch (e, st) {
      debugPrint('ABEND belohnung fehler $e\n$st');
      if (mounted) setState(() => _fehler = true);
    }
  }

  void _zurDetektei() {
    _halter.abschlussErledigt();
    context.go(Routes.start);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final a = _abschluss;
    return AkteThema(
      akte: a?.ergebnis.akte ?? '',
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: MFarben.von(context).grund,
          body: MRahmen(
            marke: l.abend_belohnung_marke,
            titel: l.abend_belohnung_titel,
            untertitel: a == null || a.endeName.isEmpty ? null : a.endeName,
            aktionen: [MKnopf(text: l.abend_belohnung_detektei, icon: Icons.home_rounded, onPressed: _zurDetektei)],
            child: _inhalt(context),
          ),
        ),
      ),
    );
  }

  Widget _inhalt(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final b = _belohnung;
    if (_fehler) {
      return MTafel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.abend_belohnung_fehler, style: t.text),
            const SizedBox(height: MMass.s12),
            MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: _buchen),
          ],
        ),
      );
    }
    if (b == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: MMass.s32),
        child: Text(l.abend_belohnung_laedt, textAlign: TextAlign.center, style: t.leise),
      );
    }
    final katalog = _katalog!;
    final defs = [for (final id in b.karten) if (katalog[id] != null) katalog[id]!];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (b.schonVerbucht) ...[
          Text(l.abend_belohnung_bereits, style: t.leise),
          const SizedBox(height: MMass.s12),
        ],
        Text(l.abend_belohnung_karten.toUpperCase(), style: t.marke),
        const SizedBox(height: MMass.s12),
        if (defs.isEmpty)
          Text(l.abend_belohnung_keine, style: t.text)
        else if (MBewegung.ruhig(context))
          _KartenListe(defs: defs, neu: b.neu.toSet(), figuren: _figuren)
        else
          _KartenStapel(
            defs: defs,
            neu: b.neu.toSet(),
            figuren: _figuren,
            aufgedeckt: _aufgedeckt,
            onUmgedreht: (i, vorn) => setState(() => vorn ? _aufgedeckt.add(i) : _aufgedeckt.remove(i)),
            onAlle: () => setState(() => _aufgedeckt.addAll([for (var i = 0; i < defs.length; i++) i])),
          ),
        const SizedBox(height: MMass.s32),
        _Erfahrung(belohnung: b),
      ],
    );
  }
}

/// Karten ohne Bewegung: alle offen, mit Titel, Wirkung und Marke.
class _KartenListe extends StatelessWidget {
  const _KartenListe({required this.defs, required this.neu, required this.figuren});

  final List<KartenDef> defs;
  final Set<String> neu;
  final Map<String, Map<String, KartenFigur>> figuren;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final d in defs)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s12),
            child: MTafel(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KartenKarte(def: d, figur: kartenFigurVon(figuren, d), breite: 96),
                  const SizedBox(width: MMass.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.titel, style: t.ueberschrift.copyWith(fontSize: 18)),
                        const SizedBox(height: MMass.s4),
                        Text(d.text, style: t.leise),
                        const SizedBox(height: MMass.s8),
                        Wrap(
                          spacing: MMass.s8,
                          runSpacing: MMass.s8,
                          children: [
                            if (neu.contains(d.id)) const NeuMarke() else MChip(l.abend_belohnung_doppelt, farbe: f.papierLeise),
                            MChip(KartenTexte.seltenheit(d.seltenheit), farbe: f.seltenheit(seltenheitStufe(d.seltenheit).index)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Verdeckte Karten, die nacheinander hereingleiten; ein Tipp dreht sie um.
class _KartenStapel extends StatefulWidget {
  const _KartenStapel({
    required this.defs,
    required this.neu,
    required this.figuren,
    required this.aufgedeckt,
    required this.onUmgedreht,
    required this.onAlle,
  });

  final List<KartenDef> defs;
  final Set<String> neu;
  final Map<String, Map<String, KartenFigur>> figuren;
  final Set<int> aufgedeckt;
  final void Function(int index, bool vorn) onUmgedreht;
  final VoidCallback onAlle;

  @override
  State<_KartenStapel> createState() => _KartenStapelState();
}

class _KartenStapelState extends State<_KartenStapel> with SingleTickerProviderStateMixin {
  static const _versatz = 240;
  static const _dauer = 520;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _dauer + _versatz * (widget.defs.length - 1)),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final n = widget.defs.length;
    final gesamt = _dauer + _versatz * (n - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.abend_belohnung_tipp, style: t.leise),
        const SizedBox(height: MMass.s16),
        LayoutBuilder(
          builder: (context, box) {
            const abstand = MMass.s12;
            final proReihe = math.min(n, box.maxWidth >= 560 ? 4 : 3);
            final breite = math.min(170.0, (box.maxWidth - abstand * (proReihe - 1)) / proReihe);
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: abstand,
              runSpacing: MMass.s16,
              children: [
                for (var i = 0; i < n; i++)
                  _eintrag(context, i, breite, Interval(i * _versatz / gesamt, (i * _versatz + _dauer) / gesamt, curve: Curves.easeOutCubic), f, l),
              ],
            );
          },
        ),
        const SizedBox(height: MMass.s12),
        if (widget.aufgedeckt.length < n)
          Align(
            alignment: Alignment.center,
            child: MKnopf(text: l.abend_belohnung_alle, art: MKnopfArt.leise, icon: Icons.flip_rounded, onPressed: widget.onAlle),
          ),
      ],
    );
  }

  Widget _eintrag(BuildContext context, int i, double breite, Interval kurve, MFarben f, L l) {
    final d = widget.defs[i];
    final vorn = widget.aufgedeckt.contains(i);
    final anim = CurvedAnimation(parent: _c, curve: kurve);
    return SlideTransition(
      position: Tween(begin: const Offset(0.9, 0), end: Offset.zero).animate(anim),
      child: FadeTransition(
        opacity: anim,
        child: SizedBox(
          width: breite,
          child: Column(
            children: [
              KartenKarte(
                key: ValueKey('belohnung-karte-$i'),
                def: d,
                figur: kartenFigurVon(widget.figuren, d),
                breite: breite,
                aufgedeckt: vorn,
                umdrehbar: true,
                onUmgedreht: (v) => widget.onUmgedreht(i, v),
                rueckseitenSemantik: l.abend_belohnung_verdeckt(i + 1, widget.defs.length),
              ),
              const SizedBox(height: MMass.s8),
              SizedBox(
                height: 32,
                child: AnimatedOpacity(
                  duration: MBewegung.schnell(context),
                  opacity: vorn ? 1 : 0,
                  child: vorn
                      ? (widget.neu.contains(d.id) ? const NeuMarke() : MChip(l.abend_belohnung_doppelt, farbe: f.papierLeise))
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Erfahrungsleiste: füllt sich von der alten zur neuen Erfahrung. Bei einer
/// Beförderung läuft sie bis zum Rand, springt auf null und füllt sich im neuen
/// Rang; dazu stempelt der neue Rang. Ohne Bewegung steht sofort der Endstand.
class _Erfahrung extends StatefulWidget {
  const _Erfahrung({required this.belohnung});

  final AbendBelohnung belohnung;

  @override
  State<_Erfahrung> createState() => _ErfahrungState();
}

class _ErfahrungState extends State<_Erfahrung> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  bool _gestartet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gestartet) return;
    _gestartet = true;
    if (MBewegung.ruhig(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Füllstand (0..1) der Leiste zum Fortschritt [v] der Animation.
  double _stand(double v) {
    final b = widget.belohnung;
    final vorher = rankProgress(b.xpVorher);
    final nachher = rankProgress(b.xpNachher);
    // Die Leiste füllt sich im ersten Teil; ein Rangaufstieg braucht zwei Etappen.
    final fuell = Curves.easeInOutCubic.transform((v / 0.75).clamp(0.0, 1.0));
    if (!b.rangAufstieg) return vorher + (nachher - vorher) * fuell;
    return fuell < 0.5 ? vorher + (1 - vorher) * (fuell / 0.5) : nachher * ((fuell - 0.5) / 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final b = widget.belohnung;
    final next = nextRankXp(b.xpNachher);
    final rang = l.rankName(b.rangNachher);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.abend_belohnung_xp_titel.toUpperCase(), style: t.marke),
        const SizedBox(height: MMass.s8),
        Text(l.abend_belohnung_xp(b.xp), style: t.ueberschrift),
        const SizedBox(height: MMass.s12),
        Semantics(
          label: '${l.abend_belohnung_xp(b.xp)}, ${next == null ? l.hub_rank_max : l.hub_rank_progress(b.xpNachher, next)}',
          excludeSemantics: true,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                key: const ValueKey('belohnung-xp-leiste'),
                value: _stand(_c.value),
                minHeight: 10,
                color: f.akzent,
                backgroundColor: f.flaecheHoch,
              ),
            ),
          ),
        ),
        const SizedBox(height: MMass.s8),
        Text(next == null ? l.hub_rank_max : l.hub_rank_progress(b.xpNachher, next), style: t.leise),
        if (b.rangAufstieg) ...[
          const SizedBox(height: MMass.s20),
          Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                // Der Stempel fällt ein, wenn die Leiste voll war.
                final v = Curves.easeOutBack.transform(((_c.value - 0.7) / 0.3).clamp(0.0, 1.0));
                return Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.rotate(angle: -0.06, child: Transform.scale(scale: 1.6 - 0.6 * v, child: child)),
                );
              },
              child: Semantics(
                label: l.abend_belohnung_rang_semantik(rang),
                excludeSemantics: true,
                child: DecoratedBox(
                  key: const ValueKey('belohnung-rang-stempel'),
                  decoration: BoxDecoration(
                    border: Border.all(color: f.gefahr, width: 3),
                    borderRadius: BorderRadius.circular(MMass.r10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: MMass.s16, vertical: MMass.s12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RankBadge(rank: b.rangNachher, size: 40),
                        const SizedBox(width: MMass.s12),
                        Flexible(
                          child: Text(
                            l.abend_belohnung_rang_stempel(rang).toUpperCase(),
                            style: t.ueberschrift.copyWith(color: f.gefahr, letterSpacing: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
