/// Lader des Kammerspiel-Inhalts für `dart:io` (CLI, Tests). Bewusst nicht von
/// `party_druck.dart` exportiert, damit die Web-App ohne `dart:io` bleibt; die
/// App lädt dieselben Dateien ([kammerInhaltDateien]) über `rootBundle` und
/// ruft [KammerInhalt.ausJson] selbst auf.
library;

import 'dart:io';

import 'src/party/druck/kammer/inhalt.dart';

export 'src/party/druck/kammer/besetzung.dart';
export 'src/party/druck/kammer/inhalt.dart';
export 'src/party/druck/kammer/platzhalter.dart';

/// Liest alle Inhaltsdateien als Text: ordner-relativer Pfad → Dateiinhalt.
/// [repoWurzel] ist das Verzeichnis, in dem `content/` liegt.
Map<String, String> leseKammerDateien(String repoWurzel) => {
      for (final d in kammerInhaltDateien) d: File('$repoWurzel/$kammerInhaltOrdner/$d').readAsStringSync(),
    };

/// Lädt und prüft den Kammerspiel-Inhalt aus dem Repo unter [repoWurzel].
KammerInhalt ladeKammerInhalt(String repoWurzel) => KammerInhalt.ausJson(leseKammerDateien(repoWurzel));
