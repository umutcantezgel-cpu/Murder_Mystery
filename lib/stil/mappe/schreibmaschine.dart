import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Text, der wie auf der Schreibmaschine Zeichen für Zeichen erscheint.
///
/// - Das Layout steht vom ersten Bild an fest: der noch nicht getippte Rest ist
///   unsichtbar gesetzt, nichts springt.
/// - Der Bildschirmleser bekommt sofort den ganzen Text.
/// - Antippen zeigt sofort alles; bei „Bewegung reduzieren“ steht der Text gleich da.
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

class _MSchreibmaschineState extends State<MSchreibmaschine> {
  Timer? _takt;
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
      _takt?.cancel();
      _sichtbar = MBewegung.ruhig(context) ? widget.text.length : 0;
      if (_sichtbar < widget.text.length) _starte();
    }
  }

  void _starte() {
    final schritt = Duration(microseconds: (1e6 / widget.zeichenProSekunde).round());
    _takt = Timer.periodic(schritt, (t) {
      if (!mounted) return t.cancel();
      setState(() => _sichtbar = (_sichtbar + 1).clamp(0, widget.text.length));
      if (_sichtbar >= widget.text.length) {
        t.cancel();
        widget.onFertig?.call();
      }
    });
  }

  void _alles() {
    if (_sichtbar >= widget.text.length) return;
    _takt?.cancel();
    setState(() => _sichtbar = widget.text.length);
    widget.onFertig?.call();
  }

  @override
  void dispose() {
    _takt?.cancel();
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
