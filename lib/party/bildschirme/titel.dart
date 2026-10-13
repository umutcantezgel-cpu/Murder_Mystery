import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../stil/stil.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Titelbildschirm (Phase titel, Master 7.6 Schritt 1): Die geschlossene
/// Fallakte liegt unter der Schreibtischlampe. Auf dem Deckel klebt das
/// Titelschild, ein Zettel erinnert daran, dass das Geburtstagskind wegschaut.
/// Der Lampenschein flackert ruhig; der Weg führt zur Einrichtung.
class TitelBildschirm extends StatelessWidget {
  const TitelBildschirm({super.key, required this.sitzung, this.menu});

  final PartySitzung sitzung;
  final Widget? menu;

  @override
  Widget build(BuildContext context) => PartyRahmen(
        scroll: false,
        aktionen: [
          ?menu,
          PartyKnopf(text: sitzung.ui('ui.titel.start'), onPressed: sitzung.zurEinrichtung),
        ],
        child: LayoutBuilder(
          // Zentriert, und bei kleinem Fenster scrollbar. Das Licht bleibt ungeschnitten.
          builder: (context, box) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _Lichtschein(child: _deckel(context, math.min(box.maxWidth, 600))),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// Der Aktendeckel: Titelschild mit Titel und Untertitel, darunter der Zettel.
  Widget _deckel(BuildContext context, double breite) {
    final akte = AkteStil.fuer(sitzung.daten.fall);
    return MAktenmappe(
      reiter: akte.sigel,
      farbe: context.farben.akzent,
      siegel: akte.sigel,
      blaetter: 3,
      neigung: -0.008,
      padding: EdgeInsets.fromLTRB(breite < 400 ? 14 : 22, 28, breite < 400 ? 14 : 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Zierlinie(),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, box) {
              final titel = sitzung.kanon.fall['titel'] as String;
              final stil = MPapierSchrift.aufmacher.copyWith(fontSize: breite < 400 ? 30 : 40);
              return Text(titel, style: stil.copyWith(fontSize: ganzeWorteGroesse(context, titel, stil, box.maxWidth)), textAlign: TextAlign.center);
            },
          ),
          const SizedBox(height: 12),
          Text(
            sitzung.kanon.fall['untertitel'] as String,
            style: MPapierSchrift.kursiv.copyWith(color: MRoh.tinteLeise),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          const _Zierlinie(),
          const SizedBox(height: 28),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                MBlatt(
                  art: PapierArt.notiz,
                  neigung: 0.022,
                  samen: 12,
                  padding: const EdgeInsets.fromLTRB(40, 16, 18, 14),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final hinweis = sitzung.ui('ui.titel.hinweis');
                      return Text(
                        hinweis,
                        style: MPapierSchrift.hand.copyWith(fontSize: ganzeWorteGroesse(context, hinweis, MPapierSchrift.hand, box.maxWidth, minimum: 13)),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
                const Positioned(top: -10, left: 0, right: 0, child: Center(child: MKlebestreifen(breite: 70, winkel: -0.06))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Doppelte Tintenlinie mit einer Raute in der Mitte (Zierde eines Titelschilds).
class _Zierlinie extends StatelessWidget {
  const _Zierlinie();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(height: 10, child: CustomPaint(painter: _ZierMaler())),
      );
}

class _ZierMaler extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final m = size.center(Offset.zero);
    final p = Paint()
      ..color = MRoh.tinte.withValues(alpha: 0.65)
      ..strokeWidth = 1;
    const luecke = 12.0;
    for (final dy in const [-2.0, 2.0]) {
      canvas.drawLine(Offset(0, m.dy + dy), Offset(m.dx - luecke, m.dy + dy), p);
      canvas.drawLine(Offset(m.dx + luecke, m.dy + dy), Offset(size.width, m.dy + dy), p);
    }
    final raute = Path()
      ..moveTo(m.dx, m.dy - 5)
      ..lineTo(m.dx + 6, m.dy)
      ..lineTo(m.dx, m.dy + 5)
      ..lineTo(m.dx - 6, m.dy)
      ..close();
    canvas.drawPath(raute, Paint()..color = MRoh.stempelRot.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(covariant _ZierMaler alt) => false;
}

/// Warmer Schein der Lampe hinter der Akte. Zwei Sinusse ergeben ein ruhiges Flackern.
class _Lichtschein extends StatefulWidget {
  const _Lichtschein({required this.child});

  final Widget child;

  @override
  State<_Lichtschein> createState() => _LichtscheinState();
}

class _LichtscheinState extends State<_Lichtschein> with SingleTickerProviderStateMixin {
  late final AnimationController _takt;

  @override
  void initState() {
    super.initState();
    _takt = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Bewegung reduzieren: ruhiger Schein ohne Flackern.
    if (MBewegung.ruhig(context)) {
      _takt.stop();
    } else if (!_takt.isAnimating) {
      _takt.repeat();
    }
  }

  @override
  void dispose() {
    _takt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _takt,
        child: widget.child,
        builder: (context, kind) {
          // Der langsame Sinus trägt die Welle, der schnelle schwach darüber.
          final welle = 0.7 * math.sin(_takt.value * 2 * math.pi) + 0.3 * math.sin(_takt.value * 6 * math.pi);
          final helligkeit = 0.24 + 0.07 * welle;
          final schein = context.farben.akzent;
          // Ein weicher Lichtkegel als Verlauf statt eines großen Weichzeichners.
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -140,
                right: -140,
                top: -120,
                bottom: -120,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.5,
                        colors: [schein.withValues(alpha: helligkeit), schein.withValues(alpha: helligkeit * 0.35), schein.withValues(alpha: 0)],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
              ),
              kind!,
            ],
          );
        },
      );
}
