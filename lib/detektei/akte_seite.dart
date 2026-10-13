import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/mordakte_core.dart' show LookDef;
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../l10n/lookup.dart';
import '../meta/meta_store.dart';
import '../stil/stil.dart';
import 'akte_bausteine.dart';
import 'akten.dart';
import 'schreibtisch.dart' show GanzeWorte;

/// Enden, an denen die Anklage stimmte (`content/party/<akte>/fall.json`).
const _geloesteEnden = {'ende_meister', 'ende_teilerfolg'};

/// Seite einer Akte (Route `/akte/:id`): die ganze Fallakte.
///
/// - Deckblatt in der Aktenmappe: Aktenzeichen, Tatortfoto, Titel, Untertitel,
///   Marken und der Stempel „Ungelöst“ (oder „Gelöst“, wenn auf diesem Gerät ein
///   Abend der Akte mit richtiger Anklage endete).
/// - „Die Lage“: Schauplatz, Anlass, Zeitpunkt, die Stimmung als Randnotizen.
/// - „Personen“: das Opfer und die Besetzung als Fotoabzüge mit Name und Rolle.
///
/// Alles stammt aus öffentlichen Feldern ([AkteAuszug]); kein Blatt verrät,
/// wer als Täter in Frage kommt. Unten führt der Weg in den Assistenten, bei
/// Akten mit Druckfassung auch zur Druckmappe.
class AkteSeite extends StatefulWidget {
  const AkteSeite({super.key, required this.akteId});

  final String akteId;

  @override
  State<AkteSeite> createState() => _AkteSeiteState();
}

class _AkteSeiteState extends State<AkteSeite> {
  late Future<List<AkteInfo>> _akten = AktenKatalog.laden();
  late final Future<AkteAuszug> _auszug = AkteAuszug.laden(widget.akteId);

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AkteThema(
      akte: widget.akteId,
      child: Builder(
        builder: (context) {
          final f = MFarben.von(context);
          final zurueck = MKnopf(
            text: l.common_back,
            art: MKnopfArt.zweit,
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go(Routes.start),
          );
          return Scaffold(
            backgroundColor: f.grund,
            body: FutureBuilder<List<AkteInfo>>(
              future: _akten,
              builder: (context, snap) {
                if (snap.hasError) {
                  return MRahmen(
                    aktionen: [zurueck],
                    child: MBlatt(
                      art: PapierArt.notiz,
                      neigung: -0.006,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l.detektei_akten_fehler, style: MPapierSchrift.text),
                          const SizedBox(height: MMass.s12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: MKnopf(text: l.detektei_nochmal, art: MKnopfArt.zweit, onPressed: () => setState(() => _akten = AktenKatalog.laden())),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final liste = snap.data;
                if (liste == null) return const SizedBox.shrink();
                final index = liste.indexWhere((a) => a.id == widget.akteId);
                if (index < 0) {
                  return MRahmen(
                    aktionen: [zurueck],
                    child: MBlatt(
                      art: PapierArt.notiz,
                      neigung: 0.005,
                      child: Text(l.detektei_akte_unbekannt, style: MPapierSchrift.text),
                    ),
                  );
                }
                final akte = liste[index];
                return MRahmen(
                  aktionen: [
                    zurueck,
                    if (akte.druckbar)
                      MKnopf(
                        text: l.detektei_akte_druckmappe,
                        art: MKnopfArt.zweit,
                        icon: Icons.print_rounded,
                        onPressed: () => context.go(Routes.druckmappeVon(akte.id)),
                      ),
                    MKnopf(
                      text: l.detektei_akte_spielen,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => context.go(Routes.abendNeuMit(akte.id)),
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: MMass.s8),
                      _Deckblatt(akte: akte, index: index),
                      FutureBuilder<AkteAuszug>(
                        future: _auszug,
                        builder: (context, snap) {
                          final a = snap.data;
                          if (a == null || a.leer) return const SizedBox.shrink();
                          final lage = a.lage;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (lage != null) ...[const SizedBox(height: MMass.s32), _LageBlatt(akte: akte, lage: lage)],
                              if (a.personen.isNotEmpty || a.opfer != null) ...[
                                const SizedBox(height: MMass.s32),
                                _PersonenBlatt(akte: akte, auszug: a),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: MMass.s16),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Das Deckblatt der Akte in ihrer Mappe.
class _Deckblatt extends StatelessWidget {
  const _Deckblatt({required this.akte, required this.index});

  final AkteInfo akte;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final stil = AkteStil.fuer(akte.id);
    final nr = akteNummer(index);
    final stand = context.watch<MetaStore>().akten[akte.id];
    final geloest = stand != null && stand.enden.any(_geloesteEnden.contains);
    final stempel = MStempel(
      text: geloest ? l.verdict_stamp_solid : l.verdict_stamp_unsolved,
      farbe: geloest ? const Color(0xFF2F6B37) : MRoh.stempelRot,
      groesse: 20,
      winkel: -0.16,
      aufschlagen: true,
    );
    final zeichen = Text('$nr/${akteSigel(akte)}', style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: MRoh.tinteLeise, letterSpacing: 1.2));
    final kopf = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: GanzeWorte(akte.titel, style: MPapierSchrift.titel)),
        if (akte.untertitel.isNotEmpty) ...[
          const SizedBox(height: MMass.s8),
          GanzeWorte(akte.untertitel, style: MPapierSchrift.kursiv.copyWith(color: MRoh.tinteLeise)),
        ],
        const SizedBox(height: MMass.s16),
        Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.25)),
        const SizedBox(height: MMass.s16),
        AkteMarken(akte: akte),
      ],
    );
    return LayoutBuilder(
      builder: (context, aussen) => MAktenmappe(
        reiter: l.case_file_no(nr),
        farbe: stil.akzent,
        siegel: akteSigel(akte),
        // Höchstens zwei Blätter: weitere schöben sich auf breiten Mappen über den Reiter.
        blaetter: mappenBlaetter(aussen.maxWidth),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: LayoutBuilder(
          builder: (context, box) {
            final breit = box.maxWidth >= 520;
            final foto = Stack(
              clipBehavior: Clip.none,
              children: [
                AkteTatortfoto(akte: akte, seitenverhaeltnis: 3 / 2, neigung: -0.014, klammer: true, breite: breit ? box.maxWidth * 0.48 : null),
                Positioned(right: 4, bottom: -18, child: IgnorePointer(child: stempel)),
              ],
            );
            if (breit) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.only(top: 14), child: foto),
                  const SizedBox(width: MMass.s24),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [zeichen, const SizedBox(height: MMass.s12), kopf])),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                zeichen,
                const SizedBox(height: MMass.s20),
                foto,
                const SizedBox(height: MMass.s32),
                kopf,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// „Die Lage“: ein Formblatt mit Schauplatz, Anlass und Zeitpunkt; die Stimmung
/// steht als Randnotiz in Füllertinte daneben (am Handy darunter).
class _LageBlatt extends StatelessWidget {
  const _LageBlatt({required this.akte, required this.lage});

  final AkteInfo akte;
  final AkteLage lage;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final felder = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lage.schauplatz.isNotEmpty) _Feld(name: l.detektei_akte_schauplatz, wert: lage.schauplatz),
        if (lage.anlass.isNotEmpty) _Feld(name: l.detektei_akte_anlass, wert: lage.anlass),
        if (lage.datum.isNotEmpty) _Feld(name: l.detektei_akte_zeitpunkt, wert: lage.datum),
      ],
    );
    final notizen = lage.atmosphaere.isEmpty ? null : _Randnotizen(zeilen: lage.atmosphaere);
    return MBlatt(
      klammer: true,
      neigung: -0.005,
      samen: akteSamen(akte.id) + 1,
      // Oben Platz für die Büroklammer.
      padding: const EdgeInsets.fromLTRB(22, 36, 22, 22),
      child: LayoutBuilder(
        builder: (context, box) {
          final breit = box.maxWidth >= 520 && notizen != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MBlattKopf(zeile: l.detektei_akte_lage),
              if (breit)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: felder),
                    const SizedBox(width: MMass.s20),
                    Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(top: 4), child: notizen)),
                  ],
                )
              else ...[
                felder,
                if (notizen != null) ...[const SizedBox(height: MMass.s8), notizen],
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Formularzeile wie [MFeld] (Feldname in Schreibmaschine, Wert in Lora), die
/// auch bei großer Schrift kein Wort zerteilt.
class _Feld extends StatelessWidget {
  const _Feld({required this.name, required this.wert});

  final String name;
  final String wert;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GanzeWorte(name, style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: MRoh.tinteLeise)),
            const SizedBox(height: 2),
            GanzeWorte(wert, style: MPapierSchrift.text),
          ],
        ),
      );
}

/// Stimmungssätze als handschriftliche Notizen am roten Heftrand.
class _Randnotizen extends StatelessWidget {
  const _Randnotizen({required this.zeilen});

  final List<String> zeilen;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(border: Border(left: BorderSide(color: MRoh.linieRot, width: 1.4))),
        child: Padding(
          padding: const EdgeInsets.only(left: MMass.s12, top: 2, bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < zeilen.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : MMass.s8),
                  child: Transform.rotate(
                    angle: i.isEven ? -0.012 : 0.008,
                    alignment: Alignment.centerLeft,
                    child: GanzeWorte(zeilen[i], style: MPapierSchrift.hand.copyWith(fontSize: 20, height: 1.2)),
                  ),
                ),
            ],
          ),
        ),
      );
}

/// „Personen“: oben das Opfer als verblasster Abzug, darunter die Besetzung als
/// Fotoabzüge mit Name in Füller und Rolle in Schreibmaschine. Jede Figur sieht
/// gleich aus; nur die Lage auf dem Blatt wechselt mit der Reihenfolge.
class _PersonenBlatt extends StatelessWidget {
  const _PersonenBlatt({required this.akte, required this.auszug});

  final AkteInfo akte;
  final AkteAuszug auszug;

  static const _neigungen = [-0.03, 0.022, -0.012, 0.034, -0.024, 0.01];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final opfer = auszug.opfer;
    return MBlatt(
      klebestreifen: true,
      neigung: 0.004,
      samen: akteSamen(akte.id) + 2,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MBlattKopf(zeile: l.abend_start_personen),
          if (opfer != null) ...[
            MergeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: MFotoabzug(
                      look: opfer.look ?? const LookDef(),
                      groesse: 76,
                      neigung: -0.045,
                      klammer: true,
                      gedaempft: true,
                      akzent: opfer.farbe,
                    ),
                  ),
                  const SizedBox(width: MMass.s20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: MMass.s8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GanzeWorte(l.intro_victim, style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: MRoh.stempelRot, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          GanzeWorte(opfer.name, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
                          if (opfer.titel.isNotEmpty) GanzeWorte(opfer.titel, style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: MRoh.tinteLeise)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MMass.s20),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.2)),
            const SizedBox(height: MMass.s20),
          ],
          LayoutBuilder(
            builder: (context, box) {
              const abstand = MMass.s12;
              final skala = MediaQuery.textScalerOf(context).scale(1);
              final spalten = ((box.maxWidth + abstand) / (92 * skala.clamp(1.0, 3.0) + abstand)).floor().clamp(1, 6);
              // Bei großer Schrift: eine Liste mit Foto links, damit Rollen nicht mitten im Wort brechen.
              if (spalten < 2) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < auszug.personen.length; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : MMass.s16),
                        child: _Person(person: auszug.personen[i], bild: 64, neigung: _neigungen[i % _neigungen.length], zeile: true),
                      ),
                  ],
                );
              }
              final breite = (box.maxWidth - abstand * (spalten - 1)) / spalten;
              final bild = (breite - 22).clamp(56.0, 96.0);
              return Wrap(
                spacing: abstand,
                runSpacing: MMass.s20,
                children: [
                  for (var i = 0; i < auszug.personen.length; i++)
                    SizedBox(
                      width: breite,
                      child: _Person(person: auszug.personen[i], bild: bild, neigung: _neigungen[i % _neigungen.length]),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Person extends StatelessWidget {
  const _Person({required this.person, required this.bild, required this.neigung, this.zeile = false});

  final KartenFigur person;
  final double bild;
  final double neigung;

  /// Als Zeile (Foto links, Text rechts) statt als Kachel.
  final bool zeile;

  @override
  Widget build(BuildContext context) {
    final foto = ExcludeSemantics(child: MFotoabzug(look: person.look ?? const LookDef(), groesse: bild, neigung: neigung, akzent: person.farbe));
    final ausrichtung = zeile ? TextAlign.start : TextAlign.center;
    final name = GanzeWorte(person.name, textAlign: ausrichtung, style: MPapierSchrift.hand.copyWith(fontSize: 20, height: 1.1));
    final rolle = person.titel.isEmpty
        ? null
        : GanzeWorte(person.titel, textAlign: ausrichtung, style: MPapierSchrift.maschine.copyWith(fontSize: 12, height: 1.3, color: MRoh.tinteLeise));
    if (zeile) {
      // Foto und Name nebeneinander, die Rolle darunter in voller Breite.
      return MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [foto, const SizedBox(width: MMass.s16), Expanded(child: name)],
            ),
            if (rolle != null) ...[const SizedBox(height: MMass.s8), rolle],
          ],
        ),
      );
    }
    return MergeSemantics(
      child: Column(
        children: [
          foto,
          const SizedBox(height: MMass.s8),
          SizedBox(width: double.infinity, child: name),
          if (rolle != null) SizedBox(width: double.infinity, child: rolle),
        ],
      ),
    );
  }
}
