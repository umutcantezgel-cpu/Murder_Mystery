import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart' show LookDef;
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
import '../einrichtung/klasse_zeile.dart';
import 'ansicht.dart';
import 'gastgeber_dienst.dart';
import 'gastgeber_sitzung.dart';
import 'online_fehler.dart';
import 'online_halter.dart';
import 'online_teile.dart';
import 'qr_bild.dart';

/// Die Lobby des Gastgebers (Route `/abend/lobby`): zeigt den Raumcode groß und
/// als QR-Code, wer schon am Tisch sitzt und ob alle bereit sind, und lässt die
/// Zahl der Rollen und den Tischvorrat festlegen. „Abend starten“ meldet den
/// Gastgeber bereit und startet den Abend; danach führt er als Detektiv weiter
/// (`/abend`). Das Relais wird erst hier verbunden, nicht schon beim Wählen der
/// Spielweise.
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
  int? _rollen;

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
    if (mounted) setState(() {});
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
    if (d.gestartet) _zumAbend();
  }

  void _zumAbend() {
    if (_uebergeben || !mounted) return;
    _uebergeben = true;
    _abendHalter.uebernehmen(GastgeberSitzung(_d));
    context.go(Routes.abend);
  }

  int get _min => math.max(_d.minRollen, math.min(_d.gaeste.length, _d.maxRollen));
  int get _max => _d.maxRollen;
  int get _anzahl => (_rollen ?? 7).clamp(_min, _max).toInt();

  bool get _alleBereit => _d.gaeste.every((g) => g.bereit && g.online);

  Future<void> _starten() async {
    if (_startet) return;
    final l = L.of(context);
    final deck = context.read<MetaStore>().deck;
    setState(() => _startet = true);
    try {
      await _d.abendStarten(rollen: _anzahl, vorrat: deck);
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
                onPressed: d.offen && d.verbunden && !_startet && _alleBereit ? _starten : null,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!d.verbunden) ...[
          const _GetrenntHinweis(),
          const SizedBox(height: MMass.s16),
        ],
        _CodeTafel(code: code, link: link, sigel: AkteStil.fuer(d.akteId).sigel),
        const SizedBox(height: MMass.s32),
        _TischTafel(dienst: d, alleBereit: _alleBereit),
        const SizedBox(height: MMass.s16),
        _RollenTafel(
          anzahl: _anzahl,
          min: _min,
          max: _max,
          gaeste: d.gaeste.length,
          onAendern: (n) => setState(() => _rollen = n),
        ),
        const SizedBox(height: MMass.s24),
        // Eine Akte mit fester Lösung kennt keinen Fall-Code; eine Druckfassung gibt es online nie.
        if (d.daten.kanon.festeLoesung) const FesteLoesungHinweis(online: true),
        const KlasseZeile(),
        const SizedBox(height: MMass.s16),
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
class _CodeTafel extends StatelessWidget {
  const _CodeTafel({required this.code, required this.link, required this.sigel});

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

/// Das Gästeregister: wer am Tisch sitzt, je Platz eine Karteikarte mit
/// Schattenriss (die Rollen verteilt erst der Start) und dem Bereit-Stempel.
class _TischTafel extends StatelessWidget {
  const _TischTafel({required this.dienst, required this.alleBereit});

  final GastgeberDienst dienst;
  final bool alleBereit;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final spieler = dienst.spieler;
    final gaeste = dienst.gaeste;
    // Die Spielleitung spielt den Detektiv: ihr Abzug zeigt ihn.
    final detektiv = onlineAussehen(dienst.daten, onlineDetektivId(dienst.daten));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnlineRegisterKopf('${l.online_tisch_titel} (${spieler.length})'),
        for (var i = 0; i < spieler.length; i++) _Zeile(spieler: spieler[i], nr: i, detektiv: detektiv),
        const SizedBox(height: MMass.s4),
        if (gaeste.isEmpty)
          OnlineWarteNotiz(text: l.online_tisch_leer)
        else if (alleBereit)
          OnlineWarteNotiz(text: l.online_alle_bereit, uhr: false, stempel: l.online_bereit)
        else
          OnlineWarteNotiz(text: l.online_warten_bereit),
      ],
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({required this.spieler, required this.nr, required this.detektiv});

  final SpielerInfo spieler;
  final int nr;
  final LookDef? detektiv;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final Widget zustand;
    if (spieler.istGastgeber) {
      zustand = MChip(l.online_spielleitung, icon: Icons.star_rounded);
    } else if (!spieler.online) {
      zustand = MChip(l.online_getrennt, icon: Icons.wifi_off_rounded, farbe: onlineWarnTinte);
    } else if (spieler.bereit) {
      zustand = onlineStempel(l.online_bereit);
    } else {
      zustand = MChip(l.online_nicht_bereit, icon: Icons.hourglass_empty_rounded, farbe: MRoh.tinteLeise);
    }
    return OnlinePlatzKarte(name: spieler.name, look: spieler.istGastgeber ? detektiv : null, zustand: zustand, nr: nr);
  }
}

/// Zahl der Rollen als Besetzungsblatt: mindestens so viele wie Gäste,
/// höchstens die Besetzung der Akte. Freie Rollen übernehmen Bots; je Bot liegt
/// ein gestempelter Schattenriss auf dem Blatt.
class _RollenTafel extends StatelessWidget {
  const _RollenTafel({required this.anzahl, required this.min, required this.max, required this.gaeste, required this.onAendern});

  final int anzahl;
  final int min;
  final int max;
  final int gaeste;
  final ValueChanged<int> onAendern;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final bots = (anzahl - gaeste).clamp(0, anzahl).toInt();
    final gesperrt = MRoh.tinte.withValues(alpha: 0.28);
    return MBlatt(
      neigung: 0.004,
      samen: 29,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.online_rollen_titel, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
          const SizedBox(height: 4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: MMass.s12),
          Semantics(container: true, child: Text(l.online_rollen_anzahl(anzahl), textAlign: TextAlign.center, style: MPapierSchrift.titel)),
          Row(
            children: [
              IconButton(
                tooltip: l.online_rollen_weniger,
                onPressed: anzahl > min ? () => onAendern(anzahl - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: MRoh.tinte,
                disabledColor: gesperrt,
              ),
              Expanded(
                child: min >= max
                    ? const SizedBox.shrink()
                    : Slider(
                        value: anzahl.toDouble(),
                        min: min.toDouble(),
                        max: max.toDouble(),
                        divisions: max - min,
                        activeColor: MRoh.stempelRot,
                        inactiveColor: MRoh.tinte.withValues(alpha: 0.18),
                        thumbColor: MRoh.messingMitte,
                        semanticFormatterCallback: (v) => l.online_rollen_anzahl(v.round()),
                        onChanged: (v) => onAendern(v.round()),
                      ),
              ),
              IconButton(
                tooltip: l.online_rollen_mehr,
                onPressed: anzahl < max ? () => onAendern(anzahl + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: MRoh.tinte,
                disabledColor: gesperrt,
              ),
            ],
          ),
          const SizedBox(height: MMass.s4),
          Text(l.online_rollen_bots(bots), style: MPapierSchrift.text),
          if (bots > 0) ...[
            const SizedBox(height: MMass.s16),
            OnlineBotReihe(bots: [for (var i = 0; i < bots; i++) (look: null, name: null, farbe: null)], stempel: l.online_bot_stempel),
          ],
          const SizedBox(height: MMass.s16),
          Text(l.online_rollen_hinweis, style: MPapierSchrift.leise),
        ],
      ),
    );
  }
}
