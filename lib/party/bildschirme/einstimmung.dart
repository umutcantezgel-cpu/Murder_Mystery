import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/mappe/online_bausteine.dart' show MOnlineSilhouette;
import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Wie die übrigen Partybildschirme deutsch, auch ohne Lokalisierung im Baum.
final _de = LDe();

/// Einstimmung (Finale Schlosskeller, A-063, [PartySitzung.einstimmung]):
/// Vorgeschichte und Vorstellung zu Beginn der Einleitung, vor Vorspiel und
/// Diashow. Je Schritt genau ein Baustein.
///
/// - Oben Kapitelzähler („Vorgeschichte · 3 von 7“) und Kapiteltitel
///   ([EinstimmungSchritt.titel], nicht vorgelesen).
/// - Bei einer Figur die [VorstellungsKarte] für alle: Porträt, Name,
///   Rollentitel, Steckbrief-Satz und wer sie spielt. Das steht nie im
///   Vorlesetext.
/// - Darunter das [ErzaehlerFeld] mit genau der Kennung des Schritts: Die
///   Stimme liest wortgleich, am Tisch liegt der Text zugedeckt im Pult, am
///   Erzähler-Handy liest der Erzähler.
/// - „Weiter“ und „… überspringen“ drückt, wer leitet ([PartySitzung.einstimmungSteuerbar]).
class EinstimmungBildschirm extends StatelessWidget {
  const EinstimmungBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: sitzung, builder: (context, _) => _inhalt(context));

  Widget _inhalt(BuildContext context) {
    final s = sitzung;
    final schritt = s.einstimmung;
    if (schritt == null) return const SizedBox.shrink();
    final letzter = s.einstimmungNr >= s.einstimmungAnzahl - 1;
    final steuerbar = s.einstimmungSteuerbar;
    final wer = s.vorleserName.trim().isEmpty ? _de.vorleser_erzaehler : s.vorleserName.trim();
    final figur = schritt.figur;
    return PartyFussHinweis(
      text: steuerbar ? null : _de.einstimmung_fuehrt(wer),
      child: PartyRahmen(
        marke: einstimmungZaehler(schritt),
        titel: s.ui(schritt.titel),
        aktionen: [
          if (!letzter)
            PartyKnopf(
              key: const ValueKey('einstimmung-ueberspringen'),
              text: einstimmungUeberspringenText(schritt.teil),
              haupt: false,
              icon: Icons.fast_forward_rounded,
              onPressed: steuerbar ? s.einstimmungUeberspringen : null,
            ),
          PartyKnopf(
            key: const ValueKey('einstimmung-weiter'),
            text: letzter ? (s.vorspielMorgen != null ? _de.einstimmung_zum_vorspiel : _de.rundgang_zur_einleitung) : _de.einstimmung_weiter,
            icon: Icons.arrow_forward_rounded,
            onPressed: steuerbar ? s.einstimmungWeiter : null,
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (figur != null) ...[
              VorstellungsKarte.fuer(s, figur, key: ValueKey('vorstellung-$figur')),
              const SizedBox(height: MMass.s16),
            ],
            ErzaehlerFeld(sitzung: s, kennungen: [schritt.kennung]),
          ],
        ),
      ),
    );
  }
}

/// Kapitelzähler eines Schritts: „Vorgeschichte · 3 von 7“.
String einstimmungZaehler(EinstimmungSchritt s) => _de.einstimmung_zaehler(
      s.teil == EinstimmungTeil.vorgeschichte ? _de.einstimmung_vorgeschichte : _de.einstimmung_vorstellung,
      '${s.nr}',
      '${s.von}',
    );

/// „Vorgeschichte überspringen“ bzw. „Vorstellung überspringen“.
String einstimmungUeberspringenText(EinstimmungTeil teil) =>
    teil == EinstimmungTeil.vorgeschichte ? _de.einstimmung_ueberspringen_vorgeschichte : _de.einstimmung_ueberspringen_vorstellung;

/// Die Karte einer vorgestellten Figur (oder des Detektivs): Porträt, Name,
/// Rollentitel, typischer Satz aus dem Steckbrief und darunter, wer sie am Tisch
/// spielt ([spieler]: „gespielt von …“, im Solo „Die App spielt …“). Nur
/// Öffentliches; gleich am Tisch und auf der Gastseite. Der Vorlesetext steht
/// nie darin.
class VorstellungsKarte extends StatelessWidget {
  const VorstellungsKarte({super.key, required this.look, required this.name, this.rolle, this.satz, this.spieler, this.akzent, this.marke});

  /// Die Karte der Figur [figur] an diesem Abend.
  factory VorstellungsKarte.fuer(PartySitzung s, String figur, {Key? key}) {
    final detektiv = figur == Besetzung.detektiv;
    LookDef? look;
    try {
      look = s.figurAussehen(figur);
    } catch (_) {
      look = null;
    }
    return VorstellungsKarte(
      key: key,
      look: look,
      name: detektiv ? s.ui('ui.einrichtung.detektiv_${s.einstellungen.detektiv}') : s.figurName(figur),
      rolle: detektiv ? null : s.figurTitel(figur),
      satz: s.daten.steckbriefe?.je[figur]?.satz,
      spieler: vorstellungSpieler(s, figur),
      akzent: detektiv ? null : s.figurFarbe(figur),
    );
  }

  final LookDef? look;
  final String name;
  final String? rolle, satz;

  /// Wer die Figur spielt, fertig gesetzt; `null`: keine Zeile.
  final String? spieler;
  final Color? akzent;

  /// Etikett über dem Namen (Gast: „Du bist dran“), sonst nichts.
  final String? marke;

  @override
  Widget build(BuildContext context) {
    final rolle = this.rolle, satz = this.satz, spieler = this.spieler, marke = this.marke;
    return MBlatt(
      key: const ValueKey('vorstellungskarte'),
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      randFarbe: akzent,
      neigung: -0.004,
      samen: name.codeUnits.fold(17, (a, b) => (a * 31 + b) & 0xffff),
      padding: const EdgeInsets.fromLTRB(16, 14, 18, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: look == null
                ? const MOnlineSilhouette(groesse: 76, samen: 17)
                : MFotoabzug(look: look!, groesse: 76, neigung: -0.04, klammer: true, akzent: akzent),
          ),
          const SizedBox(width: MMass.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (marke != null) ...[
                  Align(alignment: Alignment.centerLeft, child: MChip(marke, key: const ValueKey('vorstellung-marke'), icon: Icons.star_rounded, gefuellt: true)),
                  const SizedBox(height: MMass.s8),
                ],
                MGanzeWorte(name, stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 21), minimum: 16),
                if (rolle != null && rolle.isNotEmpty) Text(rolle, style: MPapierSchrift.leise),
                if (satz != null && satz.isNotEmpty) ...[
                  const SizedBox(height: MMass.s8),
                  Text('„$satz“', key: const ValueKey('vorstellung-satz'), style: MPapierSchrift.kursiv),
                ],
                if (spieler != null) ...[
                  const SizedBox(height: MMass.s8),
                  Text(spieler, key: const ValueKey('vorstellung-spieler'), style: MPapierSchrift.hand.copyWith(fontSize: 20)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wer [figur] an diesem Abend spielt, als Zeile der Vorstellungskarte:
/// „gespielt von …“ mit dem Namen am Tisch; spielt die App sie (Solo, online
/// ohne Gerät), „Die App spielt …“. Den Detektiv nennt die Zeile nur mit Namen.
/// Reihum ohne eingetragenen Namen gibt es keine Zeile (`null`).
String? vorstellungSpieler(PartySitzung s, String figur) {
  if (figur == Besetzung.detektiv) {
    final n = s.detektivName.trim();
    return n.isEmpty ? null : _de.einstimmung_gespielt_von(n);
  }
  final n = s.solo ? '' : (s.namen[figur] ?? '').trim();
  if (n.isNotEmpty) return _de.einstimmung_gespielt_von(n);
  return s.solo || s.online ? _de.einstimmung_app_spielt(s.figurName(figur)) : null;
}
