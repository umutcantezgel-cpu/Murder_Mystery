import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart' show Abendfassung, Enden, EndeRegel, LookDef;
import 'package:mordakte_core/runden.dart' show KartenArt, Sitz, Stufe;
import 'package:mordakte_netz/mordakte_netz.dart' show VerbindungsStatus;

import '../../karten/widgets/karten_ansicht.dart' show KartenTexte;
import '../../l10n/lookup.dart';
import '../../netz/relay_einstellung.dart';
import '../../party/bildschirme/erzaehlerpult.dart' show VorleserKarte;
import '../../party/daten.dart';
import '../../stil/mappe/online_bausteine.dart';
import '../../stil/stil.dart';
import 'ansicht.dart';
import 'gast_befragung.dart';
import 'gast_diashow.dart';
import 'gast_dienst.dart';
import 'gast_einstimmung.dart';
import 'gast_erzaehler.dart';
import 'gast_ermittlung.dart';
import 'gast_lobby.dart';
import 'gast_moment.dart';
import 'gast_rundgang.dart';
import 'gast_streifzug.dart';
import 'gast_uhr.dart';
import 'online_teile.dart';

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

  /// Kurzer oder langer Abend (M7b): Der Raum zeigt `fassung` nur beim
  /// langen Abend; ohne den Schlüssel ist es der kurze.
  Abendfassung get fassung => Abendfassung.lesen(v['fassung']);

  /// Gehört die Rundenuhr zum laufenden Abschnitt? Kurz in den Gesprächen,
  /// lang im ganzen Streifzug (Gespräche und Entscheidungen), wie im Raum.
  bool get uhrInPhase => phase == 'gespraeche' || (fassung.istLang && phase == 'entscheidungen');
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

  /// Dossier dieses Geräts (`null` für Detektiv, Erzähler und Assistenz).
  Map<String, Object?>? get dossier => privat['dossier'] is Map ? jMap(privat['dossier']) : null;
  String? get rolle => privat['rolle'] is String ? privat['rolle'] as String : null;

  /// Sitz dieses Geräts (Langer Abend M3); in der Lobby ohne Sitz `null`.
  Sitz? get sitz => ich?.sitz;

  /// Liest dieses Gerät vor (Vorleser-Sitz: Erzähler, sonst Detektiv)?
  bool get vorleser => privat['vorleser'] == true;

  /// Erzähltext für dieses Gerät: vor dem Finale nur beim Vorleser (privat),
  /// ab dem Finale für alle (öffentlich).
  List<String> get erzaehlerTexte => privat['erzaehler'] is List ? jTexte(privat['erzaehler']) : jTexte(v['erzaehler']);

  /// Wer gerade leitet („Weiter“) und vorliest, wie im Raum
  /// (`SchlosskellerRaum.vorleser`): der Erzähler-Sitz, solange er verbunden
  /// ist, sonst der Detektiv-Sitz, sonst der Gastgeber. In der Lobby niemand.
  String? get leiterId {
    if (phase == 'lobby') return null;
    for (final sitz in [Sitz.erzaehler, Sitz.detektiv]) {
      for (final s in spieler) {
        if (s.sitz == sitz && s.online) return s.id;
      }
    }
    return jText(v['host']).isEmpty ? null : jText(v['host']);
  }

  /// Leitet dieses Gerät gerade den Abend?
  bool get leitet => leiterId == ichId;

  /// Name dessen, der gerade leitet und vorliest.
  String get leiterName => nameVon(leiterId);

  /// Ermittelt dieses Gerät (Detektiv-Sitz oder Vertretung, privat `detektiv`)?
  bool get ermittelt => privat['detektiv'] == true;

  /// Kennt die Akte einen Erzähler-Sitz (heute der Schlosskeller)? Solange sie
  /// lädt, verrät es die Ansicht: Nur dort steht `erzaehlerLiest`.
  bool get mitErzaehlerSitz => daten?.mitErzaehlerSitz ?? v.containsKey('erzaehlerLiest');

  /// Wie die Akte den Ermittler nennt (Etikett des Detektiv-Sitzes): in den
  /// Noir-Akten „Inspektor“, im Gewölbe „Geburtstagskind“, im Schlosskeller
  /// „Detektiv“ (`ui.allgemein.detektiv`). Altakten bleiben so unverändert.
  String get detektivWort => detektivBezeichnung(l, daten);

  /// Nummer dieses Platzes am Tisch, zweistellig (Reiter der Mappe).
  String get platzNr {
    final i = spieler.indexWhere((s) => s.id == ichId);
    return '${i < 0 ? 1 : i + 1}'.padLeft(2, '0');
  }

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

  /// Aussehen einer Figur für Fotoabzüge (`null`: Schattenriss).
  LookDef? aussehen(String? id) => onlineAussehen(daten, id);

  /// Kennung der Detektivfigur der Akte (das Gerät auf dem Detektiv-Sitz spielt sie).
  String? get detektivId => onlineDetektivId(daten);

  /// Name am Tisch zu einer Figur: Gast mit dieser Rolle, der Platz auf dem
  /// Detektiv-Sitz für den Detektiv, sonst der Figurenname (ein Bot spielt sie).
  String personAmTisch(String id) {
    if (id == detektivId) {
      if (onlineDetektivPlatz(spieler) case final d?) return d.name;
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
      return gastLobby(c, marke);
    case 'rollen':
      return _rollen(c);
    // Einstimmung (A-063): Vorgeschichte und Vorstellung vor Vorspiel und Diashow (gast_einstimmung.dart).
    case 'intro' when gastEinstimmungSchritt(c) != null:
      return _abschnitt(c, rundenMarke, gastEinstimmungTitel(c, gastEinstimmungSchritt(c)!), [GastEinstimmung(kontext: c)],
          mitErzaehlertext: false, vorleserKarte: false, weiter: false, aktionen: gastEinstimmungAktionen(c));
    // Langer Abend (M7b): erst das Vorspiel, dann die Diashow (gast_rundgang.dart).
    case 'intro' when gastRundgang(c) != null:
      return _abschnitt(c, rundenMarke, l.rundgang_vorspiel, [GastRundgang(kontext: c)],
          mitErzaehlertext: false, vorleserKarte: false, weiter: false, aktionen: gastRundgangAktionen(c));
    // Diashow zur Einleitung (M4): Bild für alle, Text nur beim Vorleser (gast_diashow.dart).
    case 'intro' when gastMitDiashow(c):
      return _abschnitt(c, rundenMarke, l.online_phase_intro, [GastDiashow(kontext: c)], mitErzaehlertext: false);
    case 'intro':
      return _abschnitt(c, rundenMarke, l.online_phase_intro, []);
    // Langer Abend (M7b): Der Gast-Detektiv geht auf Streifzug (gast_streifzug.dart).
    case 'gespraeche' || 'entscheidungen' when c.ermittelt && c.fassung.istLang && c.v['streifzug'] is Map:
      return _abschnitt(c, rundenMarke, phase == 'gespraeche' ? l.online_phase_gespraeche : l.online_phase_entscheidungen, [?gastMomentAufruf(c), gastDetektivStreifzug(c)]);
    // Der Gast auf dem Detektiv-Sitz ermittelt selbst (M3, gast_ermittlung.dart).
    // „Dein Moment“ (Finale §3): wer leitet, gibt den letzten Aufruf; wer eine Figur spielt, zieht.
    case 'gespraeche' when c.ermittelt:
      return _abschnitt(c, rundenMarke, l.online_phase_gespraeche, [?gastMomentAufruf(c), gastDetektivGespraeche(c)]);
    case 'gespraeche':
      return _abschnitt(c, rundenMarke, l.online_phase_gespraeche,
          [?gastStreifzugStatus(c), ?gastMomentAufruf(c), ?gastMomentKarte(c), ?gastMomentHinweis(c), _gespraeche(c)]);
    case 'entscheidungen' when c.ermittelt:
      return _abschnitt(c, rundenMarke, l.online_phase_entscheidungen, [GastErmittlung(key: ValueKey('ermittlung-${c.runde}'), kontext: c)]);
    case 'entscheidungen':
      return _abschnitt(c, rundenMarke, l.online_phase_entscheidungen, [?gastStreifzugStatus(c), _ermittlung(c)]);
    case 'gruppenwahl':
      return _abschnitt(c, rundenMarke, l.online_phase_gruppenwahl, [GastGruppenwahl(key: ValueKey('wahl-${c.runde}'), kontext: c)]);
    case 'bonus':
      return _abschnitt(c, rundenMarke, l.online_phase_bonus, []);
    // „Dein Moment“: im Zwischenresümee die Leisten und Gerüchte der Runde für alle.
    case 'resuemee':
      return _abschnitt(c, rundenMarke, l.online_phase_resuemee, [?gastEinflussWirkungen(c)]);
    case 'anklage' when c.ermittelt:
      return _abschnitt(c, marke, l.online_phase_anklage, [GastAnklage(kontext: c)]);
    case 'anklage':
      return _abschnitt(c, marke, l.online_phase_anklage, [_anklage(c)]);
    case 'finale':
      return _abschnitt(c, marke, l.online_phase_finale, [], aktionen: _belohnungOhneGastgeber(c));
    case 'aufloesung':
      return _abschnitt(c, marke, l.online_phase_aufloesung, [_aufloesung(c), ?gastEinflussAufloesung(c)], aktionen: _belohnungOhneGastgeber(c));
    // Langer Abend (M7b): nach der Auflösung der Morgen, dann das Schlussbild.
    case 'ende' when gastRundgang(c) != null:
      return _abschnitt(c, marke, l.rundgang_morgen, [GastRundgang(kontext: c)],
          mitErzaehlertext: false, vorleserKarte: false, weiter: false, aktionen: [...gastRundgangAktionen(c), ..._belohnungOhneGastgeber(c)]);
    case 'ende':
      return _ende(c, marke);
    default:
      return _abschnitt(c, marke, l.online_phase_unbekannt, []);
  }
}

// ---------------------------------------------------------------- Bausteine

/// Formularkopf eines Blatts: Schreibmaschinenzeile in Stempelrot über einer
/// Tintenlinie.
List<Widget> _formkopf(String titel) => [
      Text(titel, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
      const SizedBox(height: 4),
      Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
      const SizedBox(height: MMass.s12),
    ];

/// Samen aus den Zeichen eines Textes (gleicher Text, gleiches Blatt).
int _samen(String text, [int start = 5]) => text.codeUnits.fold(start, (a, b) => (a * 31 + b) & 0xffff);

/// Ein Blatt der Gastansicht mit Kapitälchen-Formularkopf. Art, Klammer,
/// Klebestreifen und Reißnagel geben jedem Dokument seine Gestalt.
class _Block extends StatelessWidget {
  const _Block({
    required this.titel,
    required this.kinder,
    this.hervorgehoben = false,
    this.art = PapierArt.akte,
    this.klammer = false,
    this.klebestreifen = false,
    this.reissnagel = false,
  });

  final String? titel;
  final List<Widget> kinder;
  final bool hervorgehoben;
  final PapierArt art;
  final bool klammer;
  final bool klebestreifen;
  final bool reissnagel;

  @override
  Widget build(BuildContext context) {
    final kopf = titel;
    final samen = _samen(kopf ?? '', art.index * 7 + 5);
    final oben = klebestreifen || reissnagel;
    return Padding(
      padding: EdgeInsets.only(bottom: MMass.s16, top: klammer || oben ? MMass.s12 : 0),
      child: MBlatt(
        art: art,
        hervorgehoben: hervorgehoben,
        klammer: klammer,
        klebestreifen: klebestreifen,
        reissnagel: reissnagel,
        kopfLinie: art == PapierArt.karteikarte ? 7 : null,
        linien: art != PapierArt.karteikarte,
        neigung: samen.isEven ? -0.004 : 0.004,
        samen: samen,
        // Unter der Büroklammer beginnt der Kopf erst, wo sie endet.
        padding: EdgeInsets.fromLTRB(20, oben ? 24 : (klammer ? 34 : 18), 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (kopf != null) ..._formkopf(kopf.toUpperCase()),
            ...kinder,
          ],
        ),
      ),
    );
  }
}

/// Wartezettel mit Taschenuhr und Abstand nach unten.
Widget _notiz(String text, {Key? textKey, String? titel, String? stempel, bool gross = false, bool uhr = true}) => Padding(
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: OnlineWarteNotiz(text: text, textKey: textKey, titel: titel, stempel: stempel, gross: gross, uhr: uhr, samen: _samen(text)),
    );

/// Fotoabzug einer Figur, sonst ein Schattenriss.
Widget _foto(GastKontext c, String? id, {double groesse = 52, double neigung = -0.04, bool klammer = false}) {
  final look = c.aussehen(id);
  if (look == null) return MOnlineSilhouette(groesse: groesse, neigung: neigung, samen: _samen(id ?? ''));
  return MFotoabzug(look: look, groesse: groesse, neigung: neigung, klammer: klammer, akzent: c.figurFarbe(id));
}

/// Erzählertext (fertige Texte aus der Ansicht) als getippte Berichtsblätter,
/// leicht versetzt gestapelt. Vor dem Finale hat ihn nur der Vorleser-Sitz.
Widget _erzaehler(GastKontext c) {
  final bloecke = c.erzaehlerTexte;
  if (bloecke.isEmpty) return const SizedBox.shrink();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < bloecke.length; i++)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? MMass.s12 : 0, bottom: MMass.s16),
          child: MBlatt(
            neigung: i.isEven ? -0.004 : 0.005,
            klammer: i == 0,
            samen: _samen(bloecke[i], 0),
            padding: EdgeInsets.fromLTRB(22, i == 0 ? 34 : 20, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i == 0) ..._formkopf(c.l.online_erzaehler_titel.toUpperCase()),
                // Schmal und mit großer Schrift bricht kein Wort mitten durch (wie am Tisch).
                MGanzeWorte(bloecke[i], stil: MPapierSchrift.erzaehler, minimum: 14),
              ],
            ),
          ),
        ),
    ],
  );
}

/// Eine Zeile Text mit Tintenpunkt (auf Papier).
Widget _punkt(String text) => Padding(
      padding: const EdgeInsets.only(bottom: MMass.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10),
            child: Container(width: 6, height: 6, decoration: BoxDecoration(color: MRoh.stempelRot.withValues(alpha: 0.8), shape: BoxShape.circle)),
          ),
          Expanded(child: Text(text, style: MPapierSchrift.text)),
        ],
      ),
    );

/// Die Plätze am Tisch als Gästeregister: je Platz eine Karteikarte mit
/// Fotoabzug der Figur (Schattenriss, solange die Rolle unbekannt ist).
Widget _tisch(GastKontext c, {bool mitFiguren = true}) {
  final spieler = c.spieler;
  return Padding(
    padding: const EdgeInsets.only(top: MMass.s8, bottom: MMass.s16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnlineRegisterKopf(c.l.online_tisch_titel.toUpperCase()),
        for (var i = 0; i < spieler.length; i++) _platz(c, spieler[i], i, mitFiguren: mitFiguren),
      ],
    ),
  );
}

Widget _platz(GastKontext c, SpielerInfo s, int nr, {required bool mitFiguren}) {
  final l = c.l;
  final rolle = mitFiguren ? s.rolle : null;
  final figur = rolle == null ? '' : c.figurName(rolle);
  // Der Detektiv-Sitz spielt den Detektiv: sein Abzug zeigt ihn schon in der
  // Lobby, wie auf dem Gerät des Gastgebers.
  final bild = rolle ?? (s.sitz == Sitz.detektiv ? c.detektivId : null);
  // Sitze (M3): Detektiv und Erzähler tragen ihr Etikett, der Gastgeber nur, wenn er keinen Sitz hat.
  final Widget? zustand = !s.online
      ? MChip(l.online_getrennt, icon: Icons.wifi_off_rounded, farbe: onlineWarnTinte)
      : c.phase == 'lobby'
          ? (s.istGastgeber
              ? MChip(l.online_spielleitung, icon: Icons.star_rounded)
              : s.bereit
                  ? onlineStempel(l.online_bereit)
                  : MChip(l.online_nicht_bereit, icon: Icons.hourglass_empty_rounded, farbe: MRoh.tinteLeise))
          : switch (s.sitz) {
              Sitz.erzaehler => MChip(l.abend_platz_erzaehler, icon: Icons.menu_book_rounded, farbe: MRoh.tinteLeise),
              Sitz.detektiv => MChip(c.detektivWort, icon: Icons.search_rounded, farbe: MRoh.tinteLeise),
              _ when s.istGastgeber => MChip(l.online_spielleitung, icon: Icons.star_rounded),
              Sitz.assistenz => MChip(l.online_assistenz, icon: Icons.visibility_outlined, farbe: MRoh.tinteLeise),
              _ => s.rolle == null ? MChip(l.online_assistenz, icon: Icons.visibility_outlined, farbe: MRoh.tinteLeise) : null,
            };
  return OnlinePlatzKarte(
    name: s.name,
    // Der eigene Platz trägt „(Du)“ als Randnotiz in Füllertinte.
    notiz: s.id == c.ichId ? '(${l.common_you})' : null,
    unter: figur != s.name ? figur : null,
    look: c.aussehen(bild),
    farbe: rolle == null ? null : c.figurFarbe(rolle),
    zustand: zustand,
    nr: nr,
  );
}

/// „Meine Rolle“ als geschlossener Aktendeckel; ein Tipp schlägt ihn auf und
/// zeigt das Dossier (während des Abends nachlesbar).
Widget _meineRolle(GastKontext c) {
  if (c.dossier == null) return const SizedBox.shrink();
  return _MeineRolle(key: const ValueKey('meine-rolle'), kontext: c);
}

class _MeineRolle extends StatefulWidget {
  const _MeineRolle({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  State<_MeineRolle> createState() => _MeineRolleState();
}

class _MeineRolleState extends State<_MeineRolle> {
  bool _offen = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.kontext;
    final rolle = c.rolle;
    final deckel = Semantics(
      button: true,
      expanded: _offen,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => setState(() => _offen = !_offen),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: MOnlineAktendeckel(
            reiter: 'Nr. ${c.platzNr}',
            farbe: c.figurFarbe(rolle),
            neigung: _offen ? 0 : -0.004,
            child: Row(
              children: [
                // Der Abzug ist Zierde: Der Knopf heißt nur „Meine Rolle: …“.
                ExcludeSemantics(child: _foto(c, rolle, groesse: 40, neigung: -0.05)),
                const SizedBox(width: MMass.s12),
                Expanded(child: Text(c.l.online_meine_rolle(c.figurName(rolle)), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20))),
                const SizedBox(width: MMass.s8),
                Icon(_offen ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: MRoh.tinte),
              ],
            ),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: MMass.s8, bottom: MMass.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          deckel,
          AnimatedSize(
            duration: MBewegung.normal(context),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _offen
                ? Padding(padding: const EdgeInsets.only(top: MMass.s16), child: DossierAnsicht(kontext: c))
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// Rahmen eines Abschnitts: Erzähler, Spezifisches, dann Rolle und Tisch.
///
/// Vorleser-Sitz (M3): Liest ein anderes Gerät vor, steht statt des Texts die
/// [VorleserKarte]. Der Erzähler-Sitz bekommt dazu sein Erzählerpaket
/// ([gastErzaehlerTeile]); wer leitet, hat „Weiter“ ([gastWeiter]).
///
/// [mitErzaehlertext] `false`: Der spezifische Teil zeigt den Erzähltext selbst (Diashow).
GastSeiteninhalt _abschnitt(GastKontext c, String marke, String titel, List<Widget> spezifisch,
    {List<Widget> aktionen = const [], bool mitErzaehlertext = true, bool vorleserKarte = true, bool weiter = true}) {
  final l = c.l;
  // Ein Rundgang (M7b) zeigt selbst, wer vorliest; die Karte zu den Texten der Einleitung käme zu früh.
  final liestAnderswo = vorleserKarte && c.erzaehlerTexte.isEmpty && c.v['erzaehlerLiest'] == true;
  return GastSeiteninhalt(
    marke: marke,
    titel: titel,
    untertitel: c.phase == 'lobby'
        ? null
        : c.sitz == Sitz.erzaehler
            ? l.online_erzaehler_hinweis
            : (c.rolle == null && c.sitz == Sitz.assistenz ? l.online_assistenz_text : null),
    kinder: [
      // Die gemeinsame Rundenuhr steht oben, solange sie läuft (M4, gast_uhr.dart).
      ?gastRundenUhr(c),
      if (mitErzaehlertext) _erzaehler(c),
      if (liestAnderswo)
        Padding(
          padding: const EdgeInsets.only(bottom: MMass.s16),
          child: VorleserKarte(name: c.leiterName, texte: jZahl(c.v['bausteinZahl'])),
        ),
      ...spezifisch,
      if (c.sitz == Sitz.erzaehler) ...gastErzaehlerTeile(c),
      // „Dein Moment“: Die Zug-Tafel der Runde sieht nur der Erzähler-Sitz.
      if (c.sitz == Sitz.erzaehler) ?gastEinflussTafel(c),
      if (spezifisch.isEmpty && c.erzaehlerTexte.isEmpty && !liestAnderswo && !c.leitet) _notiz(l.online_warten_spielleitung),
      _meineRolle(c),
      _tisch(c),
    ],
    aktionen: [...aktionen, if (weiter) ...gastWeiter(c)],
  );
}

/// „Weiter“ für das Gerät, das gerade leitet (meist der Erzähler-Sitz); frei,
/// sobald der Raum weiter kann (`kannWeiter`).
List<Widget> gastWeiter(GastKontext c) => [
      if (c.leitet)
        MKnopf(
          key: const ValueKey('gast-weiter'),
          text: c.l.online_weiter,
          icon: Icons.arrow_forward_rounded,
          // „Dein Moment“: Während des letzten Aufrufs wartet „Weiter“ auf den Countdown.
          onPressed: c.verbunden && c.v['kannWeiter'] == true && !gastMomentWartet(c) ? () => c.befehl({'typ': 'weiter'}) : null,
        ),
    ];

/// Schließt der Raum, bevor dieses Gerät die Phase „ende“ erhalten hat, bleiben
/// Finale oder Auflösung die letzte Ansicht, und sie enthält alles für die
/// Belohnung: Ist der Gastgeber weg oder der Raum zu, lässt sie sich hier abholen.
List<Widget> _belohnungOhneGastgeber(GastKontext c) => [
      if (c.belohnung != null && !c.verbunden) MKnopf(text: c.l.abend_belohnung_ansehen, icon: Icons.style_rounded, onPressed: c.belohnung),
    ];

// ------------------------------------------------------------------- Rollen

GastSeiteninhalt _rollen(GastKontext c) {
  final l = c.l;
  final d = c.dossier;
  if (d == null && (c.sitz == Sitz.erzaehler || c.ermittelt)) {
    // Erzähler und Detektiv lesen keine Rolle; wer leitet, führt weiter, sobald alle gelesen haben.
    return _abschnitt(c, l.online_gast_marke(raumCodeAnzeige(c.dienst.raumCode)), l.online_phase_rollen, [
      if (c.ermittelt) ...gastDetektivRollen(c),
      _notiz(l.online_sitz_rollen, textKey: const ValueKey('sitz-rollen')),
    ]);
  }
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
      Padding(padding: const EdgeInsets.only(bottom: MMass.s24), child: DossierAnsicht(kontext: c)),
      if (gelesen) _notiz(l.online_gelesen_warten, textKey: const ValueKey('rolle-gelesen')),
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

/// Das eigene Dossier als Aktenmappe wie beim Spiel an einem Gerät: Reiter mit
/// der Platznummer, Band in der Farbe der Figur, Fotoabzug mit Büroklammer und
/// die Abschnitte als Formularköpfe. Tarnung und Tatwissen stehen nur für
/// Täterin oder Täter da, aber ohne eigenen Kopf unter „Was ich verberge“: Ein
/// Blick über die Schulter sieht dieselben Blätter, Stempel und Köpfe in
/// derselben Folge (K-22, E-041).
class DossierAnsicht extends StatelessWidget {
  const DossierAnsicht({super.key, required this.kontext});

  final GastKontext kontext;

  @override
  Widget build(BuildContext context) {
    final c = kontext;
    final l = c.l;
    final d = c.dossier;
    if (d == null) return const SizedBox.shrink();
    final rolle = c.rolle;
    final tarnung = jText(d['tarnung']);
    final tatwissen = jTexte(d['tatwissen']);
    final besetzung = jText(d['besetzung']);
    return MAktenmappe(
      key: const ValueKey('dossier'),
      reiter: 'Nr. ${c.platzNr}',
      farbe: c.figurFarbe(rolle),
      stempel: l.online_dossier_stempel,
      blaetter: 3,
      // Oben bleibt Platz für den Stempel, damit er keine Zeile verdeckt.
      padding: const EdgeInsets.fromLTRB(18, 54, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fotoabzug neben „Wer ich bin“; wird es schmal oder die Schrift groß, darüber.
          LayoutBuilder(
            builder: (context, b) {
              final foto = _foto(c, rolle, groesse: 76, klammer: true);
              final wer = _dossierInhalt(l.online_dossier_wer, [Text(jText(d['wer']), style: MPapierSchrift.text)]);
              final skala = MediaQuery.textScalerOf(context).scale(10) / 10;
              if ((b.maxWidth - 108) / skala < 170) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [Align(alignment: Alignment.centerLeft, child: foto), const SizedBox(height: MMass.s20), wer],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  foto,
                  const SizedBox(width: MMass.s16),
                  Expanded(child: Padding(padding: const EdgeInsets.only(top: 6), child: wer)),
                ],
              );
            },
          ),
          _dossierAbschnitt(l.online_dossier_ziel, [Text(jText(d['ziel']), style: MPapierSchrift.text)]),
          // „Dein Moment“ (Finale §3.9): die zwei Sterne und eine kurze Erklärung.
          if (gastZiele(c) case final z?) _dossierAbschnitt(l.moment_ziele, [z]),
          _dossierAbschnitt(l.online_dossier_weiss, _zeilen(jTexte(d['weiss']))),
          _dossierAbschnitt(l.online_dossier_verbirgt, [
            if (tarnung.isNotEmpty) ...[
              Text(l.online_dossier_tarnung, style: MPapierSchrift.leise),
              Text(tarnung, style: MPapierSchrift.text),
              const SizedBox(height: 10),
            ],
            if (tatwissen.isNotEmpty) ...[
              Text(l.online_dossier_tatwissen, style: MPapierSchrift.leise),
              ..._zeilen(tatwissen),
            ],
            ..._zeilen(jTexte(d['verbirgt'])),
          ]),
          if (besetzung.isNotEmpty) _dossierAbschnitt(l.online_dossier_besetzung, [Text(besetzung, style: MPapierSchrift.leise)]),
        ],
      ),
    );
  }

  Widget _dossierAbschnitt(String titel, List<Widget> kinder) => Padding(
        padding: const EdgeInsets.only(top: 22),
        child: _dossierInhalt(titel, kinder),
      );

  Widget _dossierInhalt(String titel, List<Widget> kinder) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titel, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, fontSize: 15)),
          const SizedBox(height: 4),
          Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          ...kinder,
        ],
      );

  List<Widget> _zeilen(List<String> zeilen) => [
        for (final z in zeilen) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(z, style: MPapierSchrift.text)),
      ];
}

// ---------------------------------------------------------------- Gespräche

Widget _gespraeche(GastKontext c) {
  // Modell befragung (A-051): eigene Karte mit Stichpunkten statt Eröffnung, keine Sprechblasen der Bots.
  if (c.v.containsKey('tisch')) return GastBefragung(c: c);
  final l = c.l;
  final eigene = jMaps(c.privat['gespraeche']);
  final bots = jMaps(c.v['botGespraeche']);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (c.dossier != null) ...[
        const SizedBox(height: MMass.s8),
        OnlineRegisterKopf(l.online_gespraeche_titel.toUpperCase()),
        if (eigene.isEmpty) _notiz(l.online_gespraeche_keine, uhr: false),
        for (var i = 0; i < eigene.length; i++)
          Padding(padding: const EdgeInsets.only(top: MMass.s8, bottom: MMass.s16), child: _Gespraech(c: c, g: eigene[i], nr: i)),
      ],
      if (bots.isNotEmpty) ...[
        const SizedBox(height: MMass.s8),
        OnlineRegisterKopf(l.online_bots_titel.toUpperCase()),
        for (var i = 0; i < bots.length; i++) Padding(padding: const EdgeInsets.only(bottom: MMass.s16), child: _BotBlase(c: c, g: bots[i], nr: i)),
      ],
    ],
  );
}

/// Ein Pflichtgespräch dieses Geräts als Karteikarte: Fotoabzug des Gegenübers,
/// mit wem, Thema, Ziel und Eröffnungssatz.
class _Gespraech extends StatelessWidget {
  const _Gespraech({required this.c, required this.g, required this.nr});

  final GastKontext c;
  final Map<String, Object?> g;
  final int nr;

  @override
  Widget build(BuildContext context) {
    final l = c.l;
    final partner = jText(g['partner']);
    return MBlatt(
      art: PapierArt.karteikarte,
      kopfLinie: 7,
      linien: false,
      klammer: true,
      randFarbe: c.figurFarbe(partner),
      neigung: nr.isEven ? -0.004 : 0.004,
      samen: 40 + nr,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MOnlineBildZeile(
            bild: _foto(c, partner, groesse: 56, neigung: nr.isEven ? 0.04 : -0.04),
            text: Text(l.online_gespraech_mit(c.personAmTisch(partner)), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
          ),
          const SizedBox(height: MMass.s16),
          MFeld(name: l.online_gespraech_thema, wert: jText(g['thema'])),
          MFeld(name: l.online_gespraech_ziel, wert: jText(g['ziel'])),
          MFeld(name: l.online_gespraech_eroeffnung, wert: jText(g['text']), kursiv: true),
        ],
      ),
    );
  }
}

/// Öffentlicher Wortwechsel, den ein Bot führt, als Protokollstreifen: wer mit
/// wem spricht, das Thema, der Satz und was dabei herauskommt (als Randnotiz).
class _BotBlase extends StatelessWidget {
  const _BotBlase({required this.c, required this.g, required this.nr});

  final GastKontext c;
  final Map<String, Object?> g;
  final int nr;

  @override
  Widget build(BuildContext context) {
    final l = c.l;
    final rolle = jText(g['rolle']);
    final thema = jText(g['thema']);
    final preis = jMaps(g['preisgaben']);
    return MOnlineProtokoll(
      samen: 60 + nr,
      neigung: nr.isEven ? 0.003 : -0.003,
      randFarbe: c.figurFarbe(rolle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MOnlineBildZeile(
            abstand: MMass.s12,
            bild: _foto(c, rolle, groesse: 44, neigung: -0.05),
            text: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.online_bot_spricht(c.figurName(rolle), c.personAmTisch(jText(g['partner']))), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 17)),
                if (thema.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(thema, style: MPapierSchrift.leise)),
              ],
            ),
          ),
          const SizedBox(height: MMass.s12),
          Text(jText(g['text']), style: MPapierSchrift.kursiv),
          for (final p in preis)
            if (jText(p['text']).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: MMass.s8),
                child: Text('${l.online_preisgabe}: ${jText(p['text'])}', style: MPapierSchrift.hand.copyWith(fontSize: 22)),
              ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Ermittlung

Widget _ermittlung(GastKontext c) {
  final l = c.l;
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
      padding: const EdgeInsets.only(bottom: MMass.s16),
      child: Wrap(
        spacing: MMass.s8,
        runSpacing: MMass.s8,
        // Wird es eng, schrumpft das Etikett, statt die Zahl abzuschneiden.
        children: [
          for (final (text, icon) in [(l.online_nachtzeit(restMin), Icons.nightlight_round), (l.online_marken(marken), Icons.sell_outlined)])
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: MChip(text, icon: icon, passend: true)),
        ],
      ),
    ),
  ];

  if (z != null) {
    final id = jText(z['id']);
    final option = z['option'] is String ? z['option'] as String : null;
    final zugPhase = jText(z['phase']);
    // Altakten (ohne Erzähler-Sitz) sagen wie vor M3 „Spielleitung“, nie das Wort des Schlosskellers.
    final neu = c.mitErzaehlerSitz;
    final frage = id == 'auftakt' ? l.online_auftakt : (id.startsWith('abstecher:') ? (neu ? l.online_abstecher : l.online_abstecher_leitung) : frageZu(id));
    final gewaehlt = option == null ? '' : optionText(id, option);
    final wurf = z['wurf'] is Map ? jMap(z['wurf']) : null;
    kinder.add(_Block(
      titel: l.online_frage_titel,
      hervorgehoben: true,
      art: PapierArt.karteikarte,
      klammer: true,
      kinder: [
        if (frage.isNotEmpty) Text(frage, style: MPapierSchrift.ueberschrift),
        if (gewaehlt.isNotEmpty) ...[
          const SizedBox(height: MMass.s12),
          Text(l.online_gewaehlt_titel.toUpperCase(), style: MPapierSchrift.marke),
          const SizedBox(height: MMass.s4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 4, right: MMass.s8), child: Icon(Icons.check_rounded, size: 20, color: MRoh.tinteBlau)),
              Expanded(child: Text(gewaehlt, style: MPapierSchrift.text)),
            ],
          ),
        ],
      ],
    ));
    switch (zugPhase) {
      case 'aktion':
        kinder.add(_notiz(neu ? l.online_zug_aktion : l.online_zug_aktion_leitung));
      case 'wurf':
        kinder.add(GastWuerfel(kontext: c, zug: z));
      case 'tischruf':
        if (wurf != null) kinder.add(_wurfBlock(c, wurf));
        kinder.add(_notiz(neu ? l.online_tischruf_wartet : l.online_tischruf_wartet_leitung));
      case 'fund':
        if (wurf != null) kinder.add(_wurfBlock(c, wurf));
        final funde = jTexte(z['funde']);
        final neben = jText(z['nebenfund']);
        if (funde.isNotEmpty || neben.isNotEmpty) {
          kinder.add(_Block(
            titel: l.online_fund_titel,
            art: PapierArt.karteikarte,
            reissnagel: true,
            // „Dein Moment“: Randnotizen und Ertappt sind öffentlich.
            kinder: [for (final f in funde) _punkt(f), if (neben.isNotEmpty) Text(neben, style: MPapierSchrift.text), ?gastFundZusatz(c, z)],
          ));
        } else {
          kinder.add(_notiz(neu ? l.online_fund_wartet : l.online_fund_wartet_leitung));
        }
    }
  } else if (e != null) {
    final optionen = jMaps(e['optionen']);
    kinder.add(_Block(
      titel: l.online_frage_titel,
      hervorgehoben: true,
      art: PapierArt.karteikarte,
      klammer: true,
      kinder: [
        Text(jText(e['frage']), style: MPapierSchrift.ueberschrift),
        const SizedBox(height: MMass.s12),
        Text(l.online_optionen_titel.toUpperCase(), style: MPapierSchrift.marke),
        const SizedBox(height: MMass.s8),
        for (final o in optionen) ...[_punkt(jText(o['text'])), ?gastAbzeichen(c, jText(o['id']))],
        const SizedBox(height: MMass.s8),
        Row(
          children: [
            const MOnlineTaschenuhr(groesse: 28),
            const SizedBox(width: MMass.s12),
            Expanded(child: Text(c.mitErzaehlerSitz ? l.online_ermittlung_wartet : l.online_ermittlung_wartet_leitung, style: MPapierSchrift.leise)),
          ],
        ),
      ],
    ));
  } else {
    kinder.add(_notiz(l.online_ermittlung_fertig));
  }

  if (notizbuch.isNotEmpty) {
    kinder.add(_Block(
      titel: l.online_notizbuch_titel,
      art: PapierArt.notiz,
      kinder: [
        for (final eintrag in notizbuch.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (frageZu(eintrag.key).isNotEmpty) Text(frageZu(eintrag.key), style: MPapierSchrift.leise),
                for (final f in jTexte(eintrag.value)) _punkt(f),
              ],
            ),
          ),
      ],
    ));
  }
  if (wuerfe.isNotEmpty) {
    kinder.add(_Block(
      titel: l.online_wuerfe_titel,
      art: PapierArt.telegramm,
      kinder: [
        for (final w in wuerfe)
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s4),
            child: Text(
              l.online_wurf_zeile(c.stufeWort(jText(w['stufe'])), jZahl(w['a']), jZahl(w['b']), jZahl(w['mod']), jZahl(w['a']) + jZahl(w['b']) + jZahl(w['mod'])),
              style: MPapierSchrift.maschine.copyWith(fontSize: 14),
            ),
          ),
      ],
    ));
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: kinder);
}

/// Das Ergebnis eines Wurfs: Stufe groß, darunter die Rechnung in Schreibmaschine.
Widget _wurfBlock(GastKontext c, Map<String, Object?> w) {
  final l = c.l;
  final summe = jZahl(w['a']) + jZahl(w['b']) + jZahl(w['mod']);
  return _Block(
    titel: l.online_wurf_titel,
    hervorgehoben: true,
    kinder: [
      Text(c.stufeWort(jText(w['stufe'])), key: const ValueKey('wurf-stufe'), style: MPapierSchrift.titel),
      const SizedBox(height: MMass.s4),
      Text(l.online_wurf_rechnung(jZahl(w['a']), jZahl(w['b']), jZahl(w['mod']), summe), style: MPapierSchrift.maschine),
      if (w['garantie'] == true) Padding(padding: const EdgeInsets.only(top: MMass.s4), child: Text(l.online_wurf_garantie, style: MPapierSchrift.leise)),
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
    final chancen = jMap(z['chancen']);
    final marken = jZahl(c.v['marken']);
    final pate = c.nameVon(jText(c.v['wuerfelPate']));
    final offen = c.verbunden && !_laeuft;
    return _Block(
      titel: l.online_wuerfel_titel,
      hervorgehoben: true,
      klammer: true,
      kinder: [
        Text(_meinWurf ? l.online_wuerfel_du : l.online_wuerfelt(pate), key: const ValueKey('wuerfel-pate'), style: MPapierSchrift.ueberschrift),
        const SizedBox(height: MMass.s12),
        Text(l.online_chancen(jZahl(z['mod'])), style: MPapierSchrift.leise),
        // „Dein Moment“ (Finale §3.4): Zeile „Tisch“ der Chancenvorschau.
        if (jMap(z['tischVorschau']) case final t when jZahl(t['tisch']) != 0 || jZahl(t['umweg']) != 0)
          Text(
            [
              if (jZahl(t['tisch']) != 0) '${l.einfluss_tisch} ${jZahl(t['tisch']) > 0 ? '+' : '-'}${jZahl(t['tisch']).abs()}',
              if (jZahl(t['umweg']) != 0) '${l.einfluss_umweg} +${jZahl(t['umweg'])}',
            ].join(' · '),
            key: const ValueKey('gast-chance-tisch'),
            style: MPapierSchrift.maschine,
          ),
        const SizedBox(height: MMass.s8),
        for (final stufe in ['erfolg', 'teilerfolg', 'pech'])
          Padding(
            padding: const EdgeInsets.only(bottom: MMass.s4),
            child: Row(
              children: [
                Expanded(child: Text(c.stufeName(stufe), style: MPapierSchrift.maschine)),
                const SizedBox(width: MMass.s8),
                Text('${jZahl(chancen[stufe])} %', style: MPapierSchrift.maschine),
              ],
            ),
          ),
        if (_meinWurf) ...[
          const SizedBox(height: MMass.s8),
          if (!_auftakt && _werkzeuge.isNotEmpty)
            for (final k in _werkzeuge)
              MHaken(
                key: ValueKey('werkzeug-${k['id']}'),
                wert: _karteWert == k['id'],
                onChanged: offen ? (v) => _hilfe(karte: v ? jText(k['id']) : null, karteLeer: !v) : null,
                text: l.online_werkzeug_einsetzen(c.dienst.katalog?[jText(k['id'])]?.titel ?? KartenTexte.art(KartenArt.werkzeug)),
              ),
          if (!_auftakt && !_abstecher && marken > 0)
            MHaken(
              key: const ValueKey('marke-einsetzen'),
              wert: _markeWert,
              onChanged: offen ? (v) => _hilfe(marke: v) : null,
              text: l.online_marke_einsetzen,
            ),
          const SizedBox(height: MMass.s12),
          MKnopf(
            text: l.online_wuerfeln_knopf,
            icon: Icons.casino_outlined,
            breit: true,
            onPressed: offen ? _wuerfeln : null,
          ),
        ],
      ],
    );
  }
}

// -------------------------------------------------------------- Gruppenwahl

/// Die eigene Rundenwahl als Stimmzettel: zwei Zeilen mit Kreis, A oder B;
/// niemand sieht, was man wählt.
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
    final wahl = c.privat['wahl'] is Map ? jMap(c.privat['wahl']) : null;
    if (c.dossier == null) {
      // Detektiv und Erzähler wählen nicht mit; Assistenz hat keine Stimme.
      return _notiz(c.sitz == Sitz.erzaehler || c.ermittelt ? l.online_wahl_sitz : l.online_wahl_assistenz);
    }
    if (c.privat['hatGestimmt'] == true) {
      return _notiz(
        l.online_wahl_abgegeben,
        textKey: const ValueKey('wahl-abgegeben'),
        titel: l.online_wahl_titel.toUpperCase(),
        stempel: l.online_wahl_abgegeben_kurz,
        gross: true,
      );
    }
    if (wahl == null) {
      return _notiz(l.online_warten_spielleitung);
    }
    return _Block(
      titel: l.online_wahl_titel,
      hervorgehoben: true,
      klebestreifen: true,
      kinder: [
        Text(l.online_wahl_geheim, style: MPapierSchrift.leise),
        const SizedBox(height: MMass.s16),
        _WahlKarte(key: const ValueKey('wahl-a'), text: jText(wahl['a']), gewaehlt: _kooperativ == true, onTippen: () => setState(() => _kooperativ = true)),
        const SizedBox(height: MMass.s12),
        _WahlKarte(key: const ValueKey('wahl-b'), text: jText(wahl['b']), gewaehlt: _kooperativ == false, onTippen: () => setState(() => _kooperativ = false)),
        const SizedBox(height: MMass.s20),
        MKnopf(
          text: l.online_wahl_abgeben,
          breit: true,
          onPressed: _kooperativ != null && c.verbunden && !_laeuft ? _abgeben : null,
        ),
      ],
    );
  }
}

/// Eine Zeile des Stimmzettels: Kreis zum Ankreuzen und die Antwort. Die
/// gewählte Zeile trägt ein Kreuz in Füllertinte und einen blauen Rahmen.
class _WahlKarte extends StatelessWidget {
  const _WahlKarte({super.key, required this.text, required this.gewaehlt, required this.onTippen});

  final String text;
  final bool gewaehlt;
  final VoidCallback onTippen;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: gewaehlt,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTippen,
            borderRadius: BorderRadius.circular(3),
            splashFactory: NoSplash.splashFactory,
            highlightColor: MRoh.tinte.withValues(alpha: 0.06),
            child: AnimatedContainer(
              duration: MBewegung.schnell(context),
              constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
              decoration: BoxDecoration(
                color: gewaehlt ? MRoh.tinteBlau.withValues(alpha: 0.06) : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: gewaehlt ? MRoh.tinteBlau.withValues(alpha: 0.8) : MRoh.tinte.withValues(alpha: 0.35),
                  width: gewaehlt ? 1.8 : 1.1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MOnlineStimmkreis(angekreuzt: gewaehlt),
                  const SizedBox(width: 14),
                  Expanded(child: Padding(padding: const EdgeInsets.only(top: 3), child: Text(text, style: MPapierSchrift.text))),
                ],
              ),
            ),
          ),
        ),
      );
}

// ------------------------------------------------- Anklage und Auflösung

/// Die Verdächtigen als Reihe von Fotoabzügen, alle gleich gesetzt: kein
/// Ausgrauen, keine Reihenfolge nach Verdacht.
Widget _anklage(GastKontext c) {
  final l = c.l;
  final verdaechtige = jTexte(c.v['verdaechtige']);
  return _Block(
    titel: l.online_verdaechtige_titel,
    reissnagel: true,
    kinder: [
      Text(c.mitErzaehlerSitz ? l.online_anklage_wartet : l.online_anklage_wartet_leitung, style: MPapierSchrift.leise),
      const SizedBox(height: MMass.s16),
      for (var i = 0; i < verdaechtige.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: MMass.s12),
          child: MOnlineBildZeile(
            bild: _foto(c, verdaechtige[i], groesse: 52, neigung: i.isEven ? -0.04 : 0.035),
            text: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.figurName(verdaechtige[i]), style: MPapierSchrift.ueberschrift.copyWith(fontSize: 20)),
                if (c.figurTitel(verdaechtige[i]).isNotEmpty) Text(c.figurTitel(verdaechtige[i]), style: MPapierSchrift.leise),
              ],
            ),
          ),
        ),
    ],
  );
}

Widget _aufloesung(GastKontext c) {
  final l = c.l;
  final a = c.v['aufloesung'] is Map ? jMap(c.v['aufloesung']) : null;
  if (a == null) return const SizedBox.shrink();
  final regel = c.endeRegel(jText(a['ende']));
  final pfad = jText(a['pfad']);
  Widget wert(String titel, String w, {TextStyle? stil}) => Padding(
        padding: const EdgeInsets.only(bottom: MMass.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titel.toUpperCase(), style: MPapierSchrift.marke),
            const SizedBox(height: 2),
            Text(w, style: stil ?? MPapierSchrift.ueberschrift),
          ],
        ),
      );
  return _Block(
    titel: l.online_aufloesung_titel,
    hervorgehoben: true,
    klammer: true,
    kinder: [
      MOnlineBildZeile(
        bild: _foto(c, pfad, groesse: 76),
        text: wert(l.online_aufloesung_taeter, c.figurName(pfad)),
      ),
      const SizedBox(height: MMass.s8),
      wert(l.online_aufloesung_punkte, '${jZahl(a['punkte'])}'),
      if (regel != null) wert(l.online_aufloesung_ende, regel.name),
      // Bei fester Lösung führt kein Code zu einem anderen Abend (wie auf der Abschlusstafel).
      if (c.daten?.kanon.festeLoesung != true)
        wert(l.online_aufloesung_code, jText(a['fallCode']), stil: MPapierSchrift.maschine.copyWith(fontSize: 22, letterSpacing: 3)),
      // Erst nach dem Finale: Die Akte wird zugestempelt, bei jedem Ausgang mit demselben Stempel.
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(top: MMass.s4, right: MMass.s4),
          child: MStempel(text: l.ending_case_closed, groesse: 15, winkel: -0.14, aufschlagen: true),
        ),
      ),
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
      ?gastEinflussAufloesung(c),
      _meineRolle(c),
      _tisch(c),
    ],
    aktionen: [
      MKnopf(text: l.abend_belohnung_ansehen, icon: Icons.style_rounded, onPressed: c.belohnung),
    ],
  );
}
