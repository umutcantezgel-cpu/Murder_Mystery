import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart' show PartyPhase;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../l10n/lookup.dart';
import '../../netz/relay_einstellung.dart';
import '../../party/party_seite.dart';
import '../../party/sitzung.dart';
import '../../stil/stil.dart';
import 'gastgeber_sitzung.dart';
import 'gastgeber_wartet.dart';
import 'online_fehler.dart';
import 'online_halter.dart';

/// Der Abend des Gastgebers: dieselben Bildschirme wie beim Spiel an einem Gerät
/// ([PartyAblauf]); nur die Rollenphase und die Gruppenwahl zeigen den
/// Fortschritt der Gäste statt der Geräteübergabe. Über allem steht eine
/// schmale Leiste mit dem Raumcode und dem Menü (Gäste, Abend beenden).
class GastgeberAblauf extends StatefulWidget {
  const GastgeberAblauf({super.key, required this.sitzung, this.onEnde});

  final GastgeberSitzung sitzung;

  /// Weg vom Ende des Abends (Belohnung).
  final VoidCallback? onEnde;

  @override
  State<GastgeberAblauf> createState() => _GastgeberAblaufState();
}

class _GastgeberAblaufState extends State<GastgeberAblauf> {
  GastgeberSitzung get s => widget.sitzung;

  @override
  void initState() {
    super.initState();
    s.addListener(_pruefeFehler);
  }

  @override
  void dispose() {
    s.removeListener(_pruefeFehler);
    super.dispose();
  }

  /// Eine Ablehnung des Raums (z. B. „noch nicht alle bereit“) einmal anzeigen.
  void _pruefeFehler() {
    final key = s.letzterFehler;
    if (key == null) return;
    s.fehlerQuittieren();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(befehlsFehlerText(L.of(context), key))));
    });
  }

  Widget? _ersatz(PartySitzung p) => switch (p.phase) {
        PartyPhase.rollen => GastgeberRollenWarten(sitzung: s),
        PartyPhase.gruppenwahl => GastgeberGruppenwahl(sitzung: s),
        _ => null,
      };

  @override
  Widget build(BuildContext context) => AkteThema(
        akte: s.daten.fall,
        child: Builder(
          builder: (context) => ColoredBox(
            color: MFarben.von(context).grund,
            child: Column(
              children: [
                _Leiste(sitzung: s),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: PartyAblauf(sitzung: s, onEnde: widget.onEnde, ersatz: _ersatz),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Schmale Leiste über dem Abend: Raumcode, wie viele Gäste verbunden sind, Menü.
class _Leiste extends StatelessWidget {
  const _Leiste({required this.sitzung});

  final GastgeberSitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: f.grund2, border: Border(bottom: BorderSide(color: f.linie))),
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: sitzung.dienst,
          builder: (context, _) {
            final gaeste = sitzung.dienst.gaeste;
            final da = gaeste.where((g) => g.online).length;
            // Ohne Relais ist der Stand der Gäste veraltet: nur die Trennung zeigen.
            final getrennt = !sitzung.dienst.geschlossen && !sitzung.dienst.verbunden;
            return Padding(
              padding: const EdgeInsets.only(left: MMass.s16, right: MMass.s4),
              child: Row(
                children: [
                  Icon(getrennt ? Icons.wifi_off_rounded : Icons.groups_2_outlined, size: 20, color: getrennt ? f.warnung : f.akzent),
                  const SizedBox(width: MMass.s8),
                  Expanded(
                    child: Text(
                      '${l.online_leiste_raum(raumCodeAnzeige(sitzung.dienst.raumCode))} · ${getrennt ? l.online_leiste_getrennt : l.online_leiste_online(da, gaeste.length)}',
                      key: const ValueKey('online-leiste'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.leise.copyWith(fontSize: 13, color: getrennt ? f.warnung : null),
                    ),
                  ),
                  IconButton(
                    tooltip: l.online_menue,
                    onPressed: () => _menue(context),
                    icon: const Icon(Icons.more_vert_rounded),
                    color: f.papier,
                    constraints: const BoxConstraints(minWidth: MMass.tippflaeche, minHeight: MMass.tippflaeche),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _menue(BuildContext context) async {
    final beenden = await showDialog<bool>(
      context: context,
      builder: (c) => _Menue(sitzung: sitzung),
    );
    if (beenden != true || !context.mounted) return;
    final online = context.read<OnlineHalter>();
    final dienst = sitzung.dienst;
    // Endgültig beenden: Die Gäste erfahren es, der abgelegte Stand wird gelöscht.
    // Die Abendseite räumt die Sitzung danach selbst ab.
    await dienst.schliessen();
    online.vergissDienst(dienst);
    if (context.mounted) context.go(Routes.start);
  }
}

/// Raum, Gäste und „Abend beenden“.
class _Menue extends StatelessWidget {
  const _Menue({required this.sitzung});

  final GastgeberSitzung sitzung;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = MSchrift.von(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: MTafel(
          child: ListenableBuilder(
            listenable: sitzung.dienst,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.online_code_titel.toUpperCase(), style: t.marke),
                const SizedBox(height: MMass.s4),
                Text(raumCodeAnzeige(sitzung.dienst.raumCode), style: t.titel),
                const SizedBox(height: MMass.s16),
                Text(l.online_tisch_titel.toUpperCase(), style: t.marke),
                const SizedBox(height: MMass.s8),
                for (final p in sitzung.dienst.spieler) PlatzZeile(spieler: p),
                const SizedBox(height: MMass.s16),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: MMass.s8,
                  runSpacing: MMass.s8,
                  children: [
                    MKnopf(text: l.common_close, art: MKnopfArt.zweit, onPressed: () => Navigator.of(context).pop(false)),
                    MKnopf(text: l.online_beenden, icon: Icons.stop_circle_outlined, onPressed: () => _bestaetigen(context)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _bestaetigen(BuildContext context) async {
    final l = L.of(context);
    final ja = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.online_beenden_titel),
        content: Text(l.online_beenden_text),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(l.online_beenden_nein)),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text(l.online_beenden_ja)),
        ],
      ),
    );
    if (ja == true && context.mounted) Navigator.of(context).pop(true);
  }
}
