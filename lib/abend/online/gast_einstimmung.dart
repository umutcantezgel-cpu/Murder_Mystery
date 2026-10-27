import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show Besetzung, EinstimmungSchritt, EinstimmungTeil;

import '../../party/bildschirme/einstimmung.dart' show VorstellungsKarte, einstimmungUeberspringenText, einstimmungZaehler;
import '../../party/bildschirme/erzaehlerpult.dart' show VorleserKarte;
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_ansicht.dart' show GastKontext;
import 'online_teile.dart';

/// Die laufende Einstimmung des Raums (Vorgeschichte und Vorstellung, A-063),
/// sonst `null`: öffentlich `einstimmung` mit Teil, Schritt, Zahl, Nummer im
/// Teil, Kennung und vorgestellter Figur. Nie der Text.
Map<String, Object?>? gastEinstimmung(GastKontext c) => c.v['einstimmung'] is Map ? jMap(c.v['einstimmung']) : null;

/// Der laufende Schritt als [EinstimmungSchritt], sonst `null`.
EinstimmungSchritt? gastEinstimmungSchritt(GastKontext c) {
  final e = gastEinstimmung(c);
  final teil = EinstimmungTeil.values.where((t) => t.name == e?['teil']).firstOrNull;
  if (e == null || teil == null) return null;
  final figur = e['figur'];
  return EinstimmungSchritt(teil: teil, kennung: jText(e['kennung']), figur: figur is String ? figur : null, nr: jZahl(e['nr'], 1), von: jZahl(e['von'], 1));
}

/// Kapiteltitel des Schritts aus der Akte des Geräts (nicht vorgelesen); ohne
/// geladene Akte der Name des Teils.
String gastEinstimmungTitel(GastKontext c, EinstimmungSchritt s) {
  try {
    final t = c.daten?.texte.baustein(s.titel);
    if (t != null && t.trim().isNotEmpty) return t;
  } catch (_) {
    // Fehlt der Baustein, steht der Name des Teils da.
  }
  return s.teil == EinstimmungTeil.vorgeschichte ? c.l.einstimmung_vorgeschichte : c.l.einstimmung_vorstellung;
}

/// Vorgeschichte und Vorstellung auf dem Gerät eines Gastes: Kapitelzähler,
/// bei einer Figur die Vorstellungskarte für alle (eigene Figur: „Du bist
/// dran“), den Vorlesetext nur beim Vorleser-Sitz (privat `einstimmungText`),
/// sonst wer vorliest. Wer leitet, schaltet weiter ([gastEinstimmungAktionen]).
class GastEinstimmung extends StatelessWidget {
  const GastEinstimmung({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  Widget build(BuildContext context) {
    final c = kontext;
    final l = c.l;
    final s = gastEinstimmungSchritt(c);
    if (s == null) return const SizedBox.shrink();
    final schritt = jZahl(gastEinstimmung(c)?['schritt']);
    final text = c.privat['einstimmungText'];
    final figur = s.figur;
    return Column(
      key: ValueKey('gast-einstimmung-$schritt'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: MMass.s12),
          child: Text(l.einstimmung_laeuft.toUpperCase(), key: const ValueKey('gast-einstimmung-laeuft'), style: c.t.marke),
        ),
        Text(einstimmungZaehler(s).toUpperCase(), key: const ValueKey('gast-einstimmung-zaehler'), style: c.t.marke),
        const SizedBox(height: MMass.s12),
        if (figur != null) ...[
          _karte(c, figur, detektiv: s.kennung.endsWith('.m') ? 'm' : 'w'),
          const SizedBox(height: MMass.s12),
        ],
        if (text is String)
          MBlatt(
            key: const ValueKey('gast-einstimmung-vorlesetext'),
            klammer: true,
            neigung: 0.004,
            samen: text.length,
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 20),
            child: MGanzeWorte(text, stil: MPapierSchrift.erzaehler, minimum: 14),
          )
        else
          VorleserKarte(name: c.leiterName, texte: 1),
        if (!c.leitet) ...[
          const SizedBox(height: MMass.s16),
          OnlineWarteNotiz(text: l.einstimmung_fuehrt(c.leiterName.isEmpty ? l.vorleser_erzaehler : c.leiterName), uhr: false),
        ],
        const SizedBox(height: MMass.s16),
      ],
    );
  }

  /// Die Vorstellungskarte: wer die Figur spielt, steht nur auf der Karte. Ist
  /// es dieses Gerät, „Du bist dran“; spielt sie kein Gerät, die App.
  Widget _karte(GastKontext c, String figur, {required String detektiv}) {
    final l = c.l;
    final istDetektiv = figur == Besetzung.detektiv;
    final platz = istDetektiv ? onlineDetektivPlatz(c.spieler) : c.spieler.where((p) => p.rolle == figur).firstOrNull;
    final ich = platz != null && platz.id == c.ichId;
    final name = platz?.name.trim() ?? '';
    final figurName = istDetektiv ? _detektivName(c, detektiv) : c.figurName(figur);
    final String? spieler = name.isNotEmpty && name != figurName
        ? l.einstimmung_gespielt_von(name)
        : (!istDetektiv && platz == null ? l.einstimmung_app_spielt(figurName) : null);
    return VorstellungsKarte(
      key: ValueKey('gast-vorstellung-$figur'),
      look: c.aussehen(istDetektiv ? c.detektivId : figur),
      name: figurName,
      rolle: istDetektiv ? null : c.figurTitel(figur),
      satz: c.daten?.steckbriefe?.je[figur]?.satz,
      spieler: spieler,
      akzent: istDetektiv ? null : c.figurFarbe(figur),
      marke: ich ? l.einstimmung_du_bist_dran : null,
    );
  }

  /// „Detektiv“ bzw. „Detektivin“ aus der Akte; ohne Akte das Wort des Sitzes.
  String _detektivName(GastKontext c, String g) {
    try {
      return c.daten?.texte.baustein('ui.einrichtung.detektiv_$g') ?? c.detektivWort;
    } catch (_) {
      return c.detektivWort;
    }
  }
}

/// Knöpfe der Einstimmung für das Gerät, das leitet: den Rest des Teils
/// überspringen und weiter (am letzten Schritt zur Einleitung bzw. zum
/// Vorspiel). Sonst keine.
List<Widget> gastEinstimmungAktionen(GastKontext c) {
  final e = gastEinstimmung(c);
  final s = gastEinstimmungSchritt(c);
  if (e == null || s == null || !c.leitet) return const [];
  final l = c.l;
  final schritt = jZahl(e['schritt']);
  final letzter = schritt >= jZahl(e['anzahl'], 1) - 1;
  final vorspiel = c.fassung.istLang && c.daten?.vorspielMorgen != null;
  return [
    if (!letzter)
      MKnopf(
        key: const ValueKey('gast-einstimmung-ueberspringen'),
        text: einstimmungUeberspringenText(s.teil),
        art: MKnopfArt.zweit,
        icon: Icons.fast_forward_rounded,
        onPressed: c.verbunden ? () => c.befehl({'typ': 'einstimmung', 'ueberspringen': true}) : null,
      ),
    MKnopf(
      key: const ValueKey('gast-einstimmung-weiter'),
      text: letzter ? (vorspiel ? l.einstimmung_zum_vorspiel : l.rundgang_zur_einleitung) : l.einstimmung_weiter,
      icon: Icons.arrow_forward_rounded,
      onPressed: c.verbunden ? () => c.befehl({'typ': 'einstimmung', 'schritt': schritt}) : null,
    ),
  ];
}
