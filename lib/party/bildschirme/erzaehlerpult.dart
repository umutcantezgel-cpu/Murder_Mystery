import 'package:flutter/material.dart';

import '../../klang/klang.dart';
import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/stil.dart';
import '../sitzung.dart';

/// Wie die übrigen Partybildschirme deutsch, auch ohne Lokalisierung im Baum.
final _de = LDe();

/// Erzählerpult beim Spiel an einem Gerät (Langer Abend M3): Sitzt ein
/// Erzähler am Tisch ([PartySitzung.erzaehlerAmPult]), liegen die Erzähltexte
/// eines Schritts zugedeckt. Wie bei den Dossiers geht das Gerät an den
/// Erzähler; erst „Ich bin …, zeig her“ öffnet das Pult
/// ([PartySitzung.pultZeigen]). Danach liest er vor und deckt zu
/// ([ErzaehlerpultZudecken]). Bis zum Finale; die Auflösung lesen alle.
/// Bevorzugt liest der Erzähler am eigenen Handy mit
/// ([PartySitzung.begleitung], „Am eigenen Handy lesen“).
///
/// Der zugedeckte Zustand nennt nur, wie viele Texte warten: nie ein Wort daraus.
class ErzaehlerpultZu extends StatelessWidget {
  const ErzaehlerpultZu({super.key, required this.sitzung, required this.texte});

  final PartySitzung sitzung;

  /// Wie viele Texte in diesem Schritt warten.
  final int texte;

  @override
  Widget build(BuildContext context) {
    final l = _de;
    final name = sitzung.erzaehlerName;
    return MBlatt(
      key: const ValueKey('erzaehlerpult-zu'),
      art: PapierArt.telegramm,
      neigung: -0.005,
      samen: 61,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.erzaehlerpult_titel.toUpperCase(), style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
          const SizedBox(height: MMass.s4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: MMass.s12),
          MGanzeWorte(l.erzaehlerpult_geben(name), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
          const SizedBox(height: MMass.s8),
          Text(l.erzaehlerpult_nur(name), style: MPapierSchrift.text),
          if (texte > 0) ...[
            const SizedBox(height: MMass.s4),
            Text(l.erzaehlerpult_texte(texte), style: MPapierSchrift.leise),
          ],
          const SizedBox(height: MMass.s16),
          Wrap(
            spacing: MMass.s8,
            runSpacing: MMass.s8,
            children: [
              MKnopf(
                text: l.erzaehlerpult_zeigen(name),
                icon: Icons.menu_book_rounded,
                onPressed: () {
                  Klang.instanz.spiele('siegel');
                  sitzung.pultZeigen();
                },
              ),
              // Erzähler-Begleiter: Der Erzähler liest am eigenen Handy mit.
              if (sitzung.begleitung case final b?)
                MKnopf(
                  key: const ValueKey('erzaehlerpult-handy'),
                  text: l.erzaehlerpult_handy,
                  art: MKnopfArt.zweit,
                  icon: Icons.smartphone_rounded,
                  onPressed: () => b.zeigen(context),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Unter den offenen Texten des Pults: zudecken, sobald alles gelesen ist.
class ErzaehlerpultZudecken extends StatelessWidget {
  const ErzaehlerpultZudecken({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: MKnopf(
          key: const ValueKey('erzaehlerpult-zudecken'),
          text: _de.erzaehlerpult_zudecken,
          art: MKnopfArt.zweit,
          icon: Icons.visibility_off_outlined,
          onPressed: sitzung.pultSchliessen,
        ),
      );
}

/// Karte für ein Gerät, das gerade nicht vorliest (Vorleser-Sitz, M3): wer
/// liest, und dass der Text nur dort steht. Keine Zeile des Texts. Mit
/// [hinweis] statt des Satzes zum Zuhören (z. B. die Frist beim Ausfall des
/// Erzählers).
class VorleserKarte extends StatelessWidget {
  const VorleserKarte({super.key, required this.name, this.texte = 0, this.hinweis});

  /// Wer vorliest (Name am Tisch); leer: „Der Erzähler“.
  final String name;

  /// Wie viele Texte gerade vorgelesen werden (0: unbekannt).
  final int texte;
  final String? hinweis;

  @override
  Widget build(BuildContext context) {
    final l = _de;
    final wer = name.trim().isEmpty ? l.vorleser_erzaehler : name.trim();
    return Semantics(
      container: true,
      liveRegion: true,
      child: MBlatt(
        key: const ValueKey('vorleser-karte'),
        art: PapierArt.notiz,
        neigung: 0.004,
        samen: 63,
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Row(
          children: [
            const Icon(Icons.record_voice_over_outlined, color: MRoh.tinteBlau, size: 30),
            const SizedBox(width: MMass.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.vorleser_titel.toUpperCase(), style: MPapierSchrift.marke),
                  const SizedBox(height: MMass.s4),
                  MGanzeWorte(l.vorleser_liest(wer), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
                  const SizedBox(height: MMass.s4),
                  Text(hinweis ?? l.vorleser_zuhoeren, style: MPapierSchrift.leise),
                  if (texte > 0) Text(l.erzaehlerpult_texte(texte), style: MPapierSchrift.leise),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
