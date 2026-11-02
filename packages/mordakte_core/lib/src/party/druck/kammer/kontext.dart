/// Kontext des Kammerspiel-Drucks (ARCHITEKTUR A2): Inhalt, Besetzung, Stil,
/// Detektiv und die Spielernamen der App. Jeder sichtbare Text kommt aus dem
/// Inhalt unter `content/kammerspiel/schlosskeller/`: Spieltexte aus den
/// Inhaltsdateien, Beschriftungen aus `ui/*.json` ([KammerKontext.ui]). Kein
/// Teil erzeugt Text (F-11, `story_text_ausserhalb_test.dart`).
///
/// Platzhalter (`{rolle:…}`, `{wenn:…}`, `{ab:…}`, `{detektiv:…}`, `{wert}`)
/// löst [KammerKontext.text] je Besetzung auf; die Auszeichnung (`**fett**`,
/// `*kursiv*`, Zeilen, Absätze) setzen die Helfer in `satz.dart`.
library;

import '../satz_stil.dart';
import 'besetzung.dart';
import 'inhalt.dart';
import 'platzhalter.dart';
import 'satz.dart';

/// Alles, was ein Teil des Kammerspiels zum Setzen braucht.
class KammerKontext {
  /// Kontext für [personen] (Rollen + Detektiv + Erzähler, 6 bis 20; sonst
  /// [RangeError]) und Detektiv [detektiv] (`w` oder `m`; sonst
  /// [ArgumentError]). [spieler] ordnet Kanon-Figuren-IDs
  /// ([KammerPlatz.kanonFigur], wie in der Gästeliste der App) einen
  /// Spielernamen zu; er steht nur auf Knöpfen der App („Senden an …“), nie im
  /// PDF.
  KammerKontext(this.inhalt, {required int personen, required this.stil, String detektiv = 'w', Map<String, String> spieler = const {}})
      : besetzung = KammerBesetzung.fuer(inhalt, personen: personen),
        detektivWeiblich = switch (detektiv) {
          'w' => true,
          'm' => false,
          _ => throw ArgumentError.value(detektiv, 'detektiv', 'w oder m erwartet'),
        },
        spieler = Map.unmodifiable(spieler);

  final KammerInhalt inhalt;
  final KammerBesetzung besetzung;
  final DruckStil stil;

  /// Detektivin (`w`) oder Detektiv (`m`): `{detektiv:männlich|weiblich}`.
  final bool detektivWeiblich;

  /// Spielernamen je Kanon-Figuren-ID (nur für die App).
  final Map<String, String> spieler;

  /// Gemeinsame Satz-Helfer (Absätze, Kästen, Tabellen, Raster …).
  late final KammerSatz satz = KammerSatz(this);

  KammerFall get fall => inhalt.fall;

  /// Personen am Tisch.
  int get personen => besetzung.personen;

  /// `w` oder `m`.
  String get detektiv => detektivWeiblich ? 'w' : 'm';

  /// Der Fall-Code (fest U4YRK).
  String get fallCode => fall.fallCode;

  /// Die Rolle auf Platz [p].
  KammerRolle rolle(KammerPlatz p) => inhalt.rolle(p.id);

  /// Spielername der Person, die [p] spielt, oder null.
  String? spielerName(KammerPlatz p) => spieler[p.kanonFigur];

  /// Für Knöpfe „Senden an …“: der Spielername, sonst der Rollenname.
  String sendenAn(KammerPlatz p) => spielerName(p) ?? p.name;

  // ---------------------------------------------------------------- Texte

  /// Werte für [loeseKammerText] bei dieser Besetzung, mit [werte] für die
  /// Wert-Platzhalter.
  KammerTextWerte textWerte([Map<String, String> werte = const {}]) =>
      besetzung.textWerte(detektivWeiblich: detektivWeiblich, werte: werte);

  /// Löst die Platzhalter in [roh] für diese Besetzung auf; die Auszeichnung
  /// bleibt stehen. Ein schon aufgelöster Text bleibt gleich (Klammern gibt es
  /// außerhalb von Platzhaltern nicht). Fehlt ein Wert, wirft es [FormatException].
  String text(String roh, {Map<String, String> werte = const {}}) => loeseKammerText(roh, textWerte(werte));

  /// Löst [roh] auf; Einträge, die danach leer sind, fallen weg (SCHEMA §2).
  List<String> texte(Iterable<String> roh, {Map<String, String> werte = const {}}) => [
        for (final t in roh)
          if (kammerKlartext(text(t, werte: werte)).trim().isNotEmpty) text(t, werte: werte),
      ];

  /// [roh] aufgelöst und in Absätze, Zeilen und Läufe zerlegt.
  List<KammerAbsatz> absaetze(String roh, {Map<String, String> werte = const {}}) =>
      kammerAuszeichnung(text(roh, werte: werte));

  /// [roh] aufgelöst, ohne Auszeichnung (für Überschriften, Dateinamen, Messungen).
  String klartext(String roh, {Map<String, String> werte = const {}}) => kammerKlartext(text(roh, werte: werte));

  /// Ob [roh] nach dem Auflösen leer ist (dann fällt der Eintrag weg).
  bool leer(String roh, {Map<String, String> werte = const {}}) => klartext(roh, werte: werte).trim().isEmpty;

  /// Beschriftung `ui/<teil>.json` → [schluessel], aufgelöst mit [werte]
  /// (`{code}`, `{name}` …). [teil] ist `gemeinsam` oder eine Teilnummer aus
  /// [kammerTeile]. Fehlt der Schlüssel oder ein Wert, wirft es
  /// [ArgumentError] mit Datei und Schlüssel.
  String ui(String teil, String schluessel, [Map<String, String> werte = const {}]) {
    final roh = inhalt.uiText(teil, schluessel);
    try {
      return text(roh, werte: werte);
    } on FormatException catch (e) {
      throw ArgumentError('ui/$teil.json: $schluessel: ${e.message}');
    }
  }

  /// Beschriftung aus `ui/gemeinsam.json` (Kopf, Fuß, `heft.*`, `karte.*` …).
  String uiGemeinsam(String schluessel, [Map<String, String> werte = const {}]) => ui('gemeinsam', schluessel, werte);

  /// Ob `ui/<teil>.json` den Schlüssel kennt.
  bool hatUi(String teil, String schluessel) => inhalt.ui[teil]?.containsKey(schluessel) ?? false;

  /// Titel des Falls („Spuk im Schlosskeller“).
  String get fallTitel => uiGemeinsam('fall.titel');

  /// Titel des Spiels („Kammerspiel“).
  String get spielTitel => uiGemeinsam('spiel.titel');

  /// Titel von Teil [teil] (`ui/<teil>.json` → `titel`).
  String teilTitel(String teil) => ui(teil, 'titel');

  /// Kopfzeile bzw. Dokumenttitel: Fall · Spiel · [titel] (`ui/gemeinsam.json` → `kopf`).
  String kopfText(String titel) => kammerKlartext(uiGemeinsam('kopf', {'fall': fallTitel, 'spiel': spielTitel, 'teil': titel}));
}
