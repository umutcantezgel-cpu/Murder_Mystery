import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';

import '../../karten/widgets/karten_ansicht.dart';
import '../../karten/widgets/karten_hand.dart';
import '../../l10n/lookup.dart';
import '../../stil/mappe/abend2_bausteine.dart';
import '../../stil/stil.dart';
import '../karten_figur.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Öffentliche Würfelbühne: Chancen vor dem Wurf, Wort und Symbol danach.
/// Weder Bild noch Animation ermitteln das Ergebnis; allein der Zugkern würfelt.
///
/// Das Würfelbrett ist ein dunkler Deckel; die Chancen stehen getippt auf einem
/// angeklebten Zettel, die Hand liegt auf dem Brett, gewürfelt wird mit dem
/// Messingschild.
class WuerfelTafel extends StatefulWidget {
  const WuerfelTafel({super.key, required this.sitzung});
  final PartySitzung sitzung;

  @override
  State<WuerfelTafel> createState() => _WuerfelTafelState();
}

class _WuerfelTafelState extends State<WuerfelTafel> {
  bool _marke = false;

  /// Eingesetzte Werkzeug-Karte (+1 auf diesen Wurf), sonst null.
  String? _karte;
  PartySitzung get s => widget.sitzung;

  /// Eine Werkzeugkarte wirkt nur unter dem Deckel +2; liegt der Wurf auch ohne sie
  /// schon dort (z. B. mit „gründlich“), wird sie nicht angeboten und nicht verbraucht.
  bool get _werkzeugWirkt => s.wuerfelVorschau().mod < WuerfelRegel.modMax;

  void _tippe(KartenDef k) {
    if (k.art != KartenArt.werkzeug || !s.vorrat.verfuegbar(k.id) || !_werkzeugWirkt) return;
    setState(() => _karte = _karte == k.id ? null : k.id);
  }

  @override
  Widget build(BuildContext context) {
    final z = s.zug!;
    final werkzeug = _karte != null;
    final v = s.wuerfelVorschau(marke: _marke, werkzeug: werkzeug);
    // Auch ein Abstecher kennt keine Marke; dort wirkt sie nie.
    final markeMoeglich = !z.istAbstecher && s.wuerfelVorschau(marke: true, werkzeug: werkzeug).markeWirkt;
    // Online würfelt nur das Gerät der Würfelpatin oder des Würfelpaten; sonst
    // steht hier, wer würfelt (die Chancen sind für alle am Tisch öffentlich).
    final darf = s.darfWuerfeln;
    final werkzeugKarten = _werkzeugWirkt ? kartenDerArt(s.vorrat, const {KartenArt.werkzeug}) : const <String>{};
    final t = context.schrift;
    return MTafel(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.ui('ui.zug.wuerfel'), style: t.titel),
          const SizedBox(height: 8),
          Text(s.ui('ui.zug.pate', {'name': s.wuerfelPate}), style: t.text),
          const SizedBox(height: 18),
          _Chancenzettel(sitzung: s, vorschau: v),
          if (v.garantie) ...[
            const SizedBox(height: 12),
            Text(s.ui('ui.zug.garantie'), style: t.text),
          ],
          if (darf && !z.istAuftakt && s.hatKarten) ...[
            const SizedBox(height: 12),
            KartenHand(
              vorrat: s.vorrat,
              aktiv: werkzeugKarten,
              gewaehlt: {?_karte},
              hinweis: werkzeugKarten.isEmpty ? null : KartenTexte.handWuerfel,
              figurVon: s.kartenFigur,
              onTipp: _tippe,
            ),
          ],
          if (darf && !z.istAuftakt && !z.istAbstecher && s.marken > 0) ...[
            const SizedBox(height: 6),
            MHaken(
              wert: _marke && markeMoeglich,
              onChanged: markeMoeglich ? (wert) => setState(() => _marke = wert) : null,
              text: s.ui(markeMoeglich ? 'ui.zug.marke_einsetzen' : 'ui.zug.marke_deckel'),
            ),
          ],
          const SizedBox(height: 10),
          Text(z.istAbstecher ? KartenTexte.erkundenWuerfel : s.ui(z.istAuftakt ? 'ui.zug.auftakt_folge' : 'ui.zug.pech_folge'), style: t.leise),
          const SizedBox(height: 16),
          if (darf)
            MKnopf(text: s.ui('ui.zug.werfen'), gross: true, onPressed: () => s.wuerfeln(marke: _marke && markeMoeglich, karte: _karte))
          else
            Text(L.of(context).online_wuerfelt(s.wuerfelPate), key: const ValueKey('wuerfelt-gerade'), style: t.ueberschrift),
        ],
      ),
    );
  }
}

/// Die Chancen als getippte Tabelle auf einem angeklebten Zettel: je Stufe das
/// Symbol, das Wort, eine Punktlinie und die Prozentzahl.
class _Chancenzettel extends StatelessWidget {
  const _Chancenzettel({required this.sitzung, required this.vorschau});

  final PartySitzung sitzung;
  final ({int mod, bool garantie, bool markeWirkt, Map<Stufe, int> prozent}) vorschau;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final v = vorschau;
    final zeile = MPapierSchrift.maschine.copyWith(fontSize: 15);
    // Bei großer Schrift steht die Zahl unter dem Wort, wenn beide nicht in eine Zeile passen.
    final eng = MediaQuery.textScalerOf(context).scale(10) > 13;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: eng ? 0 : 4),
      child: MBlatt(
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        klebestreifen: true,
        neigung: 0.006,
        samen: 41,
        padding: EdgeInsets.fromLTRB(eng ? 12 : 16, 20, eng ? 12 : 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.ui('ui.zug.chancen', {'mod': '${v.mod}'}), style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
            const SizedBox(height: 4),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
            const SizedBox(height: 6),
            for (final stufe in Stufe.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: eng ? _engeZeile(stufe, zeile) : _zeile(stufe, zeile),
              ),
          ],
        ),
      ),
    );
  }

  /// Symbol, Wort, Punktlinie, Prozent: eine getippte Tabellenzeile.
  Widget _zeile(Stufe stufe, TextStyle zeile) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StufenSymbol(stufe, groesse: 26),
          const SizedBox(width: 10),
          // Das Wort nimmt, was es braucht (höchstens drei Viertel), die Punktlinie den Rest.
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: box.maxWidth * 0.75),
                    child: Text(sitzung.ui('ui.zug.${stufe.name}'), style: zeile),
                  ),
                  const Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: _Punktlinie())),
                ],
              ),
            ),
          ),
          Text('${vorschau.prozent[stufe]} %', style: zeile.copyWith(fontWeight: FontWeight.bold)),
        ],
      );

  /// Bei großer Schrift: Symbol und Wort, die Zahl rechts daneben oder darunter.
  Widget _engeZeile(Stufe stufe, TextStyle zeile) => Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StufenSymbol(stufe, groesse: 26),
              const SizedBox(width: 8),
              Flexible(child: Text(sitzung.ui('ui.zug.${stufe.name}'), style: zeile)),
            ],
          ),
          Text('${vorschau.prozent[stufe]} %', style: zeile.copyWith(fontWeight: FontWeight.bold)),
        ],
      );
}

/// Punktlinie zwischen Wort und Zahl einer getippten Tabelle.
class _Punktlinie extends StatelessWidget {
  const _Punktlinie();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 12, child: CustomPaint(painter: _PunkteMaler()));
}

class _PunkteMaler extends CustomPainter {
  const _PunkteMaler();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = MRoh.tinte.withValues(alpha: 0.4);
    for (var x = 1.5; x < size.width; x += 6) {
      canvas.drawCircle(Offset(x, size.height - 3), 0.9, p);
    }
  }

  @override
  bool shouldRepaint(covariant _PunkteMaler alt) => false;
}

/// Ergebnis eines Wurfs: zwei gemalte Würfel rollen aufs Brett und zeigen die
/// Augen, darunter Stufe, Rechnung auf einem Beleg und die Folge. Die Würfel
/// zeigen nur, was der Zugkern gewürfelt hat.
class WurfErgebnis extends StatelessWidget {
  const WurfErgebnis({super.key, required this.sitzung, required this.wurf});
  final PartySitzung sitzung;
  final Wurf wurf;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final t = context.schrift;
    final ruhig = MediaQuery.disableAnimationsOf(context) || MediaQuery.accessibleNavigationOf(context);
    return MTafel(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: s.ui('ui.zug.${wurf.stufe.name}'),
            image: true,
            child: ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                key: ValueKey(wurf.zeile),
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: ruhig ? 0 : 650),
                curve: Curves.easeOutCubic,
                builder: (context, t, _) => _Wurfbild(a: wurf.a, b: wurf.b, t: ruhig ? 1 : t),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StufenSymbol(wurf.stufe, groesse: 30),
              const SizedBox(width: 10),
              Flexible(child: Text(s.ui('ui.zug.${wurf.stufe.name}'), style: t.ueberschrift, textAlign: TextAlign.center)),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: MBlatt(
              art: PapierArt.karteikarte,
              kopfLinie: 7,
              linien: false,
              neigung: -0.008,
              samen: wurf.anlauf + 17,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.ui('ui.zug.rechnung', {
                      'a': '${wurf.a}', 'b': '${wurf.b}', 'mod': '${wurf.mod}',
                      'summe': '${wurf.summe}', 'anlauf': '${wurf.anlauf}',
                    }),
                    style: MPapierSchrift.maschine.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (wurf.garantie) Text(s.ui('ui.zug.garantie'), style: MPapierSchrift.leise, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.zug?.istAbstecher == true
                ? KartenTexte.erkundenFolge(wurf.stufe, const ZugParameter())
                : s.ui(s.zug?.istAuftakt == true ? 'ui.zug.auftakt_folge' : 'ui.zug.${wurf.stufe.name}_folge'),
            style: t.leise,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Die zwei Würfel im Lauf [t] (0 = noch in der Hand, 1 = liegen): Sie rollen
/// von den Seiten heran, drehen sich und springen einmal auf.
class _Wurfbild extends StatelessWidget {
  const _Wurfbild({required this.a, required this.b, required this.t});

  final int a;
  final int b;
  final double t;

  @override
  Widget build(BuildContext context) {
    final rest = 1 - t;
    final sprung = math.sin(t * math.pi) * 14;
    Widget wuerfel(int augen, double richtung, double drall) => Transform.translate(
          offset: Offset(richtung * rest * 70, -sprung),
          child: Transform.rotate(
            angle: drall * rest * math.pi * 2,
            child: Transform.scale(scale: 0.8 + t * 0.2, child: MWuerfel(augen: augen, groesse: 58)),
          ),
        );
    // Der Filz der Würfelschale: dunkelgrün, innen beschattet.
    return Center(
      child: Container(
        height: 96,
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const RadialGradient(radius: 0.9, colors: [Color(0xFF2C4635), Color(0xFF16261C)]),
          border: Border.all(color: MRoh.messingDunkel.withValues(alpha: 0.8), width: 2),
          boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            wuerfel(a, -1, 1.25),
            const SizedBox(width: 22),
            Transform.rotate(angle: 0.18, child: wuerfel(b, 1, -1)),
          ],
        ),
      ),
    );
  }
}

/// Tischruf nach Pech: das Ergebnis, darunter ein Telegramm an den Tisch mit
/// „Nochmal“ und „Umweg“.
class TischrufTafel extends StatelessWidget {
  const TischrufTafel({super.key, required this.sitzung});
  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      WurfErgebnis(sitzung: s, wurf: s.zug!.wurf!),
      const SizedBox(height: 14),
      MBlatt(
        art: PapierArt.telegramm,
        neigung: 0.004,
        samen: 29,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(s.ui('ui.zug.tischruf'), style: MPapierSchrift.ueberschrift),
          const SizedBox(height: 8),
          Text(s.ui('ui.zug.pech_szene'), style: MPapierSchrift.text),
          if (s.hatKarten) ...[
            const SizedBox(height: 12),
            MKartenablage(
              child: KartenHand(
                vorrat: s.vorrat,
                aktiv: kartenDerArt(s.vorrat, const {KartenArt.nochmal, KartenArt.umweg}),
                hinweis: kartenDerArt(s.vorrat, const {KartenArt.nochmal, KartenArt.umweg}).isEmpty ? null : KartenTexte.handTischruf,
                figurVon: s.kartenFigur,
                onTipp: (k) {
                  if (!s.vorrat.verfuegbar(k.id)) return;
                  if (k.art == KartenArt.nochmal) s.tischruf(Tischruf.nochmal, karte: k.id);
                  if (k.art == KartenArt.umweg) s.tischruf(Tischruf.umweg, karte: k.id);
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          MKnopf(text: s.ui('ui.zug.nochmal'), onPressed: () => s.tischruf(Tischruf.nochmal)),
          const SizedBox(height: 8),
          MKnopf(text: s.ui('ui.zug.umweg_knopf'), art: MKnopfArt.zweit, onPressed: () => s.tischruf(Tischruf.umweg)),
        ]),
      ),
    ]);
  }
}

/// Symbol einer Stufe. Keine Emoji-Schrift nötig: Auch das Gespenst ist auf
/// allen Plattformen gleich. Auf Papier in Tinte, auf dem Schreibtisch hell.
class StufenSymbol extends StatelessWidget {
  const StufenSymbol(this.stufe, {super.key, this.groesse = 24});
  final Stufe stufe;
  final double groesse;

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    return switch (stufe) {
      Stufe.erfolg => Icon(Icons.search_rounded, color: f.akzentHell, size: groesse),
      Stufe.teilerfolg => Icon(Icons.lightbulb_outline_rounded, color: f.papier, size: groesse),
      Stufe.pech => CustomPaint(size: Size.square(groesse), painter: _Gespenst(koerper: f.papier, augen: f.grund)),
    };
  }
}

class _Gespenst extends CustomPainter {
  const _Gespenst({required this.koerper, required this.augen});

  final Color koerper;
  final Color augen;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final pfad = Path()..moveTo(4, 21)..lineTo(4, 10)
      ..cubicTo(4, -1, 20, -1, 20, 10)..lineTo(20, 21)
      ..lineTo(16, 18)..lineTo(12, 21)..lineTo(8, 18)..close();
    canvas.drawPath(pfad, Paint()..color = koerper);
    final auge = Paint()..color = augen;
    canvas.drawOval(const Rect.fromLTWH(8, 8, 2.5, 4), auge);
    canvas.drawOval(const Rect.fromLTWH(14, 8, 2.5, 4), auge);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Gespenst alt) => alt.koerper != koerper || alt.augen != augen;
}
