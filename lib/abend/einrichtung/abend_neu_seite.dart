import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte_core/runden.dart' show AbstecherOrt, KartenKatalog, TischVorrat;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../detektei/akte_bausteine.dart' show akteSigel, akteTonText;
import '../../detektei/akten.dart';
import '../../karten/katalog_laden.dart';
import '../../karten/widgets/deck_zeile.dart';
import '../../l10n/lookup.dart';
import '../../meta/meta_store.dart';
import '../../netz/ablage_prefs.dart';
import '../../party/daten.dart';
import '../../party/sitzung.dart';
import '../../stil/mappe/assistent_formular.dart';
import '../../stil/stil.dart';
import '../abend_halter.dart';
import '../online/gastgeber_dienst.dart';
import '../online/online_halter.dart';
import 'abschnitte.dart';
import 'klasse_zeile.dart';

/// Spielweise eines Abends. Sie wird im Assistenten vor den Einstellungen gewählt.
enum Spielweise {
  /// Du ermittelst allein, Bots spielen die Gäste.
  solo,

  /// Ein Gerät geht reihum.
  reihum,

  /// Jede Person am eigenen Gerät: online über einen Raumcode, ein Gerät führt.
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

  /// Der Raum für „Jeder am eigenen Gerät“ wird gerade geöffnet.
  bool _oeffnet = false;
  bool _oeffnenFehler = false;

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
      // Eine Druckfassung gibt es nur für Akten mit Druckmappe.
      final druckbar = _akten?.where((a) => a.id == id).firstOrNull?.druckbar ?? false;
      final werte = EinrichtungsWerte(s, druckbar: druckbar)..solo = _weise == Spielweise.solo;
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
        _Schritt.spielweise => _weise != null,
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
    if (_weise == Spielweise.eigene) {
      unawaited(_raumOeffnen());
      return;
    }
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

  /// „Jeder am eigenen Gerät“: Raum und Schlüssel anlegen und in die Lobby
  /// wechseln. Das Relais wird erst dort verbunden.
  Future<void> _raumOeffnen() async {
    final g = _geladen;
    if (g == null || _oeffnet) return;
    final meta = context.read<MetaStore>();
    final online = context.read<OnlineHalter>();
    final router = GoRouter.of(context);
    final standardName = L.of(context).name_default;
    setState(() {
      _oeffnet = true;
      _oeffnenFehler = false;
    });
    try {
      final katalog = _katalog ?? await kartenBereit(meta);
      final name = (meta.name ?? '').trim();
      final dienst = await GastgeberDienst.neu(
        daten: g.sitzung.daten,
        akteId: g.akteId,
        name: name.isEmpty ? standardName : name,
        detektiv: g.werte.detektiv,
        ablage: const AblagePrefs(),
        abstecher: g.abstecher,
        katalog: katalog,
        fallCodeEingabe: g.werte.codeEingabe,
        geburtstagskind: g.werte.geburtstag.text.trim(),
        minuten: g.werte.minuten,
        stimme: g.werte.stimme,
      );
      if (!mounted) {
        await dienst.schliessen();
        return;
      }
      online.uebernehmeDienst(dienst);
      router.go(Routes.abendLobby);
    } catch (e, st) {
      debugPrint('ABEND raum fehler $e\n$st');
      if (mounted) setState(() => _oeffnenFehler = true);
    } finally {
      if (mounted) setState(() => _oeffnet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final nummer = _schritt.index + 1;
    final namen = [l.abend_schritt_akte, l.abend_schritt_spielweise, l.abend_schritt_einstellungen, l.abend_schritt_start];
    final (titel, untertitel) = switch (_schritt) {
      _Schritt.akte => (l.abend_akte_titel, l.abend_akte_hinweis),
      _Schritt.spielweise => (l.abend_spielweise_titel, l.abend_spielweise_hinweis),
      _Schritt.einstellungen => (
          l.abend_einstellungen_titel,
          _weise == Spielweise.eigene
              ? l.online_einstellungen_hinweis
              : _geladen?.sitzung.ui(_weise == Spielweise.solo ? 'ui.solo.einrichtung' : 'ui.einrichtung.hinweis'),
        ),
      _Schritt.start => (l.abend_start_titel, l.abend_start_hinweis),
    };
    final letzter = _schritt == _Schritt.start;
    return AkteThema(
      akte: _akteId ?? '',
      child: Builder(
        // Die Zurück-Taste (Android) geht wie der Knopf einen Schritt zurück, statt die App zu verlassen.
        builder: (context) => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _zurueck();
          },
          child: Scaffold(
            backgroundColor: MFarben.von(context).grund,
            body: MRahmen(
              marke: l.abend_schritt(nummer, _Schritt.values.length),
              titel: titel,
              untertitel: untertitel,
              // Die Schritte als Registerreiter der Fallmappe.
              kopf: MRegisterSchritte(
                namen: namen,
                aktuell: _schritt.index,
                semantik: '${l.abend_schritt(nummer, namen.length)}: ${namen[_schritt.index]}',
              ),
              aktionen: [
                MKnopf(
                  text: _schritt == _Schritt.akte ? l.common_cancel : l.common_back,
                  art: MKnopfArt.zweit,
                  onPressed: _zurueck,
                ),
                MKnopf(
                  text: letzter ? (_weise == Spielweise.eigene ? l.online_raum_oeffnen : l.abend_start) : l.abend_weiter,
                  icon: letzter ? (_weise == Spielweise.eigene ? Icons.meeting_room_outlined : Icons.play_arrow_rounded) : null,
                  onPressed: _kannWeiter && !_oeffnet ? (letzter ? _starten : _weiter) : null,
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
            for (var i = 0; i < akten.length; i++)
              _AkteWahl(akte: akten[i], nr: i + 1, gewaehlt: akten[i].id == _akteId, onTap: () => _waehleAkte(akten[i].id)),
          ],
        );
      case _Schritt.spielweise:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WeiseKarte(
              nr: 1,
              icon: Icons.smart_toy_outlined,
              titel: l.abend_spielweise_solo,
              text: l.abend_spielweise_solo_text,
              gewaehlt: _weise == Spielweise.solo,
              onTap: () => _waehleWeise(Spielweise.solo),
            ),
            _WeiseKarte(
              nr: 2,
              icon: Icons.groups_2_outlined,
              titel: l.abend_spielweise_reihum,
              text: l.abend_spielweise_reihum_text,
              gewaehlt: _weise == Spielweise.reihum,
              onTap: () => _waehleWeise(Spielweise.reihum),
            ),
            _WeiseKarte(
              nr: 3,
              icon: Icons.devices_outlined,
              titel: l.abend_spielweise_eigene,
              text: l.abend_spielweise_eigene_text,
              gewaehlt: _weise == Spielweise.eigene,
              onTap: () => _waehleWeise(Spielweise.eigene),
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
        return EinrichtungsAbschnitte(werte: g.werte, online: _weise == Spielweise.eigene);
      case _Schritt.start:
        final g = _geladen;
        final akte = _akte;
        if (g == null || akte == null) return _Laedt(text: l.abend_laedt);
        final nr = (_akten?.indexOf(akte) ?? 0) + 1;
        return ListenableBuilder(
          listenable: g.werte,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Bereit(
                akte: akte,
                nr: nr,
                felder: [
                  (
                    l.abend_start_spielweise,
                    switch (_weise) {
                      Spielweise.solo => l.abend_spielweise_solo,
                      Spielweise.eigene => l.abend_spielweise_eigene,
                      _ => l.abend_spielweise_reihum,
                    },
                  ),
                  // Online legt die Lobby die Rollen fest, sobald klar ist, wer mitspielt.
                  if (_weise != Spielweise.eigene) (l.abend_start_personen, '${g.werte.rollen}'),
                  if (_weise != Spielweise.solo) (l.abend_start_dauer, l.common_minutes(g.werte.minuten)),
                ],
              ),
              const SizedBox(height: MMass.s32),
              // Die Klasse bestimmt die Karte der Belohnung, das Deck liegt am Abend als gemeinsame Hilfe auf dem Tisch.
              const KlasseZeile(),
              const SizedBox(height: MMass.s24),
              DeckZeile(katalog: _katalog, onAendern: () => context.push(Routes.sammlungDeck)),
              if (_weise == Spielweise.eigene) ...[
                const SizedBox(height: MMass.s24),
                MBlatt(
                  art: PapierArt.notiz,
                  klebestreifen: true,
                  neigung: 0.005,
                  samen: 71,
                  padding: const EdgeInsets.fromLTRB(40, 20, 18, 16),
                  child: Text(l.online_start_hinweis, style: MPapierSchrift.text.copyWith(fontSize: 15)),
                ),
                if (_oeffnenFehler) ...[
                  const SizedBox(height: MMass.s16),
                  _Fehler(text: l.online_oeffnen_fehler, nochmal: _raumOeffnen),
                ],
              ],
            ],
          ),
        );
    }
  }
}

/// Eine Akte zur Wahl: eine kleine Aktenmappe aus Manila mit Reiter, Siegel der
/// Akte, Titel und Untertitel. Die gewählte trägt den Stempel „Gewählt“ und
/// liegt dicker gefüllt da. Für den Bildschirmleser eine Auswahl mit dem Titel
/// als Beschriftung und dem Untertitel als Hinweis.
class _AkteWahl extends StatelessWidget {
  const _AkteWahl({required this.akte, required this.nr, required this.gewaehlt, required this.onTap});

  final AkteInfo akte;
  final int nr;
  final bool gewaehlt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final stil = AkteStil.fuer(akte.id);
    final min = akte.minRollen, max = akte.maxRollen;
    final angaben = [
      if (akte.ton.isNotEmpty) akteTonText(l, akte.ton),
      if (min != null && max != null) l.detektei_personen(min, max),
    ].join(' · ');
    Widget text(bool schmal) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(akte.titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: schmal ? 17 : 20, height: 1.25)),
        if (akte.untertitel.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(akte.untertitel, style: MPapierSchrift.kursiv.copyWith(fontSize: 15, height: 1.4, color: MRoh.tinteLeise)),
        ],
        if (angaben.isNotEmpty) ...[
          const SizedBox(height: MMass.s8),
          Text(angaben, style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: MRoh.tinteLeise)),
        ],
      ],
    );
    final mappe = LayoutBuilder(
      builder: (context, box) {
        // Schmal oder mit großer Schrift hängt das Siegel unten an der Mappe, der Text bekommt die ganze Breite.
        final skala = MediaQuery.textScalerOf(context).scale(1);
        final schmal = box.maxWidth < 260 * (skala < 1 ? 1 : skala);
        return MAktenmappe(
          reiter: 'Nr. ${nr.toString().padLeft(2, '0')}',
          farbe: stil.akzent,
          blaetter: gewaehlt ? 3 : 1,
          neigung: nr.isEven ? 0.004 : -0.003,
          siegel: schmal ? akteSigel(akte) : null,
          padding: schmal ? const EdgeInsets.fromLTRB(10, 12, 10, 30) : const EdgeInsets.fromLTRB(14, 12, 14, 14),
          onTap: onTap,
          child: schmal
              ? SizedBox(width: double.infinity, child: text(true))
              : Row(
                  children: [
                    MSiegel(kuerzel: akteSigel(akte), farbe: stil.akzent, groesse: 50),
                    const SizedBox(width: 14),
                    Expanded(child: text(false)),
                  ],
                ),
        );
      },
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s20),
      child: Semantics(
        button: true,
        selected: gewaehlt,
        label: akte.titel,
        hint: akte.untertitel,
        onTap: onTap,
        excludeSemantics: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            mappe,
            // Der Stempel schlägt neben dem Reiter auf die Oberkante der Mappe.
            if (gewaehlt)
              Positioned(
                top: 0,
                right: MMass.s16,
                child: IgnorePointer(child: MStempel(text: l.profil_klasse_gewaehlt, groesse: 14, winkel: -0.08, aufschlagen: true)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Eine Spielweise zur Wahl: eine Karteikarte mit gestempeltem Sinnbild, darunter
/// Ankreuzkästchen und Aktenzeichen, daneben Titel über der roten Linie und
/// Beschreibung. Die gewählte ist hervorgehoben, angekreuzt, und oben schlägt
/// der Stempel „Gewählt“ auf die Kante.
class _WeiseKarte extends StatelessWidget {
  const _WeiseKarte({
    required this.nr,
    required this.icon,
    required this.titel,
    required this.text,
    required this.gewaehlt,
    required this.onTap,
  });

  final int nr;
  final IconData icon;
  final String titel;
  final String text;
  final bool gewaehlt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final zeichen = Text('Nr. $nr', style: MPapierSchrift.maschine.copyWith(fontSize: 12, color: MRoh.tinteLeise));
    final karte = MBlatt(
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      onTap: onTap,
      hervorgehoben: gewaehlt,
      neigung: const [-0.004, 0.003, -0.002][(nr - 1) % 3],
      samen: 30 + nr,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: LayoutBuilder(
        builder: (context, box) {
          // Kästchen und Aktenzeichen stehen unter dem Sinnbild; der Text bekommt die volle Breite.
          final kennung = Row(
            mainAxisSize: MainAxisSize.min,
            children: [MKaestchen(gewaehlt: gewaehlt, groesse: 18, samen: nr * 7919), const SizedBox(width: 6), zeichen],
          );
          final inhalt = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20, height: 1.25)),
              const SizedBox(height: MMass.s4),
              Container(height: 1.4, color: MRoh.linieRot),
              const SizedBox(height: 6),
              Text(text, style: MPapierSchrift.text.copyWith(fontSize: 14, height: 1.45)),
            ],
          );
          // Schmal oder mit großer Schrift: Sinnbild, Kästchen und Aktenzeichen über dem Text.
          final skala = MediaQuery.textScalerOf(context).scale(1);
          if (box.maxWidth < 250 * (skala < 1 ? 1 : skala)) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Sinnbild(icon: icon, gewaehlt: gewaehlt),
                    const SizedBox(width: MMass.s12),
                    kennung,
                  ],
                ),
                const SizedBox(height: MMass.s8),
                inhalt,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [_Sinnbild(icon: icon, gewaehlt: gewaehlt), const SizedBox(height: 6), kennung],
              ),
              const SizedBox(width: 14),
              Expanded(child: inhalt),
            ],
          );
        },
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: Semantics(
        button: true,
        selected: gewaehlt,
        label: titel,
        hint: text,
        onTap: onTap,
        excludeSemantics: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            karte,
            // Der Stempel trifft die obere rechte Kante.
            if (gewaehlt)
              Positioned(
                top: -10,
                right: 10,
                child: IgnorePointer(child: MStempel(text: l.profil_klasse_gewaehlt, groesse: 14, winkel: -0.09, aufschlagen: true)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Sinnbild einer Spielweise: das Symbol in Füllertinte in einem doppelten
/// Stempelring, der gewählte Ring in Stempelrot.
class _Sinnbild extends StatelessWidget {
  const _Sinnbild({required this.icon, required this.gewaehlt});

  final IconData icon;
  final bool gewaehlt;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 58,
        child: CustomPaint(
          painter: _RingMaler(gewaehlt ? MRoh.stempelRot : MRoh.tinte.withValues(alpha: 0.5)),
          child: Center(child: Icon(icon, size: 30, color: gewaehlt ? MRoh.stempelRot : MRoh.tinteBlau)),
        ),
      );
}

class _RingMaler extends CustomPainter {
  _RingMaler(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final m = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..color = farbe;
    canvas.drawCircle(m, r - 1.5, p..strokeWidth = 2.2);
    canvas.drawCircle(m, r - 5.5, p..strokeWidth = 0.9);
  }

  @override
  bool shouldRepaint(covariant _RingMaler alt) => alt.farbe != farbe;
}

/// Der Start: die Fallmappe ist gepackt und versiegelt. Reiter mit Aktenzeichen,
/// Titel der Akte und die Angaben des Abends als Formularfelder; das Siegel der
/// Akte hält die Mappe zu, bis der Abend beginnt.
class _Bereit extends StatelessWidget {
  const _Bereit({required this.akte, required this.nr, required this.felder});

  final AkteInfo akte;
  final int nr;

  /// Feldname und Wert in Lesereihenfolge.
  final List<(String, String)> felder;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final stil = AkteStil.fuer(akte.id);
    return LayoutBuilder(
      builder: (context, box) {
        // Schmal oder mit großer Schrift: weniger Rand und ein kleinerer Titel, damit
        // lange Namen wie „Schlosskeller“ nicht mitten im Wort brechen.
        final skala = MediaQuery.textScalerOf(context).scale(1);
        final schmal = box.maxWidth < 300 * (skala < 1 ? 1 : skala);
        return _mappe(l, stil, schmal);
      },
    );
  }

  Widget _mappe(L l, AkteStil stil, bool schmal) => MAktenmappe(
      reiter: 'Nr. ${nr.toString().padLeft(2, '0')}',
      farbe: stil.akzent,
      siegel: akteSigel(akte),
      blaetter: 3,
      padding: schmal ? const EdgeInsets.fromLTRB(10, 14, 10, 34) : const EdgeInsets.fromLTRB(18, 16, 18, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.abend_start_akte, style: MPapierSchrift.maschine.copyWith(fontSize: 13, color: MRoh.tinteLeise)),
          const SizedBox(height: 2),
          Text(akte.titel, style: schmal ? MPapierSchrift.ueberschrift.copyWith(fontSize: 17, height: 1.25) : MPapierSchrift.ueberschrift),
          if (akte.untertitel.isNotEmpty) ...[
            const SizedBox(height: MMass.s4),
            Text(akte.untertitel, style: MPapierSchrift.kursiv.copyWith(fontSize: 15, height: 1.4, color: MRoh.tinteLeise)),
          ],
          const SizedBox(height: MMass.s12),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: MMass.s12),
          LayoutBuilder(
            builder: (context, box) {
              // Zwei Spalten wie auf einem Formular, schmal untereinander.
              final skala = MediaQuery.textScalerOf(context).scale(1);
              final zwei = box.maxWidth >= 240 * (skala < 1 ? 1 : skala);
              final breite = zwei ? (box.maxWidth - MMass.s16) / 2 : box.maxWidth;
              return Wrap(
                spacing: MMass.s16,
                children: [
                  for (final (name, wert) in felder) SizedBox(width: breite, child: MFeld(name: name, wert: wert)),
                ],
              );
            },
          ),
        ],
      ),
    );
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
              const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, color: MRoh.messingMitte)),
              const SizedBox(height: MMass.s16),
            ],
            Text(text, textAlign: TextAlign.center, style: MSchrift.von(context).leise),
          ],
        ),
      );
}

/// Fehlermeldung als Telegramm mit „Nochmal versuchen“.
class _Fehler extends StatelessWidget {
  const _Fehler({required this.text, required this.nochmal});

  final String text;
  final VoidCallback nochmal;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return MBlatt(
      art: PapierArt.telegramm,
      neigung: -0.004,
      samen: 83,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: MRoh.stempelRot),
              const SizedBox(width: MMass.s12),
              Expanded(child: Text(text, style: MPapierSchrift.telegramm.copyWith(fontSize: 17))),
            ],
          ),
          const SizedBox(height: MMass.s16),
          Align(
            alignment: Alignment.centerLeft,
            child: MKnopf(text: l.abend_nochmal, art: MKnopfArt.zweit, onPressed: nochmal),
          ),
        ],
      ),
    );
  }
}
