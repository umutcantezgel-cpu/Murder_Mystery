/// Besetzung eines Kammerspiel-Abends (E6, E7, MECH 4.6, 5.1, 9.13, 10.1,
/// ZR 0.2, ZR 13): Wer welches Heft bekommt, welche Tandems und welche
/// Solo-Rolle es gibt, ob das Abwesenheitsblatt nötig ist, welche Karten,
/// Marker und Tipp-Zettel gedruckt werden.
///
/// Zählweise: Personen = Rollen + Detektiv + Erzähler. Die Rollen werden in
/// Platzreihenfolge besetzt: Wer Platz k spielt, hat alle Plätze unter k am
/// Tisch. Bei ungerader Zahl von Zusatzrollen spielt die letzte ihr Tandem
/// allein; das ist immer der kleinere Platz eines Tandems.
library;

import 'inhalt.dart';
import 'platzhalter.dart';

/// Kennung des Detektivs bei Markern.
const String kammerDetektiv = 'detektiv';

/// Kennung von Herrn Schneider bei Markern.
const String kammerSchneider = 'schneider';

/// Ein Positions-Marker (MECH 10.2): wer und für welchen Zeitpunkt.
class KammerMarker {
  const KammerMarker(this.wer, this.platz, this.zeitpunkt);

  /// Rollen-ID, [kammerDetektiv] oder [kammerSchneider].
  final String wer;

  /// Platz der Rolle; null bei Detektiv und Herrn Schneider.
  final int? platz;

  /// Kennung aus fall.json `zeitpunkte` (`z2357`, `scheppern`).
  final String zeitpunkt;

  @override
  bool operator ==(Object other) =>
      other is KammerMarker && other.wer == wer && other.platz == platz && other.zeitpunkt == zeitpunkt;

  @override
  int get hashCode => Object.hash(wer, platz, zeitpunkt);

  @override
  String toString() => '$wer/$zeitpunkt';
}

/// Ein Tandem mit mindestens einer besetzten Rolle.
class KammerTandemBesetzung {
  const KammerTandemBesetzung(this.tandem, this.besetzt);
  final KammerTandem tandem;

  /// Die heute besetzten Plätze des Tandems (einer oder zwei).
  final List<KammerPlatz> besetzt;

  /// Nur ein Platz besetzt: Diese Rolle spielt ihr Tandem allein.
  bool get solo => besetzt.length == 1;
}

/// Besetzung für eine Personenzahl.
class KammerBesetzung {
  KammerBesetzung._(this.inhalt, this.personen, this.besetzt);

  /// Besetzung für [personen] (Rollen + Detektiv + Erzähler). Wirft
  /// [RangeError] außerhalb des Bereichs aus fall.json (6 bis 20).
  factory KammerBesetzung.fuer(KammerInhalt inhalt, {required int personen}) {
    final f = inhalt.fall;
    RangeError.checkValueInInterval(personen, f.personenMin, f.personenMax, 'personen');
    final rollen = personen - f.ohneRolle.length;
    return KammerBesetzung._(inhalt, personen, List.unmodifiable(f.plaetze.take(rollen)));
  }

  final KammerInhalt inhalt;

  /// Personen am Tisch.
  final int personen;

  /// Besetzte Plätze in Platzreihenfolge.
  final List<KammerPlatz> besetzt;

  /// Zahl der Rollen (Personen ohne Detektiv und Erzähler).
  int get rollen => besetzt.length;

  bool istBesetzt(String id) => besetzt.any((p) => p.id == id);

  Set<String> get besetzteIds => {for (final p in besetzt) p.id};

  /// Rollenhefte in Teil 10: besetzte Plätze 1–10.
  List<KammerPlatz> get hauptrollen => [for (final p in besetzt) if (p.art != KammerArt.zusatz) p];

  /// Zusatzhefte in Teil 12: besetzte Plätze 11–18.
  List<KammerPlatz> get zusatzrollen => [for (final p in besetzt) if (p.art == KammerArt.zusatz) p];

  /// Die vier Verdächtigen (immer besetzt): Fassungen in Teil 11.
  List<KammerPlatz> get verdaechtige => [for (final p in besetzt) if (p.art == KammerArt.verdaechtig) p];

  /// Zeugen 5–10, die heute niemand spielt, in Platzreihenfolge (E7).
  List<KammerPlatz> get fehlendeZeugen =>
      [for (final p in inhalt.fall.plaetze) if (p.art == KammerArt.zeuge && !besetzt.contains(p)) p];

  /// Das Abwesenheitsblatt gibt es genau dann, wenn ein Zeuge 5–10 fehlt (E7, MECH 5.1).
  bool get abwesenheitsblatt => fehlendeZeugen.isNotEmpty;

  /// Zeugenstreifen auf dem Abwesenheitsblatt, in Platzreihenfolge.
  List<KammerStreifen> get streifen => [for (final p in fehlendeZeugen) inhalt.streifenVon(p.id)];

  /// Aktionskarten fehlender Zeugen, die der Detektiv bekommt (MECH 4.6).
  List<KammerPlatz> get aktionskartenBeimDetektiv => fehlendeZeugen;

  /// Rollen, deren Geheimniskarte gedruckt wird: alle besetzten und alle
  /// fehlenden Zeugen 5–10; fehlende Zusatzrollen nicht (MECH 4.1, 10.1).
  List<KammerPlatz> get geheimniskarten =>
      [for (final p in inhalt.fall.plaetze) if (besetzt.contains(p) || fehlendeZeugen.contains(p)) p];

  /// Rollen, deren Aktionskarte gedruckt wird (wie [geheimniskarten]; die der
  /// fehlenden Zeugen mit dem Kopf „heute beim Detektiv“).
  List<KammerPlatz> get aktionskarten => geheimniskarten;

  /// Tandems mit mindestens einer besetzten Rolle, in Tandemreihenfolge.
  List<KammerTandemBesetzung> get tandems => [
        for (final t in inhalt.fall.tandems)
          if (t.plaetze.any((p) => p <= rollen))
            KammerTandemBesetzung(t, [for (final p in t.plaetze) if (p <= rollen) inhalt.platz(p)]),
      ];

  /// Die Zusatzrolle, die ihr Tandem heute allein spielt, sonst null.
  KammerPlatz? get solo {
    for (final t in tandems) {
      if (t.solo) return t.besetzt.single;
    }
    return null;
  }

  /// Tipp-Zettel: einer je Rolle und einer für den Erzähler; der Detektiv
  /// bekommt keinen (MECH 7.1, M-21).
  int get tippZettel => rollen + 1;

  /// Positions-Marker: zwei je besetzter Rolle, dazu zwei für den Detektiv und
  /// zwei für Herrn Schneider; für fehlende Rollen keine (MECH 10.2).
  List<KammerMarker> get marker {
    final zeiten = inhalt.fall.zeitpunkte;
    return [
      for (final p in besetzt)
        for (final z in zeiten) KammerMarker(p.id, p.platz, z),
      for (final m in inhalt.tisch.marker.feste)
        for (final z in zeiten) KammerMarker(m.wer, null, z),
    ];
  }

  /// Der Platz, der bei dieser Personenzahl neu dazukommt (Skalierung, MECH 9.13);
  /// bei der kleinsten Personenzahl null (dann sind es die vier Verdächtigen).
  KammerPlatz? get neuBesetzt => personen > inhalt.fall.personenMin ? besetzt.last : null;

  /// Ab hier laufen beim Verhörstuhl die anderen Gespräche leise weiter (R-02).
  bool get verhoerLeise => personen >= inhalt.fall.schwellen.verhoerLeiseAb;

  /// Gegenüberstellung in Runde 2 und 3, dazu „Wechsel!“ (MECH 1.3).
  bool get gegenueberstellung => personen >= inhalt.fall.schwellen.gegenueberstellungAb;

  /// Jede Person liest ihren Absatz „Die Rollen am Tisch“ selbst (MECH 8.4).
  bool get rollenAmTischSelbst => personen >= inhalt.fall.schwellen.rollenAmTischSelbstAb;

  /// Abschnitt b darf nach zwölf Minuten enden (MECH 1.3).
  bool get abschnittBKurz => personen <= inhalt.fall.schwellen.abschnittBKurzBis;

  /// Werte für [loeseKammerText] bei dieser Besetzung.
  KammerTextWerte textWerte({bool detektivWeiblich = false, Map<String, String> werte = const {}}) => KammerTextWerte(
        besetzt: besetzteIds,
        namen: {for (final p in inhalt.fall.plaetze) p.id: p.name},
        personen: personen,
        detektivWeiblich: detektivWeiblich,
        werte: werte,
      );

  /// Löst [text] für diese Besetzung auf (Platzhalter, nicht die Auszeichnung).
  String text(String text, {bool detektivWeiblich = false, Map<String, String> werte = const {}}) =>
      loeseKammerText(text, textWerte(detektivWeiblich: detektivWeiblich, werte: werte));
}
