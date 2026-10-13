import 'package:flutter/material.dart';

import '../tokens.dart';
import 'material.dart';

/// Kippschalter aus Messing (statt eines Material-Schalters): eine kleine Platte
/// mit Hebel. Für den Bildschirmleser ein Schalter mit Zustand.
class MSchalter extends StatelessWidget {
  const MSchalter({super.key, required this.wert, required this.onChanged, this.semantik, this.symbolAn, this.symbolAus});

  final bool wert;
  final ValueChanged<bool>? onChanged;
  final String? semantik;
  final IconData? symbolAn;
  final IconData? symbolAus;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final dauer = MBewegung.schnell(context);
    return Semantics(
      toggled: wert,
      enabled: onChanged != null,
      label: semantik,
      onTap: onChanged == null ? null : () => onChanged!(!wert),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!wert),
        child: SizedBox(
          width: 64,
          height: MMass.tippflaeche,
          child: Center(
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: wert ? [Color.lerp(f.akzent, Colors.black, 0.45)!, Color.lerp(f.akzent, Colors.black, 0.2)!] : const [Color(0xFF15111A), Color(0xFF2A2230)],
                ),
                border: Border.all(color: MRoh.messingDunkel, width: 1.4),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1))],
              ),
              child: AnimatedAlign(
                duration: dauer,
                curve: Curves.easeOutBack,
                alignment: wert ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: messingVerlauf(),
                    boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 3, offset: Offset(0, 2))],
                  ),
                  child: Icon(wert ? (symbolAn ?? Icons.check) : (symbolAus ?? Icons.close), size: 14, color: const Color(0xFF3A2808)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ankreuzfeld mit Tintenhaken (statt einer Material-Checkbox), mit Beschriftung.
class MHaken extends StatelessWidget {
  const MHaken({super.key, required this.wert, required this.onChanged, required this.text, this.hinweis});

  final bool wert;
  final ValueChanged<bool>? onChanged;
  final String text;
  final String? hinweis;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final s = MSchrift.von(context);
    final aufPapier = MFlaeche.hellVon(context);
    final tinte = aufPapier ? MRoh.tinteBlau : f.akzentHell;
    return Semantics(
      checked: wert,
      enabled: onChanged != null,
      label: text,
      hint: hinweis,
      onTap: onChanged == null ? null : () => onChanged!(!wert),
      excludeSemantics: true,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!wert),
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(border: Border.all(color: f.papier.withValues(alpha: 0.7), width: 1.6), borderRadius: BorderRadius.circular(2)),
                child: wert ? CustomPaint(painter: _HakenMaler(tinte)) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(text, style: s.text.copyWith(fontSize: 16)),
                    if (hinweis != null) Text(hinweis!, style: s.leise),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HakenMaler extends CustomPainter {
  _HakenMaler(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(size.width * 0.12, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.62, size.width * 0.42, size.height * 0.86)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.35, size.width * 1.05, -size.height * 0.05);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = farbe,
    );
  }

  @override
  bool shouldRepaint(covariant _HakenMaler alt) => alt.farbe != farbe;
}
