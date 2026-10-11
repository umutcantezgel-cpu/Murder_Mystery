// ignore_for_file: avoid_print
// Lokale Attrappe des Relais für den Browser-Lauf (tool/e2e/geraete.mjs).
// Startet die Phoenix-Attrappe aus mordakte_netz auf 127.0.0.1 und läuft, bis sie
// beendet wird. Die Seite bekommt sie über `?relay=ws://127.0.0.1:<port>`.
// Aufruf: cd server && dart run ../tool/e2e/attrappe.dart [port]
import 'dart:async';

import 'package:mordakte_netz/io.dart';

Future<void> main(List<String> args) async {
  final port = args.isEmpty ? 4455 : int.parse(args.first);
  final attrappe = await PhoenixAttrappe.starten(port: port);
  final ws = attrappe.url.replaceFirst('http://', 'ws://');
  print('Attrappe läuft: $ws');
  print('Relais-Parameter: ?relay=$ws');
  // Läuft, bis der Prozess beendet wird (Ctrl+C oder vom Testlauf aus).
  await Completer<void>().future;
}
