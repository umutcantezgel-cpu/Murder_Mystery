import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  /// Liegt ein Abend ab? `null`, solange noch nicht nachgesehen wurde. Die
  /// Karten der Detektei hören darauf und zeigen sich, sobald sich das ändert.
  static final ValueNotifier<bool?> abgelegt = ValueNotifier(null);

  /// Der abgelegte Stand oder `null`.
  static Future<Map<String, Object?>?> lesen() async {
    Map<String, Object?>? stand;
    try {
      final roh = (await SharedPreferences.getInstance()).getString(schluessel);
      final d = roh == null ? null : jsonDecode(roh);
      stand = d is Map<String, Object?> && d['format'] == 'abendstand/1' ? d : null;
    } catch (_) {
      stand = null;
    }
    abgelegt.value = stand != null;
    return stand;
  }

  static Future<void> schreiben(PartySitzung s) async {
    abgelegt.value = true;
    try {
      await (await SharedPreferences.getInstance()).setString(schluessel, jsonEncode(s.abendstand));
    } catch (_) {}
  }

  static Future<void> loeschen() async {
    abgelegt.value = false;
    try {
      await (await SharedPreferences.getInstance()).remove(schluessel);
    } catch (_) {}
  }

  /// Baut den abgelegten Abend wieder auf (Akte, Erkundungsorte und Deck wie
  /// beim Anlegen). `null`, wenn keiner da ist oder er sich nicht mehr
  /// abspielen lässt; dann ist er verworfen. Scheitert nur das Laden der Akte
  /// (Speicher, Netz im Web), bleibt der Stand liegen und der Fehler kommt an.
  static Future<PartySitzung?> fortsetzen(MetaStore meta, [AssetBundle? bundle]) async {
    final stand = await lesen();
    if (stand == null) return null;
    final fall = stand['fall'];
    if (fall is! String) {
      await loeschen();
      return null;
    }
    final b = bundle ?? rootBundle;
    final daten = await PartyDaten.laden(b, fall: fall);
    final abstecher = await ladeAbstecher(fall, b);
    final katalog = await kartenBereit(meta, bundle);
    try {
      return PartySitzung.fortsetzen(daten, stand, katalog: katalog, abstecher: abstecher);
    } on FormatException catch (e) {
      debugPrint('ABEND fortsetzen verworfen: $e');
      await loeschen();
      return null;
    }
  }
}

/// Legt einen Abend nach jeder Änderung ab, gebündelt je Mikroaufgabe, auch
/// am Ende: Wird die App auf dem Schlussbild geschlossen (etwa beim Teilen),
/// lässt sich die Belohnung noch abholen. Weg ist der Stand nach [beenden]
/// (abgebrochen) oder, auf dem Weg zur Belohnung, sobald sie gebucht ist.
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
      unawaited(AbendSpeicher.schreiben(sitzung));
    });
  }

  /// Der Abend ist verlassen: nicht mehr ablegen und, mit [loeschen], den
  /// Stand löschen. Vor dem Entsorgen der Sitzung aufrufen.
  void beenden({bool loeschen = true}) {
    if (_aus) return;
    _aus = true;
    sitzung.removeListener(_geaendert);
    if (loeschen) unawaited(AbendSpeicher.loeschen());
  }
}
