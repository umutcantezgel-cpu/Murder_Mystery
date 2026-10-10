import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../druck_tafel.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Verdeckte Rollenvergabe und Dossier (F4-BAUMEISTER-02, Master 7.6 Schritt 3, 7.11).
///
/// Neutral zeigt der Bildschirm nur Namen und Figuren. Ein Tipp führt zuerst zu
/// „Gib das Gerät an …“; erst der Knopf darunter öffnet das Dossier der Rolle.
/// Nach dem Schließen ist der Bildschirm wieder neutral. Welche Karten gesehen
/// wurden, merkt sich nur dieser Bildschirm.
class RollenBildschirm extends StatefulWidget {
  const RollenBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  @override
  State<RollenBildschirm> createState() => _RollenBildschirmState();
}

/// Runden des Abends; Gespräche und Wahlen stehen je Runde im Dossier.
const _runden = [1, 2, 3];

/// Wie lange die Meldung „wieder zugedeckt“ über der Liste stehen bleibt.
const _meldungDauer = Duration(seconds: 4);

const _unterkopf = TextStyle(fontFamily: Keller.schrift, fontSize: 17, height: 1.5, fontWeight: FontWeight.w700, color: Keller.kerzeHell);

class _RollenBildschirmState extends State<RollenBildschirm> {
  /// Rollen, deren Karte schon gesehen wurde.
  final Set<String> _gesehen = {};

  /// Rolle, deren Zwischenstufe („Gib das Gerät an …“) gerade offen ist.
  String? _vorbereitet;

  /// Kurz nach dem Schließen wahr: die Meldung „wieder zugedeckt“.
  bool _zugedeckt = false;
  Timer? _meldungTimer;

  PartySitzung get s => widget.sitzung;

  @override
  void dispose() {
    _meldungTimer?.cancel();
    super.dispose();
  }

  /// Zwischenstufe öffnen: Das Gerät geht an diese Person.
  void _vorbereiten(String rolle) => setState(() => _vorbereitet = rolle);

  /// Die Karte zeigen; ab jetzt sieht nur diese Person das Dossier.
  void _zeigen(String rolle) {
    setState(() => _vorbereitet = null);
    s.zeigeVerdeckt(rolle);
  }

  /// Dossier zudecken, die Rolle als gesehen merken und kurz melden.
  void _schliessen(String rolle) {
    _meldungTimer?.cancel();
    _meldungTimer = Timer(_meldungDauer, () {
      if (mounted) setState(() => _zugedeckt = false);
    });
    setState(() {
      _gesehen.add(rolle);
      _zugedeckt = true;
    });
    s.verdecken();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final v = s.verdeckt;
          return v == null ? _neutral() : _verdeckt(v);
        },
      );

  // Neutrale Ansicht -----------------------------------------------------------

  /// Erklärung, Liste aller Rollen und der Weiter-Knopf für die Gruppe.
  Widget _neutral() {
    final vorbereitet = _vorbereitet;
    return PartyRahmen(
      marke: s.ui('ui.rollen.marke'),
      titel: s.ui('ui.rollen.titel'),
      aktionen: [PartyKnopf(text: s.ui('ui.rollen.weiter'), onPressed: s.weiter)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.ui(s.solo ? 'ui.solo.rollen_start' : 'ui.rollen.erklaerung'), style: Keller.text),
          const SizedBox(height: 16),
          if (s.einstellungen.druck) ...[
            DruckTafel(sitzung: s),
            const SizedBox(height: 16),
          ],
          if (_zugedeckt) ...[
            PartyTafel(akzent: Keller.kerze, child: Text(s.ui('ui.verdeckt.neutral'), style: Keller.text)),
            const SizedBox(height: 16),
          ],
          if (vorbereitet == null) _liste() else _zwischenstufe(vorbereitet),
        ],
      ),
    );
  }

  /// Alle besetzten Rollen: Farbpunkt, Spielername, Figur und Häkchen nach dem Sehen.
  Widget _liste() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in s.besetzt)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RollenZeile(sitzung: s, rolle: r, gesehen: _gesehen.contains(r), onTap: s.solo ? null : () => _vorbereiten(r)),
            ),
        ],
      );

  /// Zwischenstufe: Erst wenn die Person das Gerät hat, öffnet der Knopf die Karte.
  Widget _zwischenstufe(String rolle) {
    final name = s.spielerName(rolle);
    return PartyTafel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.ui('ui.verdeckt.weitergeben', {'name': name}), style: Keller.ueberschrift),
          const SizedBox(height: 18),
          PartyKnopf(text: s.ui('ui.verdeckt.frage', {'name': name}), onPressed: () => _zeigen(rolle)),
          const SizedBox(height: 10),
          PartyKnopf(text: s.ui('ui.allgemein.zurueck'), haupt: false, onPressed: () => setState(() => _vorbereitet = null)),
        ],
      ),
    );
  }

  // Verdeckte Ansicht ----------------------------------------------------------

  /// Das Dossier der Rolle, nur für diese Person. Die Täterfassung steht wie im
  /// Druck unter „Was ich verberge“, ohne eigene Tafel und ohne eigene Farbe: Ein
  /// Blick über die Schulter verrät nicht, wer es war (F6-SICHT-04, E-041).
  Widget _verdeckt(String rolle) {
    final d = s.dossier(rolle);
    final taeter = s.istTaeter(rolle);
    final kern = s.kernverdaechtige.contains(rolle);
    final tarnung = d.tarnung;
    final titel = s.figurTitel(rolle);
    return PartyRahmen(
      marke: s.ui('ui.rollen.dossier_marke'),
      titel: s.figurName(rolle),
      untertitel: titel.isEmpty ? null : titel,
      aktionen: [PartyKnopf(text: s.ui('ui.verdeckt.schliessen'), onPressed: () => _schliessen(rolle))],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _abschnitt(s.ui('ui.rollen.wer_titel'), [Text(d.wer, style: Keller.text)]),
          _abschnitt(s.ui('ui.rollen.weiss_titel'), _zeilen(d.weiss)),
          _abschnitt(s.ui('ui.rollen.verbirgt_titel'), [
            if (kern) ...[Text(s.ui(taeter ? 'ui.rollen.taeter_satz' : 'ui.rollen.unschuldig_satz'), style: Keller.text), const SizedBox(height: 10)],
            if (taeter && tarnung != null) ..._taeterZeilen(d, tarnung),
            ..._zeilen(d.verbirgt),
          ]),
          _abschnitt(s.ui('ui.rollen.ziel_titel'), [Text(d.ziel, style: Keller.text)]),
          _abschnitt(s.ui('ui.rollen.gespraeche_titel'), _gespraeche(d)),
          _abschnitt(s.ui('ui.rollen.wahl_titel'), _wahlen(d)),
          _abschnitt(s.ui('ui.rollen.besetzung_titel'), [Text(d.besetzung, style: Keller.leise)]),
        ],
      ),
    );
  }

  /// Nur für die Täterin oder den Täter: die Tarngeschichte und das wirkliche
  /// Geschehen, gesetzt wie die übrigen Zeilen des Abschnitts.
  List<Widget> _taeterZeilen(Dossier d, String tarnung) => [
        Text(s.ui('ui.rollen.taeter_tarnung'), style: Keller.leise),
        Text(tarnung, style: Keller.text),
        const SizedBox(height: 10),
        Text(s.ui('ui.rollen.taeter_tatwissen'), style: Keller.leise),
        ..._zeilen(d.tatwissen),
      ];

  /// Ein Abschnitt des Dossiers: Überschrift, darunter der Inhalt, in einer Tafel.
  Widget _abschnitt(String titel, List<Widget> kinder) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: PartyTafel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(titel, style: Keller.ueberschrift),
              const SizedBox(height: 12),
              ...kinder,
            ],
          ),
        ),
      );

  /// Zeilen des Dossiers. Eine Lüge zeigt erst die Behauptung, dann die Wahrheit.
  List<Widget> _zeilen(List<DossierZeile> zeilen) => [
        for (final z in zeilen) Padding(padding: const EdgeInsets.only(bottom: 10), child: _zeile(z)),
      ];

  Widget _zeile(DossierZeile z) {
    final behauptung = z.behauptung;
    if (z.art != 'luege' || behauptung == null) return Text(z.text, style: Keller.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.ui('ui.rollen.luege_behauptung'), style: Keller.leise),
        Text(behauptung, style: Keller.text),
        const SizedBox(height: 4),
        Text(s.ui('ui.rollen.luege_wahrheit'), style: Keller.leise),
        Text(z.text, style: Keller.text),
      ],
    );
  }

  /// Die Pflichtgespräche, je Runde eine Überschrift.
  List<Widget> _gespraeche(Dossier d) => [
        for (final r in _runden) ...[
          Text(s.ui('ui.allgemein.runde', {'nr': '$r'}), style: Keller.marke),
          const SizedBox(height: 8),
          for (final (g, partner) in d.gespraeche[r] ?? const <(Gespraech, String)>[])
            Padding(padding: const EdgeInsets.only(bottom: 14), child: _gespraech(g, partner)),
        ],
      ];

  /// Ein Pflichtgespräch: mit wem, Thema, Ziel und der Eröffnungssatz der Rolle.
  Widget _gespraech(Gespraech g, String partner) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.ui('ui.rollen.gespraech_mit', {'name': s.personAmTisch(partner)}), style: _unterkopf),
          const SizedBox(height: 4),
          Text(s.ui('ui.rollen.gespraech_thema'), style: Keller.leise),
          Text(g.thema, style: Keller.text),
          const SizedBox(height: 4),
          Text(s.ui('ui.rollen.gespraech_ziel'), style: Keller.leise),
          Text(g.ziel, style: Keller.text),
          const SizedBox(height: 4),
          Text(s.ui('ui.rollen.gespraech_eroeffnung'), style: Keller.leise),
          Text(g.text, style: Keller.text),
        ],
      );

  /// Die Rundenwahl je Runde. Die Sabotage steht nur da, wo es sie in dieser Fassung gibt.
  List<Widget> _wahlen(Dossier d) => [
        for (final r in _runden)
          if (d.wahlen[r] case final w?) Padding(padding: const EdgeInsets.only(bottom: 14), child: _wahl(r, w)),
      ];

  Widget _wahl(int runde, WahlText w) {
    final sabotage = w.sabotage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.ui('ui.allgemein.runde', {'nr': '$runde'}), style: Keller.marke),
        const SizedBox(height: 8),
        Text(s.ui('ui.rollen.wahl_a'), style: Keller.leise),
        Text(w.a, style: Keller.text),
        const SizedBox(height: 6),
        Text(s.ui('ui.rollen.wahl_b'), style: Keller.leise),
        Text(w.b, style: Keller.text),
        if (sabotage != null) ...[
          const SizedBox(height: 6),
          Text(s.ui('ui.rollen.wahl_sabotage'), style: Keller.leise),
          Text(sabotage, style: Keller.text),
        ],
      ],
    );
  }
}

/// Eine Zeile der neutralen Liste: Farbe, Spielername und Figur, Häkchen nach dem Sehen.
class _RollenZeile extends StatelessWidget {
  const _RollenZeile({required this.sitzung, required this.rolle, required this.gesehen, required this.onTap});

  final PartySitzung sitzung;
  final String rolle;
  final bool gesehen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Ohne eingetragenen Spielernamen steht der Figurenname schon oben: dann nur der Titel.
    final name = sitzung.spielerName(rolle) == sitzung.figurName(rolle) ? '' : sitzung.figurName(rolle);
    final figur = [name, sitzung.figurTitel(rolle)].where((t) => t.isNotEmpty).join(' · ');
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: PartyTafel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            FarbPunkt(sitzung.figurFarbe(rolle)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sitzung.spielerName(rolle), style: Keller.text),
                  Text(figur, style: Keller.leise),
                ],
              ),
            ),
            if (gesehen) Icon(Icons.check_circle, color: Keller.notlicht, semanticLabel: sitzung.ui('ui.rollen.gesehen')),
          ],
        ),
      ),
    );
  }
}
