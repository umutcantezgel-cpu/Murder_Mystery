import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Rundenzentrale (F4-BAUMEISTER-03, Master 7.6 Schritt 5): Erzählertext zum
/// Rundenstart, die Uhr der Runde und die Pflichtgespräche aller besetzten
/// Rollen. Die Uhr schaltet nichts weiter; das tut allein der Weiter-Knopf.
class RundeBildschirm extends StatefulWidget {
  const RundeBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<RundeBildschirm> createState() => _RundeBildschirmState();
}

class _RundeBildschirmState extends State<RundeBildschirm> {
  /// Takt der laufenden Uhr; `null`, wenn die Uhr steht.
  Timer? _takt;

  /// Restzeit der Uhr.
  late Duration _restzeit;

  PartySitzung get s => widget.sitzung;

  bool get _laeuft => _takt != null;
  bool get _abgelaufen => _restzeit == Duration.zero;

  @override
  void initState() {
    super.initState();
    _restzeit = s.rundendauer;
  }

  @override
  void dispose() {
    _takt?.cancel();
    super.dispose();
  }

  /// Uhr starten oder nach einer Pause weiterlaufen lassen.
  void _start() {
    if (_laeuft || _abgelaufen) return;
    setState(() => _takt = Timer.periodic(const Duration(seconds: 1), (_) => _ticke()));
  }

  /// Eine Sekunde weniger. Bei null bleibt die Uhr stehen.
  void _ticke() {
    final neu = _restzeit - const Duration(seconds: 1);
    setState(() => _restzeit = neu.isNegative ? Duration.zero : neu);
    if (_abgelaufen) _anhalten();
  }

  void _anhalten() {
    _takt?.cancel();
    setState(() => _takt = null);
  }

  /// Uhr auf die volle Rundendauer stellen und anhalten.
  void _zuruecksetzen() {
    _takt?.cancel();
    setState(() {
      _takt = null;
      _restzeit = s.rundendauer;
    });
  }

  /// Restzeit im Format mm:ss.
  String get _zeit {
    final min = _restzeit.inMinutes.toString().padLeft(2, '0');
    final sek = (_restzeit.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sek';
  }

  @override
  Widget build(BuildContext context) => PartyRahmen(
        marke: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
        titel: s.rundenName,
        untertitel: s.ui('ui.allgemein.uhrzeit', {'uhrzeit': s.rundenUhrzeit}),
        aktionen: [PartyKnopf(text: s.ui('ui.runde.weiter'), onPressed: s.kannWeiter ? s.weiter : null)],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // Die Uhr steht oben: Sie läuft die ganze Runde und bleibt sichtbar, auch wenn
          // der Erzähler zum Rundenstart länger spricht (Gästewissen, E-038).
          children: [
            _uhr(),
            const SizedBox(height: 16),
            ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
            const SizedBox(height: 28),
            _gespraeche(),
          ],
        ),
      );

  /// Die Uhr: große Ziffern, bei null der Hinweis, darunter die Knöpfe.
  Widget _uhr() {
    final um = _abgelaufen;
    return PartyTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.ui('ui.runde.uhr').toUpperCase(), style: context.schrift.marke, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _zeit,
              style: context.schrift.titel.copyWith(
                fontSize: 64,
                color: um ? context.farben.akzent : context.farben.akzentHell,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (um) ...[
            const SizedBox(height: 4),
            Text(s.ui('ui.runde.zeit_um'), style: Keller.ueberschrift.copyWith(color: context.farben.akzent), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              _knopf(Icons.play_arrow, s.ui('ui.runde.start'), (_laeuft || um) ? null : _start),
              _knopf(Icons.pause, s.ui('ui.runde.pause'), _laeuft ? _anhalten : null),
              _knopf(Icons.replay, s.ui('ui.runde.zuruecksetzen'), _zuruecksetzen),
            ],
          ),
        ],
      ),
    );
  }

  /// Symbolknopf der Uhr; der Tooltip ist ein Baustein.
  Widget _knopf(IconData symbol, String tipp, VoidCallback? onPressed) => IconButton(
        tooltip: tipp,
        onPressed: onPressed,
        icon: Icon(symbol),
        style: IconButton.styleFrom(foregroundColor: context.farben.akzentHell, disabledForegroundColor: Keller.papierGedaempft),
      );

  /// Die Pflichtgespräche der Runde, je Rolle eine Tafel in der Farbe der Figur.
  Widget _gespraeche() {
    final liste = s.gespraeche(s.runde);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.ui('ui.runde.gespraeche'), style: Keller.ueberschrift),
        const SizedBox(height: 6),
        Text(s.ui('ui.runde.hinweis'), style: Keller.leise),
        const SizedBox(height: 14),
        for (final rolle in s.besetzt)
          if (liste.any((z) => z.gespraech.rolle == rolle)) ...[
            _rollenTafel(rolle, [for (final z in liste) if (z.gespraech.rolle == rolle) z]),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  /// Die Gespräche einer Rolle; die Farbe der Figur läuft am Rand entlang.
  Widget _rollenTafel(String rolle, List<({Gespraech gespraech, String partner})> zeilen) => PartyTafel(
        akzent: s.figurFarbe(rolle),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final z in zeilen) Padding(padding: const EdgeInsets.only(bottom: 14), child: _zeile(z.gespraech, z.partner)),
          ],
        ),
      );

  /// Eine Zeile: Sprecher und Partner mit Farbpunkt, darunter das Thema.
  /// Ziel und Eröffnungssatz stehen nur im eigenen Dossier.
  Widget _zeile(Gespraech g, String partner) => Column(
        key: ValueKey(g.id),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 5), child: FarbPunkt(s.figurFarbe(g.rolle), groesse: 12)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.ui('ui.runde.paarung', {'sprecher': s.spielerName(g.rolle), 'partner': s.personAmTisch(partner)}),
                  style: Keller.text,
                ),
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.fromLTRB(22, 4, 0, 0), child: Text(g.thema, style: Keller.leise)),
        ],
      );
}
