import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show Besetzung, LookDef;
import 'package:mordakte_core/runden.dart' show Sitz;

import '../../l10n/lookup.dart';
import '../../party/erzaehlerakte_ansicht.dart' show zeigeErzaehlerakte;
import '../../stil/mappe/online_bausteine.dart';
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_ansicht.dart' show GastKontext;
import 'gast_dienst.dart';
import 'online_teile.dart';

/// Was der Erzähler online neben dem Text braucht (Langer Abend M3): das
/// pfadfreie Erzählerpaket der Runde (privat `erzaehlerPaket`, A-052) mit allen
/// Tisch-Stichpunkten, den Befragungen samt Antwort und dem Wissen ungespielter
/// Gäste, dazu wen der Detektiv gerade befragt (öffentlich). Nie Dossier,
/// Tatwissen, Tarnung, Pfad oder Qualität: Das Paket enthält sie nicht.
///
/// Für den Gast auf dem Erzähler-Sitz; der Gastgeber als Erzähler nutzt
/// [ErzaehlerPaketAnsicht] im Pult (`erzaehler_ablauf.dart`).
List<Widget> gastErzaehlerTeile(GastKontext c) {
  final paket = c.privat['erzaehlerPaket'] is Map ? jMap(c.privat['erzaehlerPaket']) : null;
  final befragungen = jMaps(c.v['befragungen']);
  return [
    // Die Erzählerakte (A-063) aus der Akte dieses Geräts, nur auf dem Erzähler-Sitz.
    if (gastErzaehlerakteErlaubt(c.dienst))
      Padding(
        padding: const EdgeInsets.only(bottom: MMass.s16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: MKnopf(
            key: const ValueKey('erzaehlerakte-knopf'),
            text: c.l.erzaehlerakte_titel,
            art: MKnopfArt.zweit,
            icon: Icons.folder_shared_outlined,
            onPressed: () => gastErzaehlerakteZeigen(c),
          ),
        ),
      ),
    if (befragungen.isNotEmpty) BefragungsStand(befragungen: befragungen, person: c.personAmTisch, erledigtText: c.l.party_befragung_erledigt),
    if (paket != null && const {'gespraeche', 'entscheidungen', 'gruppenwahl', 'bonus', 'resuemee'}.contains(c.phase))
      ErzaehlerPaketAnsicht(
        key: ValueKey('erzaehlerpaket-${c.runde}'),
        paket: paket,
        person: c.personAmTisch,
        aussehen: c.aussehen,
        offen: c.phase == 'gespraeche',
      ),
  ];
}

/// Wen der Detektiv in dieser Runde befragt, mit Haken für erledigte (öffentlich:
/// nur Person und Thema). So weiß der Erzähler, wann es weitergehen kann.
class BefragungsStand extends StatelessWidget {
  const BefragungsStand({super.key, required this.befragungen, required this.person, required this.erledigtText});

  final List<Map<String, Object?>> befragungen;
  final String Function(String figur) person;
  final String erledigtText;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: MBlatt(
        art: PapierArt.notiz,
        samen: 71,
        neigung: 0.003,
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.party_befragung_oeffentlich.toUpperCase(), style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
            const SizedBox(height: MMass.s8),
            for (final b in befragungen)
              Padding(
                padding: const EdgeInsets.only(bottom: MMass.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MGanzeWorte(person(jText(b['rolle'])), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
                          if (jText(b['thema']).isNotEmpty) MGanzeWorte(jText(b['thema']), stil: MPapierSchrift.maschine.copyWith(fontSize: 14), minimum: 10),
                        ],
                      ),
                    ),
                    if (b['erledigt'] == true) Icon(Icons.check_rounded, color: MRoh.stempelRot, semanticLabel: erledigtText),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Das Erzählerpaket einer Runde (JSON aus `ErzaehlerPaket.toJson`) als
/// aufklappbare Abschnitte: „Am Tisch“ (wer mit wem, Thema, Stichpunkte),
/// „Befragungen“ (fest oder frei, Fragen, Antwort in der dritten Person) und
/// „Ungespielte Gäste“ (was der Erzähler über sie vorliest). Jede Karte nach
/// R17; die Stichpunkte stehen so im Kanon.
class ErzaehlerPaketAnsicht extends StatelessWidget {
  const ErzaehlerPaketAnsicht({super.key, required this.paket, required this.person, required this.aussehen, this.offen = false});

  final Map<String, Object?> paket;
  final String Function(String figur) person;
  final LookDef? Function(String figur) aussehen;

  /// Ist „Am Tisch“ anfangs aufgeklappt (in den Gesprächen)?
  final bool offen;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final tisch = jMaps(paket['tisch']);
    final befragungen = jMaps(paket['befragungen']);
    final npc = jMaps(paket['npc']);
    final frei = jZahl(paket['freiWahlen']);
    return Column(
      key: const ValueKey('erzaehlerpaket'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnlineRegisterKopf(l.erzaehler_paket_titel.toUpperCase()),
        if (tisch.isNotEmpty)
          _Aufklapp(
            titel: '${l.erzaehler_paket_tisch} (${tisch.length})',
            offen: offen,
            kinder: [
              for (var i = 0; i < tisch.length; i++)
                _Karte(
                  nr: i,
                  bild: aussehen(jText(tisch[i]['sprecher'])),
                  kopf: l.erzaehler_paket_mit(person(jText(tisch[i]['sprecher'])), person(jText(tisch[i]['partner']))),
                  unter: jText(tisch[i]['thema']),
                  punkte: jTexte(tisch[i]['stichpunkte']),
                ),
            ],
          ),
        if (befragungen.isNotEmpty)
          _Aufklapp(
            titel: '${l.erzaehler_paket_befragungen} (${befragungen.length})',
            kinder: [
              if (frei > 0) Padding(padding: const EdgeInsets.only(bottom: MMass.s8), child: Text(l.erzaehler_paket_frei(frei), style: MPapierSchrift.leise)),
              for (var i = 0; i < befragungen.length; i++)
                _Karte(
                  nr: i,
                  bild: aussehen(jText(befragungen[i]['rolle'])),
                  kopf: person(jText(befragungen[i]['rolle'])),
                  marke: befragungen[i]['pflicht'] == true ? l.erzaehler_paket_pflicht : null,
                  unter: jText(befragungen[i]['thema']),
                  punkte: jTexte(befragungen[i]['fragen']),
                  punkteTitel: l.erzaehler_paket_fragen,
                  antwort: jTexte(befragungen[i]['antwort']),
                  antwortTitel: l.erzaehler_paket_antwort,
                ),
            ],
          ),
        if (npc.isNotEmpty)
          _Aufklapp(
            titel: '${l.erzaehler_paket_npc} (${npc.length})',
            kinder: [
              for (var i = 0; i < npc.length; i++)
                _Karte(nr: i, bild: aussehen(jText(npc[i]['figur'])), kopf: person(jText(npc[i]['figur'])), text: jText(npc[i]['text'])),
            ],
          ),
      ],
    );
  }
}

/// Ein aufklappbarer Abschnitt des Pakets: Kopfzeile mit Pfeil, darunter die Karten.
class _Aufklapp extends StatefulWidget {
  const _Aufklapp({required this.titel, required this.kinder, this.offen = false});

  final String titel;
  final List<Widget> kinder;
  final bool offen;

  @override
  State<_Aufklapp> createState() => _AufklappState();
}

class _AufklappState extends State<_Aufklapp> {
  late bool _offen = widget.offen;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              expanded: _offen,
              child: MBlatt(
                art: PapierArt.karteikarte,
                kopfLinie: 7,
                linien: false,
                neigung: -0.002,
                samen: widget.titel.length,
                onTap: () => setState(() => _offen = !_offen),
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    Expanded(child: MGanzeWorte(widget.titel, stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18))),
                    Icon(_offen ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: MRoh.tinte),
                  ],
                ),
              ),
            ),
            if (_offen) ...[const SizedBox(height: MMass.s8), ...widget.kinder],
          ],
        ),
      );
}

/// Eine Karte des Pakets: Fotoabzug, Kopf, Thema, Stichpunkte (höchstens drei
/// je Karte im Kanon), optional Antwort oder ein Vorlesetext.
class _Karte extends StatelessWidget {
  const _Karte({
    required this.nr,
    required this.bild,
    required this.kopf,
    this.marke,
    this.unter = '',
    this.punkte = const [],
    this.punkteTitel,
    this.antwort = const [],
    this.antwortTitel,
    this.text = '',
  });

  final int nr;
  final LookDef? bild;
  final String kopf;
  final String? marke;
  final String unter;
  final List<String> punkte;
  final String? punkteTitel;
  final List<String> antwort;
  final String? antwortTitel;
  final String text;

  @override
  Widget build(BuildContext context) {
    Widget punkt(String p) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 9, right: 8), child: SizedBox(width: 5, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: MRoh.tinte, shape: BoxShape.circle)))),
              Expanded(child: MGanzeWorte(p, stil: MPapierSchrift.text, minimum: 12)),
            ],
          ),
        );
    final foto = bild;
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: MBlatt(
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        neigung: nr.isEven ? -0.003 : 0.003,
        samen: 120 + nr,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            MOnlineBildZeile(
              bild: foto != null ? MFotoabzug(look: foto, groesse: 40, neigung: nr.isEven ? -0.05 : 0.04) : MOnlineSilhouette(groesse: 40, samen: nr),
              text: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MGanzeWorte(kopf, stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
                  if (marke != null) Text(marke!.toUpperCase(), style: MPapierSchrift.marke),
                  if (unter.isNotEmpty) MGanzeWorte(unter, stil: MPapierSchrift.maschine.copyWith(fontSize: 14), minimum: 10),
                ],
              ),
            ),
            if (punkte.isNotEmpty) ...[
              const SizedBox(height: MMass.s8),
              if (punkteTitel != null) Text(punkteTitel!, style: MPapierSchrift.leise),
              for (final p in punkte) punkt(p),
            ],
            if (antwort.isNotEmpty) ...[
              const SizedBox(height: MMass.s4),
              if (antwortTitel != null) Text(antwortTitel!, style: MPapierSchrift.leise),
              for (final p in antwort) punkt(p),
            ],
            if (text.isNotEmpty) ...[
              const SizedBox(height: MMass.s8),
              MGanzeWorte(text, stil: MPapierSchrift.erzaehler, minimum: 14),
            ],
          ],
        ),
      ),
    );
  }
}

/// Darf das Gerät eines Gastes die Erzählerakte zeigen (A-063)? Nur auf dem
/// Erzähler-Sitz (auch das Erzähler-Handy reihum), ab den Rollen und vor dem
/// Finale, nie wenn es ermittelt. Die Akte kommt aus der Akte des Geräts.
bool gastErzaehlerakteErlaubt(GastDienst d) {
  final v = d.ansicht;
  final phase = jText(v['phase'], 'lobby');
  if (d.daten?.erzaehlerakte == null || const {'lobby', 'finale', 'aufloesung', 'ende'}.contains(phase)) return false;
  if (jMap(v['privat'])['detektiv'] == true) return false;
  return spielerAusAnsicht(v).where((s) => s.id == d.spielerId).firstOrNull?.sitz == Sitz.erzaehler;
}

/// Spielt der Abend dieses Gastes „Dein Moment“? Online trägt die Ansicht dann
/// `einfluss` (ab den Rollen); am Erzähler-Handy reihum sagt es der Begleiter
/// privat (`deinMoment`), ohne die öffentliche Lage zu schicken.
bool gastMitMoment(GastDienst d) => d.ansicht['einfluss'] is Map || jMap(d.ansicht['privat'])['deinMoment'] == true;

/// Besetzte Figuren und Personenzahl für „Als PDF“ in der Erzählerakte eines
/// Gastes: mit der Rollenzahl [n] des Raums deren Besetzung. Ohne passende Zahl
/// (Erzähler-Handy reihum nach der Einstimmung) die gespielten Figuren
/// [gespielt] in Besetzungsreihenfolge; eine Personenzahl nur, wenn sie genau
/// die Besetzung ihrer Zahl sind, sonst `null` (kein Knopf).
({List<String> besetzt, int? rollen}) gastAkteBesetzung(Besetzung b, int n, Iterable<String?> gespielt) {
  if (n >= b.minRollen && n <= b.maxRollen) return (besetzt: b.besetzt(n), rollen: n);
  final rollen = gespielt.toSet();
  final besetzt = [for (final r in b.reihenfolge) if (rollen.contains(r)) r];
  final m = besetzt.length;
  return (besetzt: besetzt, rollen: m >= b.minRollen && m <= b.maxRollen && b.besetzt(m).join(',') == besetzt.join(',') ? m : null);
}

/// Öffnet die Erzählerakte für den Gast auf dem Erzähler-Sitz: besetzt sind die
/// Figuren der Rollenzahl des Raums, gespielt von den Gästen mit Figur. Mit
/// „Dein Moment“ stehen die Sterne als Ziele, sonst die des Kanons. Sie
/// schließt sich, sobald sie nicht mehr gilt (Finale, Sitz gewechselt). „Als
/// PDF“ gibt es mit der Rollenzahl des Raums, wenn sie zur Besetzung passt.
/// Fehlt sie in der Ansicht (Erzähler-Handy reihum nach der Einstimmung), gilt
/// die Zahl der gespielten Figuren, wenn sie genau die Besetzung dieser Zahl
/// sind; sonst gibt es keinen Knopf.
Future<void> gastErzaehlerakteZeigen(GastKontext c) {
  final d = c.daten!;
  final spieler = c.spieler;
  final (:besetzt, :rollen) = gastAkteBesetzung(d.texte.besetzung, jZahl(c.v['rollen']), [for (final s in spieler) s.rolle]);
  return zeigeErzaehlerakte(
    c.context,
    daten: d,
    besetzt: besetzt,
    einfluss: gastMitMoment(c.dienst),
    rollen: rollen,
    spieler: (f) => spieler.where((s) => s.rolle == f).firstOrNull?.name,
    wache: c.dienst,
    erlaubt: () => gastErzaehlerakteErlaubt(c.dienst),
  );
}
