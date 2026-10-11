import 'package:mordakte_netz/io.dart';
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:test/test.dart';

late PhoenixAttrappe attrappe;
final List<PhoenixSocket> _sockets = [];

/// Ein Socket zur Attrappe; wird nach dem Test wieder geschlossen.
Future<PhoenixSocket> verbinde({
  Duration herz = const Duration(seconds: 20),
  List<Duration> backoff = standardBackoff,
  double jitter = 0.25,
}) async {
  final s = PhoenixSocket(
    relaySocketUri(url: attrappe.url, schluessel: attrappe.schluessel),
    heartbeatIntervall: herz,
    backoff: backoff,
    jitter: jitter,
  );
  _sockets.add(s);
  await s.verbinde();
  return s;
}

Future<void> warteBis(bool Function() bedingung) async {
  final ende = DateTime.now().add(const Duration(seconds: 15));
  while (!bedingung()) {
    if (DateTime.now().isAfter(ende)) fail('Zeitüberschreitung');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  setUp(() async {
    attrappe = await PhoenixAttrappe.starten();
  });

  tearDown(() async {
    for (final s in _sockets) {
      await s.schliessen();
    }
    _sockets.clear();
    await attrappe.schliessen();
  });

  group('Beitritt und Broadcast', () {
    test('Beitritt wird mit ok bestätigt', () async {
      final s = await verbinde();
      expect(s.offen, isTrue);
      final k = s.kanal('mordakte:v1:TEST01', presence: false);
      await k.beitreten();
      expect(k.beigetreten, isTrue);
      expect(k.aktuellerStatus, KanalStatus.beigetreten);
      expect(attrappe.abonnenten, {'mordakte:v1:TEST01': 1});
    });

    test('Broadcast mit self:false erreicht nur die anderen Teilnehmer', () async {
      const t = 'mordakte:v1:TEST02';
      final a = await verbinde();
      final b = await verbinde();
      final c = await verbinde();
      final ka = a.kanal(t, presence: false);
      final kb = b.kanal(t, presence: false);
      final kc = c.kanal(t, presence: false);
      await ka.beitreten();
      await kb.beitreten();
      await kc.beitreten();
      final alsA = <String>[], alsB = <String>[], alsC = <String>[];
      ka.nachrichten.listen((m) => alsA.add('${m.ereignis}/${m.payload['n']}'));
      kb.nachrichten.listen((m) => alsB.add('${m.ereignis}/${m.payload['n']}'));
      kc.nachrichten.listen((m) => alsC.add('${m.ereignis}/${m.payload['n']}'));

      expect(ka.sende('hallo', {'n': 1}), isTrue);
      await warteBis(() => alsB.contains('hallo/1') && alsC.contains('hallo/1'));
      // Ein Nachtrag von B: Kommt er bei A an, ist alles davor (also auch hallo) dort verarbeitet.
      kb.sende('ende', {'n': 2});
      await warteBis(() => alsA.contains('ende/2'));
      expect(alsA, ['ende/2'], reason: 'der Absender bekommt sein eigenes Ereignis nicht');
      expect(alsB, ['hallo/1'], reason: 'self:false am Absender');
      expect(alsC, ['hallo/1', 'ende/2']);
    });

    test('Mit self:true bekommt der Absender sein eigenes Ereignis', () async {
      const t = 'mordakte:v1:TEST03';
      final s = await verbinde();
      final k = s.kanal(t, presence: false, self: true);
      await k.beitreten();
      final alle = <String>[];
      k.nachrichten.listen((m) => alle.add('${m.ereignis}/${m.payload['n']}'));
      k.sende('selbst', {'n': 3});
      await warteBis(() => alle.contains('selbst/3'));
    });
  });

  group('Presence', () {
    test('Stand beim Beitritt, Diffs bei Track und Abgang', () async {
      const t = 'mordakte:v1:TEST04';
      final a = await verbinde();
      final ka = a.kanal(t, presenceKey: 'a');
      await ka.beitreten();
      final verlauf = <Set<String>>[];
      ka.praesenz.listen(verlauf.add);
      ka.track({'name': 'Anna'});
      await warteBis(() => ka.praesenzSchluessel.contains('a'));

      final b = await verbinde();
      final kb = b.kanal(t, presenceKey: 'b');
      await kb.beitreten();
      await warteBis(() => kb.praesenzSchluessel.contains('a'));
      expect(kb.praesenzSchluessel, {'a'}, reason: 'presence_state beim Beitritt');
      kb.track({'name': 'Ben'});
      await warteBis(() => ka.praesenzSchluessel.containsAll({'a', 'b'}));

      await kb.verlassen();
      await warteBis(() => ka.praesenzSchluessel.length == 1);
      expect(ka.praesenzSchluessel, {'a'});
      expect(verlauf, containsAllInOrder([<String>{'a'}, <String>{'a', 'b'}, <String>{'a'}]));
    });
  });

  group('Wiederverbindung und Heartbeat', () {
    test('Nach einem Netzabbruch: Neuaufbau, erneuter Beitritt, Anwesenheit wird neu gemeldet', () async {
      const t = 'mordakte:v1:TEST05';
      final a = await verbinde(backoff: [const Duration(milliseconds: 40)], jitter: 0);
      final ka = a.kanal(t, presenceKey: 'a');
      await ka.beitreten();
      ka.track({'name': 'Anna'});
      await warteBis(() => attrappe.verbindungen.any((v) => v.themen[t] == 'a'));
      final zustaende = <SocketStatus>[];
      a.status.listen(zustaende.add);
      final vorher = a.zaehler.wiederverbunden;

      await attrappe.trenneAlle();
      await warteBis(() => a.zaehler.wiederverbunden > vorher && ka.beigetreten);
      expect(zustaende, containsAllInOrder([SocketStatus.getrennt, SocketStatus.offen]));

      // Ein frischer Beobachter sieht den Schlüssel nur, wenn die Anwesenheit wieder gemeldet wurde.
      final b = await verbinde();
      final kb = b.kanal(t, presenceKey: 'beobachter');
      await kb.beitreten();
      await warteBis(() => kb.praesenzSchluessel.contains('a'));
    });

    test('Heartbeat wird beantwortet: die Verbindung bleibt stehen', () async {
      final a = await verbinde(herz: const Duration(milliseconds: 200));
      final vorher = a.zaehler.empfangen;
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(a.offen, isTrue);
      expect(a.zaehler.wiederverbunden, 0);
      expect(attrappe.verbindungenInsgesamt, 1, reason: 'keine zweite Verbindung');
      expect(a.zaehler.empfangen - vorher, greaterThanOrEqualTo(3), reason: 'Antworten auf die Heartbeats');
    });

    test('Ein unbeantworteter Heartbeat gilt als tote Verbindung und löst einen Neuaufbau aus', () async {
      attrappe.heartbeatBeantworten = false;
      final a = await verbinde(herz: const Duration(milliseconds: 200), backoff: [const Duration(milliseconds: 40)], jitter: 0);
      await warteBis(() => a.zaehler.wiederverbunden >= 1);
      attrappe.heartbeatBeantworten = true;
      await warteBis(() => a.offen);
    });
  });
}
