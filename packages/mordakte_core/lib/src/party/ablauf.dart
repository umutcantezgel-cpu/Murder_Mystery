import '../util/rng.dart';
import 'besetzung.dart';
import 'enden.dart';
import 'entscheidungen.dart';
import 'erzaehler.dart';
import 'fall_code.dart';
import 'gruppenwahl.dart';
import 'kanon/kanon.dart';

/// Abschnitte eines Partyabends (Master 7.6).
enum PartyPhase { titel, einrichtung, rollen, intro, gespraeche, entscheidungen, gruppenwahl, bonus, resuemee, anklage, finale, aufloesung, ende }

/// Einstellungen der Einrichtung (Master 7.6, Schritt 2).
class Einstellungen {
  final int rollen;
  final String detektiv;
  final FallCode code;
  final bool druck;
  final int rundendauerMinuten;
  const Einstellungen({required this.rollen, required this.detektiv, required this.code, this.druck = false, this.rundendauerMinuten = 30});
}

/// Zusatzschicht über dem Ablauf (Finale §3.14), etwa die Einfluss-Schicht „Dein Moment“. Ohne sie
/// ([Spiel.zusatz] ist `null`) läuft jeder Abschnitt wie heute.
abstract interface class SpielZusatz {
  /// Fakten, die der Detektiv bis einschließlich Runde [bis] sieht: Funde ohne die bis zum
  /// Zwischenresümee verzögerten, dazu, was die Schicht selbst liefert. Teilmenge der Fakten des Pfads.
  Set<String> sichtbar(Spiel s, int bis);

  /// Fakten, die bis einschließlich Runde [bis] über die Schicht selbst kamen (vor jeder Entscheidung
  /// dieser Runde sichtbar); Grundlage der Geklärt-Regel.
  Set<String> geliefert(int bis);

  /// Bausteine, die nach dem Wechsel aus [von] in die Phase von [s] hinter die eigenen kommen.
  List<String> nachWechsel(Spiel s, PartyPhase von);

  /// Verschiebung des Endes (Finale §3.10).
  int get tischbonus;

  /// Mit Schicht folgt auf die Entscheidungen direkt der Bonus.
  bool get ueberspringeGruppenwahl;

  /// Güte des Hinweises im Bonus von [runde]; `null`, wenn niemand etwas zuflüstert.
  Qualitaet? bonusQualitaet(int runde);
}

/// Der Spielablauf als reiner Zustandsautomat. Alle Story-Texte kommen als
/// Baustein-Kennungen aus dem Erzähler; nichts wird erzeugt (Master 7.12).
class Spiel {
  final Kanon kanon;
  final Ermittlung ermittlung;
  final Gruppenwahl gruppe;
  final Enden enden;
  final Besetzung besetzung;
  final Erzaehler erzaehler;

  PartyPhase phase = PartyPhase.titel;
  Einstellungen? _einstellungen;
  String? _pfad;
  int runde = 0;
  final Map<String, String> gewaehlt = {};
  final Map<int, Qualitaet> qualitaeten = {};
  String? angeklagt;

  /// Alle bisher ausgegebenen Bausteine in Reihenfolge.
  final List<String> bausteine = [];

  /// Zusatzschicht (Finale §3.14); `null`: alles wie heute.
  SpielZusatz? zusatz;

  Spiel(this.kanon, {Ermittlung? ermittlung})
      : ermittlung = ermittlung ?? Ermittlung(kanon),
        gruppe = Gruppenwahl(kanon),
        enden = Enden(kanon),
        besetzung = Besetzung(kanon),
        erzaehler = Erzaehler(kanon);

  Einstellungen get einstellungen => _einstellungen ?? (throw StateError('Spiel ist noch nicht eingerichtet'));

  /// Aktiver Täter-Pfad (nur für App-Logik; nie anzeigen vor dem Finale).
  String get pfad => _pfad ?? (throw StateError('Spiel ist noch nicht eingerichtet'));

  List<String> get besetzt => besetzung.besetzt(einstellungen.rollen);

  void _erwarte(PartyPhase p) {
    if (phase != p) throw StateError('erwartet $p, ist $phase');
  }

  /// Einrichtung abschließen: Fall-Code legt den Pfad fest.
  void einrichten(Einstellungen e) {
    if (phase == PartyPhase.titel) phase = PartyPhase.einrichtung;
    _erwarte(PartyPhase.einrichtung);
    besetzung.besetzt(e.rollen);
    if (e.detektiv != 'm' && e.detektiv != 'w') throw ArgumentError('Detektiv m oder w');
    _einstellungen = e;
    _pfad = e.code.pfad(kanon.pfade);
    phase = PartyPhase.rollen;
  }

  /// Zum nächsten Abschnitt, sobald der aktuelle erledigt ist. Eine [zusatz]-Schicht hängt danach ihre
  /// Bausteine an ([SpielZusatz.nachWechsel]).
  void weiter() {
    final von = phase;
    _weiter();
    if (zusatz case final z?) bausteine.addAll(z.nachWechsel(this, von));
  }

  void _weiter() {
    switch (phase) {
      case PartyPhase.titel:
        phase = PartyPhase.einrichtung;
      case PartyPhase.einrichtung:
        throw StateError('Einrichtung über einrichten() abschließen');
      case PartyPhase.rollen:
        phase = PartyPhase.intro;
        bausteine.addAll(erzaehler.intro(this));
      case PartyPhase.intro:
        runde = 1;
        phase = PartyPhase.gespraeche;
        bausteine.addAll(erzaehler.rundenStart(runde, besetzt: (f) => besetzung.istBesetzt(f, einstellungen.rollen)));
      case PartyPhase.gespraeche:
        phase = PartyPhase.entscheidungen;
      case PartyPhase.entscheidungen:
        final offen = [for (final e in ermittlung.runde(runde)) if (!gewaehlt.containsKey(e.id)) e.id];
        if (offen.isNotEmpty) throw StateError('offene Entscheidungen: $offen');
        if (zusatz case final z? when z.ueberspringeGruppenwahl) {
          // Finale §3.1: Mit Schicht flüstert der Tisch je nach Zusammenhalt; keine Gruppenwahl.
          if (z.bonusQualitaet(runde) case final q?) qualitaeten[runde] = q;
          phase = PartyPhase.bonus;
          bausteine.addAll(erzaehler.bonus(this));
        } else {
          phase = PartyPhase.gruppenwahl;
        }
      case PartyPhase.gruppenwahl:
        if (!qualitaeten.containsKey(runde)) throw StateError('Gruppenwahl fehlt');
        phase = PartyPhase.bonus;
        bausteine.addAll(erzaehler.bonus(this));
      case PartyPhase.bonus:
        phase = PartyPhase.resuemee;
        bausteine.addAll(erzaehler.resuemee(this));
      case PartyPhase.resuemee:
        if (runde < 3) {
          runde++;
          phase = PartyPhase.gespraeche;
          bausteine.addAll(erzaehler.rundenStart(runde, besetzt: (f) => besetzung.istBesetzt(f, einstellungen.rollen)));
        } else {
          phase = PartyPhase.anklage;
          bausteine.addAll(erzaehler.anklage());
        }
      case PartyPhase.anklage:
        if (angeklagt == null) throw StateError('Anklage fehlt');
        phase = PartyPhase.finale;
        bausteine.addAll(erzaehler.finale(this));
      case PartyPhase.finale:
        phase = PartyPhase.aufloesung;
        bausteine.addAll(erzaehler.aufloesung(this));
      case PartyPhase.aufloesung:
        phase = PartyPhase.ende;
      case PartyPhase.ende:
        throw StateError('Spiel ist zu Ende');
    }
  }

  /// Anzeigereihenfolge der Optionen: je Fall-Code gemischt, damit die Lage
  /// im Kanon nichts verrät (E-025). Gleicher Code, gleiche Reihenfolge.
  List<EntscheidungsOption> optionen(String entscheidungId) {
    final e = ermittlung.entscheidung(entscheidungId);
    final liste = [...e.optionen];
    Rng(einstellungen.code.seed ^ Rng.hashString(entscheidungId)).shuffle(liste);
    return liste;
  }

  /// Eine Entscheidung der laufenden Runde treffen.
  List<Aufdeckung> waehle(String entscheidungId, String optionId) {
    _erwarte(PartyPhase.entscheidungen);
    final e = ermittlung.entscheidung(entscheidungId);
    if (e.runde != runde) throw StateError('$entscheidungId gehört zu Runde ${e.runde}');
    if (gewaehlt.containsKey(entscheidungId)) throw StateError('$entscheidungId ist schon entschieden');
    e.option(optionId);
    gewaehlt[entscheidungId] = optionId;
    return ermittlung.aufdecken(optionId, pfad);
  }

  /// Gruppenwahl der laufenden Runde: [kooperativ] zählt die A-Stimmen ohne
  /// die Täterrolle. Die Zahl wird nie angezeigt.
  Qualitaet abstimmen({required int kooperativ, required bool taeterSabotiert}) {
    _erwarte(PartyPhase.gruppenwahl);
    final andere = einstellungen.rollen - 1;
    if (kooperativ < 0 || kooperativ > andere) throw RangeError.range(kooperativ, 0, andere, 'kooperativ');
    return qualitaeten[runde] = gruppe.auswerten(rollen: einstellungen.rollen, kooperativ: kooperativ, taeterSabotiert: taeterSabotiert);
  }

  void anklagen(String person) {
    _erwarte(PartyPhase.anklage);
    if (!kanon.kernverdaechtige.contains(person)) throw ArgumentError('Anklage nur gegen Kernverdächtige');
    angeklagt = person;
  }

  /// Fakten, die der Detektiv bis einschließlich Runde [bis] aufgedeckt hat.
  Set<String> bekannteFakten([int bis = 3]) => {
        for (final e in gewaehlt.entries)
          if (ermittlung.entscheidung(e.key).runde <= bis) ...ermittlung.faktenVon(e.value, pfad),
      };

  /// Fakten, die der Detektiv bis einschließlich Runde [bis] sieht; ohne [zusatz] genau [bekannteFakten].
  Set<String> sichtbareFakten([int bis = 3]) => zusatz?.sichtbar(this, bis) ?? bekannteFakten(bis);

  Set<String> restmenge([int bis = 3]) => ermittlung.restmenge(sichtbareFakten(bis));

  /// Geklärt-Regel (Finale §3.10, nur mit [zusatz]): Alle Fakten, die die richtige Option im Pfad liefern
  /// würde, kamen schon vor dem Öffnen der Entscheidung über die Schicht. Hebt Punkte nur an.
  bool geklaert(String entscheidungId) {
    final z = zusatz;
    if (z == null) return false;
    final e = ermittlung.entscheidung(entscheidungId);
    final soll = ermittlung.faktenVon(e.richtig[pfad]!, pfad);
    return soll.isNotEmpty && z.geliefert(e.runde).containsAll(soll);
  }

  int get punkte => [
        for (final e in gewaehlt.entries)
          if (ermittlung.istRichtig(e.key, e.value, pfad) || geklaert(e.key)) e,
      ].length;

  /// Wert für die Endenmatrix: ohne [zusatz] die Punkte, mit ihr Punkte + Tischbonus in 0 … 9 (Finale §3.10).
  int get endwert {
    final z = zusatz;
    if (z == null) return punkte;
    final w = punkte + z.tischbonus;
    final hoechstens = ermittlung.entscheidungen.length;
    return w < 0 ? 0 : (w > hoechstens ? hoechstens : w);
  }

  /// Ende nach der Matrix; richtig oder falsch bestimmt allein die Anklage.
  EndeRegel get ende => enden.ende(endwert, angeklagt == pfad);
}
