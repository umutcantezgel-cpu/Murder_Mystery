import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show PartyPhase, Texte;
import 'package:mordakte_core/runden.dart' show ZielStand, ZugArt, tippKeiner;

import '../../l10n/gen/app_localizations.dart';
import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/mappe/abend2_bausteine.dart';
import '../../stil/stil.dart';
import '../einfluss_sicht.dart';
import '../party_stil.dart';
import '../sitzung.dart';

final _de = LDe();

/// Texte der Oberfläche: aus der Lokalisierung, sonst deutsch (Tests ohne Delegates).
L momentTexte(BuildContext context) => Localizations.of<L>(context, L) ?? _de;

/// Wie die Bausteine der Schicht Figuren und Texte zeigen: an einem Gerät aus
/// der Sitzung ([EinflussDarstellung.sitzung]), online aus der Akte des Gastes.
/// Story-Texte kommen allein aus der Akte (`einfluss.*`), Bedienwörter aus der ARB.
class EinflussDarstellung {
  const EinflussDarstellung({required this.texte, required this.name, required this.bild});

  /// Am Tisch: Namen am Tisch und Fotoabzüge aus der Sitzung.
  factory EinflussDarstellung.sitzung(PartySitzung s) => EinflussDarstellung(
        texte: s.daten.texte,
        name: s.spielerName,
        bild: (f, groesse) => MFotoabzug(look: s.figurAussehen(f), groesse: groesse, neigung: f.length.isEven ? -0.04 : 0.04, akzent: s.figurFarbe(f)),
      );

  final Texte texte;

  /// Name am Tisch zu einer Figur (Spielername, sonst Figurenname).
  final String Function(String figur) name;

  /// Fotoabzug einer Figur in der Größe [groesse].
  final Widget Function(String figur, double groesse) bild;

  String text(String kennung) => texte.baustein(kennung);

  /// Kurzname einer Zugart (`einfluss.zug.<art>.titel`); abgewartet hat keinen Kartentext.
  String zugTitel(L l, ZugArt a) => a == ZugArt.abgewartet ? l.moment_abgewartet : text('einfluss.zug.${a.name}.titel');

  /// Ein Zug in Kurzform: Art, mit Ziel „Art auf Name“ (sich selbst: „Ich selbst“).
  String zugKurz(L l, ZugSicht z, {String? ich}) {
    final ziel = z.ziel;
    if (ziel == null) return zugTitel(l, z.art);
    return l.moment_zug_auf(zugTitel(l, z.art), ziel == ich ? l.moment_ich_selbst : name(ziel));
  }

  /// Wortlaut einer privaten Nachricht mit Anzeigenamen und Kurzname der Zugart.
  String nachricht(NachrichtSicht n) => texte.einflussText(n.schluessel, figur: n.figur, ziel: n.ziel, zug: n.zug);
}

/// Sinnbild je Zugart (Protokoll der Nacht, Kacheln, Zug-Tafel).
IconData zugSymbol(ZugArt a) => switch (a) {
      ZugArt.zeigen => Icons.record_voice_over_rounded,
      ZugArt.decken => Icons.shield_rounded,
      ZugArt.helfen => Icons.volunteer_activism_rounded,
      ZugArt.auspacken => Icons.lock_open_rounded,
      ZugArt.ablenken => Icons.celebration_rounded,
      ZugArt.lauschen => Icons.hearing_rounded,
      ZugArt.abgewartet => Icons.hourglass_empty_rounded,
    };

/// Formularkopf in Stempelrot mit Tintenlinie (Abschnitte der Moment-Karten).
class MomentKopf extends StatelessWidget {
  const MomentKopf(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MGanzeWorte(text.toUpperCase(), stil: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, letterSpacing: 1.1)),
          const SizedBox(height: 4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
        ],
      );
}

/// Ein Stichpunkt mit Tintenpunkt (Karten nach R17).
class MomentPunkt extends StatelessWidget {
  const MomentPunkt(this.text, {super.key, this.stil});

  final String text;
  final TextStyle? stil;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Container(width: 5, height: 5, decoration: BoxDecoration(color: MRoh.stempelRot.withValues(alpha: 0.8), shape: BoxShape.circle)),
            ),
            Expanded(child: Text(text, style: stil ?? MPapierSchrift.text.copyWith(fontSize: 15))),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Der heimliche Zug: Raster, Zielwahl, Tipp

/// Der heimliche Zug einer Rolle (§3.2): Raster 2 × 3 der Zugarten (Kartentexte
/// `einfluss.zug.*`, ausgegraut, was nicht geht), darunter bei Zügen mit Ziel die
/// Zielwahl mit Fotoabzügen (beim Decken auch „Ich selbst“), in der Tipp-Runde
/// der geheime Tipp und „Das ist mein Zug“. Oben die Kachel „Wie letzte Runde“.
/// Schmal oder mit großer Schrift steht eine Kachel je Zeile.
///
/// Gleich am Tisch (verdeckte Ansicht) und am eigenen Gerät (Gast); die Daten
/// kommen aus `moment` ([MomentSicht]).
class HeimlicherZug extends StatefulWidget {
  const HeimlicherZug({super.key, required this.moment, required this.rolle, required this.darstellung, required this.onZug, this.laeuft = false});

  final MomentSicht moment;

  /// Die eigene Figur (für „Ich selbst“).
  final String rolle;
  final EinflussDarstellung darstellung;

  /// Der Zug ist gewählt; `null`: gerade nicht möglich (keine Verbindung).
  final void Function(ZugArt art, String? ziel, String? tipp)? onZug;

  /// Ein Zug ist unterwegs (online); der Knopf ruht.
  final bool laeuft;

  @override
  State<HeimlicherZug> createState() => _HeimlicherZugState();
}

class _HeimlicherZugState extends State<HeimlicherZug> {
  ZugArt? _art;
  String? _ziel;
  String? _tipp;

  MomentSicht get m => widget.moment;
  EinflussDarstellung get d => widget.darstellung;

  @override
  void initState() {
    super.initState();
    // Ein schon gesetzter Zug steht vorgewählt da; ändern geht bis zu den Folgen.
    final z = m.zug;
    if (z != null && m.arten.contains(z.art)) {
      _art = z.art;
      _ziel = z.ziel;
      _tipp = z.tipp;
    }
  }

  bool _brauchtZiel(ZugArt a) => (m.ziele[a] ?? const <String>[]).isNotEmpty;

  bool get _bereit {
    final a = _art;
    if (a == null) return false;
    if (_brauchtZiel(a) && !(m.ziele[a] ?? const <String>[]).contains(_ziel)) return false;
    if (m.tipps.isNotEmpty && !m.tipps.contains(_tipp)) return false;
    return true;
  }

  void _waehle(ZugArt a, {String? ziel}) => setState(() {
        _art = a;
        _ziel = _brauchtZiel(a) ? (ziel ?? ((m.ziele[a] ?? const <String>[]).contains(_ziel) ? _ziel : null)) : null;
      });

  @override
  Widget build(BuildContext context) {
    final l = momentTexte(context);
    final letzte = m.wieLetzteRunde;
    final a = _art;
    final eigen = m.zug;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MomentKopf(l.moment_zug_waehlen),
        if (eigen != null)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s8),
            child: Text(l.moment_dein_zug(d.zugKurz(l, eigen, ich: widget.rolle)), key: const ValueKey('moment-gesetzt'), style: MPapierSchrift.kursiv),
          ),
        if (letzte != null) ...[
          _Kachel(
            key: const ValueKey('moment-wie-letzte'),
            titel: l.moment_wie_letzte,
            punkte: [d.zugKurz(l, letzte, ich: widget.rolle)],
            symbol: Icons.replay_rounded,
            gewaehlt: a == letzte.art && _ziel == letzte.ziel,
            onTap: () => _waehle(letzte.art, ziel: letzte.ziel),
          ),
          const SizedBox(height: MMass.s12),
        ],
        LayoutBuilder(
          builder: (context, box) {
            // Zwei Spalten, solange eine Kachel bei dieser Schrift mindestens 120 Punkte breit bleibt.
            final skala = MediaQuery.textScalerOf(context).scale(10) / 10;
            const abstand = MMass.s8;
            final spalten = (box.maxWidth - abstand) / 2 / skala >= 120 ? 2 : 1;
            final breite = (box.maxWidth - abstand * (spalten - 1)) / spalten;
            return Wrap(
              spacing: abstand,
              runSpacing: abstand,
              children: [
                for (final art in ZugArt.waehlbar)
                  SizedBox(
                    width: breite,
                    child: _Kachel(
                      key: ValueKey('zug-${art.name}'),
                      titel: d.text('einfluss.zug.${art.name}.titel'),
                      punkte: [for (final p in const ['p1', 'p2', 'p3']) d.text('einfluss.zug.${art.name}.$p')],
                      symbol: zugSymbol(art),
                      gewaehlt: a == art,
                      gesperrt: m.arten.contains(art) ? null : (_gespielt(art) ? l.moment_einmal : l.moment_gesperrt),
                      onTap: () => _waehle(art),
                    ),
                  ),
              ],
            );
          },
        ),
        if (a != null && _brauchtZiel(a)) ...[
          const SizedBox(height: MMass.s16),
          Text(d.text('einfluss.zug.${a.name}.wahl'), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
          const SizedBox(height: MMass.s8),
          _FigurenWahl(
            praefix: 'ziel',
            figuren: m.ziele[a]!,
            gewaehlt: _ziel,
            darstellung: d,
            beschriftung: (f) => f == widget.rolle ? l.moment_ich_selbst : d.name(f),
            onWahl: (f) => setState(() => _ziel = f),
          ),
        ],
        if (m.tipps.isNotEmpty) ...[
          const SizedBox(height: MMass.s16),
          MomentKopf(d.text('einfluss.tipp.titel')),
          MomentPunkt(d.text('einfluss.tipp.p1')),
          const SizedBox(height: MMass.s4),
          Text(d.text('einfluss.tipp.wahl'), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
          const SizedBox(height: MMass.s8),
          _FigurenWahl(
            praefix: 'tipp',
            figuren: m.tipps,
            gewaehlt: _tipp,
            darstellung: d,
            beschriftung: (f) => f == tippKeiner ? l.moment_keine_ahnung : d.name(f),
            onWahl: (f) => setState(() => _tipp = f),
          ),
        ],
        const SizedBox(height: MMass.s16),
        MKnopf(
          key: const ValueKey('moment-bestaetigen'),
          text: l.moment_bestaetigen,
          breit: true,
          ganzeWorte: true,
          onPressed: _bereit && !widget.laeuft && widget.onZug != null
              ? () => widget.onZug!(_art!, _brauchtZiel(_art!) ? _ziel : null, m.tipps.isEmpty ? null : _tipp)
              : null,
        ),
      ],
    );
  }

  /// Hat die Rolle diese Einmal-Art schon gespielt (Auspacken)?
  bool _gespielt(ZugArt art) => m.zuege.any((z) => z.art == art);
}

/// Eine Kachel des Rasters: Sinnbild, Titel und bis zu drei Stichpunkte (R17).
/// Gewählt trägt sie einen blauen Rahmen; gesperrt ist sie ausgegraut und nennt den Grund.
class _Kachel extends StatelessWidget {
  const _Kachel({super.key, required this.titel, required this.punkte, required this.symbol, required this.gewaehlt, required this.onTap, this.gesperrt});

  final String titel;
  final List<String> punkte;
  final IconData symbol;
  final bool gewaehlt;
  final String? gesperrt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final aus = gesperrt != null;
    return Semantics(
      button: true,
      selected: gewaehlt,
      enabled: !aus,
      child: Opacity(
        opacity: aus ? 0.45 : 1,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: aus ? null : onTap,
            borderRadius: BorderRadius.circular(3),
            splashFactory: NoSplash.splashFactory,
            highlightColor: MRoh.tinteBlau.withValues(alpha: 0.06),
            child: AnimatedContainer(
              duration: MBewegung.schnell(context),
              constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              decoration: BoxDecoration(
                color: gewaehlt ? MRoh.tinteBlau.withValues(alpha: 0.07) : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: gewaehlt ? MRoh.tinteBlau.withValues(alpha: 0.85) : MRoh.tinte.withValues(alpha: 0.35),
                  width: gewaehlt ? 1.9 : 1.1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(symbol, size: 22, color: gewaehlt ? MRoh.tinteBlau : MRoh.tinte),
                      const SizedBox(width: 8),
                      Expanded(child: MGanzeWorte(titel, stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18))),
                      if (gewaehlt) const Icon(Icons.check_rounded, size: 20, color: MRoh.tinteBlau),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (final p in punkte) MomentPunkt(p, stil: MPapierSchrift.text.copyWith(fontSize: 14, height: 1.3)),
                  if (gesperrt != null) Text(gesperrt!, style: MPapierSchrift.leise.copyWith(fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wahl einer Figur mit Fotoabzug (Ziel oder Tipp); Tippen wählt.
class _FigurenWahl extends StatelessWidget {
  const _FigurenWahl({
    required this.praefix,
    required this.figuren,
    required this.gewaehlt,
    required this.darstellung,
    required this.beschriftung,
    required this.onWahl,
  });

  final String praefix;
  final List<String> figuren;
  final String? gewaehlt;
  final EinflussDarstellung darstellung;
  final String Function(String figur) beschriftung;
  final ValueChanged<String> onWahl;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final skala = MediaQuery.textScalerOf(context).scale(10) / 10;
          // Drei bis vier Karten je Zeile; bei großer Schrift breiter, damit Namen ganz bleiben.
          final breite = (96 * skala).clamp(96.0, box.maxWidth);
          return Wrap(
            spacing: MMass.s8,
            runSpacing: MMass.s8,
            children: [
              for (final f in figuren)
                SizedBox(
                  width: breite,
                  child: Semantics(
                    button: true,
                    selected: gewaehlt == f,
                    label: beschriftung(f),
                    excludeSemantics: true,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        key: ValueKey('$praefix-$f'),
                        onTap: () => onWahl(f),
                        borderRadius: BorderRadius.circular(3),
                        splashFactory: NoSplash.splashFactory,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
                          decoration: BoxDecoration(
                            color: gewaehlt == f ? MRoh.tinteBlau.withValues(alpha: 0.07) : Colors.transparent,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: gewaehlt == f ? MRoh.tinteBlau.withValues(alpha: 0.85) : MRoh.tinte.withValues(alpha: 0.25),
                              width: gewaehlt == f ? 1.9 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (f == tippKeiner)
                                const SizedBox(width: 48, height: 48, child: Icon(Icons.help_outline_rounded, size: 34, color: MRoh.tinteLeise))
                              else
                                darstellung.bild(f, 48),
                              const SizedBox(height: 6),
                              MGanzeWorte(beschriftung(f), stil: MPapierSchrift.text.copyWith(fontSize: 14), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}

// ---------------------------------------------------------------------------
// Sterne, Nachrichten, Erklärung

/// Die zwei Sterne einer Rolle als Karteikarten (§3.9): Text des Ziels und Live-Stand.
class ZielKarten extends StatelessWidget {
  const ZielKarten({super.key, required this.sterne, required this.darstellung});

  final List<SternSicht> sterne;
  final EinflussDarstellung darstellung;

  @override
  Widget build(BuildContext context) {
    final l = momentTexte(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in sterne)
          Padding(
            key: ValueKey('stern-${s.nr}'),
            padding: const EdgeInsets.only(bottom: MMass.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  s.stand == ZielStand.erreicht ? Icons.star_rounded : (s.stand == ZielStand.verloren ? Icons.star_border_rounded : Icons.star_half_rounded),
                  color: s.stand == ZielStand.verloren ? MRoh.tinteLeise : MRoh.stempelRot,
                  size: 26,
                ),
                const SizedBox(width: MMass.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.moment_stern(s.nr).toUpperCase(), style: MPapierSchrift.marke),
                      Text(darstellung.text(s.schluessel), style: MPapierSchrift.text),
                      Text(switch (s.stand) {
                        ZielStand.offen => l.moment_stand_offen,
                        ZielStand.erreicht => l.moment_stand_erreicht,
                        ZielStand.verloren => l.moment_stand_verloren,
                      }, style: MPapierSchrift.leise),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Was die Rolle aus der Runde davor erfahren hat: private Nachrichten und
/// Lauschergebnis (§3.12), nur in der verdeckten Ansicht.
class MomentNachrichten extends StatelessWidget {
  const MomentNachrichten({super.key, required this.nachrichten, required this.darstellung});

  final List<NachrichtSicht> nachrichten;
  final EinflussDarstellung darstellung;

  @override
  Widget build(BuildContext context) {
    final l = momentTexte(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MomentKopf(l.moment_erfahren),
        if (nachrichten.isEmpty) Text(l.moment_nichts, key: const ValueKey('moment-nichts'), style: MPapierSchrift.leise),
        for (final n in nachrichten)
          Padding(
            key: ValueKey('nachricht-${n.schluessel}-${n.figur ?? ''}'),
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(n.gelauscht ? Icons.hearing_rounded : Icons.mark_email_unread_outlined, size: 18, color: MRoh.tinteBlau),
                const SizedBox(width: 8),
                Expanded(child: Text(darstellung.nachricht(n), style: MPapierSchrift.hand.copyWith(fontSize: 22))),
              ],
            ),
          ),
      ],
    );
  }
}

/// Kurze Erklärung „Dein Moment“ im Dossier (R17: drei Stichpunkte).
class MomentErklaerung extends StatelessWidget {
  const MomentErklaerung({super.key});

  @override
  Widget build(BuildContext context) {
    final l = momentTexte(context);
    return Column(
      key: const ValueKey('moment-erklaerung'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [MomentPunkt(l.moment_erklaerung_1), MomentPunkt(l.moment_erklaerung_2), MomentPunkt(l.moment_erklaerung_3)],
    );
  }
}

// ---------------------------------------------------------------------------
// Am Tisch: Liste reihum und verdeckte Ansicht

/// „Dein Moment“ in den Gesprächen an einem Gerät: je Person „offen“ oder
/// „fertig“, nie was sie zog. Antippen gibt das Gerät an sie weiter
/// (Zwischenstufe) und öffnet ihren Moment verdeckt. Im Solo ziehen die Bots.
class MomentListe extends StatelessWidget {
  const MomentListe({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final l = momentTexte(context);
    return MBlatt(
      key: const ValueKey('moment-liste'),
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      neigung: -0.003,
      samen: 77 + s.runde,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MomentKopf(l.moment_titel),
          Text(s.solo ? l.moment_solo : (s.momentOffen.isEmpty ? l.moment_alle : l.moment_hinweis), style: MPapierSchrift.leise),
          if (!s.solo) ...[
            const SizedBox(height: MMass.s8),
            for (final r in s.besetzt) _zeile(context, l, r),
          ],
        ],
      ),
    );
  }

  Widget _zeile(BuildContext context, L l, String rolle) {
    final s = sitzung;
    final fertig = s.momentGezogen(rolle);
    return Semantics(
      button: true,
      child: InkWell(
        key: ValueKey('moment-$rolle'),
        onTap: () => _weitergeben(context, rolle),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                MFotoabzug(look: s.figurAussehen(rolle), groesse: 36, neigung: rolle.length.isEven ? -0.05 : 0.04, akzent: s.figurFarbe(rolle)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MGanzeWorte(s.spielerName(rolle), stil: MPapierSchrift.text.copyWith(fontSize: 17)),
                      Text(l.moment_zeile(fertig ? l.moment_fertig : l.moment_offen), style: MPapierSchrift.leise.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
                Icon(fertig ? Icons.check : Icons.visibility_off_rounded, size: 20, color: fertig ? MRoh.tinteBlau : MRoh.tinteLeise),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Zwischenstufe: Das Gerät geht an diese Person; erst ihr Knopf öffnet den Moment.
  Future<void> _weitergeben(BuildContext context, String rolle) async {
    final s = sitzung;
    // Das Gerät geht schon während der Zwischenstufe weiter: Die Zug-Tafel am Pult ist zu (Finale §3.12).
    s.pultSchliessen();
    final l = momentTexte(context);
    final name = s.spielerName(rolle);
    final ja = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (c) => MKarteiFenster(
        titel: l.moment_weitergeben(name),
        inhalt: Center(child: MFotoabzug(look: s.figurAussehen(rolle), groesse: 72, neigung: -0.04, akzent: s.figurFarbe(rolle))),
        aktionen: [
          MKnopf(text: l.moment_zurueck, art: MKnopfArt.zweit, onPressed: () => Navigator.of(c).pop(false)),
          MKnopf(key: const ValueKey('moment-zeig-her'), text: l.moment_zeig_her(name), onPressed: () => Navigator.of(c).pop(true)),
        ],
      ),
    );
    if ((ja ?? false) && s.einfluss && s.phase == PartyPhase.gespraeche) s.momentZeigen(rolle);
  }
}

/// Die verdeckte Ansicht des Moments an einem Gerät: was die Person aus der
/// Runde davor erfahren hat, ihre zwei Sterne, der heimliche Zug. „Das ist mein
/// Zug“ deckt zu; „Zudecken“ lässt den Moment offen.
class MomentBildschirm extends StatelessWidget {
  const MomentBildschirm({super.key, required this.sitzung, required this.rolle});

  final PartySitzung sitzung;
  final String rolle;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final l = momentTexte(context);
    final m = s.momentSicht(rolle);
    final d = EinflussDarstellung.sitzung(s);
    return PartyRahmen(
      marke: l.moment_titel,
      titel: s.spielerName(rolle),
      untertitel: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
      aktionen: [PartyKnopf(text: s.ui('ui.verdeckt.schliessen'), haupt: false, onPressed: s.verdecken)],
      child: MBlatt(
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        randFarbe: s.figurFarbe(rolle),
        samen: 83 + s.runde,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (s.runde > 1) ...[MomentNachrichten(nachrichten: m.vorrunde, darstellung: d), const SizedBox(height: MMass.s12)],
            MomentKopf(l.moment_ziele),
            ZielKarten(sterne: m.sterne, darstellung: d),
            const SizedBox(height: MMass.s12),
            HeimlicherZug(
              key: ValueKey('zug-$rolle-${s.runde}'),
              moment: m,
              rolle: rolle,
              darstellung: d,
              onZug: (art, ziel, tipp) => s.momentZug(rolle, art, ziel: ziel, tipp: tipp),
            ),
          ],
        ),
      ),
    );
  }
}
