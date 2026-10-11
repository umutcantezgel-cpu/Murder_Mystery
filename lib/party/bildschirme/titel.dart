import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../stil/tokens.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Titelbildschirm (Phase titel, Master 7.6 Schritt 1): Titel des Falls, ein
/// ruhig flackerndes Kerzenlicht und der Weg zur Einrichtung.
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
              child: Center(child: _Lichtschein(child: _kopf(context, box.maxWidth))),
            ),
          ),
        ),
      );

  /// Titel, Untertitel und der Hinweis zum Einrichten.
  Widget _kopf(BuildContext context, double breite) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sitzung.kanon.fall['titel'] as String, style: context.schrift.titel.copyWith(fontSize: breite < 320 ? 32 : 40), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(sitzung.kanon.fall['untertitel'] as String, style: Keller.leise, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Text(sitzung.ui('ui.titel.hinweis'), style: Keller.leise.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center),
        ],
      );
}

/// Warmer Schein hinter dem Inhalt. Zwei Sinusse ergeben ein ruhiges Flackern.
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
          final helligkeit = 0.12 + 0.05 * welle;
          return DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: context.farben.akzent.withValues(alpha: helligkeit), blurRadius: 90, spreadRadius: 30)],
            ),
            child: kind,
          );
        },
      );
}
