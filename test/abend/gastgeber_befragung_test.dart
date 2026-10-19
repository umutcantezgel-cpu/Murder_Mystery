// Befragungen auf dem Gastgebergerät (Modell befragung, A-051): Der Gastgeber
// ist der Detektiv. Er stellt Fragen über `befragen`, markiert Antworten von
// Menschen über `erledigt`, und „Weiter“ wartet, bis die Runde durch ist. Eine
// App-Rolle antwortet nur ihm und erst nach der Frage; die Antwort bleibt im
// Notizbuch. Antworten von Menschen sieht er nie.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/ansicht.dart';
import 'package:mordakte/abend/online/gastgeber_dienst.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/party/bildschirme/runde.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show Ablage, LokaleVerbindung, SpeicherAblage;

import '../party_widgets/hilfe.dart' show partyDaten, rahmen;
import 'online_hilfe.dart';

/// Der Gastgeberplatz im Raum; schreibt jeden Befehl mit.
class _Mitschrift extends LokaleVerbindung {
  _Mitschrift(super.raum) : super(id: 'gastgeber', beitreten: false);

  final List<Map<String, Object?>> befehle = [];

  @override
  Future<void> befehl(Map<String, Object?> c) {
    befehle.add(c);
    return super.befehl(c);
  }
}

/// Gastgebergerät mit einem gestarteten Raum, nur die Teile, die die Sitzung liest.
class _Dienst implements GastgeberDienst {
  _Dienst(this.raum, this.verb, {Ablage? ablage, this.salz = 'salz-test'}) : ablage = ablage ?? SpeicherAblage();

  @override
  final SchlosskellerRaum raum;

  @override
  final _Mitschrift verb;

  @override
  final Ablage ablage;

  @override
  PartyDaten get daten => partyDaten;

  @override
  final String salz;

  @override
  String get geburtstagskind => '';

  @override
  int get minuten => 30;

  @override
  bool get stimme => false;

  @override
  Map<String, Object?> get ansicht => verb.letzteAnsicht ?? const {};

  @override
  List<SpielerInfo> get spieler => spielerAusAnsicht(ansicht);

  @override
  List<SpielerInfo> get gaeste => [for (final s in spieler) if (!s.istGastgeber) s];

  @override
  String nameVon(String? id) => [for (final s in spieler) if (s.id == id) s.name].firstOrNull ?? '';

  @override
  Future<void> schliessen({bool endgueltig = false}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, Object?> _privat(SchlosskellerRaum raum, String id) => (raum.zustandFuer(id)['privat'] as Map).cast<String, Object?>();

/// Ein Raum mit Anna (Gastgeberin, Detektiv), Ben und Cleo, gestartet bis zu den Gesprächen der ersten Runde.
({SchlosskellerRaum raum, _Mitschrift verb, GastgeberSitzung s, Map<String, String> rollen}) _abend() {
  final raum = testRaum();
  starte(raum);
  spieleBisPhase(raum, 'gespraeche');
  final verb = _Mitschrift(raum);
  final s = GastgeberSitzung(_Dienst(raum, verb));
  final rollen = {for (final g in ['g1', 'g2']) _privat(raum, g)['rolle'] as String: g};
  return (raum: raum, verb: verb, s: s, rollen: rollen);
}

Future<void> _warten() => Future<void>.delayed(Duration.zero);

void main() {
  final texte = partyDaten.texte;

  test('Gastgeber: befragen und erledigt gehen an den Raum, Weiter wartet auf die Runde', () async {
    final (:raum, :verb, :s, :rollen) = _abend();
    expect(s.phase, PartyPhase.gespraeche);
    expect(s.befragungsmodell, isTrue);
    final plan = Befragungsplan(texte).fuer(4, 1);
    expect([for (final k in s.befragungen) k.rolle], [...plan.pflicht, ...plan.frei]);
    for (final k in s.befragungen) {
      expect(k.mensch, rollen.containsKey(k.rolle), reason: k.id);
      expect(k.gefragt || k.erledigt, isFalse, reason: k.id);
      expect(k.antwort, isNull, reason: 'Vor der Frage keine Antwort: ${k.id}');
    }
    expect(s.befragungenFrei, plan.freiWahlen);

    // Weiter ist gesperrt: Der Raum lehnt ab, der Abend bleibt in den Gesprächen.
    expect(s.kannWeiter, isFalse);
    expect(s.befragungenFertig, isFalse);
    s.weiter();
    await _warten();
    expect(s.letzterFehler, 'not_ready');
    s.fehlerQuittieren();
    expect(s.phase, PartyPhase.gespraeche);

    // Eine Rolle der App: Die Antwort kommt nur nach der Frage, die Befragung ist damit erledigt.
    final bot = s.befragungen.firstWhere((k) => !k.mensch && k.waehlbar);
    verb.befehle.clear();
    s.befragen(bot.id, 1);
    await _warten();
    expect(verb.befehle, [
      {'typ': 'befragen', 'id': bot.id, 'frage': 1},
    ]);
    expect(s.letzterFehler, isNull);
    final gehoert = s.befragungen.firstWhere((k) => k.id == bot.id);
    expect(gehoert.frage, 1);
    expect(gehoert.erledigt, isTrue);
    expect(gehoert.antwort, befragungsAntwort(texte, plan.text(bot.rolle)));
    expect(s.befragungsNotizen.map((k) => k.id), [bot.id]);

    // Ein Mensch: Der Gastgeber sieht keine Antwort; das Gerät der Person zeigt die Frage.
    final mensch = s.befragungen.firstWhere((k) => k.mensch && k.waehlbar);
    final gast = rollen[mensch.rolle]!;
    verb.befehle.clear();
    s.befragen(mensch.id, 0);
    await _warten();
    final gefragt = s.befragungen.firstWhere((k) => k.id == mensch.id);
    expect(gefragt.frage, 0);
    expect(gefragt.erledigt, isFalse);
    expect(gefragt.antwort, isNull, reason: 'Antworten von Menschen sieht der Gastgeber nie');
    expect((_privat(raum, gast)['befragung'] as Map)['frage'], 0);
    expect(s.kannWeiter, isFalse);
    s.befragungErledigt(mensch.id);
    await _warten();
    expect(verb.befehle, [
      {'typ': 'befragen', 'id': mensch.id, 'frage': 0},
      {'typ': 'erledigt', 'id': mensch.id},
    ]);
    expect(s.befragungen.firstWhere((k) => k.id == mensch.id).erledigt, isTrue);
    expect((_privat(raum, gast)['befragung'] as Map)['erledigt'], isTrue);

    // Der Rest der Runde; dann geht es weiter, und die Antworten der App bleiben im Notizbuch.
    PartySkript.befragungenErledigen(s);
    await _warten();
    expect(s.letzterFehler, isNull);
    expect(s.befragungenFertig, isTrue);
    expect(s.kannWeiter, isTrue);
    final notizen = [for (final k in s.befragungsNotizen) k.id];
    expect(notizen, contains(bot.id));
    expect(notizen, isNot(contains(mensch.id)));
    expect(s.befragungsNotizen.every((k) => !k.mensch && k.antwort != null), isTrue);
    s.weiter();
    await _warten();
    expect(s.phase, PartyPhase.entscheidungen);
    expect(s.befragungen, isEmpty, reason: 'Nach den Gesprächen trägt die Ansicht keine Karten mehr');
    expect([for (final k in s.befragungsNotizen) k.id], notizen);
  });

  test('Rückkehr zum Abend: Das Notizbuch der Befragungen bleibt, aber nur für denselben Abend', () async {
    final raum = testRaum();
    starte(raum);
    spieleBisPhase(raum, 'gespraeche');
    final ablage = SpeicherAblage();
    final s = GastgeberSitzung(_Dienst(raum, _Mitschrift(raum), ablage: ablage));
    await _warten();
    PartySkript.befragungenErledigen(s);
    await _warten();
    final notizen = [for (final k in s.befragungsNotizen) [k.id, k.frage, k.pflicht, k.antwort]];
    expect(notizen, isNotEmpty);
    s.weiter();
    await _warten();
    expect(s.phase, PartyPhase.entscheidungen);
    final abgelegt = jsonDecode(ablage.daten[GastgeberDienst.notizSchluessel]!) as Map;
    expect(abgelegt['salz'], 'salz-test');
    expect(abgelegt.toString(), isNot(contains('antwort')), reason: 'Die Antwort entsteht beim Laden aus den Preisgaben');

    // Die App wird beendet; nach der Rückkehr trägt die Ansicht keine Karten mehr, das Notizbuch kommt aus der Ablage.
    s.dispose();
    final zweite = GastgeberSitzung(_Dienst(raum, _Mitschrift(raum), ablage: ablage));
    expect(zweite.befragungen, isEmpty);
    await _warten();
    expect([for (final k in zweite.befragungsNotizen) [k.id, k.frage, k.pflicht, k.antwort]], notizen);
    // E-044: Was der Erzähler zum Rundenstart für unbesetzte Gäste sprach, trägt die Ansicht nur im
    // laufenden Fenster. Das Notizbuch liest es aus der Partie des Raums, die die Rückkehr neu einspielt.
    expect(jListe(zweite.dienst.ansicht['erzaehler']).where((b) => '$b'.contains(texte.baustein('npc.emine.1'))), isEmpty);
    expect(zweite.erzaehlerNotizen, [for (final k in raum.partieFuerGastgeber!.spiel.bausteine) if (k.startsWith('npc.')) k]);
    expect(zweite.erzaehlerNotizen, containsAll(['npc.emine.1', 'npc.dilara.1', 'npc.enes.1']));
    expect(zweite.erzaehlerNotizen, s.erzaehlerNotizen);
    for (final k in zweite.befragungsNotizen) {
      expect(k.antwort, befragungsAntwort(texte, texte.sammlung.befragungen[k.id]!), reason: k.id);
      expect([k.mensch, k.erledigt], [false, true], reason: k.id);
    }

    // Ein anderer Abend übernimmt nichts; Verwerfen räumt ab.
    final fremd = GastgeberSitzung(_Dienst(raum, _Mitschrift(raum), ablage: ablage, salz: 'anderer-abend'));
    await _warten();
    expect(fremd.befragungsNotizen, isEmpty);
    await GastgeberDienst.verwerfeGespeicherten(ablage);
    expect(ablage.daten.containsKey(GastgeberDienst.notizSchluessel), isFalse);
  });

  test('Gastgeber: eine freie Befragung zählt erst mit der Frage; danach entfallen die übrigen', () async {
    final (raum: _, :verb, :s, rollen: _) = _abend();
    final frei = [for (final k in s.befragungen) if (!k.pflicht) k];
    final wahlen = s.befragungenFrei;
    expect(frei.length, greaterThanOrEqualTo(wahlen));
    for (final k in frei.take(wahlen)) {
      s.befragen(k.id, 0);
      await _warten();
    }
    expect(s.befragungenFrei, 0);
    for (final k in frei.skip(wahlen)) {
      expect(s.befragungen.firstWhere((x) => x.id == k.id).waehlbar, isFalse, reason: k.id);
      verb.befehle.clear();
      s.befragen(k.id, 0);
      await _warten();
      expect(s.letzterFehler, isNotNull, reason: 'Der Raum lehnt eine weitere freie Wahl ab');
      s.fehlerQuittieren();
    }
  });

  testWidgets('Gastgeber: Verlässt ein befragter Gast den Abend vor „Beantwortet“, antwortet die App, Weiter geht', (t) async {
    t.view.physicalSize = const Size(390, 2400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final (:raum, :verb, :s, :rollen) = _abend();
    final mensch = s.befragungen.firstWhere((k) => k.mensch && k.pflicht, orElse: () => s.befragungen.firstWhere((k) => k.mensch && k.waehlbar));
    s.befragen(mensch.id, 0);
    await t.pump();
    raum.verlassen(rollen[mensch.rolle]!);
    verb.aktualisiere();
    await t.pump();
    final k = s.befragungen.firstWhere((x) => x.id == mensch.id);
    expect(k.mensch, isFalse);
    expect(k.erledigt, isTrue, reason: 'Ohne Menschen hat die App die gestellte Frage beantwortet');
    expect(k.antwort, befragungsAntwort(texte, texte.sammlung.befragungen[mensch.id]!));
    await t.pumpWidget(rahmen(ListenableBuilder(listenable: s, builder: (_, _) => RundeBildschirm(sitzung: s))));
    final karte = find.byKey(ValueKey(k.id));
    await t.ensureVisible(karte);
    expect(find.descendant(of: karte, matching: find.text(s.ui('ui.befragung.beantwortet'))), findsNothing);
    for (final a in k.antwort!) {
      expect(find.descendant(of: karte, matching: find.text(a)), findsOneWidget, reason: a);
    }
    PartySkript.befragungenErledigen(s);
    await t.pump();
    expect(s.letzterFehler, isNull);
    expect(s.kannWeiter, isTrue);
    s.weiter();
    await t.pump();
    expect(s.phase, PartyPhase.entscheidungen);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gastgeberbildschirm: Karten ohne Antworten von Menschen, „Beantwortet“, kein Spickzettel', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final (raum: _, verb: _, :s, rollen: _) = _abend();
    await t.pumpWidget(rahmen(ListenableBuilder(listenable: s, builder: (_, _) => RundeBildschirm(sitzung: s))));
    expect(find.text(s.ui('ui.befragung.titel')), findsOneWidget);
    expect(find.text(s.ui('ui.befragung.spickzettel')), findsNothing, reason: 'Online hat jede Person ihr eigenes Gerät');
    final mensch = s.befragungen.firstWhere((k) => k.mensch && k.pflicht, orElse: () => s.befragungen.firstWhere((k) => k.mensch));
    if (!mensch.pflicht) {
      final zeile = find.byKey(ValueKey('wahl-${mensch.id}'));
      await t.ensureVisible(zeile);
      await t.tap(zeile);
      await t.pump();
    }
    final frage = find.descendant(of: find.byKey(ValueKey(mensch.id)), matching: find.text(mensch.fragen.first));
    await t.ensureVisible(frage);
    await t.tap(frage);
    await t.pump();
    // Online geht das Gerät nicht herum: kein Hinweis „Gib das Gerät …“, sondern der Knopf „Beantwortet“.
    expect(find.text(s.ui('ui.befragung.geraet', {'name': s.spielerName(mensch.rolle)})), findsNothing);
    final zettel = befragungsZettel(partyDaten.texte, partyDaten.texte.sammlung.befragungen[mensch.id]!);
    for (final z in [...zettel.sagen, ...zettel.eigene, ...zettel.behaupten]) {
      expect(find.text(z), findsNothing, reason: z);
    }
    final beantwortet = find.descendant(of: find.byKey(ValueKey(mensch.id)), matching: find.text(s.ui('ui.befragung.beantwortet')));
    expect(beantwortet, findsOneWidget);
    // Die Browserprobe tippt den Knopf über seine Semantik-Kennung.
    final semantik = t.ensureSemantics();
    await t.ensureVisible(beantwortet);
    await t.pump();
    expect(find.bySemanticsIdentifier('befragung-beantwortet-${mensch.id}'), findsOneWidget);
    semantik.dispose();
    await t.ensureVisible(beantwortet);
    await t.tap(beantwortet);
    await t.pump();
    expect(s.befragungVon(mensch.rolle)!.erledigt, isTrue);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
  });
}
