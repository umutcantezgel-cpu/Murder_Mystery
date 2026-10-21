import 'package:flutter/widgets.dart';

/// Erzähler-Begleiter (Langer Abend M3b): Reihum liest der Erzähler am eigenen
/// Handy statt am verdeckten Pult. Das Reihum-Gerät öffnet dafür einen Raum nur
/// mit dem Erzählersitz; der Erzähler tritt mit dem Code bei wie ein Gast. Die
/// Umsetzung mit Relais liegt bei den Online-Abenden
/// (`lib/abend/online/erzaehler_begleiter.dart`), die Sitzung kennt nur diese
/// Schnittstelle ([PartySitzung.begleitung]).
abstract class ErzaehlerBegleitung implements Listenable {
  /// Liest der Erzähler gerade am eigenen Handy (beigetreten und verbunden)?
  /// Dann zeigt das Reihum-Gerät statt der Texte „… liest vor“.
  bool get liest;

  /// Name, mit dem der Erzähler am Handy beigetreten ist (leer vor dem
  /// Beitritt). Das Gerät nennt ihn statt des Namens aus der Einrichtung.
  String get name;

  /// Zeigt Code und QR-Code zum Beitreten; öffnet den Raum beim ersten Mal.
  Future<void> zeigen(BuildContext context);

  /// Schließt den Raum; das Gerät liest wieder selbst (über das Pult).
  Future<void> schliessen();
}
