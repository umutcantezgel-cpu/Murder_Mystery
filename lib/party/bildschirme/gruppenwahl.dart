import 'package:flutter/material.dart';

import '../party_stil.dart';
import '../sitzung.dart';

/// Gruppenwahl reihum und verdeckt (F4-BAUMEISTER-04, Master 7.8, E-025).
/// Jede besetzte Rolle wählt geheim zwischen zwei Handlungen; das
/// Geburtstagskind wählt nicht mit. Keine Ansicht zeigt eine Stimmenzahl oder
/// was jemand gewählt hat.
class GruppenwahlBildschirm extends StatefulWidget {
  const GruppenwahlBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<GruppenwahlBildschirm> createState() => _GruppenwahlBildschirmState();
}

class _GruppenwahlBildschirmState extends State<GruppenwahlBildschirm> {
  /// Gewählte Karte der verdeckten Ansicht: `true` ist A (kooperativ), `false` ist B.
  bool? _kooperativ;

  /// Der Bildschirm ist gerade zugedeckt worden; der Hinweis bleibt bis zur nächsten Person.
  bool _zugedecktEben = false;

  PartySitzung get s => widget.sitzung;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final v = s.verdeckt;
          return v == null ? _neutral() : _verdeckt(v);
        },
      );

  /// Neutrale Ansicht: Erklärung, wer dran ist, wer schon gewählt hat und wer noch fehlt.
  Widget _neutral() {
    final offen = s.offeneWaehler;
    final schon = [for (final r in s.besetzt) if (!offen.contains(r)) r];
    return PartyRahmen(
      marke: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
      titel: s.ui('ui.gruppenwahl.titel'),
      untertitel: s.ui(s.solo ? 'ui.solo.gruppenwahl' : 'ui.gruppenwahl.erklaerung'),
      aktionen: [
        if (s.alleGestimmt) PartyKnopf(text: s.ui('ui.allgemein.weiter'), onPressed: s.kannWeiter ? s.weiter : null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_zugedecktEben) ...[
            PartyTafel(child: Text(s.ui('ui.verdeckt.neutral'), style: Keller.leise)),
            const SizedBox(height: 16),
          ],
          offen.isEmpty ? PartyTafel(child: Text(s.ui('ui.gruppenwahl.alle'), style: Keller.ueberschrift)) : _naechste(offen.first),
          const SizedBox(height: 24),
          _gruppe(
            s.ui('ui.gruppenwahl.schon'),
            [for (final r in schon) _zeile(r, gewaehlt: true)],
            leer: s.ui('ui.gruppenwahl.niemand'),
          ),
          if (offen.isNotEmpty) ...[
            const SizedBox(height: 16),
            _gruppe(s.ui('ui.gruppenwahl.offen'), [for (final r in offen) _zeile(r, gewaehlt: false)]),
          ],
        ],
      ),
    );
  }

  /// Wer ist als Nächstes dran: Gerät weitergeben, dann ansehen.
  Widget _naechste(String r) => PartyTafel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.ui('ui.verdeckt.weitergeben', {'name': s.spielerName(r)}), style: Keller.text),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: PartyKnopf(
                text: s.ui('ui.verdeckt.frage', {'name': s.spielerName(r)}),
                icon: Icons.visibility_outlined,
                onPressed: () => _aufdecken(r),
              ),
            ),
          ],
        ),
      );

  /// Überschrift und Namen einer Gruppe; ohne Namen steht [leer] darunter.
  Widget _gruppe(String ueberschrift, List<Widget> zeilen, {String? leer}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ueberschrift.toUpperCase(), style: Keller.marke),
          const SizedBox(height: 8),
          if (zeilen.isEmpty && leer != null) Text(leer, style: Keller.leise),
          Wrap(spacing: 18, runSpacing: 10, children: zeilen),
        ],
      );

  /// Ein Name am Tisch. Der Schlüssel ist die Rolle.
  Widget _zeile(String r, {required bool gewaehlt}) => _NamenZeile(
        key: ValueKey(r),
        name: s.spielerName(r),
        farbe: s.figurFarbe(r),
        gewaehlt: gewaehlt,
        hinweis: gewaehlt ? s.ui('ui.gruppenwahl.hat_gewaehlt') : null,
      );

  /// Verdeckte Ansicht der Person [v]: zwei gleich breite Wahlkarten, A oben.
  Widget _verdeckt(String v) {
    final w = s.wahl(v);
    return PartyRahmen(
      marke: s.rundenName,
      titel: s.spielerName(v),
      untertitel: s.ui('ui.gruppenwahl.frage'),
      aktionen: [
        PartyKnopf(text: s.ui('ui.verdeckt.schliessen'), haupt: false, onPressed: _schliessen),
        PartyKnopf(text: s.ui('ui.gruppenwahl.bestaetigen'), onPressed: _kooperativ == null ? null : () => _bestaetigen(v)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WahlKarte(text: w.a, gewaehlt: _kooperativ == true, onTippen: () => setState(() => _kooperativ = true)),
          const SizedBox(height: 12),
          _WahlKarte(text: w.b, gewaehlt: _kooperativ == false, onTippen: () => setState(() => _kooperativ = false)),
          const SizedBox(height: 16),
          Text(s.ui('ui.gruppenwahl.tippen'), style: Keller.leise),
        ],
      ),
    );
  }

  /// Die gewählte Karte geht als Stimme ein; danach ist der Bildschirm zugedeckt.
  void _bestaetigen(String v) {
    final k = _kooperativ;
    if (k == null) return;
    setState(() {
      _kooperativ = null;
      _zugedecktEben = true;
    });
    s.stimme(v, kooperativ: k);
  }

  /// Zudecken ohne Wahl: Die Person bleibt offen.
  void _schliessen() {
    setState(() {
      _kooperativ = null;
      _zugedecktEben = true;
    });
    s.verdecken();
  }

  /// Die verdeckte Ansicht einer Person öffnen; eine Wahl von vorher ist vergessen.
  void _aufdecken(String r) {
    setState(() {
      _kooperativ = null;
      _zugedecktEben = false;
    });
    s.zeigeVerdeckt(r);
  }
}

/// Antippbare Wahlkarte. Die gewählte Karte bekommt einen warmen Rand und einen vollen Kreis.
class _WahlKarte extends StatelessWidget {
  const _WahlKarte({required this.text, required this.gewaehlt, required this.onTippen});

  final String text;
  final bool gewaehlt;
  final VoidCallback onTippen;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTippen,
        child: PartyTafel(
          akzent: gewaehlt ? Keller.kerze : Keller.linieStark,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(text, style: Keller.text)),
              const SizedBox(width: 12),
              Icon(
                gewaehlt ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: gewaehlt ? Keller.kerze : Keller.papierGedaempft,
              ),
            ],
          ),
        ),
      );
}

/// Ein Name am Tisch mit Farbpunkt: Häkchen (schon gewählt) oder leerer Kreis (noch offen).
class _NamenZeile extends StatelessWidget {
  const _NamenZeile({super.key, required this.name, required this.farbe, required this.gewaehlt, this.hinweis});

  final String name;
  final Color farbe;
  final bool gewaehlt;
  final String? hinweis;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FarbPunkt(farbe, groesse: 12),
          const SizedBox(width: 8),
          Flexible(child: Text(name, style: Keller.text)),
          const SizedBox(width: 8),
          Icon(
            gewaehlt ? Icons.check : Icons.radio_button_unchecked,
            size: 18,
            color: gewaehlt ? Keller.kerzeHell : Keller.papierGedaempft,
            semanticLabel: hinweis,
          ),
        ],
      );
}
