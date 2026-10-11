/// Kleine, tolerante Leser für die Ansichtskarten des Raums (`zustandFuer`).
/// Eine Ansicht ist eine einfache JSON-Karte; fehlt ein Feld oder hat es eine
/// unerwartete Form, liefern diese Leser leere Werte statt zu werfen.
library;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart' show Rng;

Map<String, Object?> jMap(Object? v) => v is Map ? v.cast<String, Object?>() : const {};

List<Object?> jListe(Object? v) => v is List ? v : const [];

List<Map<String, Object?>> jMaps(Object? v) => [for (final e in jListe(v)) if (e is Map) e.cast<String, Object?>()];

List<String> jTexte(Object? v) => [for (final e in jListe(v)) if (e is String) e];

String jText(Object? v, [String sonst = '']) => v is String ? v : sonst;

int jZahl(Object? v, [int sonst = 0]) => v is int ? v : sonst;

/// Ein Platz am Tisch: Gastgeber, Gast oder Assistenz.
class SpielerInfo {
  const SpielerInfo({required this.id, required this.name, required this.online, required this.bereit, this.rolle, this.istGastgeber = false});

  final String id;
  final String name;
  final bool online;
  final bool bereit;

  /// Rolle (Kanon-Figur) nach dem Start; Gastgeber und Assistenz haben keine.
  final String? rolle;
  final bool istGastgeber;
}

/// Die Plätze aus der Ansicht (`spieler`); [host] ist die Kennung des Gastgebers (`host`).
List<SpielerInfo> spielerAusAnsicht(Map<String, Object?> v) {
  final host = v['host'];
  return [
    for (final s in jMaps(v['spieler']))
      SpielerInfo(
        id: jText(s['id']),
        name: jText(s['name']),
        online: s['online'] != false,
        bereit: s['bereit'] == true,
        rolle: s['rolle'] is String ? s['rolle'] as String : null,
        istGastgeber: s['id'] == host,
      ),
  ];
}

String? _inhalt;

/// Inhaltskennung dieses Spielstands: Gastgeber und Gast müssen dieselbe haben,
/// sonst weist der Gastgeber den Beitritt ab (verschiedene Fassungen der App).
/// Sie folgt aus dem Verzeichnis der Akten (`content/party/akten.json`).
Future<String> inhaltsKennung([AssetBundle? bundle]) async {
  final k = _inhalt;
  if (k != null && bundle == null) return k;
  try {
    final roh = await (bundle ?? rootBundle).loadString('content/party/akten.json');
    final wert = 'a${Rng.hashString(jsonEncode(jsonDecode(roh))).toRadixString(16)}';
    if (bundle == null) _inhalt = wert;
    return wert;
  } catch (_) {
    // Ohne lesbares Verzeichnis keine Prüfung (leer heißt: nicht prüfen).
    return '';
  }
}
