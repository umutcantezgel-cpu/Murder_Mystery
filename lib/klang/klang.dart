import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:mordakte_klang/mordakte_klang.dart' show atmosphaerenKatalog, klangKatalog;
import 'package:shared_preferences/shared_preferences.dart';

import 'klang_umgebung.dart';

/// Ton der App (M7): kurze Klänge der Bedienung und der Welt, dazu eine
/// Atmosphäre je Akte. Alle Klänge sind per Code erzeugt
/// (`packages/mordakte_klang`, gebacken nach `assets/klang/`).
///
/// - Startet nur über [starten] (aus `main`), nie in Tests.
/// - Im Web erst nach der ersten Berührung (Regel der Browser).
/// - Schweigt, solange er nicht bereit ist, und bei jedem Fehler.
class Klang {
  Klang._();

  static final Klang instanz = Klang._();

  static const _schluesselAn = 'mordakte.ton';
  static const _schluesselEffekte = 'mordakte.ton.effekte';
  static const _schluesselAtmo = 'mordakte.ton.atmosphaere';

  /// Ton an oder aus (gespeichert).
  final ValueNotifier<bool> an = ValueNotifier(true);
  double effekte = 0.8;
  double atmosphaere = 0.5;

  bool _gestartet = false;
  bool _bereit = false;
  final Map<String, AudioSource> _quellen = {};
  final math.Random _zufall = math.Random();
  SoundHandle? _atmoGriff;
  String? _atmoName;
  String? _atmoWunsch;

  bool get bereit => _bereit;

  /// Einmal beim App-Start. Lädt die Einstellungen und wartet im Web auf die
  /// erste Berührung, bevor die Tonausgabe startet.
  Future<void> starten() async {
    if (_gestartet || laeuftImTest) return;
    _gestartet = true;
    try {
      final p = await SharedPreferences.getInstance();
      an.value = p.getBool(_schluesselAn) ?? true;
      effekte = p.getDouble(_schluesselEffekte) ?? effekte;
      atmosphaere = p.getDouble(_schluesselAtmo) ?? atmosphaere;
    } catch (_) {}
    if (kIsWeb) {
      void beiBeruehrung(PointerEvent e) {
        if (e is! PointerDownEvent) return;
        GestureBinding.instance.pointerRouter.removeGlobalRoute(beiBeruehrung);
        unawaited(_hochfahren());
      }

      GestureBinding.instance.pointerRouter.addGlobalRoute(beiBeruehrung);
    } else {
      unawaited(_hochfahren());
    }
  }

  Future<void> _hochfahren() async {
    try {
      final s = SoLoud.instance;
      if (!s.isInitialized) await s.init(bufferSize: 1024);
      for (final name in [...klangKatalog.keys, ...atmosphaerenKatalog.keys]) {
        _quellen[name] = await s.loadAsset('assets/klang/$name.wav');
      }
      _bereit = true;
      final wunsch = _atmoWunsch;
      if (wunsch != null) atmosphaereSpielen(wunsch);
    } catch (e) {
      debugPrint('Ton bleibt aus: $e');
      _bereit = false;
    }
  }

  /// Schaltet den Ton an oder aus und merkt sich die Wahl.
  Future<void> schalten(bool wert) async {
    an.value = wert;
    if (!wert) {
      _atmoStoppen();
    } else if (_atmoWunsch != null) {
      atmosphaereSpielen(_atmoWunsch);
    }
    try {
      (await SharedPreferences.getInstance()).setBool(_schluesselAn, wert);
    } catch (_) {}
  }

  /// Spielt einen kurzen Klang. Mit [varianten] wird zufällig eine der
  /// nummerierten Fassungen gewählt (`tippen1` … `tippen3`); [streuung]
  /// verändert die Tonhöhe leicht, damit Wiederholungen lebendig klingen.
  void spiele(String name, {double laut = 1, int varianten = 0, double streuung = 0.04, double tonhoehe = 1}) {
    if (!_bereit || !an.value) return;
    final n = varianten > 0 ? '$name${_zufall.nextInt(varianten) + 1}' : name;
    final q = _quellen[n];
    if (q == null) return;
    try {
      final s = SoLoud.instance;
      final h = s.play(q, volume: (laut * effekte).clamp(0.0, 1.0));
      final hoehe = tonhoehe * (1 + (_zufall.nextDouble() * 2 - 1) * streuung);
      if ((hoehe - 1).abs() > 0.001) s.setRelativePlaySpeed(h, hoehe);
    } catch (_) {}
  }

  /// Atmosphäre einer Akte (`atmo_regen` …) oder `null` für Stille; blendet
  /// in 1,5 s über.
  void atmosphaereSpielen(String? name) {
    _atmoWunsch = name;
    if (!_bereit) return;
    if (name == _atmoName && _atmoGriff != null) return;
    _atmoStoppen();
    if (name == null || !an.value) return;
    final q = _quellen[name];
    if (q == null) return;
    try {
      final s = SoLoud.instance;
      final h = s.play(q, volume: 0, looping: true);
      s.fadeVolume(h, atmosphaere, const Duration(milliseconds: 1500));
      _atmoGriff = h;
      _atmoName = name;
    } catch (_) {}
  }

  void _atmoStoppen() {
    final h = _atmoGriff;
    _atmoGriff = null;
    _atmoName = null;
    if (h == null || !_bereit) return;
    try {
      final s = SoLoud.instance;
      s.fadeVolume(h, 0, const Duration(milliseconds: 1200));
      s.scheduleStop(h, const Duration(milliseconds: 1300));
    } catch (_) {}
  }
}
