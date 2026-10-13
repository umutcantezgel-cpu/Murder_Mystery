import 'package:flutter/material.dart';

import '../../klang/klang.dart';
import '../tokens.dart';
import '../widgets/m_ganze_worte.dart';
import '../widgets/m_knopf.dart';
import 'blatt.dart';
import 'material.dart';

/// Rückfrage als Karteikarte auf dem Schreibtisch (statt eines Material-Dialogs).
///
/// Titel in Playfair über der roten Kopflinie, Text in Lora, Knöpfe unten rechts.
/// Der Bildschirmleser liest Titel und Text als Dialog.
class MKarteikartenDialog extends StatelessWidget {
  const MKarteikartenDialog({super.key, required this.titel, this.text, this.inhalt, this.aktionen = const [], this.stempel});

  final String titel;
  final String? text;

  /// Eigener Inhalt unter dem Text.
  final Widget? inhalt;
  final List<Widget> aktionen;

  /// Stempel oben rechts (z. B. „Vertraulich“).
  final String? stempel;

  @override
  Widget build(BuildContext context) {
    final breite = MediaQuery.sizeOf(context).width;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: titel,
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: breite < 400 ? 14 : 40, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: LayoutBuilder(
            builder: (context, box) {
              // Der Titel wächst mit der Schrift; die rote Kopflinie der
              // Karteikarte liegt unter seiner gemessenen Höhe.
              final innen = box.maxWidth - 40;
              final grund = MPapierSchrift.ueberschrift.copyWith(fontSize: 20);
              final titelStil = grund.copyWith(fontSize: ganzeWorteGroesse(context, titel, grund, innen, minimum: 15));
              final tp = TextPainter(
                text: TextSpan(text: titel, style: titelStil),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
              )..layout(maxWidth: innen);
              final titelHoehe = tp.height;
              tp.dispose();
              return MBlatt(
                art: PapierArt.karteikarte,
                stempel: stempel,
                neigung: -0.006,
                kopfLinie: 10 + titelHoehe + 6,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Builder(
                  builder: (context) {
                    final s = MSchrift.von(context);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(titel, style: titelStil),
                        const SizedBox(height: 14),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (text != null) Text(text!, style: s.text),
                                if (inhalt != null) ...[const SizedBox(height: 12), inhalt!],
                              ],
                            ),
                          ),
                        ),
                        if (aktionen.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 8, children: aktionen),
                        ],
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Zeigt eine [MKarteikartenDialog]-Rückfrage mit zwei Knöpfen und liefert
/// `true` für [ja], `false` für [nein] (auch beim Wegtippen).
Future<bool> frageKarteikarte(
  BuildContext context, {
  required String titel,
  String? text,
  required String ja,
  required String nein,
  bool gefaehrlich = false,
}) async {
  Klang.instanz.spiele('blatt', laut: 0.7);
  final antwort = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => MKarteikartenDialog(
      titel: titel,
      text: text,
      aktionen: [
        MKnopf(text: nein, art: MKnopfArt.zweit, onPressed: () => Navigator.of(context).pop(false)),
        MKnopf(text: ja, art: gefaehrlich ? MKnopfArt.gefahr : MKnopfArt.haupt, onPressed: () => Navigator.of(context).pop(true)),
      ],
    ),
  );
  return antwort ?? false;
}
