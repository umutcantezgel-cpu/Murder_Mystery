import 'package:flutter/material.dart';

import '../tokens.dart';

/// Rollbarer Inhalt mit sichtbarer Leiste und einem Hinweis am unteren Rand,
/// solange unten noch etwas folgt: Nichts wirkt abgeschnitten (B7).
class RollFlaeche extends StatefulWidget {
  const RollFlaeche({super.key, required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets padding;

  @override
  State<RollFlaeche> createState() => _RollFlaecheState();
}

class _RollFlaecheState extends State<RollFlaeche> {
  final _rolle = ScrollController();
  bool _mehr = false;

  void _pruefe() {
    if (!mounted || !_rolle.hasClients) return;
    final mehr = _rolle.position.extentAfter > 8;
    if (mehr != _mehr) setState(() => _mehr = mehr);
  }

  @override
  void initState() {
    super.initState();
    _rolle.addListener(_pruefe);
  }

  @override
  void dispose() {
    _rolle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pruefe());
    return Stack(
      children: [
        Scrollbar(
          controller: _rolle,
          thumbVisibility: true,
          child: SingleChildScrollView(controller: _rolle, padding: widget.padding, child: widget.child),
        ),
        // Ein flacher Verlauf am Rand und ein kleiner Pfeil rechts außen: Er zeigt,
        // dass unten mehr folgt, ohne Buchstaben zu verdecken (E-038).
        if (_mehr) ...[
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: SizedBox(
                height: 18,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x000B0A0E), Color(0xCC0B0A0E)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: IgnorePointer(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: f.grund, shape: BoxShape.circle, border: Border.all(color: f.akzent)),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: f.akzent, size: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
