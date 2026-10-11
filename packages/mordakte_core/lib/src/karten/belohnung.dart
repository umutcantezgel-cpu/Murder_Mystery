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

  const AbendErgebnis({
    required this.akte,
    required this.salz,
    required this.spielerId,
    required this.rolle,
    required this.pfad,
    required this.anklageRichtig,
    required this.ende,
    this.abstecherFunde = const {},
  });
}

/// Belohnung eines Abends: eine reine Funktion, deterministisch aus dem eigenen
/// Strom `karten:<salz>:<spielerId>` (getrennt von `wuerfel:` und `bot:`).
/// Jedes Gerät rechnet sie selbst nach dem Finale aus; online wie offline gleich.
///
/// - Immer: eine Karte der eigenen Rolle bzw. Klasse (unbesessene zuerst).
/// - Richtige Anklage: eine Karte der Täterfigur.
/// - Meister-Ende: eine legendäre Karte der Akte.
/// - Jeder gelungene Abstecher: die Karte dieses Fundorts (beim ersten Mal).
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
  return neu;
}

/// XP je Ende (Rang-Fortschritt der Detektei).
int xpFuer(String ende) => switch (ende) {
      'ende_meister' => 300,
      'ende_teilerfolg' => 200,
      'ende_justizirrtum' => 120,
      _ => 80,
    };
