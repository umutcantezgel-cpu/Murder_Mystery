import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/party_druck.dart';

import 'daten.dart';
import 'datei_knopf.dart' show FertigeDatei;
import 'druck_portraets.dart';

// Die Erzählerakte als PDF in der App (A-063): gesetzt wie mit
// `party_druck.dart --erzaehlerakte` der Kommandozeile, im festlichen Stil mit
// den Schriften aus dem Bündel und den Porträts aus dem Zeichner des Spiels
// (appDruckPortraets, 360 px statt 720 px).
//
// Die Akte kommt immer über PartyDaten.erzaehlerakteFuer: ohne „Dein Moment“
// mit den Zielen des Kanons, mit der Schicht mit ihren Sternen. Kein Druck-Satz,
// kein Fall-Code: In allen Pfaden entsteht dieselbe Datei. Sie nennt nie den
// Täter und gehört nur der Person, die erzählt; anbieten dürfen sie nur die
// Druckmappe und die Erzählerakte des Abends am Erzähler-Platz.

/// Der festliche Stil mit den sieben Schriften aus `assets/fonts` (wie `festStil`
/// der Kommandozeile).
Future<FestStil> festStilAusBuendel([AssetBundle? bundle]) async {
  final b = bundle ?? rootBundle;
  Future<Uint8List> schrift(String name) async {
    final d = await b.load('assets/fonts/$name');
    return d.buffer.asUint8List(d.offsetInBytes, d.lengthInBytes);
  }

  return FestStil(
    titel: await schrift('PlayfairDisplay-Variabel.ttf'),
    text: await schrift('Lora-Variabel.ttf'),
    kursiv: await schrift('Lora-Kursiv-Variabel.ttf'),
    hand: await schrift('Caveat-Variabel.ttf'),
    maschine: await schrift('SpecialElite-Regular.ttf'),
    funktion: await schrift('Inter-Regular.ttf'),
    funktionStark: await schrift('Inter-SemiBold.ttf'),
  );
}

/// Was die Erzählerakte von [daten] zum Setzen braucht, für [rollen] Personen;
/// [einfluss]: Spielt der Abend „Dein Moment“ (Sterne als Ziele)? `null`, wenn
/// die Akte keine Erzählerakte hat. Scheitern die Porträts (etwa die
/// PNG-Kodierung im Browser), steht die Akte ohne Bilder da.
Future<ErzaehlerakteKontext?> erzaehlerakteKontext(PartyDaten daten, {required bool einfluss, required int rollen}) async {
  final akte = daten.erzaehlerakteFuer(einfluss: einfluss);
  if (akte == null) return null;
  final stil = await festStilAusBuendel();
  Map<String, Uint8List> bilder;
  try {
    bilder = await appDruckPortraets(daten.kanon);
  } catch (e, st) {
    debugPrint('ERZAEHLERAKTE portraets fehler $e\n$st');
    bilder = const {};
  }
  return ErzaehlerakteKontext(daten.kanon, daten.texte, akte, stil: stil, rollen: rollen, portraets: FestPortraets(bilder));
}

/// Die Erzählerakte als fertige Datei (`erzaehlerakte.pdf`) für einen `DateiKnopf`.
Future<FertigeDatei> erzaehlerakteDatei(ErzaehlerakteKontext k) async {
  final d = await festErzaehlerakteDatei(k);
  return (name: d.name, bytes: d.bytes);
}
