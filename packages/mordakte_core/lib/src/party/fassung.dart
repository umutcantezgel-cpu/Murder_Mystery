/// Fassung eines Abends (Langer Abend M7b): der kurze Abend wie bisher oder
/// der lange Abend (~120 Min.) mit Streifzug durch die Welt-Ebenen, Vorspiel
/// und Morgen.
///
/// Die Fassung ist reine Darstellung und Zeit: Fall, Täterpfade, Lösung,
/// Punkte, Ende, Fakten, Würfe und Nachtminuten sind in beiden gleich. Sie liegt
/// in der Sitzung der App, in der Einrichtung und im Raum (Meta des
/// Gastgebers), nie in `Einstellungen`, `Spiel` oder `RundenPartie`. Nur Akten
/// mit der Fähigkeit `langfassung` (`content/party/akten.json`) bieten die Wahl
/// an; alle anderen bleiben kurz und unverändert.
library;

/// Kurzer oder langer Abend.
enum Abendfassung {
  /// Der Abend wie bisher: Rundenuhr nur in den Gesprächen.
  kurz,

  /// Der lange Abend: Die Rundenuhr deckt den ganzen Streifzug ab (Gespräche
  /// und Entscheidungen), dazu Vorspiel und Morgen.
  lang;

  /// Fassung aus ihrem Namen. Alles außer `lang` ist der kurze Abend: Spielstände
  /// und Räume ohne den Schlüssel (vor M7b, Altakten) bleiben so kurz.
  static Abendfassung lesen(Object? name) => name == lang.name ? lang : kurz;

  bool get istLang => this == lang;

  /// Rundendauern zur Wahl in Minuten: kurz die Gesprächsuhr, lang die Uhr des
  /// ganzen Streifzugs.
  List<int> get minutenOptionen => switch (this) {
        kurz => const [10, 15, 20],
        lang => const [20, 25, 30, 40],
      };

  /// Vorgabe der Rundendauer in Minuten.
  int get standardMinuten => switch (this) {
        kurz => 15,
        lang => 20,
      };
}

/// Bausteine der Zeitschätzung in Minuten (K-18, `planung/bollwerk/SPIELKERN.md`).
const abendEinrichtungMinuten = 10.0,
    abendIntroMinuten = 4.0,
    abendGeraetMinuten = 3.4,
    abendWahlMinuten = 5.0,
    abendResuemeeMinuten = 2.0,
    abendFinaleMinuten = 10.0,
    abendVorspielMinuten = 8.0,
    abendMorgenMinuten = 6.0;

/// Runden eines Abends.
const abendRunden = 3;

/// Vorgeschichte der Einstimmung in Minuten (A-063, SPEZIFIKATION §1).
const abendVorgeschichteMinuten = 5.0;

/// Einstimmung bei [rollen] Rollen in Minuten: die Vorgeschichte
/// ([abendVorgeschichteMinuten]) und die Vorstellung, bis 8 Rollen 2, bis 14
/// Rollen 4, darüber 6 Minuten.
double abendEinstimmungMinuten(int rollen) => abendVorgeschichteMinuten + (rollen <= 8 ? 2 : rollen <= 14 ? 4 : 6);

/// Geschätzte Länge eines Abends in Minuten, ungerundet (K-18).
///
/// K-18 schätzt den Abend als Einrichtung 10 + Einleitung 4 + drei Runden zu je
/// (Gespräch + Gerätezeit 3,4 + Gruppenwahl 5 + Resümee 2) + Finale 10.
/// - Kurz ist das Gespräch die Rundenuhr [rundenMinuten] (m):
///   `10 + 4 + 3 · (m + 3,4 + 5 + 2) + 10 = 55,2 + 3 · m`.
/// - Lang deckt die Uhr den ganzen Streifzug ab, also auch die Gerätezeit der
///   Entscheidungen; Vorspiel (8) und Morgen (6) kommen dazu:
///   `10 + 8 + 4 + 3 · (m + 5 + 2) + 10 + 6 = 59 + 3 · m`.
/// - Mit Einstimmung bei [einstimmungRollen] Rollen kommt
///   [abendEinstimmungMinuten] dazu; ohne (`null`) bleibt es bei den Werten oben.
double abendMinutenGenau(Abendfassung f, int rundenMinuten, {int? einstimmungRollen}) {
  final m = rundenMinuten.toDouble();
  final basis = switch (f) {
    Abendfassung.kurz => abendEinrichtungMinuten +
        abendIntroMinuten +
        abendRunden * (m + abendGeraetMinuten + abendWahlMinuten + abendResuemeeMinuten) +
        abendFinaleMinuten,
    Abendfassung.lang => abendEinrichtungMinuten +
        abendVorspielMinuten +
        abendIntroMinuten +
        abendRunden * (m + abendWahlMinuten + abendResuemeeMinuten) +
        abendFinaleMinuten +
        abendMorgenMinuten,
  };
  return einstimmungRollen == null ? basis : basis + abendEinstimmungMinuten(einstimmungRollen);
}

/// Geschätzte Länge eines Abends für die Anzeige „ca. X Min.“, gerundet auf
/// fünf Minuten ([abendMinutenGenau]): kurz 85/100/115, lang 120/135/150/180
/// für die Rundendauern der Fassung. Jede lange Schätzung liegt über jeder
/// kurzen, auch mit Einstimmung bei gleicher Rollenzahl ([einstimmungRollen]).
int abendMinutenCa(Abendfassung f, int rundenMinuten, {int? einstimmungRollen}) =>
    (abendMinutenGenau(f, rundenMinuten, einstimmungRollen: einstimmungRollen) / 5).round() * 5;
