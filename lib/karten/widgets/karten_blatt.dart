import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';

import '../../l10n/lookup.dart';
import '../../stil/stil.dart';
import '../katalog_laden.dart';
import 'karten_ansicht.dart';

/// Öffnet die große Kartenansicht als Karteikarte auf dem Schreibtisch: die
/// Karte, Titel, Text, Seltenheit, Art und Besitz. Eine unbekannte Karte
/// ([anzahl] gleich 0) zeigt nur, wie man sie bekommt.
Future<void> zeigeKartenBlatt(
  BuildContext context, {
  required KartenDef def,
  KartenFigur? figur,
  String? figurName,
  int anzahl = 0,
}) =>
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (c) => KartenBlatt(def: def, figur: figur, figurName: figurName, anzahl: anzahl),
    );

/// Die große Kartenansicht: eine Karteikarte, auf die die Sammelkarte geklebt
/// ist, darunter Etiketten, Wirkung und Besitz. Sie rollt, wenn der Platz nicht
/// reicht.
class KartenBlatt extends StatelessWidget {
  const KartenBlatt({super.key, required this.def, this.figur, this.figurName, this.anzahl = 0});

  final KartenDef def;
  final KartenFigur? figur;

  /// Name der Figur oder Klasse für die Überschrift.
  final String? figurName;

  /// Wie oft die Karte im Besitz ist (0 = unbekannt).
  final int anzahl;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final bekannt = anzahl > 0;
    final groesse = MediaQuery.sizeOf(context);
    final breite = (groesse.width * 0.55).clamp(150.0, 250.0);
    final titel = bekannt ? def.titel : l.karten_noch_nicht;
    final samen = def.id.codeUnits.fold(11, (a, b) => (a * 31 + b) & 0xffff);
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: titel,
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        // Kein Rahmen des Dialogs: nur die Karteikarte liegt auf dem Tisch.
        shape: const RoundedRectangleBorder(),
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: groesse.width < 400 ? 8 : 40, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            // Platz für Schatten und Schräglage des Blatts.
            padding: const EdgeInsets.all(MMass.s12),
            child: MBlatt(
              art: PapierArt.karteikarte,
              kopfLinie: 7,
              linien: false,
              neigung: -0.006,
              samen: samen,
              padding: const EdgeInsets.fromLTRB(MMass.s20, MMass.s20, MMass.s20, MMass.s16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (figurName != null) ...[
                    Text(
                      figurName!.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: MMass.s4),
                  ],
                  Text(titel, textAlign: TextAlign.center, style: MPapierSchrift.ueberschrift),
                  const SizedBox(height: MMass.s8),
                  Container(height: 1.4, color: MRoh.linieRot),
                  const SizedBox(height: MMass.s20),
                  // Die Karte ist mit einem Streifen auf die Karteikarte geklebt.
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Transform.rotate(
                          angle: samen.isEven ? 0.018 : -0.014,
                          child: bekannt
                              ? KartenKarte(def: def, figur: figur, breite: breite)
                              : UnbekannteKarte(breite: breite, semantik: l.karten_unbekannt_semantik(figurName ?? def.figur)),
                        ),
                        const Positioned(top: -12, left: 0, right: 0, child: Center(child: MKlebestreifen(breite: 70, winkel: -0.04))),
                      ],
                    ),
                  ),
                  const SizedBox(height: MMass.s20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: MMass.s8,
                    runSpacing: MMass.s8,
                    children: [
                      MChip(KartenTexte.seltenheit(def.seltenheit), farbe: seltenheitTinte(def.seltenheit)),
                      if (bekannt) MChip(KartenTexte.art(def.art), icon: artSymbol(def.art), farbe: MRoh.tinteBlau),
                      if (bekannt && def.art.spielbar) MChip(l.karten_ladungen(def.ladungen), farbe: MRoh.tinteLeise),
                    ],
                  ),
                  const SizedBox(height: MMass.s16),
                  if (bekannt) ...[
                    Text(def.text, textAlign: TextAlign.center, style: MPapierSchrift.text),
                    const SizedBox(height: MMass.s12),
                    Text(l.karten_besitz(anzahl), textAlign: TextAlign.center, style: MPapierSchrift.hand.copyWith(fontSize: 20)),
                  ] else ...[
                    Text(
                      l.karten_quelle_titel.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: MMass.s4),
                    for (final q in def.quellen)
                      if (KartenTexte.quelle(q).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: MMass.s4),
                          child: Text(KartenTexte.quelle(q), textAlign: TextAlign.center, style: MPapierSchrift.text.copyWith(fontSize: 15)),
                        ),
                  ],
                  const SizedBox(height: MMass.s20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MKnopf(text: l.common_close, art: MKnopfArt.zweit, onPressed: () => Navigator.of(context).pop()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
