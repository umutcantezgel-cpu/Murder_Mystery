import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../game/game_view.dart';
import 'karte_session.dart';
import 'party_stil.dart';
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

  Widget _zeitraffer(PartyKartenSession session) => ColoredBox(
    color: const Color(0xFF0B0A0E),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<Uhrzeit?>(
                  valueListenable: session.zeit,
                  builder: (context, t, _) => t == null
                      ? const SizedBox.shrink()
                      : Text(
                          widget.sitzung.ui('ui.allgemein.uhrzeit', {'uhrzeit': t.mitSekunden}),
                          style: Keller.text.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                        ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: widget.sitzung.ui('ui.rueckblende.nochmal'),
                onPressed: session.neuStarten,
                icon: const Icon(Icons.replay),
              ),
            ],
          ),
        ),
        // Die Szene malt sonst über ihren Rand in die Kopfzeile mit der Uhr (F6-SPIEL-01).
        Expanded(child: ClipRect(child: GameView(session: session, steuerung: false))),
      ],
    ),
  );
}

/// Rückblende einer Akte ohne Simulation: kein Zeitraffer, sondern der
/// Erzählertext `rueckblende.<pfad>` als Erinnerung in Sepia, mit Anführungszeichen
/// und ruhiger Schrift. Erst nach dem Finale verwenden (die Sitzung prüft das).
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
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x55D9B98A)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2B2118), Color(0xFF15110E)],
            ),
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.format_quote_rounded, size: 36, color: Color(0xFFD9B98A)),
              const SizedBox(height: 4),
              Text(
                sitzung.text(kennung),
                style: Keller.erzaehler.copyWith(fontStyle: FontStyle.italic, height: 1.75, color: const Color(0xFFF1E3CC)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
