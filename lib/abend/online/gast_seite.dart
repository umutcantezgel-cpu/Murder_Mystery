import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart' show Enden;
import 'package:mordakte_core/runden.dart' show AbendErgebnis;
import 'package:mordakte_netz/mordakte_netz.dart' show VerbindungsStatus;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../l10n/lookup.dart';
import '../../stil/mappe/online_bausteine.dart' show mOnlineStempelGruen;
import '../../stil/stil.dart';
import '../abend_halter.dart';
import 'ansicht.dart';
import 'gast_ansicht.dart';
import 'gast_dienst.dart';
import 'online_fehler.dart';
import 'online_halter.dart';
import 'online_teile.dart';

/// Der Abend auf dem Gerät eines Gastes (Route `/gast`). Alles, was hier steht,
/// kommt aus der Ansicht des Gastgebers für dieses Gerät: die Lobby mit der
/// Bereit-Taste, die eigene Rolle zum Lesen, Gespräche, Gruppenwahl, der
/// öffentliche Verlauf der Ermittlung mit dem Würfel, Anklage und Auflösung.
/// Am Ende rechnet das Gerät seine Kartenbelohnung selbst und zeigt die
/// vorhandene Belohnungsseite.
class GastSeite extends StatefulWidget {
  const GastSeite({super.key});

  @override
  State<GastSeite> createState() => _GastSeiteState();
}

class _GastSeiteState extends State<GastSeite> {
  late final OnlineHalter _halter = context.read<OnlineHalter>();
  late final AbendHalter _abendHalter = context.read<AbendHalter>();
  late final GastDienst? _dienst = _halter.gast;

  /// Der Platz wird aufgegeben (Abend verlassen oder zu Ende), nicht nur getrennt.
  bool _aufgeben = false;

  @override
  void initState() {
    super.initState();
    if (_dienst == null) {
      // Ohne Verbindung (z. B. nach dem Neuladen) zurück in die Detektei.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.start);
      });
    }
  }

  @override
  void dispose() {
    final d = _dienst;
    if (d != null) {
      _halter.vergissGast(d);
      // Wer die Seite nur verlässt, behält seinen Platz und kann zurückkehren.
      unawaited(_aufgeben || d.geschlossen ? d.verlassen() : d.trennen());
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _befehl(Map<String, Object?> nachricht) async {
    final d = _dienst;
    if (d == null) return;
    final fehler = await d.befehl(nachricht);
    if (fehler != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(befehlsFehlerText(L.of(context), fehler))));
    }
  }

  /// Das Ende ist gelesen: Ergebnis für die Belohnung merken und dorthin wechseln.
  /// Die Karten rechnet [belohnungFuer] später aus Salz, Pfad, Ende und
  /// Abstecher-Funden und der eigenen Rolle; die Belohnungsseite bucht sie genau einmal.
  void _belohnung() {
    final d = _dienst;
    final daten = d?.daten;
    if (d == null || daten == null) return;
    final v = d.ansicht;
    final a = jMap(v['aufloesung']);
    final endeId = jText(a['ende']);
    final regel = Enden(daten.kanon).regeln.where((r) => r.id == endeId).firstOrNull;
    if (regel == null) return;
    final rolle = jText(jMap(v['privat'])['rolle']);
    final zusage = jText(v['wuerfelZusage']);
    final ergebnis = AbendErgebnis(
      akte: jText(v['akte'], daten.fall),
      salz: jText(a['salz']),
      spielerId: d.spielerId,
      rolle: rolle.isEmpty ? null : rolle,
      pfad: jText(a['pfad']),
      anklageRichtig: regel.richtig,
      ende: regel.id,
      abstecherFunde: jTexte(a['abstecherFunde']).toSet(),
    );
    _aufgeben = true;
    _abendHalter.beende(AbendAbschluss(
      abendId: 'online-${d.raumCode}-${zusage.length > 16 ? zusage.substring(0, 16) : zusage}',
      ergebnis: ergebnis,
      punkte: jZahl(a['punkte']),
      endeName: regel.name,
    ));
    context.go(Routes.abendBelohnung);
  }

  Future<void> _verlassen() async {
    final d = _dienst;
    if (d == null) return;
    final l = L.of(context);
    final ja = await onlineRueckfrage(
      context,
      titel: l.online_verlassen_titel,
      text: l.online_verlassen_text,
      ja: l.online_verlassen_ja,
      nein: l.online_verlassen_nein,
      gefaehrlich: true,
    );
    if (!ja || !mounted) return;
    _aufgeben = true;
    await d.verlassen();
    if (mounted) context.go(Routes.start);
  }

  void _zurDetektei() {
    _aufgeben = true;
    context.go(Routes.start);
  }

  @override
  Widget build(BuildContext context) {
    final d = _dienst;
    if (d == null) return Scaffold(backgroundColor: MFarben.von(context).grund);
    return ListenableBuilder(
      listenable: d,
      builder: (context, _) => AkteThema(
        akte: jText(d.ansicht['akte']),
        child: Builder(
          builder: (context) {
            final l = L.of(context);
            final kontext = GastKontext(
              context: context,
              dienst: d,
              befehl: _befehl,
              belohnung: d.daten == null || d.ansicht['aufloesung'] is! Map ? null : _belohnung,
            );
            final inhalt = baueGastSeite(kontext);
            return Scaffold(
              backgroundColor: MFarben.von(context).grund,
              body: MRahmen(
                marke: inhalt.marke,
                titel: inhalt.titel,
                untertitel: inhalt.untertitel,
                kopf: d.status == VerbindungsStatus.verbunden ? null : _StatusBand(dienst: d, onDetektei: _zurDetektei),
                aktionen: inhalt.aktionen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...inhalt.kinder,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: MKnopf(text: l.online_verlassen, art: MKnopfArt.leise, icon: Icons.logout_rounded, onPressed: _verlassen),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Hinweis zum Zustand der Verbindung als Telegramm: Aufbau, eigene Verbindung
/// weg, Spielleitung getrennt, Abend beendet.
class _StatusBand extends StatelessWidget {
  const _StatusBand({required this.dienst, required this.onDetektei});

  final GastDienst dienst;
  final VoidCallback onDetektei;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final (icon, text, farbe) = switch (dienst.status) {
      VerbindungsStatus.verbinde => (Icons.sync_rounded, l.online_status_verbinde, MRoh.tinteBlau),
      VerbindungsStatus.verbunden => (Icons.wifi_rounded, '', mOnlineStempelGruen),
      VerbindungsStatus.getrennt => (Icons.wifi_off_rounded, l.online_status_getrennt, onlineWarnTinte),
      VerbindungsStatus.pausiert => (Icons.pause_circle_outline_rounded, l.online_status_pausiert, onlineWarnTinte),
      VerbindungsStatus.geschlossen => (Icons.info_outline_rounded, l.online_status_geschlossen, MRoh.stempelRot),
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: MMass.s4),
        child: OnlineHinweisKarte(
          key: const ValueKey('online-status'),
          art: PapierArt.telegramm,
          icon: icon,
          text: text,
          farbe: farbe,
          aktion: dienst.status == VerbindungsStatus.geschlossen
              ? MKnopf(text: l.online_zur_detektei, art: MKnopfArt.zweit, onPressed: onDetektei)
              : null,
        ),
      ),
    );
  }
}
