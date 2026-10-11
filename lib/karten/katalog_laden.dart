import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart' show LookDef, renderLook;
import 'package:mordakte_core/runden.dart';

import '../meta/meta_store.dart';

/// Ordner der Kartendateien (`content/karten/<akte>.json`).
const kartenOrdner = 'content/karten/';

/// Kartendateien, falls das Asset-Verzeichnis nicht lesbar ist (z. B. in Tests
/// mit eigenem Bündel ohne Manifest).
const _bekannteDateien = ['content/karten/mordakte.json', 'content/karten/schlosskeller.json'];

Future<KartenKatalog>? _katalogZwischen;

/// Lädt alle `content/karten/*.json` (ohne `*.schema.json`) in einen
/// [KartenKatalog]. Die Dateien werden über das AssetManifest gefunden, damit
/// eine neue Akte ohne Codeänderung erscheint. Das Standardbündel wird einmal
/// gelesen; ein Fehler bleibt nicht im Zwischenspeicher.
Future<KartenKatalog> ladeKartenKatalog([AssetBundle? bundle]) {
  if (bundle != null) return _ladeKatalog(bundle);
  final f = _katalogZwischen ??= _ladeKatalog(rootBundle);
  f.catchError((Object _) {
    if (identical(_katalogZwischen, f)) _katalogZwischen = null;
    return KartenKatalog(const []);
  });
  return f;
}

/// Lädt den Katalog und legt das Kartenkonto des Geräts an (Startset, einmalig).
/// Die Oberfläche ruft das beim Öffnen von Sammlung, Deck, Assistent und
/// Belohnung auf; mehrfaches Aufrufen schadet nicht.
Future<KartenKatalog> kartenBereit(MetaStore meta, [AssetBundle? bundle]) async {
  final katalog = await ladeKartenKatalog(bundle);
  meta.initKarten(katalog);
  return katalog;
}

/// Verwirft den Zwischenspeicher (nur für Tests mit wechselndem Inhalt).
@visibleForTesting
void vergisKartenKatalog() => _katalogZwischen = null;

Future<KartenKatalog> _ladeKatalog(AssetBundle bundle) async {
  final pfade = await kartenDateien(bundle);
  final dateien = await Future.wait(pfade.map((p) async => jsonDecode(await bundle.loadString(p)) as Map<String, Object?>));
  return KartenKatalog.ausDateien(dateien);
}

/// Pfade aller Kartendateien im Bündel, sortiert (stabile Reihenfolge).
Future<List<String>> kartenDateien(AssetBundle bundle) async {
  List<String> pfade;
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    pfade = manifest.listAssets().where(_istKartendatei).toList();
  } catch (_) {
    pfade = const [];
  }
  if (pfade.isEmpty) pfade = [..._bekannteDateien];
  pfade.sort();
  return pfade;
}

bool _istKartendatei(String p) => p.startsWith(kartenOrdner) && p.endsWith('.json') && !p.endsWith('.schema.json');

/// Erkundungsorte einer Akte aus `content/party/zusatz/<akte>/abstecher.json`;
/// ohne Datei (oder bei Fehlern) keine Orte.
Future<List<AbstecherOrt>> ladeAbstecher(String akte, [AssetBundle? bundle]) async {
  try {
    final text = await (bundle ?? rootBundle).loadString('content/party/zusatz/$akte/abstecher.json');
    return AbstecherOrt.liste(jsonDecode(text) as Map<String, Object?>);
  } catch (_) {
    return const [];
  }
}

/// Anzeige einer Kartenfigur: Name und, falls vorhanden, das Aussehen für die Büste.
class KartenFigur {
  const KartenFigur(this.id, this.name, {this.look, this.titel = '', this.farbe});

  final String id;
  final String name;
  final LookDef? look;

  /// Farbcode der Figur (Kanon `colorCode`), falls lesbar.
  final Color? farbe;

  /// Rollentitel (z. B. „Der Organisator“), falls bekannt.
  final String titel;
}

/// Figuren einer Akte aus `content/party/<akte>/figuren.json` (Name, Titel,
/// Aussehen). Fehlt die Datei (z. B. bei `mordakte`), bleibt die Karte leer.
Future<Map<String, KartenFigur>> ladeKartenFiguren(String akte, [AssetBundle? bundle]) async {
  try {
    final text = await (bundle ?? rootBundle).loadString('content/party/$akte/figuren.json');
    final j = jsonDecode(text) as Map<String, Object?>;
    final aus = <String, KartenFigur>{};
    // Auch das Opfer hat Karten (z. B. Herr Schneider); es steht hinter den Rollen.
    for (final f in [...(j['figuren'] as List? ?? const []), if (j['opfer'] is Map) j['opfer']]) {
      final m = (f as Map).cast<String, Object?>();
      final id = m['id'] as String;
      LookDef? look;
      try {
        look = LookDef.fromJson(renderLook(m));
      } catch (_) {
        look = null;
      }
      Color? farbe;
      final code = m['colorCode'];
      if (code is String && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(code)) {
        farbe = Color(int.parse(code.substring(1), radix: 16) | 0xFF000000);
      }
      aus[id] = KartenFigur(id, m['name'] as String? ?? id, look: look, titel: (m['roleTitle'] ?? '') as String, farbe: farbe);
    }
    return aus;
  } catch (_) {
    return const {};
  }
}

/// Figuren aller Akten des Katalogs (ohne die Detektivklassen `mordakte`),
/// je Akte-Kennung. So zeigen Sammlung, Deck und Belohnung dieselben Büsten.
Future<Map<String, Map<String, KartenFigur>>> ladeAlleKartenFiguren(KartenKatalog katalog, [AssetBundle? bundle]) async {
  final ids = {for (final k in katalog.alle) k.akte}..remove('mordakte');
  final aus = <String, Map<String, KartenFigur>>{};
  await Future.wait([for (final id in ids) ladeKartenFiguren(id, bundle).then((m) => aus[id] = m)]);
  return aus;
}

/// Figur zu einer Karte aus [figuren] (siehe [ladeAlleKartenFiguren]) oder null.
KartenFigur? kartenFigurVon(Map<String, Map<String, KartenFigur>> figuren, KartenDef k) => figuren[k.akte]?[k.figur];
