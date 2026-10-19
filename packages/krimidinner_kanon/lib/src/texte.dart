/// Oberflächentexte des Begleiters „Spuk im Gewölbe“ (deutsch, duzend).
///
/// Hier stehen nur Bedientexte und Überschriften. Alle Spieltexte kommen zur
/// Laufzeit aus dem Kanon; kein Kanonsatz steht im Dart-Code.
library;

/// Texte des Begleiters. Platzhalter sind Funktionen.
abstract final class GewoelbeTexte {
  // Kopf und Laden -------------------------------------------------------------
  static const titel = 'Spuk im Gewölbe';
  static const untertitel = 'Krimidinner auf Burg Schartenfels';
  static const marke = 'Partyabend';
  static const laden = 'Die Mappen werden aus dem Kanon gelesen …';
  static const ladeFehler = 'Der Kanon des Krimidinners ließ sich nicht lesen.';
  static const zurueck = 'Zurück';

  // Teile ----------------------------------------------------------------------
  static const teilUeberblick = 'Überblick';
  static const teilBesetzung = 'Besetzung';
  static const teilSteckbriefe = 'Steckbriefe';
  static const teilMappen = 'Mappen';
  static const teilDruck = 'Druck';

  // Überblick ------------------------------------------------------------------
  static const hinweisStufe =
      'Den geführten Abend mit Erzähler gibt es hier noch nicht. '
      'Besetzung, Steckbriefe und Rollenmappen kannst du schon nutzen.';
  static const geschichte = 'Die Geschichte';
  static const burg = 'Die Burg';
  static const werInDerBurg = 'Wer in der Burg ist';
  static const burgwart = 'Der Burgwart';
  static const werMitspielt = 'Wer mitspielt';
  static const werMitspieltText =
      '4 bis 20 Rollen und das Geburtstagskind als Detektiv';
  static const ablauf = 'Ablauf';
  static const ablaufMinuten =
      'Zahlen ohne Einheit sind Minuten. Wie lang Gesprächsfenster und '
      'Lagerunde dauern, hängt von der Zahl der Rollen ab (siehe „Gespräche“).';
  static const dauer = 'Dauer';
  static const gespraecheRegeln = 'Gespräche';
  static const luegenRegeln = 'Regeln zum Lügen';
  static const aufklappen = 'Aufklappen';
  static const zuklappen = 'Zuklappen';
  static const alleAufklappen = 'Alle aufklappen';
  static const alleZuklappen = 'Alle zuklappen';
  static const besetzungAendern = 'Besetzung ändern';

  // Besetzung ------------------------------------------------------------------
  /// Mit festen Leerzeichen: Der Strich bleibt am Wort davor, die Zahl bei
  /// „Personen“. Umbrochen wird höchstens nach dem Strich.
  static String personen(int n) =>
      '$n\u00a0Rollen und das Geburtstagskind\u00a0– ${n + 1}\u00a0Personen';
  static const reihenfolge =
      'Die Rollen werden immer in dieser Reihenfolge besetzt.';
  static const weniger = 'Eine Rolle weniger';
  static const mehr = 'Eine Rolle mehr';
  static const rollenZahl = 'Zahl der Rollen';
  static const frau = 'Frau';
  static const mann = 'Mann';
  static String jahre(String alter) => '$alter Jahre';

  // Steckbriefe ----------------------------------------------------------------
  static const geburtstagskind = 'Das Geburtstagskind';
  static const geburtstagskindKlein = 'das Geburtstagskind';
  static const burgwartKlein = 'der Burgwart';
  static const steckbriefeHinweis =
      'Diese Steckbriefe dürfen alle sehen. Tippe auf eine Karte, um mehr zu lesen.';

  /// Anzeigenamen für Kanonfelder; was hier fehlt, erscheint unter seinem Feldnamen.
  static const feldLabel = <String, String>{
    'Beziehung zum Burgwart (bekannt)': 'Beziehung zum Burgwart',
    'Comedy-Beteiligung (sichtbar)': 'Was alle mitbekommen',
    'Beziehung zum Burgwart (wahr)': 'Beziehung zum Burgwart – die Wahrheit',
  };

  /// Anzeigename des Kanonfelds [feld].
  static String label(String feld) => feldLabel[feld] ?? feld;

  // Mappen ---------------------------------------------------------------------
  static const mappenErklaerung =
      'Jede Person liest ihre Mappe allein. Tippe auf einen Namen und gib das '
      'Gerät weiter. Öffne die Mappe erst, wenn die richtige Person das Gerät hält.';
  static const gesehen = 'gesehen';
  static String weitergeben(String name) =>
      'Gib das Gerät an $name. Nur $name schaut jetzt hin.';
  static String oeffnen(String name) => 'Ich bin $name – Mappe öffnen';
  static const zudecken = 'Mappe zudecken';
  static String zugedeckt(String name) =>
      'Die Mappe von $name ist wieder zugedeckt.';
  static const zugedecktGeburtstagskind =
      'Die Mappe des Geburtstagskinds ist wieder zugedeckt.';
  static const rollenmappe = 'Rollenmappe';
  static String nurFuer(String name) => 'Nur für $name';

  static const dossierSteckbrief = 'Dein Steckbrief';
  static const dossierKleidung = 'Was du anziehst';
  static const dossierGeheimnis = 'Dein Geheimnis';
  static const dossierWissen = 'Was du weißt';
  static const dossierVerbindungen = 'Wen du kennst';
  static const dossierLuege = 'Lügen und Wahrheit';
  static const dossierGespraeche = 'Deine Gespräche';
  static String phase(int p) => 'Phase $p';
  static const auftraege = 'Deine Aufträge';
  static const wennManDichFragt = 'Wenn man dich fragt';
  static String frag(String ziel) => 'Frag $ziel';
  static const worumEsGeht = 'Worum es geht';
  static String fragt(String von) => '$von fragt';
  static const deineAntwort = 'Deine Antwort';
  static const antwortWahr = 'Sag die Wahrheit.';
  static const antwortAusweichend = 'Weich hier aus.';
  static const antwortGelogen = 'Hier darfst du lügen.';
  static const keineAuftraege = 'In dieser Phase fragst du niemanden.';
  static const niemandFragt = 'In dieser Phase fragt dich niemand.';

  // Detektiv-Mappe -------------------------------------------------------------
  static const detektivWer = 'Wer du bist';
  static const detektivAlibi = 'Wo du warst';
  static const detektivBeobachtet = 'Was du beobachtet hast';
  static const detektivEntscheidungen = 'Deine Entscheidungen';
  static const detektivEntscheidungenHinweis =
      'Die Fragen stehen nicht in dieser Mappe. Du bekommst sie am Abend, '
      'jede erst in ihrer Phase.';
  static const anklage = 'So läuft die Anklage';
  static String schritt(int nr) => 'Schritt $nr';

  // Druck ----------------------------------------------------------------------
  static const druckSteckbriefe = 'Steckbriefe für alle';
  static const druckSteckbriefeHinweis =
      'Die Steckbriefe dürfen alle sehen. Speichere die Datei, öffne sie im '
      'Browser und drucke sie von dort.';
  static const alsDateiSpeichern = 'Als Datei speichern';
  static const vorschau = 'Vorschau';
  static const druckMappen = 'Rollenmappen – geheim';
  static const druckMappenWarnung =
      'Druck die Mappen, ohne hineinzuschauen. Am besten druckt nicht das Geburtstagskind.';
  static String mappeFuer(String name) => 'Mappe für $name';
  static const nurBrowser =
      'Speichern geht nur im Browser. Öffne die App im Browser und drucke von dort.';
  /// Rückmeldung nach dem Anbieten der Datei. Ob sie wirklich gespeichert wurde,
  /// verrät das Teilen-Fenster nicht (ein Abbruch sieht aus wie Erfolg).
  static String erstellt(String datei) => 'Datei erstellt: $datei';
  static String dateiSteckbriefe(int n) => 'gewoelbe-steckbriefe-$n.html';
  static String dateiMappe(int nummer) =>
      'gewoelbe-mappe-${nummer.toString().padLeft(2, '0')}.html';
  static String htmlTitelSteckbriefe(int n) =>
      '$titel – Steckbriefe für $n Rollen';
  static String htmlTitelMappe(String name) =>
      '$titel – $rollenmappe für $name';
}
