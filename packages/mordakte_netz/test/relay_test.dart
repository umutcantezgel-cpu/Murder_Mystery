import 'dart:async';
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart' show Besetzung;
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:test/test.dart';

import 'relay_hilfe.dart';

late Abend a;

void main() {
  setUp(() async {
    a = await Abend.starten();
  });

  tearDown(() => a.schliessen());

  test('jeder Platz bekommt Ansichten; alle Spieler erscheinen', () async {
    for (var i = 0; i < 3; i++) {
      await a.gast(i);
    }
    for (final g in a.gaeste) {
      expect(g.turm?.epoch, 1, reason: 'Turm des Gastgebers übernommen');
      expect(g.letzteAnsicht!['raum'], a.host.raumCode);
      expect(privat(g.letzteAnsicht!)['spieler'], g.spielerId);
      expect(privat(g.letzteAnsicht!)['dossier'], isNull, reason: 'vor dem Start kein Dossier');
    }
    await warteBis(() => a.gaeste.every((g) => (g.letzteAnsicht!['spieler'] as List).length == 4));
    expect(a.hostPlatz.letzteAnsicht, isNotNull);
  });

  test('nach dem Start sieht jeder Gast nur sein eigenes Dossier', () async {
    for (var i = 0; i < 3; i++) {
      await a.gast(i);
    }
    await a.startet();
    final dossiers = {for (final r in Besetzung(a.kanon).besetzt(rollen)) r: a.dossier(r)};
    final rollenDerGaeste = <String>{};
    for (final g in a.gaeste) {
      final p = privat(g.letzteAnsicht!);
      final rolle = p['rolle'] as String;
      rollenDerGaeste.add(rolle);
      expect(p['spieler'], g.spielerId);
      expect(jsonEncode(p['dossier']), jsonEncode(dossiers[rolle]), reason: 'eigenes Dossier von ${g.spielerId}');
      final eigene = texteIn(dossiers[rolle]);
      final fremde = {for (final e in dossiers.entries) if (e.key != rolle) ...texteIn(e.value)}..removeAll(eigene);
      final text = jsonEncode(p);
      // Kontrollen: Der Vergleich hat Texte, und der eigene Text ist im Klartext sichtbar.
      expect(fremde.where((t) => t.length >= 24), isNotEmpty);
      expect(text.contains(roh(eigene.firstWhere((t) => t.length >= 24))), isTrue);
      for (final t in fremde.where((t) => t.length >= 24)) {
        expect(text.contains(roh(t)), isFalse, reason: 'fremder Dossiertext im privaten Teil von ${g.spielerId}');
      }
    }
    expect(rollenDerGaeste, hasLength(3), reason: 'drei verschiedene Rollen');
    expect(privat(a.hostPlatz.letzteAnsicht!)['dossier'], isNull, reason: 'der Gastgeber hat kein Dossier');
    expect(privat(a.hostPlatz.letzteAnsicht!)['detektiv'], isTrue, reason: 'der Gastgeber führt den Abend');
  });

  test('ein Mithörer im Relais sieht nie Dossier-Klartext', () async {
    for (var i = 0; i < 3; i++) {
      await a.gast(i);
    }
    final mit = StringBuffer();
    final lausch = await a.socket();
    final lobby = lausch.kanal(lobbyThema(a.host.raumCode), presence: false);
    lobby.nachrichten.listen((m) => mit.writeln('L ${m.ereignis} ${jsonEncode(m.payload)}'));
    await lobby.beitreten();
    for (final g in a.gaeste) {
      final k = lausch.kanal(sitzThema(a.host.raumCode, g.cid), presence: false);
      k.nachrichten.listen((m) => mit.writeln('S ${m.ereignis} ${jsonEncode(m.payload)}'));
      await k.beitreten();
    }
    await a.startet();
    await warteBis(() => a.gaeste.every(a.aktuell));

    final text = mit.toString();
    expect(RegExp(r'^S m ', multiLine: true).allMatches(text).length, greaterThanOrEqualTo(6), reason: 'der Mithörer sah den Verkehr');
    final dossierTexte = [for (final r in Besetzung(a.kanon).besetzt(rollen)) ...texteIn(a.dossier(r))].where((t) => t.length >= 12).toList();
    // Kontrolle: Der Gast sieht seinen Dossiertext, der Mithörer nicht.
    expect(dossierTexte.any((t) => jsonEncode(a.gaeste[0].letzteAnsicht).contains(roh(t))), isTrue);
    for (final t in dossierTexte) {
      expect(text.contains(roh(t)), isFalse, reason: 'Dossier-Klartext im Mitschnitt');
    }
    for (final verboten in ['"dossier"', '"privat"', '"weiss"', '"aufloesung"', '"hatGestimmt"', salz, 'Gast1', 'Gastgeber']) {
      expect(text.contains(verboten), isFalse, reason: 'Klartext "$verboten" im Mitschnitt');
    }
    for (final z in text.split('\n').where((z) => z.startsWith('L '))) {
      expect(z.startsWith('L klopf ') || z.startsWith('L turm '), isTrue, reason: 'unerwartetes Lobby-Ereignis');
    }
  });

  test('ein gefälschter Turm mit fremdem Schlüssel wird von den Gästen verworfen', () async {
    final fremd = await Schluesselpaar.erzeugen();
    final st = await a.socket();
    final lobby = st.kanal(lobbyThema(a.host.raumCode), presence: false);
    await lobby.beitreten();
    final spam = Timer.periodic(const Duration(milliseconds: 30), (_) {
      lobby.sende('turm', {
        'hpub': b64(fremd.oeffentlich),
        'epoch': 99,
        'proto': protokollVersion,
        'akte': 'schlosskeller',
        'inhalt': 'test',
        'offen': true,
        'plaetze': 9,
      });
    });
    for (var i = 0; i < 3; i++) {
      await a.gast(i);
    }
    spam.cancel();
    for (final g in a.gaeste) {
      expect(g.verworfen, greaterThan(0), reason: 'der Gast hat den gefälschten Turm gehört und verworfen');
      expect(g.turm?.epoch, 1, reason: 'Epoche 99 des Fälschers wurde nicht übernommen');
    }
    await a.startet();
    expect(privat(a.gaeste[0].letzteAnsicht!)['rolle'], isNotNull, reason: 'die Sitzung läuft mit dem echten Gastgeber');
  });

  test('ein Gast mit derselben Ablage kehrt mit gleicher Spieler-ID und Rolle zurück', () async {
    for (var i = 0; i < 3; i++) {
      await a.gast(i);
    }
    await a.startet();
    final alt = a.gaeste[0];
    final id = alt.spielerId!;
    final vorher = privat(alt.letzteAnsicht!);
    await alt.trennen();
    await warteBis(() => spieler(a.hostPlatz.letzteAnsicht!, id)['online'] == false);

    final neu = await RelayGast.beitreten(code: a.host.raumCode, name: 'Gast1', ablage: a.ablagen[0], relay: a.relay, app: 'test', inhalt: 'test');
    a.gaeste[0] = neu;
    expect(neu.spielerId, id, reason: 'gleicher Schlüssel, gleiche Spieler-ID');
    await warteBis(() => a.aktuell(neu));
    final nachher = privat(neu.letzteAnsicht!);
    expect(nachher['rolle'], vorher['rolle']);
    expect(jsonEncode(nachher['dossier']), jsonEncode(vorher['dossier']));
    await warteBis(() => spieler(a.hostPlatz.letzteAnsicht!, id)['online'] == true);
    await expectLater(
      neu.befehl({'typ': 'bereit', 'wert': true}),
      throwsA(isA<AbendFehler>().having((e) => e.key, 'key', 'game_running')),
    );
  });

  test('ein Befehl, der nach Verlust erneut gesendet wird, wird genau einmal ausgeführt', () async {
    final g = await a.gast(0, befehlWiederholung: const Duration(milliseconds: 300));
    final host = a.host;
    final vorAus = host.statistik.befehleAusgefuehrt;
    final vorWdh = host.statistik.befehleWiederholt;
    // Jede Zustellung braucht 350 ms, die Antwort kommt also erst nach der ersten
    // Wiederholung (300 ms) an: Der Gastgeber sieht dieselbe Nummer q zweimal.
    a.attrappe.stoerung.verzoegerungMin = const Duration(milliseconds: 350);
    a.attrappe.stoerung.verzoegerungMax = const Duration(milliseconds: 350);
    await g.befehl({'typ': 'bereit', 'wert': true});
    a.attrappe.stoerung.verzoegerungMin = Duration.zero;
    a.attrappe.stoerung.verzoegerungMax = Duration.zero;
    await warteBis(() => host.statistik.befehleWiederholt > vorWdh);
    expect(host.statistik.befehleAusgefuehrt - vorAus, 1, reason: 'genau eine Ausführung');
    expect(spieler(a.hostPlatz.letzteAnsicht!, g.spielerId!)['bereit'], isTrue);
  });
}
