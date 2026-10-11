import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/runden.dart' show AbstecherOrt, KartenKatalog, TischVorrat;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../detektei/akte_bausteine.dart';
import '../../detektei/akten.dart';
import '../../karten/katalog_laden.dart';
import '../../karten/widgets/deck_zeile.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../party/daten.dart';
import '../../party/sitzung.dart';
import '../../stil/stil.dart';
import '../abend_halter.dart';
import 'abschnitte.dart';

/// Spielweise eines Abends. Sie wird im Assistenten vor den Einstellungen gewählt.
enum Spielweise {
  /// Du ermittelst allein, Bots spielen die Gäste.
  solo,

  /// Ein Gerät geht reihum.
  reihum,

  /// Jede Person am eigenen Gerät (kommt später; heute gesperrt).
  eigene,
}

/// Schritte des Assistenten.
enum _Schritt { akte, spielweise, einstellungen, start }

/// Eine geladene Akte samt Sitzung und Einstellungen.
class _Geladen {
  _Geladen(this.akteId, this.sitzung, this.werte, this.abstecher);

  final String akteId;
  final PartySitzung sitzung;
  final EinrichtungsWerte werte;

  /// Erkundungsorte der Akte (leer, wenn die Akte keine hat).
  final List<AbstecherOrt> abstecher;
}

/// Assistent für einen neuen Abend (Route `/abend/neu`): Akte, Spielweise,
/// Einstellungen, Start. Der Start richtet die Sitzung ein und öffnet `/abend`.
class AbendNeuSeite extends StatefulWidget {
  const AbendNeuSeite({super.key, this.akteId});

  /// Vorgewählte Akte (von der Akte-Seite); der Assistent beginnt dann bei der Spielweise.
  final String? akteId;

  @override
  State<AbendNeuSeite> createState() => _AbendNeuSeiteState();
}

class _AbendNeuSeiteState extends State<AbendNeuSeite> {
  List<AkteInfo>? _akten;
  bool _aktenFehler = false;
  _Schritt _schritt = _Schritt.akte;
  String? _akteId;
  Spielweise? _weise;

  _Geladen? _geladen;
  String? _ladeId;
  bool _ladeFehler = false;
  bool _uebergeben = false;

  /// Katalog der Sammelkarten für die Zeile „Deck für diesen Abend“ (null, solange er lädt).
  KartenKatalog? _katalog;

  @override
  void initState() {
    super.initState();
    _akteId = widget.akteId;
    _leseAkten();
    _leseKatalog();
  }

  Future<void> _leseKatalog() async {
    try {
      final k = await kartenBereit(context.read<MetaStore>());
      if (mounted) setState(() => _katalog = k);
    } catch (e, st) {
      // Ohne Katalog läuft der Abend ohne Karten weiter.
      debugPrint('ABEND karten fehler $e\n$st');
    }
  }

  Future<void> _leseAkten() async {
    if (_aktenFehler) setState(() => _aktenFehler = false);
    try {
      final liste = await AktenKatalog.laden();
      if (!mounted) return;
      setState(() {
        _akten = liste;
        final bekannt = liste.any((a) => a.id == _akteId);
        if (bekannt) {
          // Von der Akte-Seite: Akte steht fest, weiter bei der Spielweise.
          _schritt = _Schritt.spielweise;
          _sichereLaden();
        } else {
          _akteId = liste.isEmpty ? null : liste.first.id;
        }
      });
    } catch (e, st) {
      debugPrint('ABEND akten fehler $e\n$st');
      if (mounted) setState(() => _aktenFehler = true);
    }
  }

  AkteInfo? get _akte => _akten?.where((a) => a.id == _akteId).firstOrNull;

  /// Lädt die gewählte Akte (einmal je Akte) und baut Sitzung und Einstellungen.
  void _sichereLaden() {
    final id = _akteId;
    if (id == null || _geladen?.akteId == id || _ladeId == id) return;
    _verwerfeGeladene();
    _ladeId = id;
    _ladeFehler = false;
    Future.wait<Object>([PartyDaten.laden(rootBundle, fall: id), ladeAbstecher(id)]).then((r) {
      if (!mounted || _ladeId != id) return;
      final s = PartySitzung(r[0] as PartyDaten);
      final werte = EinrichtungsWerte(s)..solo = _weise == Spielweise.solo;
      // Der Fußbereich hängt vom Fall-Code ab: bei jeder Eingabe neu zeichnen.
      werte.addListener(_werteGeaendert);
      setState(() => _geladen = _Geladen(id, s, werte, r[1] as List<AbstecherOrt>));
    }).catchError((Object e, StackTrace st) {
      debugPrint('ABEND laden fehler $e\n$st');
      if (mounted && _ladeId == id) setState(() => _ladeFehler = true);
    });
  }

  void _werteGeaendert() {
    if (mounted) setState(() {});
  }

  void _verwerfeGeladene() {
    final g = _geladen;
    _geladen = null;
    _ladeId = null;
    if (g != null) {
      g.werte.dispose();
      g.sitzung.dispose();
    }
  }

  @override
  void dispose() {
    final g = _geladen;
    if (g != null) {
      g.werte.dispose();
      // Eine übergebene Sitzung gehört schon dem Abend.
      if (!_uebergeben) g.sitzung.dispose();
    }
    super.dispose();
  }

  void _waehleAkte(String id) {
    if (id == _akteId) return;
    setState(() {
      _akteId = id;
      _verwerfeGeladene();
    });
  }

  void _waehleWeise(Spielweise w) {
    _weise = w;
    _geladen?.werte.solo = w == Spielweise.solo;
    setState(() {});
  }

  bool get _kannWeiter => switch (_schritt) {
        _Schritt.akte => _akte != null,
        _Schritt.spielweise => _weise == Spielweise.solo || _weise == Spielweise.reihum,
        _Schritt.einstellungen => _geladen != null && _geladen!.werte.codeOk,
        _Schritt.start => _geladen != null,
      };

  void _weiter() {
    if (!_kannWeiter) return;
    final naechster = _Schritt.values[(_schritt.index + 1).clamp(0, _Schritt.values.length - 1)];
    _geladen?.werte.solo = _weise == Spielweise.solo;
    setState(() {
      _schritt = naechster;
      if (naechster.index >= _Schritt.spielweise.index) _sichereLaden();
    });
  }

  void _zurueck() {
    if (_schritt == _Schritt.akte) {
      context.go(Routes.start);
    } else {
      setState(() => _schritt = _Schritt.values[_schritt.index - 1]);
    }
  }

  /// Startknopf: wie der alte Einrichtungsbildschirm richtet er die Sitzung ein
  /// ([EinrichtungsWerte.starten]) und übergibt sie dem Abend.
  void _starten() {
    final g = _geladen;
    if (g == null || _weise == null || _uebergeben) return;
    g.werte.solo = _weise == Spielweise.solo;
    // Das Deck des Geräts ist der Kartenvorrat des Abends (Solo wie reihum);
    // die Erkundungsorte gehören zur Akte. Beides gilt vor der Einrichtung.
    final katalog = _katalog;
    g.sitzung.kartenAnlegen(
      vorrat: katalog == null ? null : TischVorrat.aus(context.read<MetaStore>().deck, katalog),
      abstecher: g.abstecher,
    );
    g.werte.starten();
    _uebergeben = true;
    context.read<AbendHalter>().uebernehmen(g.sitzung);
    context.go(Routes.abend);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final nummer = _schritt.index + 1;
    final (titel, untertitel) = switch (_schritt) {
      _Schritt.akte => (l.abend_akte_titel, l.abend_akte_hinweis),
      _Schritt.spielweise => (l.abend_spielweise_titel, l.abend_spielweise_hinweis),
      _Schritt.einstellungen => (
          l.abend_einstellungen_titel,
          _geladen?.sitzung.ui(_weise == Spielweise.solo ? 'ui.solo.einrichtung' : 'ui.einrichtung.hinweis'),
        ),
      _Schritt.start => (l.abend_start_titel, l.abend_start_hinweis),
    };
    final letzter = _schritt == _Schritt.start;
    return AkteThema(
      akte: _akteId ?? '',
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: MFarben.von(context).grund,
          body: MRahmen(
            marke: l.abend_schritt(nummer, _Schritt.values.length),
            titel: titel,
            untertitel: untertitel,
            kopf: _Schrittanzeige(aktuell: _schritt.index),
            aktionen: [
              MKnopf(
                text: _schritt == _Schritt.akte ? l.common_cancel : l.common_back,
                art: MKnopfArt.zweit,
                onPressed: _zurueck,
              ),
              MKnopf(
                text: letzter ? l.abend_start : l.abend_weiter,
                icon: letzter ? Icons.play_arrow_rounded : null,
                onPressed: _kannWeiter ? (letzter ? _starten : _weiter) : null,
              ),
            ],
            child: AnimatedSwitcher(
              duration: MBewegung.normal(context),
              layoutBuilder: (aktuell, vorher) => Stack(alignment: Alignment.topCenter, children: [...vorher, ?aktuell]),
              child: KeyedSubtree(key: ValueKey(_schritt), child: _inhalt(context, l)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inhalt(BuildContext context, L l) {
    switch (_schritt) {
      case _Schritt.akte:
        final akten = _akten;
        if (_aktenFehler) return _Fehler(text: l.detektei_akten_fehler, nochmal: _leseAkten);
        if (akten == null) return _Laedt(text: l.appLoading);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final a in akten) AkteKarte(akte: a, gewaehlt: a.id == _akteId, onTap: () => _waehleAkte(a.id)),
          ],
        );
      case _Schritt.spielweise:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WeiseOption(
              icon: Icons.smart_toy_outlined,
              titel: l.abend_spielweise_solo,
              text: l.abend_spielweise_solo_text,
              gewaehlt: _weise == Spielweise.solo,
              onTap: () => _waehleWeise(Spielweise.solo),
            ),
            _WeiseOption(
              icon: Icons.groups_2_outlined,
              titel: l.abend_spielweise_reihum,
              text: l.abend_spielweise_reihum_text,
              gewaehlt: _weise == Spielweise.reihum,
              onTap: () => _waehleWeise(Spielweise.reihum),
            ),
            _WeiseOption(
              icon: Icons.devices_outlined,
              titel: l.abend_spielweise_eigene,
              text: l.abend_spielweise_eigene_text,
              gewaehlt: false,
              gesperrtHinweis: l.abend_spielweise_eigene_bald,
              baldText: l.detektei_bald,
              onTap: null,
            ),
          ],
        );
      case _Schritt.einstellungen:
        if (_ladeFehler) {
          return _Fehler(
            text: l.abend_fehler,
            nochmal: () => setState(() {
              _ladeId = null;
              _sichereLaden();
            }),
          );
        }
        final g = _geladen;
        if (g == null) return _Laedt(text: l.abend_laedt);
        return EinrichtungsAbschnitte(werte: g.werte);
      case _Schritt.start:
        final g = _geladen;
        final akte = _akte;
        if (g == null || akte == null) return _Laedt(text: l.abend_laedt);
        return ListenableBuilder(
          listenable: g.werte,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MTafel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Zeile(l.abend_start_akte, akte.titel),
                    _Zeile(
                      l.abend_start_spielweise,
                      _weise == Spielweise.solo ? l.abend_spielweise_solo : l.abend_spielweise_reihum,
                    ),
                    _Zeile(l.abend_start_personen, '${g.werte.rollen}'),
                    if (_weise != Spielweise.solo) _Zeile(l.abend_start_dauer, l.common_minutes(g.werte.minuten), letzte: true),
                  ],
                ),
              ),
              const SizedBox(height: MMass.s12),
              // Das Deck dieses Geräts liegt am Abend als gemeinsame Hilfe auf dem Tisch.
              DeckZeile(katalog: _katalog, onAendern: () => context.push(Routes.sammlungDeck)),
            ],
          ),
        );
    }
  }
}

/// Vier Balken: erledigte und aktuelle Schritte sind gefüllt.
class _Schrittanzeige extends StatelessWidget {
  const _Schrittanzeige({required this.aktuell});

  final int aktuell;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final f = MFarben.von(context);
    final namen = [l.abend_schritt_akte, l.abend_schritt_spielweise, l.abend_schritt_einstellungen, l.abend_schritt_start];
    return Semantics(
      label: '${l.abend_schritt(aktuell + 1, namen.length)}: ${namen[aktuell]}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < namen.length; i++) ...[
            if (i > 0) const SizedBox(width: MMass.s8),
            Expanded(
              child: AnimatedContainer(
                duration: MBewegung.normal(context),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= aktuell ? f.akzent : f.flaecheHoch,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Eine Spielweise zur Wahl. Mit [gesperrtHinweis] ist sie sichtbar, aber gesperrt.
class _WeiseOption extends StatelessWidget {
  const _WeiseOption({
    required this.icon,
    required this.titel,
    required this.text,
    required this.gewaehlt,
    required this.onTap,
    this.gesperrtHinweis,
    this.baldText,
  });

  final IconData icon;
  final String titel;
  final String text;
  final bool gewaehlt;
  final VoidCallback? onTap;
  final String? gesperrtHinweis;
  final String? baldText;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final t = MSchrift.von(context);
    final gesperrt = gesperrtHinweis != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: Semantics(
        button: true,
        enabled: !gesperrt,
        selected: gewaehlt,
        label: titel,
        hint: gesperrt ? gesperrtHinweis : text,
        onTap: onTap,
        excludeSemantics: true,
        child: Opacity(
          opacity: gesperrt ? 0.62 : 1,
          child: MTafel(
            hervorgehoben: gewaehlt,
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(MMass.s16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: gewaehlt ? f.akzent : f.papierLeise, size: 30),
                      const SizedBox(width: MMass.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(titel, style: t.ueberschrift),
                            const SizedBox(height: MMass.s4),
                            Text(text, style: t.leise),
                            if (gesperrt) ...[
                              const SizedBox(height: MMass.s8),
                              Row(
                                children: [
                                  if (baldText != null) ...[MChip(baldText!, farbe: f.papierLeise), const SizedBox(width: MMass.s8)],
                                  Expanded(child: Text(gesperrtHinweis!, style: t.leise.copyWith(fontSize: 13))),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!gesperrt) ...[
                        const SizedBox(width: MMass.s8),
                        Icon(gewaehlt ? Icons.check_circle_rounded : Icons.circle_outlined, color: gewaehlt ? f.akzent : f.papierLeise),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Zeile der Zusammenfassung: Marke und Wert.
class _Zeile extends StatelessWidget {
  const _Zeile(this.marke, this.wert, {this.letzte = false});

  final String marke;
  final String wert;
  final bool letzte;

  @override
  Widget build(BuildContext context) {
    final t = MSchrift.von(context);
    return Padding(
      padding: EdgeInsets.only(bottom: letzte ? 0 : MMass.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(marke.toUpperCase(), style: t.marke),
          const SizedBox(height: MMass.s4),
          Text(wert, style: t.ueberschrift),
        ],
      ),
    );
  }
}

/// Ladeanzeige; bei „Bewegung reduzieren“ ohne drehenden Kreis.
class _Laedt extends StatelessWidget {
  const _Laedt({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: MMass.s32),
        child: Column(
          children: [
            if (!MBewegung.ruhig(context)) ...[
              const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3)),
              const SizedBox(height: MMass.s16),
            ],
            Text(text, textAlign: TextAlign.center, style: MSchrift.von(context).leise),
          ],
        ),
      );
}

/// Fehlermeldung mit „Nochmal versuchen“.
class _Fehler extends StatelessWidget {
  const _Fehler({required this.text, required this.nochmal});

  final String text;
  final VoidCallback nochmal;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return MTafel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, style: MSchrift.von(context).text),
          const SizedBox(height: MMass.s12),
          MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: nochmal),
        ],
      ),
    );
  }
}
