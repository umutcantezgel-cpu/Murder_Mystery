import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations_de.dart';
import '../stil/stil.dart';
import 'bildschirme/erzaehlerpult.dart';
import 'party_stil.dart';
import 'sitzung.dart';
import 'stimme.dart';

/// Wie die übrigen Partybildschirme deutsch, auch ohne Lokalisierung im Baum.
final _de = LDe();

/// Wortgleich-Prüfung (Master 7.12): Ein Vorlesetext gilt nur, wenn er dem
/// Baustein [kennung] entspricht. Unbekannte Kennungen sind nie wortgleich.
bool wortgleich(PartySitzung s, String kennung, String text) => s.hatText(kennung) && text == s.text(kennung);

/// Steht der Erzähltext dieses Schritts auf diesem Gerät offen? Nur auf dem
/// Vorleser-Sitz ([PartySitzung.istVorleser]) und, sitzt an einem Gerät ein
/// Erzähler mit am Tisch, nur bei offenem Pult ([PartySitzung.pultOffen]).
/// Bildschirme, die Erzähltext selbst setzen (Resümee), fragen hier.
bool erzaehltextOffen(PartySitzung s) => s.istVorleser && (!s.erzaehlerAmPult || s.pultOffen);

/// Erzählerfeld (F4-BAUMEISTER-05, Master 7.12): zeigt die Bausteine [kennungen]
/// wortgleich als Text. Ist die Erzählerstimme an, liest es sie nacheinander vor,
/// aber nur, wenn der Wortlaut stimmt.
///
/// Vorleser-Sitz (Langer Abend M3): Den Text sieht nur, wer vorliest
/// ([erzaehltextOffen]). Ein Gerät, das nicht vorliest, zeigt die
/// [VorleserKarte]; mit Erzähler am Tisch liegt der Text zugedeckt im
/// Erzählerpult ([ErzaehlerpultZu]), bis der Erzähler hinschaut. Ohne Erzähler
/// und im Solo bleibt der Text immer sichtbar.
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
    s.addListener(_offenGeaendert);
    _offen = erzaehltextOffen(s);
    // Nach dem ersten Aufbau liest das Feld, wenn die Stimme an ist.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && s.stimmeAn && _offen) unawaited(_vorlesen());
    });
  }

  /// War der Text beim letzten Blick offen (Vorleser, Pult offen)?
  bool _offen = false;

  /// Öffnet sich das Pult oder wechselt der Vorleser, liest die Stimme neu; schließt
  /// es sich, verstummt sie.
  void _offenGeaendert() {
    final jetzt = erzaehltextOffen(s);
    if (jetzt == _offen || !mounted) return;
    setState(() => _offen = jetzt);
    if (jetzt) {
      _einblenden.forward(from: 0);
      if (s.stimmeAn) unawaited(_vorlesen());
    } else {
      _lauf++;
      if (_spricht) _stimme.stopp();
      _spricht = false;
    }
  }

  @override
  void didUpdateWidget(covariant ErzaehlerFeld alt) {
    super.didUpdateWidget(alt);
    if (alt.sitzung != widget.sitzung) {
      alt.sitzung.removeListener(_offenGeaendert);
      widget.sitzung.addListener(_offenGeaendert);
      _offen = erzaehltextOffen(s);
    }
    if (!listEquals(alt.kennungen, widget.kennungen)) {
      _einblenden.forward(from: 0);
      if (s.stimmeAn && _offen) unawaited(_vorlesen());
    }
  }

  @override
  void dispose() {
    s.removeListener(_offenGeaendert);
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

  /// Gilt dieser Lauf noch? Nach Abbau, Abschalten, einem neuen Lauf oder
  /// zugedecktem Text nicht mehr.
  bool _gilt(int lauf) => mounted && lauf == _lauf && s.stimmeAn && erzaehltextOffen(s);

  @override
  Widget build(BuildContext context) {
    final kennungen = _bekannte;
    // Vorleser-Sitz (M3): Wer nicht vorliest, sieht nur, dass vorgelesen wird.
    if (!s.istVorleser) {
      if (kennungen.isEmpty) return const SizedBox.shrink();
      final wer = s.vorleserName.trim().isEmpty ? _de.vorleser_erzaehler : s.vorleserName.trim();
      return VorleserKarte(
        name: s.vorleserName,
        texte: kennungen.length,
        // Ist der Erzähler getrennt, übernimmt dieses Gerät nach einer Frist
        // (online); reihum liest er mit dem Erzähler-Begleiter am Handy.
        hinweis: s.uebernahmeFrist
            ? _de.vorleser_frist(wer)
            : (s.begleitung?.liest ?? false)
                ? _de.begleiter_handy_hinweis(wer)
                : null,
      );
    }
    if (s.erzaehlerAmPult && !s.pultOffen) {
      // Ohne Text in diesem Schritt (etwa in den Entscheidungen) gibt es nichts zu übergeben.
      if (kennungen.isEmpty) return const SizedBox.shrink();
      return ErzaehlerpultZu(sitzung: s, texte: kennungen.length);
    }
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
        // Am offenen Pult: nach dem Vorlesen zudecken (die Tafeln des Bildschirms stehen darüber).
        if (s.erzaehlerAmPult) ...[
          ErzaehlerpultZudecken(sitzung: s),
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
