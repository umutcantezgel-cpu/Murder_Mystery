import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show LookDef;
import 'package:mordakte_core/runden.dart';

import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/stil.dart';
import '../../ui/widgets/portrait.dart' show PortraitPainter;
import '../katalog_laden.dart';
import 'spielkarte.dart';

final _de = LDe();

/// Texte der Karten ohne Kontext (die Oberfläche ist deutsch; die Quelle ist
/// `app_de.arb`). Hand und Spielkarten im Abend brauchen so keine Lokalisierung
/// über dem Widgetbaum.
abstract final class KartenTexte {
  static String seltenheit(Seltenheit s) => switch (s) {
        Seltenheit.gewoehnlich => _de.karten_seltenheit_gewoehnlich,
        Seltenheit.selten => _de.karten_seltenheit_selten,
        Seltenheit.legendaer => _de.karten_seltenheit_legendaer,
      };

  static String art(KartenArt a) => switch (a) {
        KartenArt.werkzeug => _de.karten_art_werkzeug,
        KartenArt.marke => _de.karten_art_marke,
        KartenArt.zeit => _de.karten_art_zeit,
        KartenArt.gruendlich => _de.karten_art_gruendlich,
        KartenArt.nochmal => _de.karten_art_nochmal,
        KartenArt.umweg => _de.karten_art_umweg,
        KartenArt.abstecher => _de.karten_art_abstecher,
        KartenArt.erinnerung => _de.karten_art_erinnerung,
        KartenArt.kosmetik => _de.karten_art_kosmetik,
      };

  static String ladungen(int n) => _de.karten_ladungen(n);

  static String quelle(KartenQuelle q) => switch (q.art) {
        'rolle' => _de.karten_quelle_rolle,
        'taeter' => _de.karten_quelle_taeter,
        'meister' => _de.karten_quelle_meister,
        'abstecher' => _de.karten_quelle_abstecher,
        'start' => _de.karten_quelle_start,
        _ => '',
      };

  static String get unbekannt => _de.karten_unbekannt;
  static String get rueckseite => _de.karten_rueckseite;

  // Hand und Abend (Party-Bildschirme, ohne Lokalisierung im Widgetbaum).
  static String get handTitel => _de.karten_hand_titel;
  static String handKarte(String titel, int rest, int max) => _de.karten_hand_karte(titel, rest, max);
  static String get handSpielbar => _de.karten_hand_spielbar;
  static String get handGesperrt => _de.karten_hand_gesperrt;
  static String get handGewaehlt => _de.karten_hand_gewaehlt;
  static String get handLeer => _de.karten_hand_leer;
  static String get handSpielen => _de.karten_hand_spielen;
  static String get handSchliessen => _de.karten_hand_schliessen;
  static String get handWuerfel => _de.karten_hand_wuerfel;
  static String get handTischruf => _de.karten_hand_tischruf;
  static String get handGruendlich => _de.karten_hand_gruendlich;
  static String get handKartenHinweis => _de.karten_hand_karte_hinweis;
  static String get handImZug => _de.karten_hand_im_zug;
  static String erkunden(String name) => _de.karten_erkunden(name);
  static String get erkundenMarke => _de.karten_erkunden_marke;
  static String get erkundenText => _de.karten_erkunden_text;
  static String erkundenKosten(int min, int pech) => _de.karten_erkunden_kosten(min, pech);
  static String get erkundenLos => _de.karten_erkunden_los;
  static String get erkundenNein => _de.karten_erkunden_nein;
  static String erkundenKarte(String titel) => _de.karten_erkunden_karte(titel);
  static String get erkundenWuerfel => _de.karten_erkunden_wuerfel;
  static String get erkundenFund => _de.karten_erkunden_fund;
  static String get erkundenListe => _de.karten_erkunden_liste;
  static String gruendlichKarte(String titel) => _de.karten_gruendlich_karte(titel);

  /// Folgezeile unter dem Wurf eines Abstechers (Minuten aus [ZugParameter]).
  static String erkundenFolge(Stufe stufe, ZugParameter p) => switch (stufe) {
        Stufe.erfolg => _de.karten_erkunden_erfolg_folge(p.erfolgGewinn),
        Stufe.teilerfolg => _de.karten_erkunden_teilerfolg_folge,
        Stufe.pech => _de.karten_erkunden_pech_folge(p.abstecherPechZeit),
      };
}

/// Zinn, Messing oder Blutgold je Seltenheit der Karte.
KartenSeltenheit seltenheitStufe(Seltenheit s) => switch (s) {
      Seltenheit.gewoehnlich => KartenSeltenheit.zinn,
      Seltenheit.selten => KartenSeltenheit.messing,
      Seltenheit.legendaer => KartenSeltenheit.blutgold,
    };

/// Tintenfarbe einer Seltenheit auf Papier: das Metall, mit Tinte abgedunkelt.
Color seltenheitTinte(Seltenheit s) => Color.lerp(MFarben.mordakte.seltenheit(seltenheitStufe(s).index), MRoh.tinte, 0.45)!;

/// Symbol der Wirkung einer Karte.
IconData artSymbol(KartenArt a) => switch (a) {
      KartenArt.werkzeug => Icons.search_rounded,
      KartenArt.marke => Icons.bubble_chart_rounded,
      KartenArt.zeit => Icons.hourglass_bottom_rounded,
      KartenArt.gruendlich => Icons.zoom_in_rounded,
      KartenArt.nochmal => Icons.replay_rounded,
      KartenArt.umweg => Icons.alt_route_rounded,
      KartenArt.abstecher => Icons.explore_rounded,
      KartenArt.erinnerung => Icons.menu_book_rounded,
      KartenArt.kosmetik => Icons.palette_rounded,
    };

/// Siegel der Akte unten auf der Karte (zwei Buchstaben).
String akteSigel(String akte) => AkteStil.fuer(akte).sigel;

/// Feste Messing- und Tintenfarben der Detektivklassen (`klasse:<name>`); sie
/// haben keinen Farbcode einer Figur.
const _klassenFarben = {
  'klasse:forensic': Color(0xFF2E5C66),
  'klasse:profiler': Color(0xFF4A3F73),
  'klasse:journalist': Color(0xFF8C6A2A),
  'klasse:excop': Color(0xFF6B3A2C),
  'klasse:medic': Color(0xFF2F6B52),
};

/// Grundfarbe des Ölverlaufs einer Karte: der Farbcode der Figur (leicht in
/// Sättigung und Helligkeit gefasst, damit Namensband und Text lesbar bleiben),
/// bei Detektivklassen die feste Messing-/Tintenfarbe, sonst der Ton der Akte.
/// Nie das Grau der Seltenheit: Zinn bleibt dem Rahmen und dem Edelstein.
Color kartenGrundfarbe(KartenDef def, KartenFigur? figur) {
  final stil = AkteStil.fuer(def.akte);
  final klasse = _klassenFarben[def.figur];
  if (klasse != null) return klasse;
  var c = figur?.farbe ?? Color.lerp(stil.hintergrund, stil.akzent, 0.5)!;
  // Fast farblose Codes (Schwarz, Grau, Weiß) bekommen einen Hauch der Akte.
  if (HSLColor.fromColor(c).saturation < 0.18) c = Color.lerp(c, stil.akzent, 0.3)!;
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness(hsl.lightness.clamp(0.28, 0.5)).withSaturation(hsl.saturation.clamp(0.25, 0.9)).toColor();
}

/// Eine Sammelkarte des Katalogs als [SpielKarte]. Das Bildfeld zeigt, wenn das
/// Aussehen der Figur bekannt ist, ihre Büste (mit dem Symbol der Wirkung als
/// Marke), sonst das große Symbol der Wirkung.
class KartenKarte extends StatelessWidget {
  const KartenKarte({
    super.key,
    required this.def,
    this.figur,
    this.breite,
    this.aufgedeckt = true,
    this.umdrehbar = false,
    this.onUmgedreht,
    this.rueckseitenSemantik,
  });

  final KartenDef def;
  final KartenFigur? figur;
  final double? breite;
  final bool aufgedeckt;
  final bool umdrehbar;
  final ValueChanged<bool>? onUmgedreht;

  /// Beschriftung der Rückseite für den Bildschirmleser (sonst „Kartenrückseite“).
  final String? rueckseitenSemantik;

  @override
  Widget build(BuildContext context) {
    final stufe = seltenheitStufe(def.seltenheit);
    // Die Karte ist ein dunkler Gegenstand mit eigener Schrift, auch wenn sie auf
    // einem Blatt Papier liegt: darunter gelten die Farben des Schreibtischs.
    return MFlaeche.dunkel(
      child: SpielKarte(
        name: def.titel,
        farbe: kartenGrundfarbe(def, figur),
        wirkung: def.text,
        seltenheit: stufe,
        seltenheitText: KartenTexte.seltenheit(def.seltenheit),
        akte: akteSigel(def.akte),
        aufgedeckt: aufgedeckt,
        umdrehbar: umdrehbar,
        onUmgedreht: onUmgedreht,
        rueckseitenSemantik: rueckseitenSemantik ?? KartenTexte.rueckseite,
        breite: breite,
        bild: KartenMotiv(art: def.art, look: figur?.look),
      ),
    );
  }
}

/// Bild einer Karte: mit [look] die Büste der Figur und das Symbol der Wirkung
/// als kleine Marke oben links, ohne [look] das große Symbol der Wirkung.
class KartenMotiv extends StatelessWidget {
  const KartenMotiv({super.key, required this.art, this.look});

  final KartenArt art;
  final LookDef? look;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final l = look;
    return SizedBox.square(
      dimension: 100,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [f.papier.withValues(alpha: l == null ? 0.2 : 0.28), f.papier.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          if (l != null) ...[
            Positioned.fill(child: CustomPaint(painter: PortraitPainter(look: l, background: false, accent: f.akzentHell))),
            Positioned(
              left: 8,
              top: 12,
              width: 26,
              height: 26,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x99000000),
                  border: Border.all(color: f.papier.withValues(alpha: 0.7)),
                ),
                child: Icon(artSymbol(art), size: 16, color: f.papier.withValues(alpha: 0.95)),
              ),
            ),
          ] else
            Center(child: Icon(artSymbol(art), size: 56, color: f.papier.withValues(alpha: 0.92))),
        ],
      ),
    );
  }
}

/// Eine noch unbekannte Karte: verdeckt, gedämpft, mit Silhouette.
class UnbekannteKarte extends StatelessWidget {
  const UnbekannteKarte({super.key, this.breite, this.semantik});

  final double? breite;

  /// Beschriftung für den Bildschirmleser.
  final String? semantik;

  @override
  Widget build(BuildContext context) => MFlaeche.dunkel(child: Builder(builder: _baue));

  Widget _baue(BuildContext context) {
    final f = MFarben.von(context);
    return LayoutBuilder(
      builder: (context, box) {
        final w = breite ?? (box.maxWidth.isFinite ? box.maxWidth : 120.0);
        return Semantics(
          label: semantik ?? KartenTexte.unbekannt,
          image: true,
          excludeSemantics: true,
          child: SizedBox(
            width: w,
            height: w / MMass.kartenSeiten,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 0.55,
                  child: SpielKarte(
                    name: '',
                    farbe: f.zinn,
                    aufgedeckt: false,
                    umdrehbar: false,
                    breite: w,
                    rueckseitenSemantik: KartenTexte.unbekannt,
                  ),
                ),
                Center(child: Icon(Icons.person_rounded, size: w * 0.42, color: f.grund.withValues(alpha: 0.78))),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Kleine Marke „NEU“ für eine frisch erhaltene Karte: auf dem Schreibtisch ein
/// Etikett im Akzent, auf Papier ein stempelrotes Etikett mit heller Schrift.
class NeuMarke extends StatelessWidget {
  const NeuMarke({super.key});

  @override
  Widget build(BuildContext context) {
    if (!MFlaeche.hellVon(context)) return MChip(_de.karten_neu, gefuellt: true, farbe: MFarben.von(context).akzent);
    return DecoratedBox(
      decoration: BoxDecoration(color: MRoh.stempelRot, borderRadius: BorderRadius.circular(2)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 9, 3),
        child: Text(_de.karten_neu, style: MRohSchrift.schreibmaschine.copyWith(fontSize: 13, height: 1.2, letterSpacing: 0.5, color: MRoh.blatt)),
      ),
    );
  }
}
