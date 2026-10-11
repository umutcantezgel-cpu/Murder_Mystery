import 'package:flutter/material.dart';

import '../tokens.dart';
import 'm_hintergrund.dart';
import 'roll_flaeche.dart';

/// Seitenrahmen des Spiels: Hintergrund ([MHintergrund]), Kopf (Marke, Titel,
/// Untertitel), Inhalt und ein Fuß mit Aktionen. Der Inhalt ist auf
/// [MMass.breite] begrenzt und rollt, solange [scroll] gilt.
class MRahmen extends StatelessWidget {
  const MRahmen({
    super.key,
    required this.child,
    this.marke,
    this.titel,
    this.untertitel,
    this.aktionen = const [],
    this.scroll = true,
    this.kopf,
  });

  final Widget child;
  final String? marke;
  final String? titel;
  final String? untertitel;
  final List<Widget> aktionen;

  /// `true`: der Inhalt rollt; `false`: er füllt den Platz (der Inhalt rollt selbst).
  final bool scroll;

  /// Eigener Kopf über dem Inhalt (z. B. Schrittanzeige), unter Marke und Titel.
  final Widget? kopf;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final s = MSchrift.von(context);
    final inhalt = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: scroll ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (marke != null) Text(marke!.toUpperCase(), style: s.marke),
        if (marke != null) const SizedBox(height: 6),
        if (titel != null) Text(titel!, style: s.titel),
        if (untertitel != null) ...[const SizedBox(height: 6), Text(untertitel!, style: s.leise)],
        if (titel != null || untertitel != null) const SizedBox(height: MMass.s20),
        if (kopf != null) ...[kopf!, const SizedBox(height: MMass.s16)],
        if (scroll) child else Expanded(child: child),
      ],
    );
    return MHintergrund(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: MMass.breite),
                  child: scroll
                      ? RollFlaeche(padding: const EdgeInsets.fromLTRB(MMass.s20, MMass.s24, MMass.s20, MMass.s24), child: inhalt)
                      : Padding(padding: const EdgeInsets.fromLTRB(MMass.s20, MMass.s24, MMass.s20, MMass.s12), child: inhalt),
                ),
              ),
            ),
            if (aktionen.isNotEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: f.grund.withValues(alpha: 0.94),
                  border: Border(top: BorderSide(color: f.linie)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: MMass.breite),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(MMass.s20, MMass.s12, MMass.s20, MMass.s12),
                      child: Wrap(alignment: WrapAlignment.end, spacing: MMass.s12, runSpacing: MMass.s8, children: aktionen),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
