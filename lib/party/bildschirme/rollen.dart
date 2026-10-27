import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../klang/klang.dart';
import '../../stil/stil.dart';
import '../druck_tafel.dart';
import '../erzaehlerakte_ansicht.dart';
import '../party_stil.dart';
import '../sitzung.dart';
import 'detektiv_karte.dart';
import 'spickzettel.dart';

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

TextStyle _unterkopf(BuildContext context) => MPapierSchrift.ueberschrift.copyWith(fontSize: 17, height: 1.4);

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
    Klang.instanz.spiele('siegel');
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
          // Die Karte des Detektivs (M6): Einweisung, Regeln, Klasse, Befragungen.
          DetektivKarteEintrag(sitzung: s),
          const SizedBox(height: 16),
          // Erzählerakte (A-063): nur reihum mit Erzähler am Tisch, verdeckt wie ein Dossier.
          if (s.erzaehlerakteSichtbar) ...[
            ErzaehlerakteEintrag(sitzung: s),
            const SizedBox(height: 16),
          ],
          if (s.einstellungen.druck) ...[
            DruckTafel(sitzung: s),
            const SizedBox(height: 16),
          ] else if (!s.solo && s.daten.hat('druckspiel')) ...[
            // Abend am Bildschirm (M5): das Erzählerheft zum Vorlesen, ohne Druckspiel.
            DruckTafel(sitzung: s, druckspiel: false),
            const SizedBox(height: 16),
          ],
          if (_zugedeckt) ...[
            PartyTafel(akzent: context.farben.akzent, child: Text(s.ui('ui.verdeckt.neutral'), style: Keller.text)),
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

  /// Zwischenstufe: ein versiegelter Umschlag. Erst wenn die Person das Gerät
  /// hat, öffnet der Knopf die Karte.
  Widget _zwischenstufe(String rolle) {
    final name = s.spielerName(rolle);
    return MBlatt(
      art: PapierArt.telegramm,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      neigung: -0.006,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: MSiegel(kuerzel: AkteStil.fuer(s.daten.fall).sigel, farbe: context.farben.gefahr, groesse: 54)),
          const SizedBox(height: 16),
          Text(s.ui('ui.verdeckt.weitergeben', {'name': name}), style: MPapierSchrift.ueberschrift, textAlign: TextAlign.center),
          const SizedBox(height: 20),
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
    final nr = (s.besetzt.indexOf(rolle) + 1).toString().padLeft(2, '0');
    return PartyRahmen(
      marke: s.ui('ui.rollen.dossier_marke'),
      titel: s.figurName(rolle),
      untertitel: titel.isEmpty ? null : titel,
      aktionen: [PartyKnopf(text: s.ui('ui.verdeckt.schliessen'), onPressed: () => _schliessen(rolle))],
      child: MAktenmappe(
        reiter: 'Nr. $nr',
        farbe: s.figurFarbe(rolle),
        blaetter: 3,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MFotoabzug(look: s.figurAussehen(rolle), groesse: 76, neigung: -0.04, klammer: true, akzent: s.figurFarbe(rolle)),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _abschnittInhalt(s.ui('ui.rollen.wer_titel'), [Text(d.wer, style: MPapierSchrift.text)]),
                  ),
                ),
              ],
            ),
            _abschnitt(s.ui('ui.rollen.weiss_titel'), _zeilen(d.weiss)),
            _abschnitt(s.ui('ui.rollen.verbirgt_titel'), [
              if (kern) ...[Text(s.ui(taeter ? 'ui.rollen.taeter_satz' : 'ui.rollen.unschuldig_satz'), style: MPapierSchrift.kursiv), const SizedBox(height: 10)],
              if (taeter && tarnung != null) ..._taeterZeilen(d, tarnung),
              ..._zeilen(d.verbirgt),
            ]),
            _abschnitt(s.ui('ui.rollen.ziel_titel'), [Text(d.ziel, style: MPapierSchrift.text)]),
            if (s.befragungsmodell) ...[
              // Modell befragung (A-051): Bei der Rollenübergabe nur die Notizen der ersten Runde,
              // die übrigen zeigt der Spickzettel in der Runde selbst.
              SpickzettelInhalt(sitzung: s, rolle: rolle, runde: 1),
              const SizedBox(height: 10),
              Text(s.ui('ui.befragung.runde_eins'), style: MPapierSchrift.leise),
            ] else
              _abschnitt(s.ui('ui.rollen.gespraeche_titel'), _gespraeche(d)),
            _abschnitt(s.ui('ui.rollen.wahl_titel'), _wahlen(d)),
            _abschnitt(s.ui('ui.rollen.besetzung_titel'), [Text(d.besetzung, style: MPapierSchrift.leise)]),
          ],
        ),
      ),
    );
  }

  /// Nur für die Täterin oder den Täter: die Tarngeschichte und das wirkliche
  /// Geschehen, gesetzt wie die übrigen Zeilen des Abschnitts.
  List<Widget> _taeterZeilen(Dossier d, String tarnung) => [
        Text(s.ui('ui.rollen.taeter_tarnung'), style: MPapierSchrift.leise),
        Text(tarnung, style: MPapierSchrift.text),
        const SizedBox(height: 10),
        Text(s.ui('ui.rollen.taeter_tatwissen'), style: MPapierSchrift.leise),
        ..._zeilen(d.tatwissen),
      ];

  /// Ein Abschnitt des Dossiers: Formularkopf in Schreibmaschine, darunter der Inhalt.
  Widget _abschnitt(String titel, List<Widget> kinder) => Padding(
        padding: const EdgeInsets.only(top: 22),
        child: _abschnittInhalt(titel, kinder),
      );

  Widget _abschnittInhalt(String titel, List<Widget> kinder) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titel, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, fontSize: 15)),
          const SizedBox(height: 4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          ...kinder,
        ],
      );

  /// Zeilen des Dossiers. Eine Lüge zeigt erst die Behauptung, dann die Wahrheit.
  List<Widget> _zeilen(List<DossierZeile> zeilen) => [
        for (final z in zeilen) Padding(padding: const EdgeInsets.only(bottom: 10), child: _zeile(z)),
      ];

  Widget _zeile(DossierZeile z) {
    final behauptung = z.behauptung;
    if (z.art != 'luege' || behauptung == null) return Text(z.text, style: MPapierSchrift.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.ui('ui.rollen.luege_behauptung'), style: MPapierSchrift.leise),
        Text(behauptung, style: MPapierSchrift.kursiv),
        const SizedBox(height: 4),
        Text(s.ui('ui.rollen.luege_wahrheit'), style: MPapierSchrift.leise),
        Text(z.text, style: MPapierSchrift.hand.copyWith(fontSize: 20)),
      ],
    );
  }

  /// Die Pflichtgespräche, je Runde eine Überschrift.
  List<Widget> _gespraeche(Dossier d) => [
        for (final r in _runden) ...[
          Text(s.ui('ui.allgemein.runde', {'nr': '$r'}), style: MPapierSchrift.marke),
          const SizedBox(height: 8),
          for (final (g, partner) in d.gespraeche[r] ?? const <(Gespraech, String)>[])
            Padding(padding: const EdgeInsets.only(bottom: 14), child: _gespraech(g, partner)),
        ],
      ];

  /// Ein Pflichtgespräch: mit wem, Thema, Ziel und der Eröffnungssatz der Rolle.
  Widget _gespraech(Gespraech g, String partner) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.ui('ui.rollen.gespraech_mit', {'name': s.personAmTisch(partner)}), style: _unterkopf(context)),
          const SizedBox(height: 4),
          Text(s.ui('ui.rollen.gespraech_thema'), style: MPapierSchrift.leise),
          Text(g.thema, style: MPapierSchrift.text),
          const SizedBox(height: 4),
          Text(s.ui('ui.rollen.gespraech_ziel'), style: MPapierSchrift.leise),
          Text(g.ziel, style: MPapierSchrift.text),
          const SizedBox(height: 4),
          Text(s.ui('ui.rollen.gespraech_eroeffnung'), style: MPapierSchrift.leise),
          Text(g.text, style: MPapierSchrift.kursiv),
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
        Text(s.ui('ui.allgemein.runde', {'nr': '$runde'}), style: MPapierSchrift.marke),
        const SizedBox(height: 8),
        Text(s.ui('ui.rollen.wahl_a'), style: MPapierSchrift.leise),
        Text(w.a, style: MPapierSchrift.text),
        const SizedBox(height: 6),
        Text(s.ui('ui.rollen.wahl_b'), style: MPapierSchrift.leise),
        Text(w.b, style: MPapierSchrift.text),
        if (sabotage != null) ...[
          const SizedBox(height: 6),
          Text(s.ui('ui.rollen.wahl_sabotage'), style: MPapierSchrift.leise),
          Text(sabotage, style: MPapierSchrift.text),
        ],
      ],
    );
  }
}

/// Eine Karteikarte der neutralen Liste: Fotoabzug der Figur, Spielername und
/// Figur, ein grüner Haken nach dem Sehen.
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
    final nr = sitzung.besetzt.indexOf(rolle);
    return Semantics(
      button: onTap != null,
      child: MBlatt(
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        onTap: onTap,
        randFarbe: sitzung.figurFarbe(rolle),
        neigung: nr.isEven ? -0.003 : 0.003,
        samen: nr + 3,
        padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
        child: Row(
          children: [
            MFotoabzug(look: sitzung.figurAussehen(rolle), groesse: 52, neigung: nr.isEven ? -0.05 : 0.04, akzent: sitzung.figurFarbe(rolle)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sitzung.spielerName(rolle), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 19)),
                  if (figur.isNotEmpty) Text(figur, style: MPapierSchrift.leise),
                ],
              ),
            ),
            if (gesehen) Icon(Icons.check_circle, color: const Color(0xFF2F6B37), semanticLabel: sitzung.ui('ui.rollen.gesehen')),
          ],
        ),
      ),
    );
  }
}
