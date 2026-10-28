/// Der Gastgeber: Das Gerät, das den autoritativen [AbendRaum] hält, und
/// das Relais (Supabase Realtime) als reiner Zwischenträger. Der eigene Platz
/// des Gastgebers läuft lokal ([RelayHost.lokaleVerbindung]) und geht nie über das Netz.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:mordakte_core/runden.dart' show AbendRaum, PartyRaumFehler, ProtokollRaum, mitAbendzeit;

import 'ablage.dart';
import 'krypto.dart';
import 'lokal.dart';
import 'phoenix.dart';
import 'protokoll.dart';
import 'relay_standard.dart';
import 'umschlag.dart';
import 'verbindung.dart' show LetzterWert;

/// Baut einen frischen Raum für [raumCode]; [meta] sind die Geheimnisse des
/// Raums (z. B. Salz und Fall-Code), die der Gastgeber mit dem Protokoll
/// ablegt, damit ein Neustart denselben Abend wiederherstellt. Dazu die
/// Einstellungen des Abends, die den Raum formen: Sitz des Gastgebers,
/// Fassung (`fassung: lang`), Einstimmung (`einstimmung: true`, A-063) und
/// „Dein Moment“ (`einfluss: true`, Finale §3). Der Gastgeber reicht die Meta
/// unverändert durch, auch nach der Wiederherstellung; Gäste sehen sie nie, nur
/// die Ansicht des Raums (`einstimmung`, `einfluss`).
typedef RaumFabrik = AbendRaum Function(String raumCode, Map<String, Object?> meta);

/// Zähler für Messung und Fehlersuche.
class RelayHostStatistik {
  int klopfAkzeptiert = 0;
  int klopfAbgewiesen = 0;
  int klopfVerworfen = 0;
  int umschlaegeGesendet = 0;
  int umschlaegeEmpfangen = 0;
  int umschlaegeVerworfen = 0;
  int ansichtenGesendet = 0;
  int ansichtenUebersprungen = 0;
  int befehleAusgefuehrt = 0;
  int befehleWiederholt = 0;
  int befehleAbgelehnt = 0;
  int ratenVerzoegert = 0;
  int groessteAnsichtZeichen = 0;

  /// Höchste Zahl Umschläge in einem gleitenden 1-Sekunden-Fenster.
  int spitzeProSekunde = 0;
}

class _Sitz {
  _Sitz(this.cid, this.pub) : pid = spielerIdVon(cid);

  final String cid;
  final String pid;
  final Uint8List pub;
  PhoenixKanal? kanal;
  UmschlagPaar? paar;
  final Completer<bool> offen = Completer<bool>();
  bool angemeldet = false;
  bool online = false;
  bool sahPraesenz = false;
  bool warBeigetreten = false;
  bool zu = false;
  String? name;

  /// Zeitpunkt des letzten beglaubigten Umschlags dieses Gastes (die unbeglaubigte
  /// Presence allein beweist keine Anwesenheit).
  DateTime letzterUmschlag = DateTime.now();
  int? letzteQ;
  String? letzteAntwort; // null = ok, sonst Fehlerschlüssel
  String? letzterHash;
  int? gesendeteVersion;
  Timer? entprell;
  Timer? offlineTimer;
  Timer? graceTimer;
  Timer? anmeldeTimer;
  StreamSubscription<PhoenixNachricht>? subNachricht;
  StreamSubscription<Set<String>>? subPraesenz;
  StreamSubscription<KanalStatus>? subStatus;
  final Queue<int> eingang = Queue<int>();

  void timerStoppen() {
    entprell?.cancel();
    offlineTimer?.cancel();
    graceTimer?.cancel();
    anmeldeTimer?.cancel();
    entprell = offlineTimer = graceTimer = anmeldeTimer = null;
  }
}

class RelayHost {
  /// [raum] ist der autoritative Raum; ist er ein [ProtokollRaum], wird sein
  /// Protokoll mit abgelegt und der Abend ist wiederherstellbar. Sein
  /// `raumCode` muss zu [schluessel] gehören ([Schluesselpaar.raumCode]).
  RelayHost(
    this.raum, {
    required this.schluessel,
    this.relay = const RelayParameter(),
    this.akte = 'schlosskeller',
    this.inhalt = '',
    this.ablage,
    this.meta = const {},
    this.epoch = 1,
    this.offlineFrist = offlineFristStandard,
    this.umschlagFrist = umschlagFristStandard,
    this.entprellung = const Duration(milliseconds: 200),
    this.maxProSekunde = 30,
    this.maxSitze = 64,
    this.log,
    int Function()? abendzeit,
  }) : abendzeit = abendzeit ?? LokaleVerbindung.wanduhr {
    if (raum.raumCode != schluessel.raumCode) {
      throw ArgumentError('Der Raumcode ${raum.raumCode} gehört nicht zum Gastgeberschlüssel.');
    }
  }

  /// Erzeugt Schlüssel und Raum neu: der Code folgt aus dem Schlüssel, der Raum
  /// kommt aus [fabrik] (ohne [ProtokollRaum] wird er darin eingewickelt).
  /// Noch nicht gestartet ([starten]).
  static Future<RelayHost> neu({
    required RaumFabrik fabrik,
    Map<String, Object?> meta = const {},
    RelayParameter relay = const RelayParameter(),
    String akte = 'schlosskeller',
    String inhalt = '',
    Ablage? ablage,
    Duration offlineFrist = offlineFristStandard,
    Duration umschlagFrist = umschlagFristStandard,
    void Function(String)? log,
    int Function()? abendzeit,
  }) async {
    final schluessel = await Schluesselpaar.erzeugen();
    final raum = fabrik(schluessel.raumCode, meta);
    return RelayHost(
      raum is ProtokollRaum ? raum : ProtokollRaum(raum),
      schluessel: schluessel,
      relay: relay,
      akte: akte,
      inhalt: inhalt,
      ablage: ablage,
      meta: meta,
      offlineFrist: offlineFrist,
      umschlagFrist: umschlagFrist,
      log: log,
      abendzeit: abendzeit,
    );
  }

  /// Der Schlüssel, unter dem der Gastgeberzustand in der [Ablage] liegt.
  static const ablageSchluessel = 'mordakte.relay.host';

  /// Liest einen abgelegten Gastgeberzustand und baut daraus den Abend wieder
  /// auf: gleicher Schlüssel und Code, Raum aus [fabrik] mit dem gespeicherten
  /// Protokoll eingespielt, neue Epoche (alle Sitzungsschlüssel ändern sich).
  /// `null`, wenn nichts Brauchbares abgelegt ist. Danach [starten] aufrufen.
  static Future<RelayHost?> wiederherstellen({
    required Ablage ablage,
    required RaumFabrik fabrik,
    RelayParameter relay = const RelayParameter(),
    String? inhalt,
    Duration offlineFrist = offlineFristStandard,
    Duration umschlagFrist = umschlagFristStandard,
    void Function(String)? log,
    int Function()? abendzeit,
  }) async {
    final roh = await ablage.lesen(ablageSchluessel);
    if (roh == null) return null;
    try {
      final d = (jsonDecode(roh) as Map).cast<String, Object?>();
      if (d['v'] != 1) return null;
      final priv = unB64(d['hpriv']);
      if (priv == null || priv.length != 32) return null;
      final schluessel = await Schluesselpaar.ausGeheimnis(priv);
      final code = d['code'] as String;
      if (schluessel.raumCode != code) return null;
      final meta = ((d['meta'] as Map?) ?? const {}).cast<String, Object?>();
      final protokoll = [
        for (final e in (d['log'] as List? ?? const [])) (e as List).cast<Object?>().toList(),
      ];
      final raum = ProtokollRaum.wiederherstellen(protokoll, () => fabrik(code, meta));
      final host = RelayHost(
        raum,
        schluessel: schluessel,
        relay: relay,
        akte: d['akte'] as String? ?? 'schlosskeller',
        inhalt: inhalt ?? d['inhalt'] as String? ?? '',
        ablage: ablage,
        meta: meta,
        epoch: (d['epoch'] as int) + 1,
        offlineFrist: offlineFrist,
        umschlagFrist: umschlagFrist,
        log: log,
        abendzeit: abendzeit,
      );
      final hostId = d['hostId'];
      if (hostId is String && raum.spielerIds.contains(hostId)) {
        host._hostId = hostId;
        host._hostName = d['hostName'] as String? ?? '';
        host._lokal = LokaleVerbindung(raum, id: hostId, name: host._hostName ?? '', beitreten: false, beiAenderung: host._geaendert, abendzeit: host.abendzeit);
      }
      final gaeste = d['gaeste'];
      if (gaeste is Map) {
        for (final e in gaeste.entries) {
          final k = e.key;
          final pub = unB64((e.value as Map)['pub']);
          if (k is String && istCid(k) && pub != null && pub.length == 32 && cidVon(pub) == k) {
            host._bekannt[k] = pub;
          }
        }
      }
      // Alle Gäste gelten zunächst als offline, bis ihre Presence zurück ist.
      for (final id in List.of(raum.spielerIds)) {
        if (id != host._hostId) raum.verbunden(id, false);
      }
      return host;
    } catch (e) {
      log?.call('Wiederherstellung fehlgeschlagen: $e');
      return null;
    }
  }

  final AbendRaum raum;
  final Schluesselpaar schluessel;
  final RelayParameter relay;
  final String akte;

  /// Inhaltskennung (Version des Akteninhalts); Gäste mit anderer, nicht
  /// leerer Kennung werden abgewiesen. Leer: keine Prüfung.
  final String inhalt;
  final Ablage? ablage;
  final Map<String, Object?> meta;
  final int epoch;
  final Duration offlineFrist;

  /// So lange darf ein angemeldeter Gast ohne beglaubigten Umschlag bleiben:
  /// danach gilt er trotz Presence als offline ([umschlagFristStandard]).
  final Duration umschlagFrist;
  final Duration entprellung;
  final int maxProSekunde;
  final int maxSitze;
  final void Function(String)? log;
  final RelayHostStatistik statistik = RelayHostStatistik();

  /// Uhr des Abends in Millisekunden (Vorgabe: die Wanduhr dieses Geräts). Jeder
  /// Befehl, auch der des eigenen Platzes, trägt sie im Feld `zeit`; ein Gast
  /// kann sie nicht setzen. Im `pong` geht sie als `ht` hinaus, damit Gäste die
  /// Restzeit der gemeinsamen Rundenuhr selbst rechnen (`runden_uhr.dart`).
  /// Nach einem Neustart läuft dieselbe Uhr weiter, das Protokoll trägt die
  /// Zeiten der Befehle.
  final int Function() abendzeit;

  String get raumCode => raum.raumCode;

  PhoenixSocket? _socket;
  PhoenixKanal? _lobby;
  final Map<String, _Sitz> _sitze = {};
  final Map<String, Uint8List> _bekannt = {};
  final LinkedHashSet<String> _wartend = LinkedHashSet<String>();
  final Queue<void Function()> _steuer = Queue<void Function()>();
  final Queue<int> _gesendetZeiten = Queue<int>();
  final Queue<int> _klopfZeiten = Queue<int>();
  final List<Timer> _restTimer = [];
  LokaleVerbindung? _lokal;
  String? _hostId;
  String? _hostName;
  Timer? _drainTimer;
  Timer? _turmTimer;
  bool _gestartet = false;
  bool _zu = false;
  bool _speichernLaeuft = false;
  bool _speichernNoch = false;
  bool _lobbyWarDa = false;
  Timer? _wacheTimer;
  DateTime _verbundenSeit = DateTime.fromMillisecondsSinceEpoch(0);
  final LetzterWert<bool> _verbindung = LetzterWert<bool>(false);

  /// Stand geschlossener Sitze angemeldeter Gäste, solange die Epoche gilt (die
  /// Schlüssel bleiben dieselben): Wiederholschutz, Sendezähler und letzte
  /// Befehlsnummer dürfen beim Wiedereröffnen nicht zurückspringen, sonst ließen
  /// sich alte Umschläge einspielen.
  final Map<String, ({int empfangen, int gesendet, int? letzteQ})> _staende = {};

  /// Spieler-ID des Gastgebers (nach [lokaleVerbindung]).
  String? get hostId => _hostId;

  /// Zähler des Sockets (Ereignisse/s messen); vor dem Start `null`.
  PhoenixZaehler? get zaehler => _socket?.zaehler;

  /// Steht die Verbindung zum Relais (Socket offen und Lobby-Thema beigetreten)?
  /// Sonst erreicht den Gastgeber kein Gast, und er erreicht keinen.
  bool get verbunden {
    final s = _socket, l = _lobby;
    return !_zu && s != null && s.offen && l != null && l.beigetreten;
  }

  /// Meldet jeden Wechsel von [verbunden]; ein neuer Zuhörer bekommt zuerst den
  /// aktuellen Stand.
  Stream<bool> get verbindung => _verbindung.strom;

  void _verbindungNeu() {
    final v = verbunden;
    if (_verbindung.wert == v) return;
    if (v) _verbundenSeit = DateTime.now();
    _verbindung.add(v);
  }

  /// Angemeldete Gäste (Spieler-IDs).
  List<String> get gaeste => [
        for (final s in _sitze.values)
          if (s.angemeldet) s.pid,
      ];

  /// Der Platz des Gastgebers; ein bestehender Platz (Wiederherstellung) wird zurückgegeben.
  /// Muss vor dem ersten Gast stehen: Der erste Platz im Raum führt den Abend.
  LokaleVerbindung lokaleVerbindung(String id, String name) {
    final alt = _lokal;
    if (alt != null) {
      if (alt.spielerId == id) return alt;
      throw StateError('Der Gastgeberplatz gehört schon ${alt.spielerId}.');
    }
    _hostId = id;
    _hostName = name;
    final v = LokaleVerbindung(raum, id: id, name: name, beiAenderung: _geaendert, abendzeit: abendzeit);
    _lokal = v;
    _turmGeplant();
    _speichern();
    return v;
  }

  // ---------------------------------------------------------------- Start

  /// Verbindet sich mit dem Relais, eröffnet die Lobby und nimmt Gäste an.
  /// Wirft [PhoenixFehler], wenn das Relais nicht erreichbar ist.
  Future<void> starten({Duration timeout = const Duration(seconds: 15)}) async {
    if (_gestartet) return;
    _gestartet = true;
    final socket = _socket = PhoenixSocket(relay.socketUri, fabrik: relay.kanalFabrik, log: log);
    socket.status.listen((_) => _verbindungNeu());
    try {
      await socket.verbinde(timeout: timeout);
      await _lobbyOeffnen(socket, timeout);
    } catch (_) {
      await socket.schliessen();
      _gestartet = false;
      rethrow;
    }
    // Wiederhergestellte Gäste: Plätze gleich wieder öffnen; wer innerhalb der
    // Frist nicht zurückkehrt, verlässt den Raum.
    for (final e in _bekannt.entries) {
      unawaited(_sitzOeffnen(e.key, e.value).catchError((Object _) => null));
      _restTimer.add(Timer(offlineFrist, () {
        final s = _sitze[e.key];
        if (_zu || (s != null && s.angemeldet)) return;
        raum.verlassen(spielerIdVon(e.key));
        _bekannt.remove(e.key);
        if (s != null) _sitzSchliessen(s);
        _geaendert();
      }));
    }
    _wacheTimer?.cancel();
    _wacheTimer = Timer.periodic(umschlagFrist ~/ 5, (_) => _wache());
    await _speichernJetzt();
  }

  Future<void> _lobbyOeffnen(PhoenixSocket socket, Duration timeout) async {
    final lobby = socket.kanal(lobbyThema(raumCode), presenceKey: hostPresenceKey);
    _lobby = lobby;
    lobby.nachrichten.listen((m) {
      if (m.ereignis == 'klopf') {
        unawaited(_klopf(m.payload).catchError((Object e) {
          log?.call('Klopfen: $e');
        }));
      }
    });
    lobby.status.listen((s) {
      _verbindungNeu();
      if (s == KanalStatus.beigetreten) {
        if (_lobbyWarDa) {
          // Wieder verbunden: Turm neu ausrufen, alle Plätze auffrischen.
          _turmGeplant();
          for (final sitz in _sitze.values) {
            if (sitz.angemeldet) _markiere(sitz, sofort: true);
          }
        }
        _lobbyWarDa = true;
      }
    });
    await lobby.beitreten(timeout: timeout);
    lobby.track({'epoch': epoch, 'h': 1});
    _turmGeplant();
  }

  // ----------------------------------------------------------------- Turm

  int get _plaetze => (raum.maxSpieler - raum.spielerIds.length).clamp(0, 1 << 20);

  Map<String, Object?> _turm() => {
        'hpub': b64(schluessel.oeffentlich),
        'epoch': epoch,
        'proto': protokollVersion,
        'akte': akte,
        'inhalt': inhalt,
        'offen': _hostId != null && raum.vorStart && _plaetze > 0,
        'plaetze': _plaetze,
      };

  /// Bündelt Turm-Ausrufe: Jeder Turm erreicht alle in der Lobby.
  void _turmGeplant() {
    if (_zu || _turmTimer != null || _lobby == null) return;
    _turmTimer = Timer(const Duration(milliseconds: 300), () {
      _turmTimer = null;
      if (_zu) return;
      _steuer.add(() {
        _zaehleSendung();
        _lobby?.sende('turm', _turm());
      });
      _leeren();
    });
  }

  // ---------------------------------------------------------------- Klopf

  bool _klopfErlaubt() {
    final jetzt = DateTime.now().millisecondsSinceEpoch;
    while (_klopfZeiten.isNotEmpty && jetzt - _klopfZeiten.first > 1000) {
      _klopfZeiten.removeFirst();
    }
    if (_klopfZeiten.length >= 20) return false;
    _klopfZeiten.add(jetzt);
    return true;
  }

  Future<void> _klopf(Map<String, Object?> p) async {
    if (_zu) return;
    if (!_klopfErlaubt()) {
      statistik.klopfVerworfen++;
      return;
    }
    final cid = p['cid'];
    final pub = unB64(p['pub']);
    if (cid is! String || !istCid(cid) || pub == null || pub.length != 32 || cidVon(pub) != cid) {
      statistik.klopfVerworfen++;
      return;
    }
    _turmGeplant();
    final bekannt = raum.spielerIds.contains(spielerIdVon(cid));
    final gast = p['inhalt'];
    String? ablehnung;
    if (p['proto'] != protokollVersion) {
      ablehnung = 'proto';
    } else if (inhalt.isNotEmpty && gast is String && gast.isNotEmpty && gast != inhalt) {
      ablehnung = 'inhalt';
    } else if (!bekannt && !raum.vorStart) {
      ablehnung = 'gestartet';
    } else if (!bekannt && raum.spielerIds.length >= raum.maxSpieler) {
      ablehnung = 'voll';
    }
    final sitz = await _sitzOeffnen(cid, pub);
    if (sitz == null) {
      statistik.klopfVerworfen++;
      return;
    }
    if (ablehnung != null && !sitz.angemeldet) {
      statistik.klopfAbgewiesen++;
      await _abweisen(sitz, ablehnung);
    } else {
      statistik.klopfAkzeptiert++;
    }
  }

  /// Schickt die Ablehnung; auf ein Hallo trägt sie dessen Kennung [r], denn nur
  /// so nimmt der Gast sie vor dem Willkommen an.
  Future<void> _abweisen(_Sitz s, String grund, {Object? r}) async {
    await _senden(s, {'t': 'zu', 'grund': grund, 'r': ?(r is String ? r : null)});
    // Kurze Gnadenzeit, damit der Gast die Ablehnung noch bekommt.
    Timer(const Duration(seconds: 3), () {
      if (!s.angemeldet) _sitzSchliessen(s);
    });
  }

  // ----------------------------------------------------------------- Sitz

  Future<_Sitz?> _sitzOeffnen(String cid, Uint8List pub) async {
    final socket = _socket;
    var s = _sitze[cid];
    if (s != null) {
      final ok = await s.offen.future;
      return ok && !s.zu ? s : null;
    }
    if (socket == null || _sitze.length >= maxSitze || _zu) return null;
    s = _Sitz(cid, pub);
    _sitze[cid] = s;
    final sitz = s;
    try {
      final keys = await Sitzungsschluessel.ableiten(
        eigen: schluessel,
        fremdOeffentlich: pub,
        code: raumCode,
        epoch: epoch,
        cid: cid,
      );
      final topic = sitzThema(raumCode, cid);
      final stand = _staende[cid];
      final paar = sitz.paar = UmschlagPaar(topic: topic, eigeneSeite: 'h', schluessel: keys, startN: stand?.gesendet ?? 0);
      if (stand != null) {
        paar.empfangsUntergrenze(stand.empfangen);
        sitz.letzteQ = stand.letzteQ;
      }
      final kanal = sitz.kanal = socket.kanal(topic, presenceKey: hostPresenceKey);
      sitz.subNachricht = kanal.nachrichten.listen((m) => _sitzNachricht(sitz, m));
      sitz.subPraesenz = kanal.praesenz.listen((k) => _praesenz(sitz, k));
      sitz.subStatus = kanal.status.listen((st) => _sitzStatus(sitz, st));
      await kanal.beitreten();
      kanal.track({'h': 1});
      sitz.anmeldeTimer = Timer(const Duration(seconds: 30), () {
        if (!sitz.angemeldet && !_bekannt.containsKey(sitz.cid)) _sitzSchliessen(sitz);
      });
      sitz.offen.complete(true);
      return sitz;
    } catch (e) {
      log?.call('Sitz $cid nicht geöffnet: $e');
      if (!sitz.offen.isCompleted) sitz.offen.complete(false);
      _sitzSchliessen(sitz);
      return null;
    }
  }

  void _sitzStatus(_Sitz s, KanalStatus st) {
    if (st == KanalStatus.beigetreten) {
      if (s.warBeigetreten && s.angemeldet) {
        // Nach einem Abbruch wieder da: lieber einmal zu viel senden.
        _markiere(s, sofort: true);
      }
      s.warBeigetreten = true;
    }
  }

  void _sitzSchliessen(_Sitz s) {
    if (s.zu) return;
    s.zu = true;
    s.timerStoppen();
    final paar = s.paar;
    if (s.angemeldet && paar != null) {
      _staende[s.cid] = (empfangen: paar.empfangenN, gesendet: paar.gesendetN, letzteQ: s.letzteQ);
    }
    _wartend.remove(s.cid);
    if (_sitze[s.cid] == s) _sitze.remove(s.cid);
    if (!s.offen.isCompleted) s.offen.complete(false);
    unawaited(s.subNachricht?.cancel());
    unawaited(s.subPraesenz?.cancel());
    unawaited(s.subStatus?.cancel());
    final k = s.kanal;
    if (k != null) unawaited(k.verlassen());
  }

  // -------------------------------------------------------------- Presence

  void _praesenz(_Sitz s, Set<String> keys) {
    if (_zu || s.zu || s.kanal?.beigetreten != true) return;
    final da = keys.contains(s.cid);
    if (da) {
      s.sahPraesenz = true;
      // Presence ist unbeglaubigt: Wer den Raumcode kennt, kann den Schlüssel des
      // Gastes eintragen. Sie hält einen Platz nur online, wenn zuletzt ein echter
      // Umschlag kam; sonst zählt allein die Wache.
      if (!_frisch(s)) return;
      s.offlineTimer?.cancel();
      s.offlineTimer = null;
      if (s.angemeldet && !s.online) {
        s.online = true;
        raum.verbunden(s.pid, true);
        _geaendert();
      }
    } else if (s.sahPraesenz) {
      _offline(s);
    }
  }

  bool _frisch(_Sitz s) {
    final bezug = s.letzterUmschlag.isAfter(_verbundenSeit) ? s.letzterUmschlag : _verbundenSeit;
    return DateTime.now().difference(bezug) <= umschlagFrist;
  }

  /// Presence dient nur als schneller Hinweis auf Abwesenheit: Wer zu lange
  /// keinen beglaubigten Umschlag geschickt hat (Pings kommen alle 20 s), gilt
  /// als offline. Ohne eigene Verbindung kann nichts ankommen: dann ruht die Wache.
  void _wache() {
    if (_zu || !verbunden) return;
    for (final s in List.of(_sitze.values)) {
      if (s.angemeldet && s.online && !_frisch(s)) _offline(s);
    }
  }

  void _offline(_Sitz s) {
    if (!s.angemeldet || s.zu || _zu) return;
    if (s.online) {
      s.online = false;
      raum.verbunden(s.pid, false);
      _geaendert();
    }
    s.offlineTimer ??= Timer(offlineFrist, () {
      s.offlineTimer = null;
      if (s.zu || s.online || _zu) return;
      raum.verlassen(s.pid);
      _bekannt.remove(s.cid);
      _geaendert();
      _sitzSchliessen(s);
    });
  }

  // -------------------------------------------------------------- Eingang

  void _sitzNachricht(_Sitz s, PhoenixNachricht m) {
    if (_zu || s.zu || m.ereignis != sitzEreignis) return;
    final paar = s.paar;
    if (paar == null) return;
    unawaited(paar.oeffnen(m.payload).then((r) async {
      if (r == null) {
        statistik.umschlaegeVerworfen++;
        return;
      }
      // Schutz vor Überflutung: Nur beglaubigte Umschläge zählen, ein Mithörer
      // kann dem Gast also nicht seine Rate wegnehmen.
      if (!_eingangErlaubt(s)) {
        statistik.umschlaegeVerworfen++;
        return;
      }
      statistik.umschlaegeEmpfangen++;
      await _gastNachricht(s, r.nachricht);
    }).catchError((Object e) {
      log?.call('Eingang von ${s.cid}: $e');
    }));
  }

  bool _eingangErlaubt(_Sitz s) {
    final jetzt = DateTime.now().millisecondsSinceEpoch;
    while (s.eingang.isNotEmpty && jetzt - s.eingang.first > 1000) {
      s.eingang.removeFirst();
    }
    if (s.eingang.length >= 20) return false;
    s.eingang.add(jetzt);
    return true;
  }

  Future<void> _gastNachricht(_Sitz s, Map<String, Object?> m) async {
    s.letzterUmschlag = DateTime.now();
    final t = m['t'];
    if (t == 'hallo') return _hallo(s, m);
    if (!s.angemeldet) {
      await _senden(s, {'t': 'nein', 'key': 'nicht_angemeldet'});
      return;
    }
    // Eine beglaubigte Nachricht beweist Anwesenheit, auch wenn ein Presence-Diff verloren ging.
    s.sahPraesenz = true;
    s.offlineTimer?.cancel();
    s.offlineTimer = null;
    if (!s.online) {
      s.online = true;
      raum.verbunden(s.pid, true);
      _geaendert();
    }
    switch (t) {
      case 'befehl':
        return _befehl(s, m);
      case 'sync' || 'ping':
        final v = m['v'];
        if (t == 'ping') await _senden(s, {'t': 'pong', 'v': raum.version, 'ht': abendzeit()});
        if (v is int && v != s.gesendeteVersion) _markiere(s, sofort: true);
      case 'tschuess':
        raum.verlassen(s.pid);
        _bekannt.remove(s.cid);
        _geaendert();
        _sitzSchliessen(s);
      default:
        await _senden(s, {'t': 'nein', 'key': 'invalid'});
    }
  }

  Future<void> _hallo(_Sitz s, Map<String, Object?> m) async {
    final name = m['name'], r = m['r'];
    if (_hostId == null) {
      await _senden(s, {'t': 'nein', 'key': 'kein_gastgeber'});
      return;
    }
    // Die beglaubigte Ablehnung stützt sich nur auf das beglaubigte Hallo, nie auf
    // den Klartext-Klopf (den kann jeder mit dem Raumcode fälschen).
    if (m['proto'] != protokollVersion) {
      await _abweisen(s, 'proto', r: r);
      return;
    }
    final gast = m['inhalt'];
    if (inhalt.isNotEmpty && gast is String && gast.isNotEmpty && gast != inhalt) {
      await _abweisen(s, 'inhalt', r: r);
      return;
    }
    if (name is! String || name.trim().isEmpty || name.runes.length > 40 || r is! String || r.isEmpty || r.length > 64) {
      await _senden(s, {'t': 'nein', 'key': 'invalid'});
      return;
    }
    bool ok;
    try {
      ok = raum.beitreten(s.pid, name);
    } catch (_) {
      ok = false;
    }
    if (!ok) {
      await _abweisen(s, raum.vorStart ? 'voll' : 'gestartet', r: r);
      return;
    }
    s.angemeldet = true;
    s.online = true;
    s.name = name.trim();
    s.anmeldeTimer?.cancel();
    s.offlineTimer?.cancel();
    s.offlineTimer = null;
    _bekannt[s.cid] = s.pub;
    await _senden(s, {'t': 'willkommen', 'spieler': s.pid, 'raum': raumCode, 'epoch': epoch, 'r': r});
    _markiere(s, sofort: true);
    // Presence, die nie erscheint, gilt nach einer Frist als offline.
    s.graceTimer?.cancel();
    s.graceTimer = Timer(const Duration(seconds: 8), () {
      if (!s.sahPraesenz) _offline(s);
    });
    _geaendert();
  }

  Future<void> _befehl(_Sitz s, Map<String, Object?> m) async {
    final q = m['q'], c = m['c'];
    if (q is! int || c is! Map) {
      await _senden(s, {'t': 'nein', 'key': 'invalid'});
      return;
    }
    final letzte = s.letzteQ;
    if (letzte != null) {
      if (q == letzte) {
        // Wiederholung: dieselbe Antwort, nichts doppelt ausführen.
        statistik.befehleWiederholt++;
        await _antwort(s, q, s.letzteAntwort);
        return;
      }
      if (q < letzte) return;
    }
    String? fehler;
    try {
      // Die Abendzeit stempelt der Gastgeber beim Annehmen; was der Gast mitschickt, gilt nie.
      raum.nachricht(s.pid, mitAbendzeit(Map<String, Object?>.from(c), abendzeit()));
    } on PartyRaumFehler catch (e) {
      fehler = e.code;
    } catch (_) {
      fehler = 'invalid';
    }
    s.letzteQ = q;
    s.letzteAntwort = fehler;
    if (fehler == null) {
      statistik.befehleAusgefuehrt++;
    } else {
      statistik.befehleAbgelehnt++;
    }
    await _antwort(s, q, fehler);
    if (fehler == null) _geaendert();
  }

  Future<void> _antwort(_Sitz s, int q, String? fehler) =>
      _senden(s, fehler == null ? {'t': 'ok', 'q': q} : {'t': 'fehler', 'q': q, 'key': fehler});

  // ---------------------------------------------------------------- Senden

  void _zaehleSendung() {
    final jetzt = DateTime.now().millisecondsSinceEpoch;
    while (_gesendetZeiten.isNotEmpty && jetzt - _gesendetZeiten.first >= 1000) {
      _gesendetZeiten.removeFirst();
    }
    _gesendetZeiten.add(jetzt);
    if (_gesendetZeiten.length > statistik.spitzeProSekunde) {
      statistik.spitzeProSekunde = _gesendetZeiten.length;
    }
  }

  bool get _budgetFrei {
    final jetzt = DateTime.now().millisecondsSinceEpoch;
    while (_gesendetZeiten.isNotEmpty && jetzt - _gesendetZeiten.first >= 1000) {
      _gesendetZeiten.removeFirst();
    }
    return _gesendetZeiten.length < maxProSekunde;
  }

  /// Steuerbotschaften (Antworten, Willkommen, Pong, Zu) haben Vorrang vor
  /// Ansichten, zählen aber im selben Budget: Mehr als [maxProSekunde]
  /// Nachrichten je Sekunde verlassen den Gastgeber nie.
  Future<void> _senden(_Sitz s, Map<String, Object?> msg) {
    final fertig = Completer<void>();
    _steuer.add(() {
      unawaited(_sendeSteuer(s, msg).whenComplete(fertig.complete));
    });
    _leeren();
    return fertig.future;
  }

  Future<void> _sendeSteuer(_Sitz s, Map<String, Object?> msg) async {
    final kanal = s.kanal, paar = s.paar;
    if (s.zu || _zu || kanal == null || paar == null) return;
    _zaehleSendung(); // vor dem ersten await: das Budget gilt sofort
    try {
      if (await paar.senden(kanal, msg)) statistik.umschlaegeGesendet++;
    } catch (e) {
      log?.call('Senden an ${s.cid}: $e');
    }
  }

  String _hash(Map<String, Object?> ansicht) {
    final k = Map<String, Object?>.of(ansicht)..remove('version');
    return sha256.convert(utf8.encode(jsonEncode(k))).toString();
  }

  /// Schickt die aktuelle Ansicht des Gastes, wenn sie sich (ohne `version`)
  /// seit der letzten gesendeten geändert hat (`letzterHash == null` erzwingt).
  Future<void> _sendeAnsicht(_Sitz s) async {
    final kanal = s.kanal, paar = s.paar;
    if (s.zu || !s.angemeldet || _zu || kanal == null || paar == null) return;
    final Map<String, Object?> ansicht;
    try {
      ansicht = raum.zustandFuer(s.pid);
    } on PartyRaumFehler {
      return; // offline oder nicht im Raum: keine Ansicht
    }
    final h = _hash(ansicht);
    if (h == s.letzterHash) {
      statistik.ansichtenUebersprungen++;
      return;
    }
    s.letzterHash = h;
    s.gesendeteVersion = ansicht['version'] as int?;
    final laenge = jsonEncode(ansicht).length;
    if (laenge > statistik.groessteAnsichtZeichen) statistik.groessteAnsichtZeichen = laenge;
    // Vor dem ersten await zählen, damit die Warteschlange das Budget einhält.
    _zaehleSendung();
    try {
      if (await paar.senden(kanal, ansicht)) {
        statistik.umschlaegeGesendet++;
        statistik.ansichtenGesendet++;
      }
    } catch (e) {
      log?.call('Ansicht an ${s.cid}: $e');
    }
  }

  /// Der Raum hat sich ohne Nachricht eines Platzes geändert (etwa das
  /// Reihum-Gerät hinter einem Erzähler-Begleiter): Alle Plätze bekommen ihre
  /// Ansicht neu, wie nach einem Befehl.
  void ansichtenNeu() => _geaendert();

  /// Nach jeder Änderung: eigener Platz sofort, Gäste entprellt (200 ms je
  /// Empfänger), nur bei geänderter Ansicht, gedeckelt auf [maxProSekunde]
  /// Nachrichten, immer die jüngste Fassung.
  void _geaendert() {
    if (_zu) return;
    _lokal?.aktualisiere();
    for (final s in _sitze.values) {
      if (s.angemeldet) _markiere(s);
    }
    _turmGeplant();
    _speichern();
  }

  void _markiere(_Sitz s, {bool sofort = false}) {
    if (s.zu) return;
    if (sofort) {
      s.entprell?.cancel();
      s.entprell = null;
      s.letzterHash = null;
      _wartend.add(s.cid);
      _leeren();
      return;
    }
    s.entprell ??= Timer(entprellung, () {
      s.entprell = null;
      _wartend.add(s.cid);
      _leeren();
    });
  }

  /// Leert die Warteschlangen im Rahmen des Budgets: erst Steuerbotschaften,
  /// dann Ansichten (beim Senden wird die jüngste Fassung gebaut, nicht die
  /// von vor der Wartezeit).
  void _leeren() {
    _drainTimer?.cancel();
    _drainTimer = null;
    while (_steuer.isNotEmpty || _wartend.isNotEmpty) {
      if (!_budgetFrei) {
        statistik.ratenVerzoegert++;
        _drainTimer = Timer(const Duration(milliseconds: 40), _leeren);
        return;
      }
      if (_steuer.isNotEmpty) {
        _steuer.removeFirst()();
        continue;
      }
      final cid = _wartend.first;
      _wartend.remove(cid);
      final s = _sitze[cid];
      if (s == null || !s.angemeldet || s.zu) continue;
      unawaited(_sendeAnsicht(s));
    }
  }

  // ------------------------------------------------------------ Ablage

  void _speichern() {
    if (ablage == null || _zu) return;
    unawaited(_speichernJetzt());
  }

  /// Schreibt Schlüssel, Epoche, Akte und Protokoll. Höchstens ein Schreibvorgang
  /// läuft; Änderungen währenddessen lösen einen weiteren, jüngeren aus.
  Future<void> _speichernJetzt() async {
    final a = ablage;
    if (a == null) return;
    if (_speichernLaeuft) {
      _speichernNoch = true;
      return;
    }
    _speichernLaeuft = true;
    try {
      do {
        _speichernNoch = false;
        final r = raum;
        final daten = <String, Object?>{
          'v': 1,
          'code': raumCode,
          'hpriv': b64(schluessel.geheim),
          'epoch': epoch,
          'akte': akte,
          'inhalt': inhalt,
          'meta': meta,
          'hostId': _hostId,
          'hostName': _hostName,
          'gaeste': {
            for (final e in _bekannt.entries)
              if (r.spielerIds.contains(spielerIdVon(e.key))) e.key: {'pub': b64(e.value)},
          },
          if (r is ProtokollRaum) 'log': r.protokoll,
        };
        await a.schreiben(ablageSchluessel, jsonEncode(daten));
      } while (_speichernNoch);
    } catch (e) {
      log?.call('Ablage: $e');
    } finally {
      _speichernLaeuft = false;
    }
  }

  // --------------------------------------------------------------- Ende

  /// Schließt den Abend: Die Gäste bekommen `zu`, Verbindung und Themen
  /// werden geschlossen. [endgueltig]: auch die Ablage löschen (kein
  /// Wiederaufnehmen mehr); sonst bleibt der Stand für [wiederherstellen] liegen.
  /// [gaesteBenachrichtigen] `false`: wie ein Absturz oder ein vom System
  /// beendetes Gerät, die Gäste warten dann auf die Rückkehr des Gastgebers.
  Future<void> schliessen({bool endgueltig = true, bool gaesteBenachrichtigen = true}) async {
    if (_zu) return;
    if (!endgueltig) await _speichernJetzt();
    if (gaesteBenachrichtigen) {
      for (final s in List.of(_sitze.values)) {
        if (s.angemeldet) await _senden(s, {'t': 'zu', 'grund': 'geschlossen'});
      }
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    _zu = true;
    _verbindungNeu();
    _wacheTimer?.cancel();
    _turmTimer?.cancel();
    _drainTimer?.cancel();
    for (final t in _restTimer) {
      t.cancel();
    }
    for (final s in List.of(_sitze.values)) {
      s.zu = true;
      s.timerStoppen();
    }
    _sitze.clear();
    await _socket?.schliessen();
    await _lokal?.schliessen();
    await _verbindung.schliessen();
    if (endgueltig) await ablage?.loeschen(ablageSchluessel);
  }

  /// Testhilfe: kappt die Relais-Verbindung wie ein Netzabbruch.
  void kappeVerbindung() => _socket?.kappe();
}
