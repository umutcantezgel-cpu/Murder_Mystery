import 'package:flutter/material.dart';

import '../tokens.dart';

/// Art eines Knopfs: der warme Hauptknopf, ein Rahmenknopf oder ein leiser Textknopf.
enum MKnopfArt { haupt, zweit, leise }

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

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final form = RoundedRectangleBorder(borderRadius: BorderRadius.circular(MMass.r10));
    const mindest = Size(MMass.tippflaeche, MMass.tippflaeche);
    final polster = EdgeInsets.symmetric(horizontal: 20, vertical: gross ? 20 : 14);
    TextStyle schrift(FontWeight gewicht) => TextStyle(fontFamily: MRohSchrift.text, fontSize: gross ? 18 : 16, fontWeight: gewicht);
    final inhalt = icon == null
        ? Text(text, textAlign: TextAlign.center)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon, size: 20), const SizedBox(width: MMass.s8), Flexible(child: Text(text, textAlign: TextAlign.center))],
          );
    final Widget knopf = switch (art) {
      MKnopfArt.haupt => FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: f.akzent,
            foregroundColor: f.akzentAuf,
            disabledBackgroundColor: f.flaecheHoch,
            disabledForegroundColor: f.papierLeise,
            minimumSize: mindest,
            padding: polster,
            textStyle: schrift(FontWeight.w700),
            shape: form,
          ),
          child: inhalt,
        ),
      MKnopfArt.zweit => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: f.papier,
            disabledForegroundColor: f.papierLeise,
            side: BorderSide(color: onPressed == null ? f.linie : f.linieStark),
            minimumSize: mindest,
            padding: polster,
            textStyle: schrift(FontWeight.w600),
            shape: form,
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
            textStyle: schrift(FontWeight.w600),
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
