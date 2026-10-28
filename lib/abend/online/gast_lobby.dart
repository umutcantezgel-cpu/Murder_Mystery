import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart' show Sitz;

import '../../l10n/lookup.dart';
import '../../stil/mappe/online_bausteine.dart';
import '../../stil/stil.dart';
import '../rollen_uebersicht.dart';
import 'gast_ansicht.dart' show GastKontext, GastSeiteninhalt;
import 'lobby_besetzung.dart';
import 'online_teile.dart';

/// Die Lobby auf dem Gerät eines Gastes (Langer Abend M3): oben „Dein Platz“
/// (Detektiv, Erzähler oder die zugeteilte Figur, sonst Zufall), ohne Sitz
/// darunter der eigene Wunsch. Wer auf dem Detektiv- oder dem Erzähler-Sitz
/// sitzt, legt wie der Gastgeber Rollenzahl und Figuren fest; der Detektiv wählt
/// hier seine Klasse (sie reist mit dem Sitz). Darunter alle Plätze mit Figur
/// und „Bereit“. Solange die Akte lädt, nur die Plätze.
GastSeiteninhalt gastLobby(GastKontext c, String marke) {
  final l = c.l;
  final ich = c.ich;
  final bereit = ich?.bereit ?? false;
  final daten = c.daten;
  final stand = daten == null ? null : LobbyStand.aus(c.v, daten, c.ichId);
  return GastSeiteninhalt(
    marke: marke,
    titel: l.online_gast_lobby_titel,
    untertitel: l.online_gast_lobby_hinweis,
    kinder: [
      if (stand != null) ...[
        _DeinPlatz(stand: stand),
        if (ich != null && ich.sitz == null) _Wunsch(stand: stand, kontext: c),
        if (stand.ichTeileZu) ...[
          const SizedBox(height: MMass.s8),
          OnlineRegisterKopf(l.online_gast_verteilen_titel.toUpperCase()),
          LobbyRollenTafel(stand: stand, onAendern: c.verbunden ? (n) => c.befehl({'typ': 'besetzung', 'rollen': n}) : null),
          const SizedBox(height: MMass.s16),
        ],
        if (ich?.sitz == Sitz.detektiv) ...[
          LobbyKlasse(
            ichId: c.ichId,
            klasseImRaum: c.privat['klasse'] is String ? c.privat['klasse'] as String : null,
            befehl: c.befehl,
            karte: daten!.hat('klassen'),
            katalog: c.dienst.katalog,
          ),
          const SizedBox(height: MMass.s16),
        ],
        Padding(padding: const EdgeInsets.only(top: MMass.s8, bottom: MMass.s8), child: LobbyTisch(stand: stand, befehl: c.befehl)),
        Align(alignment: Alignment.centerLeft, child: RollenUebersichtKnopf(hervorheben: ich?.sitz ?? Sitz.rolle, mitErzaehler: c.mitErzaehlerSitz, detektivWort: c.detektivWort, einfluss: c.v['einfluss'] is Map)),
        const SizedBox(height: MMass.s8),
      ] else
        for (var i = 0; i < c.spieler.length; i++) OnlinePlatzKarte(name: c.spieler[i].name, nr: i),
    ],
    aktionen: [
      MKnopf(
        text: bereit ? l.online_bereit_zurueck : l.online_bereit_knopf,
        art: bereit ? MKnopfArt.zweit : MKnopfArt.haupt,
        icon: bereit ? Icons.undo_rounded : Icons.check_rounded,
        onPressed: c.verbunden ? () => c.befehl({'typ': 'bereit', 'wert': !bereit}) : null,
      ),
    ],
  );
}

/// „Dein Platz“ als Karteikarte: Fotoabzug und was dieses Gerät heute tut.
class _DeinPlatz extends StatelessWidget {
  const _DeinPlatz({required this.stand});

  final LobbyStand stand;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final ich = stand.ich;
    if (ich == null) return const SizedBox.shrink();
    final figur = ich.figur;
    final (titel, name, text) = switch (ich.sitz) {
      Sitz.detektiv => (l.online_gast_platz_titel, detektivBezeichnung(l, stand.daten), l.online_gast_detektiv_text),
      Sitz.erzaehler => (l.online_gast_platz_titel, l.abend_platz_erzaehler, l.online_gast_erzaehler_text),
      _ when figur != null => (l.online_gast_figur_titel, figurName(stand.daten, figur), _titel(figur)),
      _ => (l.online_gast_figur_titel, l.online_lobby_zufall, l.online_gast_zufall_text),
    };
    final look = lobbyAussehen(stand, ich);
    return Padding(
      padding: const EdgeInsets.only(top: MMass.s8, bottom: MMass.s16),
      child: MBlatt(
        key: const ValueKey('dein-platz'),
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        klammer: true,
        neigung: -0.004,
        samen: 47,
        padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
        child: MOnlineBildZeile(
          bild: look != null
              ? MFotoabzug(look: look, groesse: 64, neigung: -0.04, klammer: true)
              : (ich.sitz == Sitz.erzaehler
                  ? const Icon(Icons.menu_book_rounded, size: 48, color: MRoh.tinteBlau)
                  : const MOnlineSilhouette(groesse: 64, samen: 3)),
          text: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titel.toUpperCase(), style: MPapierSchrift.marke),
              const SizedBox(height: 2),
              MGanzeWorte(name, stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 22)),
              if (text.isNotEmpty) Text(text, style: MPapierSchrift.leise),
            ],
          ),
        ),
      ),
    );
  }

  String _titel(String figur) {
    final n = stand.daten.kanon.figur(figur);
    final t = n?['roleTitle'] ?? n?['title'];
    return t is String ? t : '';
  }
}

/// Der eigene Wunsch (nur ohne Sitz): ein Hinweis für die Zuteilung, nie bindend.
class _Wunsch extends StatelessWidget {
  const _Wunsch({required this.stand, required this.kontext});

  final LobbyStand stand;
  final GastKontext kontext;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final c = kontext;
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: MBlatt(
        key: const ValueKey('wunsch'),
        art: PapierArt.notiz,
        neigung: 0.003,
        samen: 49,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.online_gast_wunsch_titel.toUpperCase(), style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
            const SizedBox(height: MMass.s4),
            Text(l.online_gast_wunsch_hinweis, style: MPapierSchrift.leise),
            const SizedBox(height: MMass.s12),
            FigurWahl(
              stand: stand,
              gewaehlt: stand.ich?.wunsch,
              fuer: c.ichId,
              zufallText: l.online_gast_kein_wunsch,
              onWahl: (f) {
                if (c.verbunden) c.befehl({'typ': 'wunsch', 'rolle': f});
              },
            ),
          ],
        ),
      ),
    );
  }
}
