/// Regressionstests zu den Netz-Befunden ON-1 bis ON-5: Sendezähler des Gastes nach
/// dem Hallo-Reset, beglaubigte Ablehnungen, alte Umschläge beim Wiedereröffnen,
/// Presence ohne Umschläge und die Verbindungsanzeige des Gastgebers.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:mordakte_netz/io.dart';
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:test/test.dart';

import 'relay_hilfe.dart';

const _epoche = 1;

/// Antwort auf ein geöffnetes Gast-Umschlag: die Umschläge, die zurückgehen (leer: schweigen).
typedef Antwort = List<Map<String, Object?>> Function(TestGastgeber g, String cid, Map<String, Object?> nachricht);

/// Ein Gastgeber, den der Test selbst spielt: Er ruft auf jeden Klopf einen Turm aus,
/// öffnet die Umschläge der Gäste und antwortet, wie [antwort] es verlangt.
class TestGastgeber {
  TestGastgeber._(this.schluessel, this._socket, this._antwort);

  static Future<TestGastgeber> starten(PhoenixSocket socket, {required Antwort antwort}) async {
    await socket.verbinde();
    final g = TestGastgeber._(await Schluesselpaar.erzeugen(), socket, antwort);
    g._lobby = socket.kanal(lobbyThema(g.code), presence: false);
    g._lobby.nachrichten.listen((m) {
      if (m.ereignis == 'klopf') unawaited(g._klopf(m.payload));
    });
    await g._lobby.beitreten();
    return g;
  }

  final Schluesselpaar schluessel;
  final PhoenixSocket _socket;
  final Antwort _antwort;
  late final PhoenixKanal _lobby;
  final Map<String, Future<UmschlagPaar>> _paare = {};

  /// Alle geöffneten Gast-Nachrichten in Ankunftsreihenfolge.
  final List<({String cid, Map<String, Object?> nachricht})> empfangen = [];

  String get code => schluessel.raumCode;

  Future<void> schliessen() => _socket.schliessen();

  /// Willkommen und erste Ansicht, so wie der echte Gastgeber sie für einen Gast schickt.
  List<Map<String, Object?>> willkommen(String cid, Object? r) => [
        {'t': 'willkommen', 'spieler': spielerIdVon(cid), 'raum': code, 'epoch': _epoche, 'r': r},
        {'t': 'abend', 'version': 1, 'raum': code, 'privat': {'spieler': spielerIdVon(cid)}},
      ];

  Future<void> _klopf(Map<String, Object?> p) async {
    final cid = p['cid'], pub = unB64(p['pub']);
    if (cid is! String || pub == null) return;
    await (_paare[cid] ??= _sitzOeffnen(cid, pub));
    _lobby.sende('turm', {
      'hpub': b64(schluessel.oeffentlich),
      'epoch': _epoche,
      'proto': protokollVersion,
      'akte': 'schlosskeller',
      'inhalt': '',
      'offen': true,
      'plaetze': 3,
    });
  }

  Future<UmschlagPaar> _sitzOeffnen(String cid, List<int> pub) async {
    final keys = await Sitzungsschluessel.ableiten(eigen: schluessel, fremdOeffentlich: pub, code: code, epoch: _epoche, cid: cid);
    final thema = sitzThema(code, cid);
    final paar = UmschlagPaar(topic: thema, eigeneSeite: 'h', schluessel: keys);
    final sitz = _socket.kanal(thema, presenceKey: hostPresenceKey);
    sitz.nachrichten.listen((m) {
      if (m.ereignis == sitzEreignis) unawaited(_empfange(cid, paar, sitz, m.payload));
    });
    await sitz.beitreten();
    sitz.track({'h': 1});
    return paar;
  }

  Future<void> _empfange(String cid, UmschlagPaar paar, PhoenixKanal sitz, Map<String, Object?> roh) async {
    final u = await paar.oeffnen(roh);
    if (u == null) return;
    empfangen.add((cid: cid, nachricht: u.nachricht));
    for (final antwort in _antwort(this, cid, u.nachricht)) {
      await paar.senden(sitz, antwort);
    }
  }
}

/// Eine lokale Attrappe samt Verbindung, für Tests, die den Gastgeber selbst spielen.
class Netz {
  Netz._(this.attrappe, this.relay, this.socket);

  static Future<Netz> starten() async {
    final attrappe = await PhoenixAttrappe.starten();
    final relay = RelayParameter(url: attrappe.url, schluessel: attrappe.schluessel);
    return Netz._(attrappe, relay, PhoenixSocket(relay.socketUri));
  }

  final PhoenixAttrappe attrappe;
  final RelayParameter relay;
  final PhoenixSocket socket;

  Future<void> schliessen() async {
    await socket.schliessen();
    await attrappe.schliessen();
  }
}

Map<String, Object?> _umschlag(String nutzlast) => (jsonDecode(nutzlast) as Map).cast<String, Object?>();

/// Die Umschläge eines Sitzes, die [seite] (`h` Gastgeber, `c` Gast) gesendet hat, in Absendereihenfolge.
List<Map<String, Object?>> umschlaege(PhoenixAttrappe attrappe, String thema, String seite) => [
      for (final e in attrappe.eintraege)
        if (e.topic == thema && e.ereignis == sitzEreignis && _umschlag(e.nutzlast)['s'] == seite) _umschlag(e.nutzlast),
    ];

int hoechstesN(List<Map<String, Object?>> us) => us.fold(0, (m, u) => max(m, u['n'] as int));

String cidAus(SpeicherAblage ablage, String code) =>
    (jsonDecode(ablage.daten[RelayGast.ablageSchluesselFuer(code)]!) as Map)['cid'] as String;

/// Schlüsselpaar eines Gastes aus seiner Ablage, so wie er es beim Beitritt speichert.
Future<Schluesselpaar> schluesselAus(SpeicherAblage ablage, String code) async {
  final d = (jsonDecode(ablage.daten[RelayGast.ablageSchluesselFuer(code)]!) as Map).cast<String, Object?>();
  return Schluesselpaar.ausGeheimnis(unB64(d['priv'])!);
}

/// Ein roher Gast (kein [RelayGast]): klopft mit leerer Inhaltskennung an, damit die
/// Klopf-Prüfung ihn durchlässt, und schickt dann genau [hallo]. Liefert seine Kennung
/// und die erste Antwort des Gastgebers auf dieses Hallo (erkennbar an seiner Kennung `r`).
/// [nachKlopf] läuft nach dem angenommenen Klopf und vor dem Hallo.
Future<({String cid, Map<String, Object?> antwort})> rohesHallo(
  Abend a,
  Map<String, Object?> hallo, {
  Future<void> Function(Schluesselpaar gast)? nachKlopf,
}) async {
  final g = await Schluesselpaar.erzeugen();
  final code = a.host.raumCode;
  final socket = await a.socket();
  final lobby = socket.kanal(lobbyThema(code), presence: false);
  await lobby.beitreten();
  final vorher = a.host.statistik.klopfAkzeptiert;
  lobby.sende('klopf', {'cid': g.cid, 'pub': b64(g.oeffentlich), 'proto': protokollVersion, 'app': 'roh', 'inhalt': ''});
  await warteBis(() => a.host.statistik.klopfAkzeptiert > vorher);
  await nachKlopf?.call(g);
  final sitz = socket.kanal(sitzThema(code, g.cid), presence: false);
  await sitz.beitreten();
  final keys = await Sitzungsschluessel.ableiten(eigen: g, fremdOeffentlich: a.host.schluessel.oeffentlich, code: code, epoch: a.host.epoch, cid: g.cid);
  final paar = UmschlagPaar(topic: sitzThema(code, g.cid), eigeneSeite: 'c', schluessel: keys);
  final antwort = Completer<Map<String, Object?>>();
  sitz.nachrichten.listen((m) {
    if (m.ereignis != sitzEreignis) return;
    unawaited(paar.oeffnen(m.payload).then((u) {
      // Nur Antworten auf dieses Hallo: Ein Zu ohne Kennung (etwa auf einen fremden Klopf) zählt nicht.
      if (u != null && !antwort.isCompleted && u.nachricht['r'] == hallo['r']) antwort.complete(u.nachricht);
    }));
  });
  await paar.senden(sitz, hallo);
  return (cid: g.cid, antwort: await antwort.future.timeout(const Duration(seconds: 10)));
}

void main() {
  group('ON-1: Sendezähler des Gastes', () {
    test('nach dem Hallo-Reset beginnt der neue Umschlagpaar über dem höchsten gesendeten Zähler', () async {
      final n = await Netz.starten();
      addTearDown(n.schliessen);
      // Die erste Hallo-Runde bleibt unbeantwortet, der Gast setzt sich nach vier Takten zurück.
      String? erste;
      final gastgeber = await TestGastgeber.starten(n.socket, antwort: (g, cid, m) {
        if (m['t'] != 'hallo') return const [];
        erste ??= m['r'] as String;
        if (m['r'] == erste) return const [];
        return g.willkommen(cid, m['r']);
      });
      final gast = await RelayGast.beitreten(
        code: gastgeber.code,
        name: 'Gast',
        ablage: SpeicherAblage(),
        relay: n.relay,
        app: 'test',
        inhalt: '',
        timeout: const Duration(seconds: 10),
        knopfIntervall: const Duration(milliseconds: 50),
      );
      addTearDown(gast.trennen);

      final ns = [for (final u in umschlaege(n.attrappe, sitzThema(gastgeber.code, gast.cid), 'c')) u['n'] as int];
      expect(ns.length, greaterThanOrEqualTo(5), reason: 'Hallos der ersten Runde und das neue Hallo');
      for (var i = 1; i < ns.length; i++) {
        expect(ns[i], greaterThan(ns[i - 1]), reason: 'der Sendezähler fällt nach dem Reset nie unter den bisherigen (Umschlag ${i + 1})');
      }
      expect(gastgeber.empfangen.map((e) => e.nachricht['r']).toSet(), hasLength(2), reason: 'zwei Hallo-Runden: vor und nach dem Reset');
    });
  });

  group('ON-2: beglaubigte Ablehnung', () {
    test('inhalt erreicht den echten Gast als AbendFehler(inhalt), ohne Platz', () async {
      final a = await Abend.starten();
      addTearDown(a.schliessen);
      final ablage = SpeicherAblage();
      await expectLater(
        RelayGast.beitreten(code: a.host.raumCode, name: 'Gast', ablage: ablage, relay: a.relay, app: 'test', inhalt: 'anders', timeout: const Duration(seconds: 10)),
        throwsA(isA<AbendFehler>().having((e) => e.key, 'key', 'inhalt')),
      );
      expect(a.host.raum.spielerIds, isNot(contains(spielerIdVon(cidAus(ablage, a.host.raumCode)))), reason: 'der Gast hat keinen Platz bekommen');
      final ok = await a.gast(0);
      expect(ok.letzteAnsicht, isNotNull, reason: 'Kontrolle: die passende Kennung tritt bei');
    });

    test('voll erreicht den echten Gast als AbendFehler(voll)', () async {
      final a = await Abend.starten(maxSpieler: 3);
      addTearDown(a.schliessen);
      await a.gast(0);
      await a.gast(1);
      await expectLater(
        RelayGast.beitreten(code: a.host.raumCode, name: 'Gast3', ablage: SpeicherAblage(), relay: a.relay, app: 'test', inhalt: 'test', timeout: const Duration(seconds: 10)),
        throwsA(isA<AbendFehler>().having((e) => e.key, 'key', 'voll')),
      );
    });

    test('gestartet erreicht den echten Gast als AbendFehler(gestartet)', () async {
      final a = await Abend.starten();
      addTearDown(a.schliessen);
      for (var i = 0; i < 3; i++) {
        await a.gast(i);
      }
      await a.startet();
      await expectLater(
        RelayGast.beitreten(code: a.host.raumCode, name: 'Spaet', ablage: SpeicherAblage(), relay: a.relay, app: 'test', inhalt: 'test', timeout: const Duration(seconds: 10)),
        throwsA(isA<AbendFehler>().having((e) => e.key, 'key', 'gestartet')),
      );
    });

    test('proto erreicht den Gast als AbendFehler(proto), wenn der Gastgeber beglaubigt ablehnt', () async {
      final n = await Netz.starten();
      addTearDown(n.schliessen);
      final gastgeber = await TestGastgeber.starten(n.socket, antwort: (g, cid, m) => m['t'] == 'hallo' ? [{'t': 'zu', 'grund': 'proto', 'r': m['r']}] : const []);
      await expectLater(
        RelayGast.beitreten(code: gastgeber.code, name: 'Gast', ablage: SpeicherAblage(), relay: n.relay, app: 'test', inhalt: '', timeout: const Duration(seconds: 10)),
        throwsA(isA<AbendFehler>().having((e) => e.key, 'key', 'proto')),
      );
    });

    test('das Hallo prüft die Inhaltskennung: fremd wird mit zu(inhalt, r) beantwortet, passend und ohne Feld treten bei', () async {
      final a = await Abend.starten();
      addTearDown(a.schliessen);
      final fremd = await rohesHallo(a, {'t': 'hallo', 'name': 'Roh', 'proto': protokollVersion, 'app': 'roh', 'r': 'r-fremd', 'inhalt': 'anders'});
      expect(fremd.antwort, {'t': 'zu', 'grund': 'inhalt', 'r': 'r-fremd'});
      expect(a.host.raum.spielerIds, isNot(contains(spielerIdVon(fremd.cid))), reason: 'ein abgewiesener Hallo legt keinen Platz an');

      final passend = await rohesHallo(a, {'t': 'hallo', 'name': 'Roh', 'proto': protokollVersion, 'app': 'roh', 'r': 'r-passend', 'inhalt': 'test'});
      expect(passend.antwort['t'], 'willkommen');
      expect(a.host.gaeste, contains(spielerIdVon(passend.cid)));

      final ohne = await rohesHallo(a, {'t': 'hallo', 'name': 'Alt', 'proto': protokollVersion, 'app': 'roh', 'r': 'r-alt'});
      expect(ohne.antwort['t'], 'willkommen', reason: 'ein Gast ohne Inhaltsfeld wird nicht geprüft');
    });

    test('ein Hallo mit fremder Protokollversion bekommt zu(proto) mit der Kennung des Hallos', () async {
      final a = await Abend.starten();
      addTearDown(a.schliessen);
      final ergebnis = await rohesHallo(a, {'t': 'hallo', 'name': 'Roh', 'proto': 999, 'app': 'roh', 'r': 'r-proto', 'inhalt': 'test'});
      expect(ergebnis.antwort, {'t': 'zu', 'grund': 'proto', 'r': 'r-proto'});
      expect(a.host.raum.spielerIds, isNot(contains(spielerIdVon(ergebnis.cid))));
    });

    test('ein Gerät mit Version 2 (ohne Sitze und Vorleser-Sitz) wird abgewiesen', () async {
      expect(protokollVersion, 3);
      final a = await Abend.starten();
      addTearDown(a.schliessen);
      final ergebnis = await rohesHallo(a, {'t': 'hallo', 'name': 'Alt', 'proto': 2, 'app': 'roh', 'r': 'r-v2', 'inhalt': 'test'});
      expect(ergebnis.antwort, {'t': 'zu', 'grund': 'proto', 'r': 'r-v2'});
      expect(a.host.raum.spielerIds, isNot(contains(spielerIdVon(ergebnis.cid))));
    });

    test('ein gefälschter Klopf eines Dritten nach einem gültigen Klopf wirft den echten Gast nicht hinaus', () async {
      final a = await Abend.starten();
      addTearDown(a.schliessen);
      // Angriffsfolge: Der Gast klopft gültig. Danach klopft ein Dritter mit derselben Kennung
      // und fremdem Protokoll. Erst danach schickt der Gast sein Hallo; es muss ein Willkommen
      // kommen und keine Ablehnung. (Deterministisch: jeder Schritt wartet auf die Zähler.)
      final ergebnis = await rohesHallo(
        a,
        {'t': 'hallo', 'name': 'Gast1', 'proto': protokollVersion, 'app': 'roh', 'r': 'r-echt', 'inhalt': 'test'},
        nachKlopf: (gast) async {
          final dritter = await a.socket();
          final lobby = dritter.kanal(lobbyThema(a.host.raumCode), presence: false);
          await lobby.beitreten();
          final vorher = a.host.statistik.klopfAbgewiesen;
          lobby.sende('klopf', {'cid': gast.cid, 'pub': b64(gast.oeffentlich), 'proto': 'x', 'app': 'fremd', 'inhalt': 'test'});
          await warteBis(() => a.host.statistik.klopfAbgewiesen > vorher);
        },
      );
      expect(ergebnis.antwort, containsPair('t', 'willkommen'), reason: 'der gefälschte Klopf darf das Hallo des Gastes nicht beantworten');
      expect(a.host.gaeste, contains(spielerIdVon(ergebnis.cid)), reason: 'der Gast ist angemeldet');
    });
  });

  group('ON-3: Wiedereröffnen des Sitzes', () {
    test('alte Umschläge werden nach dem Wiedereröffnen verworfen, kein Geisterplatz, der Host-Zähler springt nicht auf 0', () async {
      final a = await Abend.starten(offlineFrist: const Duration(milliseconds: 300));
      addTearDown(a.schliessen);
      final code = a.host.raumCode;
      final ablage = SpeicherAblage();
      final gast = await RelayGast.beitreten(code: code, name: 'Gast', ablage: ablage, relay: a.relay, app: 'test', inhalt: 'test');
      final pid = gast.spielerId!;
      final thema = sitzThema(code, gast.cid);
      await gast.befehl({'typ': 'bereit', 'wert': true});
      final alte = umschlaege(a.attrappe, thema, 'c');
      final hostAlt = hoechstesN(umschlaege(a.attrappe, thema, 'h'));
      expect(alte, hasLength(greaterThanOrEqualTo(2)), reason: 'Hallo und Befehl des Gastes liegen im Mitschnitt');

      await gast.trennen();
      await warteBis(() => !a.host.raum.spielerIds.contains(pid));
      final schluessel = await schluesselAus(ablage, code);

      // Der Gast klopft wieder an (nur öffentliche Daten), der Sitz öffnet sich neu.
      final dritter = await a.socket();
      final lobby = dritter.kanal(lobbyThema(code), presence: false);
      await lobby.beitreten();
      final klopfVorher = a.host.statistik.klopfAkzeptiert;
      lobby.sende('klopf', {'cid': schluessel.cid, 'pub': b64(schluessel.oeffentlich), 'proto': protokollVersion, 'app': 'test', 'inhalt': 'test'});
      await warteBis(() => a.host.statistik.klopfAkzeptiert > klopfVorher);

      // Danach spielt ein Dritter die alten Umschläge auf dem wiedereröffneten Sitz ein.
      final sitz = dritter.kanal(thema, presence: false);
      await sitz.beitreten();
      final verworfenVorher = a.host.statistik.umschlaegeVerworfen;
      final ausgefuehrtVorher = a.host.statistik.befehleAusgefuehrt;
      for (final u in alte) {
        sitz.sende('m', u);
      }
      await warteBis(() => a.host.statistik.umschlaegeVerworfen >= verworfenVorher + alte.length);
      expect(a.host.raum.spielerIds, isNot(contains(pid)), reason: 'kein Geisterplatz durch wiederholte Hallos');
      expect(a.host.statistik.befehleAusgefuehrt, ausgefuehrtVorher, reason: 'der alte Befehl läuft nicht noch einmal');

      // Der Gast kommt legitim zurück; der Sendezähler des Gastgebers setzt dort fort, wo der Sitz stand.
      final vorBeitritt = a.attrappe.eintraege.length;
      final zurueck = await RelayGast.beitreten(code: code, name: 'Gast', ablage: ablage, relay: a.relay, app: 'test', inhalt: 'test');
      addTearDown(zurueck.trennen);
      expect(zurueck.spielerId, pid);
      await warteBis(() => a.host.gaeste.contains(pid));
      final neue = [
        for (final e in a.attrappe.eintraege.skip(vorBeitritt))
          if (e.topic == thema && e.ereignis == sitzEreignis && _umschlag(e.nutzlast)['s'] == 'h') _umschlag(e.nutzlast)['n'] as int,
      ];
      expect(neue, isNotEmpty);
      expect(neue.reduce((x, y) => min(x, y)), greaterThan(hostAlt), reason: 'der Sendezähler des Gastgebers startet beim Wiedereröffnen nicht bei 0');
    });
  });

  group('ON-4: Presence ohne Umschläge', () {
    test('ein verbundener Gast ohne Umschlag gilt nach der Frist als offline, obwohl seine Presence da ist (Wache)', () async {
      final a = await Abend.starten(umschlagFrist: const Duration(milliseconds: 400));
      addTearDown(a.schliessen);
      final gast = await a.gast(0);
      final pid = gast.spielerId!;
      // Kein trennen: Der Gast bleibt verbunden und seine Presence bleibt da. Nur die Wache
      // (Takt umschlagFrist/5) darf ihn nach der Frist ohne Umschlag offline setzen.
      final online = <bool>[];
      final sub = a.hostPlatz.ansichten.listen((v) => online.add(spieler(v, pid)['online'] == true));
      addTearDown(sub.cancel);
      await warteBis(() => online.isNotEmpty);
      expect(online.last, isTrue, reason: 'Kontrolle: der frische Gast ist online');

      await warteBis(() => online.last == false);

      // Gegenprobe: Ein beglaubigter Umschlag des Gastes setzt ihn wieder online.
      await gast.befehl({'typ': 'bereit', 'wert': true});
      await warteBis(() => online.last == true);
    });

    test('Presence eines Dritten ohne frischen Umschlag hält einen Gast nicht online (Frischeprüfung in _praesenz)', () async {
      final a = await Abend.starten(umschlagFrist: const Duration(milliseconds: 400));
      addTearDown(a.schliessen);
      final gast = await a.gast(0);
      final pid = gast.spielerId!;
      expect(spieler(a.hostPlatz.letzteAnsicht!, pid)['online'], isTrue, reason: 'Kontrolle: der frische Gast ist online');

      // Nach der Frist ist der letzte Umschlag des Gastes nicht mehr frisch; danach geht er.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await gast.trennen();
      await warteBis(() => spieler(a.hostPlatz.letzteAnsicht!, pid)['online'] == false);

      // Ein Dritter meldet Presence unter dem Schlüssel des Gastes, ohne Umschlag. Die Wache
      // setzt einen zu Unrecht Online-Gemeldeten sofort zurück, darum zählt jede Ansicht des
      // Gastgebers ab hier, nicht nur der Endstand.
      final online = <bool>[];
      final sub = a.hostPlatz.ansichten.listen((v) => online.add(spieler(v, pid)['online'] == true));
      addTearDown(sub.cancel);
      final dritter = await a.socket();
      final sitz = dritter.kanal(sitzThema(a.host.raumCode, gast.cid), presenceKey: gast.cid);
      await sitz.beitreten();
      sitz.track({'c': 1});
      await Future<void>.delayed(const Duration(milliseconds: 800));
      expect(online, isNotEmpty, reason: 'Kontrolle: der Gastgeber hat Ansichten bekommen');
      expect(online, everyElement(isFalse), reason: 'Presence allein hält den Gast nicht online, auch nicht kurz');

      // Kontrolle: Kehrt der Gast mit einem echten Umschlag zurück, ist er wieder online.
      final zurueck = await RelayGast.beitreten(code: a.host.raumCode, name: 'Gast1', ablage: a.ablagen[0], relay: a.relay, app: 'test', inhalt: 'test');
      addTearDown(zurueck.trennen);
      await warteBis(() => spieler(a.hostPlatz.letzteAnsicht!, pid)['online'] == true);
    });

    test('die Wache ruht bei getrennter Verbindung; nach dem Neuaufbau gilt die Frist von neuem (_verbundenSeit)', () async {
      final a = await Abend.starten(umschlagFrist: const Duration(milliseconds: 400));
      addTearDown(a.schliessen);
      final gast = await a.gast(0);
      final pid = gast.spielerId!;
      final online = <bool>[];
      final sub = a.hostPlatz.ansichten.listen((v) => online.add(spieler(v, pid)['online'] == true));
      addTearDown(sub.cancel);
      // Ein beglaubigter Umschlag kurz vor dem Abbruch: der Gast ist frisch und online.
      await gast.befehl({'typ': 'bereit', 'wert': true});
      expect(online.last, isTrue, reason: 'Kontrolle: der Gast ist online');

      a.host.kappeVerbindung();
      await warteBis(() => !a.host.verbunden);
      final getrennt = online.length;
      // Der Neuaufbau braucht mindestens eine Sekunde; in dieser Zeit ist die Frist (400 ms) längst
      // abgelaufen, ohne Relais kommt aber kein Umschlag an. Die ruhende Wache setzt den Gast nicht offline.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(a.host.verbunden, isFalse, reason: 'Kontrolle: der Gastgeber ist noch getrennt');
      expect(online.skip(getrennt), everyElement(isTrue), reason: 'bei getrennter Verbindung wird niemand offline gesetzt');

      // Nach dem Neuaufbau läuft die Frist ab dem Neuaufbau: der Gast bleibt eine Weile online,
      // obwohl kein Umschlag seit dem Abbruch kam (die letzte Presence ist unbeglaubigt).
      await warteBis(() => a.host.verbunden);
      final nachNeuaufbau = online.length;
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(online.skip(nachNeuaufbau), everyElement(isTrue), reason: 'nach dem Neuaufbau gilt die Frist neu, der Gast geht nicht sofort offline');

      // Danach arbeitet die Wache wieder: Ohne Umschlag geht der Gast nach der Frist offline.
      await warteBis(() => online.last == false);
    });
  });

  group('ON-5: Verbindungsanzeige des Gastgebers', () {
    test('verbunden und verbindung folgen Kappung und Neuaufbau', () async {
      final a = await Abend.starten();
      addTearDown(a.schliessen);
      expect(a.host.verbunden, isTrue, reason: 'nach dem Start steht die Verbindung');
      final werte = <bool>[];
      final sub = a.host.verbindung.listen(werte.add);
      addTearDown(sub.cancel);
      await warteBis(() => werte.isNotEmpty);

      a.host.kappeVerbindung();
      expect(a.host.verbunden, isFalse, reason: 'sofort nach der Kappung');
      await warteBis(() => werte.length >= 2);
      expect(a.host.verbunden, isFalse, reason: 'bis zum Neuaufbau');

      await warteBis(() => a.host.verbunden);
      await warteBis(() => werte.length >= 3);
      expect(werte, [true, false, true], reason: 'nur Wechsel, der erste Wert ist der aktuelle Stand');
    });
  });
}
