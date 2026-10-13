import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../stil/stil.dart';
import 'party_stil.dart';
import 'sitzung.dart';
import 'stimme.dart';

/// Wortgleich-Prüfung (Master 7.12): Ein Vorlesetext gilt nur, wenn er dem
/// Baustein [kennung] entspricht. Unbekannte Kennungen sind nie wortgleich.
bool wortgleich(PartySitzung s, String kennung, String text) => s.hatText(kennung) && text == s.text(kennung);

/// Erzählerfeld (F4-BAUMEISTER-05, Master 7.12): zeigt die Bausteine [kennungen]
/// wortgleich als Text. Ist die Erzählerstimme an, liest es sie nacheinander vor,
/// aber nur, wenn der Wortlaut stimmt. Der Text bleibt immer sichtbar.
class ErzaehlerFeld extends StatefulWidget {
  const ErzaehlerFeld({super.key, required this.sitzung, required this.kennungen, this.verborgen = const {}});

  final PartySitzung sitzung;

  /// Baustein-Kennungen in Lesereihenfolge.
  final List<String> kennungen;

  /// Kennungen, die der Bildschirm selbst zeigt (z. B. die Rückblende als
  /// Erinnerung): sie bekommen hier keine Tafel, werden aber vorgelesen.
  final Set<String> verborgen;

  @override
  State<ErzaehlerFeld> createState() => _ErzaehlerFeldState();
}

class _ErzaehlerFeldState extends State<ErzaehlerFeld> with SingleTickerProviderStateMixin {
  /// Einblenden der Tafeln: 400 ms insgesamt, jede Tafel etwas später.
  late final AnimationController _einblenden = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  late final Stimme _stimme = Stimme.erzeugen();

  /// Nummer des laufenden Vorlesens; ein älterer Lauf bricht ab.
  int _lauf = 0;

  /// Läuft gerade eine Äußerung dieses Feldes?
  bool _spricht = false;

  PartySitzung get s => widget.sitzung;

  /// Die Kennungen, zu denen es einen Baustein gibt. Unbekannte fallen weg,
  /// nie tritt ein Ersatztext an ihre Stelle.
  List<String> get _bekannte => [
        for (final k in widget.kennungen)
          if (s.hatText(k)) k,
      ];

  @override
  void initState() {
    super.initState();
    _einblenden.forward();
    // Nach dem ersten Aufbau liest das Feld, wenn die Stimme an ist.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && s.stimmeAn) unawaited(_vorlesen());
    });
  }

  @override
  void didUpdateWidget(covariant ErzaehlerFeld alt) {
    super.didUpdateWidget(alt);
    if (!listEquals(alt.kennungen, widget.kennungen)) {
      _einblenden.forward(from: 0);
      if (s.stimmeAn) unawaited(_vorlesen());
    }
  }

  @override
  void dispose() {
    _lauf++;
    if (_spricht) _stimme.stopp();
    _einblenden.dispose();
    super.dispose();
  }

  /// Erzählerstimme an oder aus. Aus bricht das Vorlesen sofort ab.
  void _schalte(bool an) {
    setState(() {
      s.stimmeAn = an;
    });
    if (an) {
      unawaited(_vorlesen());
    } else {
      _lauf++;
      _spricht = false;
      _stimme.stopp();
    }
  }

  /// Liest alle Bausteine nacheinander vor. Jeder Text wird vorher auf
  /// Wortgleichheit geprüft; was nicht passt, bleibt beim Bildschirmtext.
  Future<void> _vorlesen() async {
    final lauf = ++_lauf;
    _stimme.stopp();
    if (!_stimme.verfuegbar) return;
    for (final k in _bekannte) {
      final text = s.text(k);
      if (!_gilt(lauf)) return;
      if (!wortgleich(s, k, text)) continue;
      _spricht = true;
      final ok = await _stimme.sprich(text);
      if (lauf == _lauf) _spricht = false;
      if (!ok) return;
    }
  }

  /// Gilt dieser Lauf noch? Nach Abbau, Abschalten oder einem neuen Lauf nicht mehr.
  bool _gilt(int lauf) => mounted && lauf == _lauf && s.stimmeAn;

  @override
  Widget build(BuildContext context) {
    final kennungen = _bekannte;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _kopf(),
        const SizedBox(height: 16),
        for (var i = 0; i < kennungen.length; i++)
          if (!widget.verborgen.contains(kennungen[i])) ...[
            _tafel(i, kennungen[i]),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  /// Kopfzeile: der Messingschalter für die Stimme, dazu je nach Gerät Knopf oder Hinweis.
  Widget _kopf() {
    final an = s.stimmeAn;
    final da = _stimme.verfuegbar;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Text(s.ui('ui.erzaehler.stimme'), style: context.schrift.leise),
        Tooltip(
          message: s.ui('ui.erzaehler.stimme_tipp'),
          child: MSchalter(
            wert: an,
            onChanged: _schalte,
            semantik: s.ui('ui.erzaehler.stimme'),
            symbolAn: Icons.volume_up,
            symbolAus: Icons.volume_off,
          ),
        ),
        if (an && da) PartyKnopf(text: s.ui('ui.erzaehler.nochmal'), haupt: false, icon: Icons.replay, onPressed: () => unawaited(_vorlesen())),
        if (an && !da) Text(s.ui('ui.erzaehler.keine_stimme'), style: context.schrift.leise),
      ],
    );
  }

  /// Ein getipptes Berichtsblatt je Baustein, leicht versetzt wie auf dem
  /// Schreibtisch gestapelt. Rückblicke der Lacher tragen oben eine rote Marke.
  bool get _schmal => MediaQuery.sizeOf(context).width < 380 && MediaQuery.textScalerOf(context).scale(1) > 1.3;

  Widget _tafel(int i, String k) {
    final rueckblick = k.startsWith('intro.lacher.');
    return FadeTransition(
      // Gestaffelt: die ersten vier Blätter starten nacheinander, alle sind nach 400 ms da.
      opacity: _einblenden.drive(CurveTween(curve: Interval((i > 4 ? 4 : i) * 0.1, 1, curve: Curves.easeOut))),
      child: MBlatt(
        neigung: i.isEven ? -0.004 : 0.005,
        klammer: i == 0,
        samen: k.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0xffff),
        // Schmale Geräte mit großer Schrift: engere Ränder, und lange Wörter
        // brechen nie mitten durch (die Schrift wird dann etwas kleiner).
        padding: _schmal ? const EdgeInsets.fromLTRB(14, 18, 14, 18) : const EdgeInsets.fromLTRB(22, 20, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rueckblick) ...[
              Text(s.ui('ui.erzaehler.rueckblick').toUpperCase(), style: MPapierSchrift.marke),
              const SizedBox(height: 8),
            ],
            MGanzeWorte(s.text(k), stil: MPapierSchrift.erzaehler, minimum: 14),
          ],
        ),
      ),
    );
  }
}
