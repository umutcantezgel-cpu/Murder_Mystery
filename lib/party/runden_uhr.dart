import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mordakte_core/runden.dart' show RundenUhr, UhrAktion;

import '../stil/mappe/abend1_bausteine.dart';
import '../stil/mappe/material.dart' show BuerstungMaler, messingVerlauf;
import '../stil/stil.dart';
import 'sitzung.dart';

/// Texte der Rundenuhr: am Tisch Bausteine der Sitzung ([RundenUhrTexte.sitzung]),
/// auf dem Gerät eines Gastes aus der ARB (`gast_uhr.dart`).
class RundenUhrTexte {
  const RundenUhrTexte({
    required this.titel,
    required this.start,
    required this.weiter,
    required this.pause,
    required this.plus,
    required this.zeitUm,
    required this.angehalten,
    required this.stellt,
  });

  /// Bausteine der Sitzung (`ui.runde.*`).
  factory RundenUhrTexte.sitzung(PartySitzung s) => RundenUhrTexte(
        titel: s.ui('ui.runde.uhr'),
        start: s.ui('ui.runde.start'),
        weiter: s.ui('ui.runde.weiterlaufen'),
        pause: s.ui('ui.runde.pause'),
        plus: s.ui('ui.runde.plus'),
        zeitUm: s.ui('ui.runde.zeit_um'),
        angehalten: s.ui('ui.runde.angehalten'),
        stellt: (name) => s.ui('ui.runde.stellt', {'name': name}),
      );

  final String titel, start, weiter, pause, plus, zeitUm, angehalten;

  /// „Die Uhr stellt …“ für Geräte ohne Knöpfe.
  final String Function(String name) stellt;
}

/// Zugabe des Knopfs „plus“ in Minuten.
const uhrZugabe = 5;

/// Die gemeinsame Rundenuhr (Langer Abend M4): eine Taschenuhr aus Messing mit
/// der Restzeit im Fenster, bei null der Stempel quer über dem Zifferblatt.
/// Darunter, wenn dieses Gerät die Uhr stellt ([steuern]), Start (nach einer
/// Pause: Weiter), Pause und plus fünf Minuten; sonst, wer sie stellt ([stellt]).
///
/// Die Uhr selbst ist reiner Zustand ([RundenUhr]): Hier tickt nur die Anzeige,
/// einmal je Sekunde, solange sie läuft. Die Restzeit kommt aus [jetzt], der
/// Abendzeit dieses Geräts (Gäste: mit dem Versatz zum Gastgeber). So zeigen
/// alle Geräte dieselbe Zeit, ohne dass ein Takt durchs Netz geht. Die Uhr
/// schaltet nie etwas weiter; das tut allein „Weiter“.
class RundenUhrAnzeige extends StatefulWidget {
  const RundenUhrAnzeige({
    super.key,
    required this.uhr,
    required this.jetzt,
    required this.texte,
    this.steuern,
    this.stellt,
    this.groesse = 320,
  });

  final RundenUhr uhr;

  /// Abendzeit dieses Geräts in Millisekunden.
  final int Function() jetzt;

  final RundenUhrTexte texte;

  /// Aktion an der Uhr; `null`: Dieses Gerät stellt sie nicht.
  final void Function(UhrAktion aktion, {int? minuten})? steuern;

  /// Name dessen, der die Uhr stellt (nur ohne [steuern]); leer: kein Hinweis.
  final String? stellt;

  /// Größte Breite der Taschenuhr.
  final double groesse;

  @override
  State<RundenUhrAnzeige> createState() => _RundenUhrAnzeigeState();
}

class _RundenUhrAnzeigeState extends State<RundenUhrAnzeige> {
  /// Takt der Anzeige, solange die Uhr läuft und noch Zeit übrig ist.
  Timer? _takt;

  @override
  void initState() {
    super.initState();
    _taktPruefen();
  }

  @override
  void didUpdateWidget(RundenUhrAnzeige alt) {
    super.didUpdateWidget(alt);
    _taktPruefen();
  }

  @override
  void dispose() {
    _takt?.cancel();
    super.dispose();
  }

  RundenUhr get _uhr => widget.uhr;

  void _taktPruefen() {
    final soll = _uhr.laeuft && !_uhr.abgelaufen(widget.jetzt());
    if (soll && _takt == null) {
      _takt = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        if (_uhr.abgelaufen(widget.jetzt())) {
          _takt?.cancel();
          _takt = null;
        }
      });
    } else if (!soll) {
      _takt?.cancel();
      _takt = null;
    }
  }

  /// Restzeit im Format mm:ss, auf volle Sekunden aufgerundet (am Anfang die
  /// volle Dauer, null erst, wenn die Zeit um ist).
  static String zeit(int ms) {
    final sek = (ms / 1000).ceil();
    return '${(sek ~/ 60).toString().padLeft(2, '0')}:${(sek % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.texte;
    final jetzt = widget.jetzt();
    final rest = _uhr.rest(jetzt);
    final um = _uhr.abgelaufen(jetzt);
    final gesamt = _uhr.dauer;
    final steht = _uhr.gestartet && _uhr.pausiert;
    final steuern = widget.steuern;
    final stellt = widget.stellt?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(t.titel.toUpperCase(), style: MSchrift.von(context).marke, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, box) => Center(
            child: MTaschenuhr(
              groesse: math.min(box.maxWidth * 0.84, widget.groesse),
              anteil: gesamt <= 0 ? 0 : rest / gesamt,
              sekunden: (gesamt - rest) ~/ 1000,
              fenster: Text(
                zeit(rest),
                key: const ValueKey('rundenuhr-zeit'),
                style: MPapierSchrift.titel.copyWith(
                  fontSize: 40,
                  height: 1.1,
                  color: um ? MRoh.stempelRot : MRoh.tinte,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              stempel: um
                  ? MStempelZeile(
                      t.zeitUm,
                      groesse: 17,
                      winkel: -0.16,
                      aufschlagen: true,
                      grund: MRoh.karteikarte.withValues(alpha: 0.94),
                    )
                  : null,
            ),
          ),
        ),
        if (steht && !um) ...[
          const SizedBox(height: 6),
          Text(t.angehalten.toUpperCase(), key: const ValueKey('rundenuhr-angehalten'), style: MSchrift.von(context).marke, textAlign: TextAlign.center),
        ],
        const SizedBox(height: 14),
        if (steuern != null)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: [
              if (steht)
                _knopf(Icons.play_arrow_rounded, t.weiter, () => steuern(UhrAktion.weiter))
              else
                _knopf(Icons.play_arrow_rounded, t.start, _uhr.laeuft ? null : () => steuern(UhrAktion.start)),
              _knopf(Icons.pause_rounded, t.pause, _uhr.laeuft && !um ? () => steuern(UhrAktion.pause) : null),
              _knopf(
                Icons.more_time_rounded,
                t.plus,
                _uhr.dauer + uhrZugabe * RundenUhr.minute <= RundenUhr.hoechstDauer ? () => steuern(UhrAktion.plus, minuten: uhrZugabe) : null,
              ),
            ],
          )
        else if (stellt.isNotEmpty)
          Text(t.stellt(stellt), key: const ValueKey('rundenuhr-stellt'), style: MSchrift.von(context).leise, textAlign: TextAlign.center),
      ],
    );
  }

  /// Runder Messingknopf der Uhr; der Tooltip ist ein Baustein.
  Widget _knopf(IconData symbol, String tipp, VoidCallback? onPressed) => IconButton(
        tooltip: tipp,
        onPressed: onPressed,
        icon: Icon(symbol, size: 28),
        style: ButtonStyle(
          fixedSize: const WidgetStatePropertyAll(Size(58, 58)),
          shape: const WidgetStatePropertyAll(CircleBorder()),
          overlayColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.1)),
          foregroundColor: WidgetStateProperty.resolveWith(
            (z) => z.contains(WidgetState.disabled) ? const Color(0x995A4220) : const Color(0xFF2A1A06),
          ),
          backgroundBuilder: (context, zustaende, kind) => _MessingRund(
            gedrueckt: zustaende.contains(WidgetState.pressed),
            gesperrt: zustaende.contains(WidgetState.disabled),
            child: kind,
          ),
        ),
      );
}

/// Die Rundenuhr am Tisch (Rundenzentrale, Erzählerpult): Zustand und
/// Abendzeit aus der [sitzung], Knöpfe nur auf dem Gerät, das leitet.
class SitzungsUhr extends StatelessWidget {
  const SitzungsUhr({super.key, required this.sitzung, this.groesse = 320});

  final PartySitzung sitzung;
  final double groesse;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: sitzung,
        builder: (context, _) => RundenUhrAnzeige(
          uhr: sitzung.uhr,
          jetzt: sitzung.abendzeit,
          texte: RundenUhrTexte.sitzung(sitzung),
          steuern: sitzung.uhrSteuerbar ? (a, {minuten}) => sitzung.uhrAktion(a, minuten: minuten) : null,
          stellt: sitzung.uhrSteuerbar ? null : sitzung.uhrStellerName,
          groesse: groesse,
        ),
      );
}

/// Runder Messingknopf mit gebürsteter Fläche, gesperrt grau und blass.
class _MessingRund extends StatelessWidget {
  const _MessingRund({required this.gedrueckt, required this.gesperrt, this.child});

  final bool gedrueckt;
  final bool gesperrt;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget knopf = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: messingVerlauf(gedrueckt: gedrueckt),
        border: Border.all(color: MRoh.messingDunkel, width: 1.4),
        boxShadow: gedrueckt
            ? const [BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1))]
            : const [
                BoxShadow(color: Color(0x88000000), blurRadius: 8, offset: Offset(0, 4)),
                BoxShadow(color: Color(0x33FFE7A8), blurRadius: 0, spreadRadius: -1, offset: Offset(0, -1)),
              ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            const Positioned.fill(child: CustomPaint(painter: BuerstungMaler())),
            ?child,
          ],
        ),
      ),
    );
    if (gesperrt) knopf = Opacity(opacity: 0.45, child: knopf);
    return AnimatedScale(scale: gedrueckt ? 0.95 : 1, duration: MBewegung.schnell(context), child: knopf);
  }
}
