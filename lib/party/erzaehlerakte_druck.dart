import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart' show Kanon;
import 'package:mordakte_core/party_druck.dart';

import 'daten.dart';
import 'datei_knopf.dart' show FertigeDatei;
import 'druck_portraets.dart';

// Die Erzählerakte als PDF in der App (A-063): gesetzt wie mit
// `party_druck.dart --erzaehlerakte` der Kommandozeile, im festlichen Stil mit
// den Schriften aus dem Bündel und den Porträts aus dem Zeichner des Spiels
// (appDruckPortraets, 240 px statt 720 px). Die Porträts gehen vor dem Satz Bild
// für Bild in JPEG über, mit einer Pause dazwischen ([vorab]); so hält der Satz
// selbst die Oberfläche nur noch kurz an.
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
/// PNG-Kodierung im Browser oder ein unlesbares Bild), steht die Akte ohne Bilder da.
Future<ErzaehlerakteKontext?> erzaehlerakteKontext(PartyDaten daten, {required bool einfluss, required int rollen}) async {
  final akte = daten.erzaehlerakteFuer(einfluss: einfluss);
  if (akte == null) return null;
  final stil = await festStilAusBuendel();
  FestPortraets portraets;
  try {
    portraets = await vorab(daten.kanon, await appDruckPortraets(daten.kanon));
  } catch (e, st) {
    debugPrint('ERZAEHLERAKTE portraets fehler $e\n$st');
    portraets = FestPortraets(const {});
  }
  return ErzaehlerakteKontext(daten.kanon, daten.texte, akte, stil: stil, rollen: rollen, portraets: portraets);
}

/// Die Porträts [bilder] als `FestPortraets`, schon in JPEG umgerechnet, wie die
/// Erzählerakte sie setzt: jedes groß, die Figuren zusätzlich klein (Netz und
/// Bindungen). Zwischen zwei Bildern kommt die Oberfläche zum Zug; ohne das
/// rechnete der Satz alle Bilder am Stück um (gemessen 2,4 bis 3,0 s ohne Pause
/// bei 360 px). Die Datei bleibt dieselbe: `FestPortraets` merkt sich jedes Bild.
Future<FestPortraets> vorab(Kanon kanon, Map<String, Uint8List> bilder) async {
  final p = FestPortraets(bilder);
  final figuren = {for (final f in kanon.figuren) f['id'] as String};
  for (final id in bilder.keys) {
    for (final klein in [false, if (figuren.contains(id)) true]) {
      p.bild(id, klein: klein);
      await Future<void>.delayed(Duration.zero);
    }
  }
  return p;
}

/// Die Erzählerakte als fertige Datei (`erzaehlerakte.pdf`) für einen `DateiKnopf`.
Future<FertigeDatei> erzaehlerakteDatei(ErzaehlerakteKontext k) async {
  final d = await festErzaehlerakteDatei(k);
  return (name: d.name, bytes: d.bytes);
}
