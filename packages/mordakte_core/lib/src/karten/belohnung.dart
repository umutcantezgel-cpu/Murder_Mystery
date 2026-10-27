import '../util/rng.dart';
import 'karte.dart';

/// Ergebnis eines Abends aus Sicht eines Geräts (nach dem Finale bekannt).
class AbendErgebnis {
  final String akte;

  /// Salz des Abends (nach dem Finale offen) – Quelle des Kartenstroms.
  final String salz;
  final String spielerId;

  /// Gespielte Rolle (Kanon-Figur) oder `klasse:<name>` für den Detektiv.
  final String? rolle;
  final String pfad;
  final bool anklageRichtig;
  final String ende;

  /// Abstecher mit Erfolg oder Teilerfolg (Kennungen).
  final Set<String> abstecherFunde;

  /// Figuren, die an diesem Gerät am Tisch saßen (solo und reihum alle besetzten
  /// Rollen, beim Gastgeber eines Online-Abends ebenso). Gäste am eigenen Gerät
  /// lassen das leer: Sie bekommen die Karte ihrer eigenen Rolle.
  final Set<String> tischFiguren;

  /// Erfahrung aus der Einfluss-Schicht (Finale §3.10), nur bei Gästen eines Abends mit Schicht.
  final EinflussErfahrung? einfluss;

  const AbendErgebnis({
    required this.akte,
    required this.salz,
    required this.spielerId,
    required this.rolle,
    required this.pfad,
    required this.anklageRichtig,
    required this.ende,
    this.abstecherFunde = const {},
    this.tischFiguren = const {},
    this.einfluss,
  });

  /// Erfahrungspunkte des Abends ([xpFuer] mit [einfluss]).
  int get xp => xpFuer(ende, einfluss: einfluss);
}

/// Belohnung eines Abends: eine reine Funktion, deterministisch aus dem eigenen
/// Strom `karten:<salz>:<spielerId>` (getrennt von `wuerfel:` und `bot:`).
/// Jedes Gerät rechnet sie selbst nach dem Finale aus; online wie offline gleich.
///
/// - Immer: eine Karte der eigenen Rolle bzw. Klasse (unbesessene zuerst).
/// - Richtige Anklage: eine Karte der Täterfigur.
/// - Meister-Ende: eine legendäre Karte der Akte.
/// - Jeder gelungene Abstecher: die Karte dieses Fundorts (beim ersten Mal).
/// - Am Tisch ([AbendErgebnis.tischFiguren]): eine Rollenkarte einer dieser
///   Figuren, damit jede Figur auch ohne eigenes Gerät sammelbar ist. Sie wird
///   zuletzt gezogen, die übrigen Züge bleiben dadurch unverändert.
List<String> belohnungFuer(AbendErgebnis e, KartenKatalog katalog, Set<String> besitz) {
  final rng = Rng(Rng.hashString('karten:${e.salz}:${e.spielerId}'));
  final neu = <String>[];
  String? ziehe(List<KartenDef> pool) {
    final offen = [for (final k in pool) if (!besitz.contains(k.id) && !neu.contains(k.id)) k];
    final aus = offen.isNotEmpty ? offen : [for (final k in pool) if (!neu.contains(k.id)) k];
    if (aus.isEmpty) return null;
    aus.sort((a, b) => a.id.compareTo(b.id));
    return aus[rng.nextInt(aus.length)].id;
  }

  void nimm(String? id) {
    if (id != null) neu.add(id);
  }

  final rolle = e.rolle;
  if (rolle != null) {
    final akteFuerRolle = rolle.startsWith('klasse:') ? 'mordakte' : e.akte;
    nimm(ziehe([for (final k in katalog.vonFigur(akteFuerRolle, rolle)) if (k.hatQuelle('rolle')) k]));
  }
  if (e.anklageRichtig) {
    nimm(ziehe([for (final k in katalog.vonFigur(e.akte, e.pfad)) if (k.hatQuelle('taeter')) k]));
  }
  if (e.ende == 'ende_meister') {
    nimm(ziehe([for (final k in katalog.vonAkte(e.akte)) if (k.hatQuelle('meister')) k]));
  }
  for (final a in [...e.abstecherFunde]..sort()) {
    for (final k in katalog.vonAkte(e.akte)) {
      if (k.hatQuelle('abstecher', abstecher: a) && !besitz.contains(k.id) && !neu.contains(k.id)) neu.add(k.id);
    }
  }
  if (e.tischFiguren.isNotEmpty) {
    nimm(ziehe([
      for (final f in [...e.tischFiguren]..sort())
        for (final k in katalog.vonFigur(e.akte, f))
          if (k.hatQuelle('rolle')) k,
    ]));
  }
  return neu;
}

/// Was die Einfluss-Schicht einer Rolle am Abend einbrachte (Finale §3.10): erreichte Sterne, Stern des
/// Abends, Spürnase. Nur mit Schicht; der Detektiv bekommt keine (er zählt über das verschobene Ende).
class EinflussErfahrung {
  final int sterne;
  final bool sternDesAbends;
  final bool spuernase;
  const EinflussErfahrung({required this.sterne, this.sternDesAbends = false, this.spuernase = false});

  /// +15 je Stern, +25 Stern des Abends, +10 Spürnase.
  int get xp => 15 * sterne + (sternDesAbends ? 25 : 0) + (spuernase ? 10 : 0);
}

/// XP je Ende (Rang-Fortschritt der Detektei); mit [einfluss] (Gast eines Abends mit Einfluss-Schicht)
/// kommt dessen Erfahrung dazu. Ohne [einfluss] wie bisher.
int xpFuer(String ende, {EinflussErfahrung? einfluss}) =>
    switch (ende) {
      'ende_meister' => 300,
      'ende_teilerfolg' => 200,
      'ende_justizirrtum' => 120,
      _ => 80,
    } +
    (einfluss?.xp ?? 0);
