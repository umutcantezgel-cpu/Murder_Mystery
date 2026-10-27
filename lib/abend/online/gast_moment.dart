import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart' show EinflussFund, Sitz, momentAufrufFrist;

import '../../party/bildschirme/einfluss_teile.dart';
import '../../party/bildschirme/moment.dart';
import '../../party/einfluss_sicht.dart';
import '../../stil/mappe/online_bausteine.dart' show MOnlineSilhouette;
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_ansicht.dart' show GastKontext;

/// „Dein Moment“ am eigenen Gerät (Finale §3, online): Wer eine Figur spielt,
/// zieht in den Gesprächen über den pulsierenden Knopf „Dein Moment“ geheim
/// seinen Zug (Nachricht `zug`), alles aus privat `moment`. Der Detektiv sieht
/// nur Wirkungen (Abzeichen, Leisten, Gerüchte, Funde) und stellt Nachfragen
/// (`nachfrage`); wer leitet, gibt den letzten Aufruf (`letzterAufruf`) mit
/// Countdown aus `einfluss.aufruf`; der Erzähler-Sitz sieht `einflussTafel`;
/// ab dem Finale alle `aufloesung.einfluss`. Ohne Schicht trägt die Ansicht
/// keinen dieser Schlüssel, und nichts hiervon erscheint.

/// Öffentliche Lage der Schicht aus der Ansicht, sonst `null` (ohne Schicht).
EinflussLage? gastEinflussLage(GastKontext c) => c.v['einfluss'] is Map ? EinflussLage.ausJson(c.v['einfluss']) : null;

/// Darstellung für die Bausteine der Schicht: Texte aus der Akte des Geräts,
/// Namen am Tisch und Fotoabzüge; `null`, solange die Akte lädt.
EinflussDarstellung? gastDarstellung(GastKontext c) {
  final d = c.daten;
  if (d == null) return null;
  return EinflussDarstellung(
    texte: d.texte,
    name: c.personAmTisch,
    bild: (f, groesse) {
      final look = c.aussehen(f);
      return look == null
          ? MOnlineSilhouette(groesse: groesse, neigung: -0.04, samen: f.length)
          : MFotoabzug(look: look, groesse: groesse, neigung: f.length.isEven ? -0.04 : 0.04, akzent: c.figurFarbe(f));
    },
  );
}

/// Menschen, auf deren Zug der Raum in den laufenden Gesprächen noch wartet (`einfluss.offen`; wer
/// aufgab, zieht als Bot und fehlt dort).
List<String> gastMomentOffen(GastKontext c) {
  final o = gastEinflussLage(c)?.offen;
  if (c.phase != 'gespraeche' || o == null) return const [];
  return o;
}

/// Restzeit des letzten Aufrufs in Millisekunden (Abendzeit des Gastgebers), sonst `null`.
int? gastAufrufRest(GastKontext c) {
  final a = gastEinflussLage(c)?.aufruf;
  if (a == null || c.phase != 'gespraeche') return null;
  return a + momentAufrufFrist - c.dienst.gastgeberZeit;
}

/// Wartet „Weiter“ noch auf den Moment (letzter Aufruf läuft, nicht alle haben gezogen)?
bool gastMomentWartet(GastKontext c) {
  if (gastMomentOffen(c).isEmpty) return false;
  final rest = gastAufrufRest(c);
  return rest != null && rest > 0;
}

// ---------------------------------------------------------------------------
// Figuren: der Knopf und der Moment

/// Der Moment eines Gastes mit Figur in den Gesprächen; sonst `null`.
Widget? gastMomentKarte(GastKontext c) {
  if (c.phase != 'gespraeche' || c.privat['moment'] is! Map) return null;
  return GastMomentKarte(key: ValueKey('gast-moment-${c.runde}-${c.rolle}'), kontext: c);
}

/// Pulsierender Knopf „Dein Moment“; offen die verdeckte Ansicht mit dem
/// heimlichen Zug. Nach dem Senden ist sie zu; bis zu den Folgen lässt sich der
/// Zug ändern.
class GastMomentKarte extends StatefulWidget {
  const GastMomentKarte({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  State<GastMomentKarte> createState() => _GastMomentKarteState();
}

class _GastMomentKarteState extends State<GastMomentKarte> with SingleTickerProviderStateMixin {
  bool _offen = false;
  bool _laeuft = false;
  late final AnimationController _puls = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  GastKontext get c => widget.kontext;

  @override
  void dispose() {
    _puls.dispose();
    super.dispose();
  }

  Future<void> _ziehen(MomentSicht m, String art, String? ziel, String? tipp) async {
    if (_laeuft) return;
    setState(() => _laeuft = true);
    try {
      await c.befehl({'typ': 'zug', 'art': art, 'ziel': ?ziel, 'tipp': ?tipp});
      if (mounted) setState(() => _offen = false);
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = momentTexte(context);
    final m = MomentSicht.ausJson(c.privat['moment']);
    final d = gastDarstellung(c);
    final rolle = c.rolle;
    if (!m.offen || d == null || rolle == null) return const SizedBox.shrink();
    final gezogen = m.zug != null;
    // Der Knopf pulsiert, solange der Zug fehlt (nicht bei reduzierter Bewegung).
    if (!gezogen && !_offen && !MBewegung.ruhig(context)) {
      if (!_puls.isAnimating) _puls.repeat(reverse: true);
    } else {
      _puls.stop();
    }
    final rest = gastAufrufRest(c);
    final countdown = rest != null && rest > 0 && !gezogen ? GastAufrufUhr(kontext: c, key: const ValueKey('gast-countdown')) : null;
    if (!_offen) {
      return Padding(
        padding: const EdgeInsets.only(bottom: MMass.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _puls, curve: Curves.easeInOut)),
              child: MKnopf(
                key: const ValueKey('gast-moment-knopf'),
                text: l.moment_titel,
                icon: Icons.auto_awesome_rounded,
                breit: true,
                gross: true,
                onPressed: c.verbunden ? () => setState(() => _offen = true) : null,
              ),
            ),
            if (gezogen)
              Padding(
                padding: const EdgeInsets.only(top: MMass.s8),
                child: Text(l.moment_gezogen_online, key: const ValueKey('gast-moment-gezogen'), style: MSchrift.von(context).leise),
              ),
            ?countdown,
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: MBlatt(
        key: const ValueKey('gast-moment-offen'),
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        randFarbe: c.figurFarbe(rolle),
        samen: 83 + c.runde,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ?countdown,
            if (c.runde > 1) ...[MomentNachrichten(nachrichten: m.vorrunde, darstellung: d), const SizedBox(height: MMass.s12)],
            MomentKopf(l.moment_ziele),
            ZielKarten(sterne: m.sterne, darstellung: d),
            const SizedBox(height: MMass.s12),
            HeimlicherZug(
              moment: m,
              rolle: rolle,
              darstellung: d,
              laeuft: _laeuft,
              onZug: c.verbunden ? (art, ziel, tipp) => _ziehen(m, art.name, ziel, tipp) : null,
            ),
            const SizedBox(height: MMass.s8),
            MKnopf(text: l.moment_zurueck, art: MKnopfArt.zweit, breit: true, onPressed: () => setState(() => _offen = false)),
          ],
        ),
      ),
    );
  }
}

/// Countdown des letzten Aufrufs (zählt je Sekunde); danach ein Satz, dass abgewartet wird.
class GastAufrufUhr extends StatefulWidget {
  const GastAufrufUhr({super.key, required this.kontext, this.mitWeiter = false});

  final GastKontext kontext;

  /// Für den, der leitet: nach dem Countdown „Weiter“.
  final bool mitWeiter;

  @override
  State<GastAufrufUhr> createState() => _GastAufrufUhrState();
}

class _GastAufrufUhrState extends State<GastAufrufUhr> {
  Timer? _uhr;

  @override
  void initState() {
    super.initState();
    _uhr = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uhr?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.kontext;
    final l = momentTexte(context);
    final rest = gastAufrufRest(c);
    if (rest == null) return const SizedBox.shrink();
    final s = MSchrift.von(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MMass.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rest > 0)
            Text(l.moment_aufruf_laeuft((rest / 1000).ceil()), key: const ValueKey('gast-aufruf-laeuft'), style: s.ueberschrift)
          else
            Text(l.moment_aufruf_vorbei, key: const ValueKey('gast-aufruf-vorbei'), style: s.text),
          if (widget.mitWeiter && rest <= 0) ...[
            const SizedBox(height: MMass.s8),
            MKnopf(
              key: const ValueKey('gast-aufruf-weiter'),
              text: c.l.online_weiter,
              icon: Icons.arrow_forward_rounded,
              onPressed: c.verbunden ? () => c.befehl({'typ': 'weiter'}) : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// Wer leitet, sieht in den Gesprächen, wer noch zieht, und gibt den letzten Aufruf.
Widget? gastMomentAufruf(GastKontext c) {
  if (c.phase != 'gespraeche' || !c.leitet || gastEinflussLage(c) == null) return null;
  final l = momentTexte(c.context);
  final offen = gastMomentOffen(c);
  final rest = gastAufrufRest(c);
  final s = MSchrift.von(c.context);
  return Padding(
    key: const ValueKey('gast-moment-aufruf'),
    padding: const EdgeInsets.only(bottom: MMass.s16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l.moment_titel, style: s.ueberschrift),
        if (offen.isEmpty)
          Text(l.moment_alle, style: s.leise)
        else ...[
          for (final r in offen) Text('${c.personAmTisch(r)}: ${l.moment_offen}', style: s.leise),
          const SizedBox(height: MMass.s8),
          if (rest == null) ...[
            Text(l.moment_aufruf_hinweis, style: s.text),
            const SizedBox(height: MMass.s8),
            MKnopf(
              key: const ValueKey('gast-letzter-aufruf'),
              text: l.moment_aufruf_knopf,
              icon: Icons.campaign_rounded,
              onPressed: c.verbunden ? () => c.befehl({'typ': 'letzterAufruf'}) : null,
            ),
          ] else
            GastAufrufUhr(kontext: c, mitWeiter: true),
        ],
      ],
    ),
  );
}

/// Sitze ohne Figur in den Gesprächen: Alle ziehen gerade ihren Moment.
Widget? gastMomentHinweis(GastKontext c) {
  if (c.phase != 'gespraeche' || c.privat['moment'] is Map || c.leitet || gastMomentOffen(c).isEmpty) return null;
  return Padding(
    padding: const EdgeInsets.only(bottom: MMass.s16),
    child: Text(momentTexte(c.context).moment_warten, key: const ValueKey('gast-moment-warten'), style: MSchrift.von(c.context).leise),
  );
}

// ---------------------------------------------------------------------------
// Erzähler, Detektiv, Auflösung

/// Zug-Tafel auf dem Erzähler-Sitz (privat `einflussTafel`), sonst `null`.
Widget? gastEinflussTafel(GastKontext c) {
  final t = TafelSicht.ausJson(c.privat['einflussTafel']);
  final d = gastDarstellung(c);
  if (t == null || d == null || c.sitz != Sitz.erzaehler) return null;
  return Padding(padding: const EdgeInsets.only(bottom: MMass.s16), child: ZugTafelAnsicht(tafel: t, darstellung: d));
}

/// Ausgepackte Fakten für das Notizbuch (§3.6), aus `einfluss.folgen[].gestanden`; `null`, solange keiner
/// ausgepackt wurde oder die Akte lädt.
Widget? gastAusgepackt(GastKontext c) {
  final lage = gastEinflussLage(c);
  final d = gastDarstellung(c);
  final erm = c.daten?.karte.ermittlung;
  if (lage == null || d == null || erm == null || AusgepacktListe.eintraege(lage.folgen, erm).isEmpty) return null;
  return AusgepacktListe(folgen: lage.folgen, ermittlung: erm, darstellung: d);
}

/// Die Wirkungen der Schicht für den Gast-Detektiv in der Ermittlung: Leisten und die Gerüchte der Runde.
Widget? gastEinflussWirkungen(GastKontext c) {
  final lage = gastEinflussLage(c);
  final d = gastDarstellung(c);
  if (lage == null || d == null) return null;
  final geruechte = lage.folgenVon(c.runde)?.geruechte ?? const <String>[];
  return Padding(
    key: const ValueKey('gast-einfluss-wirkungen'),
    padding: const EdgeInsets.only(bottom: MMass.s16),
    child: MBlatt(
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      samen: 71 + c.runde,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LeistenAnzeige(zusammenhalt: lage.zusammenhalt, spuk: lage.spuk, hoechstens: c.daten?.einfluss?.zahlen.leisteHoechstens ?? 6),
          for (final g in geruechte) MomentPunkt(d.text(g)),
        ],
      ),
    ),
  );
}

/// Abzeichen des Tischwerts an einer Option der laufenden Runde, sonst `null`.
Widget? gastAbzeichen(GastKontext c, String optionId) {
  final t = gastEinflussLage(c)?.tisch[optionId] ?? 0;
  final d = gastDarstellung(c);
  if (t == 0 || d == null) return null;
  return Padding(padding: const EdgeInsets.only(left: 4, bottom: 6), child: Align(alignment: Alignment.centerLeft, child: TischAbzeichen(tisch: t, darstellung: d)));
}

/// Zusätze der Fundkarte (Randnotizen, Ertappt, Befragung) aus `zug.einfluss`, sonst `null`.
Widget? gastFundZusatz(GastKontext c, Map<String, Object?> zug) {
  final d = gastDarstellung(c);
  final daten = c.daten;
  if (zug['einfluss'] is! Map || d == null || daten == null) return null;
  try {
    return EinflussFundZusatz(fund: EinflussFund.ausJson(jMap(zug['einfluss'])), ermittlung: daten.karte.ermittlung, darstellung: d);
  } on FormatException {
    return null;
  }
}

/// Text zum Tischruf: verwischte Spur und die Wirkung der beiden Rufe, sonst leer.
List<Widget> gastTischrufWirkung(GastKontext c, Map<String, Object?> zug) {
  final d = gastDarstellung(c);
  if (d == null || gastEinflussLage(c) == null) return const [];
  final s = MSchrift.von(c.context);
  return [
    if (zug['verwischt'] == true) Padding(padding: const EdgeInsets.only(bottom: MMass.s8), child: Text(d.text('einfluss.verwischt'), key: const ValueKey('gast-verwischt'), style: MPapierSchrift.text)),
    MomentPunkt(d.text('einfluss.tischruf.nochmal'), stil: s.leise),
    MomentPunkt(d.text('einfluss.tischruf.umweg'), stil: s.leise),
  ];
}

/// Nachfragen des Gast-Detektivs nach Runde drei, vor der Anklage.
Widget? gastNachfragen(GastKontext c, {required bool offen}) {
  final lage = gastEinflussLage(c);
  final d = gastDarstellung(c);
  final daten = c.daten;
  if (lage == null || d == null || daten == null) return null;
  return Padding(
    padding: const EdgeInsets.only(bottom: MMass.s16),
    child: NachfrageTafel(
      offen: lage.nachfragenOffen,
      optionen: lage.nachfrageOptionen,
      nachgefragt: lage.nachgefragt,
      ermittlung: daten.karte.ermittlung,
      darstellung: d,
      onNachfrage: offen && c.ermittelt ? (o) => c.befehl({'typ': 'nachfrage', 'option': o}) : null,
    ),
  );
}

/// Ab dem Finale: Protokoll der Nacht, Sterne, Tipps und Endwert (`aufloesung.einfluss`).
Widget? gastEinflussAufloesung(GastKontext c) {
  final a = jMap(c.v['aufloesung']);
  final sicht = AufloesungSicht.ausJson(a['einfluss']);
  final d = gastDarstellung(c);
  if (sicht == null || d == null) return null;
  return Padding(
    padding: const EdgeInsets.only(bottom: MMass.s16),
    child: EinflussAufloesungAnsicht(aufloesung: sicht, darstellung: d, punkte: jZahl(a['punkte'])),
  );
}

/// Die zwei Sterne im Dossier eines Gastes mit Figur (aus privat `moment`), sonst `null`.
Widget? gastZiele(GastKontext c) {
  final d = gastDarstellung(c);
  if (c.privat['moment'] is! Map || d == null) return null;
  final m = MomentSicht.ausJson(c.privat['moment']);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [ZielKarten(sterne: m.sterne, darstellung: d), const SizedBox(height: MMass.s8), const MomentErklaerung()],
  );
}
