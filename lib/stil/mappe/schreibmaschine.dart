import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../klang/klang.dart';
import '../tokens.dart';

/// Text, der wie auf der Schreibmaschine Zeichen für Zeichen erscheint.
///
/// - Das Layout steht vom ersten Bild an fest: der noch nicht getippte Rest ist
///   unsichtbar gesetzt, nichts springt.
/// - Der Bildschirmleser bekommt sofort den ganzen Text.
/// - Antippen zeigt sofort alles; bei „Bewegung reduzieren“ steht der Text gleich da.
/// - Das Tempo hängt an der Zeit, nicht an der Bildrate: Auf langsamen Geräten
///   erscheinen je Bild mehrere Zeichen.
class MSchreibmaschine extends StatefulWidget {
  const MSchreibmaschine(
    this.text, {
    super.key,
    this.stil,
    this.zeichenProSekunde = 55,
    this.textAlign = TextAlign.start,
    this.onFertig,
  });

  final String text;
  final TextStyle? stil;
  final double zeichenProSekunde;
  final TextAlign textAlign;
  final VoidCallback? onFertig;

  @override
  State<MSchreibmaschine> createState() => _MSchreibmaschineState();
}

class _MSchreibmaschineState extends State<MSchreibmaschine> with SingleTickerProviderStateMixin {
  late final Ticker _takt = createTicker(_tick);
  int _sichtbar = 0;
  bool _gestartet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_gestartet) {
      _gestartet = true;
      if (MBewegung.ruhig(context)) {
        _sichtbar = widget.text.length;
      } else {
        _starte();
      }
    }
  }

  @override
  void didUpdateWidget(covariant MSchreibmaschine alt) {
    super.didUpdateWidget(alt);
    if (alt.text != widget.text) {
      _takt.stop();
      _sichtbar = MBewegung.ruhig(context) ? widget.text.length : 0;
      if (_sichtbar < widget.text.length) _starte();
    }
  }

  void _starte() => _takt.start();

  void _tick(Duration seit) {
    final laenge = widget.text.length;
    final soll = (seit.inMicroseconds * widget.zeichenProSekunde / 1e6).floor().clamp(0, laenge);
    if (soll <= _sichtbar) return;
    final alt = _sichtbar;
    setState(() => _sichtbar = soll);
    // Jede zweite Taste klingt, höchstens ein Anschlag je Bild; Leerzeichen sind still.
    final taste = soll.isEven ? soll : soll - 1;
    if (taste > alt && taste > 0 && taste < laenge && widget.text[taste - 1] != ' ') {
      Klang.instanz.spiele('tippen', varianten: 3, laut: 0.45, streuung: 0.06);
    }
    if (soll >= laenge) {
      _takt.stop();
      widget.onFertig?.call();
    }
  }

  void _alles() {
    if (_sichtbar >= widget.text.length) return;
    _takt.stop();
    setState(() => _sichtbar = widget.text.length);
    widget.onFertig?.call();
  }

  @override
  void dispose() {
    _takt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stil = widget.stil ?? MSchrift.von(context).maschine;
    final sichtbar = widget.text.substring(0, _sichtbar);
    final rest = widget.text.substring(_sichtbar);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _alles,
      child: Semantics(
        label: widget.text,
        excludeSemantics: true,
        child: Text.rich(
          TextSpan(
            style: stil,
            children: [
              TextSpan(text: sichtbar),
              TextSpan(text: rest, style: const TextStyle(color: Colors.transparent)),
            ],
          ),
          textAlign: widget.textAlign,
        ),
      ),
    );
  }
}
