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
import 'package:mordakte_netz/mordakte_netz.dart' show LokaleVerbindung, VerbindungsStatus;

import '../party_widgets/hilfe.dart' show partyDaten;

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

/// Gastgebergerät für die Lobby: Raum offen und verbunden, die Plätze [spieler];
/// kein Relais, kein Start.
class TestLobbyDienst implements GastgeberDienst {
  TestLobbyDienst(this.spieler, {this.verbunden = true});

  @override
  final List<SpielerInfo> spieler;

  @override
  final bool verbunden;

  @override
  PartyDaten get daten => partyDaten;

  @override
  String get akteId => 'schlosskeller';

  @override
  String get raumCode => 'ABCDEF';

  @override
  bool get offen => true;

  @override
  bool get gestartet => false;

  @override
  bool get geschlossen => false;

  @override
  int get minRollen => 4;

  @override
  int get maxRollen => 8;

  @override
  Sitz get sitz => Sitz.detektiv;

  @override
  List<SpielerInfo> get gaeste => [for (final s in spieler) if (!s.istGastgeber) s];

  @override
  KartenKatalog? get katalog => null;

  @override
  Future<void> oeffnen() async {}

  @override
  Future<void> schliessen({bool endgueltig = true}) async {}

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Plätze der Lobby: Anna leitet (auf dem Detektiv-Sitz), Ben ist bereit, Cleo (langer Name) noch nicht, Dora ist getrennt.
const lobbyPlaetze = [
  SpielerInfo(id: 'gastgeber', name: 'Anna', online: true, bereit: true, istGastgeber: true, sitz: Sitz.detektiv),
  SpielerInfo(id: 'g1', name: 'Ben', online: true, bereit: true),
  SpielerInfo(id: 'g2', name: 'Cleopatra Konstantinopoulou-Wagenknecht', online: true, bereit: false),
  SpielerInfo(id: 'g3', name: 'Dora', online: false, bereit: false),
];

/// Lokale Verbindung des Gastgebers, die jeden Befehl in den Raum gibt.
class TestVerbindung implements LokaleVerbindung {
  TestVerbindung(this.raum);

  @override
  final SchlosskellerRaum raum;

  @override
  String? get spielerId => 'gastgeber';

  @override
  Stream<Map<String, Object?>> get ansichten => const Stream<Map<String, Object?>>.empty();

  @override
  Map<String, Object?>? get letzteAnsicht => raum.zustandFuer('gastgeber');

  @override
  Future<void> befehl(Map<String, Object?> c) async => raum.nachricht('gastgeber', c);

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
  String get geburtstagskind => '';

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
