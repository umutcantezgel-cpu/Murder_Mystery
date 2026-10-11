import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/runden.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../stil/stil.dart';
import 'katalog_laden.dart';
import 'widgets/karten_ansicht.dart';

/// Geladene Daten des Deck-Baus.
class _Daten {
  _Daten(this.katalog, this.figuren);

  final KartenKatalog katalog;
  final Map<String, Map<String, KartenFigur>> figuren;
}

/// Deck-Bau (Route `/sammlung/deck`): drei Plätze, besessene spielbare Karten
/// antippen zum Einsetzen oder Herausnehmen. Je Art liegt höchstens eine Karte
/// im Deck (eine Karte gleicher Art ersetzt die bisherige), zusammen höchstens
/// vier Ladungen. Jede Änderung wird sofort im [MetaStore] gespeichert.
class DeckSeite extends StatefulWidget {
  const DeckSeite({super.key});

  @override
  State<DeckSeite> createState() => _DeckSeiteState();
}

class _DeckSeiteState extends State<DeckSeite> {
  late final MetaStore _meta = context.read<MetaStore>();
  late Future<_Daten> _laden = _ladeDaten();
  String? _hinweis;

  Future<_Daten> _ladeDaten() async {
    final katalog = await kartenBereit(_meta);
    return _Daten(katalog, await ladeAlleKartenFiguren(katalog));
  }

  void _zurueck() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.sammlung);
    }
  }

  /// Karte einsetzen oder herausnehmen; die Regeln des Tischvorrats gelten.
  void _tippe(_Daten d, KartenDef k) {
    final l = L.of(context);
    final deck = [..._meta.deck];
    if (deck.contains(k.id)) {
      deck.remove(k.id);
      setState(() => _hinweis = null);
      _meta.setzeDeck(deck, katalog: d.katalog);
      return;
    }
    final gleicheArt = deck.indexWhere((id) => d.katalog[id]?.art == k.art);
    if (gleicheArt >= 0) {
      deck[gleicheArt] = k.id;
    } else if (deck.length >= TischVorrat.maxKarten) {
      setState(() => _hinweis = l.karten_deck_voll);
      return;
    } else {
      deck.add(k.id);
    }
    final ladungen = deck.fold<int>(0, (s, id) => s + (d.katalog[id]?.ladungen ?? 0));
    if (ladungen > TischVorrat.maxLadungen) {
      setState(() => _hinweis = l.karten_deck_zuviel);
      return;
    }
    setState(() => _hinweis = null);
    _meta.setzeDeck(deck, katalog: d.katalog);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    return Scaffold(
      backgroundColor: f.grund,
      body: MRahmen(
        titel: l.karten_deck_titel,
        untertitel: l.karten_deck_text,
        aktionen: [MKnopf(text: l.karten_deck_fertig, icon: Icons.check_rounded, onPressed: _zurueck)],
        child: FutureBuilder<_Daten>(
          future: _laden,
          builder: (context, snap) {
            final t = MSchrift.von(context);
            if (snap.hasError) {
              return MTafel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.karten_fehler, style: t.text),
                    const SizedBox(height: MMass.s12),
                    MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: () => setState(() => _laden = _ladeDaten())),
                  ],
                ),
              );
            }
            final d = snap.data;
            if (d == null) {
              return Padding(padding: const EdgeInsets.symmetric(vertical: MMass.s32), child: Text(l.karten_laedt, textAlign: TextAlign.center, style: t.leise));
            }
            return _Bau(daten: d, hinweis: _hinweis, onTipp: (k) => _tippe(d, k));
          },
        ),
      ),
    );
  }
}

class _Bau extends StatelessWidget {
  const _Bau({required this.daten, required this.hinweis, required this.onTipp});

  final _Daten daten;
  final String? hinweis;
  final ValueChanged<KartenDef> onTipp;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final meta = context.watch<MetaStore>();
    final deck = [for (final id in meta.deck) if (daten.katalog[id] != null) daten.katalog[id]!];
    final ladungen = deck.fold<int>(0, (s, k) => s + k.ladungen);
    final eigene = [
      for (final k in daten.katalog.alle)
        if (k.art.spielbar && meta.besitztKarte(k.id)) k,
    ];
    return LayoutBuilder(
      builder: (context, box) {
        const abstand = MMass.s12;
        final spalten = box.maxWidth >= 640 ? 4 : 3;
        final breite = (box.maxWidth - abstand * (spalten - 1)) / spalten;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < TischVorrat.maxKarten; i++) ...[
                  if (i > 0) const SizedBox(width: abstand),
                  SizedBox(
                    width: breite,
                    child: _Platz(
                      nummer: i + 1,
                      def: i < deck.length ? deck[i] : null,
                      figuren: daten.figuren,
                      onTipp: onTipp,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: MMass.s12),
            Text(l.karten_deck_ladungen(ladungen, TischVorrat.maxLadungen), style: t.leise),
            if (hinweis != null)
              Padding(
                padding: const EdgeInsets.only(top: MMass.s8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(hinweis!, style: t.text.copyWith(fontSize: 15, color: f.warnung)),
                ),
              ),
            const SizedBox(height: MMass.s24),
            Text(l.karten_deck_deine.toUpperCase(), style: t.marke),
            const SizedBox(height: MMass.s12),
            if (eigene.isEmpty) Text(l.karten_deck_keine, style: t.leise),
            Wrap(
              spacing: abstand,
              runSpacing: abstand,
              children: [
                for (final k in eigene)
                  SizedBox(
                    width: breite,
                    child: _Auswahl(
                      def: k,
                      figur: kartenFigurVon(daten.figuren, k),
                      imDeck: deck.any((d) => d.id == k.id),
                      anzahl: meta.kartenAnzahl(k.id),
                      onTipp: onTipp,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Ein Platz des Decks: die eingesetzte Karte (Tipp nimmt sie heraus) oder leer.
class _Platz extends StatelessWidget {
  const _Platz({required this.nummer, required this.def, required this.figuren, required this.onTipp});

  final int nummer;
  final KartenDef? def;
  final Map<String, Map<String, KartenFigur>> figuren;
  final ValueChanged<KartenDef> onTipp;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final k = def;
    final platz = l.karten_deck_platz(nummer);
    if (k == null) {
      return Semantics(
        label: '$platz: ${l.karten_deck_leer}',
        excludeSemantics: true,
        child: AspectRatio(
          aspectRatio: MMass.kartenSeiten,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: f.flaeche.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(MMass.r14),
              border: Border.all(color: f.linieStark),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: f.papierLeise, size: 28),
                  const SizedBox(height: MMass.s4),
                  Text(l.karten_deck_leer, style: t.leise),
                  Text(platz, style: t.leise.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      label: '$platz: ${l.karten_deck_entfernen(k.titel)}',
      onTap: () => onTipp(k),
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('deck-platz-${k.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onTipp(k),
        child: KartenKarte(def: k, figur: kartenFigurVon(figuren, k)),
      ),
    );
  }
}

/// Eine besessene spielbare Karte zur Auswahl; ein Haken zeigt, dass sie im Deck liegt.
class _Auswahl extends StatelessWidget {
  const _Auswahl({required this.def, required this.figur, required this.imDeck, required this.anzahl, required this.onTipp});

  final KartenDef def;
  final KartenFigur? figur;
  final bool imDeck;
  final int anzahl;
  final ValueChanged<KartenDef> onTipp;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final text = imDeck ? l.karten_deck_entfernen(def.titel) : l.karten_deck_einsetzen(def.titel);
    return Semantics(
      button: true,
      selected: imDeck,
      label: '$text, ${KartenTexte.art(def.art)}, ${KartenTexte.ladungen(def.ladungen)}',
      onTap: () => onTipp(def),
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('deck-karte-${def.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onTipp(def),
        child: Stack(
          children: [
            Opacity(opacity: imDeck ? 0.55 : 1, child: KartenKarte(def: def, figur: figur)),
            if (imDeck)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MMass.r14),
                    border: Border.all(color: f.akzent, width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    // Bei schmalen Karten oder großer Schrift schrumpft die ganze Marke,
                    // statt den Text zu kürzen.
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(MMass.s4, 0, MMass.s4, MMass.s8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: MChip(l.karten_deck_drin, icon: Icons.check_rounded, gefuellt: true, passend: true),
                      ),
                    ),
                  ),
                ),
              ),
            if (anzahl > 1)
              Positioned(
                right: 6,
                top: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: f.grund.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(MMass.r20), border: Border.all(color: f.linieStark)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(l.karten_anzahl(anzahl), style: t.leise.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: f.papier)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
