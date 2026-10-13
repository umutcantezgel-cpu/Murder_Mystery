import 'package:flutter/material.dart';

import '../../abend/einrichtung/abschnitte.dart';
import '../../stil/stil.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Einrichtung des Abends (F4-BAUMEISTER-01, Master 7.6, Schritt 2): Personen
/// und Spielernamen, Geburtstagskind, Detektiv oder Detektivin, Fall-Code oder
/// Zufall, Bildschirm- oder Druckspiel, Rundendauer und Erzählerstimme. Der
/// Startknopf richtet den Abend ein; das Geburtstagskind schaut dabei weg.
///
/// Dieser Bildschirm gehört zum alten Einstieg `/party`. Im Spiel wählt der
/// Assistent `/abend/neu` die Spielweise vorab und verwendet dieselben
/// Abschnitte (`abschnitte.dart`).
class EinrichtungBildschirm extends StatefulWidget {
  const EinrichtungBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<EinrichtungBildschirm> createState() => _EinrichtungBildschirmState();
}

class _EinrichtungBildschirmState extends State<EinrichtungBildschirm> {
  late final EinrichtungsWerte _werte = EinrichtungsWerte(widget.sitzung);

  PartySitzung get s => widget.sitzung;

  @override
  void dispose() {
    _werte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _werte,
        builder: (context, _) => PartyRahmen(
          marke: s.ui('ui.einrichtung.marke'),
          titel: s.ui('ui.einrichtung.titel'),
          untertitel: s.ui(_werte.solo ? 'ui.solo.einrichtung' : 'ui.einrichtung.hinweis'),
          aktionen: [PartyKnopf(text: s.ui('ui.einrichtung.start'), onPressed: _werte.codeOk ? _werte.starten : null)],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _formAbschnitt(),
              EinrichtungsAbschnitte(werte: _werte),
            ],
          ),
        ),
      );

  /// Party am Gerät oder Solo mit Bots (nur im alten Einstieg; der Assistent
  /// fragt vorab): zwei Ankreuzfelder, genau eines trägt den Tintenhaken.
  Widget _formAbschnitt() => EinrichtungsTafel(ueberschrift: s.ui('ui.solo.spielweise'), kinder: [
        _Spielweise(
          symbol: Icons.groups_2_outlined,
          child: MHaken(text: s.ui('ui.solo.party'), wert: !_werte.solo, onChanged: (_) => _werte.solo = false),
        ),
        _Spielweise(
          symbol: Icons.person_search_outlined,
          child: MHaken(text: s.ui('ui.solo.solo'), wert: _werte.solo, onChanged: (_) => _werte.solo = true),
        ),
      ]);
}

/// Eine Spielweise: Ankreuzfeld mit einem kleinen Sinnbild am Rand.
class _Spielweise extends StatelessWidget {
  const _Spielweise({required this.symbol, required this.child});

  final IconData symbol;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: child),
          const SizedBox(width: 10),
          ExcludeSemantics(child: Icon(symbol, size: 26, color: MFarben.von(context).papierLeise)),
        ],
      );
}
