// Testhilfe für die Online-Bildschirme: ein echter Raum, durch den ein Abend
// läuft, liefert die Ansichten eines Gastgeräts je Abschnitt; ein Gastgerät
// ohne Verbindung zeigt sie in der Gastseite (wie `GastSeite`, nur ohne Netz).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/gast_ansicht.dart';
import 'package:mordakte/abend/online/ansicht.dart';
import 'package:mordakte/abend/online/gast_dienst.dart';
import 'package:mordakte/abend/online/gastgeber_dienst.dart';
import 'package:mordakte/l10n/gen/app_localizations.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show AbendFehler, Ablage, LokaleVerbindung, SpeicherAblage, VerbindungsStatus;

import '../party_widgets/hilfe.dart' show akteDaten, partyDaten;

const _karte = 'schlosskeller:ahmet:lupe';

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? wert) => [for (final v in wert as List) _map(v)];

/// Gastgerät mit fester Ansicht und Akte; alles andere ist nicht nötig.
class TestGast implements GastDienst {
  TestGast(this.ansicht, {this.spielerId = 'g1', this.status = VerbindungsStatus.verbunden}) : daten = partyDaten;

  @override
  final Map<String, Object?> ansicht;

  @override
  final PartyDaten? daten;

  @override
  final VerbindungsStatus status;

  @override
  final String spielerId;

  @override
  String get raumCode => 'ABCDEF';

  @override
  KartenKatalog? get katalog => null;

  @override
  bool get geschlossen => status == VerbindungsStatus.geschlossen;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void dispose() {}

  @override
  Future<void> trennen() async {}

  @override
  Future<void> verlassen() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Ein Raum mit Gastgeberin Anna und den Gästen Ben (`g1`) und Cleo (`g2`, langer Name),
/// Täterpfad [pfad] und einer Werkzeugkarte im Vorrat.
SchlosskellerRaum testRaum({String pfad = 'ahmet'}) {
  final raum = SchlosskellerRaum(
    raumCode: 'ABCDEF',
    kanon: partyDaten.kanon,
    texte: partyDaten.texte,
    fallCode: FallCode.fuerPfad(pfad, partyDaten.kanon.pfade),
    salz: 'salz-test',
    festerGastgeber: true,
    katalog: KartenKatalog([
      KartenDef(
        id: _karte, akte: 'schlosskeller', figur: 'ahmet', seltenheit: Seltenheit.gewoehnlich,
        art: KartenArt.werkzeug, titel: 'Lupe', text: 'Ein Werkzeug aus der Welt.', quellen: const [KartenQuelle('start')],
      ),
    ]),
  );
  raum.beitreten('gastgeber', 'Anna');
  raum.beitreten('g1', 'Ben');
  raum.beitreten('g2', 'Cleopatra Konstantinopoulou-Wagenknecht');
  return raum;
}

/// Startet den Abend im Raum: alle bereit, vier Rollen.
void starte(SchlosskellerRaum raum) {
  for (final id in ['g1', 'g2', 'gastgeber']) {
    raum.nachricht(id, {'typ': 'bereit', 'wert': true});
  }
  raum.nachricht('gastgeber', {'typ': 'start', 'rollen': 4, 'detektiv': 'w', 'vorrat': [_karte]});
}

/// Modell befragung (A-051): Der Detektiv ([detektiv]) erledigt die Befragungen
/// der Runde über Nachrichten – feste und so viele freie, wie erlaubt, je mit
/// der ersten Frage; was ein Mensch beantwortet, markiert er als erledigt.
/// Ohne Befragungen (Altakte, andere Phase) geschieht nichts.
void befragungenImRaum(SchlosskellerRaum raum, {String detektiv = 'gastgeber'}) {
  final privat = _map(raum.zustandFuer(detektiv)['privat']);
  final karten = privat['befragungen'];
  if (karten is! List) return;
  var frei = privat['befragungenFrei'] as int;
  for (final k in _liste(karten)) {
    if (k['erledigt'] == true) continue;
    if (k['frage'] == null) {
      if (k['pflicht'] != true) {
        if (frei <= 0) continue;
        frei--;
      }
      raum.nachricht(detektiv, {'typ': 'befragen', 'id': k['id'], 'frage': 0});
    }
    if (k['mensch'] == true) raum.nachricht(detektiv, {'typ': 'erledigt', 'id': k['id']});
  }
}

/// Ein Schritt des Abends wie in der Raumprüfung: Gäste lesen und stimmen,
/// die Spielleitung wählt richtig, würfelt über den Würfelpaten und geht weiter.
/// [vorWeiter] läuft nach dem Lesen der Rollen und nach den Stimmen, bevor die
/// Spielleitung weitergeht.
void schritt(SchlosskellerRaum raum, Ermittlung erm, String pfad, {void Function()? vorWeiter}) {
  final s = raum.zustandFuer('gastgeber');
  switch (s['phase']) {
    case 'rollen':
      for (final t in _liste(s['spieler'])) {
        if (t['rolle'] != null && t['online'] == true) raum.nachricht(t['id'] as String, {'typ': 'rollenGelesen'});
      }
      vorWeiter?.call();
      raum.nachricht('gastgeber', {'typ': 'weiter'});
    case 'entscheidungen':
      if (s['zug'] case final Map zug) {
        switch (zug['phase']) {
          case 'aktion':
            raum.nachricht('gastgeber', {'typ': 'aktionFertig', 'aktion': zug['aktion']});
          case 'wurf':
            raum.nachricht(s['wuerfelPate'] as String, {'typ': 'wurf'});
          case 'tischruf':
            raum.nachricht('gastgeber', {'typ': 'tischruf', 'ruf': 'umweg'});
          case 'fund':
            raum.nachricht('gastgeber', {'typ': 'fundGelesen'});
          default:
            fail('Unerwarteter Zugabschnitt ${zug['phase']}');
        }
      } else if (s['entscheidung'] case final Map e) {
        final option = erm.entscheidung(e['id'] as String).richtig[pfad]!;
        raum.nachricht('gastgeber', {'typ': 'wahl', 'option': option});
      } else {
        raum.nachricht('gastgeber', {'typ': 'weiter'});
      }
    case 'gespraeche':
      befragungenImRaum(raum);
      vorWeiter?.call();
      raum.nachricht('gastgeber', {'typ': 'weiter'});
    case 'gruppenwahl':
      for (final t in _liste(s['spieler'])) {
        if (t['rolle'] != null && t['online'] == true) raum.nachricht(t['id'] as String, {'typ': 'stimme', 'kooperativ': true});
      }
      vorWeiter?.call();
      raum.nachricht('gastgeber', {'typ': 'weiter'});
    case 'anklage':
      raum.nachricht('gastgeber', {'typ': 'anklage', 'person': pfad});
      raum.nachricht('gastgeber', {'typ': 'weiter'});
    default:
      raum.nachricht('gastgeber', {'typ': 'weiter'});
  }
}

/// Ein gestarteter Raum mit Anna (Gastgeberin), Ben (`g1`), Cleo (`g2`) und
/// Dora (`g3`), vier Rollen, Pfad ahmet; die Sitze vergibt die Lobby (M3):
/// [detektiv] und [erzaehler] sind Geräte (der Gastgeber sitzt auf einem davon).
/// Der Detektiv-Sitz eines Gastes trägt die Klasse [klasse].
SchlosskellerRaum sitzRaum({String detektiv = 'gastgeber', String? erzaehler, String? klasse = 'profiler', PartyDaten? daten}) {
  final d = daten ?? akteDaten('schlosskeller');
  final raum = SchlosskellerRaum(
    raumCode: 'ABCDEF',
    kanon: d.kanon,
    texte: d.texte,
    fallCode: FallCode.fuerPfad('ahmet', d.kanon.pfade),
    salz: 'salz-test',
    festerGastgeber: true,
    gastgeberSitz: erzaehler == 'gastgeber' ? Sitz.erzaehler : Sitz.detektiv,
  );
  for (final (id, name) in [('gastgeber', 'Anna'), ('g1', 'Ben'), ('g2', 'Cleo'), ('g3', 'Dora')]) {
    raum.beitreten(id, name);
  }
  if (erzaehler != null && erzaehler != 'gastgeber') raum.nachricht('gastgeber', {'typ': 'sitz', 'spieler': erzaehler, 'sitz': 'erzaehler'});
  if (detektiv != 'gastgeber') raum.nachricht('gastgeber', {'typ': 'sitz', 'spieler': detektiv, 'sitz': 'detektiv', 'klasse': ?klasse});
  for (final id in ['g1', 'g2', 'g3', 'gastgeber']) {
    raum.nachricht(id, {'typ': 'bereit', 'wert': true});
  }
  raum.nachricht('gastgeber', {'typ': 'start', 'rollen': 4, 'detektiv': 'w', 'vorrat': const <String>[]});
  return raum;
}

/// Spielt in einem Raum mit Sitzen bis zum Abschnitt [phase]: Rollen lesen,
/// Befragungen und Ermittlung vom Detektiv-Sitz [detektiv], „Weiter“ vom
/// Leiter [leiter] (Erzähler, sonst Detektiv). Mit [ersteEntscheidung] bis zur
/// ersten offenen Frage der Entscheidungen.
void spieleBisSitz(SchlosskellerRaum raum, String phase, {required String detektiv, required String leiter, bool ersteEntscheidung = false}) {
  final erm = raum.partieFuerGastgeber!.spiel.ermittlung;
  for (var i = 0; i < 400; i++) {
    final s = raum.zustandFuer(detektiv);
    if (s['phase'] == phase && (!ersteEntscheidung || (s['entscheidung'] is Map && s['zug'] == null))) return;
    switch (s['phase']) {
      case 'rollen':
        for (final t in _liste(s['spieler'])) {
          if (t['rolle'] != null && t['online'] == true) raum.nachricht(t['id'] as String, {'typ': 'rollenGelesen'});
        }
      case 'gespraeche':
        befragungenImRaum(raum, detektiv: detektiv);
      case 'gruppenwahl':
        for (final t in _liste(s['spieler'])) {
          if (t['rolle'] != null && t['online'] == true && s['kannWeiter'] != true) {
            try {
              raum.nachricht(t['id'] as String, {'typ': 'stimme', 'kooperativ': true});
            } on PartyRaumFehler {
              // Schon gestimmt.
            }
          }
        }
      case 'anklage':
        if (s['kannWeiter'] != true) raum.nachricht(detektiv, {'typ': 'anklage', 'person': 'ahmet'});
      case 'entscheidungen':
        if (s['zug'] case final Map zug) {
          switch (zug['phase']) {
            case 'aktion':
              raum.nachricht(detektiv, {'typ': 'aktionFertig', 'aktion': zug['aktion']});
            case 'wurf':
              raum.nachricht(s['wuerfelPate'] as String, {'typ': 'wurf'});
            case 'tischruf':
              raum.nachricht(detektiv, {'typ': 'tischruf', 'ruf': 'umweg'});
            case 'fund':
              raum.nachricht(detektiv, {'typ': 'fundGelesen'});
          }
          continue;
        } else if (s['entscheidung'] case final Map e) {
          raum.nachricht(detektiv, {'typ': 'wahl', 'option': erm.entscheidung(e['id'] as String).richtig['ahmet']!});
          continue;
        }
    }
    raum.nachricht(leiter, {'typ': 'weiter'});
  }
  fail('Abschnitt $phase nicht erreicht');
}

/// Gastgeberplatz im Raum (echte lokale Verbindung); schreibt jeden Befehl mit.
class SitzVerbindung extends LokaleVerbindung {
  SitzVerbindung(super.raum, {this.nachher}) : super(id: 'gastgeber', beitreten: false);

  final List<Map<String, Object?>> befehle = [];

  /// Nach jedem Befehl (z. B. die Gäste neu zeichnen).
  final VoidCallback? nachher;

  @override
  Future<void> befehl(Map<String, Object?> c) async {
    befehle.add(c);
    try {
      await super.befehl(c);
    } finally {
      nachher?.call();
    }
  }
}

/// Gastgebergerät mit einem gestarteten Raum mit Sitzen; die Ansicht kommt
/// immer frisch aus dem Raum, Befehle gehen über eine echte lokale Verbindung.
class SitzDienst implements GastgeberDienst {
  SitzDienst(this.raum, {PartyDaten? daten, VoidCallback? nachher})
      : daten = daten ?? akteDaten('schlosskeller'),
        verb = SitzVerbindung(raum, nachher: nachher);

  @override
  final SchlosskellerRaum raum;

  @override
  final SitzVerbindung verb;

  @override
  final Ablage ablage = SpeicherAblage();

  @override
  final PartyDaten daten;

  @override
  String get salz => 'salz-test';

  @override
  String get detektivName => '';

  @override
  Sitz get sitz => raum.sitzVon('gastgeber') ?? Sitz.detektiv;

  @override
  int get minuten => 30;

  @override
  bool get stimme => false;

  @override
  Map<String, Object?> get ansicht => raum.zustandFuer('gastgeber');

  @override
  List<SpielerInfo> get spieler => spielerAusAnsicht(ansicht);

  @override
  List<SpielerInfo> get gaeste => [for (final s in spieler) if (!s.istGastgeber) s];

  @override
  String nameVon(String? id) => [for (final s in spieler) if (s.id == id) s.name].firstOrNull ?? '';

  @override
  String get raumCode => 'ABCDEF';

  @override
  bool get geschlossen => false;

  @override
  bool get verbunden => true;

  @override
  Future<void> schliessen({bool endgueltig = false}) async {}

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Gastgerät an einem echten Raum: Die Ansicht kommt bei jedem Lesen frisch aus
/// dem Raum, Befehle gehen als [spielerId] hinein und melden die Änderung.
class LiveGast extends ChangeNotifier implements GastDienst {
  LiveGast(this.raum, {required this.spielerId, PartyDaten? daten}) : daten = daten ?? akteDaten('schlosskeller');

  final AbendRaum raum;

  @override
  final String spielerId;

  @override
  final PartyDaten? daten;

  /// Alle Befehle in der Reihenfolge, in der sie kamen, und was der Raum sagte (`null`: angenommen).
  final List<(Map<String, Object?>, String?)> befehle = [];

  @override
  Map<String, Object?> get ansicht => raum.zustandFuer(spielerId);

  @override
  VerbindungsStatus get status => VerbindungsStatus.verbunden;

  @override
  String get raumCode => 'ABCDEF';

  @override
  KartenKatalog? get katalog => null;

  @override
  bool get geschlossen => false;

  @override
  Future<String?> befehl(Map<String, Object?> c) async {
    String? fehler;
    try {
      raum.nachricht(spielerId, c);
    } on PartyRaumFehler catch (e) {
      fehler = e.code;
    }
    befehle.add((c, fehler));
    notifyListeners();
    return fehler;
  }

  /// Der Raum hat sich ohne dieses Gerät geändert (ein anderes Gerät): neu zeichnen.
  void geaendert() => notifyListeners();

  @override
  Future<void> trennen() async {}

  @override
  Future<void> verlassen() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Die Gastseite von [g] wie in `GastSeite`, neu gebaut bei jeder Änderung.
Widget gastSeiteLive(LiveGast g) => ListenableBuilder(
      listenable: g,
      builder: (context, _) {
        final inhalt = baueGastSeite(GastKontext(context: context, dienst: g, befehl: (m) async => g.befehl(m), belohnung: null));
        return Scaffold(
          body: MRahmen(
            marke: inhalt.marke,
            titel: inhalt.titel,
            untertitel: inhalt.untertitel,
            aktionen: inhalt.aktionen,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: inhalt.kinder),
          ),
        );
      },
    );

/// Spielt im gestarteten [raum], bis die Spielleitung im Abschnitt [phase] steht.
void spieleBisPhase(SchlosskellerRaum raum, String phase, {String pfad = 'ahmet'}) {
  final erm = Ermittlung(partyDaten.kanon);
  for (var i = 0; i < 3000; i++) {
    if (raum.zustandFuer('gastgeber')['phase'] == phase) return;
    schritt(raum, erm, pfad);
  }
  fail('Abschnitt $phase nicht erreicht');
}

/// Spielt einen ganzen Abend im Raum und merkt sich die Ansicht von [gast] je
/// Abschnitt (Lobby, Rollen, Gespräche, Ermittlung je Zugabschnitt, Gruppenwahl
/// vor und nach der Stimme, Anklage, Finale, Auflösung, Ende).
Map<String, Map<String, Object?>> ansichtenEinesAbends({String gast = 'g1', String pfad = 'ahmet'}) {
  final raum = testRaum(pfad: pfad);
  final ansichten = <String, Map<String, Object?>>{'lobby': raum.zustandFuer(gast)};
  raum.nachricht(gast, {'typ': 'bereit', 'wert': true});
  ansichten['lobby-bereit'] = raum.zustandFuer(gast);
  starte(raum);
  final erm = Ermittlung(partyDaten.kanon);
  for (var i = 0; i < 3000; i++) {
    final phase = raum.zustandFuer('gastgeber')['phase'] as String;
    final g = raum.zustandFuer(gast);
    var schluessel = phase;
    if (phase == 'entscheidungen') {
      final zug = g['zug'];
      schluessel = zug is Map
          ? 'entscheidungen:${zug['phase']}${zug['phase'] == 'wurf' && g['wuerfelPate'] == gast ? '-mein' : ''}'
          : (g['entscheidung'] is Map ? 'entscheidungen:frage' : 'entscheidungen:fertig');
    }
    ansichten.putIfAbsent(schluessel, () => g);
    if (phase == 'ende') return ansichten;
    schritt(raum, erm, pfad, vorWeiter: () => ansichten.putIfAbsent('$phase-danach', () => raum.zustandFuer(gast)));
  }
  fail('Das Ende des Abends wurde nicht erreicht');
}

/// Die App-Hülle der Online-Tests: Thema der Akte, Deutsch, Schriftgröße [schrift],
/// Fenster [groesse] in logischen Pixeln, auf Wunsch „Bewegung reduzieren“.
Future<void> zeigeImThema(
  WidgetTester tester,
  WidgetBuilder seite, {
  Size groesse = const Size(390, 844),
  double schrift = 1,
  bool ruhig = false,
  Widget Function(Widget kind)? huelle,
}) async {
  tester.view.physicalSize = groesse;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildMordakteTheme(),
    locale: const Locale('de'),
    supportedLocales: L.supportedLocales,
    localizationsDelegates: const [
      L.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(schrift), disableAnimations: ruhig),
      child: child!,
    ),
    home: AkteThema(akte: 'schlosskeller', child: Builder(builder: seite)),
  );
  await tester.pumpWidget(huelle == null ? app : huelle(app));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// Die Gastseite für [ansicht] wie in `GastSeite`: Rahmen mit Kopf, Inhalt und Aktionen.
Widget gastSeite(BuildContext context, Map<String, Object?> ansicht, {String spieler = 'g1'}) {
  final inhalt = baueGastSeite(GastKontext(context: context, dienst: TestGast(ansicht, spielerId: spieler), befehl: (_) async {}, belohnung: () {}));
  return Scaffold(
    body: MRahmen(
      marke: inhalt.marke,
      titel: inhalt.titel,
      untertitel: inhalt.untertitel,
      aktionen: inhalt.aktionen,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: inhalt.kinder),
    ),
  );
}

/// Ein Raum in der Lobby: Anna (Gastgeberin, auf [gastgeberSitz]), Ben (`g1`,
/// bereit), Cleo (`g2`, mit [langerName] ein sehr langer Name, noch nicht
/// bereit) und Dora (`g3`, getrennt).
SchlosskellerRaum lobbyRaum({Sitz gastgeberSitz = Sitz.detektiv, PartyDaten? daten, bool langerName = true}) {
  final d = daten ?? partyDaten;
  final raum = SchlosskellerRaum(
    raumCode: 'ABCDEF',
    kanon: d.kanon,
    texte: d.texte,
    fallCode: FallCode.fuerPfad(d.kanon.pfade.first, d.kanon.pfade),
    salz: 'salz-test',
    festerGastgeber: true,
    gastgeberSitz: gastgeberSitz,
  );
  for (final (id, name) in [('gastgeber', 'Anna'), ('g1', 'Ben'), ('g2', langerName ? 'Cleopatra Konstantinopoulou-Wagenknecht' : 'Cleo'), ('g3', 'Dora')]) {
    raum.beitreten(id, name);
  }
  raum.nachricht('gastgeber', {'typ': 'bereit', 'wert': true});
  raum.nachricht('g1', {'typ': 'bereit', 'wert': true});
  raum.verbunden('g3', false);
  return raum;
}

/// Gastgebergerät für die Lobby: Raum offen und verbunden, ein echter Raum in
/// der Lobby ([lobbyRaum]); jeder Befehl geht in den Raum und meldet die
/// Änderung. Kein Relais, kein Start.
class TestLobbyDienst extends ChangeNotifier implements GastgeberDienst {
  TestLobbyDienst(this.raum, {this.verbunden = true, PartyDaten? daten}) : daten = daten ?? partyDaten {
    verb = TestVerbindung(raum, nachher: notifyListeners);
  }

  @override
  final SchlosskellerRaum raum;

  @override
  late final TestVerbindung verb;

  @override
  final bool verbunden;

  @override
  final PartyDaten daten;

  @override
  Map<String, Object?> get ansicht => raum.zustandFuer('gastgeber');

  @override
  List<SpielerInfo> get spieler => spielerAusAnsicht(ansicht);

  @override
  String get akteId => daten.fall;

  @override
  String get raumCode => 'ABCDEF';

  @override
  bool get offen => true;

  @override
  bool get gestartet => !raum.vorStart;

  @override
  bool get geschlossen => false;

  @override
  int get minRollen => daten.texte.besetzung.minRollen;

  @override
  int get maxRollen => daten.texte.besetzung.maxRollen;

  @override
  Sitz get sitz => raum.sitzVon('gastgeber') ?? Sitz.detektiv;

  @override
  List<SpielerInfo> get gaeste => [for (final s in spieler) if (!s.istGastgeber) s];

  @override
  KartenKatalog? get katalog => null;

  @override
  Future<void> oeffnen() async {}

  @override
  Future<void> schliessen({bool endgueltig = true}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Lokale Verbindung des Gastgebers, die jeden Befehl in den Raum gibt und
/// danach [nachher] ruft (z. B. die Änderung melden). Ablehnungen des Raums
/// kommen wie beim Relais als [AbendFehler].
class TestVerbindung implements LokaleVerbindung {
  TestVerbindung(this.raum, {this.nachher});

  @override
  final SchlosskellerRaum raum;

  final VoidCallback? nachher;

  /// Alle Befehle in der Reihenfolge, in der sie kamen.
  final List<Map<String, Object?>> befehle = [];

  @override
  String? get spielerId => 'gastgeber';

  @override
  Stream<Map<String, Object?>> get ansichten => const Stream<Map<String, Object?>>.empty();

  @override
  Map<String, Object?>? get letzteAnsicht => raum.zustandFuer('gastgeber');

  @override
  Future<void> befehl(Map<String, Object?> c) async {
    befehle.add(c);
    try {
      raum.nachricht('gastgeber', c);
    } on PartyRaumFehler catch (e) {
      throw AbendFehler(e.code);
    } finally {
      nachher?.call();
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Gastgebergerät mit einem gestarteten Raum, nur die Teile, die die Sitzung liest.
class TestAbendDienst implements GastgeberDienst {
  TestAbendDienst(this.raum) : verb = TestVerbindung(raum);

  @override
  final SchlosskellerRaum raum;

  @override
  final LokaleVerbindung verb;

  @override
  PartyDaten get daten => partyDaten;

  @override
  String get salz => 'salz-test';

  @override
  String get detektivName => '';

  @override
  Sitz get sitz => Sitz.detektiv;

  @override
  int get minuten => 30;

  @override
  bool get stimme => false;

  @override
  Map<String, Object?> get ansicht => raum.zustandFuer('gastgeber');

  @override
  List<SpielerInfo> get spieler => spielerAusAnsicht(ansicht);

  @override
  List<SpielerInfo> get gaeste => [for (final s in spieler) if (!s.istGastgeber) s];

  @override
  String nameVon(String? id) => [for (final s in spieler) if (s.id == id) s.name].firstOrNull ?? '';

  @override
  String get raumCode => 'ABCDEF';

  @override
  bool get geschlossen => false;

  @override
  bool get verbunden => true;

  @override
  Future<void> schliessen({bool endgueltig = true}) async {}

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
