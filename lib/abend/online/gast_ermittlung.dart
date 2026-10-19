import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show KlassenFaehigkeit, LookDef;
import 'package:mordakte_core/runden.dart' show KartenArt;
import 'package:provider/provider.dart';

import '../../game/game_view.dart';
import '../../karten/widgets/karten_ansicht.dart' show KartenTexte;
import '../../meta/meta_store.dart';
import '../../party/bildschirme/befragung.dart' show BefragungsKarte, BefragungsListe;
import '../../party/bildschirme/detektiv_karte.dart' show DetektivKarteEintrag;
import '../../party/klasse_wirkung.dart';
import '../../party/stand/befragung_stand.dart' show BefragungKarte;
import '../../stil/mappe/online_bausteine.dart';
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_ansicht.dart' show GastKontext, GastWuerfel;
import 'gast_befragung.dart';
import 'gast_karte_session.dart';
import 'gast_lese_sitzung.dart';
import 'online_teile.dart';

/// Der Gast auf dem Detektiv-Sitz (Langer Abend M3): ermittelt am eigenen
/// Handy. Alles kommt aus seiner Ansicht des Raums (Positivliste), jede
/// Handlung geht als Raumnachricht hinaus; der Raum nimmt Ermittlung nur vom
/// Detektiv-Sitz an. Neues steht im Kartenformat R17, die Wortlaute der
/// Oberfläche kommen wie am Tisch aus den Bausteinen (`ui.*`).
///
/// - Rollen: die Detektivkarte (Auftrag, Regeln, Klasse des Sitzes, M6.4).
/// - Gespräche: die Befragungskarten aus M2 ([BefragungsListe]); wer am Tisch
///   antwortet, markiert der Detektiv als beantwortet.
/// - Entscheidungen: [GastErmittlung] mit Karte, Optionen, „gründlich“, Karten,
///   „Das ist endgültig“, Abstecher, Tischruf, Fund und Notizbuch.
/// - Anklage: [GastAnklage].
List<Widget> gastDetektivRollen(GastKontext c) {
  final s = GastLeseSitzung.fuer(c);
  if (s == null) return const [];
  return [Padding(padding: const EdgeInsets.only(bottom: MMass.s16), child: DetektivKarteEintrag(sitzung: s))];
}

/// Die Befragungen des Gast-Detektivs in den Gesprächen (A-051): feste und frei
/// gewählte, Antwort einer App-Rolle erst nach der Frage; darunter öffentlich,
/// wer am Tisch mit wem worüber spricht.
Widget gastDetektivGespraeche(GastKontext c) {
  final s = GastLeseSitzung.fuer(c);
  if (s == null) return const SizedBox.shrink();
  final fertig = c.v['kannWeiter'] == true;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OnlineRegisterKopf(s.ui('ui.befragung.titel').toUpperCase()),
      Text(s.ui('ui.befragung.hinweis_tisch'), style: MSchrift.von(c.context).leise),
      const SizedBox(height: MMass.s12),
      // Eine Frage zeigt sich gleich als gestellt, noch bevor der Raum antwortet.
      ListenableBuilder(
        listenable: s,
        builder: (_, _) => BefragungsListe(
          sitzung: s,
          onFrage: c.verbunden ? s.befragen : null,
          aktionen: (k) => [
            if (k.gefragt && k.mensch && !k.erledigt)
              Semantics(
                container: true,
                identifier: 'befragung-beantwortet-${k.id}',
                child: MKnopf(text: s.ui('ui.befragung.beantwortet'), onPressed: c.verbunden ? () => s.befragungErledigt(k.id) : null),
              ),
          ],
        ),
      ),
      if (!fertig) Padding(padding: const EdgeInsets.only(bottom: MMass.s12), child: Text(s.ui('ui.befragung.offen'), style: MSchrift.von(c.context).text)),
      GastBefragung(c: c),
      _Notizbuch(kontext: c),
    ],
  );
}

/// Die Ermittlung des Gast-Detektivs in einer Runde: die Karte oben (nur
/// lesend, das gewählte Ziel funkelt, der Weg läuft sichtbar), darunter je
/// Zugabschnitt eine Karte zum Handeln.
class GastErmittlung extends StatefulWidget {
  const GastErmittlung({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  State<GastErmittlung> createState() => _GastErmittlungState();
}

class _GastErmittlungState extends State<GastErmittlung> {
  GastKarteSession? _karte;
  String? _option;
  bool _gruendlich = false;
  String? _gruendlichKarte;
  String? _abstecher;
  String? _abstecherKarte;
  bool _laeuft = false;

  GastKontext get c => widget.kontext;
  GastLeseSitzung? get s => GastLeseSitzung.fuer(c);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nur die ausdrückliche Systemeinstellung kürzt den sichtbaren Weg ab.
    _karte?.bewegungReduziert = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void didUpdateWidget(covariant GastErmittlung alt) {
    super.didUpdateWidget(alt);
    final e = _entscheidung;
    // Eine neue Frage beginnt ohne Vorschlag.
    if (e == null || !_optionen(e).any((o) => o['id'] == _option)) {
      _option = null;
      _gruendlich = false;
      _gruendlichKarte = null;
    }
    if (_zug != null) _abstecher = null;
    _karte?.markiert = _option;
    _karte?.ansichtGeaendert();
  }

  @override
  void dispose() {
    unawaited(_karte?.dispose());
    super.dispose();
  }

  Map<String, Object?>? get _entscheidung => c.v['entscheidung'] is Map ? jMap(c.v['entscheidung']) : null;
  Map<String, Object?>? get _zug => c.v['zug'] is Map ? jMap(c.v['zug']) : null;
  List<Map<String, Object?>> _optionen(Map<String, Object?> e) => jMaps(e['optionen']);
  List<Map<String, Object?>> get _vorrat => jMaps(c.v['vorrat']);

  /// Karten des Tisches einer Art mit Ladung.
  List<Map<String, Object?>> _karten(Set<KartenArt> arten) => [
        for (final k in _vorrat)
          if (arten.any((a) => a.name == k['art']) && jZahl(k['rest']) > 0) k,
      ];

  String _titel(Map<String, Object?> karte) => c.dienst.katalog?[jText(karte['id'])]?.titel ?? KartenTexte.art(KartenArt.aus(jText(karte['art'])));

  /// Die Karte des Detektivs, sobald die Akte da ist; die Klasse des Sitzes wirkt wie am Tisch.
  GastKarteSession? _karteSession() {
    final daten = c.daten;
    if (daten == null) return null;
    return _karte ??= () {
      final quelle = AnsichtsKartenQuelle(daten, () => widget.kontext.v);
      final klasse = c.privat['klasse'] is String ? c.privat['klasse'] as String : context.read<MetaStore?>()?.loadout.cls;
      final f = KlassenFaehigkeit.vonKlasse(klasse);
      final menschen = {for (final p in c.spieler) ?p.rolle};
      return GastKarteSession(
        daten,
        quelle,
        name: () => c.nameVon(c.ichId),
        // Die eigene Meldung kommt still: War der Gastgeber schneller, ist sie veraltet.
        onAktionFertig: (nr) => unawaited(widget.kontext.dienst.befehl({'typ': 'aktionFertig', 'aktion': nr})),
        klasse: f == null || !daten.hat('klassen')
            ? null
            : KlasseWirkung(faehigkeit: f, daten: daten, quelle: quelle, appSprichtFuer: (figur) => !menschen.contains(figur)),
      )
        ..markiert = _option
        ..bewegungReduziert = MediaQuery.disableAnimationsOf(context);
    }();
  }

  Future<void> _senden(Map<String, Object?> nachricht) async {
    if (_laeuft) return;
    setState(() => _laeuft = true);
    try {
      await c.befehl(nachricht);
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = c.l;
    final karte = _karteSession();
    final offen = c.verbunden && !_laeuft;
    final z = _zug;
    final e = _entscheidung;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (karte != null)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MMass.r10),
              // Nur lesend: Die Seite rollt über die Karte hinweg.
              child: SizedBox(height: 260, child: IgnorePointer(child: GameView(key: const ValueKey('gast-karte'), session: karte, steuerung: false, kameraPassend: true))),
            ),
          ),
        Wrap(
          spacing: MMass.s8,
          runSpacing: MMass.s8,
          children: [
            for (final (text, icon) in [(l.online_nachtzeit(jZahl(c.v['restMinuten'])), Icons.nightlight_round), (l.online_marken(jZahl(c.v['marken'])), Icons.sell_outlined)])
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: MChip(text, icon: icon, passend: true)),
          ],
        ),
        const SizedBox(height: MMass.s16),
        if (z != null) ..._zugTeile(z, offen) else if (e != null) ..._frage(e, offen) else ..._fertig(offen),
        _Notizbuch(kontext: c),
      ],
    );
  }

  // ---------------------------------------------------------------- Frage

  /// Die offene Entscheidung: Optionen zur Wahl (das Ziel funkelt auf der
  /// Karte), „gründlich“ bei einer Suche, Karten dafür und „Das ist endgültig“.
  List<Widget> _frage(Map<String, Object?> e, bool offen) {
    final s = this.s;
    if (s == null) return const [];
    final l = c.l;
    final optionen = _optionen(e);
    final suche = e['suche'] == true;
    final gruendlichKarten = _karten({KartenArt.gruendlich});
    final sofort = _karten({KartenArt.zeit, KartenArt.marke, KartenArt.erinnerung});
    final abstecher = jMaps(c.v['abstecher']);
    return [
      _blatt(
        jText(e['frage']),
        [
          Text(l.detektiv_gast_optionen, style: MPapierSchrift.leise),
          const SizedBox(height: MMass.s8),
          for (final o in optionen)
            _Wahl(
              key: ValueKey('option-${o['id']}'),
              text: jText(o['text']),
              gewaehlt: _option == o['id'],
              onTap: () => setState(() {
                _option = jText(o['id']);
                _karte?.markiert = _option;
              }),
            ),
          if (_option != null) ...[
            const SizedBox(height: MMass.s12),
            Text(s.ui('ui.karte.endgueltig'), style: MPapierSchrift.text),
            Text(s.ui('ui.zug.wahl_bindung'), style: MPapierSchrift.leise),
            if (suche)
              MHaken(
                key: const ValueKey('gruendlich'),
                wert: _gruendlich,
                text: s.ui('ui.zug.gruendlich'),
                onChanged: (v) => setState(() {
                  _gruendlich = v;
                  if (!v) _gruendlichKarte = null;
                }),
              ),
            if (suche)
              for (final k in gruendlichKarten)
                MHaken(
                  key: ValueKey('gruendlich-${k['id']}'),
                  wert: _gruendlichKarte == k['id'],
                  text: l.detektiv_gast_karte_gruendlich(_titel(k)),
                  onChanged: (v) => setState(() {
                    _gruendlichKarte = v ? jText(k['id']) : null;
                    _gruendlich = v || _gruendlich;
                  }),
                ),
            const SizedBox(height: MMass.s12),
            Wrap(
              spacing: MMass.s8,
              runSpacing: MMass.s8,
              children: [
                MKnopf(text: s.ui('ui.karte.nein'), art: MKnopfArt.zweit, onPressed: () => setState(() => _option = null)),
                MKnopf(
                  key: const ValueKey('option-bestaetigen'),
                  text: s.ui('ui.karte.ja'),
                  onPressed: offen
                      ? () => _senden({
                            'typ': 'wahl',
                            'option': _option,
                            if (suche && _gruendlich) 'gruendlich': true,
                            if (suche && _gruendlich) 'karte': ?_gruendlichKarte,
                          })
                      : null,
                ),
              ],
            ),
          ],
        ],
        hervorgehoben: true,
      ),
      if (sofort.isNotEmpty)
        _blatt(KartenTexte.handTitel, [
          for (final k in sofort)
            Padding(
              padding: const EdgeInsets.only(bottom: MMass.s8),
              child: MKnopf(
                key: ValueKey('karte-${k['id']}'),
                text: l.detektiv_gast_karte_spielen(_titel(k)),
                art: MKnopfArt.zweit,
                breit: true,
                onPressed: offen ? () => _senden({'typ': 'karte', 'id': k['id']}) : null,
              ),
            ),
        ]),
      ..._erkunden(abstecher, offen),
    ];
  }

  /// Offene Abstecher: „Erkunden: …“, dann eine Bestätigung mit Abstecher-Karte.
  List<Widget> _erkunden(List<Map<String, Object?>> abstecher, bool offen) {
    if (abstecher.isEmpty) return const [];
    final l = c.l;
    final gewaehlt = abstecher.where((a) => a['id'] == _abstecher).firstOrNull;
    final karten = _karten({KartenArt.abstecher});
    return [
      _blatt(KartenTexte.erkundenListe, [
        if (gewaehlt == null)
          for (final a in abstecher)
            Padding(
              padding: const EdgeInsets.only(bottom: MMass.s8),
              child: MKnopf(
                key: ValueKey('erkunden-${a['id']}'),
                text: KartenTexte.erkunden(jText(a['name'])),
                art: MKnopfArt.zweit,
                breit: true,
                onPressed: offen ? () => setState(() => _abstecher = jText(a['id'])) : null,
              ),
            )
        else ...[
          Text(jText(gewaehlt['name']), style: MPapierSchrift.ueberschrift),
          Text(KartenTexte.erkundenText, style: MPapierSchrift.text),
          for (final k in karten)
            MHaken(
              wert: _abstecherKarte == k['id'],
              text: KartenTexte.erkundenKarte(_titel(k)),
              onChanged: (v) => setState(() => _abstecherKarte = v ? jText(k['id']) : null),
            ),
          const SizedBox(height: MMass.s8),
          Wrap(
            spacing: MMass.s8,
            runSpacing: MMass.s8,
            children: [
              MKnopf(text: KartenTexte.erkundenNein, art: MKnopfArt.zweit, onPressed: () => setState(() => _abstecher = null)),
              MKnopf(
                key: const ValueKey('erkunden-los'),
                text: KartenTexte.erkundenLos,
                onPressed: offen ? () => _senden({'typ': 'abstecher', 'ort': gewaehlt['id'], 'karte': ?_abstecherKarte}) : null,
              ),
            ],
          ),
          Text(l.online_abstecher, style: MPapierSchrift.leise),
        ],
      ]),
    ];
  }

  // ------------------------------------------------------------------ Zug

  List<Widget> _zugTeile(Map<String, Object?> z, bool offen) {
    final s = this.s;
    if (s == null) return const [];
    final l = c.l;
    final wurf = z['wurf'] is Map ? jMap(z['wurf']) : null;
    switch (jText(z['phase'])) {
      case 'aktion':
        return [_notiz(l.detektiv_gast_unterwegs, schluessel: 'gast-unterwegs')];
      case 'wurf':
        return [GastWuerfel(kontext: c, zug: z)];
      case 'tischruf':
        // Wie am Tisch (TischrufTafel): Eine Karte löst ihren eigenen Ruf aus
        // und macht ihn kostenfrei; die Knöpfe darunter rufen ohne Karte.
        final karten = _karten({KartenArt.nochmal, KartenArt.umweg});
        return [
          if (wurf != null) _wurf(wurf),
          _blatt(s.ui('ui.zug.tischruf'), [
            Text(s.ui('ui.zug.pech_szene'), style: MPapierSchrift.text),
            const SizedBox(height: MMass.s12),
            for (final k in karten)
              Padding(
                padding: const EdgeInsets.only(bottom: MMass.s8),
                child: MKnopf(
                  key: ValueKey('ruf-karte-${k['id']}'),
                  text: l.detektiv_gast_karte_ruf(_titel(k)),
                  art: MKnopfArt.zweit,
                  breit: true,
                  onPressed: offen ? () => _senden({'typ': 'tischruf', 'ruf': k['art'], 'karte': k['id']}) : null,
                ),
              ),
            Wrap(
              spacing: MMass.s8,
              runSpacing: MMass.s8,
              children: [
                MKnopf(
                  key: const ValueKey('ruf-nochmal'),
                  text: s.ui('ui.zug.nochmal'),
                  onPressed: offen ? () => _senden({'typ': 'tischruf', 'ruf': 'nochmal'}) : null,
                ),
                MKnopf(
                  key: const ValueKey('ruf-umweg'),
                  text: s.ui('ui.zug.umweg_knopf'),
                  art: MKnopfArt.zweit,
                  onPressed: offen ? () => _senden({'typ': 'tischruf', 'ruf': 'umweg'}) : null,
                ),
              ],
            ),
          ], hervorgehoben: true),
        ];
      case 'fund':
        final funde = jTexte(z['funde']);
        final neben = jText(z['nebenfund']);
        final auftakt = jText(z['id']) == 'auftakt';
        return [
          if (wurf != null) _wurf(wurf),
          _blatt(c.l.online_fund_titel, [
            for (final f in funde) _punkt(f),
            if (neben.isNotEmpty) Text(neben, style: MPapierSchrift.text),
            const SizedBox(height: MMass.s12),
            MKnopf(
              key: const ValueKey('fund-gelesen'),
              text: s.ui(auftakt ? 'ui.zug.auftakt_weiter' : 'ui.karte.gelesen'),
              onPressed: offen ? () => _senden({'typ': 'fundGelesen'}) : null,
            ),
          ], hervorgehoben: true),
        ];
    }
    return const [];
  }

  List<Widget> _fertig(bool offen) {
    final s = this.s;
    return [
      if (s != null) _notiz(s.ui('ui.karte.fertig'), uhr: false),
      ..._erkunden(jMaps(c.v['abstecher']), offen),
    ];
  }

  // ------------------------------------------------------------- Bausteine

  Widget _wurf(Map<String, Object?> w) {
    final l = c.l;
    final summe = jZahl(w['a']) + jZahl(w['b']) + jZahl(w['mod']);
    return _blatt(l.online_wurf_titel, [
      Text(c.stufeWort(jText(w['stufe'])), style: MPapierSchrift.titel),
      Text(l.online_wurf_rechnung(jZahl(w['a']), jZahl(w['b']), jZahl(w['mod']), summe), style: MPapierSchrift.maschine),
    ]);
  }
}

/// Die Anklage des Gast-Detektivs: die Kernverdächtigen als gleich gesetzte
/// Fotoabzüge; einer wird markiert, dann „Das ist endgültig“. Danach steht nur
/// noch, wen er angeklagt hat; weiter führt, wer leitet.
class GastAnklage extends StatefulWidget {
  const GastAnklage({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  State<GastAnklage> createState() => _GastAnklageState();
}

class _GastAnklageState extends State<GastAnklage> {
  String? _markiert;
  bool _laeuft = false;
  bool _gesendet = false;

  GastKontext get c => widget.kontext;

  Future<void> _anklagen(String person) async {
    setState(() => _laeuft = true);
    try {
      await c.befehl({'typ': 'anklage', 'person': person});
      if (mounted) setState(() => _gesendet = true);
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = GastLeseSitzung.fuer(c);
    if (s == null) return const SizedBox.shrink();
    final verdaechtige = jTexte(c.v['verdaechtige']);
    final fertig = _gesendet || c.v['kannWeiter'] == true;
    final markiert = _markiert;
    return _blatt(c.l.detektiv_gast_anklage, [
      Text(s.ui(fertig && markiert != null ? 'ui.anklage.angeklagt' : 'ui.anklage.hinweis', {'name': markiert == null ? '' : c.figurName(markiert)}),
          style: MPapierSchrift.leise),
      const SizedBox(height: MMass.s12),
      for (final v in verdaechtige)
        _Wahl(
          key: ValueKey('verdaechtig-$v'),
          text: c.figurName(v),
          unter: c.figurTitel(v),
          look: c.aussehen(v),
          gewaehlt: markiert == v,
          onTap: fertig ? null : () => setState(() => _markiert = v),
        ),
      if (!fertig && markiert != null) ...[
        const SizedBox(height: MMass.s8),
        Text(s.ui('ui.anklage.endgueltig'), style: MPapierSchrift.text),
        const SizedBox(height: MMass.s8),
        MKnopf(
          key: const ValueKey('anklagen'),
          text: s.ui('ui.anklage.anklagen'),
          onPressed: c.verbunden && !_laeuft ? () => _anklagen(markiert) : null,
        ),
      ],
    ], hervorgehoben: true);
  }
}

/// Das Notizbuch des Gast-Detektivs: die Antworten der App aus seinen
/// Befragungen (wie das Notizbuch am Tisch, A-051), Funde der Runden
/// (öffentlich) und was der Erzähler über ungespielte Gäste sprach (privat,
/// E-044). Eine Befragung, die oben noch als Karte steht, kommt nicht doppelt.
class _Notizbuch extends StatelessWidget {
  const _Notizbuch({required this.kontext});

  final GastKontext kontext;

  @override
  Widget build(BuildContext context) {
    final s = GastLeseSitzung.fuer(kontext);
    // Das Notizbuch aus der Ablage (nach dem Neuladen) kommt nach dem ersten Bild.
    return s == null ? _inhalt(null) : ListenableBuilder(listenable: s, builder: (_, _) => _inhalt(s));
  }

  Widget _inhalt(GastLeseSitzung? s) {
    final c = kontext;
    final funde = jMap(c.v['notizbuch']);
    final npc = jTexte(c.privat['erzaehlerNotizen']);
    final oben = {for (final k in s?.befragungen ?? const <BefragungKarte>[]) k.id};
    final antworten = [for (final k in s?.befragungsNotizen ?? const <BefragungKarte>[]) if (!oben.contains(k.id)) k];
    if (funde.isEmpty && npc.isEmpty && antworten.isEmpty) return const SizedBox.shrink();
    String frage(String id) {
      try {
        return c.daten?.karte.ermittlung.entscheidung(id).frage ?? '';
      } catch (_) {
        return '';
      }
    }

    return _blatt(c.l.detektiv_gast_notizen, [
      if (s != null && antworten.isNotEmpty) ...[
        MGanzeWorte(s.ui('ui.befragung.notizen'), stil: MPapierSchrift.ueberschrift.copyWith(fontSize: 17), minimum: 12),
        const SizedBox(height: MMass.s8),
        for (final (i, k) in antworten.indexed)
          Padding(padding: const EdgeInsets.only(bottom: MMass.s12), child: BefragungsKarte(sitzung: s, karte: k, nr: i)),
      ],
      for (final e in funde.entries) ...[
        if (frage(e.key).isNotEmpty) Text(frage(e.key), style: MPapierSchrift.leise),
        for (final f in jTexte(e.value)) _punkt(f),
        const SizedBox(height: MMass.s8),
      ],
      for (final n in npc) Padding(padding: const EdgeInsets.only(bottom: MMass.s8), child: Text(n, style: MPapierSchrift.kursiv)),
    ], art: PapierArt.notiz);
  }
}

/// Eine Möglichkeit zum Antippen: Kreis zum Ankreuzen, optional Abzug, Text.
class _Wahl extends StatelessWidget {
  const _Wahl({super.key, required this.text, required this.gewaehlt, required this.onTap, this.unter = '', this.look});

  final String text;
  final String unter;
  final LookDef? look;
  final bool gewaehlt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s8),
        child: Semantics(
          button: true,
          selected: gewaehlt,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(3),
              splashFactory: NoSplash.splashFactory,
              child: Container(
                constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
                padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                decoration: BoxDecoration(
                  color: gewaehlt ? MRoh.tinteBlau.withValues(alpha: 0.06) : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: gewaehlt ? MRoh.tinteBlau.withValues(alpha: 0.8) : MRoh.tinte.withValues(alpha: 0.3), width: gewaehlt ? 1.8 : 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MOnlineStimmkreis(angekreuzt: gewaehlt),
                    const SizedBox(width: 12),
                    if (look case final bild?) ...[
                      MFotoabzug(look: bild, groesse: 44, neigung: -0.04),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MGanzeWorte(text, stil: MPapierSchrift.text, minimum: 12),
                          if (unter.isNotEmpty) MGanzeWorte(unter, stil: MPapierSchrift.leise, minimum: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// Ein Blatt mit Formularkopf in Stempelrot.
Widget _blatt(String titel, List<Widget> kinder, {bool hervorgehoben = false, PapierArt art = PapierArt.karteikarte}) => Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: MBlatt(
        art: art,
        hervorgehoben: hervorgehoben,
        kopfLinie: art == PapierArt.karteikarte ? 7 : null,
        linien: art != PapierArt.karteikarte,
        neigung: titel.length.isEven ? -0.003 : 0.003,
        samen: titel.length + 11,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titel.toUpperCase(), style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
            const SizedBox(height: 4),
            Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
            const SizedBox(height: MMass.s12),
            ...kinder,
          ],
        ),
      ),
    );

Widget _notiz(String text, {bool uhr = true, String? schluessel}) => Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: OnlineWarteNotiz(text: text, uhr: uhr, textKey: schluessel == null ? null : ValueKey(schluessel)),
    );

Widget _punkt(String text) => Padding(
      padding: const EdgeInsets.only(bottom: MMass.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10),
            child: Container(width: 6, height: 6, decoration: BoxDecoration(color: MRoh.stempelRot.withValues(alpha: 0.8), shape: BoxShape.circle)),
          ),
          Expanded(child: MGanzeWorte(text, stil: MPapierSchrift.text, minimum: 12)),
        ],
      ),
    );
