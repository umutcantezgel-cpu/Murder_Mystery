/// Kleine, tolerante Leser für die Ansichtskarten des Raums (`zustandFuer`).
/// Eine Ansicht ist eine einfache JSON-Karte; fehlt ein Feld oder hat es eine
/// unerwartete Form, liefern diese Leser leere Werte statt zu werfen.
library;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart' show Rng, Texte, befragungsKarten;
import 'package:mordakte_core/runden.dart' show Sitz;

import '../../party/stand/befragung_stand.dart';

Map<String, Object?> jMap(Object? v) => v is Map ? v.cast<String, Object?>() : const {};

List<Object?> jListe(Object? v) => v is List ? v : const [];

List<Map<String, Object?>> jMaps(Object? v) => [for (final e in jListe(v)) if (e is Map) e.cast<String, Object?>()];

List<String> jTexte(Object? v) => [for (final e in jListe(v)) if (e is String) e];

String jText(Object? v, [String sonst = '']) => v is String ? v : sonst;

int jZahl(Object? v, [int sonst = 0]) => v is int ? v : sonst;

/// Ein Platz am Tisch: Gastgeber oder Gast, mit seinem Sitz (Detektiv,
/// Erzähler, Rolle oder Assistenz).
class SpielerInfo {
  const SpielerInfo({
    required this.id,
    required this.name,
    required this.online,
    required this.bereit,
    this.rolle,
    this.istGastgeber = false,
    this.sitz,
    this.figur,
    this.wunsch,
  });

  final String id;
  final String name;
  final bool online;
  final bool bereit;

  /// Rolle (Kanon-Figur) nach dem Start; Detektiv, Erzähler und Assistenz haben keine.
  final String? rolle;
  final bool istGastgeber;

  /// Sitz am Abend (Langer Abend M3). In der Lobby nur Detektiv oder Erzähler
  /// (sonst `null`), ab dem Start auch Rolle oder Assistenz.
  final Sitz? sitz;

  /// Figur aus der Lobby-Zuteilung (nur vor dem Start); ohne Zuteilung lost der Start.
  final String? figur;

  /// Gewünschte Figur (nur vor dem Start), ein Hinweis für die Zuteilung.
  final String? wunsch;
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
        sitz: Sitz.lesen(s['sitz']),
        figur: s['figur'] is String ? s['figur'] as String : null,
        wunsch: s['wunsch'] is String ? s['wunsch'] as String : null,
      ),
  ];
}

/// Die Befragungskarten des Detektivs aus dem privaten Teil seiner Ansicht
/// (A-051, `befragung_modul.dart`): Fragen, Stand und die Antwort einer
/// App-Rolle erst nach der Frage, als Karten (R17, E-044). Gleich für den
/// Gastgeber und einen Gast auf dem Detektiv-Sitz.
List<BefragungKarte> befragungsKartenAus(Map<String, Object?> privat) {
  final offen = jZahl(privat['befragungenFrei']);
  return [
    for (final k in jMaps(privat['befragungen']))
      BefragungKarte(
        id: jText(k['id']),
        rolle: jText(k['rolle']),
        thema: jText(k['thema']),
        fragen: jTexte(k['fragen']),
        pflicht: k['pflicht'] == true,
        mensch: k['mensch'] == true,
        frage: k['frage'] is int ? k['frage'] as int : null,
        erledigt: k['erledigt'] == true,
        waehlbar: k['pflicht'] == true || k['frage'] is int || offen > 0,
        antwortKarten: k['antwort'] is List ? [for (final x in jListe(k['antwort'])) jTexte(x)] : null,
      ),
  ];
}

/// Das Notizbuch der Befragungen in der Ablage eines Online-Geräts (Gastgeber
/// und Gast-Detektiv): je beantworteter Befragung nur Kennung, Frage und Art.
List<Map<String, Object?>> notizenFuerAblage(Iterable<BefragungKarte> notizen) => [
      for (final k in notizen) {'id': k.id, 'frage': k.frage, 'pflicht': k.pflicht},
    ];

/// Liest [notizenFuerAblage] zurück. Die Antwort entsteht wieder aus den
/// Preisgaben der Akte ([befragungsKarten]), wie im Raum; Unbekanntes fällt weg.
Map<String, BefragungKarte> notizenAusAblage(Texte texte, Object? roh) => {
      for (final n in jMaps(roh))
        if (texte.sammlung.befragungen[jText(n['id'])] case final b?)
          if (n['frage'] case final int frage when frage >= 0 && frage < b.fragen.length)
            b.id: BefragungKarte(
              id: b.id, rolle: b.rolle, thema: b.thema, fragen: b.fragen, pflicht: n['pflicht'] == true,
              mensch: false, frage: frage, erledigt: true, waehlbar: false, antwortKarten: befragungsKarten(texte, b),
            ),
    };

String? _inhalt;

/// Inhaltskennung dieses Spielstands: Gastgeber und Gast müssen dieselbe haben,
/// sonst weist der Gastgeber den Beitritt ab (verschiedene Fassungen der App).
/// Sie folgt aus dem Verzeichnis der Akten (`content/party/akten.json`), das je Akte
/// eine Prüfsumme über alle ihre Inhalte trägt (`inhalt`, `tool/inhalt_kennung.py`).
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
