import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../game/game_view.dart';
import '../stil/mappe/abend2_bausteine.dart';
import '../stil/stil.dart';
import 'karte_session.dart';
import 'sitzung.dart';

/// Rückblende im Finale (F4-ORCH-03, Master 7.13): Zeitraffer der Tatmatrix
/// des aktiven Pfads. Im Dunkeln nur Umrisse, hervorgehoben sind die Person
/// mit dem Schlag und Herr Schneider; das Licht folgt dem Stromausfall (B-04).
/// Erst nach dem Finale verwenden (die Sitzung prüft das).
class RueckblendeAnsicht extends StatefulWidget {
  const RueckblendeAnsicht({super.key, required this.sitzung, this.onFertig});

  final PartySitzung sitzung;

  /// Wird einmal aufgerufen, wenn der Zeitraffer am Ende ist.
  final VoidCallback? onFertig;

  @override
  State<RueckblendeAnsicht> createState() => _RueckblendeAnsichtState();
}

class _RueckblendeAnsichtState extends State<RueckblendeAnsicht> {
  /// Nur bei Akten mit Simulation; sonst erzählt [RueckblendeText] die Rückblende.
  PartyKartenSession? _session;

  @override
  void initState() {
    super.initState();
    if (!widget.sitzung.hatRueckblende) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onFertig?.call();
      });
      return;
    }
    final session = _session = PartyKartenSession(widget.sitzung, rueckblendeModus: true, zeitraffer: widget.sitzung.zeitraffer);
    session.fertig.addListener(_fertig);
  }

  void _fertig() {
    if (_session?.fertig.value == true) widget.onFertig?.call();
  }

  @override
  void dispose() {
    _session?.fertig.removeListener(_fertig);
    _session?.dispose();
    super.dispose();
  }

  /// Uhr und Wiederholen stehen über dem Bild, nicht darauf: Sie verdecken so
  /// keine Figur und keinen Ring (E-038, B9).
  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) return RueckblendeText(sitzung: widget.sitzung);
    return _zeitraffer(session);
  }

  /// Der Zeitraffer ist ein dunkles Bild (auch wenn er auf einer Titelseite
  /// liegt): Uhr und Wiederholen stehen hell darüber.
  Widget _zeitraffer(PartyKartenSession session) => MFlaeche.dunkel(
    child: ColoredBox(
      color: const Color(0xFF0B0A0E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<Uhrzeit?>(
                    valueListenable: session.zeit,
                    // Die Uhr liegt im festen Bildkasten: Sie wächst mit der Schrift nur
                    // begrenzt, damit die Szene sichtbar bleibt.
                    builder: (context, t, _) => t == null
                        ? const SizedBox.shrink()
                        : MediaQuery.withClampedTextScaling(
                            maxScaleFactor: 1.4,
                            child: Text(
                              widget.sitzung.ui('ui.allgemein.uhrzeit', {'uhrzeit': t.mitSekunden}),
                              style: MRohSchrift.schreibmaschine.copyWith(color: MRoh.blatt, fontFeatures: const [FontFeature.tabularFigures()]),
                            ),
                          ),
                  ),
                ),
                IconButton(
                  tooltip: widget.sitzung.ui('ui.rueckblende.nochmal'),
                  onPressed: session.neuStarten,
                  style: IconButton.styleFrom(
                    backgroundColor: MRoh.messingMitte,
                    foregroundColor: const Color(0xFF2A1A06),
                    side: const BorderSide(color: MRoh.messingDunkel),
                  ),
                  icon: const Icon(Icons.replay),
                ),
              ],
            ),
          ),
          // Die Szene malt sonst über ihren Rand in die Kopfzeile mit der Uhr (F6-SPIEL-01).
          Expanded(child: ClipRect(child: GameView(session: session, steuerung: false))),
        ],
      ),
    ),
  );
}

/// Rückblende einer Akte ohne Simulation: kein Zeitraffer, sondern der
/// Erzählertext `rueckblende.<pfad>` als Erinnerung: ein Foto in Sepia mit
/// gezacktem Rand, eingeklebt, der Text kursiv in Tinte, darunter die
/// Beschriftung in Füllerschrift. Erst nach dem Finale verwenden (die Sitzung
/// prüft das).
class RueckblendeText extends StatelessWidget {
  const RueckblendeText({super.key, required this.sitzung});

  final PartySitzung sitzung;

  /// Kennung des Bausteins dieser Rückblende.
  String get kennung => 'rueckblende.${sitzung.pfad}';

  @override
  Widget build(BuildContext context) {
    if (!sitzung.hatText(kennung)) return const SizedBox.shrink();
    final ruhig = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      container: true,
      label: sitzung.ui('ui.finale.rueckblende'),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: ruhig ? 1 : 0, end: 1),
        duration: ruhig ? Duration.zero : const Duration(milliseconds: 900),
        curve: Curves.easeOut,
        builder: (context, t, child) => Opacity(opacity: t, child: child),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: MErinnerungsfoto(
            neigung: -0.008,
            samen: kennung.codeUnits.fold(13, (a, b) => (a * 31 + b) & 0xffff),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Text('„', style: MPapierSchrift.aufmacher.copyWith(height: 0.9, color: MRoh.tinte.withValues(alpha: 0.55))),
                ),
                Text(sitzung.text(kennung), style: MPapierSchrift.erzaehler.copyWith(fontStyle: FontStyle.italic, height: 1.7)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ExcludeSemantics(child: Text(sitzung.ui('ui.finale.rueckblende'), style: MPapierSchrift.hand.copyWith(fontSize: 22))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
