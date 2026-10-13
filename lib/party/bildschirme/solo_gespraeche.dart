import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart';

import '../../stil/stil.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../sitzung.dart';

/// Der Mensch bleibt Detektiv: eine öffentliche Aussage nach der anderen,
/// ohne Rollenwechsel, Gesprächsuhr oder Zugriff auf ein fremdes Dossier.
///
/// Jede Aussage liegt als Vernehmungsprotokoll obenauf; dahinter deutet ein
/// Stapel an, dass noch weitere Protokolle folgen.
class SoloGespraecheBildschirm extends StatefulWidget {
  const SoloGespraecheBildschirm({super.key, required this.sitzung});
  final PartySitzung sitzung;

  @override
  State<SoloGespraecheBildschirm> createState() => _SoloGespraecheBildschirmState();
}

class _SoloGespraecheBildschirmState extends State<SoloGespraecheBildschirm> {
  int _nummer = 0;
  PartySitzung get s => widget.sitzung;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final liste = s.soloGespraeche;
          final g = _nummer < liste.length ? liste[_nummer] : null;
          return PartyRahmen(
            key: ValueKey('solo-${s.runde}-$_nummer'),
            marke: s.ui('ui.allgemein.runde', {'nr': '${s.runde}'}),
            titel: s.ui('ui.solo.gespraeche'),
            untertitel: s.ui('ui.solo.gespraeche_hinweis'),
            aktionen: [
              if (_nummer > 0) PartyKnopf(text: s.ui('ui.solo.vorheriges'), haupt: false, onPressed: () => setState(() => _nummer--)),
              if (g != null)
                PartyKnopf(
                  text: s.ui('ui.solo.gehoert'),
                  onPressed: () {
                    s.soloGespraechGelesen(g.id);
                    setState(() => _nummer++);
                  },
                ),
              if (s.kannWeiter) PartyKnopf(text: s.ui('ui.runde.weiter'), onPressed: s.weiter),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_nummer == 0) ...[
                  ErzaehlerFeld(sitzung: s, kennungen: s.erzaehler),
                  const SizedBox(height: 20),
                ],
                if (g != null) ...[
                  Text(s.ui('ui.solo.fortschritt', {'nr': '${_nummer + 1}', 'gesamt': '${liste.length}'}), style: context.schrift.marke),
                  const SizedBox(height: 14),
                  _Stapel(tiefe: (liste.length - _nummer - 1).clamp(0, 2), child: BotSprechblase(sitzung: s, gespraech: g)),
                ] else
                  MBlatt(
                    art: PapierArt.notiz,
                    neigung: -0.006,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                    child: Text(s.ui('ui.solo.fertig'), style: MPapierSchrift.hand.copyWith(fontSize: 22)),
                  ),
              ],
            ),
          );
        },
      );
}

/// Weitere Protokolle unter dem obersten: leere Blätter, leicht versetzt.
class _Stapel extends StatelessWidget {
  const _Stapel({required this.tiefe, required this.child});

  final int tiefe;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = tiefe; i > 0; i--)
            Positioned(
              left: 4.0 * i,
              right: -3.0 * i,
              top: 5.0 * i,
              bottom: -6.0 * i,
              child: Transform.rotate(
                angle: 0.008 * i,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.lerp(MRoh.blatt, MRoh.blattSchatten, 0.25 * i),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 3))],
                  ),
                ),
              ),
            ),
          child,
        ],
      );
}

/// Vernehmungsprotokoll einer öffentlichen Aussage. Auch das Notizbuch zeigt
/// nur diese unveränderliche Ansicht: Fotoabzug und Name der sprechenden Figur,
/// mit wem sie spricht, das Thema als getipptes Formularfeld und die Aussage
/// in Kursive auf dem Blatt.
class BotSprechblase extends StatelessWidget {
  const BotSprechblase({super.key, required this.sitzung, required this.gespraech});
  final PartySitzung sitzung;
  final BotGespraech gespraech;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    final g = gespraech;
    final farbe = s.figurFarbe(g.rolle);
    final samen = g.id.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0xffff);
    return MBlatt(
      key: ValueKey(g.id),
      randFarbe: farbe,
      samen: samen,
      neigung: samen.isEven ? -0.004 : 0.004,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  MFotoabzug(look: s.figurAussehen(g.rolle), groesse: 64, neigung: samen.isEven ? -0.05 : 0.04, akzent: farbe),
                  const Positioned(top: -9, left: 0, right: 0, child: Center(child: MKlebestreifen(breite: 44, winkel: 0.08))),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.figurName(g.rolle), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(s.ui('ui.rollen.gespraech_mit', {'name': s.personAmTisch(g.partner)}), style: MPapierSchrift.leise),
                      if (!s.besetzt.contains(g.rolle)) Text(s.ui('ui.solo.npc'), style: MPapierSchrift.leise.copyWith(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Formularfeld(name: s.ui('ui.rollen.gespraech_thema'), wert: g.thema),
          const SizedBox(height: 14),
          _Aussage(g.text),
          for (final z in g.preisgaben) ...[
            const SizedBox(height: 12),
            _Aussage(z.text),
          ],
        ],
      ),
    );
  }
}

/// Getipptes Formularfeld: Feldname klein, Eintrag in Schreibmaschine auf einer Linie.
class _Formularfeld extends StatelessWidget {
  const _Formularfeld({required this.name, required this.wert});

  final String name;
  final String wert;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: MPapierSchrift.zwischentitel.copyWith(fontSize: 13, color: MRoh.stempelRot, letterSpacing: 1.1)),
          const SizedBox(height: 2),
          DecoratedBox(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: MRoh.tinte.withValues(alpha: 0.35)))),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(wert, style: MPapierSchrift.maschine),
            ),
          ),
        ],
      );
}

/// Eine Aussage zu Protokoll: Kursive, links eine Tintenlinie wie ein Zitat.
class _Aussage extends StatelessWidget {
  const _Aussage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: MRoh.tinte.withValues(alpha: 0.28), width: 2))),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(text, style: MPapierSchrift.kursiv),
        ),
      );
}
