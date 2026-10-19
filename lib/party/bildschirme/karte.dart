import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../../game/game_view.dart';
import '../../game/szenen_erweiterung.dart';
import '../../karten/widgets/karten_ansicht.dart';
import '../../karten/widgets/karten_hand.dart';
import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/mappe/abend2_bausteine.dart';
import '../../stil/stil.dart';
import '../karte_session.dart';
import '../karten_figur.dart';
import '../klasse_wirkung.dart';
import '../sitzung.dart';
import 'abstecher.dart';
import 'gespraech_szene.dart';
import 'npc_karte.dart';
import 'solo_gespraeche.dart';
import 'zug_tafel.dart';

final _de = LDe();

/// Die Entscheidungen des Detektivs auf der Karte (F4-ORCH-01, Master 7.7):
/// Frage oben, die Ziele der laufenden Entscheidung leuchten auf der Karte.
/// Eine Handlung macht einen Vorschlag; erst „Das ist endgültig“ wählt.
///
/// Über der Szene klemmt der Ermittlungsauftrag als Karteikarte; Rückfragen,
/// Liste, Notizbuch und Karten liegen als Karteikarten auf dem Schreibtisch,
/// der Weg steht auf einem Notizzettel, Funde hängen als Beweisanhänger.
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
  /// Gemessene Höhe des Gesprächsprotokolls (Randgespräch), für die Kamera.
  double _gespraechHoehe = 0;

  /// Eingesetzte Gründlich-Karte der Entscheidung, die gerade bestätigt wird.
  String? _gruendlichKarte;

  /// Abstecher, dessen Bestätigung gerade offen ist.
  AbstecherOrt? _abstecher;

  PartySitzung get s => widget.sitzung;

  @override
  void initState() {
    super.initState();
    _session = PartyKartenSession(s, klasse: KlasseWirkung.diesesGeraets(context, s));
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
                // Im Randgespräch ruht der Auftrag: die Szene bekommt den Platz oben.
                sichtRand: SzenenRand(
                  oben: rand.top + (s.gespraech != null ? 12 : _kopfHoehe),
                  unten: rand.bottom + (s.gespraech != null ? _gespraechHoehe + 12 : aktion ? _leisteHoehe + 12 : 56),
                ),
                umgebung: SzenenUmgebung(mitte: Color.lerp(f.nachtOben, f.schein, 0.1)!, rand: f.grund),
              )),
              if (s.gespraech == null) Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: MMass.breite),
                      // Auch bei 200-%-Schrift bleibt eine sichtbare Kartenbühne.
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: box.maxHeight * 0.44),
                        child: _Misst(
                          onSize: (g) {
                            if (mounted && (g.height - _kopfHoehe).abs() > 0.5) setState(() => _kopfHoehe = g.height);
                          },
                          child: SingleChildScrollView(child: Padding(
                            // Oben Platz für die Büroklammer, die über die Karte ragt.
                            padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                            child: _kopf(fund != null ? s.spiel.ermittlung.entscheidung(fund.entscheidung) : aktiveFrage),
                          )),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Randgespräch mit einem Zeugen: Protokoll unten, darüber die Szene.
              if (s.gespraech != null) Positioned(
                left: 12, right: 12, bottom: 12,
                child: SafeArea(top: false, child: Center(child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 560, maxHeight: box.maxHeight * 0.55),
                  child: _Misst(
                    onSize: (g) {
                      if (mounted && (g.height - _gespraechHoehe).abs() > 0.5) setState(() => _gespraechHoehe = g.height);
                    },
                    child: SingleChildScrollView(child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: GespraechsSzene(sitzung: s),
                    )),
                  ),
                ))),
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
                  MKnopf(text: s.ui('ui.zug.auftakt_weiter'), onPressed: s.fundGelesen),
                ],
              )),
              if (s.kannWeiter && e == null && fund == null && vorschlag == null && _abstecher == null) _abgedeckt(_fertig()),
            ],
          ));
        },
      );

  /// Der Weg zum Ziel als Notizzettel: Ziel, was gerade geschieht, ein Strich
  /// für den Fortschritt und „Kurz“.
  Widget _aktionsLeiste(double fortschritt) {
    final fehler = _session.aktionsFehler.value;
    final zug = s.zug!;
    final beschreibung = fehler ? 'ui.zug.blockiert' : switch (_session.figurenPose) {
      SzenenPose.gehen => zug.ruf == Tischruf.umweg ? 'ui.zug.umweg' : 'ui.zug.weg',
      SzenenPose.befragen => 'ui.zug.befragen',
      _ => 'ui.zug.suchen',
    };
    return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: MMass.breite), child: MBlatt(
      art: PapierArt.notiz,
      linien: false,
      neigung: 0.003,
      samen: 77,
      padding: const EdgeInsets.fromLTRB(40, 12, 16, 12),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MGanzwortText(
          zug.istAuftakt ? s.ui('ui.zug.auftakt') : zug.istAbstecher ? s.abstecherLaufend!.name : s.karte.ziele[zug.option]!.name,
          style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(s.ui(beschreibung), style: MPapierSchrift.maschine.copyWith(fontSize: 14)),
        const SizedBox(height: 8),
        // Eigene Ebene: Nur der Strich malt in jedem Bild neu, nicht das Papier.
        RepaintBoundary(child: _Wegstrich(fortschritt: fortschritt, gestoert: fehler)),
        const SizedBox(height: 10),
        MKnopf(text: s.ui('ui.zug.kurz'), art: MKnopfArt.zweit, onPressed: fehler ? null : _session.aktionAbkuerzen),
      ]),
    )));
  }

  /// Der Ermittlungsauftrag: eine Karteikarte mit Büroklammer über der Szene.
  /// Frage in Playfair, Uhrzeit und Stand getippt, der Hinweis auf Wunsch; die
  /// Hand liegt darunter in der Kartenablage.
  Widget _kopf(Entscheidung? e) {
    if (e == null) return const SizedBox.shrink();
    final nr = (e.runde - 1) * 3 + e.nr;
    final entscheidung = s.zug == null;
    final stand = MPapierSchrift.maschine.copyWith(fontSize: 13, height: 1.35);
    final blatt = MBlatt(
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      klammer: true,
      samen: nr + 60,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Formularkopf, rechts der Pfeil für den Hinweis.
          Row(
            children: [
              Expanded(
                child: Text(s.ui('ui.karte.entscheidung', {'nr': '$nr'}), style: MPapierSchrift.zwischentitel.copyWith(fontSize: 14, color: MRoh.stempelRot)),
              ),
              if (entscheidung) IconButton(
                tooltip: s.ui('ui.allgemein.weiter'),
                onPressed: () => setState(() => _hinweisOffen = !_hinweisOffen),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                icon: Icon(_hinweisOffen ? Icons.expand_less : Icons.expand_more, color: MRoh.tinteLeise),
              ) else const SizedBox(height: 14),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 2),
                Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
                const SizedBox(height: 8),
                MGanzwortText(e.frage, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20, height: 1.25)),
                // Eine Zeile Stand: Uhrzeit, bei den Würfeln auch Nachtminuten und Marken.
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 2,
                  children: [
                    Text(s.ui('ui.allgemein.uhrzeit', {'uhrzeit': s.rundenUhrzeit}), style: stand),
                    if (s.mitWuerfel) Text('${s.ui('ui.zug.nachtzeit', {'min': '${s.restMinuten}'})} · ${s.ui('ui.zug.marken', {'zahl': '${s.marken}'})}', style: stand.copyWith(color: MRoh.tinteLeise)),
                  ],
                ),
                if (_hinweisOffen && entscheidung) ...[
                  const SizedBox(height: 8),
                  Text(s.ui('ui.karte.hinweis'), style: MPapierSchrift.leise),
                ],
                if (entscheidung) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Kopfknopf(text: s.ui('ui.karte.liste'), icon: Icons.list_rounded, onPressed: () => _liste(e)),
                      _Kopfknopf(text: s.ui('ui.karte.notizbuch'), icon: Icons.menu_book_rounded, onPressed: _notizbuch),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
    // Die Formularzeile „Ermittlungsauftrag“ steht klein im Kopfstreifen neben
    // der Büroklammer; sie wächst mit der Schrift nur wenig, damit sie dort bleibt.
    final karte = Transform.rotate(
      angle: -0.004,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          blatt,
          Positioned(
            top: 10,
            right: 16,
            left: 48,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.2,
              child: Text(
                _de.abend2_auftrag,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: stand.copyWith(fontSize: 12, height: 1.2, letterSpacing: 1.4, color: MRoh.tinteLeise),
              ),
            ),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        karte,
        if (s.hatKarten && entscheidung) ...[
          const SizedBox(height: 6),
          // Die Ablage umschließt nur die Hand: Die Szene bleibt daneben sichtbar.
          Center(
            child: MKartenablage(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: KartenHand(
                vorrat: s.vorrat,
                aktiv: {for (final k in s.vorrat.karten) if (_sofortSpielbar(k)) k.id},
                kompakt: true,
                figurVon: s.kartenFigur,
                onTipp: _karteDialog,
              ),
            ),
          ),
        ],
      ],
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
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (c) {
          final spielbar = _sofortSpielbar(k);
          final sofort = k.art == KartenArt.zeit || k.art == KartenArt.marke || k.art == KartenArt.erinnerung;
          return MKarteiFenster(
            titel: k.titel,
            inhalt: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Die Karte selbst ist ein Gegenstand vom Schreibtisch: hell auf dunklem Grund.
                Center(child: MFlaeche.dunkel(child: KartenKarte(def: k, figur: s.kartenFigur(k), breite: 150))),
                const SizedBox(height: 14),
                Text(k.text, style: MPapierSchrift.text, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  spielbar ? KartenTexte.handSpielbar : sofort ? KartenTexte.handGesperrt : KartenTexte.handImZug,
                  style: MPapierSchrift.leise, textAlign: TextAlign.center,
                ),
              ],
            ),
            aktionen: [
              MKnopf(text: KartenTexte.handSchliessen, art: MKnopfArt.zweit, onPressed: () => Navigator.of(c).pop()),
              MKnopf(text: KartenTexte.handSpielen, onPressed: spielbar ? () {
                Navigator.of(c).pop();
                s.karteSpielen(k.id);
                if (k.art == KartenArt.erinnerung) _notizbuch();
              } : null),
            ],
          );
        },
      );

  /// Einträge „Erkunden: Name“ der offenen Abstecher (leer, wenn keiner offen ist).
  /// Sie stehen immer auf Papier (Liste, Rundenabschluss).
  List<Widget> _erkunden({VoidCallback? vorher}) => [
        if (s.abstecherOffen.isNotEmpty) ...[
          Text(KartenTexte.erkundenListe, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
          const SizedBox(height: 8),
          for (final a in s.abstecherOffen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MKnopf(
                text: KartenTexte.erkunden(a.name),
                art: MKnopfArt.zweit,
                // Bei großer Schrift ohne Kompass: Der Ortsname braucht die Breite.
                icon: MediaQuery.textScalerOf(context).scale(10) > 15 ? null : Icons.explore_rounded,
                onPressed: () {
                  vorher?.call();
                  setState(() => _abstecher = a);
                },
              ),
            ),
        ],
      ];

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

  /// Rückfrage vor der endgültigen Wahl als Karteikarte: die Stelle getippt,
  /// die Handlung in Playfair, „gründlich“ als Tintenhaken, die Gründlich-Karten
  /// in der Kartenablage.
  Widget _bestaetigung(KartenZiel z) {
    final e = s.spiel.ermittlung.entscheidung(z.entscheidung);
    final o = e.option(z.option);
    final suche = istSuche(e);
    return MBlatt(
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      neigung: 0.004,
      samen: z.option.codeUnits.fold(11, (a, b) => (a * 31 + b) & 0xffff),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(z.name, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
          const SizedBox(height: 4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          MGanzwortText(o.text, style: MPapierSchrift.ueberschrift),
          const SizedBox(height: 10),
          Text(s.ui('ui.karte.endgueltig'), style: MPapierSchrift.text),
          if (s.mitWuerfel) ...[
            const SizedBox(height: 8),
            Text(s.ui('ui.zug.wahl_bindung'), style: MPapierSchrift.leise),
          ],
          if (s.mitWuerfel && suche) MHaken(
            wert: _gruendlich,
            text: s.ui('ui.zug.gruendlich'),
            onChanged: (wert) => setState(() {
              _gruendlich = wert;
              if (!_gruendlich) _gruendlichKarte = null;
            }),
          ),
          if (s.hatKarten && suche) ...[
            const SizedBox(height: 8),
            MKartenablage(
              child: KartenHand(
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
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 8,
            children: [
              MKnopf(text: s.ui('ui.karte.nein'), art: MKnopfArt.zweit, onPressed: () { _gruendlich = false; _gruendlichKarte = null; s.verwerfen(); }),
              MKnopf(text: s.ui('ui.karte.ja'), onPressed: () {
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

  /// Runde abgeschlossen: ein geklammertes Aktenblatt mit den offenen
  /// Abstechern und dem Messingschild zur Gruppenwahl.
  Widget _fertig() => MBlatt(
        klammer: true,
        neigung: -0.004,
        samen: 91 + s.runde,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            MGanzwortText(s.ui('ui.karte.fertig'), style: MPapierSchrift.ueberschrift),
            const SizedBox(height: 16),
            ..._erkunden(),
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerRight, child: MKnopf(text: s.ui('ui.karte.zur_gruppenwahl'), onPressed: s.weiter)),
          ],
        ),
      );

  /// Die Möglichkeiten der Entscheidung als Karteikarte mit nummerierten
  /// Etiketten; darunter die offenen Abstecher.
  Future<void> _liste(Entscheidung e) => showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (c) {
          final optionen = s.optionen(e.id);
          // Bei großer Schrift entfällt die Nummernspalte: Die Etiketten bekommen
          // die ganze Breite, und die Nummer bricht nicht vom Punkt.
          final nummern = MediaQuery.textScalerOf(c).scale(10) <= 15;
          return MKarteiFenster(
            marke: s.ui('ui.karte.liste_titel'),
            titel: e.frage,
            inhalt: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < optionen.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        if (nummern)
                          ExcludeSemantics(
                            child: SizedBox(
                              width: 26,
                              child: Text('${i + 1}.', style: MPapierSchrift.maschine.copyWith(color: MRoh.stempelRot)),
                            ),
                          ),
                        Expanded(
                          child: MKnopf(
                            text: optionen[i].text,
                            art: MKnopfArt.zweit,
                            onPressed: () {
                              Navigator.of(c).pop();
                              s.schlageVor(optionen[i].id);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ..._erkunden(vorher: () => Navigator.of(c).pop()),
              ],
            ),
          );
        },
      );

  /// Das Notizbuch: ein Notizblock mit den gehörten Sprechblasen, den Funden je
  /// Entscheidung und dem Würfelprotokoll.
  Future<void> _notizbuch() => showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (c) => MKarteiFenster(
          art: PapierArt.notiz,
          titel: s.ui('ui.karte.notizbuch'),
          neigung: 0.003,
          inhalt: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s.funde.isEmpty && s.soloNotizen.isEmpty) Text(s.ui('ui.karte.notizbuch_leer'), style: MPapierSchrift.leise),
              if (s.soloNotizen.isNotEmpty) ...[
                MGanzwortText(s.ui('ui.solo.notizen'), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
                const SizedBox(height: 10),
                for (final g in s.soloNotizen) Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BotSprechblase(sitzung: s, gespraech: g),
                ),
              ],
              for (final f in s.funde.entries) ...[
                Text(s.spiel.ermittlung.entscheidung(f.key).frage, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
                for (final a in f.value) Padding(padding: const EdgeInsets.only(top: 4, bottom: 8), child: Text(a.text, style: MPapierSchrift.text)),
                const SizedBox(height: 4),
              ],
              if (s.mitWuerfel) ...[
                const SizedBox(height: 12),
                MGanzwortText(s.ui('ui.zug.protokoll'), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
                const SizedBox(height: 4),
                if (s.wuerfe.isEmpty) Text(s.ui('ui.zug.kein_wurf'), style: MPapierSchrift.leise),
                for (final w in s.wuerfe) Text(
                  '${w.id} · ${w.stufe.wort} · ${w.a} + ${w.b} + ${w.mod}${w.garantie ? ' · ${s.ui('ui.zug.garantie_kurz')}' : ''}',
                  style: MPapierSchrift.maschine.copyWith(fontSize: 13),
                ),
              ],
            ],
          ),
          aktionen: [MKnopf(text: s.ui('ui.allgemein.zurueck'), art: MKnopfArt.zweit, onPressed: () => Navigator.of(c).pop())],
        ),
      );
}

/// Kleiner Knopf im Ermittlungsauftrag: ein getipptes Etikett mit Tintenrahmen,
/// schmaler als ein [MKnopf], damit über der Szene Platz bleibt. Die Tippfläche
/// bleibt mindestens 48 Pixel hoch.
class _Kopfknopf extends StatelessWidget {
  const _Kopfknopf({required this.text, required this.icon, required this.onPressed});

  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: MRoh.tinte,
          backgroundColor: MRoh.tinte.withValues(alpha: 0.04),
          side: BorderSide(color: MRoh.tinte.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.padded,
          textStyle: MRohSchrift.schreibmaschine.copyWith(fontSize: 13, letterSpacing: 0.1),
        ),
        icon: Icon(icon, size: 17),
        label: Text(text),
      );
}

/// Fortschritt des Wegs: eine gestrichelte Bleistiftspur, die sich in Füllertinte
/// füllt, vorn eine rote Stecknadel. Für den Bildschirmleser ein Prozentwert.
class _Wegstrich extends StatelessWidget {
  const _Wegstrich({required this.fortschritt, required this.gestoert});

  final double fortschritt;
  final bool gestoert;

  @override
  Widget build(BuildContext context) => Semantics(
        value: '${(fortschritt.clamp(0.0, 1.0) * 100).round()}%',
        child: SizedBox(height: 16, child: CustomPaint(painter: _WegMaler(fortschritt.clamp(0.0, 1.0), gestoert))),
      );
}

class _WegMaler extends CustomPainter {
  _WegMaler(this.wert, this.gestoert);

  final double wert;
  final bool gestoert;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final spur = Paint()
      ..color = MRoh.tinte.withValues(alpha: 0.3)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var x = 2.0; x < size.width - 2; x += 8) {
      canvas.drawLine(Offset(x, y), Offset(x + 4, y), spur);
    }
    final ende = 2 + (size.width - 10) * wert;
    canvas.drawLine(
      Offset(2, y),
      Offset(ende, y),
      Paint()
        ..color = gestoert ? MRoh.stempelRot : MRoh.tinteBlau
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(ende, y), 5.5, Paint()..color = MRoh.stempelRot);
    canvas.drawCircle(Offset(ende - 1.5, y - 1.5), 1.8, Paint()..color = Colors.white.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(covariant _WegMaler alt) => alt.wert != wert || alt.gestoert != gestoert;
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
