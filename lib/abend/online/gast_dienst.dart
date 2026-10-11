import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/runden.dart' show KartenKatalog;
import 'package:mordakte_netz/mordakte_netz.dart';

import '../../karten/katalog_laden.dart';
import '../../netz/ablage_prefs.dart';
import '../../netz/relay_einstellung.dart';
import '../../party/daten.dart';
import 'ansicht.dart';

/// Das Gerät eines Gastes am Online-Abend: hält die Verbindung zum Gastgeber
/// ([RelayGast]) und die zuletzt empfangene Ansicht. Alles, was der Gast sieht,
/// kommt aus dieser Ansicht (der Positivliste des Raums für genau dieses Gerät);
/// die Akte ([daten]) liefert nur Figurennamen und Farben.
class GastDienst extends ChangeNotifier {
  GastDienst._(this.verb, this.name, this._ablage) {
    _ansicht = verb.letzteAnsicht;
    _status = VerbindungsStatus.verbunden;
    _hoererAnsicht = verb.ansichten.listen((v) {
      _ansicht = v;
      _akteLaden(v);
      notifyListeners();
    });
    _hoererStatus = verb.status.listen((s) {
      _status = s;
      if (s == VerbindungsStatus.geschlossen && !_selbst) unawaited(vergessen());
      notifyListeners();
    });
    final v = _ansicht;
    if (v != null) _akteLaden(v);
  }

  /// Ablage der Gäste: im Web nur dieser Tab, damit zwei Tabs zwei Gäste sind.
  static const standardAblage = AblagePrefs(proTab: true);

  final RelayGast verb;
  final String name;
  final Ablage _ablage;
  StreamSubscription<Map<String, Object?>>? _hoererAnsicht;
  StreamSubscription<VerbindungsStatus>? _hoererStatus;
  Map<String, Object?>? _ansicht;
  VerbindungsStatus _status = VerbindungsStatus.verbinde;
  PartyDaten? _daten;
  String? _akteLaeuft;
  KartenKatalog? _katalog;
  bool _selbst = false;
  bool _entsorgt = false;

  /// Raumcode (6 Zeichen).
  String get raumCode => verb.raumCode;

  /// Eigene Gerätekennung im Raum.
  String get spielerId => verb.spielerId ?? '';

  /// Die letzte Ansicht des Gastgebers für dieses Gerät.
  Map<String, Object?> get ansicht => _ansicht ?? const {};

  VerbindungsStatus get status => _status;

  /// Die Akte (Figuren, Enden), sobald geladen; die Ansicht zeigt sich auch ohne sie.
  PartyDaten? get daten => _daten;

  /// Katalog der Sammelkarten (Titel der Tischkarten), sobald geladen.
  KartenKatalog? get katalog => _katalog;

  bool get geschlossen => _status == VerbindungsStatus.geschlossen;

  /// Tritt dem Raum [code] bei. Wirft [AbendFehler] mit dem Grund (`code`,
  /// `relay`, `kein_raum`, `zeitueberschreitung`, `voll`, `gestartet`, `proto`,
  /// `inhalt`). Merkt sich Raum und Name, damit die Detektei die Rückkehr anbietet.
  static Future<GastDienst> beitreten({required String code, required String name, RelayParameter? relay}) async {
    final c = RaumCode.lesen(code);
    if (c == null) throw const AbendFehler('code');
    final g = await RelayGast.beitreten(
      code: c,
      name: name,
      ablage: standardAblage,
      relay: relay ?? relayFuerSeite(),
      app: 'mordakte',
      inhalt: await inhaltsKennung(),
    );
    final d = GastDienst._(g, name, standardAblage);
    await d._merken();
    return d;
  }

  /// Der gemerkte Raum eines früheren Beitritts auf diesem Gerät: `{code, name}`.
  static Future<({String code, String name})?> gemerkt([Ablage ablage = standardAblage]) async {
    try {
      final roh = await ablage.lesen(AblagePrefs.gastSitzung);
      if (roh == null) return null;
      final j = jsonDecode(roh);
      if (j is! Map) return null;
      final code = j['code'], name = j['name'];
      if (code is! String || name is! String || RaumCode.lesen(code) == null || name.trim().isEmpty) return null;
      return (code: code, name: name);
    } catch (_) {
      return null;
    }
  }

  /// Vergisst den gemerkten Raum (und den Wiederverbindungs-Schlüssel dazu).
  static Future<void> vergiss(String code, [Ablage ablage = standardAblage]) async {
    try {
      await ablage.loeschen(AblagePrefs.gastSitzung);
      await ablage.loeschen(RelayGast.ablageSchluesselFuer(code));
    } catch (_) {}
  }

  Future<void> _merken() async {
    try {
      await _ablage.schreiben(AblagePrefs.gastSitzung, jsonEncode({'code': raumCode, 'name': name}));
    } catch (_) {}
  }

  Future<void> vergessen() => vergiss(raumCode, _ablage);

  void _akteLaden(Map<String, Object?> v) {
    final akte = jText(v['akte']);
    if (akte.isEmpty || _daten != null || _akteLaeuft == akte) return;
    _akteLaeuft = akte;
    PartyDaten.laden(rootBundle, fall: akte).then((d) {
      if (_entsorgt) return;
      _daten = d;
      notifyListeners();
    }).catchError((Object e) {
      // Ohne Akte bleiben Figurennamen schlicht Kennungen.
      debugPrint('ONLINE akte fehler $e');
      _akteLaeuft = null;
    });
    ladeKartenKatalog().then((k) {
      if (_entsorgt) return;
      _katalog = k;
      notifyListeners();
    }).catchError((Object e) {
      debugPrint('ONLINE katalog fehler $e');
    });
  }

  /// Schickt eine Raumnachricht. `null` bei Erfolg, sonst der Schlüssel der
  /// Ablehnung (`not_ready`, `invalid_phase`, `zeitueberschreitung`, …).
  Future<String?> befehl(Map<String, Object?> c) async {
    try {
      await verb.befehl(c);
      return null;
    } on AbendFehler catch (e) {
      return e.key;
    } catch (_) {
      return 'invalid';
    }
  }

  /// Verlässt den Abend endgültig: Der Gastgeber nimmt den Platz aus dem Raum.
  Future<void> verlassen() async {
    _selbst = true;
    await vergessen();
    try {
      await verb.verlassen();
    } catch (_) {}
  }

  /// Trennt, ohne den Platz aufzugeben: Mit dem gemerkten Schlüssel kommt das
  /// Gerät später in dieselbe Rolle zurück.
  Future<void> trennen() async {
    _selbst = true;
    try {
      await verb.trennen();
    } catch (_) {}
  }

  @override
  void dispose() {
    _entsorgt = true;
    unawaited(_hoererAnsicht?.cancel());
    unawaited(_hoererStatus?.cancel());
    super.dispose();
  }
}
