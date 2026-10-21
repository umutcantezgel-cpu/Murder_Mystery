/// Relais-Matrix: ein vollständiger Schlosskeller-Abend über das Relais
/// (Supabase Realtime oder lokale Attrappe). Das Gastgebergerät hält den
/// autoritativen Raum (`SchlosskellerRaum` in `ProtokollRaum`), jeder Gast
/// hängt mit eigenem Socket und eigenem Schlüssel daran.
///
/// Geprüft wird: jeder Gast bekommt nur sein eigenes Dossier, vor dem Finale
/// kein Salz/Fall-Code/keine Auflösung, ein Mithörer in allen Themen sieht nie
/// Klartext der Dossiers (und kann nichts wiedereinspielen oder fälschen), ein
/// Gast behält nach dem Neuverbinden seine Rolle, Befehle laufen trotz
/// Nachrichtenverlust genau einmal, falsche Türme werden verworfen.
///
/// Lokal gegen die Attrappe:
///   dart run tool/relay_matrix.dart --lokal --clients=4,8
/// Live gegen Supabase (öffentlicher Schlüssel ist Standard):
///   dart run tool/relay_matrix.dart --clients=4 [--url=https://<ref>.supabase.co] [--key=…]
///
/// Weitere Optionen: `--diagnose` (Zeitstempel, Lastspitzen, Anlass von Fehlern,
/// auch Dossiertexte), `--erzwinge` (die Attrappe verwirft Zustellungen über 100/s
/// wirklich). Hinter einem Proxy (HTTPS_PROXY) laufen die Sockets über
/// `findProxyFromEnvironment`. Der Lauf endet mit Exitcode 0 nur bei Erfolg.
///
/// Neben den Privatheitsprüfungen laufen mitten im Abend: Netzabbruch eines Gastes
/// (nur lokal, die Attrappe kappt), App-Neustart eines Gastes mit gespeichertem
/// Schlüssel, Netzabbruch beim Gastgeber, Absturz und Wiederherstellung des Gastgebers
/// aus der Ablage (neue Epoche), Nachrichtenverlust und -verzögerung (nur lokal).
///
/// Gäste: Das Gastgebergerät spielt zusätzlich auf seinem lokalen Platz.
///
/// Sitze (M3): Jede Laststufe läuft in drei Konstellationen (Host = Erzähler +
/// Gast = Detektiv, Host = Detektiv ohne Erzähler, Host = Detektiv + Gast =
/// Erzähler). Der Sitz des Gastgebers kommt wie in der App aus der Meta `sitz`
/// (auch nach der Wiederherstellung). Geprüft wird zusätzlich: Erzähltext nur
/// beim Vorleser, Erzählerpaket nur beim Erzähler und nie mit verbirgt,
/// Tatwissen oder Tarnung, npc-Notizen beim Detektiv, Klasse beim Detektiv und
/// beim Gastgeber, Rechte je Sitz. Zuletzt fällt ein Gast-Detektiv aus, und der
/// Gastgeber vergibt seinen Sitz neu (auch über einen Neustart des Gastgebers).
///
/// Rundenuhr und Diashow (M4): Die Abendzeit jedes Befehls stempelt der
/// Gastgeber (eine mitgeschickte Zeit gilt nicht), alle sehen dieselbe Uhr und
/// rechnen die Restzeit mit dem Versatz aus dem `pong`; den Bilderzähler der
/// Einleitung sehen alle gleich. Beides stellt nur, wer leitet.
///
/// Fassung (M7b): Ein weiterer Lauf je Laststufe spielt den langen Abend (Meta
/// `fassung: lang` wie in der App, auch nach dem Neustart des Gastgebers). Dort
/// läuft die Uhr der Gespräche in den Entscheidungen weiter, für alle gleich,
/// und wer leitet, stellt sie dort; jede Ansicht trägt `fassung: lang`, sonst
/// nichts Neues. Im kurzen Abend fehlen Uhr (`invalid_phase`) und Schlüssel in
/// den Entscheidungen wie bisher. Dazu der Streifzug (Erkundung, Treffpunkte):
/// nur vom Detektiv-Sitz, alle sehen dasselbe Treffen, die Treffpunkte aller
/// nur der Detektiv; kurz ist `erkunde` ungültig und der Schlüssel fehlt. Lang
/// laufen auch Vorspiel und Morgen (M7b): Alle sehen dieselbe Station, den
/// Vorlesetext nur der Vorleser, weiter schaltet nur, wer leitet (auch über den
/// Neustart des Gastgebers).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/io.dart';
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:mordakte_server/party.dart' show ladeErkundung, ladeVorspielMorgen, resolvePartyDir;

String _stage = 'Vorbereitung';

/// `--diagnose`: Fehlermeldungen dürfen den Anlass nennen (Dossiertext, Feld). Sonst nie.
bool _diagnose = false;

/// `--erzwinge`: Die Attrappe verwirft Zustellungen über der Free-Plan-Grenze (100/s) wirklich.
bool _erzwinge = false;

/// Zeitfenster (Sekunden seit Epoche) mit Beitritt, Netzabbruch, Neustart oder
/// Verlust: Dort sind kurze Lastspitzen erwartet und werden getrennt gemessen.
final List<(int, int, String)> _fenster = [];

final Stopwatch _uhr = Stopwatch()..start();

void _meldung(String text) {
  if (_diagnose) print('    [${(_uhr.elapsedMilliseconds / 1000).toStringAsFixed(1)} s] $text');
}

void Function(String)? _logFuer(String wer) => _diagnose ? (m) => _meldung('$wer: $m') : null;

Future<T> _imFenster<T>(String name, Future<T> Function() job) async {
  final a = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  try {
    return await job();
  } finally {
    _fenster.add((a, DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1, name));
  }
}

void _require(bool ok, String label) {
  if (!ok) throw StateError(label);
}

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _list(Object? v) => [for (final e in v as List) _map(e)];

Iterable<String> _keys(Object? v) sync* {
  if (v is Map) {
    for (final e in v.entries) {
      yield e.key.toString();
      yield* _keys(e.value);
    }
  } else if (v is List) {
    for (final e in v) {
      yield* _keys(e);
    }
  }
}

/// Hinter einem Proxy (Container) gehen die WebSocket-Verbindungen über
/// `findProxyFromEnvironment` (HTTPS_PROXY/NO_PROXY).
class _ProxyOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final c = super.createHttpClient(context);
    c.findProxy = HttpClient.findProxyFromEnvironment;
    return c;
  }
}

Future<T> _bis<T>(T? Function() f, String was, {Duration timeout = const Duration(seconds: 30)}) async {
  final ende = DateTime.now().add(timeout);
  while (true) {
    final r = f();
    if (r != null) return r;
    if (DateTime.now().isAfter(ende)) throw StateError('Zeitüberschreitung: $was');
    await Future<void>.delayed(const Duration(milliseconds: 15));
  }
}

/// Ein Platz am Abend mit allen empfangenen Ansichten.
class _Platz {
  _Platz(this.name, this.verb) {
    _sub = verb.ansichten.listen(inbox.add);
    _statusSub = verb.status.listen(statusVerlauf.add);
  }

  final String name;
  AbendVerbindung verb;
  final List<Map<String, Object?>> inbox = [];
  final List<VerbindungsStatus> statusVerlauf = [];
  late StreamSubscription<Map<String, Object?>> _sub;
  late StreamSubscription<VerbindungsStatus> _statusSub;

  Map<String, Object?> get latest => inbox.last;
  String get pid => verb.spielerId!;
  int get version => inbox.isEmpty ? -1 : latest['version'] as int;

  /// Neue Verbindung desselben Gastes (App-Neustart): Ansichtenverlauf bleibt erhalten.
  void ersetze(AbendVerbindung neu) {
    unawaited(_sub.cancel());
    unawaited(_statusSub.cancel());
    verb = neu;
    _sub = verb.ansichten.listen(inbox.add);
    _statusSub = verb.status.listen(statusVerlauf.add);
  }
}

/// Ein Mithörer, der den Code kennt: tritt Lobby und allen Sitz-Themen bei und
/// schneidet alles mit; versucht danach Wiedereinspielen und Fälschen.
class _Lauscher {
  _Lauscher(this.relay, this.code);

  final RelayParameter relay;
  final String code;
  late final PhoenixSocket socket;
  final StringBuffer roh = StringBuffer();
  final Map<String, List<Map<String, Object?>>> umschlaege = {};
  final Set<String> themen = {};
  final List<PhoenixKanal> kanaele = [];
  int lobbyNachrichten = 0;
  int sitzUmschlaege = 0;

  Future<void> starten() async {
    socket = PhoenixSocket(relay.socketUri, fabrik: relay.kanalFabrik);
    await socket.verbinde();
    final lobby = socket.kanal(lobbyThema(code), presence: false);
    kanaele.add(lobby);
    lobby.nachrichten.listen((m) {
      lobbyNachrichten++;
      roh.writeln('L ${m.ereignis} ${jsonEncode(m.payload)}');
      if (m.ereignis == 'klopf') _sitz(m.payload['cid']);
    });
    await lobby.beitreten();
  }

  void _sitz(Object? cid) {
    if (cid is! String || !themen.add(cid)) return;
    final thema = sitzThema(code, cid);
    final k = socket.kanal(thema, presence: false);
    kanaele.add(k);
    k.nachrichten.listen((m) {
      sitzUmschlaege++;
      roh.writeln('S $thema ${m.ereignis} ${jsonEncode(m.payload)}');
      (umschlaege[thema] ??= []).add(m.payload);
    });
    unawaited(k.beitreten().catchError((Object _) {}));
  }

  /// Spielt Mitgeschnittenes (je Thema die ersten und letzten [proRichtung]
  /// Umschläge) erneut ein, dazu manipulierte und im Absender vertauschte
  /// Kopien, gemächlich gestaffelt (die Free-Plan-Grenze gilt auch Angreifern).
  Future<int> wiedereinspielen({int proRichtung = 3, Duration pause = const Duration(milliseconds: 40)}) async {
    var n = 0;
    for (final e in umschlaege.entries) {
      final k = kanaele.firstWhere((c) => c.topic == e.key);
      final liste = e.value;
      final auswahl = <Map<String, Object?>>[
        ...liste.take(proRichtung),
        ...liste.skip(max(proRichtung, liste.length - proRichtung)),
      ];
      for (final u in auswahl) {
        k.sende('m', u);
        n++;
        final kopie = Map<String, Object?>.of(u);
        final ct = unB64(kopie['ct']);
        if (ct != null && ct.isNotEmpty) {
          ct[ct.length ~/ 2] ^= 1;
          kopie['ct'] = b64(ct);
          k.sende('m', kopie);
          n++;
        }
        // Gefälscht: Absender vertauscht.
        k.sende('m', {...u, 's': u['s'] == 'h' ? 'c' : 'h'});
        n++;
        await Future<void>.delayed(pause);
      }
    }
    return n;
  }

  Future<void> schliessen() => socket.schliessen();
}

/// Ein Hochstapler: kündigt in der Lobby einen Turm mit fremdem Gastgeberschlüssel an.
class _Hochstapler {
  _Hochstapler(this.relay, this.code);
  final RelayParameter relay;
  final String code;
  late final PhoenixSocket socket;
  Timer? _timer;

  Future<void> starten() async {
    socket = PhoenixSocket(relay.socketUri, fabrik: relay.kanalFabrik);
    await socket.verbinde();
    final lobby = socket.kanal(lobbyThema(code), presence: false);
    await lobby.beitreten();
    final fremd = await Schluesselpaar.erzeugen();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      lobby.sende('turm', {
        'hpub': b64(fremd.oeffentlich),
        'epoch': 77,
        'proto': protokollVersion,
        'akte': 'schlosskeller',
        'inhalt': 'matrix',
        'offen': true,
        'plaetze': 9,
      });
    });
  }

  Future<void> schliessen() async {
    _timer?.cancel();
    await socket.schliessen();
  }
}

/// Sitze eines Laufs: Gastgeber und Gast1 (der erste Gast); [lang]: der lange Abend (M7b).
typedef _Konstellation = ({String name, String hostSitz, String? gastSitz, bool lang});

const _konstellationen = <_Konstellation>[
  (name: 'Host = Erzähler + Gast = Detektiv', hostSitz: 'erzaehler', gastSitz: 'detektiv', lang: false),
  (name: 'Host = Detektiv ohne Erzähler', hostSitz: 'detektiv', gastSitz: null, lang: false),
  (name: 'Host = Detektiv + Gast = Erzähler', hostSitz: 'detektiv', gastSitz: 'erzaehler', lang: false),
  // Langer Abend: Der Gast-Erzähler stellt die Uhr auch in den Entscheidungen.
  (name: 'Langer Abend: Host = Detektiv + Gast = Erzähler', hostSitz: 'detektiv', gastSitz: 'erzaehler', lang: true),
];

class _Ergebnis {
  int sendungenSpitze = 0;
  int zugestelltSpitze = 0;
  String? attrappeSpitze;
}

Future<void> _lauf({
  required int n,
  required RelayParameter relay,
  required PhoenixAttrappe? attrappe,
  required Kanon kanon,
  required Texte texte,
  required _Konstellation k,
}) async {
  final minRollen = kanon.besetzungJson['minRollen'] as int;
  final maxRollen = kanon.besetzungJson['maxRollen'] as int;
  final rollen = (n - (k.gastSitz == null ? 0 : 1)).clamp(minRollen, maxRollen);
  final zufall = Random.secure();
  final salz = [for (var i = 0; i < 32; i++) zufall.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
  final fallCode = FallCode.zufall(Rng(zufall.nextInt(1 << 32)));

  _stage = 'Gastgeber ($n Gäste, ${k.name})';
  _meldung('Lauf mit $n Gästen beginnt (${k.name})');
  final hostAblage = SpeicherAblage();
  AbendRaum fabrik(String code, Map<String, Object?> meta) => SchlosskellerRaum(
        raumCode: code,
        kanon: kanon,
        texte: texte,
        fallCode: FallCode.lesen(meta['fallCode'] as String)!,
        salz: meta['salz'] as String,
        festerGastgeber: true,
        // Wie die App (GastgeberDienst): Der Sitz des Gastgebers steht in der Meta.
        gastgeberSitz: Sitz.lesen(meta['sitz']) ?? Sitz.detektiv,
        // Wie die App: Rundendauer aus der Meta, Diashow der Akte (M4).
        rundenMinuten: 20,
        diaAnzahl: _diaAnzahl,
        // Wie die App (M7b): die Fassung aus der Meta, nur bei lang geschrieben; lang mit dem Streifzug,
        // dazu Vorspiel und Morgen der Akte (der Raum nimmt sie nur im langen Abend).
        fassung: Abendfassung.lesen(meta['fassung']),
        erkundung: Abendfassung.lesen(meta['fassung']).istLang ? _erkundung : null,
        rundgang: _vorspielMorgen,
      );
  var host = await RelayHost.neu(
    fabrik: fabrik,
    meta: {'salz': salz, 'fallCode': fallCode.code, 'sitz': k.hostSitz, if (k.lang) 'fassung': 'lang'},
    relay: relay,
    akte: 'schlosskeller',
    inhalt: 'matrix',
    ablage: hostAblage,
    log: _logFuer('Gastgeber'),
  );
  final code = host.raumCode;
  final hostPlatz = _Platz('Gastgeber', host.lokaleVerbindung('host', 'Gastgeber'));
  await host.starten();
  _require(RaumCode.lesen(code) == code && code.length == 6, 'Raumcode hat nicht die Form.');
  _require(hostAblage.daten.containsKey(RelayHost.ablageSchluessel), 'Gastgeberzustand wurde nicht abgelegt.');

  final alle = <PhoenixSocket>[];
  final gaeste = <RelayGast>[];
  final plaetze = <_Platz>[];
  final ablagen = <SpeicherAblage>[];
  _Lauscher? lauscher;
  _Hochstapler? hochstapler;
  final ergebnis = _Ergebnis();
  Timer? sampler;
  try {
    // Messung: gezählte Frames aller Sockets je Sekunde.
    var letzteSumme = 0;
    sampler = Timer.periodic(const Duration(seconds: 1), (_) {
      var summe = host.zaehler?.empfangen ?? 0;
      for (final g in gaeste) {
        summe += g.zaehler.empfangen;
      }
      final d = summe - letzteSumme;
      letzteSumme = summe;
      if (d > ergebnis.zugestelltSpitze) ergebnis.zugestelltSpitze = d;
    });

    _stage = 'Mithörer und Hochstapler';
    lauscher = _Lauscher(relay, code);
    await lauscher.starten();
    alle.add(lauscher.socket);
    hochstapler = _Hochstapler(relay, code);
    await hochstapler.starten();

    _stage = 'Gäste treten bei';
    await _imFenster('Beitritt', () async {
      for (var i = 0; i < n; i++) {
        final ablage = SpeicherAblage();
        ablagen.add(ablage);
        final g = await RelayGast.beitreten(
          code: code,
          name: 'Gast${i + 1}',
          ablage: ablage,
          relay: relay,
          app: 'matrix',
          inhalt: 'matrix',
          pingIntervall: const Duration(seconds: 5),
        );
        gaeste.add(g);
        plaetze.add(_Platz('Gast${i + 1}', g));
        await Future<void>.delayed(const Duration(milliseconds: 60));
      }
    });
    await hochstapler.schliessen();
    final verworfeneTuerme = gaeste.fold<int>(0, (s, g) => s + g.verworfen);
    _require(verworfeneTuerme > 0, 'Kein gefälschter Turm wurde verworfen (Prüfung ohne Wirkung).');
    _require(
      gaeste.every((g) => g.turm != null && g.turm!.epoch == 1),
      'Ein Gast hat einen gefälschten Turm übernommen.',
    );
    for (final p in plaetze) {
      await _bis(() => p.inbox.isEmpty ? null : true, 'erste Ansicht ${p.name}');
      _require(_map(p.latest['privat'])['spieler'] == p.pid, 'Erste Ansicht gehört einem anderen Spieler.');
      _require(p.pid == 'g_${(p.verb as RelayGast).cid}', 'Spieler-ID passt nicht zur Kennung.');
    }
    _require(gaeste.map((g) => g.cid).toSet().length == n, 'Kennungen nicht eindeutig.');

    // Sitze in der Lobby (M3): Der Gastgeber sitzt nach der Meta; Gast1 bekommt den anderen Sitz.
    // Die Klasse reist mit dem Detektiv-Sitz, ein Gast-Detektiv setzt sie selbst.
    _stage = 'Sitze (${k.name})';
    final gast1 = plaetze[0];
    final detektivPlatz = k.gastSitz == 'detektiv' ? gast1 : hostPlatz;
    final erzaehlerPlatz = k.hostSitz == 'erzaehler' ? hostPlatz : (k.gastSitz == 'erzaehler' ? gast1 : null);
    final leitPlatz = erzaehlerPlatz ?? detektivPlatz;
    final vorleserPlatz = erzaehlerPlatz ?? detektivPlatz;
    final klasse = k.gastSitz == 'detektiv' ? 'journalist' : 'excop';
    _require(_list(hostPlatz.latest['spieler']).firstWhere((t) => t['id'] == hostPlatz.pid)['sitz'] == k.hostSitz,
        'Gastgeber sitzt nicht auf dem Sitz aus der Meta.');
    await _erwarteFehler(gast1, {'typ': 'sitz', 'spieler': gast1.pid, 'sitz': 'erzaehler'}, 'not_host');
    if (k.gastSitz != null) await _befehl(hostPlatz, hostPlatz, 'sitz', {'spieler': gast1.pid, 'sitz': k.gastSitz});
    await _befehl(hostPlatz, detektivPlatz, 'sitz', {'spieler': detektivPlatz.pid, 'sitz': 'detektiv', 'klasse': klasse});
    final rollenPlaetze = [for (final p in plaetze) if (p != detektivPlatz && p != erzaehlerPlatz) p];

    // Abend: alle bereit, Start.
    _stage = 'Bereit und Start';
    _meldung('Gäste beigetreten');
    await _bereit(hostPlatz, hostPlatz);
    for (final p in plaetze) {
      await _bereit(hostPlatz, p);
    }
    await _bis(() => _list(hostPlatz.latest['spieler']).length == n + 1 && _list(hostPlatz.latest['spieler']).every((t) => t['bereit'] == true) ? true : null,
        'alle bereit');
    await _befehl(hostPlatz, hostPlatz, 'start', {'rollen': rollen});
    _require(hostPlatz.latest['phase'] == 'rollen', 'Start führte nicht zu den Rollen.');
    for (final p in plaetze) {
      await _bis(() => p.latest['phase'] == 'rollen' && (_map(p.latest['privat'])['rolle'] != null || !rollenPlaetze.contains(p)) ? true : null,
          'Rolle für ${p.name}');
    }
    final rollenIds = {for (final p in rollenPlaetze) p: _map(p.latest['privat'])['rolle'] as String};
    _require(rollenIds.values.toSet().length == rollenPlaetze.length, 'Rollen nicht eindeutig verteilt.');
    // Gäste sehen die Spielerliste mit Rollen anderer Spieler? Nur die Rollen-IDs, nie Dossiers.
    for (final p in plaetze) {
      final privat = _map(p.latest['privat']);
      _require(privat['spieler'] == p.pid && (privat['dossier'] is Map) == rollenPlaetze.contains(p), 'Gast ohne eigenes Dossier oder Sitz mit Dossier.');
      _require(privat['detektiv'] == (p == detektivPlatz), 'Detektiv-Merkmal am falschen Gerät.');
    }

    // Fälschungsversuche über das Relais: feste Fehlerschlüssel, Rechte je Sitz.
    _stage = 'Fälschungsversuche';
    final rolle = rollenPlaetze.first;
    await _erwarteFehler(rolle, {'typ': 'rollenGelesen', 'spieler': hostPlatz.pid}, 'invalid');
    await _erwarteFehler(rolle, {'typ': 'weiter'}, 'not_host');
    await _erwarteFehler(rolle, {'typ': 'start', 'rollen': 4}, 'not_host');
    await _erwarteFehler(rolle, {'typ': 'gibmirdassalz'}, 'invalid');
    await _erwarteFehler(rolle, {'typ': 'anklage', 'person': 'ahmet'}, 'not_detective');
    if (erzaehlerPlatz != null) {
      await _erwarteFehler(erzaehlerPlatz, {'typ': 'fundGelesen'}, 'not_detective');
      await _erwarteFehler(detektivPlatz, {'typ': 'weiter'}, 'not_host');
    }

    // Verlust im Relais: Befehle laufen trotzdem genau einmal.
    var gastBefehle = 0;
    final vorher = host.statistik.befehleAusgefuehrt + host.statistik.befehleAbgelehnt;
    if (attrappe != null) {
      _stage = 'Nachrichtenverlust';
      attrappe.stoerung.verlust = 0.15;
      attrappe.stoerung.verzoegerungMax = const Duration(milliseconds: 40);
    }
    await _imFenster('Verlust', () async {
      for (final p in rollenPlaetze) {
        _stage = 'rollenGelesen ${p.name}';
        await _befehl(hostPlatz, p, 'rollenGelesen');
        gastBefehle++;
      }
      if (attrappe != null) {
        attrappe.stoerung.verlust = 0;
        attrappe.stoerung.verzoegerungMax = Duration.zero;
        // Verlorene Ansichten heilt der Ping (alle 5 s) über die Versionsmeldung.
        await _konvergenz(hostPlatz, plaetze, timeout: const Duration(seconds: 40));
      }
    });
    final nachher = host.statistik.befehleAusgefuehrt + host.statistik.befehleAbgelehnt;
    _require(nachher - vorher == gastBefehle, 'Befehle wurden nicht genau einmal ausgeführt ($vorher -> $nachher, erwartet +$gastBefehle).');
    await _befehl(hostPlatz, leitPlatz, 'weiter');

    var befragungenGesehen = 0;
    var uhrGeprueft = false, diaGeprueft = false;
    var streifzugGeprueft = false, uhrAbgeraeumt = false, uhrNeu = false, wegGeprueft = false;
    var gefaelschterWurf = false;
    var neuverbindungA = false;
    var hostNetz = false;
    var hostNeustart = false;
    var neuverbindungB = false;
    var schritte = 0;
    // Vorspiel und Morgen (M7b): nur im langen Abend; im Ende läuft dann noch der Morgen.
    final rundgaenge = <String>{};
    final rundgangTexte = <String>{};
    while (hostPlatz.latest['phase'] != 'ende' || hostPlatz.latest['rundgang'] is Map) {
      _require(++schritte < 500, 'Abend erreicht das Ende nicht.');
      final s = hostPlatz.latest;
      _stage = 'Phase ${s['phase']}';
      _meldung('Phase ${s['phase']} Runde ${s['runde']} v${s['version']}');
      switch (s['phase']) {
        case 'intro' || 'ende' when s['rundgang'] is Map:
          rundgaenge.add(_map(s['rundgang'])['teil'] as String);
          rundgangTexte.addAll(await _imFenster('Rundgang', () => _rundgang(hostPlatz, leitPlatz, rolle, plaetze, vorleserPlatz)));
        case 'entscheidungen':
          if (!streifzugGeprueft) {
            streifzugGeprueft = true;
            await _imFenster('Uhr im Streifzug', () => _uhrStreifzug(hostPlatz, leitPlatz, rolle, plaetze, lang: k.lang));
          }
          if (!neuverbindungA && attrappe != null && s['entscheidung'] != null) {
            neuverbindungA = true;
            await _imFenster('Netzabbruch Gast', () => _netzabbruch(attrappe, code, plaetze[1], hostPlatz));
          }
          if (s['zug'] case final Map z) {
            switch (z['phase']) {
              case 'aktion':
                await _befehl(hostPlatz, detektivPlatz, 'aktionFertig', {'aktion': z['aktion']});
              case 'wurf':
                final pate = [hostPlatz, ...plaetze].firstWhere((p) => p.pid == s['wuerfelPate']);
                _require(pate != erzaehlerPlatz, 'Der Erzähler ist Würfelpate.');
                if (!gefaelschterWurf) {
                  await _erwarteFehler(pate, {'typ': 'wurf', 'a': 6, 'b': 6}, 'invalid');
                  gefaelschterWurf = true;
                }
                if (z['id'] != 'auftakt') await _befehl(hostPlatz, pate, 'wuerfelHilfe', {'marke': false});
                await _befehl(hostPlatz, pate, 'wurf');
              case 'tischruf':
                await _befehl(hostPlatz, detektivPlatz, 'tischruf', {'ruf': n.isEven ? 'nochmal' : 'umweg'});
              case 'fund':
                await _befehl(hostPlatz, detektivPlatz, 'fundGelesen');
              default:
                throw StateError('Unbekannter Zugabschnitt.');
            }
          } else if (s['entscheidung'] case final Map e) {
            await _befehl(hostPlatz, detektivPlatz, 'wahl', {'option': _list(e['optionen']).first['id']});
          } else {
            await _befehl(hostPlatz, leitPlatz, 'weiter');
          }
        case 'gespraeche':
          if (!uhrGeprueft) {
            uhrGeprueft = true;
            await _imFenster('Rundenuhr', () => _rundenuhr(host, hostPlatz, leitPlatz, rolle, plaetze));
          } else if (!uhrNeu) {
            // Jede Runde beginnt mit gestellter Uhr, kurz wie lang.
            uhrNeu = true;
            _require(RundenUhr.ausJson(s['uhr'])?.gestartet == false, 'Die neue Runde beginnt nicht mit gestellter Uhr.');
          }
          if (!wegGeprueft) {
            wegGeprueft = true;
            await _imFenster('Streifzug', () => _streifzug(hostPlatz, detektivPlatz, rolle, plaetze, lang: k.lang));
          }
          // Modell befragung (A-051): Der Detektiv-Sitz erledigt seine Befragungen.
          // Erst sehen alle Gäste ihre Spickzettel, dann fragt der Detektiv; vor „Weiter“ sehen sie den Stand.
          await _konvergenz(hostPlatz, plaetze, timeout: const Duration(seconds: 40));
          befragungenGesehen += await _befragungen(hostPlatz, detektivPlatz);
          await _konvergenz(hostPlatz, plaetze, timeout: const Duration(seconds: 40));
          await _befehl(hostPlatz, leitPlatz, 'weiter');
        case 'gruppenwahl':
          if (!uhrAbgeraeumt) {
            // Nach dem Streifzug gibt es keine Uhr mehr, kurz wie lang.
            uhrAbgeraeumt = true;
            _require(!s.containsKey('uhr'), 'Uhr in der Gruppenwahl.');
            await _erwarteFehler(leitPlatz, {'typ': 'uhr', 'aktion': 'pause'}, 'invalid_phase');
          }
          if (!neuverbindungB) {
            neuverbindungB = true;
            await _imFenster('Neustart Gast-App', () => _appNeustart(plaetze[min(2, n - 1)], gaeste, ablagen, relay, code, min(2, n - 1), hostPlatz));
          }
          for (final p in plaetze) {
            await _bis(() => p.latest['phase'] == 'gruppenwahl' && p.latest['runde'] == s['runde'] ? true : null, 'Gruppenwahl-Ansicht ${p.name}');
            if (_map(p.latest['privat'])['hatGestimmt'] == false) {
              await _befehl(hostPlatz, p, 'stimme', {'kooperativ': n.isEven});
            }
          }
          await _befehl(hostPlatz, leitPlatz, 'weiter');
        case 'intro':
          if (!diaGeprueft) {
            diaGeprueft = true;
            await _imFenster('Diashow', () => _diashow(hostPlatz, leitPlatz, rolle, plaetze));
          }
          if (!hostNetz) {
            hostNetz = true;
            await _imFenster('Netzabbruch Gastgeber', () => _hostNetzabbruch(host, hostPlatz, plaetze));
          }
          await _befehl(hostPlatz, leitPlatz, 'weiter');
        case 'resuemee':
          if (!hostNeustart) {
            hostNeustart = true;
            host = await _imFenster('Neustart Gastgeber', () => _hostNeustart(host, hostPlatz, plaetze, hostAblage, fabrik, relay, rolle: rolle));
          }
          await _befehl(hostPlatz, leitPlatz, 'weiter');
        case 'anklage':
          await _befehl(hostPlatz, detektivPlatz, 'anklage', {'person': (s['verdaechtige'] as List).first});
          await _befehl(hostPlatz, leitPlatz, 'weiter');
        case 'rollen':
          for (final p in rollenPlaetze) {
            if (_map(p.latest['privat'])['gelesen'] != true) await _befehl(hostPlatz, p, 'rollenGelesen');
          }
          await _befehl(hostPlatz, leitPlatz, 'weiter');
        default:
          await _befehl(hostPlatz, leitPlatz, 'weiter');
      }
    }
    _require(gefaelschterWurf, 'Manipulationsprüfung des Würfels wurde nicht erreicht.');
    _require(uhrGeprueft && diaGeprueft, 'Rundenuhr- und Diashow-Prüfung wurden nicht erreicht.');
    _require(streifzugGeprueft && uhrAbgeraeumt && uhrNeu, 'Prüfungen der Uhr im Streifzug wurden nicht erreicht.');
    _require(wegGeprueft, 'Die Prüfung des Streifzugs wurde nicht erreicht.');
    _require(neuverbindungB, 'App-Neustart-Prüfung wurde nicht erreicht.');
    _require(hostNetz && hostNeustart, 'Gastgeber-Prüfungen (Netzabbruch, Neustart) wurden nicht erreicht.');
    _require(attrappe == null || neuverbindungA, 'Netzabbruch-Prüfung wurde nicht erreicht.');
    _require(k.lang ? rundgaenge.containsAll(['vorspiel', 'morgen']) : rundgaenge.isEmpty, 'Vorspiel und Morgen nur im langen Abend und dort ganz.');

    _stage = 'Ende abwarten';
    await _konvergenz(hostPlatz, plaetze, timeout: const Duration(seconds: 40));
    final letzte = hostPlatz.latest;
    _require(letzte['phase'] == 'ende', 'Abend endete nicht.');
    final loesung = _map(letzte['aufloesung']);
    final pfad = loesung['pfad'] as String;
    final geheimSalz = loesung['salz'] as String;
    _require(geheimSalz == salz, 'Auflösung nennt ein anderes Salz.');
    for (final p in plaetze) {
      _require(p.latest['phase'] == 'ende' && p.latest['aufloesung'] != null, '${p.name} bekam die Auflösung nicht.');
    }

    // Würfelprotokoll nachrechnen.
    final quelle = SalzWuerfel(geheimSalz);
    for (final w in _list(letzte['wuerfe'])) {
      final erwartet = Wurf.werfen(quelle, w['id'] as String, w['anlauf'] as int, w['mod'] as int, garantie: w['garantie'] as bool);
      _require(jsonEncode(erwartet.toJson()) == jsonEncode(w), 'Würfelprotokoll lässt sich nicht nachrechnen.');
    }

    // Privatheit: alle empfangenen Ansichten jedes Gastes.
    _stage = 'Privatheitsprüfung';
    // Die Liste steht einmal im Kern (raumOeffentlicheSchluessel, A-009).
    const erlaubt = raumOeffentlicheSchluessel;
    const geheim = {'pfad', 'fallCode', 'salz', 'seed', 'richtig', 'qualitaeten', 'aufloesung'};
    final dossiersAlle = <String, Map<String, Object?>>{
      for (final r in Besetzung(kanon).besetzt(rollen)) r: _dossierJson(texte, r, pfad, rollen),
    };
    var geprueft = 0;
    var spickzettel = 0;
    var ansichtenGesamt = 0;
    var verglichen = 0;
    var notizen = 0;
    var auflosungFuerAlle = 0;
    final hostOhnePrivat = <Object?, String>{
      for (final v in hostPlatz.inbox) v['version']: jsonEncode(Map<String, Object?>.of(v)..remove('privat')),
    };
    // Vorleser-Sitz (M3): Was der Vorleser vor dem Finale bekam, sieht kein anderes Gerät.
    final vorgelesen = <String>{
      for (final v in vorleserPlatz.inbox)
        if (!['lobby', 'finale', 'aufloesung', 'ende'].contains(v['phase'])) ...(_map(v['privat'])['erzaehler'] as List).cast<String>(),
    };
    _require(vorgelesen.isNotEmpty, 'Der Vorleser bekam keinen Erzähltext.');
    // Vorspiel und Morgen (M7b): Den Vorlesetext einer Station sieht nur der Vorleser, auch am Morgen.
    for (final p in [hostPlatz, ...plaetze].where((p) => p != vorleserPlatz)) {
      for (final view in p.inbox) {
        final text = jsonEncode(view);
        _require(!_map(view['privat']).containsKey('rundgangText') && rundgangTexte.every((t) => !text.contains(jsonEncode(t))),
            'Vorlesetext des Rundgangs an ${p.name}, der nicht vorliest.');
      }
    }
    final npcTexte = {for (final e in texte.sammlung.bausteine.entries) if (e.key.startsWith('npc.')) e.value};
    // Nie beim Erzähler oder Detektiv: verbirgt, Tatwissen und Tarnung irgendeiner Rolle.
    final rollenGeheim = <String>{
      for (final d in dossiersAlle.values) ...[
        for (final t in (d['verbirgt'] as List?) ?? const []) t as String,
        for (final t in (d['tatwissen'] as List?) ?? const []) t as String,
        if (d['tarnung'] case final String t) t,
      ],
    };
    for (final p in [hostPlatz, ...plaetze]) {
      final istDetektiv = p == detektivPlatz, istErzaehler = p == erzaehlerPlatz;
      for (final view in p.inbox) {
        final privat = _map(view['privat']);
        final lobby = view['phase'] == 'lobby';
        // Fassung (M7b): lang trägt jede Ansicht `fassung: lang`, kurz keine den Schlüssel.
        _require(k.lang ? view['fassung'] == 'lang' : !view.containsKey('fassung'), 'Fassung fehlt oder steht im kurzen Abend (${p.name}).');
        final nachFinale = ['finale', 'aufloesung', 'ende'].contains(view['phase']);
        if (!nachFinale) {
          _require(!view.containsKey('erzaehler'), 'Öffentlicher Erzähltext vor dem Finale (${p.name}).');
          if (p == vorleserPlatz && !lobby) {
            final eigene = privat['erzaehler'] as List;
            _require(eigene.length == view['bausteinZahl'] && view['erzaehlerLiest'] == eigene.isNotEmpty, 'Vorleser ohne seinen Erzähltext.');
          } else {
            _require(!privat.containsKey('erzaehler') && !privat.containsKey('vorleser'), 'Erzähltext an ${p.name}, der nicht vorliest.');
            final ohneNotiz = jsonEncode({...view, 'privat': Map.of(privat)..remove('erzaehlerNotizen')});
            _require(vorgelesen.every((t) => !ohneNotiz.contains(jsonEncode(t))), 'Erzähltext vor dem Finale bei ${p.name}.');
          }
          _require(_list(view['spieler']).every((t) => raumSpielerFelder.containsAll(t.keys)), 'Nicht freigegebenes Spielerfeld.');
        } else if (view['phase'] != 'ende') {
          // Ab dem Finale sehen alle die Auflösungstexte (öffentlich, für alle gleich).
          _require(view['erzaehler'] is List, 'Nach dem Finale fehlt der öffentliche Erzähltext.');
          auflosungFuerAlle++;
        }
        if (!lobby) {
          _require(privat.containsKey('erzaehlerPaket') == istErzaehler, 'Erzählerpaket am falschen Sitz (${p.name}).');
          _require(privat.containsKey('erzaehlerNotizen') == istDetektiv, 'npc-Notizen am falschen Sitz (${p.name}).');
          _require(privat['klasse'] == (istDetektiv || p == hostPlatz ? klasse : null), 'Klasse am falschen Gerät (${p.name}).');
          _require(privat['detektiv'] == istDetektiv, 'Detektiv-Merkmal am falschen Gerät (${p.name}).');
        }
        if (privat['erzaehlerNotizen'] case final List n) {
          _require(npcTexte.containsAll(n), 'Notiz des Detektivs ist kein npc-Wissen.');
          notizen += n.length;
        }
        if ((istDetektiv || istErzaehler) && !nachFinale) {
          _require(_keys(view).toSet().intersection({'dossier', 'verbirgt', 'tatwissen', 'tarnung'}).isEmpty, 'Rollenwissen an ${p.name} (Sitz).');
          final nur = jsonEncode(privat);
          _require(rollenGeheim.every((t) => !nur.contains(jsonEncode(t).substring(1, jsonEncode(t).length - 1))),
              'verbirgt, Tatwissen oder Tarnung im privaten Teil von ${p.name} (Sitz).');
        }
      }
    }
    _require(auflosungFuerAlle > 0, 'Keine Ansicht nach dem Finale geprüft.');
    _require(rollen > 7 || notizen > 0, 'Der Detektiv bekam kein npc-Wissen als Notiz.');
    for (final p in plaetze) {
      final eigeneRolle = rollenIds[p];
      final eigenes = eigeneRolle == null ? const <String, Object?>{} : dossiersAlle[eigeneRolle]!;
      final eigeneTexte = _texte(eigenes);
      final fremdeTexte = eigeneRolle == null
          ? rollenGeheim
          : (<String>{
              for (final e in dossiersAlle.entries)
                if (e.key != eigeneRolle) ..._texte(e.value),
            }..removeAll(eigeneTexte));
      for (final view in p.inbox) {
        ansichtenGesamt++;
        final privat = _map(view['privat']);
        _require(privat['spieler'] == p.pid && view['raum'] == code, 'Ansicht gehört einem anderen Empfänger oder Raum.');
        final text = jsonEncode(view);
        final phase = view['phase'];
        final nachFinale = ['finale', 'aufloesung', 'ende'].contains(phase);
        if (!nachFinale) {
          _require(_keys(view).toSet().intersection(geheim).isEmpty, 'Geheimer Steuerwert vor dem Finale übertragen (${p.name}).');
          _require(view.keys.every(erlaubt.contains), 'Nicht freigegebenes Feld vor dem Finale: ${view.keys.where((k) => !erlaubt.contains(k))}.');
          _require(!text.contains(geheimSalz), 'Salz in einer Ansicht vor dem Finale.');
          _require(!text.contains(texte.sammlung.taeter[pfad]!.tarnung) || eigeneRolle == pfad, 'Täterfassung vor dem Finale an Unschuldigen.');
        }
        _require(_keys(view).where((k) => k == 'dossier').length <= 1, 'Mehr als ein Dossier in einer Ansicht.');
        // Modell befragung: kein Gast sieht eine Antwort der App oder fremde Befragungskarten,
        // der eigene Spickzettel ist genau der der eigenen Rolle in dieser Runde. Ausnahmen:
        // der Detektiv-Sitz (seine Karten) und das Erzählerpaket (pfadfreie Antworten, A-052).
        if (p != detektivPlatz) {
          final ohnePaket = {...view, 'privat': Map.of(privat)..remove('erzaehlerPaket')};
          _require(!_keys(ohnePaket).contains('antwort') && !privat.containsKey('befragungen'), 'Befragungsantwort oder Detektivkarten an ${p.name}.');
        }
        if (privat['befragung'] case final Map b) {
          final runde = view['runde'] as int;
          _require(eigeneRolle != null && b['id'] == BefragungText.kennung(eigeneRolle, runde), 'Fremde Befragung an ${p.name}.');
          final soll = befragungsZettel(texte, texte.sammlung.befragungen[b['id']]!);
          _require(jsonEncode(b['karten']) == jsonEncode([for (final k in soll.karten) {'zeilen': k.zeilen, 'behaupte': k.behaupten}]),
              'Falscher Spickzettel an ${p.name}.');
          spickzettel++;
        }
        if (privat['dossier'] != null) {
          _require(jsonEncode(privat['dossier']) == jsonEncode(eigenes), 'Falsches oder fremdes Dossier an ${p.name}.');
          geprueft++;
        }
        // Alles außer `privat` ist öffentlich und muss bei gleicher Version
        // für alle gleich sein; die Texte fremder Dossiers dürfen höchstens
        // öffentlich bekannt sein, im privaten Teil nie auftauchen.
        final hostGleich = hostOhnePrivat[view['version']];
        if (hostGleich != null) {
          _require(jsonEncode(Map<String, Object?>.of(view)..remove('privat')) == hostGleich,
              'Öffentlicher Teil bei ${p.name} weicht vom Gastgeber ab (Version ${view['version']}).');
          verglichen++;
        }
        final privatText = jsonEncode(privat);
        for (final t in fremdeTexte) {
          if (t.length >= 24) {
            _require(!privatText.contains(jsonEncode(t).substring(1, jsonEncode(t).length - 1)),
                'Fremder Dossiertext im privaten Teil von ${p.name} (Phase ${view['phase']})${_diagnose ? ': "$t"' : ''}.');
          }
        }
      }
    }
    _require(verglichen > n * 5, 'Zu wenige Ansichten mit dem Gastgeber verglichen ($verglichen).');
    final hostText = [for (final v in hostPlatz.inbox) jsonEncode(v)].join('\n');
    _require(!hostPlatz.inbox.any((v) => _map(v['privat'])['dossier'] != null), 'Gastgeber (Detektiv) bekam ein Dossier.');
    _require(hostText.isNotEmpty, 'Gastgeber ohne Ansichten.');
    _require(geprueft >= rollenPlaetze.length, 'Zu wenige Dossiers geprüft.');
    if (texte.besetzung.befragungsmodell) {
      _require(spickzettel >= rollenPlaetze.length, 'Zu wenige Spickzettel geprüft ($spickzettel).');
      _require(befragungenGesehen >= 9, 'Der Detektiv hat kaum Befragungen geführt ($befragungenGesehen).');
      // Antworten der App bekommt nur der Detektiv-Sitz, und nur nach der Frage.
      _require(!detektivPlatz.inbox.any((v) => _list(_map(v['privat'])['befragungen'] ?? const []).any((k) => k['frage'] == null && k.containsKey('antwort'))),
          'Antwort vor der Frage an den Detektiv.');
    }
    final ablageText = hostAblage.daten[RelayHost.ablageSchluessel]!;
    _require(ablageText.contains('"log"'), 'Gastgeberzustand ohne Protokoll abgelegt.');

    // Mithörer: nie Klartext, nichts wiedereinspielbar.
    _stage = 'Mithörer';
    final mitgeschnitten = lauscher.roh.toString();
    _require(lauscher.sitzUmschlaege > 4 * n, 'Mithörer sah kaum Verkehr (Prüfung ohne Wirkung): ${lauscher.sitzUmschlaege}.');
    _require(lauscher.themen.length == n, 'Mithörer kennt nicht alle Sitze.');
    final alleKlartexte = <String>{for (final d in dossiersAlle.values) ..._texte(d)};
    final lesbar = alleKlartexte.where((t) => t.length >= 12).toList();
    _require(lesbar.isNotEmpty, 'Keine Dossiertexte zum Vergleich.');
    for (final t in lesbar) {
      final roh = jsonEncode(t).substring(1, jsonEncode(t).length - 1);
      _require(!mitgeschnitten.contains(roh) && !mitgeschnitten.contains(t), 'Mithörer sah Dossier-Klartext.');
    }
    for (final verboten in ['"dossier"', '"privat"', '"weiss"', '"verbirgt"', '"aufloesung"', geheimSalz, '"hatGestimmt"', 'Gast1', 'Gastgeber']) {
      _require(!mitgeschnitten.contains(verboten), 'Mithörer sah Klartext ($verboten).');
    }
    final lobbyZeilen = mitgeschnitten.split('\n').where((z) => z.startsWith('L ')).toList();
    for (final z in lobbyZeilen) {
      _require(z.startsWith('L klopf ') || z.startsWith('L turm '), 'Unerwartetes Lobby-Ereignis.');
    }
    // Positivprobe: Die berechtigten Gäste können diese Texte sehr wohl lesen.
    final gastText = [for (final v in rollenPlaetze.first.inbox) jsonEncode(v)].join('\n');
    _require(lesbar.any(gastText.contains), 'Positivprobe: Gast sieht seinen eigenen Dossiertext nicht.');

    // Der legitime Verkehr muss die Free-Plan-Grenze einhalten; gemessen vor dem
    // Angriff (die Einspielungen des Mithörers verzerren die Zahlen).
    sampler.cancel();
    if (attrappe != null) {
      if (_diagnose) {
        final top = attrappe.sekundenZaehler.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        for (final e in top.take(5)) {
          final th = attrappe.sekundenProThema[e.key] ?? const <String, int>{};
          final lobby = th[lobbyThema(code)] ?? 0;
          final absender = <int, int>{};
          for (final x in attrappe.eintraege) {
            if (x.zeit.millisecondsSinceEpoch ~/ 1000 == e.key) absender[x.von] = (absender[x.von] ?? 0) + 1;
          }
          final fn = [for (final f in _fenster) if (e.key >= f.$1 && e.key <= f.$2) f.$3];
          print('    Sekunde ${e.key % 1000}: ${e.value} Zustellungen (Lobby $lobby, Sitze ${e.value - lobby}) $fn; Sendungen je Verbindung $absender');
        }
      }
      // Der Mithörer ist ein zusätzlicher Abonnent (verdoppelt die Zustellungen); die
      // Grenze gilt für den legitimen Verkehr im normalen Spiel. Kurze Spitzen bei
      // Beitritt, Netzabbruch und Neustart (Fenster) werden getrennt gemeldet.
      final lauscherIds = {
        for (final v in attrappe.verbindungen)
          if (v.themen.containsKey(lobbyThema(code)) && v.themen[lobbyThema(code)] == null) v.id,
      };
      final an = attrappe.sekundenAnVerbindung;
      var normal = 0, gestoert = 0;
      for (final e in attrappe.sekundenZaehler.entries) {
        final legitim = e.value - lauscherIds.fold<int>(0, (a, id) => a + (an[e.key]?[id] ?? 0));
        if (_fenster.any((f) => e.key >= f.$1 && e.key <= f.$2)) {
          gestoert = max(gestoert, legitim);
        } else {
          normal = max(normal, legitim);
        }
      }
      _require(normal <= attrappe.limitProSekunde, 'Free-Plan-Grenze im normalen Spiel überschritten: $normal/s legitime Zustellungen (Grenze ${attrappe.limitProSekunde}/s).');
      ergebnis.attrappeSpitze = '$normal/s legitim im normalen Spiel, $gestoert/s in Störfenstern, ${attrappe.spitzeProSekunde}/s mit Mithörer '
          '(Grenze ${attrappe.limitProSekunde}; ${attrappe.zugestellt} Zustellungen, größter Frame ${attrappe.groessteNutzlast ~/ 1024} KB)';
    }
    ergebnis.sendungenSpitze = host.statistik.spitzeProSekunde;

    final vorEinspielen = host.statistik.befehleAusgefuehrt;
    final verworfenVorher = host.statistik.umschlaegeVerworfen;
    final gastVerworfenVorher = gaeste.fold<int>(0, (s, g) => s + g.verworfen);
    final ansichtenVorher = [for (final p in plaetze) p.inbox.length];
    final hostVersion = hostPlatz.version;
    final gesendet = await lauscher.wiedereinspielen();
    // Jede eingespielte Nachricht erreicht Gastgeber und Gast und wird von beiden verworfen
    // (mit --erzwinge verwirft schon die Attrappe einen Teil: dann genügt mindestens eine).
    await _bis(() => host.statistik.umschlaegeVerworfen - verworfenVorher >= (_erzwinge ? 1 : gesendet) ? true : null, 'Gastgeber verwirft alle Einspielungen');
    await _bis(() => gaeste.fold<int>(0, (s, g) => s + g.verworfen) - gastVerworfenVorher >= (_erzwinge ? 1 : gesendet) ? true : null, 'Gäste verwerfen alle Einspielungen');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _require(host.statistik.befehleAusgefuehrt == vorEinspielen, 'Wiedereingespielter Befehl wurde ausgeführt.');
    for (var i = 0; i < n; i++) {
      _require(plaetze[i].inbox.length == ansichtenVorher[i], 'Wiedereingespielte Ansicht wurde angenommen (${plaetze[i].name}).');
    }
    _require(hostPlatz.version == hostVersion, 'Wiedereinspielung veränderte den Raum.');

    _require(host.statistik.spitzeProSekunde <= 40, 'Gastgeber sendete zeitweise ${host.statistik.spitzeProSekunde} Nachrichten/s.');
    _require(host.statistik.groessteAnsichtZeichen < 200 * 1024, 'Ansicht nahe an der Nutzlastgrenze.');

    final st = host.statistik;
    print('RELAIS-ONLINE OK · ${k.name} · $n Gäste + Gastgeber · $rollen Rollen${k.lang ? ' · Vorspiel und Morgen' : ''} · $ansichtenGesamt Gast-Ansichten geprüft, $geprueft Dossiers · '
        'Mithörer ${lauscher.sitzUmschlaege} Umschläge ohne Klartext, $gesendet Einspielungen abgewehrt · '
        'Befehle ${st.befehleAusgefuehrt} (davon ${st.befehleWiederholt} Wiederholungen erkannt) · '
        'Gastgeber-Spitze ${ergebnis.sendungenSpitze}/s, gezählte Frames Spitze ${ergebnis.zugestelltSpitze}/s'
        '${ergebnis.attrappeSpitze == null ? '' : ', Attrappe ${ergebnis.attrappeSpitze}'} · '
        'größte Ansicht ${st.groessteAnsichtZeichen ~/ 1024} KB, ${st.ratenVerzoegert} Verzögerungen durch die 30/s-Grenze');
  } finally {
    sampler?.cancel();
    await hochstapler?.schliessen().catchError((Object _) {});
    for (final g in gaeste) {
      try {
        await g.trennen();
      } catch (_) {}
    }
    try {
      await host.schliessen();
    } catch (_) {}
    for (final s in alle) {
      try {
        await s.schliessen();
      } catch (_) {}
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

Map<String, Object?> _dossierJson(Texte texte, String rolle, String pfad, int rollen) {
  final d = texte.dossier(rolle, pfad, rollen);
  return {
    'wer': d.wer,
    'ziel': d.ziel,
    'besetzung': d.besetzung,
    'weiss': [for (final z in d.weiss) z.text],
    'verbirgt': [for (final z in d.verbirgt) z.text],
    if (d.tarnung != null) 'tarnung': d.tarnung,
    if (d.tatwissen.isNotEmpty) 'tatwissen': [for (final z in d.tatwissen) z.text],
  };
}

Set<String> _texte(Map<String, Object?> dossier) {
  final out = <String>{};
  void sammle(Object? v) {
    if (v is String) {
      out.add(v);
    } else if (v is List) {
      v.forEach(sammle);
    } else if (v is Map) {
      v.values.forEach(sammle);
    }
  }

  sammle(dossier);
  return out;
}

/// Modell befragung (A-051): Der Detektiv-Sitz ([detektiv], Gastgeber oder Gast) stellt je feste
/// und bis zur Grenze freie Befragung die erste Frage und erledigt, was ein Mensch am Tisch
/// beantwortet. Ergibt die Zahl der Befragungen.
Future<int> _befragungen(_Platz host, _Platz detektiv) async {
  final privat = _map(detektiv.latest['privat']);
  if (privat['befragungen'] is! List) return 0;
  var frei = privat['befragungenFrei'] as int;
  var zahl = 0;
  for (final k in _list(privat['befragungen'])) {
    if (k['erledigt'] == true) continue;
    if (k['frage'] == null) {
      if (k['pflicht'] != true) {
        if (frei <= 0) continue;
        frei--;
      }
      await _befehl(host, detektiv, 'befragen', {'id': k['id'], 'frage': 0});
      zahl++;
    }
    if (k['mensch'] == true) await _befehl(host, detektiv, 'erledigt', {'id': k['id']});
  }
  return zahl;
}

Future<void> _bereit(_Platz host, _Platz wer) => _befehl(host, wer, 'bereit', {'wert': true});

/// Erkundung des Schlosskellers (`content/welt/schlosskeller/erkundung.json`), wie in der App.
final Erkundung? _erkundung = ladeErkundung('${Directory(resolvePartyDir(null)).parent.parent.path}/welt/schlosskeller');

/// Streifzug (M7b) in den ersten Gesprächen: kurz kennt der Raum `erkunde`
/// nicht und zeigt keinen Schlüssel. Lang nur vom Detektiv-Sitz; nach Erkunden
/// und Treffen sehen alle dieselbe Stelle und dasselbe Treffen, die Treffpunkte
/// aller stehen nur privat beim Detektiv, und die getroffene Person erkennt
/// ihre Figur.
Future<void> _streifzug(_Platz host, _Platz detektiv, _Platz rolle, List<_Platz> plaetze, {required bool lang}) async {
  if (!lang) {
    _require(!host.latest.containsKey('streifzug'), 'Kurzer Abend: Streifzug in der Ansicht.');
    await _erwarteFehler(detektiv, {'typ': 'erkunde', 'ort': 'ek_brunnen'}, 'invalid');
    return;
  }
  await _erwarteFehler(rolle, {'typ': 'erkunde', 'ort': 'ek_brunnen'}, 'not_detective');
  await _befehl(host, detektiv, 'erkunde', {'ort': 'ek_brunnen'});
  await _bis(() => detektiv.latest['streifzug'] is Map ? true : null, 'Streifzug beim Detektiv');
  final treffpunkte = _map(_map(_map(detektiv.latest['privat'])['streifzug'])['treffpunkte']);
  _require(treffpunkte.isNotEmpty, 'Streifzug: Der Detektiv-Sitz hat keine Treffpunkte.');
  final befragung = treffpunkte.keys.first;
  await _befehl(host, detektiv, 'treffen', {'befragung': befragung});
  await _konvergenz(host, plaetze, timeout: const Duration(seconds: 40));
  final treffen = <String>{};
  for (final p in [host, ...plaetze]) {
    final weg = _map(p.latest['streifzug']);
    _require((weg['erkundet'] as List).contains('ek_brunnen'), 'Streifzug: Erkundung fehlt bei ${p.name}.');
    final t = _map(weg['treffpunkt']);
    _require(t['ort'] == treffpunkte[befragung], 'Streifzug: Treffpunkt weicht ab bei ${p.name}.');
    treffen.add(jsonEncode(t));
    _require(p == detektiv || !_map(p.latest['privat']).containsKey('streifzug'), 'Streifzug: Treffpunkte aller bei ${p.name}.');
    if (_map(p.latest['privat'])['rolle'] case final String r when r == t['figur']) {
      _require(weg['ebene'] != null, 'Streifzug: Die getroffene Person sieht keine Stelle.');
    }
  }
  _require(treffen.length == 1, 'Streifzug: Das Treffen ist nicht für alle gleich.');
}

/// Bilder der Diashow des Schlosskellers (`content/welt/schlosskeller/diashow.json`), wie in der App.
final int _diaAnzahl = () {
  final datei = File('${Directory(resolvePartyDir(null)).parent.parent.path}/welt/schlosskeller/diashow.json');
  return Diashow.ausJson((jsonDecode(datei.readAsStringSync()) as Map).cast<String, Object?>()).dias.length;
}();

/// Vorspiel und Morgen des Schlosskellers (`content/welt/schlosskeller/vorspiel_morgen.json`), wie in der App.
final VorspielMorgen? _vorspielMorgen = ladeVorspielMorgen('${Directory(resolvePartyDir(null)).parent.parent.path}/welt/schlosskeller');

/// Vorspiel oder Morgen (M7b) über das Relais: Eine Rolle darf nicht schalten,
/// ein veralteter Schritt ist `stale`; je Station sehen alle dieselbe Karte, den
/// Vorlesetext nur [vorleser] (privat). Liefert die vorgelesenen Texte.
Future<Set<String>> _rundgang(_Platz host, _Platz leiter, _Platz rolle, List<_Platz> plaetze, _Platz vorleser) async {
  final texte = <String>{};
  final teil = _map(host.latest['rundgang'])['teil'];
  await _erwarteFehler(rolle, {'typ': 'rundgang', 'station': 0}, 'not_host');
  await _erwarteFehler(leiter, {'typ': 'rundgang', 'station': (_map(host.latest['rundgang'])['station'] as int) + 1}, 'stale');
  for (var i = 0; i < 12; i++) {
    final g = host.latest['rundgang'];
    if (g is! Map || g['teil'] != teil) break;
    await _konvergenz(host, plaetze, timeout: const Duration(seconds: 40));
    final alle = [host, ...plaetze];
    _require({for (final p in alle) jsonEncode(p.latest['rundgang'])}.length == 1, 'Die Station ist nicht für alle gleich.');
    for (final p in alle) {
      final privat = _map(p.latest['privat']);
      if (p == vorleser) {
        _require(privat['rundgangText'] is String, 'Der Vorleser bekam den Vorlesetext der Station nicht.');
        texte.add(privat['rundgangText'] as String);
      } else {
        _require(!privat.containsKey('rundgangText'), 'Vorlesetext der Station an ${p.name}, der nicht vorliest.');
      }
    }
    if (teil == 'vorspiel') _require(host.latest['kannWeiter'] != true, 'Während des Vorspiels geht es nicht weiter in die Runden.');
    await _befehl(host, leiter, 'rundgang', {'station': g['station']});
  }
  _require(host.latest['rundgang'] == null, 'Der Rundgang endet nicht.');
  return texte;
}

/// Diashow (M4): Den Zähler `dia` sehen alle gleich; schalten darf nur, wer
/// leitet. Eine Rolle bekommt `not_host`, ein Bild außerhalb `invalid`.
Future<void> _diashow(_Platz host, _Platz leiter, _Platz rolle, List<_Platz> plaetze) async {
  _require(host.latest['dia'] == 0, 'Die Einleitung beginnt nicht mit dem ersten Bild.');
  await _erwarteFehler(rolle, {'typ': 'dia', 'nr': 1}, 'not_host');
  await _erwarteFehler(leiter, {'typ': 'dia', 'nr': _diaAnzahl}, 'invalid');
  for (var nr = 1; nr < _diaAnzahl; nr++) {
    await _befehl(host, leiter, 'dia', {'nr': nr});
  }
  await _konvergenz(host, plaetze, timeout: const Duration(seconds: 40));
  _require([host, ...plaetze].every((p) => p.latest['dia'] == _diaAnzahl - 1), 'Nicht alle Geräte zeigen dasselbe Bild.');
}

/// Gemeinsame Rundenuhr (M4): Der Gastgeber stempelt die Abendzeit, auch wenn
/// ein Gerät eine eigene mitschickt; alle sehen dieselbe Uhr und rechnen die
/// Restzeit mit dem Versatz aus dem `pong` selbst. Nur wer leitet, stellt sie.
Future<void> _rundenuhr(RelayHost relais, _Platz host, _Platz leiter, _Platz rolle, List<_Platz> plaetze) async {
  _require(RundenUhr.ausJson(host.latest['uhr'])?.gestartet == false, 'Die Runde beginnt nicht mit gestellter Uhr.');
  await _erwarteFehler(rolle, {'typ': 'uhr', 'aktion': 'start'}, 'not_host');
  final vorher = relais.abendzeit();
  await _befehl(host, leiter, 'uhr', {'aktion': 'start', 'zeit': 1});
  final nachher = relais.abendzeit();
  await _befehl(host, leiter, 'uhr', {'aktion': 'plus', 'minuten': 5});
  await _konvergenz(host, plaetze, timeout: const Duration(seconds: 40));
  final uhren = {for (final p in [host, ...plaetze]) jsonEncode(p.latest['uhr'])};
  _require(uhren.length == 1, 'Die Uhr ist nicht für alle gleich.');
  final uhr = RundenUhr.ausJson(host.latest['uhr'])!;
  _require(uhr.laeuft && uhr.start! >= vorher && uhr.start! <= nachher, 'Die Uhr trägt nicht die Zeit des Gastgebers.');
  _require(uhr.dauer == 25 * RundenUhr.minute, 'Plus fünf Minuten fehlt.');
  for (final p in plaetze) {
    final g = p.verb as RelayGast;
    _require(g.versatz != null, '${p.name} kennt die Uhr des Gastgebers nicht.');
    _require(uhr.rest(g.gastgeberZeit) > uhr.dauer - 60000, '${p.name} rechnet eine falsche Restzeit.');
  }
}

/// Uhr im Streifzug (M7b), beim Eintritt in die Entscheidungen der ersten Runde.
/// Lang läuft die Uhr der Gespräche weiter (gestartet, 25 Minuten), alle sehen
/// sie gleich, nur wer leitet, hält sie an und lässt sie weiterlaufen. Kurz gibt
/// es dort keine Uhr, und `uhr` ist `invalid_phase` wie bisher.
Future<void> _uhrStreifzug(_Platz host, _Platz leiter, _Platz rolle, List<_Platz> plaetze, {required bool lang}) async {
  final s = host.latest;
  if (!lang) {
    _require(!s.containsKey('uhr'), 'Kurzer Abend: Uhr in den Entscheidungen.');
    await _erwarteFehler(leiter, {'typ': 'uhr', 'aktion': 'pause'}, 'invalid_phase');
    return;
  }
  final uhr = RundenUhr.ausJson(s['uhr']);
  _require(uhr != null && uhr.laeuft && uhr.dauer == 25 * RundenUhr.minute, 'Langer Abend: Die Uhr der Gespräche läuft in den Entscheidungen nicht weiter.');
  await _erwarteFehler(rolle, {'typ': 'uhr', 'aktion': 'pause'}, 'not_host');
  await _befehl(host, leiter, 'uhr', {'aktion': 'pause'});
  _require(RundenUhr.ausJson(host.latest['uhr'])?.pausiert == true, 'Langer Abend: Die Uhr hält in den Entscheidungen nicht an.');
  await _befehl(host, leiter, 'uhr', {'aktion': 'weiter'});
  await _konvergenz(host, plaetze, timeout: const Duration(seconds: 40));
  final uhren = {for (final p in [host, ...plaetze]) jsonEncode(p.latest['uhr'])};
  _require(uhren.length == 1 && RundenUhr.ausJson(host.latest['uhr'])!.laeuft, 'Langer Abend: Die Uhr in den Entscheidungen ist nicht für alle gleich.');
}

Future<void> _befehl(_Platz host, _Platz sender, String typ, [Map<String, Object?> daten = const {}]) async {
  final v = host.version;
  await sender.verb.befehl({'typ': typ, ...daten});
  await _bis(() => host.version > v ? true : null, 'Ansicht des Gastgebers nach $typ', timeout: const Duration(seconds: 15));
}

Future<void> _erwarteFehler(_Platz sender, Map<String, Object?> c, String key) async {
  try {
    await sender.verb.befehl(c);
  } on AbendFehler catch (e) {
    _require(e.key == key, 'Fehlerschlüssel ${e.key} statt $key für ${c['typ']}.');
    return;
  }
  throw StateError('Befehl ${c['typ']} wurde nicht abgelehnt (erwartet $key).');
}

/// Alle Gäste haben den Inhalt, den der Gastgeber für sie berechnet (ohne
/// `version`: Änderungen, die ein Gast nicht sieht, ändern seine Ansicht nicht).
/// Verlorene Ansichten heilt der Ping über die Versionsmeldung.
Future<void> _konvergenz(_Platz host, List<_Platz> plaetze, {required Duration timeout}) async {
  String ohneVersion(Map<String, Object?> v) => jsonEncode(Map<String, Object?>.of(v)..remove('version'));
  final raum = (host.verb as LokaleVerbindung).raum;
  bool gleich(_Platz p) {
    try {
      return p.inbox.isNotEmpty && ohneVersion(p.latest) == ohneVersion(raum.zustandFuer(p.pid));
    } on PartyRaumFehler {
      return false; // noch offline im Raum
    }
  }

  await _bis(() => plaetze.every(gleich) ? true : null,
      'Gäste haben die aktuelle Ansicht', timeout: timeout);
}

/// Netzabbruch beim Gastgeber: Der Socket reißt, verbindet sich neu, alle Themen
/// treten wieder bei, die Gäste bekommen frische Ansichten und spielen weiter.
Future<void> _hostNetzabbruch(RelayHost host, _Platz hostPlatz, List<_Platz> plaetze) async {
  _stage = 'Netzabbruch beim Gastgeber';
  _meldung(_stage);
  final vorher = host.zaehler!.wiederverbunden;
  host.kappeVerbindung();
  await _bis(() => host.zaehler!.wiederverbunden > vorher ? true : null, 'Gastgeber verbindet sich neu', timeout: const Duration(seconds: 40));
  await _bis(() => plaetze.every((p) => p.statusVerlauf.last == VerbindungsStatus.verbunden) ? true : null, 'Gäste wieder verbunden',
      timeout: const Duration(seconds: 40));
  await _konvergenz(hostPlatz, plaetze, timeout: const Duration(seconds: 40));
  await _erwarteFehler(plaetze[0], {'typ': 'bereit', 'wert': true}, 'game_running');
}

/// Absturz des Gastgebers und Wiederherstellung aus der Ablage (Schlüssel, Code,
/// Protokoll, neue Epoche): Die Gäste verbinden sich mit neuen Sitzungsschlüsseln
/// und behalten Rolle und Dossier.
Future<RelayHost> _hostNeustart(
  RelayHost alt,
  _Platz hostPlatz,
  List<_Platz> plaetze,
  SpeicherAblage ablage,
  RaumFabrik fabrik,
  RelayParameter relay, {
  required _Platz rolle,
}) async {
  final sitzVorher = jsonEncode([for (final t in _list(hostPlatz.latest['spieler'])) [t['id'], t['sitz']]]);
  _stage = 'Neustart des Gastgebers';
  final dossiers = [for (final p in plaetze) jsonEncode(_map(p.latest['privat'])['dossier'])];
  final ids = [for (final p in plaetze) p.pid];
  final code = alt.raumCode;
  _meldung('Gastgeber wird beendet (Absturz)');
  await alt.schliessen(endgueltig: false, gaesteBenachrichtigen: false);
  _meldung('Gastgeber weg, warte auf Pause der Gäste (${[for (final p in plaetze) p.statusVerlauf.last.name]})');
  await _bis(() => plaetze.every((p) => p.statusVerlauf.last == VerbindungsStatus.pausiert) ? true : null, 'Gäste bemerken die Abwesenheit des Gastgebers',
      timeout: const Duration(seconds: 60));
  _meldung('Gäste pausiert, stelle wieder her');
  final neu = await RelayHost.wiederherstellen(ablage: ablage, fabrik: fabrik, relay: relay, log: _logFuer('Gastgeber2'));
  _require(neu != null, 'Wiederherstellung lieferte nichts.');
  _require(neu!.raumCode == code && neu.epoch == alt.epoch + 1 && neu.hostId == 'host', 'Wiederhergestellter Gastgeber hat andere Kennwerte.');
  hostPlatz.ersetze(neu.lokaleVerbindung('host', 'Gastgeber'));
  await neu.starten();
  _meldung('Gastgeber neu gestartet, warte auf Gäste');
  await _bis(() => plaetze.every((p) => p.statusVerlauf.last == VerbindungsStatus.verbunden) ? true : null, 'Gäste wieder verbunden nach Neustart',
      timeout: const Duration(seconds: 60));
  await _konvergenz(hostPlatz, plaetze, timeout: const Duration(seconds: 40));
  for (var i = 0; i < plaetze.length; i++) {
    _require(plaetze[i].pid == ids[i], 'Spieler-ID änderte sich beim Neustart des Gastgebers.');
    _require(jsonEncode(_map(plaetze[i].latest['privat'])['dossier']) == dossiers[i], 'Dossier änderte sich beim Neustart des Gastgebers.');
  }
  // Die Sitze kommen aus Meta und Protokoll zurück (Erzähler, Detektiv, Rollen).
  _require(jsonEncode([for (final t in _list(hostPlatz.latest['spieler'])) [t['id'], t['sitz']]]) == sitzVorher, 'Sitze änderten sich beim Neustart des Gastgebers.');
  await _erwarteFehler(rolle, {'typ': 'weiter'}, 'not_host');
  return neu;
}

/// Netzabbruch eines Gastes mitten in der Runde: Der Socket wird vom Relais
/// gekappt, der Gast verbindet sich von selbst neu und behält seine Rolle.
Future<void> _netzabbruch(PhoenixAttrappe attrappe, String code, _Platz p, _Platz host) async {
  _stage = 'Netzabbruch ${p.name}';
  _meldung(_stage);
  final gast = p.verb as RelayGast;
  final rolleVorher = jsonEncode(_map(p.latest['privat'])['dossier']);
  final idVorher = p.pid;
  final verlaufVorher = p.statusVerlauf.length;
  final gekappt = await attrappe.trenneBeiPresenceKey(sitzThema(code, gast.cid), gast.cid);
  _require(gekappt == 1, 'Genau eine Verbindung sollte gekappt werden ($gekappt).');
  await _bis(() => p.statusVerlauf.length > verlaufVorher && p.statusVerlauf.skip(verlaufVorher).contains(VerbindungsStatus.getrennt) ? true : null,
      'Status getrennt', timeout: const Duration(seconds: 10));
  await _bis(() => p.statusVerlauf.last == VerbindungsStatus.verbunden ? true : null, 'Status verbunden nach Netzabbruch', timeout: const Duration(seconds: 40));
  _require(p.pid == idVorher, 'Spieler-ID änderte sich nach Netzabbruch.');
  // Der Gast bekommt seine Ansicht neu und behält die Rolle.
  await _bis(() => jsonEncode(_map(p.latest['privat'])['dossier']) == rolleVorher ? true : null, 'Dossier nach Netzabbruch');
  // Der Befehlsweg funktioniert wieder (eine Ablehnung des Raums beweist, dass der Gastgeber antwortet).
  await _erwarteFehler(p, {'typ': 'bereit', 'wert': true}, 'game_running');
  final spieler = _list(host.latest['spieler']).firstWhere((s) => s['id'] == p.pid);
  _require(spieler['online'] == true, 'Gastgeber sieht den Gast nach dem Netzabbruch nicht als online.');
}

/// App-Neustart: Der Gast schließt ohne abzumelden und tritt mit demselben
/// gespeicherten Schlüssel erneut bei (Wiederverbindungs-Token).
Future<void> _appNeustart(_Platz p, List<RelayGast> gaeste, List<SpeicherAblage> ablagen, RelayParameter relay, String code, int index, _Platz host) async {
  _stage = 'App-Neustart ${p.name}';
  _meldung(_stage);
  final alt = p.verb as RelayGast;
  final rolleVorher = jsonEncode(_map(p.latest['privat'])['dossier']);
  final idVorher = p.pid;
  await alt.trennen();
  await _bis(() => _list(host.latest['spieler']).firstWhere((s) => s['id'] == idVorher)['online'] == false ? true : null, 'Gast als offline erkannt',
      timeout: const Duration(seconds: 40));
  final neu = await RelayGast.beitreten(
    code: code,
    name: p.name,
    ablage: ablagen[index],
    relay: relay,
    app: 'matrix',
    inhalt: 'matrix',
    pingIntervall: const Duration(seconds: 5),
  );
  gaeste[index] = neu;
  p.ersetze(neu);
  _require(neu.spielerId == idVorher, 'App-Neustart: andere Spieler-ID.');
  await _bis(() => p.inbox.isNotEmpty && p.latest['phase'] == 'gruppenwahl' ? true : null, 'Ansicht nach App-Neustart');
  _require(jsonEncode(_map(p.latest['privat'])['dossier']) == rolleVorher, 'App-Neustart: Rolle oder Dossier hat sich geändert.');
  await _bis(() => _list(host.latest['spieler']).firstWhere((s) => s['id'] == idVorher)['online'] == true ? true : null, 'Gast wieder online');
}

/// Ausfall des Gast-Detektivs über das Relais (Nachschliff M3, A-062): Host =
/// Erzähler, Gast1 = Detektiv mit Klasse, Gast2 und Gast3 spielen Figuren. Ist Gast1
/// getrennt, nimmt der Raum Gast2 nicht an (eine Figur übernimmt nie); der Gastgeber
/// übernimmt den Sitz selbst (`detektivNeu`), Gast1 bekommt den Erzähler-Sitz, die
/// Klasse bleibt beim Sitz. Nach einem Absturz des Gastgebers spielt das Protokoll
/// denselben Sitzplan ein; Gast1 kommt mit seinem Schlüssel zurück, liest als
/// Erzähler vor und führt weiter. Kein Dossier wechselt den Platz.
Future<void> _detektivAusfall({required RelayParameter relay, required Kanon kanon, required Texte texte}) async {
  _stage = 'Detektiv-Ausfall: Gastgeber';
  final zufall = Random.secure();
  final salz = [for (var i = 0; i < 32; i++) zufall.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
  final fallCode = FallCode.zufall(Rng(zufall.nextInt(1 << 32)));
  final hostAblage = SpeicherAblage();
  AbendRaum fabrik(String code, Map<String, Object?> meta) => SchlosskellerRaum(
        raumCode: code,
        kanon: kanon,
        texte: texte,
        fallCode: FallCode.lesen(meta['fallCode'] as String)!,
        salz: meta['salz'] as String,
        festerGastgeber: true,
        gastgeberSitz: Sitz.lesen(meta['sitz']) ?? Sitz.detektiv,
      );
  var host = await RelayHost.neu(
    fabrik: fabrik,
    meta: {'salz': salz, 'fallCode': fallCode.code, 'sitz': 'erzaehler'},
    relay: relay,
    akte: 'schlosskeller',
    inhalt: 'matrix',
    ablage: hostAblage,
    log: _logFuer('Gastgeber'),
  );
  final code = host.raumCode;
  final hostPlatz = _Platz('Gastgeber', host.lokaleVerbindung('host', 'Gastgeber'));
  await host.starten();
  final gaeste = <RelayGast>[];
  final plaetze = <_Platz>[];
  final ablagen = <SpeicherAblage>[];
  try {
    for (var i = 0; i < 3; i++) {
      final ablage = SpeicherAblage();
      ablagen.add(ablage);
      final g = await RelayGast.beitreten(
          code: code, name: 'Gast${i + 1}', ablage: ablage, relay: relay, app: 'matrix', inhalt: 'matrix', pingIntervall: const Duration(seconds: 5));
      gaeste.add(g);
      plaetze.add(_Platz('Gast${i + 1}', g));
    }
    for (final p in plaetze) {
      await _bis(() => p.inbox.isEmpty ? null : true, 'erste Ansicht ${p.name}');
    }
    final alt = plaetze[0], neu = plaetze[1];
    await _befehl(hostPlatz, hostPlatz, 'sitz', {'spieler': alt.pid, 'sitz': 'detektiv'});
    await _befehl(hostPlatz, alt, 'sitz', {'spieler': alt.pid, 'sitz': 'detektiv', 'klasse': 'journalist'});
    for (final p in [hostPlatz, ...plaetze]) {
      await _bereit(hostPlatz, p);
    }
    await _befehl(hostPlatz, hostPlatz, 'start', {'rollen': 4});
    final figuren = plaetze.skip(1).toList();
    for (final p in figuren) {
      await _bis(() => _map(p.latest['privat'])['dossier'] is Map ? true : null, 'Rolle für ${p.name}');
    }
    final dossiers = {for (final p in figuren) p.pid: jsonEncode(_map(p.latest['privat'])['dossier'])};

    _stage = 'Detektiv-Ausfall: Rechte';
    await _erwarteFehler(hostPlatz, {'typ': 'detektivNeu', 'spieler': hostPlatz.pid}, 'invalid');
    await _erwarteFehler(neu, {'typ': 'detektivNeu', 'spieler': neu.pid}, 'not_host');

    _stage = 'Detektiv-Ausfall: Gast1 getrennt';
    await (alt.verb as RelayGast).trennen();
    await _bis(() => _list(hostPlatz.latest['spieler']).firstWhere((s) => s['id'] == alt.pid)['online'] == false ? true : null, 'Detektiv als offline erkannt',
        timeout: const Duration(seconds: 40));
    for (final p in figuren) {
      await _erwarteFehler(hostPlatz, {'typ': 'detektivNeu', 'spieler': p.pid}, 'invalid');
    }
    await _befehl(hostPlatz, hostPlatz, 'detektivNeu', {'spieler': hostPlatz.pid});
    final privatHost = _map(hostPlatz.latest['privat']);
    _require(privatHost['detektiv'] == true && privatHost['klasse'] == 'journalist', 'Der Gastgeber ermittelt nicht oder ohne die Klasse des Sitzes.');
    final sitze = jsonEncode([for (final t in _list(hostPlatz.latest['spieler'])) [t['id'], t['sitz']]]);
    _require(sitze == jsonEncode([[hostPlatz.pid, 'detektiv'], [alt.pid, 'erzaehler'], [neu.pid, 'rolle'], [plaetze[2].pid, 'rolle']]),
        'Die Sitze wurden nicht getauscht.');

    _stage = 'Detektiv-Ausfall: Neustart des Gastgebers';
    await host.schliessen(endgueltig: false, gaesteBenachrichtigen: false);
    final verbunden = plaetze.skip(1).toList();
    await _bis(() => verbunden.every((p) => p.statusVerlauf.last == VerbindungsStatus.pausiert) ? true : null, 'Gäste bemerken den Absturz',
        timeout: const Duration(seconds: 60));
    final wieder = await RelayHost.wiederherstellen(ablage: hostAblage, fabrik: fabrik, relay: relay, log: _logFuer('Gastgeber2'));
    _require(wieder != null, 'Wiederherstellung lieferte nichts.');
    host = wieder!;
    hostPlatz.ersetze(host.lokaleVerbindung('host', 'Gastgeber'));
    await host.starten();
    await _bis(() => verbunden.every((p) => p.statusVerlauf.last == VerbindungsStatus.verbunden) ? true : null, 'Gäste nach dem Neustart',
        timeout: const Duration(seconds: 60));
    await _konvergenz(hostPlatz, verbunden, timeout: const Duration(seconds: 40));
    _require(jsonEncode([for (final t in _list(hostPlatz.latest['spieler'])) [t['id'], t['sitz']]]) == sitze, 'Sitze änderten sich beim Neustart nach dem Wechsel.');

    _stage = 'Detektiv-Ausfall: Rückkehr von Gast1';
    final zurueck = await RelayGast.beitreten(
        code: code, name: alt.name, ablage: ablagen[0], relay: relay, app: 'matrix', inhalt: 'matrix', pingIntervall: const Duration(seconds: 5));
    gaeste[0] = zurueck;
    alt.ersetze(zurueck);
    _require(zurueck.spielerId == alt.pid, 'Rückkehr: andere Spieler-ID.');
    await _bis(() => _list(alt.latest['spieler']).firstWhere((s) => s['id'] == alt.pid)['sitz'] == 'erzaehler' ? true : null, 'Gast1 sitzt auf dem Erzähler-Sitz');
    final privat1 = _map(alt.latest['privat']);
    _require(privat1['detektiv'] == false && !privat1.containsKey('rolle') && !privat1.containsKey('dossier') && !privat1.containsKey('klasse'),
        'Gast1 sitzt nicht ohne Figur auf dem Erzähler-Sitz.');
    await _erwarteFehler(alt, {'typ': 'fundGelesen'}, 'not_detective');
    for (final p in figuren) {
      if (_map(p.latest['privat'])['gelesen'] == false) await _befehl(hostPlatz, p, 'rollenGelesen');
    }
    // Gast1 ist verbunden und leitet als Erzähler, nicht mehr der Gastgeber.
    await _erwarteFehler(hostPlatz, {'typ': 'weiter'}, 'not_host');
    await _befehl(hostPlatz, alt, 'weiter');
    _require(hostPlatz.latest['phase'] == 'intro', 'Nach dem Wechsel geht der Abend nicht weiter.');
    await _bis(() => (_map(alt.latest['privat'])['erzaehler'] as List?)?.isNotEmpty == true ? true : null, 'Gast1 liest die Einleitung vor');
    await _konvergenz(hostPlatz, plaetze, timeout: const Duration(seconds: 40));
    for (final p in plaetze) {
      for (final v in p.inbox) {
        _require(v.keys.every(raumOeffentlicheSchluessel.contains), 'Detektiv-Ausfall: nicht freigegebenes Feld bei ${p.name}.');
        final privat = _map(v['privat']);
        if (p == alt) {
          _require(!privat.containsKey('rolle') && !privat.containsKey('dossier'), 'Detektiv-Ausfall: Dossier an ${p.name}.');
        } else {
          _require(!privat.containsKey('erzaehler') && !privat.containsKey('erzaehlerPaket'), 'Detektiv-Ausfall: Erzähltext an ${p.name}.');
          if (privat['dossier'] != null) _require(jsonEncode(privat['dossier']) == dossiers[p.pid], 'Detektiv-Ausfall: Ein Dossier hat den Platz gewechselt.');
        }
      }
    }
    print('RELAIS-ONLINE OK · Ausfall des Gast-Detektivs · keine Figur übernimmt, der Gastgeber ermittelt selbst, Klasse beim Sitz, '
        'Neustart mit demselben Sitzplan, Rückkehr als Erzähler, Dossiers am Platz');
  } finally {
    for (final g in gaeste) {
      try {
        await g.trennen();
      } catch (_) {}
    }
    try {
      await host.schliessen();
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

Future<void> main(List<String> args) async {
  var lokal = false;
  List<int> zahlen = [4];
  String? url, key;
  PhoenixAttrappe? attrappe;
  try {
    for (final arg in args) {
      if (arg == '--lokal') {
        lokal = true;
      } else if (arg.startsWith('--clients=')) {
        zahlen = [for (final z in arg.substring(10).split(',')) int.parse(z.trim())];
      } else if (arg.startsWith('--url=')) {
        url = arg.substring(6);
      } else if (arg.startsWith('--key=')) {
        key = arg.substring(6);
      } else if (arg == '--erzwinge') {
        _erzwinge = true;
      } else if (arg == '--diagnose') {
        _diagnose = true;
      } else if (arg == '--hilfe' || arg == '-h') {
        print('Aufruf: relay_matrix.dart [--lokal] [--clients=4,8] [--url=https://…] [--key=…] [--diagnose] [--erzwinge]');
        return;
      } else {
        throw StateError('Unbekannte Option: $arg (siehe --hilfe).');
      }
    }
    _require(zahlen.every((z) => z >= 1 && z <= 20), 'Clientzahl muss zwischen 1 und 20 liegen.');
    final proxy = Platform.environment['HTTPS_PROXY'] ?? Platform.environment['https_proxy'];
    if (proxy != null && proxy.isNotEmpty) HttpOverrides.global = _ProxyOverrides();

    final partyDir = resolvePartyDir(null);
    Map<String, Object?> lesen(String p) => (jsonDecode(File('$partyDir/$p').readAsStringSync()) as Map).cast<String, Object?>();
    final kanon = Kanon.lade(lesen);
    final texte = Texte(kanon, Textsammlung.lade(lesen));

    final RelayParameter relay;
    if (lokal) {
      attrappe = await PhoenixAttrappe.starten(limitErzwingen: _erzwinge);
      relay = RelayParameter(url: attrappe.url, schluessel: attrappe.schluessel);
      print('RELAIS-MATRIX · lokale Attrappe ${attrappe.url}');
    } else {
      relay = RelayParameter(url: url ?? relayUrl, schluessel: key ?? relaySchluessel);
      print('RELAIS-MATRIX · live ${Uri.parse(relay.url).host}');
    }
    var laeufe = 0;
    for (final n in zahlen) {
      for (final k in _konstellationen) {
        // Ein Gast mit Sitz braucht daneben mindestens einen Gast mit Figur.
        if (k.gastSitz != null && n < 2) continue;
        attrappe?.zaehlerZuruecksetzen();
        _fenster.clear();
        final t = Stopwatch()..start();
        await _lauf(n: n, relay: relay, attrappe: attrappe, kanon: kanon, texte: texte, k: k)
            .timeout(const Duration(minutes: 8), onTimeout: () => throw StateError('Zeitüberschreitung des ganzen Laufs'));
        laeufe++;
        print('  ($n Gäste, ${k.name}: ${t.elapsed.inSeconds} s)');
      }
    }
    // Fällt der Gast-Detektiv aus, vergibt der Gastgeber den Sitz neu (Nachschliff M3).
    await _detektivAusfall(relay: relay, kanon: kanon, texte: texte)
        .timeout(const Duration(minutes: 4), onTimeout: () => throw StateError('Zeitüberschreitung beim Ausfall des Gast-Detektivs'));
    print('RELAIS-MATRIX GRÜN · ${zahlen.length}/${zahlen.length} Laststufen (${zahlen.join(', ')} Gäste) · $laeufe Läufe mit Sitz-Konstellationen · Ausfall des Gast-Detektivs');
  } catch (error) {
    // Keine Rohpakete, Schlüssel, Dossiers oder Zugangsdaten ausgeben.
    final detail = error is StateError ? error.message : '${error.runtimeType}: $error';
    stderr.writeln('RELAIS-MATRIX ROT · $detail (Schritt: $_stage)');
    exitCode = 1;
  } finally {
    await attrappe?.schliessen();
  }
  // Offene Timer/Sockets dürfen den Prozess nicht festhalten.
  exit(exitCode);
}
