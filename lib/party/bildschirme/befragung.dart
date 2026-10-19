import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show TischPaarung;

import '../../stil/mappe/abend1_bausteine.dart';
import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';
import '../stand/befragung_stand.dart';

/// Solo im Modell befragung (A-051): Der Detektiv befragt drei bis fünf Bots,
/// die festen und ein bis zwei frei gewählte. Jede Karte zeigt wen, das Thema
/// und die Fragen; erst nach dem Antippen einer Frage steht die Antwort darunter.
/// Darunter höchstens drei Zeilen „Am Tisch aufgeschnappt“: nur wer mit wem
/// worüber spricht, nie eine Antwort. „Weiter“ erscheint erst, wenn die Runde
/// durch ist.
class BefragungBildschirm extends StatelessWidget {
  const BefragungBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  /// Höchstens so viele Paarungen „Am Tisch aufgeschnappt“.
  static const aufgeschnappt = 3;

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: sitzung, builder: (context, _) => _bild(context));

  Widget _bild(BuildContext context) {
    final s = sitzung;
    final fertig = s.befragungenFertig;
    return PartyRahmen(
      marke: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
      titel: s.ui('ui.befragung.titel'),
      untertitel: s.ui('ui.befragung.hinweis'),
      aktionen: [if (s.kannWeiter) PartyKnopf(text: s.ui('ui.runde.weiter'), onPressed: s.weiter)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
          const SizedBox(height: 20),
          BefragungsListe(sitzung: s, onFrage: s.befragen),
          const SizedBox(height: 22),
          _aufgeschnappt(s),
          const SizedBox(height: 18),
          MBlatt(
            art: PapierArt.notiz,
            neigung: -0.006,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: MGanzeWorte(s.ui(fertig ? 'ui.befragung.fertig' : 'ui.befragung.offen'), stil: MPapierSchrift.hand.copyWith(fontSize: 22)),
          ),
        ],
      ),
    );
  }

  /// Höchstens drei Paarungen der Runde, nur Sprecher, Partner und Thema.
  Widget _aufgeschnappt(PartySitzung s) {
    final zeilen = s.tisch(s.runde).take(aufgeschnappt).toList();
    if (zeilen.isEmpty) return const SizedBox.shrink();
    return MBlatt(
      art: PapierArt.notiz,
      neigung: 0.004,
      samen: 31 + s.runde,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MGanzeWorte(s.ui('ui.befragung.aufgeschnappt'), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 18)),
          const SizedBox(height: 10),
          for (final t in zeilen) TischZeile(sitzung: s, paarung: t),
        ],
      ),
    );
  }
}

/// Die Befragungskarten der Runde: erst die festen, dann – solange die Runde
/// freie Wahlen hat – die frei wählbaren mit dem Stand der Wahl. [onFrage]
/// stellt eine Frage; [aktionen] baut zusätzliche Knöpfe je Karte (am Tisch:
/// „Antwort zeigen“, „Beantwortet“).
class BefragungsListe extends StatelessWidget {
  const BefragungsListe({super.key, required this.sitzung, required this.onFrage, this.aktionen});

  final PartySitzung sitzung;
  final void Function(String id, int frage) onFrage;
  final List<Widget> Function(BefragungKarte karte)? aktionen;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final karten = s.befragungen;
    final pflicht = [for (final k in karten) if (k.pflicht) k];
    final frei = [for (final k in karten) if (!k.pflicht) k];
    final offen = s.befragungenFrei;
    final wahlen = offen + frei.where((k) => k.gefragt).length;
    Widget karte(BefragungKarte k, int nr) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BefragungsKarte(sitzung: s, karte: k, nr: nr, onFrage: (f) => onFrage(k.id, f), aktionen: aktionen?.call(k) ?? const []),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < pflicht.length; i++) karte(pflicht[i], i),
        // Ohne freie Wahl in dieser Runde gibt es auch keinen Abschnitt dafür.
        if (wahlen > 0) ...[
          const SizedBox(height: 10),
          Text(s.ui('ui.befragung.frei_titel').toUpperCase(), style: context.schrift.marke),
          const SizedBox(height: 4),
          Text(
            s.ui(switch (offen) { 0 => 'ui.befragung.frei_fertig', 1 => 'ui.befragung.frei_eine', _ => 'ui.befragung.frei_zwei' }),
            style: Keller.text,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < frei.length; i++) karte(frei[i], pflicht.length + i),
        ],
      ],
    );
  }
}

/// Eine Befragungskarte (A-051): Fotoabzug und Name der befragten Person, das
/// Thema und die Fragen. Vor der Frage ist jede Frage ein Knopf; danach steht
/// die gestellte Frage abgehakt da und – nur wenn die App die Rolle spricht –
/// die Antwort in Stichpunkten. Ohne [onFrage] (Notizbuch) ist die Karte nur
/// zum Lesen. Eine freie Befragung, die nicht mehr wählbar ist, zeigt nur Name
/// und Thema.
class BefragungsKarte extends StatelessWidget {
  const BefragungsKarte({super.key, required this.sitzung, required this.karte, this.nr = 0, this.onFrage, this.aktionen = const []});

  final PartySitzung sitzung;
  final BefragungKarte karte;
  final int nr;
  final void Function(int frage)? onFrage;
  final List<Widget> aktionen;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final k = karte;
    final farbe = s.figurFarbe(k.rolle);
    final offen = onFrage != null && k.waehlbar && !k.gefragt;
    final foto = MFotoabzug(look: s.figurAussehen(k.rolle), groesse: 52, neigung: nr.isEven ? -0.05 : 0.04, akzent: farbe);
    final kopf = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MGanzeWorte(s.spielerName(k.rolle), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
        if (k.pflicht) Text(s.ui('ui.befragung.pflicht').toUpperCase(), style: MPapierSchrift.marke),
      ],
    );
    return Semantics(
      container: true,
      identifier: 'befragung-${k.id}',
      child: MBlatt(
        key: ValueKey(k.id),
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        randFarbe: farbe,
        neigung: nr.isEven ? -0.003 : 0.003,
        samen: 50 + nr,
        stempel: k.erledigt ? s.ui('ui.befragung.erledigt') : null,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              // Schmal oder mit großer Schrift steht der Name unter dem Abzug.
              builder: (context, box) => schmalFuerSchrift(context, box.maxWidth)
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [foto, const SizedBox(height: 8), kopf])
                  : Row(children: [foto, const SizedBox(width: 14), Expanded(child: kopf)]),
            ),
            const SizedBox(height: 10),
            Text(s.ui('ui.befragung.thema'), style: MPapierSchrift.leise),
            MGanzeWorte(k.thema, stil: MPapierSchrift.maschine),
            if (!k.waehlbar && !k.gefragt) ...[
              const SizedBox(height: 8),
              Text(s.ui('ui.befragung.vergeben'), style: MPapierSchrift.leise),
            ] else ...[
              const SizedBox(height: 10),
              Text(s.ui('ui.befragung.fragen'), style: MPapierSchrift.leise),
              const SizedBox(height: 4),
              for (var i = 0; i < k.fragen.length; i++)
                offen
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Semantics(
                          identifier: 'befragung-frage-${k.id}-$i',
                          child: MKnopf(text: k.fragen[i], art: MKnopfArt.zweit, breit: true, onPressed: () => onFrage!(i)),
                        ),
                      )
                    : _gestellt(k.fragen[i], i == k.frage),
              if (k.antwort case final antwort?) ...[
                const SizedBox(height: 8),
                Text(s.ui('ui.befragung.antwort'), style: MPapierSchrift.leise),
                const SizedBox(height: 4),
                if (antwort.isEmpty) Text(s.ui('ui.befragung.nichts'), style: MPapierSchrift.kursiv),
                for (final a in antwort) _Aussage(a),
              ],
            ],
            if (aktionen.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 8, children: aktionen),
            ],
          ],
        ),
      ),
    );
  }

  /// Eine Frage nach der Befragung: die gestellte abgehakt, die übrigen leise.
  Widget _gestellt(String frage, bool gestellt) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 8),
              child: Icon(gestellt ? Icons.check_rounded : Icons.remove_rounded, size: 16, color: gestellt ? MRoh.stempelRot : MRoh.tinteLeise),
            ),
            Expanded(child: Text(frage, style: gestellt ? MPapierSchrift.text : MPapierSchrift.leise)),
          ],
        ),
      );
}

/// Eine Antwort zu Protokoll: Kursive, links eine Tintenlinie wie ein Zitat.
class _Aussage extends StatelessWidget {
  const _Aussage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: MRoh.tinte.withValues(alpha: 0.28), width: 2))),
          child: Padding(padding: const EdgeInsets.only(left: 12), child: Text(text, style: MPapierSchrift.kursiv)),
        ),
      );
}

/// Eine Paarung am Tisch: wer mit wem spricht, darunter das Thema. Nie Stichpunkte oder Antworten.
class TischZeile extends StatelessWidget {
  const TischZeile({super.key, required this.sitzung, required this.paarung});

  final PartySitzung sitzung;
  final TischPaarung paarung;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final t = paarung;
    return Padding(
      key: ValueKey('tisch-${t.id}'),
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MGanzeWorte(s.ui('ui.runde.paarung', {'sprecher': s.spielerName(t.rolle), 'partner': s.personAmTisch(t.partner)}),
              stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 16)),
          MGanzeWorte(t.thema, stil: MPapierSchrift.maschine.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
