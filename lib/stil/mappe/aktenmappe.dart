import 'package:flutter/material.dart';

import '../tokens.dart';
import 'material.dart';
import 'zeichen.dart';

/// Aktenmappe aus Manilakarton mit Reiter: das Muster der Mordakte.
///
/// Oben links steckt der Reiter mit [reiter] (z. B. „Akte Nr. 03“), darunter der
/// Deckel. Im Deckel liegt [child] auf Papier, dahinter lugen gestapelte Blätter
/// hervor. [farbe] färbt das Band unter dem Reiter (Akzent der Akte).
class MAktenmappe extends StatelessWidget {
  const MAktenmappe({
    super.key,
    required this.child,
    this.reiter,
    this.farbe,
    this.stempel,
    this.siegel,
    this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 18),
    this.blaetter = 2,
    this.neigung = 0,
    this.onTap,
  });

  final Widget child;

  /// Beschriftung des Reiters (Schreibmaschine, Originalschreibung).
  final String? reiter;

  /// Akzentband und Reiterfarbe (ohne Angabe: Akzent des Themas).
  final Color? farbe;

  /// Stempel quer über die rechte obere Ecke (z. B. „Ungelöst“).
  final String? stempel;

  /// Siegel unten rechts (Kürzel der Akte).
  final String? siegel;

  final EdgeInsets padding;

  /// Wie viele Blätter hinter dem Deckel hervorlugen (0–3).
  final int blaetter;
  final double neigung;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final band = farbe ?? f.akzent;
    final s = MSchrift.von(context);

    final deckel = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 18, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        child: CustomPaint(
          painter: const ManilaMaler(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 5, color: band.withValues(alpha: 0.85)),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: _Einlage(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ),
    );

    Widget mappe = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reiter != null)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CustomPaint(
              painter: _ReiterMaler(Color.lerp(MRoh.manila, Colors.white, 0.08)!),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 7, 22, 5),
                child: Text(reiter!, style: s.maschine.copyWith(fontSize: 13, color: MRoh.tinte, letterSpacing: 1.2)),
              ),
            ),
          ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Blätter, die hinter dem Deckel hervorlugen.
            for (var i = blaetter.clamp(0, 3); i > 0; i--)
              Positioned(
                top: -3.0 * i,
                right: -4.0 * i + 2,
                left: 10.0 * i,
                bottom: 6,
                child: Transform.rotate(
                  angle: 0.008 * i,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color.lerp(MRoh.blatt, MRoh.blattSchatten, 0.2 * i),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                ),
              ),
            deckel,
            if (stempel != null) Positioned(top: 18, right: 14, child: MStempel(text: stempel!, groesse: 15, winkel: -0.16)),
            if (siegel != null) Positioned(bottom: -12, right: 18, child: MSiegel(kuerzel: siegel!, farbe: band)),
          ],
        ),
      ],
    );
    if (onTap != null) {
      mappe = Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onTap, splashFactory: NoSplash.splashFactory, highlightColor: Colors.transparent, child: mappe),
      );
    }
    mappe = RepaintBoundary(child: mappe);
    return neigung == 0 ? mappe : Transform.rotate(angle: neigung, child: mappe);
  }
}

/// Das Papier im Deckel (helle Fläche, Tintenschrift).
class _Einlage extends StatelessWidget {
  const _Einlage({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))]),
        child: CustomPaint(
          painter: const PapierMaler(samen: 23),
          child: MFlaeche.papier(
            child: Builder(
              builder: (context) => DefaultTextStyle.merge(
                style: MSchrift.von(context).text,
                child: IconTheme.merge(data: IconThemeData(color: MFarben.von(context).papier), child: Padding(padding: padding, child: child)),
              ),
            ),
          ),
        ),
      );
}

class _ReiterMaler extends CustomPainter {
  _ReiterMaler(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(0, size.height)
      ..lineTo(8, 2)
      ..quadraticBezierTo(10, 0, 14, 0)
      ..lineTo(size.width - 14, 0)
      ..quadraticBezierTo(size.width - 10, 0, size.width - 8, 2)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawShadow(p, Colors.black, 2, false);
    canvas.drawPath(
      p,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(farbe, Colors.white, 0.2)!, farbe],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _ReiterMaler alt) => alt.farbe != farbe;
}

/// Registerleiste: Reiter einer Mappe zum Umblättern zwischen Abschnitten
/// (z. B. „Wer ich bin“, „Was ich weiß“, „Was ich verberge“).
class MReiterleiste extends StatelessWidget {
  const MReiterleiste({super.key, required this.reiter, required this.gewaehlt, required this.onWahl, this.farbe});

  final List<String> reiter;
  final int gewaehlt;
  final ValueChanged<int> onWahl;
  final Color? farbe;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final akzent = farbe ?? f.akzent;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < reiter.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Semantics(
                selected: i == gewaehlt,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onWahl(i),
                  child: AnimatedContainer(
                    duration: MBewegung.schnell(context),
                    constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
                    padding: EdgeInsets.fromLTRB(14, i == gewaehlt ? 12 : 9, 14, 8),
                    decoration: BoxDecoration(
                      color: i == gewaehlt ? MRoh.blatt : Color.lerp(MRoh.manila, MRoh.manilaDunkel, 0.25),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      border: Border(top: BorderSide(color: i == gewaehlt ? akzent : Colors.transparent, width: 3)),
                      boxShadow: const [BoxShadow(color: Color(0x50000000), blurRadius: 3, offset: Offset(0, -1))],
                    ),
                    child: Text(
                      reiter[i],
                      style: MRohSchrift.schreibmaschine.copyWith(fontSize: 14, color: i == gewaehlt ? MRoh.tinte : MRoh.tinteLeise),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
