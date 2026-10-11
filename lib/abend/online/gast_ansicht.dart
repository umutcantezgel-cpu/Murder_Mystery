import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show Enden, EndeRegel;
import 'package:mordakte_core/runden.dart' show KartenArt, Stufe;
import 'package:mordakte_netz/mordakte_netz.dart' show VerbindungsStatus;

import '../../karten/widgets/karten_ansicht.dart' show KartenTexte;
import '../../l10n/lookup.dart';
import '../../netz/relay_einstellung.dart';
import '../../party/daten.dart';
import '../../party/party_stil.dart' show FarbPunkt;
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_dienst.dart';

/// Schickt eine Raumnachricht; Ablehnungen zeigt die Seite selbst als Meldung.
typedef GastBefehl = Future<void> Function(Map<String, Object?> nachricht);

/// Was die Gastseite für den aktuellen Abschnitt zeigt: Kopfzeilen, Inhalt und
/// Aktionsleiste. Alles stammt aus der Ansicht des Raums ([GastDienst.ansicht]),
/// der Positivliste für dieses Gerät, nie aus eigenem Wissen über den Fall.
class GastSeiteninhalt {
  const GastSeiteninhalt({this.marke, this.titel, this.untertitel, this.kinder = const [], this.aktionen = const []});

  final String? marke;
  final String? titel;
  final String? untertitel;
  final List<Widget> kinder;
  final List<Widget> aktionen;
}

/// Lesezugriff auf Ansicht, Akte und Texte für die Bausteine unten.
class GastKontext {
  GastKontext({required this.context, required this.dienst, required this.befehl, required this.belohnung});

  final BuildContext context;
  final GastDienst dienst;
  final GastBefehl befehl;

  /// Wechselt nach dem Ende des Abends zur Belohnung (`null`: noch nicht möglich).
  final VoidCallback? belohnung;

  L get l => L.of(context);
  MSchrift get t => MSchrift.von(context);
  MFarben get f => MFarben.von(context);

  Map<String, Object?> get v => dienst.ansicht;
  Map<String, Object?> get privat => jMap(v['privat']);
  String get phase => jText(v['phase'], 'lobby');
  int get runde => jZahl(v['runde']);
  bool get verbunden => dienst.status == VerbindungsStatus.verbunden;
  PartyDaten? get daten => dienst.daten;
  List<SpielerInfo> get spieler => spielerAusAnsicht(v);
  String get ichId => dienst.spielerId;

  SpielerInfo? get ich {
    for (final s in spieler) {
      if (s.id == ichId) return s;
    }
    return null;
  }

  /// Dossier dieses Geräts (`null` für Assistenz-Plätze ohne Rolle).
  Map<String, Object?>? get dossier => privat['dossier'] is Map ? jMap(privat['dossier']) : null;
  String? get rolle => privat['rolle'] is String ? privat['rolle'] as String : null;

  /// Name eines Platzes (Gerätekennung → Name), sonst leer.
  String nameVon(String? id) {
    for (final s in spieler) {
      if (s.id == id) return s.name;
    }
    return '';
  }

  String figurName(String? id) {
    if (id == null || id.isEmpty) return '';
    final n = daten?.kanon.figur(id)?['name'];
    return n is String ? n : id;
  }

  String figurTitel(String? id) {
    if (id == null) return '';
    final n = daten?.kanon.figur(id);
    final titel = n?['roleTitle'] ?? n?['title'];
    return titel is String ? titel : '';
  }

  Color? figurFarbe(String? id) {
    if (id == null) return null;
    final code = daten?.kanon.figur(id)?['colorCode'];
    if (code is String && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(code)) return Color(int.parse(code.substring(1), radix: 16) | 0xFF000000);
    return null;
  }

  /// Kennung der Detektivfigur der Akte (die Spielleitung spielt sie).
  String? get detektivId {
    final d = daten?.kanon.figurenJson['detektiv'];
    return d is Map && d['id'] is String ? d['id'] as String : null;
  }

  /// Name am Tisch zu einer Figur: Gast mit dieser Rolle, die Spielleitung für
  /// den Detektiv, sonst der Figurenname (ein Bot spielt sie).
  String personAmTisch(String id) {
    if (id == detektivId) {
      for (final s in spieler) {
        if (s.istGastgeber) return s.name;
      }
    }
    for (final s in spieler) {
      if (s.rolle == id) return s.name;
    }
    return figurName(id);
  }

  String stufeWort(String kurz) {
    final stufe = Stufe.values.where((s) => s.kurz == kurz).firstOrNull;
    return switch (stufe) {
      Stufe.erfolg => l.online_stufe_erfolg,
      Stufe.teilerfolg => l.online_stufe_teilerfolg,
      Stufe.pech => l.online_stufe_pech,
      null => kurz,
    };
  }

  String stufeName(String name) => switch (name) {
        'erfolg' => l.online_stufe_erfolg,
        'teilerfolg' => l.online_stufe_teilerfolg,
        'pech' => l.online_stufe_pech,
        _ => name,
      };

  /// Die Regel des erreichten Endes aus der Akte (Name, richtige Anklage), sobald sie geladen ist.
  EndeRegel? endeRegel(String id) {
    final d = daten;
    if (d == null) return null;
    for (final r in Enden(d.kanon).regeln) {
      if (r.id == id) return r;
    }
    return null;
  }
}

/// Baut den Inhalt für den aktuellen Abschnitt der Ansicht.
GastSeiteninhalt baueGastSeite(GastKontext c) {
  final l = c.l;
  final marke = l.online_gast_marke(raumCodeAnzeige(c.dienst.raumCode));
  final phase = c.phase;
  final rundenMarke = c.runde > 0 ? l.online_runde(c.runde) : marke;
  switch (phase) {
    case 'lobby':
      return _lobby(c, marke);
    case 'rollen':
      return _rollen(c);
    case 'intro':
      return _abschnitt(c, rundenMarke, l.online_phase_intro, []);
    case 'gespraeche':
      return _abschnitt(c, rundenMarke, l.online_phase_gespraeche, [_gespraeche(c)]);
    case 'entscheidungen':
      return _abschnitt(c, rundenMarke, l.online_phase_entscheidungen, [_ermittlung(c)]);
    case 'gruppenwahl':
      return _abschnitt(c, rundenMarke, l.online_phase_gruppenwahl, [GastGruppenwahl(key: ValueKey('wahl-${c.runde}'), kontext: c)]);
    case 'bonus':
      return _abschnitt(c, rundenMarke, l.online_phase_bonus, []);
    case 'resuemee':
      return _abschnitt(c, rundenMarke, l.online_phase_resuemee, []);
    case 'anklage':
      return _abschnitt(c, marke, l.online_phase_anklage, [_anklage(c)]);
    case 'finale':
      return _abschnitt(c, marke, l.online_phase_finale, []);
    case 'aufloesung':
      return _abschnitt(c, marke, l.online_phase_aufloesung, [_aufloesung(c)]);
    case 'ende':
      return _ende(c, marke);
    default:
      return _abschnitt(c, marke, l.online_phase_unbekannt, []);
  }
}

// ---------------------------------------------------------------- Bausteine

/// Tafel mit Kapitälchen-Überschrift.
class _Block extends StatelessWidget {
  const _Block({required this.titel, required this.kinder, this.hervorgehoben = false});

  final String? titel;
  final List<Widget> kinder;
  final bool hervorgehoben;

  @override
  Widget build(BuildContext context) {
    final t = MSchrift.von(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: MTafel(
        hervorgehoben: hervorgehoben,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (titel != null) ...[
              Text(titel!.toUpperCase(), style: t.marke),
              const SizedBox(height: MMass.s12),
            ],
            ...kinder,
          ],
        ),
      ),
    );
  }
}

/// Erzählertext der Spielleitung (fertige Texte aus der Ansicht).
Widget _erzaehler(GastKontext c) {
  final bloecke = jTexte(c.v['erzaehler']);
  if (bloecke.isEmpty) return const SizedBox.shrink();
  return _Block(
    titel: c.l.online_erzaehler_titel,
    kinder: [
      for (var i = 0; i < bloecke.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i == bloecke.length - 1 ? 0 : MMass.s12),
          child: Text(bloecke[i], style: c.t.erzaehler),
        ),
    ],
  );
}

/// Eine Zeile Text mit Aufzählungspunkt.
Widget _punkt(GastKontext c, String text) => Padding(
      padding: const EdgeInsets.only(bottom: MMass.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 9, right: MMass.s8), child: Icon(Icons.circle, size: 6, color: c.f.akzent)),
          Expanded(child: Text(text, style: c.t.text)),
        ],
      ),
    );

/// Die Plätze am Tisch (Name, Figur, Verbindung).
Widget _tisch(GastKontext c, {bool mitFiguren = true}) {
  final l = c.l;
  final f = c.f;
  final t = c.t;
  return _Block(
    titel: l.online_tisch_titel,
    kinder: [
      for (final s in c.spieler)
        Padding(
          padding: const EdgeInsets.only(bottom: MMass.s8),
          child: Row(
            children: [
              if (mitFiguren && s.rolle != null && c.figurFarbe(s.rolle) != null)
                Padding(padding: const EdgeInsets.only(right: MMass.s8), child: FarbPunkt(c.figurFarbe(s.rolle)!, groesse: 12)),
              Expanded(
                child: Text(
                  [
                    s.name,
                    if (s.id == c.ichId) '(${l.common_you})',
                    if (mitFiguren && s.rolle != null && c.figurName(s.rolle) != s.name) c.figurName(s.rolle),
                  ].join(' · '),
                  style: t.text,
                ),
              ),
              const SizedBox(width: MMass.s8),
              Flexible(
                child: s.istGastgeber
                    ? MChip(l.online_spielleitung, icon: Icons.star_rounded)
                    : !s.online
                        ? MChip(l.online_getrennt, icon: Icons.wifi_off_rounded, farbe: f.warnung)
                        : c.phase == 'lobby'
                            ? (s.bereit
                                ? MChip(l.online_bereit, icon: Icons.check_circle_rounded, farbe: f.erfolg)
                                : MChip(l.online_nicht_bereit, icon: Icons.hourglass_empty_rounded, farbe: f.papierLeise))
                            : s.rolle == null
                                ? MChip(l.online_assistenz, icon: Icons.visibility_outlined, farbe: f.papierLeise)
                                : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
    ],
  );
}

/// „Meine Rolle“ als einklappbare Tafel (während des Abends nachlesbar).
Widget _meineRolle(GastKontext c) {
  final d = c.dossier;
  if (d == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: MMass.s16),
    child: MTafel(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(c.context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const ValueKey('meine-rolle'),
          tilePadding: const EdgeInsets.symmetric(horizontal: MMass.s16),
          childrenPadding: const EdgeInsets.fromLTRB(MMass.s16, MMass.s12, MMass.s16, MMass.s16),
          iconColor: c.f.akzent,
          collapsedIconColor: c.f.papierLeise,
          title: Text(c.l.online_meine_rolle(c.figurName(c.rolle)), style: c.t.ueberschrift.copyWith(fontSize: 18)),
          children: [DossierAnsicht(kontext: c)],
        ),
      ),
    ),
  );
}

/// Rahmen eines Abschnitts: Erzähler, Spezifisches, dann Rolle und Tisch.
GastSeiteninhalt _abschnitt(GastKontext c, String marke, String titel, List<Widget> spezifisch) {
  final l = c.l;
  return GastSeiteninhalt(
    marke: marke,
    titel: titel,
    untertitel: c.phase == 'lobby' ? null : (c.rolle == null ? l.online_assistenz_text : null),
    kinder: [
      _erzaehler(c),
      ...spezifisch,
      if (spezifisch.isEmpty && jTexte(c.v['erzaehler']).isEmpty) _Block(titel: null, kinder: [Text(l.online_warten_spielleitung, style: c.t.leise)]),
      _meineRolle(c),
      _tisch(c),
    ],
  );
}

// -------------------------------------------------------------------- Lobby

GastSeiteninhalt _lobby(GastKontext c, String marke) {
  final l = c.l;
  final ich = c.ich;
  final bereit = ich?.bereit ?? false;
  return GastSeiteninhalt(
    marke: marke,
    titel: l.online_gast_lobby_titel,
    untertitel: l.online_gast_lobby_hinweis,
    kinder: [_tisch(c, mitFiguren: false)],
    aktionen: [
      MKnopf(
        text: bereit ? l.online_bereit_zurueck : l.online_bereit_knopf,
        art: bereit ? MKnopfArt.zweit : MKnopfArt.haupt,
        icon: bereit ? Icons.undo_rounded : Icons.check_rounded,
        onPressed: c.verbunden ? () => c.befehl({'typ': 'bereit', 'wert': !bereit}) : null,
      ),
    ],
  );
}

// ------------------------------------------------------------------- Rollen

GastSeiteninhalt _rollen(GastKontext c) {
  final l = c.l;
  final d = c.dossier;
  if (d == null) {
    // Assistenz: keine eigene Rolle, nur der öffentliche Teil.
    return GastSeiteninhalt(
      marke: l.online_gast_marke(raumCodeAnzeige(c.dienst.raumCode)),
      titel: l.online_phase_rollen,
      untertitel: l.online_assistenz_text,
      kinder: [_tisch(c)],
    );
  }
  final gelesen = c.privat['gelesen'] == true;
  final titel = c.figurTitel(c.rolle);
  return GastSeiteninhalt(
    marke: l.online_rolle_marke,
    titel: c.figurName(c.rolle),
    untertitel: titel.isEmpty ? null : titel,
    kinder: [
      DossierAnsicht(kontext: c),
      if (gelesen) _Block(titel: null, hervorgehoben: true, kinder: [Text(l.online_gelesen_warten, key: const ValueKey('rolle-gelesen'), style: c.t.text)]),
    ],
    aktionen: [
      if (!gelesen)
        MKnopf(
          text: l.online_gelesen_knopf,
          icon: Icons.check_rounded,
          onPressed: c.verbunden ? () => c.befehl({'typ': 'rollenGelesen'}) : null,
        ),
    ],
  );
}

/// Das eigene Dossier: wer, Ziel, Wissen, Verborgenes und, für Täterin oder
/// Täter, Tarnung und Tatwissen. Als Aktenblatt gesetzt.
class DossierAnsicht extends StatelessWidget {
  const DossierAnsicht({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  Widget build(BuildContext context) {
    final c = kontext;
    final l = c.l;
    final f = c.f;
    final d = c.dossier;
    if (d == null) return const SizedBox.shrink();
    final kopf = TextStyle(fontFamily: MRohSchrift.text, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: f.tinte.withValues(alpha: 0.7));
    final text = TextStyle(fontFamily: MRohSchrift.text, fontSize: 16, height: 1.45, color: f.tinte);
    Widget abschnitt(String titel, List<Widget> kinder) => Padding(
          padding: const EdgeInsets.only(bottom: MMass.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(titel.toUpperCase(), style: kopf),
              const SizedBox(height: MMass.s8),
              ...kinder,
            ],
          ),
        );
    Widget zeile(String s) => Padding(padding: const EdgeInsets.only(bottom: MMass.s8), child: Text(s, style: text));
    final tarnung = jText(d['tarnung']);
    final tatwissen = jTexte(d['tatwissen']);
    return MPapier(
      key: const ValueKey('dossier'),
      stempel: l.online_dossier_stempel,
      padding: const EdgeInsets.fromLTRB(MMass.s16, MMass.s24, MMass.s16, MMass.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          abschnitt(l.online_dossier_wer, [zeile(jText(d['wer']))]),
          abschnitt(l.online_dossier_ziel, [zeile(jText(d['ziel']))]),
          abschnitt(l.online_dossier_weiss, [for (final z in jTexte(d['weiss'])) zeile(z)]),
          abschnitt(l.online_dossier_verbirgt, [for (final z in jTexte(d['verbirgt'])) zeile(z)]),
          if (tarnung.isNotEmpty) abschnitt(l.online_dossier_tarnung, [zeile(tarnung)]),
          if (tatwissen.isNotEmpty) abschnitt(l.online_dossier_tatwissen, [for (final z in tatwissen) zeile(z)]),
          if (jText(d['besetzung']).isNotEmpty) abschnitt(l.online_dossier_besetzung, [zeile(jText(d['besetzung']))]),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Gespräche

Widget _gespraeche(GastKontext c) {
  final l = c.l;
  final t = c.t;
  final eigene = jMaps(c.privat['gespraeche']);
  final bots = jMaps(c.v['botGespraeche']);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (c.dossier != null)
        _Block(
          titel: l.online_gespraeche_titel,
          kinder: [
            if (eigene.isEmpty) Text(l.online_gespraeche_keine, style: t.leise),
            for (var i = 0; i < eigene.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == eigene.length - 1 ? 0 : MMass.s16),
                child: _Gespraech(c: c, g: eigene[i]),
              ),
          ],
        ),
      if (bots.isNotEmpty)
        _Block(
          titel: l.online_bots_titel,
          kinder: [
            for (var i = 0; i < bots.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == bots.length - 1 ? 0 : MMass.s16),
                child: _BotBlase(c: c, g: bots[i]),
              ),
          ],
        ),
    ],
  );
}

/// Ein Pflichtgespräch dieses Geräts: mit wem, Thema, Ziel und Eröffnungssatz.
class _Gespraech extends StatelessWidget {
  const _Gespraech({required this.c, required this.g});

  final GastKontext c;
  final Map<String, Object?> g;

  @override
  Widget build(BuildContext context) {
    final l = c.l;
    final t = c.t;
    final partner = jText(g['partner']);
    Widget zeile(String titel, String wert) => Padding(
          padding: const EdgeInsets.only(top: MMass.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(titel, style: t.leise), Text(wert, style: t.text)],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.online_gespraech_mit(c.personAmTisch(partner)), style: t.ueberschrift.copyWith(fontSize: 18)),
        zeile(l.online_gespraech_thema, jText(g['thema'])),
        zeile(l.online_gespraech_ziel, jText(g['ziel'])),
        zeile(l.online_gespraech_eroeffnung, jText(g['text'])),
      ],
    );
  }
}

/// Öffentliche Sprechblase eines Gesprächs, das ein Bot führt.
class _BotBlase extends StatelessWidget {
  const _BotBlase({required this.c, required this.g});

  final GastKontext c;
  final Map<String, Object?> g;

  @override
  Widget build(BuildContext context) {
    final l = c.l;
    final t = c.t;
    final f = c.f;
    final rolle = jText(g['rolle']);
    final farbe = c.figurFarbe(rolle);
    final preis = jMaps(g['preisgaben']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (farbe != null) Padding(padding: const EdgeInsets.only(right: MMass.s8), child: FarbPunkt(farbe, groesse: 12)),
            Expanded(
              child: Text(l.online_bot_spricht(c.figurName(rolle), c.personAmTisch(jText(g['partner']))), style: t.ueberschrift.copyWith(fontSize: 17)),
            ),
          ],
        ),
        if (jText(g['thema']).isNotEmpty) Padding(padding: const EdgeInsets.only(top: MMass.s4), child: Text(jText(g['thema']), style: t.leise)),
        const SizedBox(height: MMass.s8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MMass.s12),
          decoration: BoxDecoration(color: f.flaecheHoch, borderRadius: BorderRadius.circular(MMass.r10), border: Border.all(color: f.linie)),
          child: Text(jText(g['text']), style: t.text),
        ),
        for (final p in preis)
          if (jText(p['text']).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: MMass.s8),
              child: Text('${l.online_preisgabe}: ${jText(p['text'])}', style: t.leise),
            ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Ermittlung

Widget _ermittlung(GastKontext c) {
  final l = c.l;
  final t = c.t;
  final z = c.v['zug'] is Map ? jMap(c.v['zug']) : null;
  final e = c.v['entscheidung'] is Map ? jMap(c.v['entscheidung']) : null;
  final daten = c.daten;
  final restMin = jZahl(c.v['restMinuten']);
  final marken = jZahl(c.v['marken']);
  final notizbuch = jMap(c.v['notizbuch']);
  final wuerfe = jMaps(c.v['wuerfe']);

  String frageZu(String id) {
    try {
      return daten?.karte.ermittlung.entscheidung(id).frage ?? '';
    } catch (_) {
      return '';
    }
  }

  String optionText(String id, String option) {
    try {
      return daten?.karte.ermittlung.entscheidung(id).option(option).text ?? '';
    } catch (_) {
      return '';
    }
  }

  final kinder = <Widget>[
    Padding(
      padding: const EdgeInsets.only(bottom: MMass.s12),
      child: Text('${l.online_nachtzeit(restMin)} · ${l.online_marken(marken)}', style: t.leise),
    ),
  ];

  if (z != null) {
    final id = jText(z['id']);
    final option = z['option'] is String ? z['option'] as String : null;
    final zugPhase = jText(z['phase']);
    final frage = id == 'auftakt' ? l.online_auftakt : (id.startsWith('abstecher:') ? l.online_abstecher : frageZu(id));
    final gewaehlt = option == null ? '' : optionText(id, option);
    final wurf = z['wurf'] is Map ? jMap(z['wurf']) : null;
    kinder.add(_Block(
      titel: l.online_frage_titel,
      hervorgehoben: true,
      kinder: [
        if (frage.isNotEmpty) Text(frage, style: t.ueberschrift),
        if (gewaehlt.isNotEmpty) ...[
          const SizedBox(height: MMass.s8),
          Text(l.online_gewaehlt_titel.toUpperCase(), style: t.marke),
          Text(gewaehlt, style: t.text),
        ],
      ],
    ));
    switch (zugPhase) {
      case 'aktion':
        kinder.add(_Block(titel: null, kinder: [Text(l.online_zug_aktion, style: t.text)]));
      case 'wurf':
        kinder.add(GastWuerfel(kontext: c, zug: z));
      case 'tischruf':
        if (wurf != null) kinder.add(_wurfBlock(c, wurf));
        kinder.add(_Block(titel: null, kinder: [Text(l.online_tischruf_wartet, style: t.text)]));
      case 'fund':
        if (wurf != null) kinder.add(_wurfBlock(c, wurf));
        final funde = jTexte(z['funde']);
        final neben = jText(z['nebenfund']);
        if (funde.isNotEmpty || neben.isNotEmpty) {
          kinder.add(_Block(
            titel: l.online_fund_titel,
            kinder: [for (final f in funde) _punkt(c, f), if (neben.isNotEmpty) Text(neben, style: t.text)],
          ));
        } else {
          kinder.add(_Block(titel: null, kinder: [Text(l.online_fund_wartet, style: t.leise)]));
        }
    }
  } else if (e != null) {
    final optionen = jMaps(e['optionen']);
    kinder.add(_Block(
      titel: l.online_frage_titel,
      hervorgehoben: true,
      kinder: [
        Text(jText(e['frage']), style: t.ueberschrift),
        const SizedBox(height: MMass.s12),
        Text(l.online_optionen_titel.toUpperCase(), style: t.marke),
        const SizedBox(height: MMass.s8),
        for (final o in optionen) _punkt(c, jText(o['text'])),
        const SizedBox(height: MMass.s4),
        Text(l.online_ermittlung_wartet, style: t.leise),
      ],
    ));
  } else {
    kinder.add(_Block(titel: null, kinder: [Text(l.online_ermittlung_fertig, style: t.text)]));
  }

  if (notizbuch.isNotEmpty) {
    kinder.add(_Block(
      titel: l.online_notizbuch_titel,
      kinder: [
        for (final eintrag in notizbuch.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (frageZu(eintrag.key).isNotEmpty) Text(frageZu(eintrag.key), style: t.leise),
                for (final f in jTexte(eintrag.value)) _punkt(c, f),
              ],
            ),
          ),
      ],
    ));
  }
  if (wuerfe.isNotEmpty) {
    kinder.add(_Block(
      titel: l.online_wuerfe_titel,
      kinder: [
        for (final w in wuerfe)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s4),
            child: Text(
              l.online_wurf_zeile(c.stufeWort(jText(w['stufe'])), jZahl(w['a']), jZahl(w['b']), jZahl(w['mod']), jZahl(w['a']) + jZahl(w['b']) + jZahl(w['mod'])),
              style: t.leise,
            ),
          ),
      ],
    ));
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: kinder);
}

/// Das Ergebnis eines Wurfs: Stufe und Rechnung.
Widget _wurfBlock(GastKontext c, Map<String, Object?> w) {
  final l = c.l;
  final t = c.t;
  final summe = jZahl(w['a']) + jZahl(w['b']) + jZahl(w['mod']);
  return _Block(
    titel: l.online_wurf_titel,
    hervorgehoben: true,
    kinder: [
      Text(c.stufeWort(jText(w['stufe'])), key: const ValueKey('wurf-stufe'), style: t.titel.copyWith(fontSize: 26)),
      const SizedBox(height: MMass.s4),
      Text(l.online_wurf_rechnung(jZahl(w['a']), jZahl(w['b']), jZahl(w['mod']), summe), style: t.leise),
      if (w['garantie'] == true) Text(l.online_wurf_garantie, style: t.leise),
    ],
  );
}

/// Würfelbühne: Ist dieses Gerät die Würfelpatin oder der Würfelpate, kann es
/// Marke und Werkzeugkarte wählen und würfeln; sonst steht da, wer würfelt.
class GastWuerfel extends StatefulWidget {
  const GastWuerfel({super.key, required this.kontext, required this.zug});

  final GastKontext kontext;
  final Map<String, Object?> zug;

  @override
  State<GastWuerfel> createState() => _GastWuerfelState();
}

class _GastWuerfelState extends State<GastWuerfel> {
  bool? _marke;
  String? _karte;
  bool _laeuft = false;

  GastKontext get c => widget.kontext;
  Map<String, Object?> get z => widget.zug;

  bool get _meinWurf => jText(c.v['wuerfelPate']) == c.ichId;
  bool get _auftakt => jText(z['id']) == 'auftakt';
  bool get _abstecher => jText(z['id']).startsWith('abstecher:');

  /// Werkzeugkarten des Tischvorrats, die noch Ladungen haben.
  List<Map<String, Object?>> get _werkzeuge => [
        for (final k in jMaps(c.v['vorrat']))
          if (k['art'] == KartenArt.werkzeug.name && jZahl(k['rest']) > 0) k,
      ];

  bool get _markeWert => _marke ?? (z['marke'] == true);
  String? get _karteWert => _karte ?? (z['werkzeug'] == true && _werkzeuge.isNotEmpty ? jText(_werkzeuge.first['id']) : null);

  /// Meldet dem Raum Marke und Karte, damit die Chancen für alle stimmen.
  Future<void> _hilfe({bool? marke, String? karte, bool karteLeer = false}) async {
    final m = marke ?? _markeWert;
    final k = karteLeer ? null : (karte ?? _karteWert);
    setState(() {
      _marke = m;
      _karte = k;
    });
    await c.befehl({'typ': 'wuerfelHilfe', 'marke': m, 'karte': ?k});
  }

  Future<void> _wuerfeln() async {
    if (_laeuft) return;
    setState(() => _laeuft = true);
    try {
      // Stimmen Marke und Karte nicht mit dem Raum überein, zuerst melden.
      if (!_auftakt && (_markeWert != (z['marke'] == true) || (_karteWert != null) != (z['werkzeug'] == true))) {
        await c.befehl({'typ': 'wuerfelHilfe', 'marke': _markeWert, 'karte': ?_karteWert});
      }
      await c.befehl({'typ': 'wurf'});
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = c.l;
    final t = c.t;
    final f = c.f;
    final chancen = jMap(z['chancen']);
    final marken = jZahl(c.v['marken']);
    final pate = c.nameVon(jText(c.v['wuerfelPate']));
    return _Block(
      titel: l.online_wuerfel_titel,
      hervorgehoben: true,
      kinder: [
        Text(_meinWurf ? l.online_wuerfel_du : l.online_wuerfelt(pate), key: const ValueKey('wuerfel-pate'), style: t.ueberschrift),
        const SizedBox(height: MMass.s12),
        Text(l.online_chancen(jZahl(z['mod'])), style: t.text),
        const SizedBox(height: MMass.s8),
        for (final stufe in ['erfolg', 'teilerfolg', 'pech'])
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s4),
            child: Row(
              children: [
                Expanded(child: Text(c.stufeName(stufe), style: t.text)),
                Text('${jZahl(chancen[stufe])} %', style: t.text.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        if (_meinWurf) ...[
          if (!_auftakt && _werkzeuge.isNotEmpty)
            for (final k in _werkzeuge)
              CheckboxListTile(
                key: ValueKey('werkzeug-${k['id']}'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: f.akzent,
                value: _karteWert == k['id'],
                onChanged: c.verbunden && !_laeuft
                    ? (v) => _hilfe(karte: v == true ? jText(k['id']) : null, karteLeer: v != true)
                    : null,
                title: Text(l.online_werkzeug_einsetzen(c.dienst.katalog?[jText(k['id'])]?.titel ?? KartenTexte.art(KartenArt.werkzeug)), style: t.leise),
              ),
          if (!_auftakt && !_abstecher && marken > 0)
            CheckboxListTile(
              key: const ValueKey('marke-einsetzen'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: f.akzent,
              value: _markeWert,
              onChanged: c.verbunden && !_laeuft ? (v) => _hilfe(marke: v == true) : null,
              title: Text(l.online_marke_einsetzen, style: t.leise),
            ),
          const SizedBox(height: MMass.s12),
          MKnopf(
            text: l.online_wuerfeln_knopf,
            icon: Icons.casino_outlined,
            breit: true,
            onPressed: c.verbunden && !_laeuft ? _wuerfeln : null,
          ),
        ],
      ],
    );
  }
}

// -------------------------------------------------------------- Gruppenwahl

/// Die eigene Rundenwahl: zwei Karten, A oder B; niemand sieht, was man wählt.
class GastGruppenwahl extends StatefulWidget {
  const GastGruppenwahl({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  State<GastGruppenwahl> createState() => _GastGruppenwahlState();
}

class _GastGruppenwahlState extends State<GastGruppenwahl> {
  bool? _kooperativ;
  bool _laeuft = false;

  GastKontext get c => widget.kontext;

  Future<void> _abgeben() async {
    final k = _kooperativ;
    if (k == null || _laeuft) return;
    setState(() => _laeuft = true);
    try {
      await c.befehl({'typ': 'stimme', 'kooperativ': k});
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = c.l;
    final t = c.t;
    final wahl = c.privat['wahl'] is Map ? jMap(c.privat['wahl']) : null;
    if (c.dossier == null) {
      return _Block(titel: null, kinder: [Text(l.online_wahl_assistenz, style: t.leise)]);
    }
    if (c.privat['hatGestimmt'] == true) {
      return _Block(
        titel: l.online_wahl_titel,
        hervorgehoben: true,
        kinder: [Text(l.online_wahl_abgegeben, key: const ValueKey('wahl-abgegeben'), style: t.ueberschrift)],
      );
    }
    if (wahl == null) {
      return _Block(titel: null, kinder: [Text(l.online_warten_spielleitung, style: t.leise)]);
    }
    return _Block(
      titel: l.online_wahl_titel,
      hervorgehoben: true,
      kinder: [
        Text(l.online_wahl_geheim, style: t.leise),
        const SizedBox(height: MMass.s12),
        _WahlKarte(key: const ValueKey('wahl-a'), kontext: c, text: jText(wahl['a']), gewaehlt: _kooperativ == true, onTippen: () => setState(() => _kooperativ = true)),
        const SizedBox(height: MMass.s12),
        _WahlKarte(key: const ValueKey('wahl-b'), kontext: c, text: jText(wahl['b']), gewaehlt: _kooperativ == false, onTippen: () => setState(() => _kooperativ = false)),
        const SizedBox(height: MMass.s16),
        MKnopf(
          text: l.online_wahl_abgeben,
          breit: true,
          onPressed: _kooperativ != null && c.verbunden && !_laeuft ? _abgeben : null,
        ),
      ],
    );
  }
}

/// Antippbare Wahlkarte; die gewählte hat einen warmen Rand und einen vollen Kreis.
class _WahlKarte extends StatelessWidget {
  const _WahlKarte({super.key, required this.kontext, required this.text, required this.gewaehlt, required this.onTippen});

  final GastKontext kontext;
  final String text;
  final bool gewaehlt;
  final VoidCallback onTippen;

  @override
  Widget build(BuildContext context) {
    final f = kontext.f;
    final t = kontext.t;
    return Semantics(
      button: true,
      selected: gewaehlt,
      child: InkWell(
        borderRadius: BorderRadius.circular(MMass.r14),
        onTap: onTippen,
        child: MTafel(
          akzent: gewaehlt ? f.akzent : f.linieStark,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(text, style: t.text)),
              const SizedBox(width: MMass.s12),
              Icon(gewaehlt ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: gewaehlt ? f.akzent : f.papierLeise),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------- Anklage und Auflösung

Widget _anklage(GastKontext c) {
  final l = c.l;
  final t = c.t;
  final verdaechtige = jTexte(c.v['verdaechtige']);
  return _Block(
    titel: l.online_verdaechtige_titel,
    kinder: [
      Text(l.online_anklage_wartet, style: t.leise),
      const SizedBox(height: MMass.s12),
      for (final p in verdaechtige)
        Padding(
          padding: const EdgeInsets.only(bottom: MMass.s8),
          child: Row(
            children: [
              if (c.figurFarbe(p) != null) Padding(padding: const EdgeInsets.only(right: MMass.s8), child: FarbPunkt(c.figurFarbe(p)!)),
              Expanded(child: Text([c.figurName(p), if (c.figurTitel(p).isNotEmpty) c.figurTitel(p)].join(' · '), style: t.text)),
            ],
          ),
        ),
    ],
  );
}

Widget _aufloesung(GastKontext c) {
  final l = c.l;
  final t = c.t;
  final a = c.v['aufloesung'] is Map ? jMap(c.v['aufloesung']) : null;
  if (a == null) return const SizedBox.shrink();
  final regel = c.endeRegel(jText(a['ende']));
  Widget wert(String titel, String w) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(titel.toUpperCase(), style: t.marke), Text(w, style: t.ueberschrift)],
        ),
      );
  return _Block(
    titel: l.online_aufloesung_titel,
    hervorgehoben: true,
    kinder: [
      wert(l.online_aufloesung_taeter, c.figurName(jText(a['pfad']))),
      wert(l.online_aufloesung_punkte, '${jZahl(a['punkte'])}'),
      if (regel != null) wert(l.online_aufloesung_ende, regel.name),
      wert(l.online_aufloesung_code, jText(a['fallCode'])),
    ],
  );
}

GastSeiteninhalt _ende(GastKontext c, String marke) {
  final l = c.l;
  final regel = c.endeRegel(jText(jMap(c.v['aufloesung'])['ende']));
  return GastSeiteninhalt(
    marke: marke,
    titel: regel?.name ?? l.online_phase_ende,
    untertitel: l.online_phase_ende,
    kinder: [
      _erzaehler(c),
      _aufloesung(c),
      _meineRolle(c),
      _tisch(c),
    ],
    aktionen: [
      MKnopf(text: l.abend_belohnung_ansehen, icon: Icons.style_rounded, onPressed: c.belohnung),
    ],
  );
}
