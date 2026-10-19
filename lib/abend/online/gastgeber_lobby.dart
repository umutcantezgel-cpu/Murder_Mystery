import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/runden.dart' show Sitz;
import 'package:mordakte_netz/mordakte_netz.dart' show AbendFehler;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../karten/widgets/deck_zeile.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../netz/relay_einstellung.dart';
import '../../stil/mappe/online_bausteine.dart';
import '../../stil/stil.dart';
import '../abend_halter.dart';
import '../einrichtung/abschnitte.dart' show FesteLoesungHinweis;
import '../rollen_uebersicht.dart';
import 'ansicht.dart';
import 'gastgeber_dienst.dart';
import 'gastgeber_sitzung.dart';
import 'lobby_besetzung.dart';
import 'online_fehler.dart';
import 'online_halter.dart';
import 'online_teile.dart';
import 'qr_bild.dart';

/// Die Lobby des Gastgebers (Route `/abend/lobby`): zeigt den Raumcode groß und
/// als QR-Code, wer schon am Tisch sitzt und ob alle bereit sind, und lässt die
/// Sitze (wer ermittelt, wer vorliest), die Zahl der Rollen, die Figuren und
/// den Tischvorrat festlegen (Langer Abend M3, [LobbyTisch]). Rollenzahl und
/// Zuteilung liegen im Raum, alle sehen sie. „Abend starten“ meldet den
/// Gastgeber bereit und startet den Abend; danach führt er auf seinem Sitz
/// weiter (`/abend`). Das Relais wird erst hier verbunden, nicht schon beim
/// Wählen der Spielweise.
class GastgeberLobbySeite extends StatefulWidget {
  const GastgeberLobbySeite({super.key});

  @override
  State<GastgeberLobbySeite> createState() => _GastgeberLobbySeiteState();
}

class _GastgeberLobbySeiteState extends State<GastgeberLobbySeite> {
  late final OnlineHalter _halter = context.read<OnlineHalter>();
  late final AbendHalter _abendHalter = context.read<AbendHalter>();
  late final GastgeberDienst? _dienst = _halter.dienst;

  bool _verbindet = true;
  bool _verbindungsFehler = false;
  bool _startet = false;
  bool _uebergeben = false;

  /// Zuletzt an den Raum gesandte Rollenzahl (nachgezogen, wenn Gäste dazukommen).
  int? _gesandt;

  GastgeberDienst get _d => _dienst!;

  @override
  void initState() {
    super.initState();
    final d = _dienst;
    if (d == null) {
      // Ohne Raum (z. B. nach dem Neuladen) zurück in die Detektei.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.start);
      });
      return;
    }
    d.addListener(_geaendert);
    unawaited(_verbinde());
  }

  @override
  void dispose() {
    final d = _dienst;
    if (d != null) {
      d.removeListener(_geaendert);
      // Verlässt der Gastgeber die Lobby, ohne zu starten, ist der Raum zu; ein
      // wiederhergestellter, schon laufender Abend bleibt in der Ablage liegen.
      if (!_uebergeben) {
        _halter.vergissDienst(d);
        unawaited(d.schliessen(endgueltig: !d.gestartet));
      }
    }
    super.dispose();
  }

  void _geaendert() {
    if (!mounted) return;
    setState(() {});
    _rollenNachziehen();
  }

  /// Die Rollenzahl liegt im Raum (`besetzung`): beim Öffnen die Vorgabe, und
  /// kommen mehr Gäste ohne Sitz als Rollen, die neue Mindestzahl.
  void _rollenNachziehen() {
    final d = _dienst;
    if (d == null || !d.offen || d.gestartet || d.ansicht['phase'] != 'lobby') return;
    final stand = _stand(d);
    if (!stand.rollenNachziehen || _gesandt == stand.anzahl) return;
    _gesandt = stand.anzahl;
    unawaited(_befehl({'typ': 'besetzung', 'rollen': stand.anzahl}));
  }

  LobbyStand _stand(GastgeberDienst d) => LobbyStand.aus(d.ansicht, d.daten, d.verb.spielerId ?? gastgeberPlatz);

  /// Lobby-Nachricht an den Raum; eine Ablehnung steht kurz als Meldung da.
  Future<void> _befehl(Map<String, Object?> nachricht) async {
    final l = L.of(context);
    try {
      await _d.verb.befehl(nachricht);
    } on AbendFehler catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(befehlsFehlerText(l, e.key))));
    }
  }

  /// Gäste aus der Gästeliste (M5), deren Name dort mit einer Figur steht, bekommen sie.
  Future<void> _ausGaesteliste(Map<String, String> vorschlag) async {
    for (final e in vorschlag.entries) {
      await _befehl({'typ': 'zuteilen', 'spieler': e.key, 'rolle': e.value});
    }
  }

  Future<void> _verbinde() async {
    final d = _d;
    if (mounted) {
      setState(() {
        _verbindet = true;
        _verbindungsFehler = false;
      });
    }
    try {
      await d.oeffnen();
    } catch (e) {
      debugPrint('ONLINE lobby fehler $e');
      if (mounted) {
        setState(() {
          _verbindet = false;
          _verbindungsFehler = true;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _verbindet = false);
    // Ein wiederhergestellter Abend läuft schon: gleich weiter zum Abend.
    if (d.gestartet) {
      _zumAbend();
    } else {
      _rollenNachziehen();
    }
  }

  void _zumAbend() {
    if (_uebergeben || !mounted) return;
    _uebergeben = true;
    _abendHalter.uebernehmen(GastgeberSitzung(_d));
    context.go(Routes.abend);
  }

  bool get _alleBereit => _d.gaeste.every((g) => g.bereit && g.online);

  Future<void> _starten() async {
    if (_startet) return;
    final l = L.of(context);
    final deck = context.read<MetaStore>().deck;
    setState(() => _startet = true);
    try {
      await _d.abendStarten(rollen: _stand(_d).anzahl, vorrat: deck);
    } on AbendFehler catch (e) {
      if (mounted) {
        setState(() => _startet = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(befehlsFehlerText(l, e.key))));
      }
      return;
    }
    if (!mounted) return;
    setState(() => _startet = false);
    _zumAbend();
  }

  Future<void> _abbrechen() async {
    final l = L.of(context);
    final ja = await onlineRueckfrage(
      context,
      titel: l.online_schliessen_titel,
      text: l.online_schliessen_text,
      ja: l.online_schliessen_ja,
      nein: l.online_schliessen_nein,
      gefaehrlich: true,
    );
    if (!ja || !mounted) return;
    await _d.schliessen(endgueltig: !_d.gestartet);
    _halter.vergissDienst(_d);
    if (mounted) context.go(Routes.start);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = _dienst;
    final f = MFarben.von(context);
    if (d == null) return Scaffold(backgroundColor: f.grund);
    return AkteThema(
      akte: d.akteId,
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: MFarben.von(context).grund,
          body: MRahmen(
            marke: l.online_lobby_marke,
            titel: l.online_lobby_titel,
            untertitel: l.online_lobby_untertitel,
            aktionen: [
              MKnopf(text: l.common_cancel, art: MKnopfArt.zweit, onPressed: _abbrechen),
              MKnopf(
                text: l.online_abend_starten,
                icon: Icons.play_arrow_rounded,
                onPressed: d.offen && d.verbunden && !_startet && _alleBereit && _stand(d).sitzeKlar ? _starten : null,
              ),
            ],
            child: _inhalt(context, d),
          ),
        ),
      ),
    );
  }

  Widget _inhalt(BuildContext context, GastgeberDienst d) {
    final l = L.of(context);
    if (_verbindungsFehler) {
      return OnlineHinweisKarte(
        icon: Icons.cloud_off_rounded,
        text: l.online_lobby_fehler,
        aktion: MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: _verbinde),
      );
    }
    if (_verbindet || !d.offen) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: MMass.s24),
        child: OnlineWarteNotiz(text: l.online_lobby_verbinde),
      );
    }
    final code = d.raumCode;
    final link = beitrittsLink(code);
    final stand = _stand(d);
    final vorschlag = stand.vorschlagAus(gaesteVorschlag(context, d.akteId));
    final ich = stand.ich;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!d.verbunden) ...[
          const _GetrenntHinweis(),
          const SizedBox(height: MMass.s16),
        ],
        OnlineCodeTafel(code: code, link: link, sigel: AkteStil.fuer(d.akteId).sigel),
        const SizedBox(height: MMass.s32),
        LobbyTisch(
          stand: stand,
          befehl: _befehl,
          fuss: d.gaeste.isEmpty
              ? OnlineWarteNotiz(text: l.online_tisch_leer)
              : !stand.sitzeKlar
                  ? OnlineWarteNotiz(key: const ValueKey('lobby-sitze'), text: l.online_lobby_detektiv_fehlt, uhr: false)
                  : _alleBereit
                      ? OnlineWarteNotiz(text: l.online_alle_bereit, uhr: false, stempel: l.online_bereit)
                      : OnlineWarteNotiz(text: l.online_warten_bereit),
        ),
        Align(alignment: Alignment.centerLeft, child: RollenUebersichtKnopf(hervorheben: ich?.sitz)),
        if (vorschlag.isNotEmpty) ...[
          const SizedBox(height: MMass.s8),
          Align(
            alignment: Alignment.centerLeft,
            child: MKnopf(
              key: const ValueKey('lobby-gaesteliste'),
              text: l.online_lobby_gaesteliste,
              art: MKnopfArt.zweit,
              icon: Icons.people_alt_outlined,
              onPressed: () => _ausGaesteliste(vorschlag),
            ),
          ),
        ],
        const SizedBox(height: MMass.s16),
        LobbyRollenTafel(stand: stand, onAendern: (n) => unawaited(_befehl({'typ': 'besetzung', 'rollen': n}))),
        const SizedBox(height: MMass.s24),
        // Eine Akte mit fester Lösung kennt keinen Fall-Code; eine Druckfassung gibt es online nie.
        if (d.daten.kanon.festeLoesung) const FesteLoesungHinweis(online: true),
        // Die Klasse reist mit dem Detektiv-Sitz (M6.4): nur, wenn der Gastgeber ermittelt.
        if (ich?.sitz == Sitz.detektiv) ...[
          LobbyKlasse(
            ichId: ich!.id,
            klasseImRaum: jMap(d.ansicht['privat'])['klasse'] as String?,
            befehl: _befehl,
            karte: d.daten.hat('klassen'),
            katalog: d.katalog,
          ),
          const SizedBox(height: MMass.s16),
        ],
        DeckZeile(katalog: d.katalog, onAendern: () => context.push(Routes.sammlungDeck)),
      ],
    );
  }
}

/// Die Verbindung zum Relais ist weg: Gäste erfahren nichts, der Abend startet nicht.
class _GetrenntHinweis extends StatelessWidget {
  const _GetrenntHinweis();

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        container: true,
        child: OnlineHinweisKarte(
          key: const ValueKey('online-getrennt'),
          art: PapierArt.telegramm,
          icon: Icons.wifi_off_rounded,
          text: L.of(context).online_lobby_getrennt,
          farbe: onlineWarnTinte,
        ),
      );
}

/// Der Raumcode als getipptes Telegramm, daneben (oder darunter) die
/// Platzkarte mit dem gedruckten QR-Code und dem Siegel der Akte.
class OnlineCodeTafel extends StatelessWidget {
  const OnlineCodeTafel({super.key, required this.code, required this.link, required this.sigel});

  final String code;

  /// Beitrittsadresse (Web) oder `null` (dann enthält der QR-Code nur den Code).
  final String? link;

  /// Kürzel der Akte für das Siegel der Platzkarte.
  final String sigel;

  void _kopieren(BuildContext context, String text) {
    final l = L.of(context);
    unawaited(Clipboard.setData(ClipboardData(text: text)));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.online_kopiert)));
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final anzeige = raumCodeAnzeige(code);
    final adresse = link;
    final telegramm = Padding(
      padding: const EdgeInsets.only(top: MMass.s12),
      child: MBlatt(
        art: PapierArt.telegramm,
        klebestreifen: true,
        neigung: -0.006,
        samen: 17,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.online_code_titel, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
            const SizedBox(height: 4),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
            const SizedBox(height: MMass.s16),
            Semantics(
              label: l.online_code_semantik(anzeige),
              excludeSemantics: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  anzeige,
                  key: const ValueKey('raumcode'),
                  style: MPapierSchrift.maschine.copyWith(fontSize: 40, height: 1.15, letterSpacing: 6),
                ),
              ),
            ),
            const SizedBox(height: MMass.s16),
            Wrap(
              spacing: MMass.s8,
              runSpacing: MMass.s8,
              children: [
                MKnopf(text: l.online_code_kopieren, art: MKnopfArt.zweit, icon: Icons.copy_rounded, onPressed: () => _kopieren(context, anzeige)),
                if (adresse != null)
                  MKnopf(text: l.online_link_kopieren, art: MKnopfArt.zweit, icon: Icons.link_rounded, onPressed: () => _kopieren(context, adresse)),
              ],
            ),
          ],
        ),
      ),
    );
    final karte = MOnlineTicket(
      neigung: 0.01,
      samen: 9,
      abschnitt: Row(
        children: [
          MSiegel(kuerzel: sigel, groesse: 34),
          const SizedBox(width: MMass.s12),
          Expanded(child: Text('Nr. $anzeige', style: MPapierSchrift.maschine.copyWith(letterSpacing: 1.5))),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrBild(daten: adresse ?? code, semantik: l.online_qr_semantik, groesse: 200),
          const SizedBox(height: MMass.s12),
          Text(l.online_qr_hinweis, textAlign: TextAlign.center, style: MPapierSchrift.leise),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, b) {
        if (b.maxWidth >= 600) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: telegramm),
              const SizedBox(width: MMass.s24),
              Expanded(flex: 2, child: karte),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            telegramm,
            const SizedBox(height: MMass.s24),
            Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 300), child: karte)),
          ],
        );
      },
    );
  }
}
