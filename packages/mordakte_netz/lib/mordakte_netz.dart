/// Online-Spiel „jeder am eigenen Gerät“ ohne eigenen Server: Das Gastgebergerät
/// hält den autoritativen Raum, Supabase Realtime (Phoenix-Broadcast) ist nur
/// Zwischenträger, private Ansichten sind Ende-zu-Ende verschlüsselt.
///
/// Reines Dart, läuft auf VM und Web. Die lokale Test-Attrappe des Relais und
/// alles mit `dart:io` liegen getrennt in `package:mordakte_netz/io.dart`.
library;

export 'src/ablage.dart';
export 'src/krypto.dart';
export 'src/lokal.dart';
export 'src/phoenix.dart';
export 'src/protokoll.dart';
export 'src/relay_gast.dart';
export 'src/relay_host.dart';
export 'src/relay_standard.dart';
export 'src/umschlag.dart';
export 'src/verbindung.dart';
