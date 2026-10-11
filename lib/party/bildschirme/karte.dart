import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../../game/game_view.dart';
import '../../game/szenen_erweiterung.dart';
import '../../karten/widgets/karten_ansicht.dart';
import '../../karten/widgets/karten_hand.dart';
import '../../stil/stil.dart' show MFarben, MSchrift;
import '../karte_session.dart';
import '../karten_figur.dart';
import '../party_stil.dart';
import '../sitzung.dart';
import 'abstecher.dart';
import 'npc_karte.dart';
import 'solo_gespraeche.dart';
import 'zug_tafel.dart';

/// Die Entscheidungen des Detektivs auf der Karte (F4-ORCH-01, Master 7.7):
/// Frage oben, die Ziele der laufenden Entscheidung leuchten auf der Karte.
/// Eine Handlung macht einen Vorschlag; erst „Das ist endgültig“ wählt.
class KartenBildschirm extends StatefulWidget {
  const KartenBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<KartenBildschirm> createState() => _KartenBildschirmState();
}

class _KartenBildschirmState extends State<KartenBildschirm> {
  late final PartyKartenSession _session;
  late final TileGrid _raster;
  /// Der Kopf ist zunächst kompakt: Frage und eine Zeile Stand. Der Pfeil klappt
  /// den Hinweis zur Steuerung auf.
  bool _hinweisOffen = false;
  bool _gruendlich = false;

  /// Gemessene Höhen der Bedienfelder über der Karte; die Kamera legt den
  /// Ausschnitt in den freien Rest dazwischen.
  double _kopfHoehe = 170;
  double _leisteHoehe = 150;

  /// Eingesetzte Gründlich-Karte der Entscheidung, die gerade bestätigt wird.
  String? _gruendlichKarte;

  /// Abstecher, dessen Bestätigung gerade offen ist.
  AbstecherOrt? _abstecher;

  PartySitzung get s => widget.sitzung;

  @override
  void initState() {
    super.initState();
    _session = PartyKartenSession(s);
    _raster = TileGrid(s.daten.szenario.map);
    s.detektivSetzen.addListener(_setzeDetektiv);
    s.detektivAn.addListener(_detektivAn);
    _detektivAn();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ein Bildschirmleser ist kein Wunsch nach weniger Bewegung. Nur die
    // ausdrückliche Systemeinstellung kürzt den sichtbaren Lauf ab.
    _session.bewegungReduziert = MediaQuery.disableAnimationsOf(context);
    if (_session.bewegungReduziert) _session.aktionAbkuerzen();
  }

  /// Entwickler-Einstieg `at=x,y`: Detektiv an eine feste Stelle.
  void _detektivAn() {
    final p = s.detektivAn.value;
    if (p != null) _session.setzeDetektiv(p.$1, p.$2);
  }

  @override
  void dispose() {
    s.detektivSetzen.removeListener(_setzeDetektiv);
    s.detektivAn.removeListener(_detektivAn);
    _session.dispose();
    super.dispose();
  }

  /// Entwickler-Skript: Detektiv neben ein Ziel stellen.
  void _setzeDetektiv() {
    final z = s.detektivSetzen.value;
    if (z == null) return;
    final (x, y) = _nebenZiel(z);
    _session.setzeDetektiv(x, y, facing: 0.8);
  }

  (double, double) _nebenZiel(KartenZiel z) {
    double zx, zy;
    if (z.person != null) {
      final f = s.karte.figuren.firstWhere((f) => f.id == z.person);
      (zx, zy) = (f.x, f.y);
    } else {
      (zx, zy) = (z.x! + 0.5, z.y! + 0.5);
    }
    const nachbarn = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (-1, 1), (1, -1), (-1, -1)];
    for (final (dx, dy) in nachbarn) {
      final tx = zx.floor() + dx, ty = zy.floor() + dy;
      if (_raster.walkable(tx, ty) && s.kanon.graph.raumAn(tx + 0.5, ty + 0.5)?.id == z.raum) return (tx + 0.5, ty + 0.5);
    }
    return (zx, zy);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final e = s.laufendeEntscheidung;
          final fund = s.letzterFund;
          final vorschlag = s.vorschlag;
          final zug = s.zug;
          final aktiveFrage = zug != null && !zug.istAuftakt && !zug.istAbstecher ? s.spiel.ermittlung.entscheidung(zug.id) : e;
          final f = MFarben.von(context);
          final rand = MediaQuery.paddingOf(context);
          final aktion = zug?.phase == RundenZugPhase.aktion;
          return LayoutBuilder(builder: (context, box) => Stack(
            children: [
              Positioned.fill(child: GameView(
                session: _session,
                steuerung: !_session.eingabeGesperrt,
                kameraPassend: true,
                // Kopf oben, in der Aktion die Leiste unten; sonst Platz für Joystick und Knopf.
                sichtRand: SzenenRand(
                  oben: rand.top + _kopfHoehe,
                  unten: rand.bottom + (aktion ? _leisteHoehe + 12 : 56),
                ),
                umgebung: SzenenUmgebung(mitte: Color.lerp(f.nachtOben, f.schein, 0.1)!, rand: f.grund),
              )),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: Keller.breite),
                      // Auch bei 200-%-Schrift bleibt eine sichtbare Kartenbühne.
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: box.maxHeight * 0.44),
                        child: _Misst(
                          onSize: (g) {
                            if (mounted && (g.height - _kopfHoehe).abs() > 0.5) setState(() => _kopfHoehe = g.height);
                          },
                          child: SingleChildScrollView(child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: _kopf(fund != null ? s.spiel.ermittlung.entscheidung(fund.entscheidung) : aktiveFrage),
                          )),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (vorschlag != null) _abgedeckt(_bestaetigung(vorschlag)),
              if (_abstecher != null && zug == null && vorschlag == null && fund == null) _abgedeckt(AbstecherBestaetigung(
                key: ValueKey('abstecher-${_abstecher!.id}'),
                sitzung: s,
                ort: _abstecher!,
                onAbbruch: () => setState(() => _abstecher = null),
                onLos: (karte) {
                  final ort = _abstecher!;
                  setState(() => _abstecher = null);
                  s.starteAbstecher(ort.id, karte: karte);
                },
              )),
              if (zug?.phase == RundenZugPhase.aktion) Positioned(
                left: 12, right: 12, bottom: 12,
                child: SafeArea(top: false, child: _Misst(
                  onSize: (g) {
                    if (mounted && (g.height - _leisteHoehe).abs() > 0.5) setState(() => _leisteHoehe = g.height);
                  },
                  child: ValueListenableBuilder<double>(
                    valueListenable: _session.aktionsFortschritt,
                    builder: (context, fortschritt, _) => _aktionsLeiste(fortschritt),
                  ),
                )),
              ),
              if (zug?.phase == RundenZugPhase.wurf) _abgedeckt(WuerfelTafel(key: ValueKey(zug!.aktion), sitzung: s)),
              if (zug?.phase == RundenZugPhase.tischruf) _abgedeckt(TischrufTafel(sitzung: s)),
              if (fund != null) _abgedeckt(Column(mainAxisSize: MainAxisSize.min, children: [
                if (zug?.wurf case final wurf?) ...[
                  WurfErgebnis(sitzung: s, wurf: wurf),
                  const SizedBox(height: 12),
                ],
                FundKarte(sitzung: s, ziel: fund.ziel, funde: fund.funde, onGelesen: s.fundGelesen),
              ])),
              if (zug?.istAbstecher == true && zug?.phase == RundenZugPhase.fund) _abgedeckt(Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WurfErgebnis(sitzung: s, wurf: zug!.wurf!),
                  const SizedBox(height: 12),
                  AbstecherFundKarte(sitzung: s, ort: s.abstecherLaufend!, text: zug.nebenfund ?? '', onGelesen: s.fundGelesen),
                ],
              )),
              if (zug?.istAuftakt == true && zug?.phase == RundenZugPhase.fund) _abgedeckt(Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WurfErgebnis(sitzung: s, wurf: zug!.wurf!),
                  const SizedBox(height: 12),
                  PartyKnopf(text: s.ui('ui.zug.auftakt_weiter'), onPressed: s.fundGelesen),
                ],
              )),
              if (s.kannWeiter && e == null && fund == null && vorschlag == null && _abstecher == null) _abgedeckt(_fertig()),
            ],
          ));
        },
      );

  Widget _aktionsLeiste(double fortschritt) {
    final fehler = _session.aktionsFehler.value;
    final zug = s.zug!;
    final beschreibung = fehler ? 'ui.zug.blockiert' : switch (_session.figurenPose) {
      SzenenPose.gehen => zug.ruf == Tischruf.umweg ? 'ui.zug.umweg' : 'ui.zug.weg',
      SzenenPose.befragen => 'ui.zug.befragen',
      _ => 'ui.zug.suchen',
    };
    return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: Keller.breite), child: PartyTafel(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(zug.istAuftakt ? s.ui('ui.zug.auftakt') : zug.istAbstecher ? s.abstecherLaufend!.name : s.karte.ziele[zug.option]!.name, style: Keller.ueberschrift),
        const SizedBox(height: 6),
        Text(s.ui(beschreibung), style: Keller.leise),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: fortschritt, color: context.farben.akzent, backgroundColor: Keller.steinHell),
        const SizedBox(height: 10),
        PartyKnopf(text: s.ui('ui.zug.kurz'), haupt: false, onPressed: fehler ? null : _session.aktionAbkuerzen),
      ]),
    )));
  }

  Widget _kopf(Entscheidung? e) {
    if (e == null) return const SizedBox.shrink();
    final nr = (e.runde - 1) * 3 + e.nr;
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final entscheidung = s.zug == null;
    return PartyTafel(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Marke, rechts der Pfeil für den Hinweis.
          Row(
            children: [
              Expanded(child: Text(s.ui('ui.karte.entscheidung', {'nr': '$nr'}).toUpperCase(), style: t.marke)),
              if (entscheidung) IconButton(
                tooltip: s.ui('ui.allgemein.weiter'),
                onPressed: () => setState(() => _hinweisOffen = !_hinweisOffen),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                icon: Icon(_hinweisOffen ? Icons.expand_less : Icons.expand_more, color: f.papierLeise),
              ) else const SizedBox(height: 14),
            ],
          ),
          Text(e.frage, style: t.ueberschrift),
          // Eine Zeile Stand: Uhrzeit, bei den Würfeln auch Nachtminuten und Marken.
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            children: [
              Text(s.ui('ui.allgemein.uhrzeit', {'uhrzeit': s.rundenUhrzeit}), style: t.leise.copyWith(fontSize: 13)),
              if (s.mitWuerfel) Text('${s.ui('ui.zug.nachtzeit', {'min': '${s.restMinuten}'})} · ${s.ui('ui.zug.marken', {'zahl': '${s.marken}'})}', style: t.leise.copyWith(fontSize: 13)),
            ],
          ),
          if (_hinweisOffen && entscheidung) ...[
            const SizedBox(height: 8),
            Text(s.ui('ui.karte.hinweis'), style: t.leise),
          ],
          if (entscheidung) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  style: _kleinerKnopf(f),
                  onPressed: () => _liste(e),
                  icon: const Icon(Icons.list_rounded, size: 18),
                  label: Text(s.ui('ui.karte.liste')),
                ),
                OutlinedButton.icon(
                  style: _kleinerKnopf(f),
                  onPressed: _notizbuch,
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: Text(s.ui('ui.karte.notizbuch')),
                ),
              ],
            ),
          ],
          if (s.hatKarten && entscheidung) ...[
            const SizedBox(height: 4),
            Center(child: KartenHand(
              vorrat: s.vorrat,
              aktiv: {for (final k in s.vorrat.karten) if (_sofortSpielbar(k)) k.id},
              kompakt: true,
              figurVon: s.kartenFigur,
              onTipp: _karteDialog,
            )),
          ],
        ],
      ),
    );
  }

  /// Sofortkarten (Zeit, Marke, Erinnerung), die jetzt gespielt werden dürfen.
  bool _sofortSpielbar(KartenDef k) {
    if (s.zug != null || s.vorschlag != null || s.letzterFund != null) return false;
    try {
      s.vorrat.pruefe(k.id, const {KartenArt.zeit, KartenArt.marke, KartenArt.erinnerung}, runde: s.runde);
      return true;
    } on KartenFehler {
      return false;
    }
  }

  /// Große Ansicht einer Handkarte mit „Spielen“. Eine Erinnerung öffnet danach
  /// das Notizbuch mit den bereits öffentlichen Sprechblasen.
  Future<void> _karteDialog(KartenDef k) => showDialog<void>(
        context: context,
        builder: (c) {
          final spielbar = _sofortSpielbar(k);
          final sofort = k.art == KartenArt.zeit || k.art == KartenArt.marke || k.art == KartenArt.erinnerung;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(child: PartyTafel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: KartenKarte(def: k, figur: s.kartenFigur(k), breite: 150)),
                  const SizedBox(height: 12),
                  Text(k.titel, style: Keller.ueberschrift, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(k.text, style: Keller.text, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    spielbar ? KartenTexte.handSpielbar : sofort ? KartenTexte.handGesperrt : KartenTexte.handImZug,
                    style: Keller.leise, textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      PartyKnopf(text: KartenTexte.handSchliessen, haupt: false, onPressed: () => Navigator.of(c).pop()),
                      PartyKnopf(text: KartenTexte.handSpielen, onPressed: spielbar ? () {
                        Navigator.of(c).pop();
                        s.karteSpielen(k.id);
                        if (k.art == KartenArt.erinnerung) _notizbuch();
                      } : null),
                    ],
                  ),
                ],
              ),
            )),
          );
        },
      );

  /// Einträge „Erkunden: Name“ der offenen Abstecher (leer, wenn keiner offen ist).
  List<Widget> _erkunden({VoidCallback? vorher}) => [
        if (s.abstecherOffen.isNotEmpty) ...[
          Text(KartenTexte.erkundenListe.toUpperCase(), style: context.schrift.marke),
          const SizedBox(height: 8),
          for (final a in s.abstecherOffen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PartyKnopf(
                text: KartenTexte.erkunden(a.name),
                haupt: false,
                icon: Icons.explore_rounded,
                onPressed: () {
                  vorher?.call();
                  setState(() => _abstecher = a);
                },
              ),
            ),
        ],
      ];

  /// Kleine Knöpfe im Kopf: mit Rahmen, damit sie als Knöpfe erkennbar sind (B7).
  static ButtonStyle _kleinerKnopf(MFarben f) => OutlinedButton.styleFrom(
        foregroundColor: f.akzentHell,
        side: BorderSide(color: f.linieStark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        visualDensity: VisualDensity.compact,
      );

  Widget _abgedeckt(Widget kind) => Positioned.fill(
        child: ColoredBox(
          color: const Color(0x99000000),
          child: SafeArea(child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: kind)),
            ),
          )),
        ),
      );

  Widget _bestaetigung(KartenZiel z) {
    final o = s.spiel.ermittlung.entscheidung(z.entscheidung).option(z.option);
    return PartyTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(z.name.toUpperCase(), style: context.schrift.marke),
          const SizedBox(height: 8),
          Text(o.text, style: Keller.ueberschrift),
          const SizedBox(height: 10),
          Text(s.ui('ui.karte.endgueltig'), style: Keller.text),
          if (s.mitWuerfel) ...[
            const SizedBox(height: 8),
            Text(s.ui('ui.zug.wahl_bindung'), style: Keller.leise),
          ],
          if (s.mitWuerfel && istSuche(s.spiel.ermittlung.entscheidung(z.entscheidung))) Material(color: Colors.transparent, child: CheckboxListTile(
            value: _gruendlich,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(s.ui('ui.zug.gruendlich'), style: Keller.leise),
            onChanged: (wert) => setState(() {
              _gruendlich = wert ?? false;
              if (!_gruendlich) _gruendlichKarte = null;
            }),
          )),
          if (s.hatKarten && istSuche(s.spiel.ermittlung.entscheidung(z.entscheidung))) ...[
            const SizedBox(height: 8),
            Center(child: KartenHand(
              vorrat: s.vorrat,
              aktiv: kartenDerArt(s.vorrat, const {KartenArt.gruendlich}),
              gewaehlt: {?_gruendlichKarte},
              hinweis: kartenDerArt(s.vorrat, const {KartenArt.gruendlich}).isEmpty ? null : KartenTexte.handGruendlich,
              figurVon: s.kartenFigur,
              onTipp: (k) {
                if (k.art != KartenArt.gruendlich || !s.vorrat.verfuegbar(k.id)) return;
                setState(() {
                  _gruendlichKarte = _gruendlichKarte == k.id ? null : k.id;
                  _gruendlich = _gruendlichKarte != null;
                });
              },
            )),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 8,
            children: [
              PartyKnopf(text: s.ui('ui.karte.nein'), haupt: false, onPressed: () { _gruendlich = false; _gruendlichKarte = null; s.verwerfen(); }),
              PartyKnopf(text: s.ui('ui.karte.ja'), onPressed: () {
                final gruendlich = _gruendlich && istSuche(s.spiel.ermittlung.entscheidung(z.entscheidung));
                final karte = gruendlich ? _gruendlichKarte : null;
                _gruendlich = false;
                _gruendlichKarte = null;
                s.bestaetigen(gruendlich: gruendlich, karte: karte);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fertig() => PartyTafel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.ui('ui.karte.fertig'), style: Keller.ueberschrift),
            const SizedBox(height: 16),
            ..._erkunden(),
            Align(alignment: Alignment.centerRight, child: PartyKnopf(text: s.ui('ui.karte.zur_gruppenwahl'), onPressed: s.weiter)),
          ],
        ),
      );

  Future<void> _liste(Entscheidung e) => showDialog<void>(
        context: context,
        builder: (c) => Dialog(
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(child: PartyTafel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.ui('ui.karte.liste_titel').toUpperCase(), style: context.schrift.marke),
                const SizedBox(height: 8),
                Text(e.frage, style: Keller.ueberschrift),
                const SizedBox(height: 12),
                for (final o in s.optionen(e.id))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PartyKnopf(
                      text: o.text,
                      haupt: false,
                      onPressed: () {
                        Navigator.of(c).pop();
                        s.schlageVor(o.id);
                      },
                    ),
                  ),
                ..._erkunden(vorher: () => Navigator.of(c).pop()),
              ],
            ),
          )),
        ),
      );

  Future<void> _notizbuch() => showDialog<void>(
        context: context,
        builder: (c) => Dialog(
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(child: PartyTafel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.ui('ui.karte.notizbuch').toUpperCase(), style: context.schrift.marke),
                const SizedBox(height: 10),
                if (s.funde.isEmpty && s.soloNotizen.isEmpty) Text(s.ui('ui.karte.notizbuch_leer'), style: Keller.leise),
                if (s.soloNotizen.isNotEmpty) ...[
                  Text(s.ui('ui.solo.notizen'), style: Keller.ueberschrift),
                  const SizedBox(height: 10),
                  for (final g in s.soloNotizen) Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BotSprechblase(sitzung: s, gespraech: g),
                  ),
                ],
                for (final f in s.funde.entries) ...[
                  Text(s.spiel.ermittlung.entscheidung(f.key).frage, style: Keller.leise),
                  for (final a in f.value) Padding(padding: const EdgeInsets.only(top: 4, bottom: 8), child: Text(a.text, style: Keller.text)),
                ],
                Align(alignment: Alignment.centerRight, child: PartyKnopf(text: s.ui('ui.allgemein.zurueck'), haupt: false, onPressed: () => Navigator.of(c).pop())),
                if (s.mitWuerfel) ...[
                  const SizedBox(height: 12),
                  Text(s.ui('ui.zug.protokoll'), style: Keller.ueberschrift),
                  if (s.wuerfe.isEmpty) Text(s.ui('ui.zug.kein_wurf'), style: Keller.leise),
                  for (final w in s.wuerfe) Text('${w.id} · ${w.stufe.wort} · ${w.a} + ${w.b} + ${w.mod}${w.garantie ? ' · ${s.ui('ui.zug.garantie_kurz')}' : ''}', style: Keller.leise),
                ],
              ],
            ),
          )),
        ),
      );
}

/// Meldet die Größe des Kindes nach jedem Layout, damit die Kamera den
/// Ausschnitt in den freien Rest des Bildes legen kann.
class _Misst extends SingleChildRenderObjectWidget {
  const _Misst({required this.onSize, required Widget super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMisst(onSize);

  @override
  void updateRenderObject(BuildContext context, _RenderMisst renderObject) => renderObject.onSize = onSize;
}

class _RenderMisst extends RenderProxyBox {
  _RenderMisst(this.onSize);

  ValueChanged<Size> onSize;
  Size? _gemeldet;

  @override
  void performLayout() {
    super.performLayout();
    if (_gemeldet == size) return;
    final g = _gemeldet = size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) onSize(g);
    });
  }
}
