import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../l10n/lookup.dart';
import '../../netz/ablage_prefs.dart';
import '../../netz/relay_einstellung.dart';
import '../../stil/stil.dart';
import 'gast_dienst.dart';
import 'gastgeber_dienst.dart';
import 'online_halter.dart';

/// Banner der Detektei: „Zurück in Raum ABC-DEF“ für einen Gast, der noch einen
/// Platz in einem Abend hat, und „Zurück zum Abend ABC-DEF“ für den Gastgeber
/// eines abgelegten Abends. Ohne gemerkten Raum bleibt das Feld leer.
class OnlineRueckkehr extends StatefulWidget {
  const OnlineRueckkehr({super.key});

  @override
  State<OnlineRueckkehr> createState() => _OnlineRueckkehrState();
}

class _OnlineRueckkehrState extends State<OnlineRueckkehr> {
  ({String code, String name})? _gast;
  String? _gastgeberCode;
  bool _laeuft = false;

  @override
  void initState() {
    super.initState();
    unawaited(_lesen());
  }

  Future<void> _lesen() async {
    final gast = await GastDienst.gemerkt();
    final host = await GastgeberDienst.gespeicherterCode(const AblagePrefs());
    if (!mounted) return;
    setState(() {
      _gast = gast;
      _gastgeberCode = host;
    });
  }

  Future<void> _gastZurueck() async {
    final g = _gast;
    if (g == null || _laeuft) return;
    final l = L.of(context);
    final halter = context.read<OnlineHalter>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _laeuft = true);
    try {
      final dienst = await GastDienst.beitreten(code: g.code, name: g.name);
      halter.uebernehmeGast(dienst);
      router.go(Routes.gast);
    } catch (e) {
      debugPrint('ONLINE rueckkehr fehler $e');
      messenger.showSnackBar(SnackBar(content: Text(l.online_rueckkehr_fehler)));
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  Future<void> _gastVergessen() async {
    final g = _gast;
    if (g == null) return;
    await GastDienst.vergiss(g.code);
    if (mounted) setState(() => _gast = null);
  }

  Future<void> _gastgeberZurueck() async {
    if (_laeuft) return;
    final l = L.of(context);
    final halter = context.read<OnlineHalter>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _laeuft = true);
    try {
      final dienst = await GastgeberDienst.wiederherstellen(ablage: const AblagePrefs(), relay: relayFuerSeite());
      if (dienst == null) {
        messenger.showSnackBar(SnackBar(content: Text(l.online_rueckkehr_fehler)));
        if (mounted) setState(() => _gastgeberCode = null);
        return;
      }
      halter.uebernehmeDienst(dienst);
      // Die Lobby verbindet das Relais und führt bei einem laufenden Abend gleich weiter.
      router.go(Routes.abendLobby);
    } catch (e) {
      debugPrint('ONLINE wiederherstellen fehler $e');
      messenger.showSnackBar(SnackBar(content: Text(l.online_rueckkehr_fehler)));
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  Future<void> _gastgeberVerwerfen() async {
    await GastgeberDienst.verwerfeGespeicherten(const AblagePrefs());
    if (mounted) setState(() => _gastgeberCode = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final gast = _gast;
    final host = _gastgeberCode;
    if (gast == null && host == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (gast != null)
          _Banner(
            key: const ValueKey('rueckkehr-gast'),
            knopf: l.online_zurueck_in_raum(raumCodeAnzeige(gast.code)),
            hinweis: l.online_zurueck_hinweis,
            verwerfen: l.online_vergessen,
            onZurueck: _laeuft ? null : _gastZurueck,
            onVerwerfen: _laeuft ? null : _gastVergessen,
          ),
        if (host != null)
          _Banner(
            key: const ValueKey('rueckkehr-gastgeber'),
            knopf: l.online_zurueck_zum_abend(raumCodeAnzeige(host)),
            hinweis: l.online_zurueck_gastgeber_hinweis,
            verwerfen: l.online_verwerfen,
            onZurueck: _laeuft ? null : _gastgeberZurueck,
            onVerwerfen: _laeuft ? null : _gastgeberVerwerfen,
            neigung: 0.004,
          ),
        const SizedBox(height: MMass.s12),
      ],
    );
  }
}

/// Rückkehr als Karteikarte mit Büroklammer: das Messingschild „Zurück …“,
/// darunter der Hinweis in Tinte und „Vergessen“ als leise Zeile.
class _Banner extends StatelessWidget {
  const _Banner({super.key, required this.knopf, required this.hinweis, required this.verwerfen, required this.onZurueck, required this.onVerwerfen, this.neigung = -0.004});

  final String knopf;
  final String hinweis;
  final String verwerfen;
  final VoidCallback? onZurueck;
  final VoidCallback? onVerwerfen;
  final double neigung;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: MMass.s16, bottom: MMass.s8),
        child: MBlatt(
          art: PapierArt.karteikarte,
          kopfLinie: 7,
          linien: false,
          klammer: true,
          neigung: neigung,
          samen: knopf.codeUnits.fold(13, (a, b) => (a * 31 + b) & 0xffff),
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              MKnopf(text: knopf, icon: Icons.replay_rounded, breit: true, onPressed: onZurueck),
              const SizedBox(height: MMass.s12),
              Text(hinweis, style: MPapierSchrift.leise.copyWith(fontSize: 13)),
              Align(
                alignment: Alignment.centerLeft,
                child: MKnopf(text: verwerfen, art: MKnopfArt.leise, onPressed: onVerwerfen),
              ),
            ],
          ),
        ),
      );
}
