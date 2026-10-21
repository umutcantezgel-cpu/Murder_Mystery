import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/runden.dart' show TischVorrat;
import 'package:provider/provider.dart';

import '../abend/abend_halter.dart';
import '../abend/abend_speicher.dart';
import '../app/router.dart';
import '../karten/katalog_laden.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../party/daten.dart';
import '../party/sitzung.dart';
import '../stil/mappe/assistent_formular.dart' show MFormkopf;
import '../stil/stil.dart';

/// Erster Fall (M8, Einstieg): Wer noch keinen Abend gespielt hat und keinen
/// abgelegten Abend hat, findet auf dem Schreibtisch die Akte „Dein erster
/// Fall“. Ein Tipp legt einen Solo-Abend im Schlosskeller an (Bots spielen die
/// Gäste, Deck und Erkundungsorte wie im Assistenten) und öffnet ihn: ohne
/// Assistent in weniger als einer Minute am Tatort.
class ErsterFall extends StatefulWidget {
  const ErsterFall({super.key});

  /// Akte des ersten Falls: die erste der Kampagne, mit Gesprächen mit Zeugen.
  static const akte = 'schlosskeller';

  @override
  State<ErsterFall> createState() => _ErsterFallState();
}

class _ErsterFallState extends State<ErsterFall> {
  bool _laeuft = false;

  @override
  void initState() {
    super.initState();
    // Füllt [AbendSpeicher.abgelegt]; verwirft jemand den Abend, zeigt sich die Akte.
    unawaited(AbendSpeicher.lesen());
  }

  Future<void> _los() async {
    if (_laeuft) return;
    final meta = context.read<MetaStore>();
    final halter = context.read<AbendHalter>();
    final router = GoRouter.of(context);
    setState(() => _laeuft = true);
    try {
      final daten = await PartyDaten.laden(rootBundle, fall: ErsterFall.akte);
      final abstecher = await ladeAbstecher(ErsterFall.akte);
      final katalog = await kartenBereit(meta);
      // Die Detektei ist schon weg (z. B. „Neuer Abend“ getippt): nichts öffnen.
      if (!mounted) return;
      final s = PartySitzung(daten);
      s.kartenAnlegen(vorrat: TischVorrat.aus(meta.deck, katalog), abstecher: abstecher);
      s.einrichten(rollen: s.minRollen, detektiv: 'w', solo: true, detektivName: (meta.name ?? '').trim());
      halter.uebernehmen(s);
      router.go(Routes.abend);
    } catch (e) {
      debugPrint('ERSTER FALL fehler $e');
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool?>(
        valueListenable: AbendSpeicher.abgelegt,
        builder: (context, abgelegt, _) => _akte(context, abgelegt),
      );

  Widget _akte(BuildContext context, bool? abgelegt) {
    final meta = context.watch<MetaStore>();
    // Unbekannt oder ein abgelegter Abend: erst der, dann der erste Fall.
    if (abgelegt != false || meta.gebuchteAbende.isNotEmpty) return const SizedBox.shrink();
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: MBlatt(
        key: const ValueKey('erster-fall'),
        art: PapierArt.akte,
        klammer: true,
        neigung: -0.005,
        samen: 101,
        randFarbe: AkteStil.fuer(ErsterFall.akte).akzent,
        padding: const EdgeInsets.fromLTRB(18, 26, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            MFormkopf(l.erster_fall_marke),
            const SizedBox(height: MMass.s8),
            Text(l.erster_fall_text, style: MPapierSchrift.text),
            const SizedBox(height: MMass.s16),
            MKnopf(text: l.erster_fall_los, icon: Icons.search_rounded, breit: true, gross: true, onPressed: _laeuft ? null : _los),
            const SizedBox(height: MMass.s8),
            Text(l.erster_fall_hinweis, style: MPapierSchrift.leise.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
