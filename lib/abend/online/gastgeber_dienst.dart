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
  StreamSubscription<bool>? _verbindungsHoerer;
  bool _offen = false;
  bool _zu = false;
  bool _verbunden = false;

  /// Raumcode (6 Zeichen, ohne Trennstrich).
  String get raumCode => host.raumCode;

  /// Die Einstellungen des Abends, mit dem Protokoll abgelegt (siehe [neu]).
  Map<String, Object?> get meta => host.meta;

  String get salz => meta['salz'] as String;
  String get gastgeberName => jText(meta['name']);
  String get detektiv => meta['detektiv'] == 'm' ? 'm' : 'w';

  /// Name des Detektivs aus der Einrichtung; Abende vor M3 legten ihn unter
  /// `geburtstag` ab.
  String get detektivName => jText(meta['detektivName'], jText(meta['geburtstag']));

  /// Früherer Name von [detektivName].
  @Deprecated('detektivName')
  String get geburtstagskind => detektivName;

  /// Sitz des Gastgebers, mit dem der Raum geöffnet wurde (Meta `sitz`):
  /// Detektiv oder Erzähler. Abende ohne den Schlüssel (vor M3) sind Detektiv.
  /// In der Lobby ändert die Nachricht `sitz` ihn; ab dem Start gilt der Raum
  /// ([SchlosskellerRaum.sitzVon]).
  Sitz get sitz => _sitzAus(meta);

  static Sitz _sitzAus(Map<String, Object?> meta) => Sitz.lesen(meta['sitz']) == Sitz.erzaehler ? Sitz.erzaehler : Sitz.detektiv;
  int get minuten => jZahl(meta['minuten'], 30);
  bool get stimme => meta['stimme'] == true;

  /// Kurzer oder langer Abend (M7b, Meta `fassung`, nur bei lang geschrieben).
  /// Abende ohne den Schlüssel sind kurz.
  Abendfassung get fassung => Abendfassung.lesen(meta['fassung']);

  /// Hat der Abend schon begonnen (Rollen verteilt)?
  bool get gestartet => !raum.vorStart;

  bool get geschlossen => _zu;

  /// Wurde der Raum geöffnet (Relais war erreichbar)? Bleibt wahr, bis der Raum zu ist.
  bool get offen => _offen;

  /// Steht die Verbindung zum Relais gerade? Fällt sie weg, erfährt kein Gast
  /// etwas, bis sie zurück ist.
  bool get verbunden => _verbunden;

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
        gastgeberSitz: _sitzAus(meta),
        katalog: katalog,
        abstecher: abstecher,
        // Rundenuhr und Diashow (M4): Dauer der Einrichtung, Bilder der Akte.
        rundenMinuten: jZahl(meta['minuten'], 30),
        diaAnzahl: daten.diashow?.dias.length ?? 0,
        // Fassung (M7b): lang nur aus der Meta und nur in Akten mit Langfassung.
        fassung: daten.hat('langfassung') ? Abendfassung.lesen(meta['fassung']) : Abendfassung.kurz,
        // Vorspiel und Morgen (M7b): der Rundgang der Akte; der Raum nimmt ihn nur im langen Abend.
        rundgang: daten.vorspielMorgen,
      );

  /// Erzeugt Schlüssel, Raumcode und Raum neu. Das Relais ist noch nicht
  /// verbunden: [oeffnen] tut das.
  ///
  /// [fallCodeEingabe] leer oder ungültig heißt Zufall. [sitz] ist der Platz
  /// des Gastgebers (Detektiv oder Erzähler). [fassung] lang nur in Akten mit
  /// Langfassung; die Meta trägt sie nur dann, kurze Abende bleiben bytegleich.
  /// Alle Einstellungen liegen in [meta], damit [wiederherstellen] denselben
  /// Abend aufbauen kann.
  static Future<GastgeberDienst> neu({
    required PartyDaten daten,
    required String akteId,
    required String name,
    required String detektiv,
    required Ablage ablage,
    List<AbstecherOrt> abstecher = const [],
    KartenKatalog? katalog,
    String? fallCodeEingabe,
    String detektivName = '',
    Sitz sitz = Sitz.detektiv,
    int minuten = 30,
    bool stimme = false,
    Abendfassung fassung = Abendfassung.kurz,
    RelayParameter? relay,
    void Function(String)? log,
  }) async {
    if (!sitz.vergeben) throw ArgumentError.value(sitz, 'sitz', 'Detektiv oder Erzähler');
    if (fassung.istLang && !daten.hat('langfassung')) throw ArgumentError.value(fassung, 'fassung', 'Diese Akte hat keinen langen Abend');
    final zufall = math.Random.secure();
    final salz = [for (var i = 0; i < 32; i++) zufall.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
    final code = (fallCodeEingabe == null ? null : FallCode.lesen(fallCodeEingabe)) ?? PartySitzung.zufallsCode();
    final meta = <String, Object?>{
      'salz': salz,
      'fallCode': code.code,
      'name': name,
      'detektiv': detektiv,
      'detektivName': detektivName,
      'sitz': sitz.name,
      'minuten': minuten,
      'stimme': stimme,
      if (fassung.istLang) 'fassung': fassung.name,
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
      await ablage.loeschen(erzaehlSchluessel);
      await ablage.loeschen(notizSchluessel);
    } catch (_) {}
  }

  /// Wo der Gastgeber seine Randgespräche ablegt ([GastgeberSitzung]).
  static const erzaehlSchluessel = 'gastgeber.erzaehlung';

  /// Wo der Gastgeber das Notizbuch seiner Befragungen ablegt ([GastgeberSitzung]).
  static const notizSchluessel = 'gastgeber.befragungen';

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
    _verbindungsHoerer ??= host.verbindung.listen((v) {
      if (_zu || v == _verbunden) return;
      _verbunden = v;
      notifyListeners();
    });
    notifyListeners();
  }

  // ------------------------------------------------------------- Abend

  /// Lobby (M3): setzt [spieler] auf [sitz] (Detektiv oder Erzähler) oder nimmt
  /// ihm den Sitz (`null`); [klasse] reist mit dem Detektiv-Sitz. Wirft
  /// [AbendFehler] mit dem festen Code des Raums.
  Future<void> sitzSetzen(String spieler, Sitz? sitz, {String? klasse}) =>
      verb.befehl({'typ': 'sitz', 'spieler': spieler, 'sitz': sitz?.name, 'klasse': ?klasse});

  /// Lobby (M3): die Rollenzahl liegt im Raum; alle sehen sie.
  Future<void> besetzungSetzen(int rollen) => verb.befehl({'typ': 'besetzung', 'rollen': rollen});

  /// Lobby (M3): Figur [rolle] für [spieler] (`null`: Zufall beim Start); Tausch,
  /// wenn ein anderes Gerät die Figur hält.
  Future<void> zuteilen(String spieler, String? rolle) => verb.befehl({'typ': 'zuteilen', 'spieler': spieler, 'rolle': rolle});

  /// Meldet den Gastgeber bereit und startet den Abend mit dem Tischvorrat
  /// [vorrat] (Kartenkennungen). Die Rollenzahl liegt seit der Lobby im Raum
  /// (`besetzung`, alle sehen sie); [rollen] gilt nur, solange dort keine steht.
  /// Wirft [AbendFehler], etwa `not_ready`, wenn ein Gast nicht bereit oder
  /// nicht verbunden ist.
  Future<void> abendStarten({required int rollen, required List<String> vorrat}) async {
    await verb.befehl({'typ': 'bereit', 'wert': true});
    await verb.befehl({'typ': 'start', if (raum.lobbyRollen == null) 'rollen': rollen, 'detektiv': detektiv, 'vorrat': vorrat});
  }

  /// Schließt den Abend. [endgueltig] `false`: Der Stand bleibt für
  /// [wiederherstellen] liegen und die Gäste erfahren nur, dass der Gastgeber
  /// weg ist (sie warten auf die Rückkehr).
  Future<void> schliessen({bool endgueltig = true}) async {
    if (_zu) return;
    _zu = true;
    _offen = false;
    _verbunden = false;
    await _hoerer?.cancel();
    _hoerer = null;
    await _verbindungsHoerer?.cancel();
    _verbindungsHoerer = null;
    try {
      await host.schliessen(endgueltig: endgueltig, gaesteBenachrichtigen: endgueltig);
      if (endgueltig) {
        await ablage.loeschen(erzaehlSchluessel);
        await ablage.loeschen(notizSchluessel);
      }
    } catch (e) {
      debugPrint('ONLINE schliessen fehler $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_hoerer?.cancel());
    _hoerer = null;
    unawaited(_verbindungsHoerer?.cancel());
    _verbindungsHoerer = null;
    super.dispose();
  }
}
