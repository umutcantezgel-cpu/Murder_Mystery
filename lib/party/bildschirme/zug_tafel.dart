import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';

import '../../karten/widgets/karten_ansicht.dart';
import '../../karten/widgets/karten_hand.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Öffentliche Würfelbühne: Chancen vor dem Wurf, Wort und Symbol danach.
/// Weder Bild noch Animation ermitteln das Ergebnis; allein der Zugkern würfelt.
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

  void _tippe(KartenDef k) {
    if (k.art != KartenArt.werkzeug || !s.vorrat.verfuegbar(k.id)) return;
    setState(() => _karte = _karte == k.id ? null : k.id);
  }

  @override
  Widget build(BuildContext context) {
    final z = s.zug!;
    final werkzeug = _karte != null;
    final v = s.wuerfelVorschau(marke: _marke, werkzeug: werkzeug);
    // Auch ein Abstecher kennt keine Marke; dort wirkt sie nie.
    final markeMoeglich = !z.istAbstecher && s.wuerfelVorschau(marke: true, werkzeug: werkzeug).markeWirkt;
    return PartyTafel(child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.ui('ui.zug.wuerfel'), style: Keller.titel),
        const SizedBox(height: 10),
        Text(s.ui('ui.zug.pate', {'name': s.wuerfelPate}), style: Keller.text),
        const SizedBox(height: 14),
        Text(s.ui('ui.zug.chancen', {'mod': '${v.mod}'}), style: Keller.ueberschrift),
        const SizedBox(height: 8),
        for (final stufe in Stufe.values) Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            StufenSymbol(stufe, groesse: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(s.ui('ui.zug.${stufe.name}'), style: Keller.text)),
            const SizedBox(width: 8),
            Text('${v.prozent[stufe]} %', style: Keller.text.copyWith(fontWeight: FontWeight.bold)),
          ]),
        ),
        if (v.garantie) ...[
          const SizedBox(height: 10),
          Text(s.ui('ui.zug.garantie'), style: Keller.text),
        ],
        if (!z.istAuftakt && s.hatKarten) ...[
          const SizedBox(height: 10),
          KartenHand(
            vorrat: s.vorrat,
            aktiv: kartenDerArt(s.vorrat, const {KartenArt.werkzeug}),
            gewaehlt: {?_karte},
            hinweis: kartenDerArt(s.vorrat, const {KartenArt.werkzeug}).isEmpty ? null : KartenTexte.handWuerfel,
            onTipp: _tippe,
          ),
        ],
        if (!z.istAuftakt && !z.istAbstecher && s.marken > 0) Material(color: Colors.transparent, child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Keller.kerze,
          value: _marke && markeMoeglich,
          onChanged: markeMoeglich ? (wert) => setState(() => _marke = wert ?? false) : null,
          title: Text(s.ui(markeMoeglich ? 'ui.zug.marke_einsetzen' : 'ui.zug.marke_deckel'), style: Keller.leise),
        )),
        const SizedBox(height: 10),
        Text(z.istAbstecher ? KartenTexte.erkundenWuerfel : s.ui(z.istAuftakt ? 'ui.zug.auftakt_folge' : 'ui.zug.pech_folge'), style: Keller.leise),
        const SizedBox(height: 16),
        PartyKnopf(text: s.ui('ui.zug.werfen'), onPressed: () => s.wuerfeln(marke: _marke && markeMoeglich, karte: _karte)),
      ],
    ));
  }
}

class WurfErgebnis extends StatelessWidget {
  const WurfErgebnis({super.key, required this.sitzung, required this.wurf});
  final PartySitzung sitzung;
  final Wurf wurf;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final ruhig = MediaQuery.disableAnimationsOf(context) || MediaQuery.accessibleNavigationOf(context);
    return PartyTafel(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Semantics(
        label: s.ui('ui.zug.${wurf.stufe.name}'), image: true,
        child: ExcludeSemantics(child: TweenAnimationBuilder<double>(
          key: ValueKey(wurf.zeile),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: ruhig ? 0 : 650),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Transform.rotate(
            angle: ruhig ? 0 : (1 - t) * math.pi * 2,
            child: Transform.scale(scale: ruhig ? 1 : 0.8 + t * 0.2, child: child),
          ),
          child: Container(
            width: 88, height: 88, alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD5AC73), width: 3),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF986739), Color(0xFF3C2517)]),
              boxShadow: const [BoxShadow(color: Color(0x55FFC27A), blurRadius: 22)],
            ),
            child: StufenSymbol(wurf.stufe, groesse: 46),
          ),
        )),
      ),
      const SizedBox(height: 12),
      Text(s.ui('ui.zug.${wurf.stufe.name}'), style: Keller.ueberschrift, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(s.ui('ui.zug.rechnung', {
        'a': '${wurf.a}', 'b': '${wurf.b}', 'mod': '${wurf.mod}',
        'summe': '${wurf.summe}', 'anlauf': '${wurf.anlauf}',
      }), style: Keller.leise, textAlign: TextAlign.center),
      if (wurf.garantie) Text(s.ui('ui.zug.garantie'), style: Keller.leise, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(s.zug?.istAbstecher == true ? KartenTexte.erkundenFolge(wurf.stufe, const ZugParameter())
          : s.ui(s.zug?.istAuftakt == true ? 'ui.zug.auftakt_folge' : 'ui.zug.${wurf.stufe.name}_folge'),
        style: Keller.leise, textAlign: TextAlign.center),
    ]));
  }
}

class TischrufTafel extends StatelessWidget {
  const TischrufTafel({super.key, required this.sitzung});
  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      WurfErgebnis(sitzung: s, wurf: s.zug!.wurf!),
      const SizedBox(height: 12),
      PartyTafel(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(s.ui('ui.zug.tischruf'), style: Keller.ueberschrift),
        const SizedBox(height: 8),
        Text(s.ui('ui.zug.pech_szene'), style: Keller.text),
        if (s.hatKarten) ...[
          const SizedBox(height: 12),
          Center(child: KartenHand(
            vorrat: s.vorrat,
            aktiv: kartenDerArt(s.vorrat, const {KartenArt.nochmal, KartenArt.umweg}),
            hinweis: kartenDerArt(s.vorrat, const {KartenArt.nochmal, KartenArt.umweg}).isEmpty ? null : KartenTexte.handTischruf,
            onTipp: (k) {
              if (!s.vorrat.verfuegbar(k.id)) return;
              if (k.art == KartenArt.nochmal) s.tischruf(Tischruf.nochmal, karte: k.id);
              if (k.art == KartenArt.umweg) s.tischruf(Tischruf.umweg, karte: k.id);
            },
          )),
        ],
        const SizedBox(height: 16),
        PartyKnopf(text: s.ui('ui.zug.nochmal'), onPressed: () => s.tischruf(Tischruf.nochmal)),
        const SizedBox(height: 8),
        PartyKnopf(text: s.ui('ui.zug.umweg_knopf'), haupt: false, onPressed: () => s.tischruf(Tischruf.umweg)),
      ])),
    ]);
  }
}

/// Keine Emoji-Schrift nötig: Auch das Gespenst ist auf allen Plattformen gleich.
class StufenSymbol extends StatelessWidget {
  const StufenSymbol(this.stufe, {super.key, this.groesse = 24});
  final Stufe stufe;
  final double groesse;

  @override
  Widget build(BuildContext context) => switch (stufe) {
    Stufe.erfolg => Icon(Icons.search_rounded, color: Keller.kerzeHell, size: groesse),
    Stufe.teilerfolg => Icon(Icons.phone_android_rounded, color: Keller.papier, size: groesse),
    Stufe.pech => CustomPaint(size: Size.square(groesse), painter: const _Gespenst()),
  };
}

class _Gespenst extends CustomPainter {
  const _Gespenst();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final pfad = Path()..moveTo(4, 21)..lineTo(4, 10)
      ..cubicTo(4, -1, 20, -1, 20, 10)..lineTo(20, 21)
      ..lineTo(16, 18)..lineTo(12, 21)..lineTo(8, 18)..close();
    canvas.drawPath(pfad, Paint()..color = Keller.papier);
    final auge = Paint()..color = Keller.stein;
    canvas.drawOval(const Rect.fromLTWH(8, 8, 2.5, 4), auge);
    canvas.drawOval(const Rect.fromLTWH(14, 8, 2.5, 4), auge);
    canvas.restore();
  }
  @override
  bool shouldRepaint(_Gespenst oldDelegate) => false;
}
