import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../app/router.dart';
import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/mappe/abend2_bausteine.dart';
import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';
import '../teilen.dart';

final _de = LDe();

/// Auflösung (Master 7.6, Schritt 8, Phase aufloesung) und das Ende (Phase ende).
/// In der Auflösung steht je Baustein der Erzählertext, bei den Rollen mit Name
/// am Tisch und Fotoabzug auf einer Karteikarte. Im Ende liegt die geschlossene
/// Akte: Punkte mit Urteilsstempel, wer es war (mit Foto), der Fall-Code und
/// Teilen (ohne Täter) und ein handschriftlicher Dank; darunter der Weg ins
/// Hauptmenü.
class AufloesungBildschirm extends StatelessWidget {
  const AufloesungBildschirm({super.key, required this.sitzung, this.onEnde});

  final PartySitzung sitzung;

  /// Weg vom Ende: im Abend die Belohnung, sonst (alter Einstieg) die Detektei.
  final VoidCallback? onEnde;

  PartySitzung get s => sitzung;

  @override
  Widget build(BuildContext context) => s.phase == PartyPhase.ende ? _ende(context) : _aufloesung();

  Widget _aufloesung() => PartyRahmen(
        marke: s.ui('ui.aufloesung.marke'),
        titel: s.ui('ui.aufloesung.titel'),
        aktionen: [MKnopf(text: s.ui('ui.allgemein.weiter'), onPressed: s.kannWeiter ? s.weiter : null)],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final k in s.erzaehler) ...[
              if (_rolle(k) case final r?) _Rolle(sitzung: s, rolle: r),
              ErzaehlerFeld(sitzung: s, kennungen: [k]),
            ],
            if (s.nachspiel case final n when n.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Nachspiel(sitzung: s, saetze: n),
            ],
          ],
        ),
      );

  Widget _ende(BuildContext context) {
    final ende = s.ende;
    final taeter = s.pfad;
    final mappe = MAktenmappe(
      reiter: s.kanon.fall['titel'] as String,
      farbe: ende.richtig ? const Color(0xFF2F6B37) : MRoh.stempelRot,
      siegel: AkteStil.fuer(s.daten.fall).sigel,
      blaetter: 3,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Punkte und Urteilsstempel nebeneinander; wird es zu eng, rutscht der Stempel darunter.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              _Wert(titel: s.ui('ui.aufloesung.punkte_titel'), wert: s.ui('ui.aufloesung.punkte', {'punkte': '${s.spiel.punkte}'})),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                child: RepaintBoundary(
                  child: MStempel(
                    text: ende.richtig ? _de.verdict_stamp_solid : _de.verdict_stamp_wrong,
                    farbe: ende.richtig ? const Color(0xFF2F6B37) : MRoh.stempelRot,
                    groesse: 20,
                    winkel: -0.14,
                    aufschlagen: true,
                  ),
                ),
              ),
            ],
          ),
          _Feldname(s.ui('ui.aufloesung.taeter_titel')),
          const SizedBox(height: 8),
          MBildZeile(
            bild: ExcludeSemantics(
              child: MFotoabzug(
                look: s.figurAussehen(taeter),
                groesse: 76,
                neigung: -0.04,
                klammer: true,
                akzent: s.figurFarbe(taeter),
              ),
            ),
            text: MGanzwortText(s.figurName(taeter), style: MPapierSchrift.ueberschrift),
          ),
          const SizedBox(height: 20),
          // Eine Akte mit fester Lösung kennt keinen Fall-Code; der Code ließe sich nirgends eingeben.
          if (!s.daten.kanon.festeLoesung) ...[
            _Feldname(s.ui('ui.aufloesung.code_titel')),
            const SizedBox(height: 4),
            Text(s.fallCode.code, style: MPapierSchrift.maschine.copyWith(fontSize: 22, letterSpacing: 2.4)),
            const SizedBox(height: 4),
            Text(s.ui('ui.aufloesung.code_hinweis'), style: MPapierSchrift.leise),
            const SizedBox(height: 12),
          ],
          // Teilen: eine Karte ohne Täter, mit Fall-Code zum Nachspielen.
          Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (knopf) => MKnopf(
                text: _de.teilen_knopf,
                art: MKnopfArt.zweit,
                icon: Icons.ios_share_rounded,
                onPressed: () {
                  final box = knopf.findRenderObject() as RenderBox?;
                  abendTeilen(context, s, ursprung: box == null ? null : box.localToGlobal(Offset.zero) & box.size);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _Trennlinie(),
          const SizedBox(height: 12),
          Text(s.ui('ui.aufloesung.dank'), style: MPapierSchrift.hand.copyWith(fontSize: 22)),
        ],
      ),
    );
    return PartyRahmen(
      marke: s.ui('ui.aufloesung.ende_marke'),
      // Der Abend ist zu Ende: in der Detektei beginnt ein neuer Abend; im Abend
      // der Weg über die Belohnung (Karten, Erfahrung, Rang).
      aktionen: [
        if (onEnde == null)
          MKnopf(text: s.ui('ui.aufloesung.hauptmenue'), art: MKnopfArt.zweit, icon: Icons.home_rounded, onPressed: () => context.go(Routes.start))
        else
          MKnopf(text: _de.abend_belohnung_ansehen, icon: Icons.style_rounded, onPressed: onEnde),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Der Name des Endes als Seitentitel (wie im Rahmen), aber ohne Bruch im Wort.
          MGanzwortText(ende.name, style: context.schrift.titel),
          const SizedBox(height: MMass.s20),
          Padding(padding: const EdgeInsets.only(top: 6, bottom: 14), child: mappe),
        ],
      ),
    );
  }
}

/// Rolle einer Kennung `aufloesung.<rolle>` oder `aufloesung.<rolle>.<taeter|unschuldig>`.
/// Die Gruppenzeile `aufloesung.gruppe.<n>` hat keine Rolle.
String? _rolle(String kennung) {
  final teile = kennung.split('.');
  return teile.length >= 2 && teile[0] == 'aufloesung' && teile[1] != 'gruppe' ? teile[1] : null;
}

/// Karteikarte über dem Baustein einer Rolle: Fotoabzug, Name am Tisch und,
/// wenn sie anders heißt, die Figur; der Farbcode als Registerstreifen.
class _Rolle extends StatelessWidget {
  const _Rolle({required this.sitzung, required this.rolle});

  final PartySitzung sitzung;
  final String rolle;

  @override
  Widget build(BuildContext context) {
    final spieler = sitzung.spielerName(rolle);
    final figur = sitzung.figurName(rolle);
    final nr = sitzung.besetzt.indexOf(rolle);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: MBlatt(
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        randFarbe: sitzung.figurFarbe(rolle),
        neigung: nr.isEven ? -0.004 : 0.004,
        samen: nr + 70,
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        child: Row(
          children: [
            ExcludeSemantics(
              child: MFotoabzug(look: sitzung.figurAussehen(rolle), groesse: 52, neigung: nr.isEven ? -0.05 : 0.04, akzent: sitzung.figurFarbe(rolle)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MGanzwortText(spieler, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
                  if (figur != spieler) Text(sitzung.ui('ui.aufloesung.figur', {'name': figur}), style: MPapierSchrift.leise),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nachspiel der Randgespräche (M6): ein Notizblatt, je Zeuge ein Satz in
/// Füllertinte neben seinem Fotoabzug.
class _Nachspiel extends StatelessWidget {
  const _Nachspiel({required this.sitzung, required this.saetze});

  final PartySitzung sitzung;
  final List<Epilog> saetze;

  @override
  Widget build(BuildContext context) => MBlatt(
        art: PapierArt.notiz,
        neigung: 0.004,
        reissnagel: true,
        samen: 91,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            MBlattKopf(zeile: _de.nachspiel_titel, unter: _de.nachspiel_hinweis),
            for (final e in saetze) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.figur case final f?) ...[
                    MFotoabzug(look: sitzung.figurAussehen(f), groesse: 44, neigung: -0.04, akzent: sitzung.figurFarbe(f)),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: Text(e.text, style: MPapierSchrift.hand)),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      );
}

/// Feldname der Akte in Schreibmaschine.
class _Feldname extends StatelessWidget {
  const _Feldname(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot));
}

/// Zeile der Akte: Feldname, darunter der Wert in Playfair.
class _Wert extends StatelessWidget {
  const _Wert({required this.titel, required this.wert});

  final String titel;
  final String wert;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Feldname(titel),
            const SizedBox(height: 4),
            MGanzwortText(wert, style: MPapierSchrift.titel),
          ],
        ),
      );
}

/// Dünne Tintenlinie zwischen den Feldern und dem Dank.
class _Trennlinie extends StatelessWidget {
  const _Trennlinie();

  @override
  Widget build(BuildContext context) => Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3));
}
