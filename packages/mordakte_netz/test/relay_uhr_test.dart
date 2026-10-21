// M4: Gemeinsame Rundenuhr und Diashow über das Relais. Die Abendzeit stempelt
// der Gastgeber beim Annehmen jedes Befehls (auch des eigenen Platzes); was ein
// Gast als `zeit` mitschickt, gilt nie. Gäste kennen den Versatz zur Uhr des
// Gastgebers aus dem `pong` (Feld `ht`) und rechnen die Restzeit selbst.
import 'package:mordakte_core/mordakte_core.dart' show Abendfassung;
import 'package:mordakte_core/runden.dart' show ProtokollRaum, RundenUhr;
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:test/test.dart';

import 'relay_hilfe.dart';

Matcher _fehler(String key) => throwsA(isA<AbendFehler>().having((e) => e.key, 'key', key));

void main() {
  test('Uhr und Bilder: Zeit vom Gastgeber, Versatz aus dem pong, Rechte wie im Raum', () async {
    // Die Uhr des Gastgebers geht eine Stunde nach: Ohne Versatz wäre die Zeit eines Gastes längst um.
    const nach = Duration(hours: 1);
    int gastgeberUhr() => DateTime.now().subtract(nach).millisecondsSinceEpoch;
    final a = await Abend.starten(abendzeit: gastgeberUhr);
    addTearDown(a.schliessen);
    for (var i = 0; i < 3; i++) {
      await a.gast(i);
    }
    final erzaehler = a.gaeste[0], rolle = a.gaeste[1];
    // Gleich nach dem Willkommen gleicht jeder Gast die Uhr ab, nicht erst mit dem nächsten Takt.
    await warteBis(() => a.gaeste.every((g) => g.versatz != null));
    for (final g in a.gaeste) {
      expect((g.versatz! + nach.inMilliseconds).abs(), lessThan(2000), reason: '${g.spielerId}: Versatz ${g.versatz}');
      expect((g.gastgeberZeit - gastgeberUhr()).abs(), lessThan(2000));
    }

    await a.hostPlatz.befehl({'typ': 'sitz', 'spieler': erzaehler.spielerId, 'sitz': 'erzaehler'});
    await a.startet();
    for (final g in a.gaeste) {
      await g.befehl({'typ': 'rollenGelesen'}).catchError((Object _) {});
    }
    await erzaehler.befehl({'typ': 'weiter'});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && g.letzteAnsicht!['phase'] == 'intro'));

    // Diashow: Den Zähler sehen alle, schalten darf nur, wer leitet (der Erzähler).
    expect({for (final g in a.gaeste) g.letzteAnsicht!['dia']}, {0});
    await expectLater(rolle.befehl({'typ': 'dia', 'nr': 2}), _fehler('not_host'));
    await expectLater(a.hostPlatz.befehl({'typ': 'dia', 'nr': 2}), _fehler('not_host'));
    await expectLater(erzaehler.befehl({'typ': 'dia', 'nr': 9}), _fehler('invalid'));
    await erzaehler.befehl({'typ': 'dia', 'nr': 2});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && g.letzteAnsicht!['dia'] == 2));
    expect(a.hostPlatz.letzteAnsicht!['dia'], 2);

    await erzaehler.befehl({'typ': 'weiter'});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && g.letzteAnsicht!['phase'] == 'gespraeche'));
    expect(a.gaeste.every((g) => !g.letzteAnsicht!.containsKey('dia')), isTrue);

    // Die Uhr: Der Erzähler schickt eine gefälschte Zeit mit; es gilt die des Gastgebers.
    final vorher = gastgeberUhr();
    await erzaehler.befehl({'typ': 'uhr', 'aktion': 'start', 'zeit': 5});
    final nachher = gastgeberUhr();
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && RundenUhr.ausJson(g.letzteAnsicht!['uhr'])?.laeuft == true));
    final uhr = RundenUhr.ausJson(rolle.letzteAnsicht!['uhr'])!;
    expect(uhr.start, inInclusiveRange(vorher, nachher));
    for (final g in a.gaeste) {
      // Mit dem Versatz rechnet jeder Gast fast die volle Dauer; mit der eigenen Uhr wäre sie um.
      expect(uhr.rest(g.gastgeberZeit), greaterThan(uhr.dauer - 5000), reason: '${g.spielerId}');
      expect(uhr.rest(DateTime.now().millisecondsSinceEpoch), 0, reason: 'Gegenprobe ohne Versatz');
    }
    await expectLater(rolle.befehl({'typ': 'uhr', 'aktion': 'pause'}), _fehler('not_host'));
    await expectLater(a.hostPlatz.befehl({'typ': 'uhr', 'aktion': 'pause'}), _fehler('not_host'));
    await erzaehler.befehl({'typ': 'uhr', 'aktion': 'plus', 'minuten': 5});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && RundenUhr.ausJson(g.letzteAnsicht!['uhr'])?.dauer == uhr.dauer + 5 * RundenUhr.minute));

    // Im Protokoll stehen die Zeiten des Gastgebers; die Wiederherstellung braucht sonst nichts.
    final log = (a.host.raum as ProtokollRaum).protokoll.where((e) => e[0] == 'nachricht').map((e) => e[2] as Map).toList();
    expect(log.every((m) => m['zeit'] is int), isTrue, reason: 'Jeder Befehl trägt die Abendzeit des Transports');
    expect(log.where((m) => m['typ'] == 'uhr').map((m) => m['zeit']), everyElement(greaterThanOrEqualTo(vorher)));
  });

  test('Langer Abend über das Relais: alle sehen die Fassung, die Uhr läuft in den Entscheidungen weiter, stellen darf nur, wer leitet', () async {
    final a = await Abend.starten(fassung: Abendfassung.lang);
    addTearDown(a.schliessen);
    for (var i = 0; i < 3; i++) {
      await a.gast(i);
    }
    final erzaehler = a.gaeste[0], rolle = a.gaeste[1];
    await a.hostPlatz.befehl({'typ': 'sitz', 'spieler': erzaehler.spielerId, 'sitz': 'erzaehler'});
    await a.startet();
    expect({for (final g in a.gaeste) g.letzteAnsicht!['fassung']}, {'lang'});
    for (final g in a.gaeste) {
      await g.befehl({'typ': 'rollenGelesen'}).catchError((Object _) {});
    }
    await erzaehler.befehl({'typ': 'weiter'});
    await erzaehler.befehl({'typ': 'weiter'});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && g.letzteAnsicht!['phase'] == 'gespraeche'));
    await erzaehler.befehl({'typ': 'uhr', 'aktion': 'start'});
    // Der Gastgeber führt den Detektiv: feste Befragungen und so viele freie, wie erlaubt.
    final karten = privat(a.hostPlatz.letzteAnsicht!);
    var frei = karten['befragungenFrei'] as int;
    for (final k in [for (final x in karten['befragungen'] as List) (x as Map).cast<String, Object?>()]) {
      if (k['pflicht'] != true) {
        if (frei <= 0) continue;
        frei--;
      }
      await a.hostPlatz.befehl({'typ': 'befragen', 'id': k['id'], 'frage': 0});
      if (k['mensch'] == true) await a.hostPlatz.befehl({'typ': 'erledigt', 'id': k['id']});
    }
    await erzaehler.befehl({'typ': 'weiter'});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && g.letzteAnsicht!['phase'] == 'entscheidungen'));
    final uhren = {for (final g in a.gaeste) g.letzteAnsicht!['uhr'].toString()};
    expect(uhren, hasLength(1));
    expect(RundenUhr.ausJson(rolle.letzteAnsicht!['uhr'])!.laeuft, isTrue, reason: 'Dieselbe Uhr wie in den Gesprächen');
    await expectLater(rolle.befehl({'typ': 'uhr', 'aktion': 'pause'}), _fehler('not_host'));
    await erzaehler.befehl({'typ': 'uhr', 'aktion': 'pause'});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && RundenUhr.ausJson(g.letzteAnsicht!['uhr'])?.pausiert == true));
    expect(a.host.meta['fassung'], 'lang');
  });
}
