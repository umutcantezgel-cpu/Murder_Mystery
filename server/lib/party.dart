/// Adapter des gemeinsamen, transportfreien Schlosskeller-Abends auf den
/// vorhandenen Server-Lebenszyklus. Authentifizierung und Reconnect bleiben im
/// RoomManager, private Daten bleiben in der Empfänger-Projektion des Kerns.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'runtime.dart';

class SchlosskellerRuntime implements AbendRuntime {
  SchlosskellerRuntime(this.inner, {int Function()? abendzeit}) : abendzeit = abendzeit ?? _wanduhr;
  final SchlosskellerRaum inner;
  final Map<String, int> _gesendet = {};

  /// Uhr des Abends (ms): Der Server stempelt jeden Befehl beim Annehmen damit
  /// (Feld `zeit`, gemeinsame Rundenuhr); was ein Gerät mitschickt, gilt nie.
  final int Function() abendzeit;

  static int _wanduhr() => DateTime.now().millisecondsSinceEpoch;

  /// Kennung der Akte (der Raum spielt jede Akte des Spiels).
  @override
  String get abend => inner.akte;
  @override
  int get maxPlayers => inner.maxSpieler;
  @override
  List<String> get humanPlayers => inner.spielerIds;
  @override
  bool get inLobby => inner.vorStart;
  @override
  bool get finished => inner.beendet;
  @override
  bool join(String playerId, String name) => inner.beitreten(playerId, name);
  @override
  void leave(String playerId) { inner.verlassen(playerId); _gesendet.remove(playerId); }
  @override
  void setConnected(String playerId, bool connected) => inner.verbunden(playerId, connected);
  @override
  void tick(int dtMs) {} // Entscheidungen treiben den Abend, nicht die Wandzeit.
  @override
  List<GameEvent> drainEvents(String playerId) => const [];

  @override
  Map<String, Object?>? stateFor(String playerId, {bool force = false}) {
    if (!force && _gesendet[playerId] == inner.version) return null;
    final state = inner.zustandFuer(playerId);
    _gesendet[playerId] = inner.version;
    return state;
  }

  @override
  String? applyAbendCommand(String playerId, Map<String, Object?> command) {
    try {
      inner.nachricht(playerId, mitAbendzeit(command, abendzeit()));
      return null;
    } on PartyRaumFehler catch (error) {
      return error.code;
    }
  }
}

String resolvePartyDir(String? fromEnv) {
  if (fromEnv != null && fromEnv.trim().isNotEmpty) return fromEnv.trim();
  for (final path in [
    '/app/content/party/schlosskeller',
    if (Platform.script.scheme == 'file') Platform.script.resolve('../../content/party/schlosskeller').toFilePath(),
    '../content/party/schlosskeller',
    'content/party/schlosskeller',
  ]) {
    if (Directory(path).existsSync()) return Directory(path).absolute.path;
  }
  throw const FormatException('Schlosskeller-Kanon fehlt; PARTY_DIR muss auf den Kanonordner zeigen.');
}

/// Liest nur die vom Kanon/Textindex vorgegebenen Dateien. Kein Dateipfad und
/// kein Fall-Code stammen aus einer Client-Nachricht. Kein Fallback-Spiel, falls
/// die Deployment-Dateien fehlen: Der Server soll dann nicht bereit melden.
///
/// Server-Räume haben keine Meta: Sie spielen den kurzen Abend. [fassung] lang
/// nutzt nur die Party-Matrix für ihren Lauf mit dem langen Abend (M7b).
RuntimeFactory loadSchlosskellerFactory(String dir, {Abendfassung fassung = Abendfassung.kurz}) {
  Map<String, Object?> lesen(String path) => (jsonDecode(File('$dir/$path').readAsStringSync()) as Map).cast<String, Object?>();
  final kanon = Kanon.lade(lesen);
  final texte = Texte(kanon, Textsammlung.lade(lesen));
  final zufall = Random.secure();
  // Diashow zur Einleitung (M4) liegt neben dem Kanon unter content/welt/.
  final dia = File('${Directory(dir).parent.parent.path}/welt/schlosskeller/diashow.json');
  final dias = dia.existsSync() ? Diashow.ausJson((jsonDecode(dia.readAsStringSync()) as Map).cast<String, Object?>()).dias.length : 0;
  // Streifzug (M7b): Der lange Abend bringt die Erkundung aus welt.json mit.
  final erkundung = fassung.istLang ? ladeErkundung('${Directory(dir).parent.parent.path}/welt/schlosskeller') : null;
  return (roomCode) => SchlosskellerRuntime(SchlosskellerRaum(
    raumCode: roomCode, kanon: kanon, texte: texte, diaAnzahl: dias, fassung: fassung, erkundung: erkundung,
    // Wer den Raum öffnet, sitzt zuerst auf dem Detektiv-Sitz; `sitz` ändert es in der Lobby.
    gastgeberSitz: Sitz.detektiv,
    fallCode: FallCode.zufall(Rng(zufall.nextInt(1 << 32))),
    salz: [for (var i = 0; i < 32; i++) zufall.nextInt(256).toRadixString(16).padLeft(2, '0')].join(),
  ));
}


/// Die Erkundung einer Akte aus ihrem Welt-Ordner ([weltDir], `welt.json` →
/// `erkundung`), sonst `null`.
Erkundung? ladeErkundung(String weltDir) {
  final welt = File('$weltDir/welt.json');
  if (!welt.existsSync()) return null;
  final datei = (jsonDecode(welt.readAsStringSync()) as Map)['erkundung'];
  if (datei is! String) return null;
  return Erkundung.ausJson((jsonDecode(File('$weltDir/$datei').readAsStringSync()) as Map).cast<String, Object?>());
}

/// Fabriken für alle Akten aus `content/party/akten.json` (ein Spiel, viele
/// Akten). [partyDir] ist der Schlosskeller-Ordner; daneben liegen die übrigen
/// Akten, `zusatz/` (Erkundungsorte) und zwei Ebenen höher `content/karten/`.
Map<String, RuntimeFactory> loadAktenFactories(String partyDir) {
  final root = Directory(partyDir).parent.path;
  Map<String, Object?> json(String path) => (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();
  final index = File('$root/akten.json');
  final ids = index.existsSync()
      ? [for (final a in (json(index.path)['akten'] as List)) (a as Map)['id'] as String]
      : ['schlosskeller'];
  final kartenDir = Directory('${Directory(root).parent.path}/karten');
  final katalog = KartenKatalog.ausDateien([
    if (kartenDir.existsSync())
      for (final f in kartenDir.listSync().whereType<File>())
        if (f.path.endsWith('.json') && !f.path.endsWith('.schema.json')) json(f.path),
  ]);
  // Fehlende ui-Texte der übrigen Akten kommen aus der eingefrorenen Basis (A-061).
  final basis = Textsammlung.lade((p) => json('$root/basis-ui/$p'));
  final zufall = Random.secure();
  return {
    for (final id in ids)
      id: () {
        final dir = '$root/$id';
        Map<String, Object?> lesen(String path) => json('$dir/$path');
        final kanon = Kanon.lade(lesen);
        final sammlung = Textsammlung.lade(lesen);
        if (id != 'schlosskeller') sammlung.ergaenzeUi(basis);
        final texte = Texte(kanon, sammlung);
        final ab = File('$root/zusatz/$id/abstecher.json');
        final abstecher = ab.existsSync() ? AbstecherOrt.liste(json(ab.path)) : const <AbstecherOrt>[];
        // Diashow zur Einleitung (M4): Der Raum braucht nur die Zahl der Bilder.
        final dia = File('${Directory(root).parent.path}/welt/$id/diashow.json');
        final dias = dia.existsSync() ? Diashow.ausJson(json(dia.path)).dias.length : 0;
        return (String roomCode) => SchlosskellerRuntime(SchlosskellerRaum(
              raumCode: roomCode, kanon: kanon, texte: texte, akte: id, katalog: katalog, abstecher: abstecher, diaAnzahl: dias,
              gastgeberSitz: Sitz.detektiv,
              fallCode: FallCode.zufall(Rng(zufall.nextInt(1 << 32))),
              salz: [for (var i = 0; i < 32; i++) zufall.nextInt(256).toRadixString(16).padLeft(2, '0')].join(),
            ));
      }(),
  };
}
