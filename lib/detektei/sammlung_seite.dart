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
import '../ui/icons.dart';
import 'akte_bausteine.dart' show akteSamen;
import 'akten.dart';
import 'schreibtisch.dart';

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

/// Sammlung (Route `/sammlung`): der Karteikasten der Detektei. Reiter je Akte
/// und für die Detektivklassen, darunter die Karten gruppiert nach Figur, jede
/// Gruppe mit einer Kopfkarte (Fotoabzug, Name, Fortschritt). Besessene Karten
/// liegen offen, unbekannte verdeckt mit Silhouette. Ein Tipp öffnet die große
/// Kartenansicht.
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
                aktionen: [
                  MKnopf(text: l.common_back, art: MKnopfArt.zweit, icon: Icons.arrow_back_rounded, onPressed: () => context.go(Routes.start)),
                  MKnopf(text: l.karten_deck_bearbeiten, icon: Icons.style_rounded, onPressed: () => context.push(Routes.sammlungDeck)),
                ],
                // Eigener Kopf wie der des Rahmens, aber ohne Wortbruch bei großer Schrift.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GanzeWorte(l.karten_sammlung_titel, style: MSchrift.von(context).titel),
                    const SizedBox(height: 6),
                    Text(l.karten_sammlung_text, style: MSchrift.von(context).leise),
                    const SizedBox(height: MMass.s20),
                    _inhalt(context, snap, daten, aktiv),
                  ],
                ),
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
      return MBlatt(
        art: PapierArt.notiz,
        neigung: -0.006,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.karten_fehler, style: MPapierSchrift.text),
            const SizedBox(height: MMass.s12),
            Align(alignment: Alignment.centerLeft, child: MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: _nochmal)),
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
          spacing: 4,
          runSpacing: MMass.s8,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            for (final id in reiter)
              _Reiter(
                text: daten.titel(l, id),
                gewaehlt: id == aktiv,
                onTap: () => setState(() => _reiter = id),
              ),
          ],
        ),
        // Die Kante des Karteikastens unter den Reitern.
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: MRoh.blatt,
            border: Border(top: BorderSide(color: MFarben.von(context).akzent, width: 2)),
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        const SizedBox(height: MMass.s20),
        _Akte(daten: daten, akte: aktiv, meta: meta),
      ],
    );
  }
}

/// Ein Reiter des Karteikastens: Akte oder Detektivklassen. Der gewählte steht
/// hell und höher, mit einer Kante im Akzent der Akte.
class _Reiter extends StatelessWidget {
  const _Reiter({required this.text, required this.gewaehlt, required this.onTap});

  final String text;
  final bool gewaehlt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    return Semantics(
      button: true,
      selected: gewaehlt,
      inMutuallyExclusiveGroup: true,
      label: text,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: MBewegung.schnell(context),
          constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
          padding: EdgeInsets.fromLTRB(14, gewaehlt ? 14 : 10, 14, 8),
          decoration: BoxDecoration(
            color: gewaehlt ? MRoh.blatt : Color.lerp(MRoh.manila, MRoh.manilaDunkel, 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            border: Border(top: BorderSide(color: gewaehlt ? f.akzent : Colors.transparent, width: 3)),
            boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 3, offset: Offset(0, -1))],
          ),
          child: Text(
            text,
            style: MRohSchrift.schreibmaschine.copyWith(fontSize: 14, height: 1.3, color: gewaehlt ? MRoh.tinte : const Color(0xFF4A3A28)),
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
        // Bestandskarte: wie viele Karten dieser Akte im Kasten liegen.
        MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 6,
          linien: false,
          neigung: -0.004,
          samen: akteSamen(akte),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.karten_sammlung_fortschritt(besessen, gesamt), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
              const SizedBox(height: MMass.s8),
              TintenBalken(wert: gesamt == 0 ? 0 : besessen / gesamt, hoehe: 10),
            ],
          ),
        ),
        const SizedBox(height: MMass.s24),
        if (karten.isEmpty) Text(l.karten_sammlung_leer, style: t.leise),
        LayoutBuilder(
          builder: (context, box) {
            const abstand = MMass.s12;
            final spalten = box.maxWidth >= 640 ? 4 : (box.maxWidth >= 420 ? 3 : 2);
            final breite = (box.maxWidth - abstand * (spalten - 1)) / spalten;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < reihenfolge.length; i++)
                  _Figur(
                    figurId: reihenfolge[i],
                    figur: figuren[reihenfolge[i]],
                    karten: gruppen[reihenfolge[i]]!,
                    meta: meta,
                    kartenBreite: breite,
                    abstand: abstand,
                    nr: i,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Eine Figur (oder Klasse) mit ihren Karten: oben eine Kopfkarte mit Fotoabzug
/// (bei Klassen ein Messingabzeichen), Name und Fortschritt, darunter die Karten.
class _Figur extends StatelessWidget {
  const _Figur({
    required this.figurId,
    required this.figur,
    required this.karten,
    required this.meta,
    required this.kartenBreite,
    required this.abstand,
    required this.nr,
  });

  final String figurId;
  final KartenFigur? figur;
  final List<KartenDef> karten;
  final MetaStore meta;
  final double kartenBreite;
  final double abstand;
  final int nr;

  String _name(L l) {
    if (figur != null) return figur!.name;
    if (figurId.startsWith('klasse:')) return l.className(figurId.substring('klasse:'.length));
    return figurId;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final name = _name(l);
    final besessen = karten.where((k) => meta.besitztKarte(k.id)).length;
    final look = figur?.look;
    final klasse = figurId.startsWith('klasse:') ? figurId.substring('klasse:'.length) : null;
    final gross = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final zaehler = Text(l.karten_figur_fortschritt(besessen, karten.length), style: MPapierSchrift.hand.copyWith(fontSize: 22));
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: MBlatt(
              art: PapierArt.karteikarte,
              kopfLinie: 6,
              linien: false,
              randFarbe: figur?.farbe,
              neigung: nr.isEven ? -0.003 : 0.004,
              samen: akteSamen(figurId),
              padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
              child: Row(
                children: [
                  if (look != null) ...[
                    ExcludeSemantics(child: MFotoabzug(look: look, groesse: 40, neigung: nr.isEven ? -0.05 : 0.04, akzent: figur?.farbe)),
                    const SizedBox(width: MMass.s12),
                  ] else if (klasse != null) ...[
                    _Abzeichen(icon: GameIcons.cls(klasse)),
                    const SizedBox(width: MMass.s12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GanzeWorte(name, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
                        if ((figur?.titel ?? '').isNotEmpty)
                          GanzeWorte(figur!.titel, style: MPapierSchrift.maschine.copyWith(fontSize: 12, height: 1.3, color: MRoh.tinteLeise)),
                        // Bei großer Schrift steht der Fortschritt unter dem Namen.
                        if (gross) zaehler,
                      ],
                    ),
                  ),
                  if (!gross) ...[const SizedBox(width: MMass.s8), zaehler],
                ],
              ),
            ),
          ),
          const SizedBox(height: MMass.s16),
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

/// Rundes Messingabzeichen mit dem Symbol einer Detektivklasse.
class _Abzeichen extends StatelessWidget {
  const _Abzeichen({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(center: Alignment(-0.35, -0.4), colors: [MRoh.messingHell, MRoh.messingMitte, MRoh.messingDunkel], stops: [0, 0.55, 1]),
          boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 2))],
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF3A2808)),
      );
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
          clipBehavior: Clip.none,
          children: [
            bekannt ? KartenKarte(def: def, figur: figur) : const UnbekannteKarte(),
            if (bekannt && b.neu) const Positioned(top: 6, left: 6, child: NeuMarke()),
            if (bekannt && b.n > 1)
              Positioned(
                right: 4,
                bottom: 6,
                // Anzahl als kleines Kartonetikett mit Schreibmaschinenziffer.
                child: Transform.rotate(
                  angle: -0.06,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: MRoh.karteikarte,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: MRoh.tinte.withValues(alpha: 0.35)),
                      boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(7, 2, 7, 1),
                      child: Text(l.karten_anzahl(b.n), style: MPapierSchrift.maschine.copyWith(fontSize: 13, height: 1.3)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
