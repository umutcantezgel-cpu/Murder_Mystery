import 'package:flutter/services.dart';
import 'package:mordakte_core/party_druck.dart';

// Das Kammerspiel in der App (ARCHITEKTUR A2, B1, B3): Der Kern lädt den Inhalt
// ohne `dart:io` ([KammerInhalt.ausJson]); die App liest dieselben Dateien wie
// die Kommandozeile ([kammerInhaltDateien] unter [kammerInhaltOrdner], in
// pubspec.yaml als Assets eingetragen) aus dem Bündel. So läuft die Druckmappe
// auch im Browser. Die Schriften des schlichten Drucks ([DruckStil]) kommen wie
// in der DruckTafel aus `assets/fonts`.

/// Gibt es zur Akte [akteId] ein Kammerspiel? Bisher nur zum Schlosskeller,
/// dessen Inhalt unter [kammerInhaltOrdner] liegt.
bool hatKammerspiel(String akteId) => kammerInhaltOrdner == 'content/kammerspiel/$akteId';

/// Lädt alle Inhaltsdateien des Kammerspiels aus [bundle] (Vorgabe:
/// `rootBundle`) und prüft sie streng ([KammerInhalt.ausJson]). Fehlt eine
/// Datei oder ein Feld, scheitert das Laden mit der Meldung des Kerns.
Future<KammerInhalt> kammerInhaltLaden([AssetBundle? bundle]) async {
  final b = bundle ?? rootBundle;
  final texte = await Future.wait([for (final d in kammerInhaltDateien) b.loadString('$kammerInhaltOrdner/$d')]);
  return KammerInhalt.ausJson({for (final (i, d) in kammerInhaltDateien.indexed) d: texte[i]});
}

/// Der schlichte Druckstil (E15) mit den drei Schriften aus `assets/fonts`, wie
/// die Kommandozeile ihn aus denselben Dateien baut.
Future<DruckStil> druckStilAusBuendel([AssetBundle? bundle]) async {
  final b = bundle ?? rootBundle;
  Future<Uint8List> schrift(String name) async {
    final d = await b.load('assets/fonts/$name');
    return d.buffer.asUint8List(d.offsetInBytes, d.lengthInBytes);
  }

  final (regular, fett, schreibmaschine) = await (schrift('Inter-Regular.ttf'), schrift('Inter-Bold.ttf'), schrift('SpecialElite-Regular.ttf')).wait;
  return DruckStil(regular: regular, fett: fett, schreibmaschine: schreibmaschine);
}

/// Inhalt und Stil zusammen: alles, was die Druckmappe für den Kontext braucht.
typedef KammerGrundlage = ({KammerInhalt inhalt, DruckStil stil});

/// Lädt Inhalt ([kammerInhaltLaden]) und Stil ([druckStilAusBuendel]) zugleich.
Future<KammerGrundlage> kammerGrundlageLaden([AssetBundle? bundle]) async {
  final (inhalt, stil) = await (kammerInhaltLaden(bundle), druckStilAusBuendel(bundle)).wait;
  return (inhalt: inhalt, stil: stil);
}

/// Personenzahl zu Beginn der Druckmappe: Die Gästeliste der Akte zählt die
/// Personen am Tisch ohne den Detektiv ([gaestePersonen], `null`: offen, dann
/// die Vorgabe des Falls, 10); im Kammerspiel spielen sie die Rollen, dazu
/// kommen Detektiv und Erzähler (E6). Liegt das außerhalb der Grenzen des Falls
/// (6 bis 20), gilt die nächste Grenze: Bei 19 oder 20 Gästen sind es 20
/// Personen, so nah an der Gästeliste wie möglich, nicht die Vorgabe 10.
int kammerPersonenVorgabe(KammerFall fall, int? gaestePersonen) {
  if (gaestePersonen == null) return fall.personenVorgabe;
  return (gaestePersonen + fall.ohneRolle.length).clamp(fall.personenMin, fall.personenMax).toInt();
}
