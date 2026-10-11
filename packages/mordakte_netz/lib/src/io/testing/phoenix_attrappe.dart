/// Lokale Attrappe des Supabase-Realtime-Relais (Phoenix-Protokoll vsn 1.0.0):
/// Join/Leave, Heartbeat, Broadcast mit `self:false`-Verteilung je Thema,
/// Presence (State beim Beitritt, Diffs bei Track/Untrack/Abgang), Zähler samt
/// Emulation der Free-Plan-Grenze (100 Nachrichten/s) und Störungen (Verlust,
/// Verzögerung, gekappte Verbindungen). Nur für Werkzeuge und Tests (`dart:io`).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Einstellbare Störungen für Broadcast-Zustellungen.
class AttrappeStoerung {
  AttrappeStoerung({this.verlust = 0, this.verzoegerungMin = Duration.zero, this.verzoegerungMax = Duration.zero});

  /// Anteil (0 bis 1) der Broadcast-Zustellungen, die verloren gehen.
  double verlust;

  /// Jede Zustellung wird um eine Zeit zwischen Min und Max verzögert.
  Duration verzoegerungMin;
  Duration verzoegerungMax;
}

/// Eine vom Relais gesehene Broadcast-Nachricht (einmal je Absendung, nicht je Zustellung).
class AttrappeEintrag {
  const AttrappeEintrag({required this.zeit, required this.topic, required this.ereignis, required this.nutzlast, required this.von});
  final DateTime zeit;

  /// Thema ohne `realtime:`-Präfix.
  final String topic;
  final String ereignis;

  /// Der innere Broadcast-Inhalt als JSON-Text, genau wie er das Relais passiert.
  final String nutzlast;
  final int von;
}

/// Sicht auf eine offene Verbindung (Diagnose).
class AttrappeVerbindungInfo {
  const AttrappeVerbindungInfo(this.id, this.themen);
  final int id;
  final Map<String, String?> themen; // Thema -> Presence-Schlüssel
}

class _Beitritt {
  _Beitritt(this.verbindung, this.topic, this.presenceAktiv, this.key, this.self, this.ack);
  final _Verbindung verbindung;
  final String topic; // mit realtime:-Präfix
  final bool presenceAktiv;
  final String? key;
  final bool self;
  final bool ack;
  Map<String, Object?>? meta;
  String? phxRef;
}

class _Verbindung {
  _Verbindung(this.id, this.ws);
  final int id;
  final WebSocket ws;
  final Map<String, _Beitritt> themen = {};
  DateTime? letzteZustellung;
  bool zu = false;
}

class PhoenixAttrappe {
  PhoenixAttrappe._(this._server, this.limitProSekunde, this.limitErzwingen, this.maxVerbindungen, this.maxNutzlast, this._zufall, this.mitschnitt);

  /// Startet die Attrappe auf dem Loopback. [port] 0: freier Port.
  ///
  /// [limitProSekunde] emuliert die Free-Plan-Grenze (alle zugestellten
  /// Broadcast- und Presence-Nachrichten zählen); mit [limitErzwingen] werden
  /// Zustellungen darüber verworfen, sonst nur gezählt. [maxVerbindungen]
  /// emuliert die Grenze gleichzeitiger Verbindungen (200).
  static Future<PhoenixAttrappe> starten({
    int port = 0,
    int limitProSekunde = 100,
    bool limitErzwingen = false,
    int maxVerbindungen = 200,
    int maxNutzlast = 256 * 1024,
    Random? zufall,
    bool mitschnitt = true,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    final a = PhoenixAttrappe._(server, limitProSekunde, limitErzwingen, maxVerbindungen, maxNutzlast, zufall ?? Random(7), mitschnitt);
    a._lauf = server.listen(a._anfrage, onError: (_) {});
    return a;
  }

  final HttpServer _server;
  final int limitProSekunde;
  final bool limitErzwingen;
  final int maxVerbindungen;
  final int maxNutzlast;
  final bool mitschnitt;
  final Random _zufall;
  StreamSubscription<HttpRequest>? _lauf;

  /// Einstellbare Störungen (wirken sofort).
  final AttrappeStoerung stoerung = AttrappeStoerung();

  /// `false`: Heartbeats bleiben unbeantwortet (tote Gegenstelle).
  bool heartbeatBeantworten = true;

  final Map<int, _Verbindung> _verbindungen = {};
  final Map<String, Map<int, _Beitritt>> _themen = {};
  final List<AttrappeEintrag> _eintraege = [];
  final Map<int, int> _sekunden = {};
  final Map<int, Map<String, int>> _sekundenThema = {};
  final Map<int, Map<int, int>> _sekundenAn = {};
  final List<Timer> _timer = [];
  int _nextId = 0;
  int _phxRef = 0;
  bool _zu = false;

  // ------------------------------------------------------------- Zähler

  /// Frames, die Clients geschickt haben.
  int eingehend = 0;

  /// Alle zugestellten Nachrichten (Antworten, Broadcast, Presence).
  int zugestellt = 0;
  int broadcastEingehend = 0;
  int broadcastZugestellt = 0;
  int presenceZugestellt = 0;
  int verworfenStoerung = 0;
  int verworfenLimit = 0;
  int abgewieseneVerbindungen = 0;
  int zuGrosseNutzlast = 0;
  int groessteNutzlast = 0;
  int verbindungenInsgesamt = 0;

  /// Basis-URL für `RelayParameter.url` (`http://127.0.0.1:<port>`).
  String get url => 'http://127.0.0.1:${_server.port}';

  /// Beliebiger Schlüssel genügt (die Attrappe prüft nur, dass einer da ist).
  String get schluessel => 'attrappe';

  int get offeneVerbindungen => _verbindungen.length;

  /// Höchste Zahl gezählter Zustellungen in einer Kalendersekunde.
  int get spitzeProSekunde => _sekunden.values.fold(0, max);

  /// Zahl der Sekunden, in denen die Grenze [limitProSekunde] überschritten wurde.
  int get sekundenUeberLimit => _sekunden.values.where((n) => n > limitProSekunde).length;

  /// Zustellungen je Sekunde (Sekunde seit Epoche -> Anzahl).
  Map<int, int> get sekundenZaehler => Map.unmodifiable(_sekunden);

  /// Zustellungen je Sekunde und empfangender Verbindung (Kennung -> Anzahl).
  Map<int, Map<int, int>> get sekundenAnVerbindung => {for (final e in _sekundenAn.entries) e.key: Map.unmodifiable(e.value)};

  /// Höchste Zahl gezählter Zustellungen in einer Sekunde, ohne die an die
  /// Verbindungen [ohne] (z. B. einen Mithörer).
  int spitzeOhne(Set<int> ohne) {
    var m = 0;
    for (final e in _sekunden.entries) {
      var n = e.value;
      final an = _sekundenAn[e.key];
      if (an != null) {
        for (final id in ohne) {
          n -= an[id] ?? 0;
        }
      }
      if (n > m) m = n;
    }
    return m;
  }

  /// Zustellungen je Sekunde und Thema (ohne Präfix), zur Fehlersuche bei Lastspitzen.
  Map<int, Map<String, int>> get sekundenProThema => {for (final e in _sekundenThema.entries) e.key: Map.unmodifiable(e.value)};

  /// Mitschnitt aller Broadcasts (zuletzt höchstens 50 000).
  List<AttrappeEintrag> get eintraege => List.unmodifiable(_eintraege);

  /// Anzahl Abonnenten je Thema (ohne Präfix).
  Map<String, int> get abonnenten => {
        for (final e in _themen.entries) e.key.substring('realtime:'.length): e.value.length,
      };

  List<AttrappeVerbindungInfo> get verbindungen => [
        for (final v in _verbindungen.values)
          AttrappeVerbindungInfo(v.id, {for (final b in v.themen.values) b.topic.substring('realtime:'.length): b.key}),
      ];

  void zaehlerZuruecksetzen() {
    eingehend = zugestellt = broadcastEingehend = broadcastZugestellt = presenceZugestellt = 0;
    verworfenStoerung = verworfenLimit = abgewieseneVerbindungen = zuGrosseNutzlast = groessteNutzlast = 0;
    _sekunden.clear();
    _sekundenThema.clear();
    _sekundenAn.clear();
    _eintraege.clear();
  }

  // -------------------------------------------------------- Störungen

  /// Kappt alle Verbindungen (Netzabbruch; die Clients verbinden sich neu).
  Future<void> trenneAlle() async {
    for (final v in List.of(_verbindungen.values)) {
      await _schliesseVerbindung(v, 1006);
    }
  }

  /// Kappt die Verbindung mit der Kennung [id].
  Future<void> trenne(int id) async {
    final v = _verbindungen[id];
    if (v != null) await _schliesseVerbindung(v, 1006);
  }

  /// Kappt die Verbindungen, die [topic] (ohne Präfix) mit dem Presence-Schlüssel
  /// [presenceKey] beigetreten sind. Liefert die Zahl gekappter Verbindungen.
  Future<int> trenneBeiPresenceKey(String topic, String presenceKey) async {
    final b = _themen['realtime:$topic'];
    if (b == null) return 0;
    final ziele = [for (final x in b.values) if (x.key == presenceKey) x.verbindung];
    for (final v in ziele) {
      await _schliesseVerbindung(v, 1006);
    }
    return ziele.length;
  }

  // ------------------------------------------------------------ Server

  void _anfrage(HttpRequest req) async {
    if (_zu) {
      req.response.statusCode = 503;
      unawaited(req.response.close());
      return;
    }
    if (req.uri.path != '/realtime/v1/websocket' || !WebSocketTransformer.isUpgradeRequest(req)) {
      req.response.statusCode = 404;
      unawaited(req.response.close());
      return;
    }
    final key = req.uri.queryParameters['apikey'];
    if (key == null || key.isEmpty || req.uri.queryParameters['vsn'] != '1.0.0') {
      req.response.statusCode = 403;
      unawaited(req.response.close());
      return;
    }
    if (_verbindungen.length >= maxVerbindungen) {
      abgewieseneVerbindungen++;
      req.response.statusCode = 429;
      unawaited(req.response.close());
      return;
    }
    final WebSocket ws;
    try {
      ws = await WebSocketTransformer.upgrade(req);
    } catch (_) {
      return;
    }
    final v = _Verbindung(++_nextId, ws);
    _verbindungen[v.id] = v;
    verbindungenInsgesamt++;
    ws.listen(
      (d) {
        if (d is String) _frame(v, d);
      },
      onDone: () => unawaited(_verbindungWeg(v)),
      onError: (_) => unawaited(_verbindungWeg(v)),
      cancelOnError: true,
    );
  }

  Future<void> _schliesseVerbindung(_Verbindung v, int code) async {
    try {
      await v.ws.close(code == 1006 ? 1011 : code).timeout(const Duration(seconds: 1));
    } catch (_) {}
    await _verbindungWeg(v);
  }

  Future<void> _verbindungWeg(_Verbindung v) async {
    if (v.zu) return;
    v.zu = true;
    _verbindungen.remove(v.id);
    for (final b in List.of(v.themen.values)) {
      _entferne(b, antwort: false);
    }
    v.themen.clear();
  }

  void _frame(_Verbindung v, String roh) {
    if (v.zu) return;
    eingehend++;
    if (roh.length > maxNutzlast) {
      zuGrosseNutzlast++;
      unawaited(_schliesseVerbindung(v, 1009));
      return;
    }
    if (roh.length > groessteNutzlast) groessteNutzlast = roh.length;
    final Object? f;
    try {
      f = jsonDecode(roh);
    } catch (_) {
      return;
    }
    if (f is! Map) return;
    final topic = f['topic'], event = f['event'], ref = f['ref'];
    final payload = f['payload'] is Map ? (f['payload'] as Map).cast<String, Object?>() : <String, Object?>{};
    if (topic is! String || event is! String) return;
    if (topic == 'phoenix') {
      if (event == 'heartbeat' && heartbeatBeantworten) {
        _sende(v, {'ref': ref, 'event': 'phx_reply', 'payload': {'status': 'ok', 'response': <String, Object?>{}}, 'topic': 'phoenix'}, zaehlt: false);
      }
      return;
    }
    switch (event) {
      case 'phx_join':
        _beitritt(v, topic, ref, payload);
      case 'phx_leave':
        final b = v.themen[topic];
        if (b != null) {
          v.themen.remove(topic);
          _entferne(b, antwort: true, ref: ref);
        }
      case 'broadcast':
        _broadcast(v, topic, ref, payload);
      case 'presence':
        _presence(v, topic, ref, payload);
      case 'access_token':
        _antwortOk(v, topic, ref);
    }
  }

  void _antwortOk(_Verbindung v, String topic, Object? ref, [Map<String, Object?> response = const {}]) {
    _sende(v, {'ref': ref, 'event': 'phx_reply', 'payload': {'status': 'ok', 'response': response}, 'topic': topic}, zaehlt: false);
  }

  void _beitritt(_Verbindung v, String topic, Object? ref, Map<String, Object?> payload) {
    if (!topic.startsWith('realtime:') || topic.length <= 'realtime:'.length) {
      _sende(v, {
        'ref': ref,
        'event': 'phx_reply',
        'payload': {'status': 'error', 'response': {'reason': 'invalid topic'}},
        'topic': topic,
      }, zaehlt: false);
      return;
    }
    final cfg = payload['config'] is Map ? (payload['config'] as Map) : const {};
    final bc = cfg['broadcast'] is Map ? (cfg['broadcast'] as Map) : const {};
    final pr = cfg['presence'] is Map ? (cfg['presence'] as Map) : const {};
    final alt = v.themen[topic];
    if (alt != null) {
      // Doppelter Beitritt ersetzt den alten (wie Phoenix).
      v.themen.remove(topic);
      _entferne(alt, antwort: false);
    }
    final b = _Beitritt(
      v,
      topic,
      pr['enabled'] == true,
      pr['key'] is String ? pr['key'] as String : null,
      bc['self'] == true,
      bc['ack'] == true,
    );
    v.themen[topic] = b;
    (_themen[topic] ??= {})[v.id] = b;
    _antwortOk(v, topic, ref, {'postgres_changes': <Object?>[]});
    if (b.presenceAktiv) {
      _sende(v, {'ref': null, 'event': 'presence_state', 'payload': _zustand(topic), 'topic': topic}, presence: true);
    }
  }

  Map<String, Object?> _zustand(String topic) {
    final out = <String, Map<String, Object?>>{};
    for (final b in _themen[topic]?.values ?? const <_Beitritt>[]) {
      final m = b.meta;
      if (m == null || !b.presenceAktiv || b.key == null) continue;
      final e = out[b.key!] ??= {'metas': <Object?>[]};
      (e['metas'] as List).add({'phx_ref': b.phxRef, ...m});
    }
    return out;
  }

  void _entferne(_Beitritt b, {required bool antwort, Object? ref}) {
    final map = _themen[b.topic];
    map?.remove(b.verbindung.id);
    if (map != null && map.isEmpty) _themen.remove(b.topic);
    if (antwort) {
      _antwortOk(b.verbindung, b.topic, ref);
      _sende(b.verbindung, {'ref': ref, 'event': 'phx_close', 'payload': <String, Object?>{}, 'topic': b.topic}, zaehlt: false);
    }
    final m = b.meta;
    if (m != null && b.key != null) {
      b.meta = null;
      _diff(b.topic, joins: const {}, leaves: {b.key!: [{'phx_ref': b.phxRef, ...m}]});
    }
  }

  void _diff(String topic, {required Map<String, List<Object?>> joins, required Map<String, List<Object?>> leaves}) {
    final frame = {
      'ref': null,
      'event': 'presence_diff',
      'payload': {
        'joins': {for (final e in joins.entries) e.key: {'metas': e.value}},
        'leaves': {for (final e in leaves.entries) e.key: {'metas': e.value}},
      },
      'topic': topic,
    };
    for (final b in List.of(_themen[topic]?.values ?? const <_Beitritt>[])) {
      if (b.presenceAktiv) _sende(b.verbindung, frame, presence: true);
    }
  }

  void _presence(_Verbindung v, String topic, Object? ref, Map<String, Object?> payload) {
    final b = v.themen[topic];
    if (b == null || b.key == null || !b.presenceAktiv) return;
    final ereignis = payload['event'];
    final alt = b.meta;
    if (ereignis == 'track') {
      final p = payload['payload'];
      final meta = p is Map ? p.cast<String, Object?>() : <String, Object?>{};
      final altRef = b.phxRef;
      b.meta = meta;
      b.phxRef = 'ref${++_phxRef}';
      _antwortOk(v, topic, ref);
      _diff(
        topic,
        joins: {b.key!: [{'phx_ref': b.phxRef, ...meta}]},
        leaves: {if (alt != null) b.key!: [{'phx_ref': altRef, ...alt}]},
      );
    } else if (ereignis == 'untrack') {
      _antwortOk(v, topic, ref);
      if (alt != null) {
        b.meta = null;
        _diff(topic, joins: const {}, leaves: {b.key!: [{'phx_ref': b.phxRef, ...alt}]});
      }
    }
  }

  void _broadcast(_Verbindung v, String topic, Object? ref, Map<String, Object?> payload) {
    final b = v.themen[topic];
    if (b == null) return;
    broadcastEingehend++;
    if (mitschnitt) {
      if (_eintraege.length >= 50000) _eintraege.removeRange(0, 10000);
      _eintraege.add(AttrappeEintrag(
        zeit: DateTime.now(),
        topic: topic.substring('realtime:'.length),
        ereignis: '${payload['event']}',
        nutzlast: jsonEncode(payload['payload']),
        von: v.id,
      ));
    }
    final frame = {'ref': null, 'event': 'broadcast', 'payload': payload, 'topic': topic};
    for (final ziel in List.of(_themen[topic]?.values ?? const <_Beitritt>[])) {
      if (ziel == b && !b.self) continue;
      _sende(ziel.verbindung, frame, broadcast: true);
    }
    if (b.ack) _antwortOk(v, topic, ref);
  }

  /// Stellt zu. [broadcast]/[presence] zählen gegen die Grenze und unterliegen Störungen.
  void _sende(_Verbindung v, Map<String, Object?> frame, {bool zaehlt = true, bool broadcast = false, bool presence = false}) {
    final topic = (frame['topic'] as String?) ?? '';
    if (v.zu) return;
    void los() {
      if (v.zu) return;
      if (broadcast || presence) {
        final s = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final n = (_sekunden[s] ?? 0) + 1;
        _sekunden[s] = n;
        final an = _sekundenAn[s] ??= {};
        an[v.id] = (an[v.id] ?? 0) + 1;
        final t = _sekundenThema[s] ??= {};
        final tk = topic.startsWith('realtime:') ? topic.substring('realtime:'.length) : topic;
        t[tk] = (t[tk] ?? 0) + 1;
        if (limitErzwingen && n > limitProSekunde) {
          verworfenLimit++;
          return;
        }
        if (_sekunden.length > 600) {
          final alt = _sekunden.keys.where((k) => k < s - 300).toList();
          for (final k in alt) {
            _sekunden.remove(k);
            _sekundenThema.remove(k);
            _sekundenAn.remove(k);
          }
        }
        if (broadcast) {
          broadcastZugestellt++;
        } else {
          presenceZugestellt++;
        }
      }
      zugestellt++;
      try {
        v.ws.add(jsonEncode(frame));
      } catch (_) {}
    }

    if (broadcast && stoerung.verlust > 0 && _zufall.nextDouble() < stoerung.verlust) {
      verworfenStoerung++;
      return;
    }
    final min = stoerung.verzoegerungMin.inMicroseconds;
    final max = stoerung.verzoegerungMax.inMicroseconds;
    if ((broadcast || presence) && max > 0) {
      final w = min + (max > min ? _zufall.nextInt(max - min + 1) : 0);
      // Reihenfolge je Verbindung bleibt erhalten: feste Verzögerung je Zustellung
      // würde Nachrichten überholen lassen; darum gestaffelt nach Reihenfolge.
      final ziel = DateTime.now().add(Duration(microseconds: w));
      final frueh = v.letzteZustellung;
      final plan = frueh != null && frueh.isAfter(ziel) ? frueh : ziel;
      v.letzteZustellung = plan;
      _timer.add(Timer(plan.difference(DateTime.now()), los));
    } else {
      los();
    }
  }

  /// Schließt den Server und alle Verbindungen.
  Future<void> schliessen() async {
    if (_zu) return;
    _zu = true;
    for (final t in _timer) {
      t.cancel();
    }
    await _lauf?.cancel();
    for (final v in List.of(_verbindungen.values)) {
      await _schliesseVerbindung(v, 1001);
    }
    await _server.close(force: true);
  }
}
