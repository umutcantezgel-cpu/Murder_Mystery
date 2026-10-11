/// Ein Gast im Relais-Spiel: klopft in der Lobby, leitet mit dem Turm des
/// Gastgebers die Sitzungsschlüssel ab und spielt danach nur noch über sein
/// eigenes, verschlüsseltes Sitz-Thema.
// ignore_for_file: prefer_initializing_formals
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'ablage.dart';
import 'krypto.dart';
import 'phoenix.dart';
import 'protokoll.dart';
import 'relay_standard.dart';
import 'umschlag.dart';
import 'verbindung.dart';

/// Was der Gastgeber im Turm ausruft (Klartext, ungeprüft außer der Codebindung).
class RelayTurmInfo {
  const RelayTurmInfo({required this.akte, required this.inhalt, required this.offen, required this.plaetze, required this.epoch});
  final String akte;
  final String inhalt;
  final bool offen;
  final int plaetze;
  final int epoch;
}

class RelayGast implements AbendVerbindung {
  RelayGast._({
    required this.raumCode,
    required String name,
    required Ablage ablage,
    required this.relay,
    required Schluesselpaar schluessel,
    required this.app,
    required this.inhalt,
    required this.pingIntervall,
    required this.pongFrist,
    required this.befehlWiederholung,
    required this.maxVersuche,
    required this.knopfIntervall,
    required Random zufall,
    required this.log,
  })  : _name = name,
        _ablage = ablage,
        _schluessel = schluessel,
        _cid = schluessel.cid,
        _zufall = zufall {
    _startN = DateTime.now().millisecondsSinceEpoch;
    _q = _startN;
  }

  /// Schlüssel in der [Ablage] für den Raum [code].
  static String ablageSchluesselFuer(String code) => 'mordakte.relay.gast.$code';

  /// Tritt dem Raum [code] bei und wartet auf die erste Ansicht. Ein vorhandener
  /// Schlüssel in [ablage] ist das Wiederverbindungs-Token: gleicher Spieler,
  /// gleiche Rolle. Wirft [AbendFehler] mit `code` (ungültiger Code), `relay`
  /// (nicht erreichbar), `kein_raum` (Gastgeber nicht gefunden), `zeitueberschreitung`
  /// oder dem Grund der Ablehnung (`voll`, `gestartet`, `proto`, `inhalt`).
  static Future<RelayGast> beitreten({
    required String code,
    required String name,
    required Ablage ablage,
    RelayParameter relay = const RelayParameter(),
    String app = '',
    String inhalt = '',
    Duration timeout = const Duration(seconds: 25),
    Duration pingIntervall = const Duration(seconds: 20),
    Duration pongFrist = const Duration(seconds: 8),
    Duration befehlWiederholung = const Duration(seconds: 2),
    int maxVersuche = 5,
    Duration knopfIntervall = const Duration(seconds: 3),
    Random? zufall,
    void Function(String)? log,
  }) async {
    final c = RaumCode.lesen(code);
    if (c == null) throw const AbendFehler('code');
    final z = zufall ?? Random.secure();
    final schluessel = await _schluesselLaden(ablage, c, name, z);
    final g = RelayGast._(
      raumCode: c,
      name: name,
      ablage: ablage,
      relay: relay,
      schluessel: schluessel,
      app: app,
      inhalt: inhalt,
      pingIntervall: pingIntervall,
      pongFrist: pongFrist,
      befehlWiederholung: befehlWiederholung,
      maxVersuche: maxVersuche,
      knopfIntervall: knopfIntervall,
      zufall: z,
      log: log,
    );
    try {
      await g._start(timeout);
    } catch (_) {
      await g._schliesse('abbruch');
      rethrow;
    }
    return g;
  }

  static Future<Schluesselpaar> _schluesselLaden(Ablage ablage, String code, String name, Random zufall) async {
    final key = ablageSchluesselFuer(code);
    try {
      final roh = await ablage.lesen(key);
      if (roh != null) {
        final d = (jsonDecode(roh) as Map).cast<String, Object?>();
        final priv = unB64(d['priv']);
        if (priv != null && priv.length == 32) {
          final paar = await Schluesselpaar.ausGeheimnis(priv);
          if (paar.cid == d['cid']) {
            await ablage.schreiben(key, jsonEncode({...d, 'name': name}));
            return paar;
          }
        }
      }
    } catch (_) {
      // Unbrauchbarer Eintrag: neuer Schlüssel.
    }
    final paar = await Schluesselpaar.erzeugen(zufall);
    await ablage.schreiben(key, jsonEncode({'v': 1, 'cid': paar.cid, 'priv': b64(paar.geheim), 'name': name}));
    return paar;
  }

  @override
  final String raumCode;
  final RelayParameter relay;
  final String app;
  final String inhalt;
  final Duration pingIntervall;
  final Duration pongFrist;
  final Duration befehlWiederholung;
  final int maxVersuche;
  final Duration knopfIntervall;
  final void Function(String)? log;

  final String _name;
  final Ablage _ablage;
  final Schluesselpaar _schluessel;
  final String _cid;
  final Random _zufall;

  late final int _startN;
  late int _q;

  late final PhoenixSocket _socket;
  PhoenixKanal? _sitz;
  PhoenixKanal? _lobby;
  UmschlagPaar? _paar;
  Uint8List? _hostPub;
  int? _epoch;
  String? _r;
  String? _ableitungFuer;
  int _gen = 0;
  bool _aktiv = false;
  bool _hostDa = false;
  bool _stumm = false;
  bool _warWillkommen = false;
  DateTime _letzterTurm = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _klopfAb = DateTime.fromMillisecondsSinceEpoch(0);

  /// Der Gastgeber war (laut Presence) weg und hat sich seither nicht beglaubigt
  /// gemeldet: Ein Turm mit neuer Epoche darf dann die Schlüssel erneuern.
  bool _hostWarWeg = false;
  bool _geschlossen = false;
  int _halloVersuche = 0;
  int _version = -1;
  DateTime _letzterKontakt = DateTime.now();
  Timer? _tickTimer;
  Timer? _pingTimer;
  final List<StreamSubscription<Object?>> _subs = [];
  final List<Map<String, Object?>> _frueh = [];
  final Map<int, Completer<String?>> _offen = {};
  final Reihe _befehlReihe = Reihe();
  final Completer<void> _erste = Completer<void>();
  final LetzterWert<Map<String, Object?>> _ansichten = LetzterWert<Map<String, Object?>>();
  final LetzterWert<VerbindungsStatus> _status = LetzterWert<VerbindungsStatus>(VerbindungsStatus.verbinde);
  RelayTurmInfo? _turmInfo;

  /// Verworfene Umschläge und Turm-Ausrufe (ungültig, gefälscht, wiederholt, falscher Absender).
  int verworfen = 0;

  /// Eigene Kennung (Teil der Spieler-ID).
  String get cid => _cid;

  /// Der zuletzt gehörte Turm des Gastgebers.
  RelayTurmInfo? get turm => _turmInfo;

  /// Zähler des Sockets (Ereignisse/s messen).
  PhoenixZaehler get zaehler => _socket.zaehler;

  @override
  String? get spielerId => spielerIdVon(_cid);

  @override
  Stream<Map<String, Object?>> get ansichten => _ansichten.strom;

  @override
  Stream<VerbindungsStatus> get status => _status.strom;

  /// Die letzte angenommene Ansicht.
  Map<String, Object?>? get letzteAnsicht => _ansichten.wert;

  // ---------------------------------------------------------------- Aufbau

  Future<void> _start(Duration timeout) async {
    final ende = DateTime.now().add(timeout);
    _socket = PhoenixSocket(relay.socketUri, fabrik: relay.kanalFabrik, log: log);
    _subs.add(_socket.status.listen((_) => _statusNeu()));
    try {
      await _socket.verbinde(timeout: timeout);
    } on PhoenixFehler {
      throw const AbendFehler('relay');
    }
    final sitz = _sitz = _socket.kanal(sitzThema(raumCode, _cid), presenceKey: _cid);
    var warDa = false;
    _subs.add(sitz.nachrichten.listen(_sitzNachricht));
    _subs.add(sitz.praesenz.listen((k) {
      final da = k.contains(hostPresenceKey);
      if (_hostDa && !da && _aktiv) _hostWarWeg = true;
      _hostDa = da;
      _statusNeu();
      _pruefeLobby();
    }));
    _subs.add(sitz.status.listen((s) {
      if (s == KanalStatus.beigetreten) {
        if (warDa) {
          // Nach einem Abbruch wieder da: Sitzung frisch bestätigen lassen.
          _aktiv = false;
          _r = null;
          _halloVersuche = 0;
          _sendeHallo();
        }
        warDa = true;
      }
      _statusNeu();
    }));
    try {
      await sitz.beitreten(timeout: timeout);
    } on PhoenixFehler {
      throw const AbendFehler('relay');
    }
    sitz.track({'c': 1});
    _tickTimer = Timer.periodic(knopfIntervall, (_) => _tick());
    _pingTimer = Timer.periodic(pingIntervall, (_) => _ping());
    _pruefeLobby();
    final rest = ende.difference(DateTime.now());
    try {
      await _erste.future.timeout(rest.isNegative ? const Duration(seconds: 1) : rest);
    } on TimeoutException {
      throw AbendFehler(_paar == null ? 'kein_raum' : 'zeitueberschreitung');
    }
  }

  // ----------------------------------------------------------------- Lobby

  /// Die Lobby wird nur gebraucht, solange noch kein Schlüssel da ist, der
  /// Gastgeber verstummt oder weg ist oder das Hallo unbeantwortet bleibt;
  /// sonst bekäme jeder Gast jedes Klopfen und jeden Turm aller anderen.
  bool get _lobbyBedarf => !_geschlossen && (_paar == null || _stumm || (_aktiv ? (!_hostDa || _hostWarWeg) : _halloVersuche >= 2));

  void _pruefeLobby() {
    if (_geschlossen) return;
    if (_lobbyBedarf) {
      if (_lobby == null) _lobbyOeffnen();
    } else {
      final l = _lobby;
      if (l != null) {
        _lobby = null;
        unawaited(l.verlassen());
      }
    }
  }

  void _lobbyOeffnen() {
    // Kehrt ein bekannter Gastgeber nur zurück (Netzabbruch, Neustart), ruft er
    // beim Start selbst einen Turm aus: Dann wartet das Klopfen erst einmal ab.
    final jetzt = DateTime.now();
    _klopfAb = _warWillkommen ? jetzt.add(Duration(milliseconds: 5000 + _zufall.nextInt(3000))) : jetzt;
    final l = _lobby = _socket.kanal(lobbyThema(raumCode), presenceKey: _cid);
    _subs.add(l.nachrichten.listen((m) {
      if (m.ereignis == 'turm') {
        unawaited(_turm(m.payload).catchError((Object e) {
          log?.call('Turm: $e');
        }));
      }
    }));
    _subs.add(l.status.listen((s) {
      if (s == KanalStatus.beigetreten) {
        // Kleine Zufallspause: Viele Gäste, die gleichzeitig klopfen, würden
        // einander die Klopfzeichen zustellen (jedes Klopfen erreicht alle in der Lobby).
        Timer(Duration(milliseconds: _zufall.nextInt(600)), () {
          if (!(_paar != null && _turmFrisch)) _klopfen();
        });
      }
    }));
    unawaited(l.beitreten().catchError((Object _) {}));
  }

  /// Ein Turm der letzten Sekunden macht weiteres Klopfen überflüssig (jedes
  /// Klopfen wird allen in der Lobby zugestellt und löst einen neuen Turm aus).
  ///
  /// Nur nach einem früheren Willkommen: Ein neuer Gast muss selbst klopfen,
  /// denn der frische Turm kann die Antwort auf das Klopfen eines anderen sein.
  bool get _turmFrisch => _warWillkommen && _halloVersuche < 2 && DateTime.now().difference(_letzterTurm) < const Duration(seconds: 7);

  void _klopfen() {
    final l = _lobby;
    if (_geschlossen || l == null || !l.beigetreten || DateTime.now().isBefore(_klopfAb)) return;
    l.sende('klopf', {
      'cid': _cid,
      'pub': b64(_schluessel.oeffentlich),
      'proto': protokollVersion,
      'app': app,
      'inhalt': inhalt,
    });
  }

  Future<void> _turm(Map<String, Object?> p) async {
    if (_geschlossen) return;
    final hpub = unB64(p['hpub']);
    final epoch = p['epoch'];
    // Der Gastgeberschlüssel muss zum Code hashen, sonst ist der Turm gefälscht.
    if (hpub == null || hpub.length != 32 || epoch is! int || !RaumCode.passt(raumCode, hpub)) {
      verworfen++;
      return;
    }
    _letzterTurm = DateTime.now();
    _turmInfo = RelayTurmInfo(
      akte: p['akte'] is String ? p['akte'] as String : '',
      inhalt: p['inhalt'] is String ? p['inhalt'] as String : '',
      offen: p['offen'] == true,
      plaetze: p['plaetze'] is int ? p['plaetze'] as int : 0,
      epoch: epoch,
    );
    if (p['proto'] != protokollVersion) {
      await _schliesse('proto');
      return;
    }
    final gleich = _hostPub != null && _epoch == epoch && b64(_hostPub!) == b64(hpub);
    if (gleich) return;
    // Eine laufende, bestätigte Sitzung wird nicht durch einen (unbeglaubigten)
    // Turm mit anderer Epoche abgelöst; ein echter Neustart des Gastgebers
    // macht ihn zuerst unerreichbar.
    if (_aktiv && !_stumm && !_hostWarWeg && _hostDa) return;
    final marke = '$epoch|${b64(hpub)}';
    if (_ableitungFuer == marke) return;
    _ableitungFuer = marke;
    final gen = ++_gen;
    final Sitzungsschluessel keys;
    try {
      keys = await Sitzungsschluessel.ableiten(
        eigen: _schluessel,
        fremdOeffentlich: hpub,
        code: raumCode,
        epoch: epoch,
        cid: _cid,
      );
    } on FormatException {
      verworfen++;
      return;
    }
    if (gen != _gen || _geschlossen) return;
    _hostPub = hpub;
    _epoch = epoch;
    _paar = UmschlagPaar(
      topic: sitzThema(raumCode, _cid),
      eigeneSeite: 'c',
      schluessel: keys,
      startN: max(_startN, _paar?.gesendetN ?? 0),
      zufall: _zufall,
    );
    _aktiv = false;
    _r = null;
    _halloVersuche = 0;
    final paar = _paar!;
    final frueh = List.of(_frueh);
    _frueh.clear();
    for (final e in frueh) {
      _oeffnen(paar, e);
    }
    _sendeHallo();
    _statusNeu();
  }

  // ---------------------------------------------------------------- Sitzung

  void _tick() {
    if (_geschlossen) return;
    _pruefeLobby();
    if (!_aktiv && _paar != null && _sitz?.beigetreten == true) {
      _halloVersuche++;
      if (_halloVersuche >= 4) {
        // Der Gastgeber antwortet nicht mit diesen Schlüsseln: neuen Turm holen.
        _paar = null;
        _hostPub = null;
        _epoch = null;
        _ableitungFuer = null;
      } else {
        _sendeHallo();
      }
    }
    if (_lobby != null) {
      final l = _lobby!;
      if (l.aktuellerStatus == KanalStatus.getrennt && _socket.offen) {
        unawaited(l.beitreten().catchError((Object _) {}));
      }
      if (!_turmFrisch && (_paar == null || _stumm || !_aktiv || !_hostDa || _hostWarWeg)) _klopfen();
    }
    _statusNeu();
  }

  void _sendeHallo() {
    final paar = _paar, sitz = _sitz;
    if (_geschlossen || paar == null || sitz == null || !sitz.beigetreten) return;
    final r = _r ??= b64(zufallsBytes(12, _zufall));
    unawaited(paar.senden(sitz, {'t': 'hallo', 'name': _name, 'proto': protokollVersion, 'app': app, 'r': r}));
  }

  void _ping() {
    final paar = _paar, sitz = _sitz;
    if (_geschlossen || !_aktiv || paar == null || sitz == null) return;
    if (DateTime.now().difference(_letzterKontakt) > pingIntervall * 2 + const Duration(seconds: 5)) {
      _stumm = true;
      _statusNeu();
      _pruefeLobby();
    }
    final gesendet = DateTime.now();
    unawaited(paar.senden(sitz, {'t': 'ping', 'v': max(_version, 0)}));
    // Der Gastgeber antwortet sofort mit Pong; bleibt es aus, ist er (neu) gestartet oder weg.
    Timer(pongFrist, () {
      if (_geschlossen || !_aktiv || _stumm) return;
      if (_letzterKontakt.isBefore(gesendet)) {
        _stumm = true;
        _statusNeu();
        _pruefeLobby();
      }
    });
  }

  void _sitzNachricht(PhoenixNachricht m) {
    if (_geschlossen || m.ereignis != sitzEreignis) return;
    final paar = _paar;
    if (paar == null) {
      // Der Gastgeber kann vor dem Turm schreiben; gleich nach der Ableitung auspacken.
      if (_frueh.length < 16) _frueh.add(m.payload);
      return;
    }
    _oeffnen(paar, m.payload);
  }

  void _oeffnen(UmschlagPaar paar, Map<String, Object?> payload) {
    unawaited(paar.oeffnen(payload).then((g) {
      if (g == null) {
        verworfen++;
        return;
      }
      if (!identical(paar, _paar) || _geschlossen) return;
      _hostNachricht(g);
    }).catchError((Object e) {
      log?.call('Umschlag: $e');
    }));
  }

  void _hostNachricht(Geoeffnet g) {
    final m = g.nachricht;
    final t = m['t'];
    if (t == 'willkommen') {
      if (_r != null && m['r'] == _r && m['spieler'] == spielerId && m['raum'] == raumCode && m['epoch'] == _epoch) {
        _aktiv = true;
        _warWillkommen = true;
        _stumm = false;
        _hostWarWeg = false;
        _version = -1; // Neue Sitzung: der Gastgeber ist die Wahrheit, auch nach einer Wiederherstellung.
        _paar?.empfangsUntergrenze(g.n);
        _kontakt();
        _statusNeu();
        _pruefeLobby();
      } else {
        verworfen++;
      }
      return;
    }
    if (!_aktiv) {
      // Vor dem Willkommen gilt nichts: sonst ließe sich Altes wiedereinspielen.
      verworfen++;
      return;
    }
    _kontakt();
    switch (t) {
      case 'abend':
        _ansicht(m);
      case 'ok':
        _antwort(m['q'], null);
      case 'fehler':
        _antwort(m['q'], m['key'] is String ? m['key'] as String : 'invalid');
      case 'zu':
        unawaited(_schliesse(m['grund'] is String ? m['grund'] as String : 'geschlossen'));
      case 'pong':
        break;
      case 'nein':
        log?.call('Abgelehnt: ${m['key']}');
    }
  }

  void _kontakt() {
    _letzterKontakt = DateTime.now();
    // Eine beglaubigte Nachricht beweist mehr als ein verlorener Presence-Diff.
    _hostDa = true;
    if (_stumm || _hostWarWeg) {
      _stumm = false;
      _hostWarWeg = false;
      _statusNeu();
      _pruefeLobby();
    }
  }

  void _ansicht(Map<String, Object?> m) {
    final v = m['version'];
    final privat = m['privat'];
    // Doppelt abgesichert: nur Ansichten dieses Raums und dieses Spielers.
    if (v is! int || privat is! Map || privat['spieler'] != spielerId || m['raum'] != raumCode) {
      verworfen++;
      return;
    }
    if (v <= _version) return;
    _version = v;
    _ansichten.add(m);
    if (!_erste.isCompleted) _erste.complete();
  }

  void _antwort(Object? q, String? key) {
    if (q is! int) return;
    final c = _offen[q];
    if (c != null && !c.isCompleted) c.complete(key);
  }

  void _statusNeu() {
    if (_geschlossen) return;
    final VerbindungsStatus s;
    if (!_socket.offen || _sitz?.beigetreten != true) {
      // Vor dem ersten Willkommen ist es noch der Aufbau, kein Abbruch.
      s = _warWillkommen ? VerbindungsStatus.getrennt : VerbindungsStatus.verbinde;
    } else if (!_aktiv) {
      s = VerbindungsStatus.verbinde;
    } else if (!_hostDa || _stumm || _hostWarWeg) {
      s = VerbindungsStatus.pausiert;
    } else {
      s = VerbindungsStatus.verbunden;
    }
    if (_status.wert != s) _status.add(s);
  }

  // ---------------------------------------------------------------- Befehle

  @override
  Future<void> befehl(Map<String, Object?> c) => _befehlReihe.einreihen(() => _befehl(c));

  Future<void> _befehl(Map<String, Object?> c) async {
    if (_geschlossen) throw const AbendFehler('geschlossen');
    final q = ++_q;
    final antwort = _offen[q] = Completer<String?>();
    try {
      for (var i = 0; i < maxVersuche; i++) {
        final paar = _paar, sitz = _sitz;
        if (_aktiv && paar != null && sitz != null) {
          await paar.senden(sitz, {'t': 'befehl', 'q': q, 'c': c});
        }
        try {
          final key = await antwort.future.timeout(befehlWiederholung);
          if (key != null) throw AbendFehler(key);
          return;
        } on TimeoutException {
          if (_geschlossen) throw const AbendFehler('geschlossen');
        }
      }
      if (_aktiv && !_geschlossen) {
        // Keine Antwort trotz Wiederholungen: Der Gastgeber ist vermutlich neu gestartet.
        _stumm = true;
        _statusNeu();
        _pruefeLobby();
      }
      throw AbendFehler(_aktiv ? 'zeitueberschreitung' : 'getrennt');
    } finally {
      _offen.remove(q);
    }
  }

  // ------------------------------------------------------------------- Ende

  /// Verlässt den Abend endgültig: Der Gastgeber nimmt den Platz aus dem Raum,
  /// der gespeicherte Schlüssel wird gelöscht.
  @override
  Future<void> verlassen() async {
    if (_geschlossen) return;
    final paar = _paar, sitz = _sitz;
    if (_aktiv && paar != null && sitz != null) {
      try {
        await paar.senden(sitz, {'t': 'tschuess'}).timeout(const Duration(seconds: 2));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      } catch (_) {}
    }
    try {
      await _ablage.loeschen(ablageSchluesselFuer(raumCode));
    } catch (_) {}
    await _schliesse('verlassen');
  }

  /// Trennt, ohne den Platz aufzugeben (App wird beendet, Gerät schläft): Mit
  /// dem gespeicherten Schlüssel kommt der Gast später in dieselbe Rolle zurück.
  Future<void> trennen() => _schliesse('getrennt');

  /// Testhilfe: kappt die Relais-Verbindung wie ein Netzabbruch.
  void kappeVerbindung() => _socket.kappe();

  Future<void> _schliesse(String grund) async {
    if (_geschlossen) return;
    _geschlossen = true;
    _tickTimer?.cancel();
    _pingTimer?.cancel();
    _status.add(VerbindungsStatus.geschlossen);
    for (final c in _offen.values) {
      if (!c.isCompleted) {
        c.future.ignore();
        c.completeError(AbendFehler(grund));
      }
    }
    if (!_erste.isCompleted) {
      _erste.future.ignore();
      _erste.completeError(AbendFehler(grund));
    }
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    _subs.clear();
    try {
      await _socket.schliessen();
    } catch (_) {}
    await _ansichten.schliessen();
    await _status.schliessen();
  }
}
