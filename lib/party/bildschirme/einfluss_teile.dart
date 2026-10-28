import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show Ermittlung, PartyPhase;
import 'package:mordakte_core/runden.dart' show BefragungsLage, EinflussFund, faktWortlaut, momentAufrufFrist, tippKeiner;

import '../../l10n/gen/app_localizations.dart';
import '../../stil/mappe/abend2_bausteine.dart';
import '../../stil/stil.dart';
import '../einfluss_sicht.dart';
import '../erzaehler_ausgabe.dart';
import '../sitzung.dart';
import 'moment.dart';

/// Wirkungen der Einfluss-Schicht „Dein Moment“ (Finale §3), wie Tisch,
/// Gastgeber und Gäste sie sehen: Abzeichen an den Optionen, Zusätze der
/// Fundkarte, Leisten, Folgen, Nachfragen, Zug-Tafel und das Protokoll der
/// Nacht. Alles kommt aus den Ansichten (`einfluss_sicht.dart`); keine Wirkung
/// hier kennt den Pfad, und vor dem Finale zeigt keine, wer was spielte.

// ---------------------------------------------------------------------------
// Ermittlung

/// Abzeichen des Tischwerts an einer Option (§3.3): „Rückendeckung +1“ bis
/// „Starke Störung −2“; ohne Tischwert nichts.
class TischAbzeichen extends StatelessWidget {
  const TischAbzeichen({super.key, required this.tisch, required this.darstellung});

  final int tisch;
  final EinflussDarstellung darstellung;

  @override
  Widget build(BuildContext context) {
    final k = abzeichenSchluessel(tisch);
    if (k == null) return const SizedBox.shrink();
    final farbe = tisch > 0 ? MRoh.tinteBlau : MRoh.stempelRot;
    return Container(
      key: ValueKey('abzeichen-$tisch'),
      padding: const EdgeInsets.fromLTRB(8, 3, 9, 3),
      decoration: BoxDecoration(
        color: farbe.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: farbe.withValues(alpha: 0.75), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tisch > 0 ? Icons.thumb_up_alt_outlined : Icons.thumb_down_alt_outlined, size: 15, color: farbe),
          const SizedBox(width: 5),
          Flexible(child: Text(darstellung.text(k), style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: farbe))),
        ],
      ),
    );
  }
}

/// Eine Randnotiz (§3.5): wer etwas beobachtet hat und was, wortgleich aus der Akte.
class RandnotizAnsicht extends StatelessWidget {
  const RandnotizAnsicht({super.key, required this.id, required this.ermittlung, required this.darstellung});

  final String id;
  final Ermittlung ermittlung;
  final EinflussDarstellung darstellung;

  @override
  Widget build(BuildContext context) {
    final b = ermittlung.beobachtungJson(id);
    final text = b?['text'];
    if (text is! String) return const SizedBox.shrink();
    final wer = b?['wer'];
    return Padding(
      key: ValueKey('randnotiz-$id'),
      padding: const EdgeInsets.only(bottom: MMass.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wer is String) ...[ExcludeSemantics(child: darstellung.bild(wer, 34)), const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (wer is String) Text(darstellung.name(wer), style: MPapierSchrift.leise),
                Text(text, style: MPapierSchrift.hand.copyWith(fontSize: 21)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ausgepackte Fakten im Notizbuch (§3.6): Sie zählen für die Regeln wie ein
/// Fund und bleiben nach dem Vorlesen der Folgen stehen, je Fakt mit dem Namen
/// am Tisch. Leer, solange niemand einen Fakt ausgepackt hat.
class AusgepacktListe extends StatelessWidget {
  const AusgepacktListe({super.key, required this.folgen, required this.ermittlung, required this.darstellung});

  final List<FolgenSicht> folgen;
  final Ermittlung ermittlung;
  final EinflussDarstellung darstellung;

  /// Figur und Wortlaut je ausgepacktem Fakt, in der Reihenfolge der Runden.
  static List<({String figur, String fakt, String text})> eintraege(List<FolgenSicht> folgen, Ermittlung ermittlung) => [
        for (final f in folgen)
          for (final g in f.gestanden)
            if (g.fakt case final id?)
              if (_wortlaut(ermittlung, id) case final text?) (figur: g.figur, fakt: id, text: text),
      ];

  static String? _wortlaut(Ermittlung erm, String id) {
    try {
      return faktWortlaut(erm, id);
    } on ArgumentError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liste = eintraege(folgen, ermittlung);
    if (liste.isEmpty) return const SizedBox.shrink();
    final l = momentTexte(context);
    return Column(
      key: const ValueKey('ausgepackt-liste'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in liste)
          Padding(
            key: ValueKey('ausgepackt-${e.figur}-${e.fakt}'),
            padding: const EdgeInsets.only(bottom: MMass.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.einfluss_ausgepackt(darstellung.name(e.figur)), style: MPapierSchrift.leise),
                Text(e.text, style: MPapierSchrift.text),
              ],
            ),
          ),
      ],
    );
  }
}

/// Zusätze einer Fundkarte mit Schicht (§3.4): Lage der Befragung, Randnotizen
/// (Zusatzfund, Redselig), Ertappt und ob die Fakten erst im Zwischenresümee kommen.
class EinflussFundZusatz extends StatelessWidget {
  const EinflussFundZusatz({super.key, required this.fund, required this.ermittlung, required this.darstellung});

  final EinflussFund fund;
  final Ermittlung ermittlung;
  final EinflussDarstellung darstellung;

  @override
  Widget build(BuildContext context) {
    final l = momentTexte(context);
    final d = darstellung;
    final ertappt = fund.ertappt;
    final lage = fund.befragung;
    return Column(
      key: const ValueKey('fund-einfluss'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lage != null) MomentPunkt(d.text(befragungsSchluessel(lage))),
        if (fund.verzoegert && lage != BefragungsLage.mauert) MomentPunkt(l.einfluss_verzoegert),
        if (fund.randnotizen.isNotEmpty) ...[
          const SizedBox(height: MMass.s8),
          MomentKopf(l.einfluss_randnotiz),
          for (final n in fund.randnotizen) RandnotizAnsicht(id: n, ermittlung: ermittlung, darstellung: d),
        ],
        if (ertappt != null) ...[
          const SizedBox(height: MMass.s8),
          Text(
            key: const ValueKey('fund-ertappt'),
            fund.ertapptZiel == null || fund.ertapptZiel == ertappt
                ? d.texte.einflussText('einfluss.ertappt.selbst', figur: ertappt)
                : d.texte.einflussText('einfluss.ertappt', figur: ertappt, ziel: fund.ertapptZiel),
            style: MPapierSchrift.kursiv.copyWith(color: MRoh.stempelRot),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Leisten und Folgen

/// Die beiden Leisten Zusammenhalt und Spuk (0 bis [hoechstens], §3.8).
class LeistenAnzeige extends StatelessWidget {
  const LeistenAnzeige({super.key, required this.zusammenhalt, required this.spuk, this.hoechstens = 6});

  final int zusammenhalt, spuk, hoechstens;

  @override
  Widget build(BuildContext context) {
    final l = momentTexte(context);
    Widget leiste(String name, int wert, Color farbe, IconData symbol, String schluessel) => Padding(
          key: ValueKey('leiste-$schluessel'),
          padding: const EdgeInsets.only(bottom: MMass.s8),
          child: Semantics(
            label: '$name ${l.einfluss_leiste_stand(wert, hoechstens)}',
            excludeSemantics: true,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                // Schmal und mit großer Schrift wird der Name kleiner, statt über den Rand zu laufen.
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(symbol, size: 20, color: farbe),
                  const SizedBox(width: 6),
                  Flexible(child: MGanzeWorte(name, stil: MPapierSchrift.text, minimum: 13)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  for (var i = 0; i < hoechstens; i++)
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        color: i < wert ? farbe.withValues(alpha: 0.85) : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: farbe.withValues(alpha: 0.7), width: 1.2),
                      ),
                    ),
                ]),
                Text(l.einfluss_leiste_stand(wert, hoechstens), style: MPapierSchrift.leise),
              ],
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MomentKopf(l.einfluss_leisten_titel),
        leiste(l.einfluss_zusammenhalt, zusammenhalt, MRoh.tinteBlau, Icons.local_cafe_outlined, 'zusammenhalt'),
        leiste(l.einfluss_spuk, spuk, MRoh.stempelRot, Icons.nights_stay_outlined, 'spuk'),
      ],
    );
  }
}

/// Reaktionsblasen der Rollen der App zu den Folgen (Solo, §3.11): Fotoabzug und Satz.
class BotBlasen extends StatelessWidget {
  const BotBlasen({super.key, required this.blasen, required this.darstellung});

  /// Text-Schlüssel `einfluss.bot.<figur>.<anlass>`.
  final List<String> blasen;
  final EinflussDarstellung darstellung;

  @override
  Widget build(BuildContext context) {
    if (blasen.isEmpty) return const SizedBox.shrink();
    final l = momentTexte(context);
    return Column(
      key: const ValueKey('bot-blasen'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MomentKopf(l.einfluss_blasen_titel),
        for (final k in blasen)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s8),
            child: Row(
              children: [
                ExcludeSemantics(child: darstellung.bild(k.split('.')[2], 38)),
                const SizedBox(width: 10),
                Expanded(child: Text(darstellung.text(k), style: MPapierSchrift.hand.copyWith(fontSize: 22))),
              ],
            ),
          ),
      ],
    );
  }
}

/// Zu Beginn der Ermittlung: die Folgen des Moments (§3.1). Der Vorleser liest
/// die Bausteine ([ErzaehlerFeld]); im Solo raunen bis zu drei Rollen der App;
/// darunter die Leisten. „Zur Ermittlung“ legt das Blatt weg.
class FolgenTafel extends StatelessWidget {
  const FolgenTafel({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final l = momentTexte(context);
    final lage = s.einflussLage;
    final folgen = lage?.folgenVon(s.runde);
    final d = EinflussDarstellung.sitzung(s);
    return MBlatt(
      key: const ValueKey('folgen-tafel'),
      klammer: true,
      samen: 101 + s.runde,
      neigung: -0.003,
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MGanzwortText(l.einfluss_folgen_titel, style: MPapierSchrift.ueberschrift),
          const SizedBox(height: MMass.s12),
          ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
          // Am offenen Erzählerpult: wer in dieser Runde was spielte (nur für den Erzähler).
          if (s.einflussTafel case final t?) ...[const SizedBox(height: MMass.s12), ZugTafelAnsicht(tafel: t, darstellung: d)],
          if (folgen != null && folgen.blasen.isNotEmpty) ...[const SizedBox(height: MMass.s12), BotBlasen(blasen: folgen.blasen, darstellung: d)],
          if (lage != null) ...[const SizedBox(height: MMass.s12), LeistenAnzeige(zusammenhalt: lage.zusammenhalt, spuk: lage.spuk, hoechstens: _hoechstens(s))],
          const SizedBox(height: MMass.s12),
          Align(
            alignment: Alignment.centerRight,
            child: MKnopf(key: const ValueKey('folgen-gelesen'), text: l.einfluss_folgen_weiter, onPressed: s.folgenGelesen),
          ),
        ],
      ),
    );
  }
}

int _hoechstens(PartySitzung s) => s.einflussAbend?.regeln.zahlen.leisteHoechstens ?? 6;

/// Das Zwischenresümee mit Schicht (§3.8): Leisten, die Ereignisse der Runde
/// (Titel und Karte) und Funde, die bis jetzt warteten (Umweg, „mauert“).
class EinflussResuemee extends StatelessWidget {
  const EinflussResuemee({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final lage = s.einflussLage;
    if (lage == null) return const SizedBox.shrink();
    final l = momentTexte(context);
    final d = EinflussDarstellung.sitzung(s);
    final ereignisse = lage.folgenVon(s.runde)?.ereignisse ?? const <String>[];
    final nach = {
      for (final e in s.nachgereicht.entries)
        if (s.spiel.ermittlung.entscheidung(e.key).runde == s.runde) e.key: e.value,
    };
    return MBlatt(
      key: const ValueKey('einfluss-resuemee'),
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      samen: 61 + s.runde,
      neigung: 0.003,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LeistenAnzeige(zusammenhalt: lage.zusammenhalt, spuk: lage.spuk, hoechstens: _hoechstens(s)),
          if (ereignisse.isNotEmpty) ...[
            const SizedBox(height: MMass.s8),
            MomentKopf(l.einfluss_ereignisse_titel),
            for (final e in ereignisse)
              Padding(
                key: ValueKey('ereignis-$e'),
                padding: const EdgeInsets.only(bottom: MMass.s8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(d.text('einfluss.ereignis.$e.titel'), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
                    MomentPunkt(d.text('einfluss.ereignis.$e.karte')),
                  ],
                ),
              ),
          ],
          if (nach.isNotEmpty) ...[
            const SizedBox(height: MMass.s8),
            MomentKopf(l.einfluss_nachgereicht_titel),
            for (final e in nach.entries) ...[
              Text(s.spiel.ermittlung.entscheidung(e.key).frage, style: MPapierSchrift.leise),
              for (final a in e.value) Padding(padding: const EdgeInsets.only(top: 4, bottom: 6), child: Text(a.text, style: MPapierSchrift.maschine)),
            ],
          ],
        ],
      ),
    );
  }
}

/// Text einer Option (für Nachfragen und Notizbuch).
String optionsText(Ermittlung erm, String optionId) {
  for (final e in erm.entscheidungen) {
    for (final o in e.optionen) {
      if (o.id == optionId) return o.text;
    }
  }
  return optionId;
}

/// Nachfragen nach Runde 3, vor der Anklage (§3.5): je offener Nachfrage eine
/// Option wählen; jede zeigt eine noch verborgene Randnotiz.
class NachfrageTafel extends StatelessWidget {
  const NachfrageTafel({
    super.key,
    required this.offen,
    required this.optionen,
    required this.nachgefragt,
    required this.ermittlung,
    required this.darstellung,
    required this.onNachfrage,
  });

  final int offen;
  final List<String> optionen;
  final List<({String option, String notiz})> nachgefragt;
  final Ermittlung ermittlung;
  final EinflussDarstellung darstellung;

  /// Nachfrage zu einer Option; `null`: gerade nicht (kein Detektiv, keine Verbindung).
  final ValueChanged<String>? onNachfrage;

  @override
  Widget build(BuildContext context) {
    if (offen <= 0 && nachgefragt.isEmpty) return const SizedBox.shrink();
    final l = momentTexte(context);
    final d = darstellung;
    return MBlatt(
      key: const ValueKey('nachfrage-tafel'),
      art: PapierArt.notiz,
      reissnagel: true,
      neigung: 0.003,
      samen: 53,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MomentKopf(d.text('einfluss.nachfrage.titel')),
          MomentPunkt(d.text('einfluss.nachfrage.p1')),
          if (offen > 0 && optionen.isNotEmpty) ...[
            Text(l.einfluss_nachfrage_offen(offen), style: MPapierSchrift.text),
            const SizedBox(height: MMass.s4),
            Text(l.einfluss_nachfrage_waehlen, style: MPapierSchrift.leise),
            const SizedBox(height: MMass.s8),
            for (final o in optionen)
              Padding(
                padding: const EdgeInsets.only(bottom: MMass.s8),
                child: MKnopf(
                  key: ValueKey('nachfrage-$o'),
                  text: optionsText(ermittlung, o),
                  art: MKnopfArt.zweit,
                  breit: true,
                  ganzeWorte: true,
                  onPressed: onNachfrage == null ? null : () => onNachfrage!(o),
                ),
              ),
          ],
          for (final n in nachgefragt) ...[
            const SizedBox(height: MMass.s4),
            Text(optionsText(ermittlung, n.option), style: MPapierSchrift.leise),
            RandnotizAnsicht(id: n.notiz, ermittlung: ermittlung, darstellung: d),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Erzähler: Zug-Tafel

/// Zug-Tafel des Erzählers (§3.12): wer in dieser Runde was spielte, Rollen der
/// App markiert. Nur auf dem Erzähler-Sitz; nie Tipps, nie Pfad.
class ZugTafelAnsicht extends StatelessWidget {
  const ZugTafelAnsicht({super.key, required this.tafel, required this.darstellung});

  final TafelSicht tafel;
  final EinflussDarstellung darstellung;

  @override
  Widget build(BuildContext context) {
    final l = momentTexte(context);
    final d = darstellung;
    return MBlatt(
      key: const ValueKey('zug-tafel-erzaehler'),
      art: PapierArt.notiz,
      neigung: -0.003,
      samen: 47 + tafel.runde,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MomentKopf(l.einfluss_tafel_titel),
          Text(l.einfluss_tafel_hinweis, style: MPapierSchrift.leise),
          const SizedBox(height: MMass.s8),
          if (tafel.zuege.isEmpty) Text(l.einfluss_tafel_leer, style: MPapierSchrift.leise),
          for (final z in tafel.zuege)
            if (z.rolle case final r?)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    ExcludeSemantics(child: d.bild(r, 30)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(d.name(r), style: MPapierSchrift.text)),
                    Icon(zugSymbol(z.art), size: 18, color: MRoh.tinteBlau),
                    const SizedBox(width: 6),
                    Flexible(child: Text(d.zugKurz(l, z, ich: r), style: MPapierSchrift.maschine.copyWith(fontSize: 14))),
                    if (z.bot) ...[const SizedBox(width: 6), Text(l.einfluss_bot, style: MPapierSchrift.leise)],
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Online: letzter Aufruf

/// Wer leitet (online), sieht, wer seinen Moment noch nicht gezogen hat, und
/// gibt den letzten Aufruf; danach läuft der Countdown aus `einfluss.aufruf`
/// und [momentAufrufFrist]. Wer dann fehlt, wartet ab.
class MomentAufruf extends StatefulWidget {
  const MomentAufruf({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<MomentAufruf> createState() => _MomentAufrufState();
}

class _MomentAufrufState extends State<MomentAufruf> {
  Timer? _uhr;

  @override
  void dispose() {
    _uhr?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sitzung;
    if (!s.einfluss || s.phase != PartyPhase.gespraeche) return const SizedBox.shrink();
    final l = momentTexte(context);
    final offen = s.momentOffen;
    final aufruf = s.momentAufruf;
    final rest = aufruf == null ? null : aufruf + momentAufrufFrist - s.abendzeit();
    // Der Countdown zählt je Sekunde; vorbei ist er still.
    if (rest != null && rest > 0) {
      _uhr ??= Timer.periodic(const Duration(seconds: 1), (_) => mounted ? setState(() {}) : null);
    } else {
      _uhr?.cancel();
      _uhr = null;
    }
    return MBlatt(
      key: const ValueKey('moment-aufruf'),
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      samen: 87 + s.runde,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MomentKopf(l.moment_titel),
          if (offen.isEmpty)
            Text(l.moment_alle, style: MPapierSchrift.leise)
          else ...[
            // Wer noch fehlt, mit dem Namen am Tisch (wie auf der Gastseite): So weiß, wer leitet, wen er anspricht.
            for (final r in offen) Text('${s.personAmTisch(r)}: ${l.moment_offen}', key: ValueKey('moment-offen-$r'), style: MPapierSchrift.leise),
            const SizedBox(height: MMass.s8),
            if (rest == null) ...[
              Text(l.moment_aufruf_hinweis, style: MPapierSchrift.text),
              if (s.leitet) ...[
                const SizedBox(height: MMass.s8),
                MKnopf(key: const ValueKey('letzter-aufruf'), text: l.moment_aufruf_knopf, icon: Icons.campaign_rounded, onPressed: s.letzterAufruf),
              ],
            ] else if (rest > 0)
              Text(l.moment_aufruf_laeuft((rest / 1000).ceil()), key: const ValueKey('aufruf-countdown'), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 18))
            else
              Text(l.moment_aufruf_vorbei, key: const ValueKey('aufruf-vorbei'), style: MPapierSchrift.text),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Auflösung

/// Nach dem Finale (§3.10): das Protokoll der Nacht (je Rolle und Runde der Zug
/// als Sinnbild, mit Ziel), die Sterne je Figur, die geheimen Tipps und
/// Punkte, Tischbonus und Endwert.
class EinflussAufloesungAnsicht extends StatelessWidget {
  const EinflussAufloesungAnsicht({super.key, required this.aufloesung, required this.darstellung, required this.punkte});

  final AufloesungSicht aufloesung;
  final EinflussDarstellung darstellung;
  final int punkte;

  @override
  Widget build(BuildContext context) {
    final l = momentTexte(context);
    final a = aufloesung;
    final d = darstellung;
    final rollen = a.rollen;
    final runden = a.protokoll.keys.toList()..sort();
    return MBlatt(
      key: const ValueKey('einfluss-aufloesung'),
      klammer: true,
      samen: 131,
      neigung: -0.002,
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MomentKopf(l.einfluss_protokoll_titel),
          for (final r in rollen) _protokollZeile(context, l, r, runden),
          const SizedBox(height: MMass.s12),
          MomentKopf(l.einfluss_sterne_titel),
          Wrap(
            spacing: MMass.s16,
            runSpacing: MMass.s8,
            children: [
              for (final r in rollen)
                Row(
                  key: ValueKey('sterne-$r'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(d.name(r), style: MPapierSchrift.text),
                    const SizedBox(width: 4),
                    for (var i = 0; i < 2; i++)
                      Icon(i < (a.sterne[r] ?? 0) ? Icons.star_rounded : Icons.star_border_rounded, size: 20, color: MRoh.stempelRot),
                  ],
                ),
            ],
          ),
          if (a.tipps.isNotEmpty) ...[
            const SizedBox(height: MMass.s12),
            MomentKopf(l.einfluss_tipps_titel),
            for (final e in a.tipps.entries)
              Padding(
                key: ValueKey('tipp-$e'),
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(d.name(e.key), style: MPapierSchrift.text)),
                    Text(e.value == tippKeiner ? l.moment_keine_ahnung : d.name(e.value), style: MPapierSchrift.maschine.copyWith(fontSize: 14)),
                    if (a.spuernasen.contains(e.key)) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.check_rounded, size: 18, color: MRoh.tinteBlau)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: MMass.s12),
          LeistenAnzeige(zusammenhalt: a.zusammenhalt, spuk: a.spuk),
          Wrap(
            spacing: MMass.s20,
            runSpacing: MMass.s8,
            children: [
              _wert(l.einfluss_punkte, '$punkte'),
              _wert(l.einfluss_tischbonus, a.tischbonus > 0 ? '+${a.tischbonus}' : (a.tischbonus < 0 ? '−${-a.tischbonus}' : '0')),
              _wert(l.einfluss_endwert, '${a.endwert}', key: const ValueKey('endwert')),
            ],
          ),
        ],
      ),
    );
  }

  /// Eine Rolle im Protokoll: Name, dann je Runde das Sinnbild des Zugs und, bei Zügen mit Ziel, dessen Abzug.
  /// Name und Sinnbilder stehen oben auf einer Linie: Jedes Sinnbild sitzt mittig auf der Höhe der ersten
  /// Namenszeile, das Zielfoto hängt darunter in derselben Zeile. So ragt nichts in die Zeile davor, auch bei
  /// großer Schrift; unter einem Foto bleibt bis zur nächsten Zeile Platz für seinen Schatten.
  Widget _protokollZeile(BuildContext context, L l, String rolle, List<int> runden) {
    final d = darstellung;
    final zuege = {for (final r in runden) r: aufloesung.protokoll[r]!.where((z) => z.rolle == rolle).firstOrNull};
    final stil = MPapierSchrift.text;
    final linie = MediaQuery.textScalerOf(context).scale(stil.fontSize ?? 17) * (stil.height ?? 1.2);
    return Padding(
      key: ValueKey('protokoll-$rolle'),
      padding: EdgeInsets.only(bottom: zuege.values.any((z) => z?.ziel != null) ? MMass.s12 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: MGanzeWorte(d.name(rolle), stil: stil, minimum: 13)),
          for (final MapEntry(key: r, value: z) in zuege.entries)
            if (z != null)
              Semantics(
                label: '${l.einfluss_runde(r)}: ${d.zugKurz(l, z, ich: rolle)}',
                excludeSemantics: true,
                child: SizedBox(
                  width: 52,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: linie < 20 ? 20 : linie,
                        child: Center(child: Icon(zugSymbol(z.art), size: 20, color: z.bot ? MRoh.tinteLeise : MRoh.tinteBlau)),
                      ),
                      if (z.ziel case final ziel?) Padding(padding: const EdgeInsets.only(top: 2), child: d.bild(ziel, 22)),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(width: 52),
        ],
      ),
    );
  }

  Widget _wert(String titel, String wert, {Key? key}) => Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titel.toUpperCase(), style: MPapierSchrift.marke),
          Text(wert, style: MPapierSchrift.titel),
        ],
      );
}
