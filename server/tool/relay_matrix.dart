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
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/io.dart';
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:mordakte_server/party.dart' show resolvePartyDir;

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
}) async {
  final minRollen = kanon.besetzungJson['minRollen'] as int;
  final maxRollen = kanon.besetzungJson['maxRollen'] as int;
  final rollen = n.clamp(minRollen, maxRollen);
  final zufall = Random.secure();
  final salz = [for (var i = 0; i < 32; i++) zufall.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
  final fallCode = FallCode.zufall(Rng(zufall.nextInt(1 << 32)));

  _stage = 'Gastgeber ($n Gäste)';
  _meldung('Lauf mit $n Gästen beginnt');
  final hostAblage = SpeicherAblage();
  AbendRaum fabrik(String code, Map<String, Object?> meta) => SchlosskellerRaum(
        raumCode: code,
        kanon: kanon,
        texte: texte,
        fallCode: FallCode.lesen(meta['fallCode'] as String)!,
        salz: meta['salz'] as String,
        festerGastgeber: true,
      );
  var host = await RelayHost.neu(
    fabrik: fabrik,
    meta: {'salz': salz, 'fallCode': fallCode.code},
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
      await _bis(() => p.latest['phase'] == 'rollen' && _map(p.latest['privat'])['rolle'] != null ? true : null, 'Rolle für ${p.name}');
    }
    final rollenIds = plaetze.map((p) => _map(p.latest['privat'])['rolle'] as String).toList();
    _require(rollenIds.toSet().length == n, 'Rollen nicht eindeutig verteilt.');
    // Gäste sehen die Spielerliste mit Rollen anderer Spieler? Nur die Rollen-IDs, nie Dossiers.
    for (final p in plaetze) {
      final privat = _map(p.latest['privat']);
      _require(privat['spieler'] == p.pid && privat['dossier'] is Map, 'Gast ohne eigenes Dossier.');
    }

    // Fälschungsversuche über das Relais: feste Fehlerschlüssel.
    _stage = 'Fälschungsversuche';
    await _erwarteFehler(plaetze[0], {'typ': 'rollenGelesen', 'spieler': hostPlatz.pid}, 'invalid');
    await _erwarteFehler(plaetze[0], {'typ': 'weiter'}, 'not_host');
    await _erwarteFehler(plaetze[0], {'typ': 'start', 'rollen': 4}, 'not_host');
    await _erwarteFehler(plaetze[0], {'typ': 'gibmirdassalz'}, 'invalid');

    // Verlust im Relais: Befehle laufen trotzdem genau einmal.
    var gastBefehle = 0;
    final vorher = host.statistik.befehleAusgefuehrt + host.statistik.befehleAbgelehnt;
    if (attrappe != null) {
      _stage = 'Nachrichtenverlust';
      attrappe.stoerung.verlust = 0.15;
      attrappe.stoerung.verzoegerungMax = const Duration(milliseconds: 40);
    }
    await _imFenster('Verlust', () async {
      for (final p in plaetze) {
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
    await _befehl(hostPlatz, hostPlatz, 'weiter');

    var gefaelschterWurf = false;
    var neuverbindungA = false;
    var hostNetz = false;
    var hostNeustart = false;
    var neuverbindungB = false;
    var schritte = 0;
    while (hostPlatz.latest['phase'] != 'ende') {
      _require(++schritte < 500, 'Abend erreicht das Ende nicht.');
      final s = hostPlatz.latest;
      _stage = 'Phase ${s['phase']}';
      _meldung('Phase ${s['phase']} Runde ${s['runde']} v${s['version']}');
      switch (s['phase']) {
        case 'entscheidungen':
          if (!neuverbindungA && attrappe != null && s['entscheidung'] != null) {
            neuverbindungA = true;
            await _imFenster('Netzabbruch Gast', () => _netzabbruch(attrappe, code, plaetze[1], hostPlatz));
          }
          if (s['zug'] case final Map z) {
            switch (z['phase']) {
              case 'aktion':
                await _befehl(hostPlatz, hostPlatz, 'aktionFertig', {'aktion': z['aktion']});
              case 'wurf':
                final pate = [hostPlatz, ...plaetze].firstWhere((p) => p.pid == s['wuerfelPate']);
                if (!gefaelschterWurf) {
                  await _erwarteFehler(pate, {'typ': 'wurf', 'a': 6, 'b': 6}, 'invalid');
                  gefaelschterWurf = true;
                }
                if (z['id'] != 'auftakt') await _befehl(hostPlatz, pate, 'wuerfelHilfe', {'marke': false});
                await _befehl(hostPlatz, pate, 'wurf');
              case 'tischruf':
                await _befehl(hostPlatz, hostPlatz, 'tischruf', {'ruf': n.isEven ? 'nochmal' : 'umweg'});
              case 'fund':
                await _befehl(hostPlatz, hostPlatz, 'fundGelesen');
              default:
                throw StateError('Unbekannter Zugabschnitt.');
            }
          } else if (s['entscheidung'] case final Map e) {
            await _befehl(hostPlatz, hostPlatz, 'wahl', {'option': _list(e['optionen']).first['id']});
          } else {
            await _befehl(hostPlatz, hostPlatz, 'weiter');
          }
        case 'gruppenwahl':
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
          await _befehl(hostPlatz, hostPlatz, 'weiter');
        case 'intro':
          if (!hostNetz) {
            hostNetz = true;
            await _imFenster('Netzabbruch Gastgeber', () => _hostNetzabbruch(host, hostPlatz, plaetze));
          }
          await _befehl(hostPlatz, hostPlatz, 'weiter');
        case 'resuemee':
          if (!hostNeustart) {
            hostNeustart = true;
            host = await _imFenster('Neustart Gastgeber', () => _hostNeustart(host, hostPlatz, plaetze, hostAblage, fabrik, relay));
          }
          await _befehl(hostPlatz, hostPlatz, 'weiter');
        case 'anklage':
          await _befehl(hostPlatz, hostPlatz, 'anklage', {'person': (s['verdaechtige'] as List).first});
          await _befehl(hostPlatz, hostPlatz, 'weiter');
        case 'rollen':
          for (final p in plaetze) {
            if (_map(p.latest['privat'])['gelesen'] != true) await _befehl(hostPlatz, p, 'rollenGelesen');
          }
          await _befehl(hostPlatz, hostPlatz, 'weiter');
        default:
          await _befehl(hostPlatz, hostPlatz, 'weiter');
      }
    }
    _require(gefaelschterWurf, 'Manipulationsprüfung des Würfels wurde nicht erreicht.');
    _require(neuverbindungB, 'App-Neustart-Prüfung wurde nicht erreicht.');
    _require(hostNetz && hostNeustart, 'Gastgeber-Prüfungen (Netzabbruch, Neustart) wurden nicht erreicht.');
    _require(attrappe == null || neuverbindungA, 'Netzabbruch-Prüfung wurde nicht erreicht.');

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
    const erlaubt = {
      't', 'protokoll', 'version', 'spiel', 'akte', 'raum', 'host', 'phase', 'runde', 'wuerfelZusage', 'spieler', 'kannWeiter', 'rollen',
      'restMinuten', 'marken', 'erzaehler', 'notizbuch', 'wuerfe', 'wuerfelPate', 'gewaehlt', 'vorrat', 'abstecher', 'abstecherErgebnis',
      'entscheidung', 'zug', 'botGespraeche', 'verdaechtige', 'privat',
    };
    const geheim = {'pfad', 'fallCode', 'salz', 'seed', 'richtig', 'qualitaeten', 'aufloesung'};
    final dossiersAlle = <String, Map<String, Object?>>{
      for (final r in Besetzung(kanon).besetzt(rollen)) r: _dossierJson(texte, r, pfad, rollen),
    };
    var geprueft = 0;
    var ansichtenGesamt = 0;
    var verglichen = 0;
    final hostOhnePrivat = <Object?, String>{
      for (final v in hostPlatz.inbox) v['version']: jsonEncode(Map<String, Object?>.of(v)..remove('privat')),
    };
    for (final p in plaetze) {
      final eigeneRolle = rollenIds[plaetze.indexOf(p)];
      final eigenes = dossiersAlle[eigeneRolle]!;
      final eigeneTexte = _texte(eigenes);
      final fremdeTexte = <String>{
        for (final e in dossiersAlle.entries)
          if (e.key != eigeneRolle) ..._texte(e.value),
      }..removeAll(eigeneTexte);
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
    _require(geprueft >= n, 'Zu wenige Dossiers geprüft.');
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
    final gastText = [for (final v in plaetze.first.inbox) jsonEncode(v)].join('\n');
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
    print('RELAIS-ONLINE OK · $n Gäste + Gastgeber · $rollen Rollen · $ansichtenGesamt Gast-Ansichten geprüft, $geprueft Dossiers · '
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

Future<void> _bereit(_Platz host, _Platz wer) => _befehl(host, wer, 'bereit', {'wert': true});

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
  RelayParameter relay,
) async {
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
  await _erwarteFehler(plaetze[0], {'typ': 'weiter'}, 'not_host');
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
    for (final n in zahlen) {
      attrappe?.zaehlerZuruecksetzen();
      _fenster.clear();
      final t = Stopwatch()..start();
      await _lauf(n: n, relay: relay, attrappe: attrappe, kanon: kanon, texte: texte)
          .timeout(const Duration(minutes: 8), onTimeout: () => throw StateError('Zeitüberschreitung des ganzen Laufs'));
      print('  ($n Gäste: ${t.elapsed.inSeconds} s)');
    }
    print('RELAIS-MATRIX GRÜN · ${zahlen.length}/${zahlen.length} Laststufen (${zahlen.join(', ')} Gäste)');
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
