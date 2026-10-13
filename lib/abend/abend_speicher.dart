import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart' show PartyPhase;
import 'package:shared_preferences/shared_preferences.dart';

import '../karten/katalog_laden.dart';
import '../meta/meta_store.dart';
import '../party/daten.dart';
import '../party/sitzung.dart';

/// Ablage des laufenden Abends auf dem Gerät (M8): der Abendstand der Sitzung
/// ([PartySitzung.abendstand]) nach jedem Schritt. Nur Solo und reihum; einen
/// Online-Abend legt der Gastgeberdienst selbst ab. Der Stand verlässt das
/// Gerät nie.
abstract final class AbendSpeicher {
  static const schluessel = 'mordakte.abendstand';

  /// Der abgelegte Stand oder `null`.
  static Future<Map<String, Object?>?> lesen() async {
    try {
      final roh = (await SharedPreferences.getInstance()).getString(schluessel);
      if (roh == null) return null;
      final stand = jsonDecode(roh);
      return stand is Map<String, Object?> && stand['format'] == 'abendstand/1' ? stand : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> schreiben(PartySitzung s) async {
    try {
      await (await SharedPreferences.getInstance()).setString(schluessel, jsonEncode(s.abendstand));
    } catch (_) {}
  }

  static Future<void> loeschen() async {
    try {
      await (await SharedPreferences.getInstance()).remove(schluessel);
    } catch (_) {}
  }

  /// Baut den abgelegten Abend wieder auf (Akte, Erkundungsorte und Deck wie
  /// beim Anlegen). `null`, wenn keiner da ist oder er sich nicht mehr
  /// abspielen lässt; dann ist er verworfen.
  static Future<PartySitzung?> fortsetzen(MetaStore meta, [AssetBundle? bundle]) async {
    final stand = await lesen();
    if (stand == null) return null;
    try {
      final fall = stand['fall'] as String;
      final b = bundle ?? rootBundle;
      final daten = await PartyDaten.laden(b, fall: fall);
      final abstecher = await ladeAbstecher(fall, b);
      final katalog = await kartenBereit(meta, bundle);
      return PartySitzung.fortsetzen(daten, stand, katalog: katalog, abstecher: abstecher);
    } catch (e) {
      debugPrint('ABEND fortsetzen fehler $e');
      await loeschen();
      return null;
    }
  }
}

/// Legt einen Abend nach jeder Änderung ab, gebündelt je Mikroaufgabe. Mit dem
/// Ende des Abends oder [beenden] (abgebrochen, zur Belohnung) ist der Stand weg.
class AbendAblage {
  AbendAblage(this.sitzung) {
    sitzung.addListener(_geaendert);
    _geaendert();
  }

  final PartySitzung sitzung;
  bool _geplant = false;
  bool _aus = false;

  void _geaendert() {
    if (_geplant || _aus) return;
    _geplant = true;
    scheduleMicrotask(() {
      _geplant = false;
      if (_aus) return;
      unawaited(sitzung.phase == PartyPhase.ende ? AbendSpeicher.loeschen() : AbendSpeicher.schreiben(sitzung));
    });
  }

  /// Der Abend ist verlassen: nicht mehr ablegen, den Stand löschen. Vor dem
  /// Entsorgen der Sitzung aufrufen.
  void beenden() {
    if (_aus) return;
    _aus = true;
    sitzung.removeListener(_geaendert);
    unawaited(AbendSpeicher.loeschen());
  }
}
