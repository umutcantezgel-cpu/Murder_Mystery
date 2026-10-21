import 'package:mordakte_core/mordakte_core.dart';

/// Eine Befragungskarte, wie der Detektiv sie sieht (A-051): wen er befragt,
/// worüber und mit welchen Fragen. Die Antwort steht nur bei Rollen, die die App
/// spricht, und erst nach der Frage. Gleich für Solo, reihum und den
/// Online-Gastgeber (dort aus der Ansicht des Raums).
class BefragungKarte {
  const BefragungKarte({
    required this.id,
    required this.rolle,
    required this.thema,
    required this.fragen,
    required this.pflicht,
    required this.mensch,
    required this.frage,
    required this.erledigt,
    required this.waehlbar,
    this.antwortKarten,
  });

  final String id, rolle, thema;
  final List<String> fragen;

  /// Feste Befragung (sonst frei wählbar).
  final bool pflicht;

  /// Spielt ein Mensch die Rolle? Dann antwortet er am Tisch, sonst die App.
  final bool mensch;

  /// Zuerst gestellte Frage (Index in [fragen]) oder null.
  final int? frage;
  final bool erledigt;

  /// Darf der Detektiv sie jetzt noch führen? Eine freie Befragung entfällt,
  /// wenn alle freien Wahlen getroffen sind.
  final bool waehlbar;

  /// Antwort der App als Karten (nur ohne Menschen, nur nach der Frage): je
  /// Preisgabe ihre Kurzfassung mit höchstens drei Stichpunkten (R17, E-044).
  final List<List<String>>? antwortKarten;

  /// Dieselbe Antwort als Stichpunkte hintereinander.
  List<String>? get antwort => antwortKarten == null ? null : [for (final k in antwortKarten!) ...k];

  bool get gefragt => frage != null;
}

/// Stand der Befragungen eines Abends an einem Gerät (Solo und reihum). Hält
/// nur, welche Frage gestellt und was erledigt ist ([BefragungsVerlauf]); die
/// Sitzung legt jeden Schritt als Befehl `befragt` ab. Im Solo spricht die App
/// jede Rolle, reihum antworten die Menschen am Tisch ([mensch]).
class BefragungStand {
  BefragungStand(this.texte, {required int rollen, required this.mensch})
      : verlauf = BefragungsVerlauf(Befragungsplan(texte), rollen);

  final Texte texte;
  final BefragungsVerlauf verlauf;

  /// Spielen Menschen die Rollen (reihum)? Im Solo antwortet die App.
  final bool mensch;

  /// Die Karten der Runde [runde]: erst die festen, dann die freien.
  List<BefragungKarte> karten(int runde) => [
        for (final id in [...verlauf.pflicht(runde), ...verlauf.frei(runde)]) _karte(runde, id),
      ];

  BefragungKarte _karte(int runde, String id) {
    final b = verlauf.text(id);
    return BefragungKarte(
      id: id,
      rolle: b.rolle,
      thema: b.thema,
      fragen: b.fragen,
      pflicht: verlauf.pflicht(runde).contains(id),
      mensch: mensch,
      frage: verlauf.frage(id),
      erledigt: verlauf.erledigt(id),
      waehlbar: verlauf.waehlbar(runde, id),
      antwortKarten: !mensch && verlauf.gefragt(id) ? befragungsKarten(texte, b) : null,
    );
  }

  /// Freie Wahlen, die in Runde [runde] noch offen sind.
  int freiOffen(int runde) => verlauf.freiOffen(runde);

  bool fertig(int runde) => verlauf.fertig(runde);

  /// Der Detektiv stellt in [runde] die Frage [frage] der Befragung [id]. Im Solo ist sie damit erledigt.
  void befragen(int runde, String id, int frage) => verlauf.befragen(runde, id, frage, sofort: !mensch);

  /// Die befragte Person hat am Tisch geantwortet.
  void erledigen(int runde, String id) => verlauf.erledigen(runde, id);

  /// Alle Antworten, die die App bisher gegeben hat, in der Reihenfolge der Fragen (Notizbuch).
  List<BefragungKarte> get aufgedeckt => [
        if (!mensch)
          for (final id in verlauf.gestellt) _karte(verlauf.text(id).runde, id),
      ];
}
