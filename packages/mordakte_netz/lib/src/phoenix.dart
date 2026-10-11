/// Minimaler Phoenix-Channels-Client (vsn 1.0.0, JSON-Objekte) für Supabase
/// Realtime: mehrere Themen auf einem Socket, Broadcast, Presence, Heartbeat,
/// Wiederverbindung mit gestaffelter Wartezeit. Reines Dart (VM und Web); die
/// Verbindung selbst kommt aus einer austauschbaren [KanalFabrik].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'relay_standard.dart' show KanalFabrik;
import 'verbindung.dart' show LetzterWert;

/// Wartezeiten vor dem nächsten Versuch (Socket und Thema): 1, 2, 5, 10 s, danach 10 s.
const standardBackoff = [Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 5), Duration(seconds: 10)];

/// Fehler der Transportschicht; [grund] ist ein fester Schlüssel.
class PhoenixFehler implements Exception {
  const PhoenixFehler(this.grund);
  final String grund;
  @override
  String toString() => 'PhoenixFehler: $grund';
}

enum SocketStatus { verbinde, offen, getrennt, geschlossen }

enum KanalStatus { getrennt, beitretend, beigetreten, geschlossen }

/// Eine empfangene Broadcast-Nachricht.
class PhoenixNachricht {
  const PhoenixNachricht(this.ereignis, this.payload);
  final String ereignis;
  final Map<String, Object?> payload;
}

/// Zähler für Messungen (Ereignisse/s) und Diagnose.
class PhoenixZaehler {
  int gesendet = 0;
  int empfangen = 0;
  int broadcastGesendet = 0;
  int broadcastEmpfangen = 0;
  int bytesGesendet = 0;
  int bytesEmpfangen = 0;
  int wiederverbunden = 0;
}

class PhoenixSocket {
  PhoenixSocket(
    this.uri, {
    KanalFabrik? fabrik,
    this.heartbeatIntervall = const Duration(seconds: 20),
    this.joinFrist = const Duration(seconds: 10),
    this.backoff = standardBackoff,
    this.jitter = 0.25,
    Random? zufall,
    this.log,
  })  : _fabrik = fabrik ?? WebSocketChannel.connect,
        _zufall = zufall ?? Random();

  final Uri uri;
  final KanalFabrik _fabrik;
  final Duration heartbeatIntervall;
  final Duration joinFrist;
  final List<Duration> backoff;

  /// Anteil, um den die Wartezeit zufällig verlängert wird (gegen Gleichtakt).
  final double jitter;
  final Random _zufall;
  final void Function(String)? log;
  final PhoenixZaehler zaehler = PhoenixZaehler();

  final Map<String, PhoenixKanal> _kanaele = {};
  final LetzterWert<SocketStatus> _status = LetzterWert<SocketStatus>(SocketStatus.getrennt);
  WebSocketChannel? _ws;
  StreamSubscription<Object?>? _sub;
  Timer? _heartbeat;
  Timer? _wiederTimer;
  String? _heartbeatRef;
  int _refZaehler = 0;
  int _versuche = 0;
  bool _gewollt = false;
  bool _zu = false;

  Stream<SocketStatus> get status => _status.strom;
  SocketStatus get aktuellerStatus => _status.wert!;
  bool get offen => _status.wert == SocketStatus.offen;

  String _ref() => '${++_refZaehler}';

  Duration _warte(int versuch) {
    final basis = backoff[min(max(versuch, 0), backoff.length - 1)];
    return Duration(microseconds: (basis.inMicroseconds * (1 + _zufall.nextDouble() * jitter)).round());
  }

  /// Baut die Verbindung auf. Wiederholt bis [timeout]; danach [PhoenixFehler].
  /// Nach dem ersten Erfolg verbindet sich der Socket bei Abbrüchen von selbst neu.
  Future<void> verbinde({Duration timeout = const Duration(seconds: 15)}) async {
    if (_zu) throw const PhoenixFehler('geschlossen');
    _gewollt = true;
    final ende = DateTime.now().add(timeout);
    var versuch = 0;
    Object? letzter;
    while (!_zu) {
      if (offen) return;
      try {
        await _oeffne(timeout < const Duration(seconds: 10) ? timeout : const Duration(seconds: 10));
        return;
      } catch (e) {
        letzter = e;
        log?.call('Verbindung fehlgeschlagen: $e');
      }
      final w = _warte(versuch++);
      if (DateTime.now().add(w).isAfter(ende)) break;
      await Future<void>.delayed(w);
    }
    _gewollt = false;
    throw PhoenixFehler('verbindung:${letzter ?? 'abgebrochen'}');
  }

  Future<void> _oeffne(Duration frist) async {
    if (_ws != null) return;
    _status.add(SocketStatus.verbinde);
    final ch = _fabrik(uri);
    try {
      await ch.ready.timeout(frist);
    } catch (e) {
      unawaited(ch.sink.close().catchError((_) {}));
      _status.add(SocketStatus.getrennt);
      rethrow;
    }
    if (_zu) {
      unawaited(ch.sink.close().catchError((_) {}));
      return;
    }
    _ws = ch;
    _versuche = 0;
    _sub = ch.stream.listen(
      (m) => _eingang(ch, m),
      onError: (Object e) => _verloren(ch, 'Fehler: $e'),
      onDone: () => _verloren(ch, 'geschlossen (${ch.closeCode})'),
      cancelOnError: false,
    );
    _heartbeatRef = null;
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(heartbeatIntervall, (_) => _schlag());
    _status.add(SocketStatus.offen);
    for (final k in List.of(_kanaele.values)) {
      k._socketOffen();
    }
  }

  void _schlag() {
    if (!offen) return;
    if (_heartbeatRef != null) {
      // Der letzte Schlag blieb unbeantwortet: Verbindung gilt als tot.
      final ch = _ws;
      if (ch != null) _verloren(ch, 'Heartbeat unbeantwortet');
      return;
    }
    _heartbeatRef = _ref();
    _sende({'topic': 'phoenix', 'event': 'heartbeat', 'payload': <String, Object?>{}, 'ref': _heartbeatRef});
  }

  bool _sende(Map<String, Object?> frame) {
    final ch = _ws;
    if (ch == null || !offen) return false;
    try {
      final text = jsonEncode(frame);
      ch.sink.add(text);
      zaehler.gesendet++;
      zaehler.bytesGesendet += text.length;
      return true;
    } catch (e) {
      log?.call('Senden fehlgeschlagen: $e');
      return false;
    }
  }

  void _eingang(WebSocketChannel von, Object? roh) {
    if (!identical(von, _ws)) return;
    if (roh is! String) return;
    zaehler.empfangen++;
    zaehler.bytesEmpfangen += roh.length;
    final Object? frame;
    try {
      frame = jsonDecode(roh);
    } catch (_) {
      return;
    }
    if (frame is! Map) return;
    final topic = frame['topic'];
    final event = frame['event'];
    if (topic is! String || event is! String) return;
    final ref = frame['ref'];
    final payload = frame['payload'] is Map ? (frame['payload'] as Map).cast<String, Object?>() : <String, Object?>{};
    if (topic == 'phoenix') {
      if (event == 'phx_reply' && ref == _heartbeatRef) _heartbeatRef = null;
      return;
    }
    _kanaele[topic]?._eingang(event, payload, ref is String ? ref : null);
  }

  void _verloren(WebSocketChannel ch, String grund) {
    if (!identical(ch, _ws)) return;
    log?.call('Socket verloren: $grund');
    _ws = null;
    _heartbeat?.cancel();
    _heartbeat = null;
    _heartbeatRef = null;
    unawaited(_sub?.cancel());
    _sub = null;
    unawaited(ch.sink.close().catchError((_) {}));
    if (_zu) return;
    _status.add(SocketStatus.getrennt);
    for (final k in List.of(_kanaele.values)) {
      k._socketWeg();
    }
    if (_gewollt) _planeNeuaufbau();
  }

  void _planeNeuaufbau() {
    if (_zu || !_gewollt || _wiederTimer != null) return;
    final w = _warte(_versuche++);
    _wiederTimer = Timer(w, () async {
      _wiederTimer = null;
      if (_zu || !_gewollt || _ws != null) return;
      try {
        await _oeffne(const Duration(seconds: 10));
        zaehler.wiederverbunden++;
      } catch (e) {
        log?.call('Neuaufbau fehlgeschlagen: $e');
        _planeNeuaufbau();
      }
    });
  }

  /// Testhilfe: kappt die Verbindung wie ein Netzabbruch (der Socket verbindet sich neu).
  void kappe() {
    final ch = _ws;
    if (ch != null) _verloren(ch, 'gekappt');
  }

  /// Das Thema [topic] (ohne `realtime:`-Präfix) auf diesem Socket. Mehrere
  /// Themen teilen sich eine Verbindung.
  PhoenixKanal kanal(
    String topic, {
    String? presenceKey,
    bool presence = true,
    bool self = false,
    bool ack = false,
  }) {
    final voll = 'realtime:$topic';
    final alt = _kanaele[voll];
    if (alt != null) return alt;
    return _kanaele[voll] = PhoenixKanal._(this, topic, voll, presenceKey, presence, self, ack);
  }

  Future<void> schliessen() async {
    if (_zu) return;
    _zu = true;
    _gewollt = false;
    _wiederTimer?.cancel();
    _wiederTimer = null;
    _heartbeat?.cancel();
    _heartbeat = null;
    for (final k in List.of(_kanaele.values)) {
      await k._ende(sendeLeave: true);
    }
    _kanaele.clear();
    final ch = _ws;
    _ws = null;
    await _sub?.cancel();
    _sub = null;
    if (ch != null) {
      try {
        await ch.sink.close(1000).timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
    _status.add(SocketStatus.geschlossen);
    await _status.schliessen();
  }
}

class PhoenixKanal {
  PhoenixKanal._(this._socket, this.topic, this.vollerName, this.presenceKey, this.presence, this.self, this.ack);

  final PhoenixSocket _socket;

  /// Name ohne Präfix, z. B. `mordakte:v1:ACDEFH`.
  final String topic;

  /// Name auf dem Draht: `realtime:<topic>`.
  final String vollerName;
  final String? presenceKey;
  final bool presence;
  final bool self;
  final bool ack;

  final StreamController<PhoenixNachricht> _nachrichten = StreamController<PhoenixNachricht>.broadcast();
  final LetzterWert<KanalStatus> _status = LetzterWert<KanalStatus>(KanalStatus.getrennt);
  final LetzterWert<Set<String>> _praesenz = LetzterWert<Set<String>>(const <String>{});
  final Map<String, Set<String>> _metas = {};
  Map<String, Object?>? _trackMeta;
  Timer? _joinTimer;
  Timer? _rejoinTimer;
  Completer<void>? _erster;
  String? _joinRef;
  int _versuche = 0;
  String _letzterGrund = 'unbekannt';
  bool _gewollt = false;

  /// Broadcast-Ereignisse anderer Teilnehmer (nie die eigenen, außer `self`).
  Stream<PhoenixNachricht> get nachrichten => _nachrichten.stream;

  Stream<KanalStatus> get status => _status.strom;
  KanalStatus get aktuellerStatus => _status.wert!;
  bool get beigetreten => _status.wert == KanalStatus.beigetreten;

  /// Schlüssel aller derzeit anwesenden Teilnehmer (nach Presence-State/-Diff).
  Stream<Set<String>> get praesenz => _praesenz.strom;
  Set<String> get praesenzSchluessel => Set.unmodifiable(_praesenz.wert!);

  Map<String, Object?> get _joinPayload => {
        'config': {
          'broadcast': {'ack': ack, 'self': self},
          'presence': {'enabled': presence, if (presenceKey != null) 'key': presenceKey},
          'private': false,
        },
      };

  /// Tritt dem Thema bei und wartet auf `phx_reply` mit Status `ok` (Frist
  /// [PhoenixSocket.joinFrist] je Versuch). Danach tritt das Thema nach
  /// Abbrüchen von selbst wieder bei (Wartezeit 1/2/5/10 s).
  Future<void> beitreten({Duration timeout = const Duration(seconds: 15)}) async {
    if (_status.wert == KanalStatus.geschlossen) throw const PhoenixFehler('geschlossen');
    _gewollt = true;
    if (beigetreten) return;
    final c = _erster = Completer<void>();
    _versuchBeitritt();
    try {
      await c.future.timeout(timeout);
    } on TimeoutException {
      _gewollt = false;
      _joinTimer?.cancel();
      _rejoinTimer?.cancel();
      if (_status.wert != KanalStatus.geschlossen) _status.add(KanalStatus.getrennt);
      throw PhoenixFehler('beitritt:$_letzterGrund');
    }
  }

  void _versuchBeitritt() {
    if (!_gewollt || !_socket.offen) return;
    if (_status.wert == KanalStatus.beitretend || _status.wert == KanalStatus.beigetreten) return;
    _rejoinTimer?.cancel();
    _status.add(KanalStatus.beitretend);
    final ref = _joinRef = _socket._ref();
    _socket._sende({
      'topic': vollerName,
      'event': 'phx_join',
      'payload': _joinPayload,
      'ref': ref,
      'join_ref': ref,
    });
    _joinTimer?.cancel();
    _joinTimer = Timer(_socket.joinFrist, () => _beitrittFehlt('zeitueberschreitung'));
  }

  void _beitrittFehlt(String grund) {
    _joinTimer?.cancel();
    _letzterGrund = grund;
    _joinRef = null;
    if (_status.wert == KanalStatus.geschlossen) return;
    _status.add(KanalStatus.getrennt);
    _socket.log?.call('Thema $topic: $grund');
    _planeRejoin();
  }

  void _planeRejoin() {
    if (!_gewollt || _rejoinTimer != null && _rejoinTimer!.isActive) return;
    _rejoinTimer = Timer(_socket._warte(_versuche++), _versuchBeitritt);
  }

  void _socketOffen() => _versuchBeitritt();

  void _socketWeg() {
    _joinTimer?.cancel();
    _rejoinTimer?.cancel();
    _joinRef = null;
    if (_status.wert != KanalStatus.geschlossen) _status.add(KanalStatus.getrennt);
    // Rückkehr übernimmt _socketOffen() des Sockets.
  }

  void _eingang(String event, Map<String, Object?> payload, String? ref) {
    switch (event) {
      case 'phx_reply':
        if (ref != null && ref == _joinRef) {
          if (payload['status'] == 'ok') {
            _joinTimer?.cancel();
            _versuche = 0;
            _letzterGrund = 'unbekannt';
            _status.add(KanalStatus.beigetreten);
            final t = _trackMeta;
            if (t != null) _sendeTrack(t);
            final c = _erster;
            if (c != null && !c.isCompleted) c.complete();
          } else {
            final r = payload['response'];
            _beitrittFehlt('abgelehnt:${r is Map ? (r['reason'] ?? r) : r}');
          }
        }
      case 'phx_error':
      case 'phx_close':
        if (_status.wert == KanalStatus.geschlossen) return;
        _joinTimer?.cancel();
        _joinRef = null;
        _letzterGrund = event;
        _status.add(KanalStatus.getrennt);
        _planeRejoin();
      case 'system':
        if (payload['status'] == 'error') {
          _joinTimer?.cancel();
          _joinRef = null;
          _letzterGrund = 'system:${payload['message']}';
          _status.add(KanalStatus.getrennt);
          _socket.log?.call('Thema $topic: $_letzterGrund');
          _planeRejoin();
        }
      case 'broadcast':
        final e = payload['event'];
        final p = payload['payload'];
        if (e is String && p is Map && !_nachrichten.isClosed) {
          _socket.zaehler.broadcastEmpfangen++;
          _nachrichten.add(PhoenixNachricht(e, p.cast<String, Object?>()));
        }
      case 'presence_state':
        _metas.clear();
        _zusammen(payload, joins: true);
        _veroeffentliche();
      case 'presence_diff':
        final j = payload['joins'], l = payload['leaves'];
        if (j is Map) _zusammen(j, joins: true);
        if (l is Map) _zusammen(l, joins: false);
        _veroeffentliche();
    }
  }

  /// Presence-Metas je Schlüssel. Beitritte zuerst, dann Abgänge nach `phx_ref`
  /// (wie `Phoenix.Presence.syncDiff`): ein Wiedereintritt im selben Diff
  /// lässt den Schlüssel stehen.
  void _zusammen(Map<Object?, Object?> teil, {required bool joins}) {
    teil.forEach((k, v) {
      if (k is! String || v is! Map) return;
      final metas = v['metas'];
      final refs = <String>[
        if (metas is List)
          for (var i = 0; i < metas.length; i++)
            if (metas[i] is Map && (metas[i] as Map)['phx_ref'] is String) (metas[i] as Map)['phx_ref'] as String else '#$i',
      ];
      if (joins) {
        (_metas[k] ??= <String>{}).addAll(refs);
      } else {
        final s = _metas[k];
        if (s == null) return;
        for (final r in refs) {
          if (r.startsWith('#')) {
            if (s.isNotEmpty) s.remove(s.first);
          } else {
            s.remove(r);
          }
        }
        if (s.isEmpty) _metas.remove(k);
      }
    });
  }

  void _veroeffentliche() {
    final neu = _metas.keys.toSet();
    final alt = _praesenz.wert!;
    if (neu.length == alt.length && neu.containsAll(alt)) return;
    _praesenz.add(neu);
  }

  /// Schickt [payload] als Broadcast-Ereignis [ereignis] an alle anderen im
  /// Thema. Ist das Thema gerade nicht beigetreten, geht nichts verloren, was
  /// nicht die Anwendung selbst wiederholt: es wird verworfen (`false`).
  bool sende(String ereignis, Map<String, Object?> payload) {
    if (!beigetreten) return false;
    final ok = _socket._sende({
      'topic': vollerName,
      'event': 'broadcast',
      'payload': {'type': 'broadcast', 'event': ereignis, 'payload': payload},
      'ref': _socket._ref(),
    });
    if (ok) _socket.zaehler.broadcastGesendet++;
    return ok;
  }

  /// Meldet die eigene Anwesenheit (wird nach jedem erneuten Beitritt wiederholt).
  void track(Map<String, Object?> meta) {
    _trackMeta = meta;
    if (beigetreten) _sendeTrack(meta);
  }

  void _sendeTrack(Map<String, Object?> meta) {
    _socket._sende({
      'topic': vollerName,
      'event': 'presence',
      'payload': {'type': 'presence', 'event': 'track', 'payload': meta},
      'ref': _socket._ref(),
    });
  }

  void untrack() {
    _trackMeta = null;
    if (!beigetreten) return;
    _socket._sende({
      'topic': vollerName,
      'event': 'presence',
      'payload': {'type': 'presence', 'event': 'untrack'},
      'ref': _socket._ref(),
    });
  }

  Future<void> verlassen() async {
    _socket._kanaele.remove(vollerName);
    await _ende(sendeLeave: true);
  }

  Future<void> _ende({required bool sendeLeave}) async {
    if (_status.wert == KanalStatus.geschlossen) return;
    _gewollt = false;
    _joinTimer?.cancel();
    _rejoinTimer?.cancel();
    final warBeigetreten = beigetreten;
    _status.add(KanalStatus.geschlossen);
    if (sendeLeave && warBeigetreten) {
      _socket._sende({'topic': vollerName, 'event': 'phx_leave', 'payload': <String, Object?>{}, 'ref': _socket._ref()});
    }
    final c = _erster;
    if (c != null && !c.isCompleted) {
      c.future.ignore();
      c.completeError(const PhoenixFehler('geschlossen'));
    }
    await _nachrichten.close();
    await _status.schliessen();
    await _praesenz.schliessen();
  }
}
