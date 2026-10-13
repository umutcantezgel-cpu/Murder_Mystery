import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../stil/mappe/abend1_bausteine.dart';
import '../../stil/stil.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Gruppenwahl reihum und verdeckt (F4-BAUMEISTER-04, Master 7.8, E-025).
/// Jede besetzte Rolle wählt geheim zwischen zwei Handlungen; das
/// Geburtstagskind wählt nicht mit. Keine Ansicht zeigt eine Stimmenzahl oder
/// was jemand gewählt hat.
///
/// Neutral liegen ein Umschlag für die Person, die dran ist, und das
/// Wählerverzeichnis auf dem Tisch. Verdeckt steckt ein Stimmzettel mit zwei
/// Wahlkreisen im Umschlag. Der Zettel sieht für jede Rolle gleich aus; nur
/// der Wortlaut der Wahl B ist bei der Täterrolle die Sabotage (E-041).
class GruppenwahlBildschirm extends StatefulWidget {
  const GruppenwahlBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<GruppenwahlBildschirm> createState() => _GruppenwahlBildschirmState();
}

class _GruppenwahlBildschirmState extends State<GruppenwahlBildschirm> {
  /// Gewählte Karte der verdeckten Ansicht: `true` ist A (kooperativ), `false` ist B.
  bool? _kooperativ;

  /// Der Bildschirm ist gerade zugedeckt worden; der Hinweis bleibt bis zur nächsten Person.
  bool _zugedecktEben = false;

  PartySitzung get s => widget.sitzung;

  /// Kürzel der Akte für Siegel.
  String get _sigel => AkteStil.fuer(s.daten.fall).sigel;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final v = s.verdeckt;
          return v == null ? _neutral() : _verdeckt(v);
        },
      );

  /// Neutrale Ansicht: Erklärung, wer dran ist, wer schon gewählt hat und wer noch fehlt.
  Widget _neutral() {
    final offen = s.offeneWaehler;
    final schon = [
      for (final r in s.besetzt)
        if (!offen.contains(r)) r,
    ];
    return PartyRahmen(
      marke: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
      titel: s.ui('ui.gruppenwahl.titel'),
      untertitel: s.ui(s.solo ? 'ui.solo.gruppenwahl' : 'ui.gruppenwahl.erklaerung'),
      aktionen: [
        if (s.alleGestimmt) PartyKnopf(text: s.ui('ui.allgemein.weiter'), onPressed: s.kannWeiter ? s.weiter : null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_zugedecktEben) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: MBlatt(
                art: PapierArt.telegramm,
                neigung: -0.008,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility_off_outlined, size: 18, color: MRoh.tinteLeise),
                    const SizedBox(width: 10),
                    Flexible(child: Text(s.ui('ui.verdeckt.neutral'), style: MPapierSchrift.telegramm)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          offen.isEmpty ? _alleGewaehlt() : _naechste(offen.first),
          const SizedBox(height: 24),
          _verzeichnis(schon, offen),
        ],
      ),
    );
  }

  /// Alle haben gewählt: der Umschlag ist zu und versiegelt.
  Widget _alleGewaehlt() => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: MUmschlag(
            offen: false,
            siegel: _sigel,
            siegelFarbe: context.farben.gefahr,
            child: Text(s.ui('ui.gruppenwahl.alle'), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20), textAlign: TextAlign.center),
          ),
        ),
      );

  /// Wer ist als Nächstes dran: ein Umschlag mit dem Fotoabzug der Person,
  /// Gerät weitergeben, dann ansehen.
  Widget _naechste(String r) => MBlatt(
        art: PapierArt.telegramm,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        neigung: -0.006,
        samen: r.codeUnits.fold(3, (a, b) => (a * 31 + b) & 0xffff),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MFotoabzug(look: s.figurAussehen(r), groesse: 64, neigung: -0.05, akzent: s.figurFarbe(r)),
                  const SizedBox(width: 14),
                  MSiegel(kuerzel: _sigel, farbe: context.farben.gefahr, groesse: 46),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(s.ui('ui.verdeckt.weitergeben', {'name': s.spielerName(r)}), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20), textAlign: TextAlign.center),
            const SizedBox(height: 18),
            Center(
              child: PartyKnopf(
                text: s.ui('ui.verdeckt.frage', {'name': s.spielerName(r)}),
                icon: Icons.visibility_outlined,
                onPressed: () => _aufdecken(r),
              ),
            ),
          ],
        ),
      );

  /// Wählerverzeichnis auf einer Karteikarte: wer schon gewählt hat und wer noch offen ist.
  Widget _verzeichnis(List<String> schon, List<String> offen) => MBlatt(
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        neigung: 0.004,
        samen: 29,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _gruppe(
              s.ui('ui.gruppenwahl.schon'),
              [for (final r in schon) _zeile(r, gewaehlt: true)],
              leer: s.ui('ui.gruppenwahl.niemand'),
            ),
            if (offen.isNotEmpty) ...[
              const SizedBox(height: 18),
              _gruppe(s.ui('ui.gruppenwahl.offen'), [for (final r in offen) _zeile(r, gewaehlt: false)]),
            ],
          ],
        ),
      );

  /// Formularkopf und Namen einer Gruppe; ohne Namen steht [leer] darunter.
  Widget _gruppe(String ueberschrift, List<Widget> zeilen, {String? leer}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(ueberschrift.toUpperCase(), style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, letterSpacing: 1.1)),
          const SizedBox(height: 4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          if (zeilen.isEmpty && leer != null) Text(leer, style: MPapierSchrift.leise),
          Wrap(spacing: 18, runSpacing: 12, children: zeilen),
        ],
      );

  /// Ein Name am Tisch. Der Schlüssel ist die Rolle.
  Widget _zeile(String r, {required bool gewaehlt}) => _NamenZeile(
        key: ValueKey(r),
        sitzung: s,
        rolle: r,
        gewaehlt: gewaehlt,
        hinweis: gewaehlt ? s.ui('ui.gruppenwahl.hat_gewaehlt') : null,
      );

  /// Verdeckte Ansicht der Person [v]: der Stimmzettel im Umschlag, A oben.
  Widget _verdeckt(String v) {
    final w = s.wahl(v);
    return PartyRahmen(
      marke: s.rundenName,
      titel: s.spielerName(v),
      untertitel: s.ui('ui.gruppenwahl.frage'),
      aktionen: [
        PartyKnopf(text: s.ui('ui.verdeckt.schliessen'), haupt: false, onPressed: _schliessen),
        PartyKnopf(text: s.ui('ui.gruppenwahl.bestaetigen'), onPressed: _kooperativ == null ? null : () => _bestaetigen(v)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: LayoutBuilder(
                // Schmal (oder mit großer Schrift) rückt der Umschlag enger an das Blatt.
                builder: (context, box) {
                  final schmal = box.maxWidth < 360;
                  final titel = s.ui('ui.gruppenwahl.titel');
                  final titelStil = MPapierSchrift.ueberschrift.copyWith(fontSize: 20);
                  return MUmschlag(
                    einstecken: 34,
                    rand: schmal ? 7 : 14,
                    child: MBlatt(
                      samen: 31,
                      neigung: -0.004,
                      padding: EdgeInsets.fromLTRB(schmal ? 12 : 18, 18, schmal ? 12 : 18, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LayoutBuilder(
                            builder: (context, innen) => Text(
                              titel,
                              style: titelStil.copyWith(fontSize: ganzeWorteGroesse(context, titel, titelStil, innen.maxWidth)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const _Doppellinie(),
                          LayoutBuilder(
                            // Beide Wahlkreise in derselben Schrift: Reicht die Breite für ein
                            // langes Wort nicht, werden beide gleich kleiner (gleiche Gestalt, E-041).
                            builder: (context, innen) {
                              final feld = innen.maxWidth - _Wahlfeld.rand;
                              final eng = schmalFuerSchrift(context, feld);
                              final textBreite = eng ? feld : feld - _Wahlfeld.kreisPlatz;
                              final groesse = math.min(
                                ganzeWorteGroesse(context, w.a, MPapierSchrift.text, textBreite),
                                ganzeWorteGroesse(context, w.b, MPapierSchrift.text, textBreite),
                              );
                              final stil = groesse == MPapierSchrift.text.fontSize ? MPapierSchrift.text : MPapierSchrift.text.copyWith(fontSize: groesse);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _Wahlfeld(
                                    marke: s.ui('ui.rollen.wahl_a'),
                                    text: w.a,
                                    stil: stil,
                                    eng: eng,
                                    gewaehlt: _kooperativ == true,
                                    onTippen: () => setState(() => _kooperativ = true),
                                  ),
                                  Container(height: 2, color: MRoh.tinte.withValues(alpha: 0.75)),
                                  _Wahlfeld(
                                    marke: s.ui('ui.rollen.wahl_b'),
                                    text: w.b,
                                    stil: stil,
                                    eng: eng,
                                    gewaehlt: _kooperativ == false,
                                    onTippen: () => setState(() => _kooperativ = false),
                                  ),
                                ],
                              );
                            },
                          ),
                          const _Doppellinie(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(s.ui('ui.gruppenwahl.tippen'), style: context.schrift.leise),
        ],
      ),
    );
  }

  /// Der gewählte Wahlkreis geht als Stimme ein; danach ist der Bildschirm zugedeckt.
  void _bestaetigen(String v) {
    final k = _kooperativ;
    if (k == null) return;
    setState(() {
      _kooperativ = null;
      _zugedecktEben = true;
    });
    s.stimme(v, kooperativ: k);
  }

  /// Zudecken ohne Wahl: Die Person bleibt offen.
  void _schliessen() {
    setState(() {
      _kooperativ = null;
      _zugedecktEben = true;
    });
    s.verdecken();
  }

  /// Die verdeckte Ansicht einer Person öffnen; eine Wahl von vorher ist vergessen.
  void _aufdecken(String r) {
    setState(() {
      _kooperativ = null;
      _zugedecktEben = false;
    });
    s.zeigeVerdeckt(r);
  }
}

/// Zwei feine Tintenlinien, wie oben und unten auf einem amtlichen Zettel.
class _Doppellinie extends StatelessWidget {
  const _Doppellinie();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 1.4, color: MRoh.tinte.withValues(alpha: 0.7)),
          const SizedBox(height: 2),
          Container(height: 0.8, color: MRoh.tinte.withValues(alpha: 0.5)),
        ],
      );
}

/// Ein Feld des Stimmzettels: Kennung (Option A/B), der Wortlaut und rechts
/// der Wahlkreis. Gewählt trägt der Kreis ein Kreuz in Füllertinte.
///
/// Für den Bildschirmleser ist das Feld ein Knopf mit dem Wortlaut als Namen
/// und dem Zustand „angekreuzt“; die Kennung ist nur gedruckt.
class _Wahlfeld extends StatelessWidget {
  const _Wahlfeld({
    required this.marke,
    required this.text,
    required this.stil,
    required this.eng,
    required this.gewaehlt,
    required this.onTippen,
  });

  /// Innenabstand links und rechts zusammen.
  static const rand = 6.0;

  /// Platz des Wahlkreises neben dem Wortlaut (Abstand und Kreis).
  static const kreisPlatz = 54.0;

  final String marke;
  final String text;

  /// Schrift des Wortlauts (für beide Felder eines Zettels gleich).
  final TextStyle stil;

  /// Schmal (gemessen an der Schriftgröße): der Wahlkreis steht neben der
  /// Kennung, der Wortlaut darunter in voller Breite.
  final bool eng;
  final bool gewaehlt;
  final VoidCallback onTippen;

  @override
  Widget build(BuildContext context) {
    final kennung = ExcludeSemantics(child: Text(marke, style: MPapierSchrift.zwischentitel.copyWith(fontSize: 13, letterSpacing: 1.1)));
    final wortlaut = Text(text, style: stil);
    return MergeSemantics(
      child: Semantics(
        button: true,
        checked: gewaehlt,
        inMutuallyExclusiveGroup: true,
        child: InkWell(
          onTap: onTippen,
          splashFactory: NoSplash.splashFactory,
          highlightColor: MRoh.tinteBlau.withValues(alpha: 0.06),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 2, 14),
              child: eng
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [Expanded(child: kennung), const SizedBox(width: 10), _Wahlkreis(gewaehlt: gewaehlt)]),
                        const SizedBox(height: 6),
                        wortlaut,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [kennung, const SizedBox(height: 4), wortlaut],
                          ),
                        ),
                        const SizedBox(width: 14),
                        _Wahlkreis(gewaehlt: gewaehlt),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kreis zum Ankreuzen; das Kreuz wird mit dem Füller gezogen (ruhig: sofort da).
class _Wahlkreis extends StatelessWidget {
  const _Wahlkreis({required this.gewaehlt});

  final bool gewaehlt;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: gewaehlt ? 1 : 0),
        duration: MBewegung.normal(context),
        curve: Curves.easeOut,
        builder: (context, t, _) => SizedBox.square(dimension: 40, child: CustomPaint(painter: _KreuzMaler(t))),
      );
}

class _KreuzMaler extends CustomPainter {
  _KreuzMaler(this.t);

  /// Fortschritt des Kreuzes (0 leer, 1 ganz gezogen).
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final m = size.center(Offset.zero);
    final r = size.shortestSide * 0.42;
    canvas.drawCircle(
      m,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = MRoh.tinte.withValues(alpha: 0.85),
    );
    if (t <= 0) return;
    final stift = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..color = MRoh.tinteBlau;
    // Erster Strich von links oben nach rechts unten, dann der zweite.
    final a1 = m + Offset(-r * 0.95, -r * 0.8);
    final a2 = m + Offset(r * 0.9, r * 0.95);
    final b1 = m + Offset(r * 0.85, -r * 0.9);
    final b2 = m + Offset(-r * 0.8, r * 0.85);
    final t1 = (t * 2).clamp(0.0, 1.0);
    final t2 = (t * 2 - 1).clamp(0.0, 1.0);
    canvas.drawLine(a1, Offset.lerp(a1, a2, t1)!, stift);
    if (t2 > 0) canvas.drawLine(b1, Offset.lerp(b1, b2, t2)!, stift);
  }

  @override
  bool shouldRepaint(covariant _KreuzMaler alt) => alt.t != t;
}

/// Ein Name am Tisch im Wählerverzeichnis: kleiner Fotoabzug, Name und ein
/// Tintenhaken (schon gewählt) oder ein leerer Kreis (noch offen).
class _NamenZeile extends StatelessWidget {
  const _NamenZeile({super.key, required this.sitzung, required this.rolle, required this.gewaehlt, this.hinweis});

  final PartySitzung sitzung;
  final String rolle;
  final bool gewaehlt;
  final String? hinweis;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MFotoabzug(
            look: sitzung.figurAussehen(rolle),
            groesse: 36,
            neigung: rolle.codeUnits.fold(0, (a, b) => a + b).isEven ? -0.05 : 0.05,
            akzent: sitzung.figurFarbe(rolle),
          ),
          const SizedBox(width: 10),
          Flexible(child: Text(sitzung.spielerName(rolle), style: MPapierSchrift.text.copyWith(fontSize: 17))),
          const SizedBox(width: 8),
          Icon(
            gewaehlt ? Icons.check : Icons.radio_button_unchecked,
            size: 20,
            color: gewaehlt ? MRoh.tinteBlau : MRoh.tinteLeise,
            semanticLabel: hinweis,
          ),
        ],
      );
}
