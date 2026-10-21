import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../game/game_view.dart';
import '../../game/szenen_erweiterung.dart' show SzenenUmgebung;
import '../../l10n/gen/app_localizations_de.dart';
import '../../stil/stil.dart';
import '../abend_karte.dart';
import '../daten.dart';
import '../erzaehler_ausgabe.dart';
import '../party_stil.dart';
import '../rundgang_karte.dart';
import '../sitzung.dart';
import 'erzaehlerpult.dart';

/// Wie die übrigen Partybildschirme deutsch, auch ohne Lokalisierung im Baum.
final _de = LDe();

/// Vorspiel (18:00, vor der Diashow der Einleitung) und Morgen (07:00, nach
/// der Auflösung) im langen Abend (M7b, [PartySitzung.rundgang]): ein Rundgang
/// über die Welt-Ebenen.
///
/// - Oben die Karte ([RundgangKarte]): Der Detektiv geht zu jeder Station,
///   Figuren der Station stehen dort; Tore und Licht folgen der Uhrzeit (am
///   Morgen draußen Tageslicht). Wer will, tippt und geht selbst.
/// - Darunter die Karte der Station nach R17 (Titel, höchstens drei
///   Stichpunkte) für alle, dann der Vorlesetext nur für den Vorleser-Sitz
///   ([RundgangVorlesen]); im Solo steht er unter der Karte.
/// - „Nächste Station“ und „Rundgang überspringen“ drückt, wer leitet
///   ([PartySitzung.rundgangSteuerbar]); nach der letzten Station geht es zur
///   Diashow bzw. zum Schlussbild.
///
/// Ohne Ebenen (Laden gescheitert) bleiben Karte und Text: Der Abend hängt nie
/// an der Grafik.
class RundgangBildschirm extends StatefulWidget {
  const RundgangBildschirm({super.key, required this.sitzung});

  final PartySitzung sitzung;

  /// Lädt Ebenen und Szenarien der Akte; Tests setzen eine Quelle aus den Repo-Dateien.
  @visibleForTesting
  static Future<(WeltEbenen, Map<String, ScenarioDef>)> Function(PartyDaten daten) weltLaden = (d) => AbendKarte.ladeWelt(rootBundle, d);

  /// Die Karte des laufenden Rundgangs, sonst `null`. Nur zum Lesen: Das
  /// Entwickler-Skript wartet daran, bis der Detektiv angekommen ist; Tests
  /// prüfen Lage, Licht und Figuren.
  static final ValueNotifier<RundgangKarte?> letzteKarte = ValueNotifier(null);

  @override
  State<RundgangBildschirm> createState() => _RundgangBildschirmState();
}

class _RundgangBildschirmState extends State<RundgangBildschirm> {
  PartySitzung get s => widget.sitzung;

  RundgangKarte? _karte;
  RundgangTeil? _teil;
  int _gezeigt = -1;
  bool _ladeFehler = false;
  bool _entsorgt = false;

  @override
  void initState() {
    super.initState();
    s.addListener(_geaendert);
    unawaited(_laden());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _karte?.bewegungReduziert = MBewegung.ruhig(context);
  }

  @override
  void dispose() {
    _entsorgt = true;
    s.removeListener(_geaendert);
    final k = _karte;
    if (RundgangBildschirm.letzteKarte.value == k) RundgangBildschirm.letzteKarte.value = null;
    if (k != null) unawaited(k.dispose());
    super.dispose();
  }

  Future<void> _laden() async {
    final teil = s.rundgang;
    final v = s.vorspielMorgen;
    if (teil == null || v == null) return;
    try {
      final (welt, szenarien) = await RundgangBildschirm.weltLaden(s.daten);
      if (_entsorgt || !mounted) return;
      final k = RundgangKarte(s.daten, welt, szenarien, v.rundgang(teil), station: s.rundgangStation, detektivName: s.personAmTisch(Besetzung.detektiv))
        ..bewegungReduziert = MBewegung.ruhig(context);
      setState(() {
        _karte = k;
        _teil = teil;
      });
      RundgangBildschirm.letzteKarte.value = k;
      _geaendert();
    } catch (e) {
      debugPrint('PARTY rundgang ohne Karte: $e');
      if (!_entsorgt && mounted) setState(() => _ladeFehler = true);
    }
  }

  /// Neue Station: Der Detektiv geht hin. Wechselt der Rundgang selbst (nach
  /// dem Fortsetzen), zeigt der Bildschirm dessen Karte erst beim Neuaufbau.
  void _geaendert() {
    final k = _karte;
    if (k == null || _entsorgt || s.rundgang != _teil) return;
    final nr = s.rundgangStation;
    if (nr == _gezeigt) return;
    _gezeigt = nr;
    unawaited(k.geheZu(nr));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: s, builder: (context, _) => _inhalt(context));

  Widget _inhalt(BuildContext context) {
    final teil = s.rundgang;
    final station = s.rundgangAktuell;
    final text = s.rundgangText;
    if (teil == null || station == null || text == null) return const SizedBox.shrink();
    final n = s.rundgangStationen.length;
    final nr = s.rundgangStation.clamp(0, n - 1);
    final letzte = nr >= n - 1;
    final steuerbar = s.rundgangSteuerbar;
    final teilName = teil == RundgangTeil.vorspiel ? _de.rundgang_vorspiel : _de.rundgang_morgen;
    final wer = s.vorleserName.trim().isEmpty ? _de.vorleser_erzaehler : s.vorleserName.trim();
    return PartyFussHinweis(
      text: steuerbar ? null : _de.rundgang_fuehrt(wer),
      child: PartyRahmen(
        marke: _de.rundgang_marke(teilName, '${station.zeit}'),
        scroll: false,
        aktionen: [
          if (!letzte)
            PartyKnopf(
              key: const ValueKey('rundgang-ueberspringen'),
              text: _de.rundgang_ueberspringen,
              haupt: false,
              icon: Icons.fast_forward_rounded,
              onPressed: steuerbar ? s.rundgangUeberspringen : null,
            ),
          PartyKnopf(
            key: const ValueKey('rundgang-weiter'),
            text: letzte ? (teil == RundgangTeil.vorspiel ? _de.rundgang_zur_einleitung : _de.rundgang_zum_schluss) : _de.rundgang_weiter,
            icon: Icons.arrow_forward_rounded,
            onPressed: steuerbar ? s.rundgangWeiter : null,
          ),
        ],
        child: LayoutBuilder(
          builder: (context, box) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: (box.maxHeight * 0.48).clamp(160.0, 420.0), child: _kartenBild(context)),
              const SizedBox(height: MMass.s12),
              Expanded(
                child: RollFlaeche(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RundgangKarteBlatt(
                        key: ValueKey('rundgang-karte-${teil.name}-$nr'),
                        text: text,
                        zaehler: _de.rundgang_station('${nr + 1}', '$n'),
                      ),
                      const SizedBox(height: MMass.s12),
                      RundgangVorlesen(key: ValueKey('rundgang-vorlesen-${teil.name}-$nr'), sitzung: s, text: text.vorlesen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Die Szene als Fotoabzug; solange sie lädt (oder ohne Ebenen) eine ruhige Fläche.
  Widget _kartenBild(BuildContext context) {
    final f = MFarben.von(context);
    final k = _karte;
    return Semantics(
      label: _de.rundgang_karte_semantik,
      container: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MMass.r10),
        child: ColoredBox(
          color: f.nachtOben,
          child: k == null
              ? Center(
                  child: _ladeFehler
                      ? Icon(Icons.map_outlined, color: f.linieStark, size: 40)
                      : const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Keller.kerze, strokeWidth: 3)),
                )
              : GameView(
                  key: const ValueKey('rundgang-szene'),
                  session: k,
                  steuerung: false,
                  kameraPassend: true,
                  umgebung: SzenenUmgebung(mitte: Color.lerp(f.nachtOben, f.schein, 0.1)!, rand: f.grund),
                ),
        ),
      ),
    );
  }
}

/// Die Karte einer Station nach R17: Titel und höchstens drei Stichpunkte auf
/// einer Karteikarte, darüber der Zähler. Nie der Vorlesetext. Gleich am Tisch
/// und auf der Gastseite.
class RundgangKarteBlatt extends StatelessWidget {
  const RundgangKarteBlatt({super.key, required this.text, this.zaehler});

  final RundgangText text;

  /// „Station 2 von 6“, sonst nichts.
  final String? zaehler;

  @override
  Widget build(BuildContext context) => MBlatt(
        art: PapierArt.karteikarte,
        kopfLinie: 7,
        linien: false,
        neigung: -0.004,
        samen: text.titel.codeUnits.fold(11, (a, b) => (a * 31 + b) & 0xffff),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (zaehler case final z?) ...[
              Text(z.toUpperCase(), style: MPapierSchrift.marke),
              const SizedBox(height: MMass.s4),
            ],
            MGanzeWorte(text.titel, stil: MPapierSchrift.ueberschrift, minimum: 16),
            const SizedBox(height: MMass.s8),
            for (final p in text.punkte)
              Padding(
                padding: const EdgeInsets.only(bottom: MMass.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 10),
                      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: MRoh.stempelRot.withValues(alpha: 0.8), shape: BoxShape.circle)),
                    ),
                    Expanded(child: Text(p, style: MPapierSchrift.text)),
                  ],
                ),
              ),
          ],
        ),
      );
}

/// Der Vorlesetext einer Station, nur für den Vorleser-Sitz (wie
/// [ErzaehlerFeld]): Wer nicht vorliest, sieht, wer liest; sitzt reihum ein
/// Erzähler am Tisch, liegt der Text zugedeckt im Pult. Im Solo und ohne
/// Erzähler steht er offen unter der Karte; ab dem Finale lesen alle.
class RundgangVorlesen extends StatelessWidget {
  const RundgangVorlesen({super.key, required this.sitzung, required this.text});

  final PartySitzung sitzung;
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = sitzung;
    if (!s.istVorleser) {
      final wer = s.vorleserName.trim().isEmpty ? _de.vorleser_erzaehler : s.vorleserName.trim();
      final amHandy = s.begleitung?.liest ?? false;
      return VorleserKarte(
        name: s.vorleserName,
        texte: 1,
        hinweis: s.uebernahmeFrist
            ? _de.vorleser_frist(wer)
            : amHandy
                ? _de.begleiter_handy_hinweis(wer)
                : null,
      );
    }
    if (s.erzaehlerAmPult && !s.pultOffen) return ErzaehlerpultZu(sitzung: s, texte: 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MBlatt(
          key: const ValueKey('rundgang-vorlesetext'),
          klammer: true,
          neigung: 0.004,
          samen: text.length,
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 20),
          child: MGanzeWorte(text, stil: MPapierSchrift.erzaehler, minimum: 14),
        ),
        if (s.erzaehlerAmPult && erzaehltextOffen(s)) ...[
          const SizedBox(height: MMass.s12),
          ErzaehlerpultZudecken(sitzung: s),
        ],
      ],
    );
  }
}
