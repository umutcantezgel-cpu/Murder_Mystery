import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/mordakte_netz.dart';

import '../../karten/katalog_laden.dart';
import '../../netz/relay_einstellung.dart';
import '../../party/daten.dart';
import '../../party/sitzung.dart' show PartySitzung;
import 'ansicht.dart';

/// Kennung des Gastgeberplatzes im Raum (der erste Platz führt den Abend).
const gastgeberPlatz = 'gastgeber';

/// Das Gastgebergerät eines Online-Abends: hält den Raum (`SchlosskellerRaum`
/// im `ProtokollRaum`), das Relais ([RelayHost]) und den eigenen, lokalen Platz.
/// Von der Lobby bis zum Ende des Abends dieselbe Instanz; die Lobby und die
/// Abendsitzung ([GastgeberSitzung]) hören auf sie.
///
/// Das Gerät verbindet sich erst mit [oeffnen], also erst nachdem jemand die
/// Spielweise „Jeder am eigenen Gerät“ gewählt hat.
class GastgeberDienst extends ChangeNotifier {
  GastgeberDienst._({
    required this.host,
    required this.verb,
    required this.daten,
    required this.akteId,
    required this.abstecher,
    required this.katalog,
    required this.ablage,
  }) : raum = ((host.raum as ProtokollRaum).innen as SchlosskellerRaum) {
    _hoerer = verb.ansichten.listen((_) => notifyListeners());
  }

  final RelayHost host;
  final SchlosskellerRaum raum;
  final LokaleVerbindung verb;
  final PartyDaten daten;
  final String akteId;
  final List<AbstecherOrt> abstecher;
  final KartenKatalog? katalog;
  final Ablage ablage;

  StreamSubscription<Map<String, Object?>>? _hoerer;
  bool _offen = false;
  bool _zu = false;

  /// Raumcode (6 Zeichen, ohne Trennstrich).
  String get raumCode => host.raumCode;

  /// Die Einstellungen des Abends, mit dem Protokoll abgelegt (siehe [neu]).
  Map<String, Object?> get meta => host.meta;

  String get salz => meta['salz'] as String;
  String get gastgeberName => jText(meta['name']);
  String get detektiv => meta['detektiv'] == 'm' ? 'm' : 'w';
  String get geburtstagskind => jText(meta['geburtstag']);
  int get minuten => jZahl(meta['minuten'], 30);
  bool get stimme => meta['stimme'] == true;

  /// Hat der Abend schon begonnen (Rollen verteilt)?
  bool get gestartet => !raum.vorStart;

  bool get geschlossen => _zu;

  /// Ist das Relais verbunden und der Raum für Gäste offen?
  bool get offen => _offen;

  /// Die aktuelle Ansicht des Gastgeberplatzes.
  Map<String, Object?> get ansicht => verb.letzteAnsicht ?? const {};

  /// Alle Plätze am Tisch (Gastgeber zuerst).
  List<SpielerInfo> get spieler => spielerAusAnsicht(ansicht);

  /// Plätze der Gäste (ohne den Gastgeber).
  List<SpielerInfo> get gaeste => [for (final s in spieler) if (!s.istGastgeber) s];

  /// Anzeigename eines Platzes (Gerätekennung → Name), sonst leer.
  String nameVon(String? id) {
    for (final s in spieler) {
      if (s.id == id) return s.name;
    }
    return '';
  }

  /// Kleinste und größte Zahl besetzter Rollen der Akte.
  int get minRollen => jZahl(daten.kanon.besetzungJson['minRollen'], 4);
  int get maxRollen => jZahl(daten.kanon.besetzungJson['maxRollen'], 8);

  // ------------------------------------------------------------- Aufbau

  static AbendRaum _baue(String code, Map<String, Object?> meta, PartyDaten daten, String akte, KartenKatalog? katalog, List<AbstecherOrt> abstecher) =>
      SchlosskellerRaum(
        raumCode: code,
        kanon: daten.kanon,
        texte: daten.texte,
        fallCode: FallCode.lesen(meta['fallCode'] as String)!,
        salz: meta['salz'] as String,
        akte: akte,
        festerGastgeber: true,
        katalog: katalog,
        abstecher: abstecher,
      );

  /// Erzeugt Schlüssel, Raumcode und Raum neu. Das Relais ist noch nicht
  /// verbunden: [oeffnen] tut das.
  ///
  /// [fallCodeEingabe] leer oder ungültig heißt Zufall. Alle Einstellungen
  /// liegen in [meta], damit [wiederherstellen] denselben Abend aufbauen kann.
  static Future<GastgeberDienst> neu({
    required PartyDaten daten,
    required String akteId,
    required String name,
    required String detektiv,
    required Ablage ablage,
    List<AbstecherOrt> abstecher = const [],
    KartenKatalog? katalog,
    String? fallCodeEingabe,
    String geburtstagskind = '',
    int minuten = 30,
    bool stimme = false,
    RelayParameter? relay,
    void Function(String)? log,
  }) async {
    final zufall = math.Random.secure();
    final salz = [for (var i = 0; i < 32; i++) zufall.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
    final code = (fallCodeEingabe == null ? null : FallCode.lesen(fallCodeEingabe)) ?? PartySitzung.zufallsCode();
    final meta = <String, Object?>{
      'salz': salz,
      'fallCode': code.code,
      'name': name,
      'detektiv': detektiv,
      'geburtstag': geburtstagskind,
      'minuten': minuten,
      'stimme': stimme,
    };
    final host = await RelayHost.neu(
      fabrik: (c, m) => _baue(c, m, daten, akteId, katalog, abstecher),
      meta: meta,
      relay: relay ?? relayFuerSeite(),
      akte: akteId,
      inhalt: await inhaltsKennung(),
      ablage: ablage,
      log: log,
    );
    final verb = host.lokaleVerbindung(gastgeberPlatz, name);
    return GastgeberDienst._(host: host, verb: verb, daten: daten, akteId: akteId, abstecher: abstecher, katalog: katalog, ablage: ablage);
  }

  /// Der Raumcode eines abgelegten Gastgeberabends, sonst `null`.
  static Future<String?> gespeicherterCode(Ablage ablage) async {
    try {
      final roh = await ablage.lesen(RelayHost.ablageSchluessel);
      if (roh == null) return null;
      final d = jsonDecode(roh);
      final code = d is Map ? d['code'] : null;
      return code is String && RaumCode.lesen(code) != null ? code : null;
    } catch (_) {
      return null;
    }
  }

  /// Verwirft einen abgelegten Gastgeberabend.
  static Future<void> verwerfeGespeicherten(Ablage ablage) async {
    try {
      await ablage.loeschen(RelayHost.ablageSchluessel);
    } catch (_) {}
  }

  /// Baut einen abgelegten Abend wieder auf (gleicher Raumcode, gleiche Rollen,
  /// neue Epoche) oder liefert `null`, wenn nichts Brauchbares abgelegt ist.
  /// Danach [oeffnen] aufrufen.
  static Future<GastgeberDienst?> wiederherstellen({required Ablage ablage, RelayParameter? relay, void Function(String)? log}) async {
    try {
      final roh = await ablage.lesen(RelayHost.ablageSchluessel);
      if (roh == null) return null;
      final d = jsonDecode(roh);
      if (d is! Map) return null;
      final akte = d['akte'] is String ? d['akte'] as String : 'schlosskeller';
      final results = await Future.wait<Object?>([PartyDaten.laden(rootBundle, fall: akte), ladeAbstecher(akte), _katalogOderNull(), inhaltsKennung()]);
      final daten = results[0] as PartyDaten;
      final abstecher = results[1] as List<AbstecherOrt>;
      final katalog = results[2] as KartenKatalog?;
      final host = await RelayHost.wiederherstellen(
        ablage: ablage,
        fabrik: (c, m) => _baue(c, m, daten, akte, katalog, abstecher),
        relay: relay ?? relayFuerSeite(),
        inhalt: results[3] as String,
        log: log,
      );
      final id = host?.hostId;
      if (host == null || id == null) {
        await verwerfeGespeicherten(ablage);
        return null;
      }
      final verb = host.lokaleVerbindung(id, jText(host.meta['name']));
      return GastgeberDienst._(host: host, verb: verb, daten: daten, akteId: akte, abstecher: abstecher, katalog: katalog, ablage: ablage);
    } catch (e) {
      log?.call('Wiederherstellung: $e');
      return null;
    }
  }

  static Future<KartenKatalog?> _katalogOderNull() async {
    try {
      return await ladeKartenKatalog();
    } catch (_) {
      return null;
    }
  }

  /// Verbindet sich mit dem Relais und nimmt Gäste an. Wirft, wenn das Relais
  /// nicht erreichbar ist; ein weiterer Aufruf versucht es noch einmal.
  Future<void> oeffnen() async {
    if (_offen || _zu) return;
    await host.starten();
    _offen = true;
    notifyListeners();
  }

  // ------------------------------------------------------------- Abend

  /// Meldet den Gastgeber bereit und startet den Abend mit [rollen] Rollen und
  /// dem Tischvorrat [vorrat] (Kartenkennungen). Wirft [AbendFehler], etwa
  /// `not_ready`, wenn ein Gast nicht bereit oder nicht verbunden ist.
  Future<void> abendStarten({required int rollen, required List<String> vorrat}) async {
    await verb.befehl({'typ': 'bereit', 'wert': true});
    await verb.befehl({'typ': 'start', 'rollen': rollen, 'detektiv': detektiv, 'vorrat': vorrat});
  }

  /// Schließt den Abend. [endgueltig] `false`: Der Stand bleibt für
  /// [wiederherstellen] liegen und die Gäste erfahren nur, dass die Spielleitung
  /// weg ist (sie warten auf die Rückkehr).
  Future<void> schliessen({bool endgueltig = true}) async {
    if (_zu) return;
    _zu = true;
    _offen = false;
    await _hoerer?.cancel();
    _hoerer = null;
    try {
      await host.schliessen(endgueltig: endgueltig, gaesteBenachrichtigen: endgueltig);
    } catch (e) {
      debugPrint('ONLINE schliessen fehler $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_hoerer?.cancel());
    _hoerer = null;
    super.dispose();
  }
}
