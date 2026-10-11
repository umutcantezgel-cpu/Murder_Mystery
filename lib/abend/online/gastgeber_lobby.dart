import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show AbendFehler;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../karten/widgets/deck_zeile.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../netz/relay_einstellung.dart';
import '../../stil/stil.dart';
import '../abend_halter.dart';
import '../einrichtung/abschnitte.dart' show FesteLoesungHinweis;
import '../einrichtung/klasse_zeile.dart';
import 'ansicht.dart';
import 'gastgeber_dienst.dart';
import 'gastgeber_sitzung.dart';
import 'online_fehler.dart';
import 'online_halter.dart';
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
      // Verlässt der Gastgeber die Lobby, ohne zu starten, ist der Raum zu.
      if (!_uebergeben) {
        _halter.vergissDienst(d);
        unawaited(d.schliessen());
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
    final ja = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.online_schliessen_titel),
        content: Text(l.online_schliessen_text),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(l.online_schliessen_nein)),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text(l.online_schliessen_ja)),
        ],
      ),
    );
    if (ja != true || !mounted) return;
    await _d.schliessen();
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
                onPressed: d.offen && !_startet && _alleBereit ? _starten : null,
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
    final t = MSchrift.von(context);
    if (_verbindungsFehler) {
      return MTafel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.online_lobby_fehler, style: t.text),
            const SizedBox(height: MMass.s12),
            MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: _verbinde),
          ],
        ),
      );
    }
    if (_verbindet || !d.offen) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: MMass.s32),
        child: Column(
          children: [
            if (!MBewegung.ruhig(context)) ...[
              const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3)),
              const SizedBox(height: MMass.s16),
            ],
            Text(l.online_lobby_verbinde, textAlign: TextAlign.center, style: t.leise),
          ],
        ),
      );
    }
    final code = d.raumCode;
    final link = beitrittsLink(code);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CodeTafel(code: code, link: link),
        const SizedBox(height: MMass.s16),
        _TischTafel(dienst: d, alleBereit: _alleBereit),
        const SizedBox(height: MMass.s16),
        _RollenTafel(
          anzahl: _anzahl,
          min: _min,
          max: _max,
          gaeste: d.gaeste.length,
          onAendern: (n) => setState(() => _rollen = n),
        ),
        const SizedBox(height: MMass.s16),
        // Eine Akte mit fester Lösung kennt keinen Fall-Code; eine Druckfassung gibt es online nie.
        if (d.daten.kanon.festeLoesung) const FesteLoesungHinweis(online: true),
        const KlasseZeile(),
        const SizedBox(height: MMass.s16),
        DeckZeile(katalog: d.katalog, onAendern: () => context.push(Routes.sammlungDeck)),
      ],
    );
  }
}

/// Der Raumcode groß, daneben der QR-Code und Knöpfe zum Kopieren.
class _CodeTafel extends StatelessWidget {
  const _CodeTafel({required this.code, required this.link});

  final String code;

  /// Beitrittsadresse (Web) oder `null` (dann enthält der QR-Code nur den Code).
  final String? link;

  void _kopieren(BuildContext context, String text) {
    final l = L.of(context);
    unawaited(Clipboard.setData(ClipboardData(text: text)));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.online_kopiert)));
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final anzeige = raumCodeAnzeige(code);
    return MTafel(
      hervorgehoben: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.online_code_titel.toUpperCase(), style: t.marke, textAlign: TextAlign.center),
          const SizedBox(height: MMass.s8),
          Semantics(
            label: l.online_code_semantik(anzeige),
            excludeSemantics: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                anzeige,
                key: const ValueKey('raumcode'),
                style: t.titel.copyWith(fontSize: 52, letterSpacing: 6, color: f.akzentHell),
              ),
            ),
          ),
          const SizedBox(height: MMass.s16),
          Center(child: QrBild(daten: link ?? code, semantik: l.online_qr_semantik)),
          const SizedBox(height: MMass.s12),
          Text(l.online_qr_hinweis, textAlign: TextAlign.center, style: t.leise),
          const SizedBox(height: MMass.s12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: MMass.s8,
            runSpacing: MMass.s8,
            children: [
              MKnopf(text: l.online_code_kopieren, art: MKnopfArt.zweit, icon: Icons.copy_rounded, onPressed: () => _kopieren(context, anzeige)),
              if (link != null)
                MKnopf(text: l.online_link_kopieren, art: MKnopfArt.zweit, icon: Icons.link_rounded, onPressed: () => _kopieren(context, link!)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Wer am Tisch sitzt, mit Bereit-Zustand.
class _TischTafel extends StatelessWidget {
  const _TischTafel({required this.dienst, required this.alleBereit});

  final GastgeberDienst dienst;
  final bool alleBereit;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final spieler = dienst.spieler;
    final gaeste = dienst.gaeste;
    return MTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${l.online_tisch_titel} (${spieler.length})'.toUpperCase(), style: t.marke),
          const SizedBox(height: MMass.s12),
          for (final s in spieler) _Zeile(spieler: s),
          if (gaeste.isEmpty) ...[
            const SizedBox(height: MMass.s4),
            Text(l.online_tisch_leer, style: t.leise),
          ] else ...[
            const SizedBox(height: MMass.s8),
            Text(alleBereit ? l.online_alle_bereit : l.online_warten_bereit, style: t.leise),
          ],
        ],
      ),
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({required this.spieler});

  final SpielerInfo spieler;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final Widget marke;
    if (spieler.istGastgeber) {
      marke = MChip(l.online_spielleitung, icon: Icons.star_rounded);
    } else if (!spieler.online) {
      marke = MChip(l.online_getrennt, icon: Icons.wifi_off_rounded, farbe: f.warnung);
    } else if (spieler.bereit) {
      marke = MChip(l.online_bereit, icon: Icons.check_circle_rounded, farbe: f.erfolg);
    } else {
      marke = MChip(l.online_nicht_bereit, icon: Icons.hourglass_empty_rounded, farbe: f.papierLeise);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s8),
      child: Row(
        children: [
          Expanded(child: Text(spieler.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.text)),
          const SizedBox(width: MMass.s8),
          Flexible(child: marke),
        ],
      ),
    );
  }
}

/// Zahl der Rollen: mindestens so viele wie Gäste, höchstens die Besetzung der Akte.
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
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final bots = (anzahl - gaeste).clamp(0, anzahl).toInt();
    return MTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.online_rollen_titel.toUpperCase(), style: t.marke),
          const SizedBox(height: MMass.s12),
          Text(l.online_rollen_anzahl(anzahl), textAlign: TextAlign.center, style: t.ueberschrift),
          Row(
            children: [
              IconButton(
                tooltip: l.online_rollen_weniger,
                onPressed: anzahl > min ? () => onAendern(anzahl - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: f.papier,
              ),
              Expanded(
                child: min >= max
                    ? const SizedBox.shrink()
                    : Slider(
                        value: anzahl.toDouble(),
                        min: min.toDouble(),
                        max: max.toDouble(),
                        divisions: max - min,
                        activeColor: f.akzent,
                        inactiveColor: f.flaecheHoch,
                        semanticFormatterCallback: (v) => l.online_rollen_anzahl(v.round()),
                        onChanged: (v) => onAendern(v.round()),
                      ),
              ),
              IconButton(
                tooltip: l.online_rollen_mehr,
                onPressed: anzahl < max ? () => onAendern(anzahl + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: f.papier,
              ),
            ],
          ),
          const SizedBox(height: MMass.s4),
          Text(l.online_rollen_bots(bots), style: t.text),
          const SizedBox(height: MMass.s4),
          Text(l.online_rollen_hinweis, style: t.leise),
        ],
      ),
    );
  }
}
