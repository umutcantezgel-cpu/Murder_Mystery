import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/mappe/abend2_bausteine.dart';
import '../../stil/stil.dart';
import '../sitzung.dart';
import 'einfluss_teile.dart' show EinflussFundZusatz;
import 'moment.dart' show EinflussDarstellung;

final _de = LDe();

/// Fundkarte nach einer Entscheidung (F4-BAUMEISTER-09, Master 7.7 und 7.10).
/// Was die Handlung zeigt, steht wortgleich im Kanon. Bei einer Person zeigt
/// die Karte Name, Farbe und Rolle und sagt, ob ein Gast die Rolle spielt.
/// So erreicht das Wissen unbesetzter Rollen den Detektiv über die Karte.
///
/// Gestaltet als Beweisanhänger: „Beweisstück Nr. …“ (die Nummer der
/// Entscheidung, in allen Pfaden gleich), bei einer Person ihr Fotoabzug mit
/// Büroklammer, die Funde getippt.
class FundKarte extends StatelessWidget {
  const FundKarte({super.key, required this.sitzung, required this.ziel, required this.funde, required this.onGelesen});

  final PartySitzung sitzung;
  final KartenZiel ziel;
  final List<Aufdeckung> funde;
  final VoidCallback onGelesen;

  @override
  Widget build(BuildContext context) {
    final person = ziel.person;
    final e = sitzung.spiel.ermittlung.entscheidung(ziel.entscheidung);
    final nr = ((e.runde - 1) * 3 + e.nr).toString().padLeft(2, '0');
    return MBeweisanhaenger(
      kopf: _de.abend2_beweisstueck(nr),
      neigung: -0.006,
      samen: ziel.option.codeUnits.fold(7, (a, b) => (a * 31 + b) & 0xffff),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          person == null
              ? _OrtKopf(sitzung: sitzung, ziel: ziel)
              : _PersonKopf(sitzung: sitzung, ziel: ziel, person: person),
          if (funde.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(sitzung.ui('ui.karte.fund'), style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
            const SizedBox(height: 4),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
            const SizedBox(height: 10),
            for (final f in funde) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(f.text, style: MPapierSchrift.maschine)),
          ],
          // „Dein Moment“ (Finale §3.4): Randnotizen, Ertappt, Lage der Befragung.
          if (sitzung.zug?.einfluss case final e? when sitzung.zug?.id == ziel.entscheidung) ...[
            const SizedBox(height: 10),
            EinflussFundZusatz(fund: e, ermittlung: sitzung.spiel.ermittlung, darstellung: EinflussDarstellung.sitzung(sitzung)),
          ],
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: MKnopf(text: sitzung.ui('ui.karte.gelesen'), onPressed: onGelesen)),
        ],
      ),
    );
  }
}

/// Personenkopf: Fotoabzug mit Büroklammer, Name und Rolle. Trägt die Person
/// einen Gegenstand, steht er darunter. Ob ein Gast die Rolle spielt, sagt ein Satz.
class _PersonKopf extends StatelessWidget {
  const _PersonKopf({required this.sitzung, required this.ziel, required this.person});

  final PartySitzung sitzung;
  final KartenZiel ziel;
  final String person;

  @override
  Widget build(BuildContext context) {
    final titel = sitzung.figurTitel(person);
    final besetzt = sitzung.besetzt.contains(person);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MBildZeile(
          oben: true,
          bild: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ExcludeSemantics(
              child: MFotoabzug(
                look: sitzung.figurAussehen(person),
                groesse: 68,
                neigung: -0.05,
                klammer: true,
                akzent: sitzung.figurFarbe(person),
              ),
            ),
          ),
          text: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MGanzwortText(sitzung.figurName(person), style: MPapierSchrift.ueberschrift),
              if (titel.isNotEmpty) Text(titel, style: MPapierSchrift.leise),
              if (ziel.art == ZielArt.gegenstand) ...[
                const SizedBox(height: 8),
                Text(ziel.name, style: MPapierSchrift.maschine),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          sitzung.solo ? sitzung.ui('ui.solo.gast') :
              besetzt ? sitzung.ui('ui.npc.besetzt', {'name': sitzung.spielerName(person)}) : sitzung.ui('ui.npc.unbesetzt'),
          style: MPapierSchrift.kursiv.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}

/// Ortskopf für Gegenstände und Räume: gestempeltes Symbol, Name der Stelle
/// und der Raum. Bei einem Raum steht der Name schon oben, daher kommt er nicht
/// noch einmal.
class _OrtKopf extends StatelessWidget {
  const _OrtKopf({required this.sitzung, required this.ziel});

  final PartySitzung sitzung;
  final KartenZiel ziel;

  @override
  Widget build(BuildContext context) {
    final raum = sitzung.kanon.graph.raeume[ziel.raum]!.anzeigename;
    return OrtZeile(
      symbol: ziel.art == ZielArt.raum ? Icons.meeting_room : Icons.search,
      name: ziel.name,
      unter: raum != ziel.name ? raum : null,
    );
  }
}

/// Kopfzeile eines Orts auf Papier: das Symbol in einem gestempelten Kreis,
/// daneben Name und Raum (auch für den Fund eines Abstechers).
class OrtZeile extends StatelessWidget {
  const OrtZeile({super.key, required this.symbol, required this.name, this.unter});

  final IconData symbol;
  final String name;
  final String? unter;

  @override
  Widget build(BuildContext context) => MBildZeile(
        abstand: 14,
        bild: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: MRoh.stempelRot.withValues(alpha: 0.75), width: 2.2),
          ),
          child: Center(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: MRoh.stempelRot.withValues(alpha: 0.5))),
              child: Icon(symbol, size: 26, color: MRoh.stempelRot.withValues(alpha: 0.9)),
            ),
          ),
        ),
        text: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MGanzwortText(name, style: MPapierSchrift.ueberschrift),
            if (unter != null) Text(unter!, style: MPapierSchrift.leise),
          ],
        ),
      );
}
