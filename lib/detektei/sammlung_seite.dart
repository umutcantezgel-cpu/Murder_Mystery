import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/runden.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../karten/katalog_laden.dart';
import '../karten/widgets/karten_ansicht.dart';
import '../karten/widgets/karten_blatt.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../stil/stil.dart';
import 'akten.dart';

/// Kennung der Detektivklassen im Katalog (`content/karten/mordakte.json`).
const klassenAkte = 'mordakte';

/// Geladene Daten der Sammlung.
class _Daten {
  _Daten(this.katalog, this.akten, this.figuren);

  final KartenKatalog katalog;
  final List<AkteInfo> akten;
  final Map<String, Map<String, KartenFigur>> figuren;

  /// Reiter: Akten der Kampagne mit Karten in Reihenfolge, weitere Akten
  /// alphabetisch, zuletzt die Detektivklassen.
  List<String> get reiter {
    final mitKarten = {for (final k in katalog.alle) k.akte};
    final r = <String>[
      for (final a in akten)
        if (mitKarten.contains(a.id) && a.id != klassenAkte) a.id,
    ];
    final rest = [for (final id in mitKarten) if (!r.contains(id) && id != klassenAkte) id]..sort();
    return [...r, ...rest, if (mitKarten.contains(klassenAkte)) klassenAkte];
  }

  String titel(L l, String akte) {
    if (akte == klassenAkte) return l.karten_tab_klassen;
    return akten.where((a) => a.id == akte).firstOrNull?.titel ?? akte;
  }
}

/// Sammlung (Route `/sammlung`): die Karten je Akte und die Detektivklassen,
/// gruppiert nach Figur. Besessene Karten liegen offen, unbekannte verdeckt mit
/// Silhouette. Ein Tipp öffnet die große Kartenansicht.
class SammlungSeite extends StatefulWidget {
  const SammlungSeite({super.key});

  @override
  State<SammlungSeite> createState() => _SammlungSeiteState();
}

class _SammlungSeiteState extends State<SammlungSeite> {
  late final MetaStore _meta = context.read<MetaStore>();
  late Future<_Daten> _laden = _ladeDaten();
  String? _reiter;

  Future<_Daten> _ladeDaten() async {
    final katalog = await kartenBereit(_meta);
    List<AkteInfo> akten;
    try {
      akten = await AktenKatalog.laden();
    } catch (_) {
      akten = const [];
    }
    return _Daten(katalog, akten, await ladeAlleKartenFiguren(katalog));
  }

  void _nochmal() => setState(() => _laden = _ladeDaten());

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return FutureBuilder<_Daten>(
      future: _laden,
      builder: (context, snap) {
        final daten = snap.data;
        final reiter = daten == null ? const <String>[] : daten.reiter;
        final aktiv = reiter.contains(_reiter) ? _reiter : (reiter.isEmpty ? null : reiter.first);
        return AkteThema(
          akte: aktiv == null || aktiv == klassenAkte ? '' : aktiv,
          child: Builder(
            builder: (context) => Scaffold(
              backgroundColor: MFarben.von(context).grund,
              body: MRahmen(
                titel: l.karten_sammlung_titel,
                untertitel: l.karten_sammlung_text,
                aktionen: [
                  MKnopf(text: l.common_back, art: MKnopfArt.zweit, icon: Icons.arrow_back_rounded, onPressed: () => context.go(Routes.start)),
                  MKnopf(text: l.karten_deck_bearbeiten, icon: Icons.style_rounded, onPressed: () => context.push(Routes.sammlungDeck)),
                ],
                child: _inhalt(context, snap, daten, aktiv),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _inhalt(BuildContext context, AsyncSnapshot<_Daten> snap, _Daten? daten, String? aktiv) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    if (snap.hasError) {
      return MTafel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.karten_fehler, style: t.text),
            const SizedBox(height: MMass.s12),
            MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: _nochmal),
          ],
        ),
      );
    }
    if (daten == null) return Padding(padding: const EdgeInsets.symmetric(vertical: MMass.s32), child: Text(l.karten_laedt, textAlign: TextAlign.center, style: t.leise));
    final meta = context.watch<MetaStore>();
    if (aktiv == null) return Text(l.karten_sammlung_leer, style: t.leise);
    final reiter = daten.reiter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: MMass.s8,
          runSpacing: MMass.s8,
          children: [
            for (final id in reiter)
              _Reiter(
                text: daten.titel(l, id),
                gewaehlt: id == aktiv,
                onTap: () => setState(() => _reiter = id),
              ),
          ],
        ),
        const SizedBox(height: MMass.s16),
        _Akte(daten: daten, akte: aktiv, meta: meta),
      ],
    );
  }
}

/// Ein Reiter: Akte oder Detektivklassen.
class _Reiter extends StatelessWidget {
  const _Reiter({required this.text, required this.gewaehlt, required this.onTap});

  final String text;
  final bool gewaehlt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    return Semantics(
      button: true,
      selected: gewaehlt,
      inMutuallyExclusiveGroup: true,
      label: text,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: gewaehlt ? f.akzentSchwach : f.flaeche,
        shape: StadiumBorder(side: BorderSide(color: gewaehlt ? f.akzent : f.linie)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MMass.s16, vertical: MMass.s8),
              child: Center(
                widthFactor: 1,
                child: Text(text, style: t.text.copyWith(fontSize: 15, fontWeight: gewaehlt ? FontWeight.w700 : FontWeight.w500, color: gewaehlt ? f.akzentHell : f.papier)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fortschritt und Karten einer Akte, nach Figur gruppiert.
class _Akte extends StatelessWidget {
  const _Akte({required this.daten, required this.akte, required this.meta});

  final _Daten daten;
  final String akte;
  final MetaStore meta;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final karten = daten.katalog.vonAkte(akte);
    final figuren = daten.figuren[akte] ?? const <String, KartenFigur>{};
    final gruppen = <String, List<KartenDef>>{};
    for (final k in karten) {
      (gruppen[k.figur] ??= []).add(k);
    }
    // Figuren in der Reihenfolge der Akte, unbekannte danach in Katalogreihenfolge.
    final reihenfolge = [
      for (final id in figuren.keys) if (gruppen.containsKey(id)) id,
      for (final id in gruppen.keys) if (!figuren.containsKey(id)) id,
    ];
    final gesamt = karten.length;
    final besessen = karten.where((k) => meta.besitztKarte(k.id)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.karten_sammlung_fortschritt(besessen, gesamt), style: t.ueberschrift.copyWith(fontSize: 18)),
        const SizedBox(height: MMass.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: gesamt == 0 ? 0 : besessen / gesamt,
            minHeight: 6,
            color: f.akzent,
            backgroundColor: f.flaecheHoch,
          ),
        ),
        const SizedBox(height: MMass.s20),
        if (karten.isEmpty) Text(l.karten_sammlung_leer, style: t.leise),
        LayoutBuilder(
          builder: (context, box) {
            const abstand = MMass.s12;
            final spalten = box.maxWidth >= 640 ? 4 : (box.maxWidth >= 420 ? 3 : 2);
            final breite = (box.maxWidth - abstand * (spalten - 1)) / spalten;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final id in reihenfolge)
                  _Figur(
                    figurId: id,
                    figur: figuren[id],
                    karten: gruppen[id]!,
                    meta: meta,
                    kartenBreite: breite,
                    abstand: abstand,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Eine Figur (oder Klasse) mit ihren Karten.
class _Figur extends StatelessWidget {
  const _Figur({
    required this.figurId,
    required this.figur,
    required this.karten,
    required this.meta,
    required this.kartenBreite,
    required this.abstand,
  });

  final String figurId;
  final KartenFigur? figur;
  final List<KartenDef> karten;
  final MetaStore meta;
  final double kartenBreite;
  final double abstand;

  String _name(L l) {
    if (figur != null) return figur!.name;
    if (figurId.startsWith('klasse:')) return l.className(figurId.substring('klasse:'.length));
    return figurId;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final name = _name(l);
    final besessen = karten.where((k) => meta.besitztKarte(k.id)).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                if (figur?.look != null) ...[
                  MPortrait(look: figur!.look!, groesse: 36, kreis: true),
                  const SizedBox(width: MMass.s12),
                ],
                Expanded(child: Text(name, style: t.ueberschrift.copyWith(fontSize: 18))),
                Text(l.karten_figur_fortschritt(besessen, karten.length), style: t.leise),
              ],
            ),
          ),
          const SizedBox(height: MMass.s12),
          Wrap(
            spacing: abstand,
            runSpacing: abstand,
            children: [
              for (final k in karten)
                SizedBox(
                  width: kartenBreite,
                  child: _Kachel(def: k, figur: figur, figurName: name, besitz: meta.besitz[k.id], meta: meta),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Eine Karte der Sammlung: offen (besessen) oder verdeckt mit Silhouette.
class _Kachel extends StatelessWidget {
  const _Kachel({required this.def, required this.figur, required this.figurName, required this.besitz, required this.meta});

  final KartenDef def;
  final KartenFigur? figur;
  final String figurName;
  final KartenBesitz? besitz;
  final MetaStore meta;

  Future<void> _oeffnen(BuildContext context) async {
    await zeigeKartenBlatt(context, def: def, figur: figur, figurName: figurName, anzahl: besitz?.n ?? 0);
    meta.markiereGesehen([def.id]);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final b = besitz;
    final bekannt = b != null;
    final semantik = bekannt
        ? [
            def.titel,
            KartenTexte.seltenheit(def.seltenheit),
            if (b.n > 1) l.karten_anzahl(b.n),
            if (b.neu) l.karten_neu,
          ].join(', ')
        : l.karten_unbekannt_semantik(figurName);
    return Semantics(
      button: true,
      label: semantik,
      onTap: () => _oeffnen(context),
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('karte-${def.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _oeffnen(context),
        child: Stack(
          children: [
            bekannt ? KartenKarte(def: def, figur: figur) : const UnbekannteKarte(),
            if (bekannt && b.neu) const Positioned(top: 6, left: 6, child: NeuMarke()),
            if (bekannt && b.n > 1)
              Positioned(
                right: 6,
                bottom: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: f.grund.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(MMass.r20), border: Border.all(color: f.linieStark)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(l.karten_anzahl(b.n), style: t.leise.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: f.papier)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
