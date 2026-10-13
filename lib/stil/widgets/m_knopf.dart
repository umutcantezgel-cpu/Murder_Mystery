import 'package:flutter/material.dart';

import '../../klang/klang.dart';
import '../mappe/material.dart';
import '../tokens.dart';

/// Art eines Knopfs:
/// - [haupt]: Messingschild mit eingravierter Schrift.
/// - [zweit]: Aktenetikett (auf dem Schreibtisch hell, auf Papier mit Tintenrahmen).
/// - [leise]: unterstrichene Tintenzeile.
/// - [gefahr]: rotes Stempelschild.
enum MKnopfArt { haupt, zweit, leise, gefahr }

/// Knopf des Spiels, mindestens 48 × 48 Pixel. Ohne [onPressed] ist er gesperrt.
/// Das Material meldet ihn dem Bildschirmleser als Knopf mit seinem Text; mit
/// [semantik] ersetzt eine eigene Beschriftung den Text.
class MKnopf extends StatelessWidget {
  const MKnopf({
    super.key,
    required this.text,
    required this.onPressed,
    this.art = MKnopfArt.haupt,
    this.icon,
    this.breit = false,
    this.gross = false,
    this.semantik,
  });

  final String text;
  final VoidCallback? onPressed;
  final MKnopfArt art;
  final IconData? icon;

  /// Füllt die ganze Breite.
  final bool breit;

  /// Großer Knopf für die Hauptaktion einer Seite.
  final bool gross;

  /// Eigene Beschriftung für den Bildschirmleser (sonst [text]).
  final String? semantik;

  /// Mit Klang: Messingschild klickt, Etikett raschelt, Tintenlink bleibt still.
  VoidCallback? get _gedrueckt {
    final aktion = onPressed;
    if (aktion == null) return null;
    return () {
      switch (art) {
        case MKnopfArt.haupt:
          Klang.instanz.spiele('knopf');
        case MKnopfArt.gefahr:
          Klang.instanz.spiele('stempel', laut: 0.6);
        case MKnopfArt.zweit:
          Klang.instanz.spiele('blatt', laut: 0.5);
        case MKnopfArt.leise:
          break;
      }
      aktion();
    };
  }

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final aufPapier = MFlaeche.hellVon(context);
    final onPressed = _gedrueckt;
    final form = RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));
    const mindest = Size(MMass.tippflaeche, MMass.tippflaeche);
    final polster = EdgeInsets.symmetric(horizontal: 22, vertical: gross ? 19 : 13);
    final schild = MRohSchrift.knopf.copyWith(fontSize: gross ? 19 : 17);
    final etikett = MRohSchrift.schreibmaschine.copyWith(fontSize: gross ? 17 : 15, letterSpacing: 0.6);
    final inhalt = icon == null
        ? Text(text, textAlign: TextAlign.center)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon, size: 20), const SizedBox(width: MMass.s8), Flexible(child: Text(text, textAlign: TextAlign.center))],
          );
    final Widget knopf = switch (art) {
      MKnopfArt.haupt || MKnopfArt.gefahr => FilledButton(
          onPressed: onPressed,
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(mindest),
            padding: WidgetStatePropertyAll(polster),
            shape: WidgetStatePropertyAll(form),
            textStyle: WidgetStatePropertyAll(schild),
            backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
            overlayColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.08)),
            elevation: const WidgetStatePropertyAll(0),
            foregroundColor: WidgetStateProperty.resolveWith(
              (z) => z.contains(WidgetState.disabled)
                  ? (art == MKnopfArt.gefahr ? const Color(0x99F2EBDD) : const Color(0x995A4220))
                  : (art == MKnopfArt.gefahr ? MRoh.blatt : const Color(0xFF2A1A06)),
            ),
            backgroundBuilder: (context, zustaende, kind) => _Schild(
              gefahr: art == MKnopfArt.gefahr,
              gedrueckt: zustaende.contains(WidgetState.pressed),
              gesperrt: zustaende.contains(WidgetState.disabled),
              child: kind,
            ),
          ),
          child: inhalt,
        ),
      MKnopfArt.zweit => OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(mindest),
            padding: WidgetStatePropertyAll(polster),
            shape: WidgetStatePropertyAll(form),
            textStyle: WidgetStatePropertyAll(etikett),
            overlayColor: WidgetStatePropertyAll(f.akzentSchwach),
            foregroundColor: WidgetStateProperty.resolveWith(
              (z) => z.contains(WidgetState.disabled) ? MRoh.tinteLeise.withValues(alpha: 0.7) : MRoh.tinte,
            ),
            side: WidgetStateProperty.resolveWith(
              (z) => BorderSide(color: MRoh.tinte.withValues(alpha: z.contains(WidgetState.disabled) ? 0.2 : (aufPapier ? 0.55 : 0.0))),
            ),
            backgroundBuilder: (context, zustaende, kind) => _Etikett(
              aufPapier: aufPapier,
              gesperrt: zustaende.contains(WidgetState.disabled),
              gedrueckt: zustaende.contains(WidgetState.pressed),
              child: kind,
            ),
          ),
          child: inhalt,
        ),
      MKnopfArt.leise => TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: f.akzentHell,
            disabledForegroundColor: f.papierLeise,
            minimumSize: mindest,
            padding: polster,
            textStyle: etikett.copyWith(decoration: TextDecoration.underline, decorationThickness: 1.2),
            shape: form,
          ),
          child: inhalt,
        ),
    };
    final breitKnopf = breit ? SizedBox(width: double.infinity, child: knopf) : knopf;
    if (semantik == null) return breitKnopf;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semantik,
      onTap: onPressed,
      excludeSemantics: true,
      child: breitKnopf,
    );
  }
}

/// Messingschild (oder rotes Stempelschild) mit Schrauben in den Ecken.
class _Schild extends StatelessWidget {
  const _Schild({required this.gefahr, required this.gedrueckt, required this.gesperrt, this.child});

  final bool gefahr;
  final bool gedrueckt;
  final bool gesperrt;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final verlauf = gefahr
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gedrueckt ? const [Color(0xFF7E1B24), Color(0xFF9A2530)] : const [Color(0xFFC0384A), MRoh.stempelRot, Color(0xFF7E1B24)],
          )
        : messingVerlauf(gedrueckt: gedrueckt);
    Widget schild = DecoratedBox(
      decoration: BoxDecoration(
        gradient: verlauf,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: gefahr ? const Color(0xFF5E1219) : MRoh.messingDunkel, width: 1.2),
        boxShadow: gedrueckt
            ? const [BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1))]
            : const [
                BoxShadow(color: Color(0x88000000), blurRadius: 8, offset: Offset(0, 4)),
                BoxShadow(color: Color(0x33FFE7A8), blurRadius: 0, spreadRadius: -1, offset: Offset(0, -1)),
              ],
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (!gefahr) const Positioned.fill(child: CustomPaint(painter: BuerstungMaler())),
          const Positioned(left: 5, top: 5, child: _Schraube()),
          const Positioned(right: 5, top: 5, child: _Schraube()),
          const Positioned(left: 5, bottom: 5, child: _Schraube()),
          const Positioned(right: 5, bottom: 5, child: _Schraube()),
          ?child,
        ],
      ),
    );
    if (gesperrt) schild = Opacity(opacity: 0.45, child: ColorFiltered(colorFilter: const ColorFilter.matrix(_grau), child: schild));
    return AnimatedScale(scale: gedrueckt ? 0.97 : 1, duration: const Duration(milliseconds: 90), child: schild);
  }
}

const _grau = <double>[
  0.5, 0.4, 0.1, 0, 0, //
  0.4, 0.5, 0.1, 0, 0,
  0.3, 0.4, 0.3, 0, 0,
  0, 0, 0, 1, 0,
];

class _Schraube extends StatelessWidget {
  const _Schraube();

  @override
  Widget build(BuildContext context) => Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(center: Alignment(-0.4, -0.4), colors: [Color(0xFFFFF0C4), Color(0xFF6E4A10)]),
        ),
      );
}

/// Aktenetikett: helles Kartonetikett auf dem Schreibtisch, auf Papier ein
/// Tintenrahmen mit leichtem Ton.
class _Etikett extends StatelessWidget {
  const _Etikett({required this.aufPapier, required this.gesperrt, required this.gedrueckt, this.child});

  final bool aufPapier;
  final bool gesperrt;
  final bool gedrueckt;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (aufPapier) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: gedrueckt ? MRoh.tinte.withValues(alpha: 0.10) : MRoh.tinte.withValues(alpha: gesperrt ? 0.02 : 0.05),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      );
    }
    return Opacity(
      opacity: gesperrt ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: gedrueckt ? null : const [BoxShadow(color: Color(0x88000000), blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CustomPaint(painter: const PapierMaler(art: PapierArt.karteikarte, flecken: false, zeilenAbstand: 400, kopf: 4), child: child),
        ),
      ),
    );
  }
}
