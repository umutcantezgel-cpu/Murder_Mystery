import '../util/rng.dart';

/// Ergebnisstufe eines Gelingenswurfs (K-07): Erfolg ≥ 9, Teilerfolg 7–8, Pech ≤ 6.
enum Stufe {
  erfolg('E', 'Lupe', 'Erfolg'),
  teilerfolg('T', 'Handy', 'Teilerfolg'),
  pech('P', 'Gespenst', 'Pech');

  final String kurz;

  /// Bild des Kellerwürfels (K-08): Darstellung, nie nur Farbe.
  final String bild;
  final String wort;
  const Stufe(this.kurz, this.bild, this.wort);
}

/// Schwellen und Modifikatorgrenzen des Würfels „stark“ (K-07, A-17).
class WuerfelRegel {
  static const int erfolgAb = 9;
  static const int teilerfolgAb = 7;
  static const int modMax = 2;

  /// Stufe aus der Summe 2W6 + Modifikator.
  static Stufe stufe(int summe) => summe >= erfolgAb
      ? Stufe.erfolg
      : summe >= teilerfolgAb
          ? Stufe.teilerfolg
          : Stufe.pech;

  /// Modifikator aus der abschließenden Liste (K-07): Werkzeug +1, „gründlich“ +2,
  /// Seifenblasen-Marke +1; begrenzt auf 0..+2. Sonst nichts.
  static int modifikator({required bool werkzeug, required bool gruendlich, required bool marke}) {
    var m = 0;
    if (werkzeug) m += 1;
    if (gruendlich) m += 2;
    if (marke) m += 1;
    return m > modMax ? modMax : m;
  }

  /// Modifikator mit Zuschlag der Einfluss-Schicht (Finale §3.4): [basis] nach K-07 plus [extra]
  /// (Tischwert und Umweg-Bonus), begrenzt auf [boden]..[deckel]. Ohne Zuschlag (`extra == 0`) genau
  /// [basis] – so bleibt jeder Wurf ohne Schicht unverändert (Golden-Schutz).
  static int gesamt(int basis, int extra, {required int boden, required int deckel}) {
    if (extra == 0) return basis;
    final m = basis + extra;
    return m < boden ? boden : (m > deckel ? deckel : m);
  }

  /// Chancen vor dem Wurf in Sechsunddreißigsteln (WÜ-2). Mit [garantie] (dritter
  /// Anlauf oder zwei Pech in Folge) ist Pech ausgeschlossen und zählt als Teilerfolg.
  static Map<Stufe, int> chancen36(int mod, {bool garantie = false}) {
    final n = {Stufe.erfolg: 0, Stufe.teilerfolg: 0, Stufe.pech: 0};
    for (var a = 1; a <= 6; a++) {
      for (var b = 1; b <= 6; b++) {
        var s = stufe(a + b + mod);
        if (garantie && s == Stufe.pech) s = Stufe.teilerfolg;
        n[s] = n[s]! + 1;
      }
    }
    return n;
  }

  /// Chancen in ganzen Prozent (Summe 100, größter Rest zuerst).
  static Map<Stufe, int> chancenProzent(int mod, {bool garantie = false}) {
    final c = chancen36(mod, garantie: garantie);
    final roh = {for (final e in c.entries) e.key: e.value * 100 / 36};
    final aus = {for (final e in roh.entries) e.key: e.value.floor()};
    var rest = 100 - aus.values.fold(0, (a, b) => a + b);
    final nachRest = roh.keys.toList()
      ..sort((x, y) {
        final d = (roh[y]! - aus[y]!).compareTo(roh[x]! - aus[x]!);
        return d != 0 ? d : x.index.compareTo(y.index);
      });
    for (final s in nachRest) {
      if (rest == 0) break;
      aus[s] = aus[s]! + 1;
      rest--;
    }
    return aus;
  }
}

/// Quelle der zwei Würfelaugen eines Anlaufs. Im Spiel nur [SalzWuerfel] (WÜ-1);
/// Prüfwerkzeuge setzen feste Ströme ein (immer Pech, immer Erfolg, neutral).
abstract class WuerfelQuelle {
  /// Zwei Augen 1..6 für den Anlauf [anlauf] (ab 1) der Entscheidung bzw. des Abstechers [id].
  (int, int) augen(String id, int anlauf);
}

/// Spielwürfel nach WÜ-1/K-23: `Rng(Rng.hashString('wuerfel:<salz>:<id>:<anlauf>'))`.
/// Gleiche Id für jede Option einer Entscheidung; keine laufende Wurfnummer.
class SalzWuerfel implements WuerfelQuelle {
  final String salz;
  const SalzWuerfel(this.salz);

  static String seedText(String salz, String id, int anlauf) => 'wuerfel:$salz:$id:$anlauf';

  @override
  (int, int) augen(String id, int anlauf) {
    final r = Rng(Rng.hashString(seedText(salz, id, anlauf)));
    return (r.nextInt(6) + 1, r.nextInt(6) + 1);
  }
}

/// Fester Strom für Beweise (C8 Nr. 1): jeder Wurf zeigt dieselben Augen.
class FesterWuerfel implements WuerfelQuelle {
  final int a;
  final int b;
  const FesterWuerfel(this.a, this.b);
  const FesterWuerfel.pech() : this(1, 1);
  const FesterWuerfel.erfolg() : this(6, 6);
  const FesterWuerfel.neutral() : this(3, 4);

  @override
  (int, int) augen(String id, int anlauf) => (a, b);
}

/// Ein protokollierter Wurf (WÜ-2: sichtbar und protokolliert).
class Wurf {
  final String id;
  final int anlauf;
  final int a;
  final int b;
  final int mod;
  final bool garantie;
  final Stufe stufe;

  const Wurf(this.id, this.anlauf, this.a, this.b, this.mod, this.garantie, this.stufe);

  int get summe => a + b + mod;

  /// Kanonische Protokollzeile (Determinismus WÜ-6).
  String get zeile => '$id#$anlauf:$a+$b+$mod${garantie ? 'G' : ''}=${stufe.kurz}';

  Map<String, Object> toJson() =>
      {'id': id, 'anlauf': anlauf, 'a': a, 'b': b, 'mod': mod, 'garantie': garantie, 'stufe': stufe.kurz};

  /// Wirft mit [quelle]; mit [garantie] wird Pech zum Teilerfolg (Pech-Garantie, K-10).
  static Wurf werfen(WuerfelQuelle quelle, String id, int anlauf, int mod, {required bool garantie}) {
    final (a, b) = quelle.augen(id, anlauf);
    var s = WuerfelRegel.stufe(a + b + mod);
    if (garantie && s == Stufe.pech) s = Stufe.teilerfolg;
    return Wurf(id, anlauf, a, b, mod, garantie, s);
  }
}
